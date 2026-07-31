"""Stream Processing Module

Decouples stream processing logic from Agent class, providing reusable streaming components.

Core components:
- StreamProcessor: Stream processing orchestrator
- EventGenerator: Event generator
- ComponentDetector: Component type detector
- RenderPolicy: Rendering policy
- TextFilterPolicy: Text filter policy
"""

from app.core.langgraph.stream.component_detector import ComponentDetector
from app.core.langgraph.stream.event_generator import EventGenerator
from app.core.langgraph.stream.processor import StreamProcessor
from app.core.langgraph.stream.render_policy import (
    CompositeRenderPolicy,
    DefaultRenderPolicy,
    RenderDecision,
    RenderPolicy,
)
from app.core.langgraph.stream.text_filter_policy import (
    CompositeTextFilterPolicy,
    DefaultTextFilterPolicy,
    TextFilterPolicy,
)

__all__ = [
    # Core Processor
    "StreamProcessor",
    "EventGenerator",
    # Component Detection
    "ComponentDetector",
    # Render Policy
    "RenderPolicy",
    "RenderDecision",
    "DefaultRenderPolicy",
    "CompositeRenderPolicy",
    # Text Filter Policy
    "TextFilterPolicy",
    "DefaultTextFilterPolicy",
    "CompositeTextFilterPolicy",
]
