"""Agent State Definition

Defines Agent state using LangGraph TypedDict + Annotated pattern.
Reference: https://docs.langchain.com/oss/python/langgraph/graph-api#state
"""

from __future__ import annotations

from typing import Annotated, Any, Literal, TypedDict

from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages


def _merge_skills(left: list[str] | None, right: list[str] | None) -> list[str]:
    """Reducer for skills_loaded: merge and deduplicate skill names."""
    left_set = set(left or [])
    right_set = set(right or [])
    return list(left_set | right_set)


def _take_last_skill(left: str | None, right: str | None) -> str | None:
    """Reducer for active_skill: take the last updated skill name (or right if non-none)."""
    if right is not None:
        return right
    return left


class AgentState(TypedDict):
    """LangGraph Agent State.

    Attributes:
        messages: Message history using add_messages reducer for stream accumulation & deduplication
        ui_mode: UI-driven routing mode
        tool_name: Tool name for GenUI direct execution
        tool_params: Tool parameters for GenUI direct execution
        direct_execute_result: Result from direct execution node (consumed by stream layer for UI)
        skills_loaded: List of loaded skill names (for tool constraint scoping)
        active_skill: Currently active skill name
    """

    # Message history (add_messages reducer handles chunk accumulation and ID deduplication)
    messages: Annotated[list[BaseMessage], add_messages]

    # UI mode (used for entry routing)
    ui_mode: Literal[
        "idle",  # Default: route to agent node
        "direct_execute",  # Skip LLM and execute tool specified by tool_name directly
    ]

    # GenUI direct execution parameters
    tool_name: str | None
    tool_params: dict[str, Any] | None

    # Direct execution result (for stream layer UI rendering)
    direct_execute_result: dict[str, Any] | None

    # Loaded skills list (using reducer to merge)
    skills_loaded: Annotated[list[str], _merge_skills]

    # Currently active skill (using reducer to safely handle concurrent updates in a single step)
    active_skill: Annotated[str | None, _take_last_skill]


def create_initial_state() -> AgentState:
    """Create initial state object."""
    return {
        "messages": [],
        "ui_mode": "idle",
        "tool_name": None,
        "tool_params": None,
        "direct_execute_result": None,
        "skills_loaded": [],
        "active_skill": None,
    }
