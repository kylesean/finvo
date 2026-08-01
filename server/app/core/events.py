"""Lightweight in-process domain event bus.

Provides a decoupled pub/sub mechanism for domain events.
Handlers are executed asynchronously (fire-and-forget) to avoid
blocking the main request flow.

Usage:
    # Define event
    class MemberJoinedEvent(DomainEvent):
        space_id: UUID
        user_uuid: UUID

    # Register handler (at app startup)
    event_bus.subscribe(MemberJoinedEvent, my_handler)

    # Emit event (in service layer)
    event_bus.emit(MemberJoinedEvent(space_id=..., user_uuid=...))
"""

from __future__ import annotations

import asyncio
from collections.abc import Callable, Coroutine
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import Any

import structlog

logger = structlog.get_logger(__name__)

# Type alias for async event handlers
EventHandler = Callable[..., Coroutine[Any, Any, None]]


@dataclass(frozen=True, kw_only=True)
class DomainEvent:
    """Base class for all domain events."""

    occurred_at: datetime = field(default_factory=lambda: datetime.now(UTC), compare=False)


class EventBus:
    """Simple in-process event bus with async fire-and-forget dispatch."""

    def __init__(self) -> None:
        self._handlers: dict[type[DomainEvent], list[EventHandler]] = {}

    def subscribe(self, event_type: type[DomainEvent], handler: EventHandler) -> None:
        """Register a handler for a specific event type."""
        if event_type not in self._handlers:
            self._handlers[event_type] = []
        self._handlers[event_type].append(handler)
        logger.debug("event_handler_registered", event_type=event_type.__name__, handler=handler.__name__)

    def emit(self, event: DomainEvent) -> None:
        """Emit an event, dispatching to all registered handlers asynchronously.

        This is fire-and-forget: handlers run as background tasks and never
        block the caller. Exceptions in handlers are logged but not propagated.
        """
        handlers = self._handlers.get(type(event), [])
        if not handlers:
            return

        for handler in handlers:
            # Track the task so it is not garbage-collected and shutdown can
            # wait for it (see BackgroundTaskManager).
            from app.core.background_tasks import spawn_background_task

            spawn_background_task(self._safe_dispatch(handler, event))

    async def _safe_dispatch(self, handler: EventHandler, event: DomainEvent) -> None:
        """Dispatch event to handler with error isolation."""
        try:
            await handler(event)
        except Exception as exc:
            logger.warning(
                "event_handler_failed",
                event_type=type(event).__name__,
                handler=handler.__name__,
                error=str(exc),
            )


# Global singleton event bus
event_bus = EventBus()
