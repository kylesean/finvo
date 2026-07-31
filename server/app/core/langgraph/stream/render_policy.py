"""RenderPolicy - Rendering Strategy Pattern Implementation

Responsibilities:
- Determines GenUI event rendering behavior (immediate/buffered/suppressed)
- Encapsulates decision logic cleanly across stream rendering
- Supports policy extensions via composite pattern

Design Patterns:
- Strategy Pattern
- Composite Pattern
"""

from abc import ABC, abstractmethod
from enum import Enum
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.schemas.genui import GenUIEvent


class RenderDecision(str, Enum):
    """Render decision enumeration."""

    EMIT = "emit"  # Emit to client immediately
    BUFFER = "buffer"  # Buffer and emit at stream end
    SUPPRESS = "suppress"  # Suppress entirely


class RenderPolicy(ABC):
    """Abstract base class for render policies.

    Subclasses implement decide() to specify render decision logic.
    """

    @abstractmethod
    def decide(self, event: "GenUIEvent", node_name: str) -> RenderDecision:
        """Determines the render decision for a GenUI event.

        Args:
            event: GenUI event
            node_name: LangGraph node name producing the event

        Returns:
            RenderDecision enum value
        """
        ...


class AlwaysEmitPolicy(RenderPolicy):
    """Always emit immediately policy (default behavior)."""

    def decide(self, event: "GenUIEvent", node_name: str) -> RenderDecision:
        """Determines that the event should always be emitted immediately."""
        return RenderDecision.EMIT


class ToolsNodeBufferPolicy(RenderPolicy):
    """Tools node a2ui_message buffering policy.

    Design rationale:
    - UI components produced by tools node are rendered after AI text analysis
    - Ensures textual insights appear prior to data visualization cards
    - Adheres to attachment placement principle
    """

    def decide(self, event: "GenUIEvent", node_name: str) -> RenderDecision:
        """Buffers a2ui_message events from the tools node, emitted at the end."""
        if node_name == "tools" and event.type == "a2ui_message":
            return RenderDecision.BUFFER
        return RenderDecision.EMIT


class CompositeRenderPolicy(RenderPolicy):
    """Composite render policy.

    Evaluates multiple policies in priority order, returning the first non-EMIT decision.
    If all policies return EMIT, returns EMIT.
    """

    def __init__(self, policies: list[RenderPolicy] | None = None):
        self._policies = policies or []

    def add_policy(self, policy: RenderPolicy) -> "CompositeRenderPolicy":
        """Add policy (fluent interface)."""
        self._policies.append(policy)
        return self

    def decide(self, event: "GenUIEvent", node_name: str) -> RenderDecision:
        """Evaluates composite policies and returns the first prioritized decision."""
        for policy in self._policies:
            decision = policy.decide(event, node_name)
            if decision != RenderDecision.EMIT:
                return decision
        return RenderDecision.EMIT


class DefaultRenderPolicy(CompositeRenderPolicy):
    """Default render policy.

    Design:
    - Buffers a2ui_message until stream completion
    - GenUI components append at the end of the message after text stream completes
    """

    def __init__(self) -> None:
        super().__init__([])
