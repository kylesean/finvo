"""Graph routing: entry, after agent, after tools."""

from typing import Literal

from langchain_core.messages import AIMessage, ToolMessage

from app.core.langgraph.agent.state import AgentState
from app.core.langgraph.tools.tool_metadata import should_end_turn
from app.core.logging import logger

_END: Literal["__end__"] = "__end__"


def route_entry(state: AgentState) -> Literal["direct_execute", "agent"]:
    if state.get("ui_mode") == "direct_execute" and state.get("tool_name"):
        return "direct_execute"
    return "agent"


def route_after_agent(state: AgentState) -> Literal["tools", "__end__"]:
    messages = state.get("messages", [])
    if not messages:
        return _END
    last = messages[-1]
    if isinstance(last, AIMessage) and getattr(last, "tool_calls", None):
        return "tools"
    return _END


def route_after_tools(state: AgentState) -> Literal["agent", "__end__"]:
    messages = state.get("messages", [])
    if not messages:
        return _END
    last = messages[-1]
    if not isinstance(last, ToolMessage):
        return _END
    if state.get("ui_mode") == "direct_execute":
        return "agent"
    tool_name = getattr(last, "name", "")
    if should_end_turn(tool_name):
        logger.info("route_tools_end", tool=tool_name)
        return _END
    return "agent"
