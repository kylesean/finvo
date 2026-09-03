"""Graph routing: entry, after agent, after tools."""

import json
from typing import Any, Literal

from langchain_core.messages import AIMessage, ToolMessage

from app.core.langgraph.agent.state import AgentState
from app.core.langgraph.tools.tool_metadata import should_end_turn
from app.core.logging import logger

_END: Literal["__end__"] = "__end__"

# How many times a failed write tool may loop back to the model for
# self-correction before the turn ends. Counted as the current streak of
# failed write-tool results since the last successful one, so an old failure
# never poisons a later turn.
_MAX_WRITE_SELF_CORRECTS = 3


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


def _write_result_failed(message: ToolMessage) -> bool:
    """True when a tool's structured result reports failure.

    Write tools swallow their own exceptions and return ``{"success": False}``
    dicts, so ``ToolMessage.status`` stays "success" even on failure — the
    payload is the only reliable signal. ``write_file`` signals errors as
    plain "Error: ..." strings instead.
    """
    content = message.content
    if isinstance(content, str):
        try:
            content = json.loads(content)
        except (json.JSONDecodeError, TypeError):
            return content.startswith("Error")
    if isinstance(content, str):
        # Decoded JSON string (write_file's "Error: ..." convention).
        return content.startswith("Error")
    return isinstance(content, dict) and content.get("success") is False


def _write_failure_streak(messages: list[Any]) -> int:
    """Count consecutive failed write-tool results, newest first.

    The scan stops at the first successful write result, so the streak only
    covers the current self-correction attempt, never historical failures
    from earlier turns.
    """
    streak = 0
    for message in reversed(messages):
        if not isinstance(message, ToolMessage) or not should_end_turn(getattr(message, "name", "")):
            continue
        if _write_result_failed(message):
            streak += 1
        else:
            break
    return streak


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
        if _write_result_failed(last) and _write_failure_streak(messages) <= _MAX_WRITE_SELF_CORRECTS:
            # Loop the failure back to the model: the structured error rides
            # in the ToolMessage, so the model can correct its input and
            # retry (or ask the user) instead of the turn ending silently on
            # the first failure. Bounded by _MAX_WRITE_SELF_CORRECTS and the
            # graph's recursion_limit; the idempotency keys on booking tools
            # make retries of partially-succeeded batches replay rather than
            # double-book.
            logger.info("route_tools_self_correct", tool=tool_name)
            return "agent"
        logger.info("route_tools_end", tool=tool_name)
        return _END
    return "agent"
