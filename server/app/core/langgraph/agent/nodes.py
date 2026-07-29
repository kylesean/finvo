"""Node 函数定义

LangGraph 节点函数，每个节点专注于单一职责。
"""

from __future__ import annotations

from collections.abc import Callable
from typing import Any, cast

from langchain_core.language_models import BaseChatModel
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage, SystemMessage
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import BaseTool

from app.core.langgraph.agent.multimodal import (
    build_multimodal_content,
    load_image_parts,
    vision_unsupported_message,
)
from app.core.langgraph.agent.state import AgentState
from app.core.logging import logger

# DuckDuckGo 工具名称常量（用于搜索策略路由）
_DDG_TOOL_NAME = "duckduckgo_results_json"

# Responses API 内置搜索工具声明
_BUILTIN_WEB_SEARCH: dict[str, str] = {"type": "web_search"}


def _resolve_search_tools(
    llm: BaseChatModel,
    tools: list[BaseTool],
) -> list[BaseTool | dict[str, Any]]:
    """根据模型 API 协议动态选择搜索工具。

    策略:
    - Responses API 模型: 使用厂商内置 web_search（服务端执行，无需 ToolNode）
    - Chat Completions 模型 (如 DeepSeek): 保留 DuckDuckGo 工具（ToolNode 执行）
    """
    uses_responses_api = getattr(llm, "use_responses_api", False)

    if uses_responses_api:
        # 移除 ddg，替换为内置 web_search
        resolved: list[BaseTool | dict[str, Any]] = [t for t in tools if getattr(t, "name", None) != _DDG_TOOL_NAME]
        resolved.append(_BUILTIN_WEB_SEARCH)
        return resolved

    # Chat Completions 模型保持 ddg 不变
    return list(tools)


def create_agent_node(
    llm: BaseChatModel,
    tools: list[BaseTool],
    system_prompt: str,
) -> Callable[[AgentState, RunnableConfig], Any]:
    """创建 Agent 节点

    Agent 节点调用 LLM 生成响应，支持动态工具过滤和搜索策略路由。
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

        # Extract and consolidate system messages into a single leading SystemMessage
        system_contents: list[str] = [system_prompt]
        non_system_messages: list[BaseMessage] = []

        for m in messages:
            if isinstance(m, SystemMessage):
                if m.content:
                    system_contents.append(str(m.content))
            else:
                non_system_messages.append(m)

        # Ephemeral multimodal enrichment: build what the MODEL sees without touching
        # state["messages"] (so the checkpoint keeps the compact plain-text user
        # message). Image parts come from the middleware's config cache on the fresh
        # path; on resume (middleware bypassed) we rebuild them from the stored
        # attachment id references. Only the local prompt copy is enriched.
        target_idx: int | None = None
        for idx in range(len(non_system_messages) - 1, -1, -1):
            m = non_system_messages[idx]
            if isinstance(m, HumanMessage):
                if (getattr(m, "additional_kwargs", {}) or {}).get("attachment_ids"):
                    target_idx = idx
                break

        image_parts = cfg.get("_image_multimodal_parts")
        if target_idx is not None and image_parts is None:
            ref_ids = (getattr(non_system_messages[target_idx], "additional_kwargs", {}) or {})["attachment_ids"]
            image_parts = await load_image_parts(ref_ids, cfg.get("user_uuid"))

        prompt_messages: list[BaseMessage] = [SystemMessage(content="\n\n".join(system_contents))] + list(
            non_system_messages
        )
        if target_idx is not None and image_parts:
            original = non_system_messages[target_idx]
            user_text = original.content if isinstance(original.content, str) else ""
            # +1 accounts for the single consolidated SystemMessage prepended above.
            prompt_messages[target_idx + 1] = HumanMessage(
                content=build_multimodal_content(user_text, image_parts),
                additional_kwargs=getattr(original, "additional_kwargs", {}),
            )

        # 支持 SkillConstraintMiddleware 动态过滤工具
        filtered_tools = cfg.get("filtered_tools")
        current_tools = cast(list[BaseTool], filtered_tools or state.get("filtered_tools") or tools)

        # 搜索策略路由: Responses API → 内置 web_search, Chat Completions → ddg
        resolved_tools = _resolve_search_tools(llm, current_tools)

        bound_llm = llm.bind_tools(resolved_tools)
        response = await bound_llm.ainvoke(prompt_messages, config)

        logger.debug(
            "agent_node_response",
            has_tool_calls=bool(getattr(response, "tool_calls", None)),
            content_length=len(response.content) if response.content else 0,
            tools_count=len(current_tools),
        )

        return {"messages": [response]}

    return agent_node


# === 内部工具注册表 ===
# GenUI 直接执行的工具，不暴露给 LLM
# 新增工具只需在此添加
def _get_internal_tools() -> dict[str, BaseTool]:
    """延迟加载内部工具，避免循环导入"""
    from app.core.langgraph.tools.space_association_tools import associate_transactions_to_space
    from app.core.langgraph.tools.transfer_tools import execute_transfer

    return {
        "execute_transfer": execute_transfer,
        "associate_transactions_to_space": associate_transactions_to_space,
    }


def create_direct_execute_node(
    tools: list[BaseTool],  # 保留参数以兼容图构建接口
) -> Callable[[AgentState, RunnableConfig], Any]:
    """创建直接执行节点

    用于 GenUI 场景：用户在 UI 上操作完成后，跳过 LLM 直接执行工具。

    协议:
        - state.tool_name: 要执行的工具名（需在 INTERNAL_TOOLS 注册）
        - state.tool_params: 工具参数
    """
    INTERNAL_TOOLS = _get_internal_tools()

    async def direct_execute_node(state: AgentState, config: RunnableConfig) -> dict[str, Any]:
        tool_name = state.get("tool_name")
        tool_params = state.get("tool_params")

        if not tool_name or not tool_params:
            logger.warning("direct_execute_missing_params", tool_name=tool_name, has_params=bool(tool_params))
            return {
                "messages": [AIMessage(content="错误：未指定要执行的操作。")],
                "ui_mode": "idle",
            }

        tool = INTERNAL_TOOLS.get(tool_name)
        if not tool:
            logger.error("direct_execute_tool_not_found", tool_name=tool_name, available=list(INTERNAL_TOOLS.keys()))
            return {
                "messages": [AIMessage(content=f"系统错误：工具 {tool_name} 未注册。")],
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

            return {
                "messages": [AIMessage(content="")],  # 静默，让 UI 组件展示结果
                "ui_mode": "idle",
                "tool_name": None,
                "tool_params": None,
                "direct_execute_result": {
                    "tool_name": tool_name,
                    "success": True,
                    "data": result if isinstance(result, dict) else {"result": result},
                    "surface_id": tool_params.get("surface_id"),
                },
            }
        except Exception as e:
            logger.error("direct_execute_error", tool_name=tool_name, error=str(e))
            return {
                "messages": [AIMessage(content=f"⚠️ 操作执行失败：{str(e)}")],
                "ui_mode": "idle",
                "tool_name": None,
                "tool_params": None,
                "direct_execute_result": None,
            }

    return direct_execute_node
