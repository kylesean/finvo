"""Background Task Management

Provides asynchronous task execution capabilities.

Supports two approaches:
1. FastAPI BackgroundTasks / asyncio.create_task - Simple, lightweight, suitable for quick tasks.
2. ARQ (Optional) - Redis-based task queue supporting retries and persistence.
"""

import asyncio
from collections.abc import Callable
from functools import wraps
from typing import Any

from app.core.logging import logger


class BackgroundTaskManager:
    """Background task manager.

    Provides a unified background task interface supporting multiple execution strategies.
    """

    @staticmethod
    async def run_in_background(func: Callable[..., Any], *args: Any, **kwargs: Any) -> None:
        """Run task in background (fire-and-forget).

        Uses asyncio.create_task to execute task in background without blocking the current request.
        Suitable for lightweight non-persisted tasks.

        Args:
            func: Async function to execute
            *args: Positional arguments
            **kwargs: Keyword arguments
        """

        async def _wrapped_task() -> None:
            try:
                logger.debug(
                    "background_task_started",
                    function=func.__name__,
                )
                await func(*args, **kwargs)
                logger.debug(
                    "background_task_completed",
                    function=func.__name__,
                )
            except Exception as e:
                logger.error(
                    "background_task_failed",
                    function=func.__name__,
                    error=str(e),
                    exc_info=True,
                )

        # Create background task
        asyncio.create_task(_wrapped_task())

    @staticmethod
    def background_task(func: Callable[..., Any]) -> Callable[..., Any]:
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
            await BackgroundTaskManager.run_in_background(func, *args, **kwargs)

        return wrapper


# Global instance
background_task_manager = BackgroundTaskManager()


# ============================================================================
# ARQ Integration (Optional)
# ============================================================================

"""
For advanced task queue features (retries, persistence, distribution), use ARQ.

Installation:
    pip install arq

Configuration (app/core/config.py):
    REDIS_HOST = "localhost"
    REDIS_PORT = 6379

Create worker (app/workers/tasks.py):
    from arq import create_pool
    from arq.connections import RedisSettings

    async def send_verification_code(ctx, code_type: str, account: str):
        from app.services.code_manager import code_manager
        await code_manager.send_code(code_type, account)

    class WorkerSettings:
        redis_settings = RedisSettings(host='localhost', port=6379)
        functions = [send_verification_code]

Start worker:
    arq app.workers.tasks.WorkerSettings

Usage in code:
    from arq import create_pool
    from arq.connections import RedisSettings

    redis = await create_pool(RedisSettings())
    await redis.enqueue_job('send_verification_code', 'email', 'user@example.com')
"""


# ============================================================================
# Celery Integration (Optional)
# ============================================================================

"""
For enterprise-grade task queue features, use Celery.

Installation:
    pip install celery[redis]

Configuration (celery_app.py):
    from celery import Celery

    celery_app = Celery(
        'tasks',
        broker='redis://localhost:6379/0',
        backend='redis://localhost:6379/0'
    )

    @celery_app.task
    def send_verification_code_task(code_type: str, account: str):
        # Note: Celery tasks must be synchronous or use celery-aio
        import asyncio
        from app.services.code_manager import code_manager
        asyncio.run(code_manager.send_code(code_type, account))

Start worker:
    celery -A celery_app worker --loglevel=info

Usage in code:
    from celery_app import send_verification_code_task
    send_verification_code_task.delay('email', 'user@example.com')
"""
