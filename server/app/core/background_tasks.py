"""Background Task Management

Provides a tracked, fire-and-forget background task mechanism:

- Every scheduled coroutine is held by a strong reference until it finishes,
  so the task is never garbage-collected mid-flight.
- ``shutdown()`` waits for in-flight tasks on application shutdown instead of
  letting the event loop tear them down abruptly.
"""

import asyncio
from collections.abc import Callable, Coroutine
from functools import wraps
from typing import Any

from app.core.logging import logger


class BackgroundTaskManager:
    """Background task manager.

    Tracks all scheduled tasks in a set; tasks are discarded on completion.
    """

    def __init__(self) -> None:
        self._tasks: set[asyncio.Task[Any]] = set()

    def spawn(self, coro: Coroutine[Any, Any, Any]) -> asyncio.Task[Any]:
        """Schedule a coroutine, holding a strong reference until it completes."""
        task = asyncio.create_task(coro)
        self._tasks.add(task)
        task.add_done_callback(self._tasks.discard)
        return task

    async def shutdown(self) -> None:
        """Wait for in-flight background tasks (called at application shutdown)."""
        pending = [t for t in self._tasks if not t.done()]
        if pending:
            logger.info("waiting_for_background_tasks", count=len(pending))
            await asyncio.gather(*pending, return_exceptions=True)
        self._tasks.clear()

    async def run_in_background(self, func: Callable[..., Any], *args: Any, **kwargs: Any) -> None:
        """Run task in background (fire-and-forget).

        Uses asyncio.create_task to execute the function without blocking the
        current request. Suitable for lightweight non-persisted tasks.

        Args:
            func: Async function to execute
            *args: Positional arguments
            **kwargs: Keyword arguments
        """

        async def _wrapped_task() -> None:
            try:
                logger.debug("background_task_started", function=func.__name__)
                await func(*args, **kwargs)
                logger.debug("background_task_completed", function=func.__name__)
            except Exception as e:
                logger.error("background_task_failed", function=func.__name__, error=str(e), exc_info=True)

        self.spawn(_wrapped_task())

    def background_task(self, func: Callable[..., Any]) -> Callable[..., Any]:
        """Decorator to mark a function as a background task.

        Usage:
            @background_task
            async def send_email(to: str, subject: str):
                ...

            # Executed automatically in background upon invocation
            await send_email("user@example.com", "Welcome")
        """

        @wraps(func)
        async def wrapper(*args: Any, **kwargs: Any) -> None:
            await self.run_in_background(func, *args, **kwargs)

        return wrapper


# Global instance
background_task_manager = BackgroundTaskManager()


def spawn_background_task(coro: Coroutine[Any, Any, Any]) -> asyncio.Task[Any]:
    """Schedule a tracked background task from anywhere in the app."""
    return background_task_manager.spawn(coro)
