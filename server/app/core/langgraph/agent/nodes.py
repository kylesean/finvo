"""Agent and direct-execute nodes."""

from __future__ import annotations

import asyncio
from collections.abc import Callable
from typing import Any

from langchain_core.language_models import BaseChatModel
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage, RemoveMessage, SystemMessage
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import BaseTool
from openai import APIConnectionError, APITimeoutError, RateLimitError
from tenacity import AsyncRetrying, retry_if_exception, stop_after_attempt, wait_exponential

from app.core.config import settings
from app.core.exceptions import to_client_error
from app.core.langgraph.agent.multimodal import build_multimodal_content, load_image_parts, vision_unsupported_message
from app.core.langgraph.agent.state import AgentState
from app.core.logging import logger

_DDG_TOOL = "duckduckgo_results_json"
_BUILTIN_WEB_SEARCH: dict[str, str] = {"type": "web_search"}
_RETRYABLE = (APIConnectionError, APITimeoutError, RateLimitError, asyncio.TimeoutError)


def is_retryable(e: BaseException) -> bool:
    if isinstance(e, _RETRYABLE):
        return True
    status = getattr(e, "status_code", None)
    return isinstance(status, int) and status >= 500


def _search_tools(llm: BaseChatModel, tools: list[BaseTool]) -> list[BaseTool | dict[str, Any]]:
    if getattr(llm, "use_responses_api", False):
        return [t for t in tools if getattr(t, "name", None) != _DDG_TOOL] + [_BUILTIN_WEB_SEARCH]
    return list(tools)


def _skill_tools(state: AgentState, base: list[BaseTool]) -> list[BaseTool]:
    active = state.get("active_skill")
    if not active:
        return list(base)
    from app.core.skills.loader import SkillLoader

    allowed: set[str] | None = None
    for skill in SkillLoader().load_skills():
        if skill.name == active and skill.allowed_tools:
            allowed = set(skill.allowed_tools)
            break
    if not allowed:
        return list(base)
    from app.core.langgraph.tools.filesystem_tools import filesystem_tools

    privileged = {t.name: t for t in filesystem_tools}
    names = set(allowed) | {"load_skill", "unload_skill"}
    picked = [t for t in base if t.name in names]
    picked += [privileged[n] for n in allowed if n in privileged and n not in {t.name for t in picked}]
    return picked


def create_agent_node(
    llm: BaseChatModel, tools: list[BaseTool], system_prompt: str
) -> Callable[[AgentState, RunnableConfig], Any]:
    async def agent_node(state: AgentState, config: RunnableConfig) -> dict[str, list[BaseMessage]]:
        messages = state["messages"]
        cfg = config.get("configurable", {})

        if cfg.get("_has_images"):
            from app.services.llm import LLMRegistry

            if not LLMRegistry.supports_vision():
                from app.core.langgraph.tools.context import current_session_language

                return {"messages": [AIMessage(content=vision_unsupported_message(current_session_language.get()))]}

        system_text, history = _split_system(messages, system_prompt)
        history = await _attach_images(history, cfg)
        prompt = _trim_history(history, llm, system_text)
        current_tools = _search_tools(llm, _skill_tools(state, tools))
        response = await _invoke_llm(llm.bind_tools(current_tools), prompt, config)
        return {"messages": [response, *_stale_system_removals(messages)]}

    return agent_node


def _split_system(messages: list[BaseMessage], base_prompt: str) -> tuple[str, list[BaseMessage]]:
    latest: str | None = None
    rest: list[BaseMessage] = []
    for m in messages:
        if isinstance(m, SystemMessage) and m.content:
            latest = str(m.content)
        else:
            rest.append(m)
    text = base_prompt if latest is None else f"{base_prompt}\n\n{latest}"
    return text, rest


async def _attach_images(history: list[BaseMessage], cfg: dict[str, Any]) -> list[BaseMessage]:
    parts = cfg.get("_image_multimodal_parts")
    if parts is None:
        for m in reversed(history):
            ids = (getattr(m, "additional_kwargs", {}) or {}).get("attachment_ids")
            if isinstance(m, HumanMessage) and ids:
                parts = await load_image_parts(ids, cfg.get("user_uuid"))
                break
    if not parts:
        return history
    out = list(history)
    for i, m in enumerate(out):
        ids = (getattr(m, "additional_kwargs", {}) or {}).get("attachment_ids")
        if isinstance(m, HumanMessage) and ids:
            text = m.content if isinstance(m.content, str) else ""
            out[i] = HumanMessage(
                content=build_multimodal_content(text, parts),
                additional_kwargs=getattr(m, "additional_kwargs", {}),
            )
            break
    return out


def _trim_history(history: list[BaseMessage], llm: BaseChatModel, system_text: str) -> list[BaseMessage]:
    from app.utils.graph import prepare_messages

    return prepare_messages(list(history), llm, system_prompt=system_text)


async def _invoke_llm(bound_llm: Any, prompt: list[BaseMessage], config: RunnableConfig) -> AIMessage:
    try:
        async for attempt in AsyncRetrying(
            stop=stop_after_attempt(settings.MAX_LLM_CALL_RETRIES),
            wait=wait_exponential(multiplier=1, min=2, max=10),
            retry=retry_if_exception(is_retryable),
            reraise=True,
        ):
            with attempt:
                return await bound_llm.ainvoke(prompt, config)
    except Exception as e:
        logger.error("agent_node_llm_failed", error=str(e), exc_info=True)
        raise
    raise AssertionError("unreachable")


def _stale_system_removals(messages: list[BaseMessage]) -> list[RemoveMessage]:
    ids = [m.id for m in messages if isinstance(m, SystemMessage) and getattr(m, "id", None)]
    return [RemoveMessage(id=sid) for sid in ids[:-1]] if len(ids) > 1 else []


def _internal_tools() -> dict[str, BaseTool]:
    from app.core.langgraph.tools.space_association_tools import associate_transactions_to_space
    from app.core.langgraph.tools.transfer_tools import execute_transfer

    return {"execute_transfer": execute_transfer, "associate_transactions_to_space": associate_transactions_to_space}


def create_direct_execute_node() -> Callable[[AgentState, RunnableConfig], Any]:
    tools = _internal_tools()

    async def direct_execute_node(state: AgentState, config: RunnableConfig) -> dict[str, Any]:
        name = state.get("tool_name")
        params = state.get("tool_params")
        if not name or not params:
            return {"messages": [AIMessage(content="Error: no action specified.")], "ui_mode": "idle"}
        tool = tools.get(name)
        if tool is None:
            return {"messages": [AIMessage(content="This action is not available right now.")], "ui_mode": "idle"}
        try:
            result = await tool.ainvoke(params, config=config)
            ok = not (isinstance(result, dict) and result.get("success") is False)
            return {
                "messages": [AIMessage(content="")],
                "ui_mode": "idle",
                "tool_name": None,
                "tool_params": None,
                "direct_execute_result": {
                    "tool_name": name,
                    "success": ok,
                    "data": result if isinstance(result, dict) else {"result": result},
                    "surface_id": params.get("surface_id"),
                    "error": result.get("message") if isinstance(result, dict) and not ok else None,
                },
            }
        except Exception as e:
            logger.error("direct_execute_error", tool=name, error=str(e), exc_info=True)
            return {
                "messages": [AIMessage(content=f"Action failed: {to_client_error(e)}")],
                "ui_mode": "idle",
                "tool_name": None,
                "tool_params": None,
                "direct_execute_result": None,
            }

    return direct_execute_node
