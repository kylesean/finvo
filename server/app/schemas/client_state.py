"""Client State Mutation Schema

Defines the subset of state operations permitted for the client in GenUI atomic mode.
Acts as the protocol contract between Client and Server for sharing StateGraph.
"""

from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field


class ClientStateMutation(BaseModel):
    """Client state mutation schema.

    GenUI atomic mode protocol:
    - Client includes state mutation in message request
    - Server atomically applies mutation before graph execution

    Design principles:
    1. Whitelist-based: Only explicitly defined fields can be modified by Client
    2. Type-safe: Strict Pydantic validation
    3. Extensible: New tools only require passing tool_name

    Attributes:
        ui_mode: Controls graph entry routing
        tool_name: Internal tool name to execute directly
        tool_params: Tool execution parameters
    """

    ui_mode: Literal["idle", "direct_execute"] | None = Field(
        default=None, description="UI mode: idle=route via agent, direct_execute=skip LLM and execute tool directly"
    )
    tool_name: str | None = Field(
        default=None, description="Tool name to execute directly (must exist in internal tool registry)"
    )
    tool_params: dict[str, Any] | None = Field(
        default=None, description="Tool parameters, required when ui_mode=direct_execute"
    )

    model_config = {"extra": "ignore"}

    def to_state_dict(self) -> dict[str, Any]:
        """Convert to a dictionary mergeable into AgentState.

        Contains only non-None fields to avoid overwriting existing state.
        """
        result: dict[str, Any] = {}
        if self.ui_mode is not None:
            result["ui_mode"] = self.ui_mode
        if self.tool_name is not None:
            result["tool_name"] = self.tool_name
        if self.tool_params is not None:
            result["tool_params"] = self.tool_params
        return result
