"""EventGenerator: A2UI emission for new surfaces and explicit updates."""

from uuid import uuid4

from app.core.genui_protocol import BASIC_CATALOG_ID
from app.core.langgraph.stream.event_generator import EventGenerator


def _cashflow(**overrides):
    base = {
        "success": True,
        "componentType": "CashFlowCard",
        "title": "Cash Flow Analysis",
        "netCashFlow": "+1,234.56",
        "savingsRate": 32.5,
    }
    base.update(overrides)
    return base


async def _emit(gen, result, tool_name="analyze_cashflow", session_id=None, tool_call_id="call_1"):
    return [
        event
        async for event in gen._component_events(
            tool_result=result,
            tool_name=tool_name,
            session_id=session_id or uuid4(),
            tool_call_id=tool_call_id,
        )
    ]


class TestNewSurface:
    async def test_emits_create_then_components(self):
        # Arrange
        gen = EventGenerator()

        # Act
        events = await _emit(gen, _cashflow())

        # Assert
        assert len(events) == 2
        create = events[0].data
        assert create["createSurface"]["catalogId"] == BASIC_CATALOG_ID
        surface_id = create["createSurface"]["surfaceId"]
        body = events[1].data["updateComponents"]
        assert body["surfaceId"] == surface_id
        root = body["components"][0]
        assert (root["id"], root["component"]) == ("root", "CashFlowCard")
        assert root["netCashFlow"] == "+1,234.56"
        assert "_surfaceId" not in root

    async def test_strips_internal_keys(self):
        # Arrange
        gen = EventGenerator()

        # Act
        events = await _emit(gen, _cashflow(_internal="secret", _intent="update"))

        # Assert
        root = events[1].data["updateComponents"]["components"][0]
        assert "_internal" not in root
        assert "_intent" not in root

    async def test_explicit_component_type_wins(self):
        # Arrange
        gen = EventGenerator()

        # Act
        events = await _emit(gen, _cashflow(id="bogus", component="bogus"))

        # Assert
        root = events[1].data["updateComponents"]["components"][0]
        assert (root["id"], root["component"]) == ("root", "CashFlowCard")


class TestIncrementalUpdate:
    async def test_update_intent_emits_only_changes(self):
        # Arrange
        gen = EventGenerator()
        session_id = uuid4()
        created = await _emit(gen, _cashflow(), session_id=session_id)
        surface_id = created[0].data["createSurface"]["surfaceId"]

        # Act
        events = await _emit(
            gen, _cashflow(_intent="update", netCashFlow="+9,999.99", savingsRate=40.0), session_id=session_id
        )

        # Assert
        paths = {e.data["updateDataModel"]["path"]: e.data["updateDataModel"]["value"] for e in events}
        assert paths == {"/netCashFlow": "+9,999.99", "/savingsRate": 40.0}
        assert all(e.data["updateDataModel"]["surfaceId"] == surface_id for e in events)

    async def test_same_type_without_intent_creates_new_surface(self):
        # Arrange
        gen = EventGenerator()
        session_id = uuid4()
        await _emit(gen, _cashflow(), session_id=session_id, tool_call_id="call_1")

        # Act
        events = await _emit(gen, _cashflow(netCashFlow="+2.00"), session_id=session_id, tool_call_id="call_2")

        # Assert
        assert len(events) == 2
        assert "createSurface" in events[0].data


class TestNoEmission:
    async def test_failed_result_emits_nothing(self):
        assert await _emit(EventGenerator(), _cashflow(success=False, error="boom")) == []

    async def test_missing_component_type_emits_nothing(self):
        assert await _emit(EventGenerator(), {"success": True, "message": "plain"}) == []

    async def test_legacy_keys_do_not_create_component(self):
        assert await _emit(EventGenerator(), {"success": True, "_genui_component": "CashFlowCard"}) == []
        assert await _emit(EventGenerator(), {"success": True, "type": "CashFlowCard"}) == []
