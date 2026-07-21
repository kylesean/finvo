"""LangGraph checkpointer connection pool management (psycopg3).

This module centralizes the lifecycle of the psycopg3 connection pool used by
LangGraph's AsyncPostgresSaver. It is SEPARATE from database.py (SQLAlchemy +
asyncpg) because AsyncPostgresSaver is implemented against psycopg3 APIs and
requires connections with autocommit enabled and no prepared statements.

Lifecycle:
- Eagerly initialized in the FastAPI lifespan (init_checkpointer)
- Lazily initialized on first use as a fallback (e.g. scripts/tests)
- Closed on application shutdown (close_checkpointer)
"""

from __future__ import annotations

import asyncio
from typing import Any
from urllib.parse import quote_plus

from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver
from psycopg import AsyncConnection
from psycopg.rows import dict_row
from psycopg_pool import AsyncConnectionPool

from app.core.config import settings
from app.core.logging import logger


class CheckpointerManager:
    """Owns the psycopg3 connection pool for the LangGraph checkpointer.

    Guards initialization with a lock so concurrent first-time callers
    (e.g. simultaneous cold-start chat requests) cannot create duplicate pools.
    """

    def __init__(self) -> None:
        """Initialize the manager (no connections are created yet)."""
        self._pool: AsyncConnectionPool[AsyncConnection[dict[str, Any]]] | None = None
        self._lock = asyncio.Lock()

    async def ensure_initialized(self) -> None:
        """Create the connection pool if it does not exist yet (idempotent)."""
        if self._pool is not None:
            return
        async with self._lock:
            if self._pool is not None:
                return
            connection_url = settings.checkpointer_database_url
            pool: AsyncConnectionPool[AsyncConnection[dict[str, Any]]] = AsyncConnectionPool(
                connection_url,
                open=False,
                min_size=1,
                max_size=settings.CHECKPOINTER_POOL_SIZE,
                kwargs={
                    "autocommit": True,
                    "connect_timeout": 5,
                    "prepare_threshold": None,
                    "row_factory": dict_row,
                },
            )
            await pool.open()
            self._pool = pool
            logger.info(
                "checkpointer_pool_initialized",
                host=settings.POSTGRES_HOST,
                database=settings.POSTGRES_DB,
                max_size=settings.CHECKPOINTER_POOL_SIZE,
            )

    def saver(self) -> AsyncPostgresSaver:
        """Return an AsyncPostgresSaver bound to the managed pool.

        Note: checkpointer.setup() is intentionally skipped to avoid runtime
        deadlocks during concurrent initialization. Checkpoint tables and
        indexes are managed by scripts/bootstrap.py.

        Raises:
            RuntimeError: If the pool has not been initialized yet.
        """
        if self._pool is None:
            raise RuntimeError(
                "Checkpointer pool is not initialized. "
                "Call ensure_initialized() first (done automatically in the app lifespan)."
            )
        return AsyncPostgresSaver(self._pool)

    async def health_check(self) -> bool:
        """Borrow a pooled connection and run a lightweight query.

        Returns:
            bool: True if the pool can serve a working connection.
        """
        if self._pool is None:
            return False
        try:
            async with self._pool.connection() as conn:
                await conn.execute("SELECT 1")
            return True
        except Exception as e:
            logger.error("checkpointer_health_check_failed", error=str(e))
            return False

    async def close(self) -> None:
        """Close the connection pool on application shutdown."""
        if self._pool is not None:
            await self._pool.close()
            self._pool = None
            logger.info("checkpointer_pool_closed")


# Global checkpointer manager instance
checkpointer_manager = CheckpointerManager()


async def init_checkpointer() -> None:
    """Eagerly initialize the checkpointer pool on application startup."""
    await checkpointer_manager.ensure_initialized()


async def close_checkpointer() -> None:
    """Close the checkpointer pool on application shutdown."""
    await checkpointer_manager.close()
