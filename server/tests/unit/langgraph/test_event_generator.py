"""Tests for EventGenerator._emit_component_events (A2UI v0.9 emission).

Verifies the backend emits the v0.9 wire format the client consumes directly:
  - new surface      -> createSurface + updateComponents (flat, root id 'root')
  - incremental      -> updateDataModel per changed field
  - failure / no component -> nothing emitted
"""

from uuid import uuid4

from app.core.genui_protocol import BASIC_CATALOG_ID
from app.core.langgraph.stream.event_generator import EventGenerator


def _cashflow_result(**overrides):
    base = {
        "success": True,
        "componentType": "CashFlowCard",
        "title": "Cash Flow Analysis",
        "netCashFlow": "+1,234.56",
        "savingsRate": 32.5,
        "totalIncome": "5,000.00",
        "totalExpense": "3,765.44",
    }
    base.update(overrides)
    return base


async def _collect(gen, tool_result, tool_name="analyze_cashflow", session_id=None, tool_call_id="call_1"):
    return [
        event
        async for event in gen._emit_component_events(
            tool_result=tool_result,
            tool_name=tool_name,
            session_id=session_id or uuid4(),
            tool_call_id=tool_call_id,
        )
    ]


class TestNewSurfaceEmission:
    async def test_emits_create_surface_then_update_components(self) -> None:
        gen = EventGenerator()
        events = await _collect(gen, _cashflow_result())

        assert len(events) == 2
        assert all(e.type == "a2ui_message" for e in events)

        # 1) createSurface
        create = events[0].data
        assert create["version"] == "v0.9"
        assert set(create.keys()) == {"version", "createSurface"}
        surface_id = create["createSurface"]["surfaceId"]
        assert create["createSurface"]["catalogId"] == BASIC_CATALOG_ID

        # 2) updateComponents (flat, root id 'root')
        update = events[1].data
        assert update["version"] == "v0.9"
        assert set(update.keys()) == {"version", "updateComponents"}
        body = update["updateComponents"]
        assert body["surfaceId"] == surface_id
        assert len(body["components"]) == 1

        root = body["components"][0]
        assert root["id"] == "root"
        assert root["component"] == "CashFlowCard"
        # data props are flattened alongside id/component
        assert root["netCashFlow"] == "+1,234.56"
        assert root["savingsRate"] == 32.5
        assert root["totalIncome"] == "5,000.00"
        # internal '_'-prefixed keys are stripped before reaching the client
        # (_surfaceId lives only in the server-side SurfaceTracker)
        assert "_surfaceId" not in root

    async def test_no_legacy_message_keys(self) -> None:
        """The old nested format (surfaceUpdate/beginRendering) must be gone."""
        gen = EventGenerator()
        events = await _collect(gen, _cashflow_result())
        for event in events:
            assert "surfaceUpdate" not in event.data
            assert "beginRendering" not in event.data
            # legacy nested component id prefix must not appear
            assert "comp_" not in str(event.data)

    async def test_id_and_component_win_over_data_collision(self) -> None:
        """If tool data contains 'id'/'component' keys, root id & type still win."""
        gen = EventGenerator()
        result = _cashflow_result(id="bogus_id", component="bogus_component")
        events = await _collect(gen, result)
        root = events[1].data["updateComponents"]["components"][0]
        assert root["id"] == "root"
        assert root["component"] == "CashFlowCard"

    async def test_internal_keys_stripped_from_wire_component(self) -> None:
        """'_'-prefixed tool data keys must never reach the client wire format."""
        gen = EventGenerator()
        result = _cashflow_result(_internal="secret", _debug=True)
        events = await _collect(gen, result)
        root = events[1].data["updateComponents"]["components"][0]
        assert "_internal" not in root
        assert "_debug" not in root
        # public props are preserved
        assert root["netCashFlow"] == "+1,234.56"


class TestIncrementalUpdate:
    async def test_reuses_surface_with_update_data_model(self) -> None:
        gen = EventGenerator()
        session_id = uuid4()

        # First emission creates the surface.
        created = await _collect(gen, _cashflow_result(), session_id=session_id)
        surface_id = created[0].data["createSurface"]["surfaceId"]

        # Second emission (same component type + update intent) -> incremental.
        update_result = _cashflow_result(
            _intent="update",
            netCashFlow="+9,999.99",
            savingsRate=40.0,
        )
        events = await _collect(gen, update_result, session_id=session_id)

        # Only the changed fields are emitted, as v0.9 updateDataModel.
        assert len(events) == 2
        paths = {}
        for event in events:
            assert event.type == "a2ui_message"
            assert event.data["version"] == "v0.9"
            body = event.data["updateDataModel"]
            assert body["surfaceId"] == surface_id
            paths[body["path"]] = body["value"]

        assert paths == {"/netCashFlow": "+9,999.99", "/savingsRate": 40.0}


class TestNoEmission:
    async def test_failed_result_emits_nothing(self) -> None:
        gen = EventGenerator()
        events = await _collect(gen, _cashflow_result(success=False, error="boom"))
        assert events == []

    async def test_no_component_type_emits_nothing(self) -> None:
        gen = EventGenerator()
        events = await _collect(gen, {"success": True, "message": "plain text result"})
        assert events == []
