"""Routing and tool specs: one behavior per test."""

import pytest
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage

from app.core.langgraph.agent.edges import route_after_agent, route_after_tools, route_entry
from app.core.langgraph.stream.policies import SILENT_TOOLS, suppress_text
from app.core.langgraph.tools.tool_metadata import cancel_warning, is_cancellable, is_silent, should_end_turn


def _tool_msg(name: str) -> ToolMessage:
    return ToolMessage(content="{}", name=name, tool_call_id="c1")


class TestRouteEntry:
    def test_direct_execute_routes_to_direct_node(self):
        assert route_entry({"ui_mode": "direct_execute", "tool_name": "execute_transfer"}) == "direct_execute"

    def test_idle_routes_to_agent(self):
        assert route_entry({"ui_mode": "idle"}) == "agent"


class TestRouteAfterAgent:
    def test_tool_calls_route_to_tools(self):
        msg = AIMessage(content="", tool_calls=[{"id": "c1", "name": "search_transactions", "args": {}}])
        assert route_after_agent({"messages": [msg]}) == "tools"

    def test_plain_reply_ends(self):
        assert route_after_agent({"messages": [HumanMessage(content="hi")]}) == "__end__"


class TestRouteAfterTools:
    @pytest.mark.parametrize("tool", ["record_transactions", "execute_transfer", "create_budget", "write_file"])
    def test_write_tools_end_turn(self, tool: str):
        assert route_after_tools({"messages": [_tool_msg(tool)], "ui_mode": "idle"}) == "__end__"

    @pytest.mark.parametrize("tool", ["search_transactions", "read_file", "unknown_tool"])
    def test_read_and_unknown_tools_return_to_agent(self, tool: str):
        assert route_after_tools({"messages": [_tool_msg(tool)], "ui_mode": "idle"}) == "agent"

    def test_direct_execute_always_returns_to_agent(self):
        assert (
            route_after_tools({"messages": [_tool_msg("record_transactions")], "ui_mode": "direct_execute"})
            == "agent"
        )


class TestToolSpecs:
    @pytest.mark.parametrize("tool", ["record_transactions", "execute_transfer", "create_budget", "write_file"])
    def test_write_tools_end_turn(self, tool: str):
        assert should_end_turn(tool) is True

    def test_read_tools_continue(self):
        assert should_end_turn("search_transactions") is False

    def test_silent_tools_suppress_text(self):
        assert is_silent("execute_transfer") is True
        assert is_silent("read_file") is True
        assert is_silent("search_transactions") is False
        assert "write_todos" not in SILENT_TOOLS

    def test_write_tools_not_cancellable_with_warning(self):
        assert is_cancellable("record_transactions") is False
        assert cancel_warning("record_transactions") is not None
        assert is_cancellable("search_transactions") is True


class TestSuppressText:
    def test_direct_execute_silent(self):
        assert suppress_text("direct_execute") is True

    def test_silent_tool_silent(self):
        assert suppress_text("tools", "read_file") is True

    def test_normal_tool_audible(self):
        assert suppress_text("agent", "search_transactions") is False
