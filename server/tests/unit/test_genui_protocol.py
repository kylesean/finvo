"""Tests for A2UI protocol v0.9 wire-format models.

These tests pin down the EXACT JSON the backend emits so it stays compatible
with the client's a2ui_core ``A2uiMessage.fromJson`` parser (which requires a
top-level ``version == "v0.9"`` string and one of the four message-body keys).
"""

from app.core.genui_protocol import (
    A2UI_VERSION,
    BASIC_CATALOG_ID,
    CreateSurface,
    CreateSurfacePayload,
    UpdateComponents,
    UpdateComponentsPayload,
    UpdateDataModel,
    UpdateDataModelPayload,
    V09Component,
)


class TestCreateSurface:
    def test_wire_format(self) -> None:
        msg = CreateSurface(createSurface=CreateSurfacePayload(surfaceId="surface_abc"))
        assert msg.model_dump() == {
            "version": "v0.9",
            "createSurface": {
                "surfaceId": "surface_abc",
                "catalogId": BASIC_CATALOG_ID,
            },
        }

    def test_default_catalog_id_matches_client_basic_catalog(self) -> None:
        # Must match genui.basicCatalogId on the client, otherwise the
        # SurfaceController catalog lookup (effectiveCatalogId == catalog.id)
        # would fail.
        assert BASIC_CATALOG_ID == "https://a2ui.org/specification/v0_9/basic_catalog.json"

    def test_version_constant(self) -> None:
        assert A2UI_VERSION == "v0.9"


class TestV09Component:
    def test_flat_component_preserves_extra_props(self) -> None:
        comp = V09Component.model_validate(
            {
                "id": "root",
                "component": "CashFlowCard",
                "netCashFlow": "+1,234.56",
                "savingsRate": 32.5,
                "_surfaceId": "surface_abc",
            }
        )
        dumped = comp.model_dump()
        assert dumped["id"] == "root"
        assert dumped["component"] == "CashFlowCard"
        assert dumped["netCashFlow"] == "+1,234.56"
        assert dumped["savingsRate"] == 32.5
        assert dumped["_surfaceId"] == "surface_abc"

    def test_component_field_is_string_discriminator(self) -> None:
        # In v0.9 'component' is the TYPE NAME (a string), NOT a nested dict.
        comp = V09Component(id="root", component="TransactionReceipt")
        assert comp.component == "TransactionReceipt"


class TestUpdateComponents:
    def test_wire_format(self) -> None:
        comp = V09Component.model_validate({"id": "root", "component": "CashFlowCard", "netCashFlow": "+1,234.56"})
        msg = UpdateComponents(updateComponents=UpdateComponentsPayload(surfaceId="surface_abc", components=[comp]))
        assert msg.model_dump() == {
            "version": "v0.9",
            "updateComponents": {
                "surfaceId": "surface_abc",
                "components": [
                    {
                        "id": "root",
                        "component": "CashFlowCard",
                        "netCashFlow": "+1,234.56",
                    }
                ],
            },
        }


class TestUpdateDataModel:
    def test_wire_format(self) -> None:
        msg = UpdateDataModel(
            updateDataModel=UpdateDataModelPayload(surfaceId="surface_abc", path="/amount", value=2000.0)
        )
        assert msg.model_dump() == {
            "version": "v0.9",
            "updateDataModel": {
                "surfaceId": "surface_abc",
                "path": "/amount",
                "value": 2000.0,
            },
        }
