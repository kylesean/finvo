"""GenUI A2UI Protocol Definitions

This module defines standard A2UI protocol message types for server-driven UI.

The backend emits A2UI protocol v0.9 natively (see the v0.9 message models
below). GenUI's A2uiMessage.fromJson() does NOT use a 'type' field; it uses the
outer key name as the message discriminator and requires a top-level 'version':
  ❌ Wrong: {"type": "create_surface", "surfaceId": "..."}
  ✅ Right: {"version": "v0.9", "createSurface": {"surfaceId": "..."}}
"""

from __future__ import annotations

from typing import Any

from pydantic import BaseModel, ConfigDict

# ============================================================================
# 1. TextChunk - Stream Text Content
# ============================================================================


class TextChunkPayload(BaseModel):
    """Payload for text chunk."""

    text: str


class TextChunk(BaseModel):
    """GenUI TextChunk message.

    GenUI expects:
    {
      "textChunk": {
        "text": "Hello world"
      }
    }
    """

    textChunk: TextChunkPayload


# ============================================================================
# 2. UserInteraction - User Action (Frontend → Backend)
# ============================================================================


class UserInteractionPayload(BaseModel):
    """Payload for user interaction."""

    surfaceId: str
    componentId: str
    action: str
    data: dict[str, Any] | None = None


class UserInteraction(BaseModel):
    """GenUI UserInteraction message.

    GenUI expects:
    {
      "userInteraction": {
        "surfaceId": "surface_123",
        "componentId": "comp_456",
        "action": "confirm",
        "data": {...}
      }
    }
    """

    userInteraction: UserInteractionPayload


# ============================================================================
# 3. DeleteSurface - Remove a Surface from UI
# ============================================================================


class DeleteSurfacePayload(BaseModel):
    """Payload for surface deletion."""

    surfaceId: str


class DeleteSurface(BaseModel):
    """GenUI DeleteSurface message.

    Used to explicitly remove a Surface from the UI.

    GenUI expects:
    {
      "deleteSurface": {
        "surfaceId": "surface_123"
      }
    }
    """

    deleteSurface: DeleteSurfacePayload


# ============================================================================
# 4. A2UI Protocol v0.9 Messages (GenUI 0.10 native wire format)
# ============================================================================
#
# GenUI 0.10 speaks A2UI protocol v0.9 natively. These models produce the exact
# wire format the client's SurfaceController consumes DIRECTLY - the client's
# _translateProtocol() passes any message with version == 'v0.9' straight
# through to a2ui.A2uiMessage.fromJson() (only normalizing createSurface's
# catalogId). Emitting v0.9 therefore requires ZERO client-side translation.
#
# Wire format (note the mandatory top-level 'version' string, validated by
# a2ui_core's A2uiMessage.fromJson):
#   {"version": "v0.9", "createSurface":   {"surfaceId": ..., "catalogId": ...}}  # noqa: ERA001
#   {"version": "v0.9", "updateComponents": {"surfaceId": ..., "components": [  # noqa: ERA001
#       {"id": "root", "component": "TypeName", ...props}]}}  # noqa: ERA001
#   {"version": "v0.9", "updateDataModel":  {"surfaceId": ..., "path": ..., "value": ...}}  # noqa: ERA001
#
# Components are FLAT in v0.9: {"id": "root", "component": "TypeName", **props}

A2UI_VERSION = "v0.9"

# Must match genui.basicCatalogId on the client (AppCatalog is built from
# BasicCatalogItems.asCatalog(), whose catalogId is this exact URI). The client
# also force-overwrites createSurface.catalogId to this value, so emitting it
# here keeps backend and client consistent.
BASIC_CATALOG_ID = "https://a2ui.org/specification/v0_9/basic_catalog.json"


class CreateSurfacePayload(BaseModel):
    """Payload for creating a surface (v0.9)."""

    surfaceId: str
    catalogId: str = BASIC_CATALOG_ID


class CreateSurface(BaseModel):
    """GenUI v0.9 CreateSurface message.

    GenUI expects:
    {
      "version": "v0.9",
      "createSurface": {
        "surfaceId": "surface_123",
        "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
      }
    }
    """

    version: str = A2UI_VERSION
    createSurface: CreateSurfacePayload


class V09Component(BaseModel):
    """A FLAT v0.9 component definition.

    Shape: {"id": "root", "component": "TypeName", **props}

    - ``id``: component id; the surface root MUST be ``'root'`` (GenUI 0.10's
      Surface widget ignores any declared root and looks up id 'root').
    - ``component``: the catalog component TYPE NAME (a string discriminator),
      NOT a nested property map.
    - all remaining keys are the component's data properties (validated by the
      client against the catalog item's dataSchema).

    Extra properties are allowed and preserved verbatim.
    """

    model_config = ConfigDict(extra="allow")

    id: str
    component: str


class UpdateComponentsPayload(BaseModel):
    """Payload for updating components (v0.9)."""

    surfaceId: str
    components: list[V09Component]


class UpdateComponents(BaseModel):
    """GenUI v0.9 UpdateComponents message.

    GenUI expects:
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "surface_123",
        "components": [
          {"id": "root", "component": "CashFlowCard", "netCashFlow": "..."}
        ]
      }
    }
    """

    version: str = A2UI_VERSION
    updateComponents: UpdateComponentsPayload


class UpdateDataModelPayload(BaseModel):
    """Payload for updating a surface's data model (v0.9).

    Used for reactive incremental updates: only widgets bound to the specified
    path rebuild, instead of the entire surface.
    """

    surfaceId: str
    path: str  # JSONPath format, e.g. "/amount" or "/user/name"
    value: Any  # The new value at the specified path


class UpdateDataModel(BaseModel):
    """GenUI v0.9 UpdateDataModel message.

    GenUI expects:
    {
      "version": "v0.9",
      "updateDataModel": {
        "surfaceId": "surface_123",
        "path": "/amount",
        "value": 2000.0
      }
    }
    """

    version: str = A2UI_VERSION
    updateDataModel: UpdateDataModelPayload
