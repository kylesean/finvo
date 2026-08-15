"""LangGraph node functions.

Each node focuses on a single responsibility.
"""

from __future__ import annotations

import asyncio
from collections.abc import Callable
from functools import lru_cache
from typing import Any, cast

from langchain_core.language_models import BaseChatModel
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage, SystemMessage
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import BaseTool
from openai import APIError, APITimeoutError, RateLimitError
from tenacity import (
    AsyncRetrying,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from app.core.config import settings
from app.core.exceptions import to_client_error
from app.core.langgraph.agent.multimodal import (
    build_multimodal_content,
    load_image_parts,
    vision_unsupported_message,
)
from app.core.langgraph.agent.state import AgentState
from app.core.logging import logger

# DuckDuckGo tool name constant (used for search strategy routing)
_DDG_TOOL_NAME = "duckduckgo_results_json"

# Responses API built-in web search tool declaration
_BUILTIN_WEB_SEARCH: dict[str, str] = {"type": "web_search"}

# Exceptions that indicate a transient LLM upstream failure and are worth
# retrying (mirrors the retry policy in app.services.llm.LLMService).
_AGENT_RETRYABLE = (RateLimitError, APITimeoutError, APIError, asyncio.TimeoutError)


def _resolve_search_tools(
    llm: BaseChatModel,
    tools: list[BaseTool],
) -> list[BaseTool | dict[str, Any]]:
    """Dynamically select search tools based on the model's API protocol.

    Strategy:
    - Responses API models: use the vendor built-in web_search (server-side, no ToolNode needed)
    - Chat Completions models (e.g. DeepSeek): keep the DuckDuckGo tool (ToolNode execution)
    """
    uses_responses_api = getattr(llm, "use_responses_api", False)

    if uses_responses_api:
        # Remove ddg, replace with built-in web_search
        resolved: list[BaseTool | dict[str, Any]] = [t for t in tools if getattr(t, "name", None) != _DDG_TOOL_NAME]
        resolved.append(_BUILTIN_WEB_SEARCH)
        return resolved

    # Chat Completions models keep ddg unchanged
    return list(tools)


# Whenever a skill grants its allowed tools, the agent must keep orchestrating.
# load_skill / unload_skill are always preserved so the model can still switch
# or disengage a skill.
_LOAD_SKILL_NAME = "load_skill"
_UNLOAD_SKILL_NAME = "unload_skill"


@lru_cache(maxsize=1)
def _skill_allowed_tools_index() -> dict[str, set[str]]:
    """Build a static skill name -> allowed-tools index from installed skills.

    Skills are static files (SKILL.md frontmatter); caching keeps the per-turn
    skill scoping cheap while still reflecting the manifests on disk.
    """
    from app.core.skills.loader import SkillLoader

    index: dict[str, set[str]] = {}
    for skill in SkillLoader().load_skills():
        if skill.allowed_tools:
            index[skill.name] = set(skill.allowed_tools)
    return index


def _resolve_skill_tools(state: AgentState, base_tools: list[BaseTool]) -> list[BaseTool]:
    """Return the current turn's toolset based on the active skill.

    - No active skill (or a skill without an allowed-tools constraint): full base
      toolset is used, matching the default behavior.
    - Active skill with allowed-tools: narrow the base toolset to that whitelist
      and inject any privileged tools the skill declares (e.g. `execute`,
      `read_file`), so the skill can actually run its scripts.
    - `load_skill` is always retained so the model can switch/disengage skills.
    """
    active_skill = state.get("active_skill")
    if not active_skill:
        return list(base_tools)

    allowed = _skill_allowed_tools_index().get(active_skill)
    if not allowed:
        return list(base_tools)

    narrowed = [t for t in base_tools if t.name in allowed]
    injected = [t for t in _privileged_filesystem_tools() if t.name in allowed]

    # Keep the skill-orchestration tools available so the model can switch or
    # unload the active skill (without them, the whitelist would lock the model
    # into the skill forever).
    _orchestration_names = {_LOAD_SKILL_NAME, _UNLOAD_SKILL_NAME}
    for t in base_tools:
        if t.name in _orchestration_names and not any(x.name == t.name for x in narrowed):
            narrowed.append(t)

    resolved = narrowed + injected
    logger.debug(
        "agent_skill_tools_scoped",
        skill=active_skill,
        narrowed_count=len(narrowed),
        injected_count=len(injected),
        allowed=sorted(allowed),
    )
    return resolved


def _privileged_filesystem_tools() -> list[BaseTool]:
    """Lazily load the privileged filesystem tools (kept off the default toolset)."""
    from app.core.langgraph.tools.filesystem_tools import filesystem_tools

    return filesystem_tools


def create_agent_node(
    llm: BaseChatModel,
    tools: list[BaseTool],
    system_prompt: str,
) -> Callable[[AgentState, RunnableConfig], Any]:
    """Create the Agent node.

    The agent node invokes the LLM to generate a response, supporting
    dynamic tool filtering and search strategy routing.
    """

    async def agent_node(state: AgentState, config: RunnableConfig) -> dict[str, list[BaseMessage]]:
        messages = state["messages"]
        cfg = config.get("configurable", {})

        # Vision guard: a non-vision model must not receive images. Short-circuit here
        # (before any LLM call) with a localized assistant message; having no
        # tool_calls, route_after_agent sends us straight to END. Mirrors the official
        # `before_agent` + jump_to:"end" pattern and yields a turn identical in the
        # live stream and in history. On resume the middleware is bypassed, so
        # `_has_images` is absent and the guard is skipped — which is fine: a
        # non-vision+image turn is refused on its first (fresh) iteration and never
        # reaches a resumable interrupted state.
        if cfg.get("_has_images"):
            from app.services.llm import LLMRegistry

            if not LLMRegistry.supports_vision():
                from app.core.langgraph.tools.context import current_session_language

                return {"messages": [AIMessage(content=vision_unsupported_message(current_session_language.get()))]}

        # Extract and consolidate system messages into a single leading SystemMessage.
        # The middleware injects a fresh SystemMessage (dynamic context + skill catalog)
        # on EVERY turn, and every turn's copy is persisted into the checkpoint — so
        # only the most recent one is meaningful. Merging all of them would grow the
        # prompt linearly with turn count (N copies of the date/skill catalog).
        system_contents: list[str] = [system_prompt]
        non_system_messages: list[BaseMessage] = []
        latest_system_content: str | None = None

        for m in messages:
            if isinstance(m, SystemMessage) and m.content:
                latest_system_content = str(m.content)
            else:
                non_system_messages.append(m)

        if latest_system_content:
            system_contents.append(latest_system_content)

        # Ephemeral multimodal enrichment: build what the MODEL sees without touching
        # state["messages"] (so the checkpoint keeps the compact plain-text user
        # message). Image parts come from the middleware's config cache on the fresh
        # path; on resume (middleware bypassed) we rebuild them from the stored
        # attachment id references. Only the local prompt copy is enriched.
        image_parts = cfg.get("_image_multimodal_parts")
        if image_parts is None:
            for m in reversed(non_system_messages):
                if isinstance(m, HumanMessage) and (getattr(m, "additional_kwargs", {}) or {}).get("attachment_ids"):
                    ref_ids = (getattr(m, "additional_kwargs", {}) or {})["attachment_ids"]
                    image_parts = await load_image_parts(ref_ids, cfg.get("user_uuid"))
                    break

        # Token budget: trim the non-system history to fit the model context
        # window; the consolidated system prompt is preserved for prompt cache.
        from app.utils.graph import prepare_messages

        prompt_messages = prepare_messages(
            list(non_system_messages),
            llm,
            system_prompt="\n\n".join(system_contents),
        )

        # Re-attach image parts to the multimodal HumanMessage after trimming
        # (locate by attachment_ids, not positional index — trimming may drop
        # older turns).
        if image_parts:
            for i, msg in enumerate(prompt_messages):
                if isinstance(msg, HumanMessage) and (getattr(msg, "additional_kwargs", {}) or {}).get(
                    "attachment_ids"
                ):
                    user_text = msg.content if isinstance(msg.content, str) else ""
                    prompt_messages[i] = HumanMessage(
                        content=build_multimodal_content(user_text, image_parts),
                        additional_kwargs=getattr(msg, "additional_kwargs", {}),
                    )
                    break

        # Tool scoping: an explicit `filtered_tools` in config overrides everything;
        # otherwise derive the toolset from the active skill (if any).
        configured_filtered = cfg.get("filtered_tools")
        if configured_filtered is not None:
            current_tools = list(cast(list[BaseTool], configured_filtered))
            logger.debug("agent_using_configured_filtered_tools", count=len(current_tools))
        else:
            current_tools = _resolve_skill_tools(state, tools)

        # Search strategy routing: Responses API → built-in web_search, Chat Completions → ddg
        resolved_tools = _resolve_search_tools(llm, current_tools)

        bound_llm = llm.bind_tools(resolved_tools)
        try:
            # Retry transient upstream failures (rate-limit/timeout/API error)
            # instead of failing the turn on a single blip. Non-recoverable errors
            # are not retried and propagate immediately.
            async for attempt in AsyncRetrying(
                stop=stop_after_attempt(settings.MAX_LLM_CALL_RETRIES),
                wait=wait_exponential(multiplier=1, min=2, max=10),
                retry=retry_if_exception_type(_AGENT_RETRYABLE),
                reraise=True,
            ):
                with attempt:
                    response = await bound_llm.ainvoke(prompt_messages, config)
        except Exception as e:
            # Do NOT write a fabricated "service unavailable" AIMessage into
            # state here: it would be persisted to the checkpoint and pollute
            # conversation history/search. Instead propagate so the stream layer
            # emits an error event (processor.py) and no fake turn is recorded.
            logger.error("agent_node_llm_failed", error=str(e), exc_info=True)
            raise

        logger.debug(
            "agent_node_response",
            has_tool_calls=bool(getattr(response, "tool_calls", None)),
            content_length=len(response.content) if response.content else 0,
            tools_count=len(current_tools),
        )

        # Per-turn cleanup of injected SystemMessages: the middleware injects a
        # fresh SystemMessage (dynamic context + skill catalog) into every turn's
        # input, so the checkpoint would otherwise accumulate one copy per turn.
        # Only the most recent is meaningful (the prompt is consolidated above) —
        # emit RemoveMessage for stale copies so the checkpoint stays bounded and
        # resume/history reads never traverse N system messages.
        from langchain_core.messages import RemoveMessage

        system_ids = []
        for m in messages:
            msg_id = getattr(m, "id", None)
            if isinstance(m, SystemMessage) and msg_id is not None:
                system_ids.append(msg_id)
        updates: list[BaseMessage] = [response]
        if len(system_ids) > 1:
            updates.extend(RemoveMessage(id=sid) for sid in system_ids[:-1])

        return {"messages": updates}

    return agent_node


# === Internal tool registry ===
# Tools executed directly by GenUI, not exposed to the LLM.
# Add new tools here.
def _get_internal_tools() -> dict[str, BaseTool]:
    """Lazily load internal tools to avoid circular imports."""
    from app.core.langgraph.tools.space_association_tools import associate_transactions_to_space
    from app.core.langgraph.tools.transfer_tools import execute_transfer

    return {
        "execute_transfer": execute_transfer,
        "associate_transactions_to_space": associate_transactions_to_space,
    }


def create_direct_execute_node() -> Callable[[AgentState, RunnableConfig], Any]:
    """Create the direct-execute node.

    Used in GenUI scenarios: after the user completes a UI action, skip the
    LLM and execute the tool directly.

    Protocol:
        - state.tool_name: name of the tool to execute (must be registered in internal_tools)
        - state.tool_params: tool parameters
    """
    internal_tools = _get_internal_tools()

    async def direct_execute_node(state: AgentState, config: RunnableConfig) -> dict[str, Any]:
        tool_name = state.get("tool_name")
        tool_params = state.get("tool_params")

        if not tool_name or not tool_params:
            logger.warning("direct_execute_missing_params", tool_name=tool_name, has_params=bool(tool_params))
            return {
                "messages": [AIMessage(content="Error: no action specified.")],
                "ui_mode": "idle",
            }

        tool = internal_tools.get(tool_name)
        if not tool:
            logger.error("direct_execute_tool_not_found", tool_name=tool_name, available=list(internal_tools.keys()))
            return {
                # Generic, user-safe copy: never surface internal tool-registration
                # details to the client or persist them into the checkpoint.
                "messages": [AIMessage(content="This action is not available right now.")],
                "ui_mode": "idle",
            }

        logger.debug(
            "direct_execute_invoking",
            tool_name=tool_name,
            params_keys=list(tool_params.keys()),
        )

        try:
            result = await tool.ainvoke(tool_params, config=config)

            logger.info("direct_execute_success", tool_name=tool_name)

            # S-I: propagate the tool's OWN success flag honestly. Some tools
            # (e.g. execute_transfer) catch their failures and return
            # {"success": False, "message": ...} instead of raising — wrapping
            # that as success=True would make the event generator emit nothing
            # (silent failure) because its component emission is gated on
            # `success`. Carry the error text for the client-facing error event.
            inner_success = True
            error_message: str | None = None
            if isinstance(result, dict) and result.get("success") is False:
                inner_success = False
                error_message = result.get("message") or "Action failed"

            return {
                "messages": [AIMessage(content="")],  # Silent — let the UI component show the result
                "ui_mode": "idle",
                "tool_name": None,
                "tool_params": None,
                "direct_execute_result": {
                    "tool_name": tool_name,
                    "success": inner_success,
                    "data": result if isinstance(result, dict) else {"result": result},
                    "surface_id": tool_params.get("surface_id"),
                    "error": error_message,
                },
            }
        except Exception as e:
            logger.error("direct_execute_error", tool_name=tool_name, error=str(e), exc_info=True)
            return {
                "messages": [AIMessage(content=f"Action failed: {to_client_error(e)}")],
                "ui_mode": "idle",
                "tool_name": None,
                "tool_params": None,
                "direct_execute_result": None,
            }

    return direct_execute_node
