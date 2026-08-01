"""Database connection and session management (SQLAlchemy + asyncpg).

This module provides async SQLAlchemy engine, session management, and database utilities
for ORM operations (User, Transaction, Session, etc.).

Note: This is SEPARATE from pg_pool.py which uses psycopg3 for LangGraph checkpointer.
The two pools connect to the same database but use different drivers:
- database.py: SQLAlchemy + asyncpg (for ORM)
- pg_pool.py: psycopg3 (for LangGraph, required by AsyncPostgresSaver)
"""

from __future__ import annotations

import uuid
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from typing import TYPE_CHECKING, Any

from sqlalchemy import delete, select, text
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.pool import NullPool
from sqlmodel import SQLModel

from app.core.config import settings
from app.core.logging import logger


class DatabaseManager:
    """Manages database connections and sessions."""

    def __init__(self) -> None:
        """Initialize database manager with engine and session factory."""
        self._engine: AsyncEngine | None = None
        self._session_factory: async_sessionmaker[AsyncSession] | None = None

    def init_engine(self) -> AsyncEngine:
        """Initialize async SQLAlchemy engine with connection pooling.

        Pool strategy is selected via settings.DB_POOL_MODE:
        - "queue" (default): AsyncAdaptedQueuePool, SQLAlchemy 2.0's default pool
          for async engines. Connections are reused in-process, avoiding a
          TCP+auth handshake per request. pool_size/max_overflow apply.
        - "null": NullPool, no client-side pooling. Only use this when a
          transaction-level external pooler (PgBouncer / Supabase Supavisor)
          sits in front of PostgreSQL.

        Returns:
            AsyncEngine: Configured async database engine
        """
        if self._engine is not None:
            return self._engine

        pool_kwargs: dict[str, Any]
        if settings.DB_POOL_MODE == "null":
            pool_kwargs = {"poolclass": NullPool}
        else:
            pool_kwargs = {
                "pool_size": settings.POSTGRES_POOL_SIZE,
                "max_overflow": settings.POSTGRES_MAX_OVERFLOW,
                "pool_timeout": settings.POSTGRES_POOL_TIMEOUT,
                "pool_recycle": settings.POSTGRES_POOL_RECYCLE,
                "pool_pre_ping": settings.POSTGRES_POOL_PRE_PING,
            }

        self._engine = create_async_engine(
            settings.database_url,
            echo=False,  # Disable SQL query logging
            **pool_kwargs,
        )

        logger.info(
            "database_engine_initialized",
            host=settings.POSTGRES_HOST,
            database=settings.POSTGRES_DB,
            pool_mode=settings.DB_POOL_MODE,
            pool_size=settings.POSTGRES_POOL_SIZE if settings.DB_POOL_MODE == "queue" else None,
            max_overflow=settings.POSTGRES_MAX_OVERFLOW if settings.DB_POOL_MODE == "queue" else None,
        )

        return self._engine

    async def log_connection_budget(self) -> None:
        """Compute and log the per-process database connection budget.

        Total server-side usage = per-process budget x number of uvicorn workers.
        Warns when the per-process budget alone exceeds 80% of the server's
        max_connections, leaving headroom for migrations/scripts/admin access.
        """
        # In "null" mode the ORM side is unbounded (grows with concurrency)
        orm_budget = (
            settings.POSTGRES_POOL_SIZE + settings.POSTGRES_MAX_OVERFLOW if settings.DB_POOL_MODE == "queue" else None
        )
        per_process = (orm_budget or 0) + settings.CHECKPOINTER_POOL_SIZE

        max_connections: int | None = None
        try:
            async with self.session_factory() as session:
                result = await session.execute(text("SHOW max_connections"))
                max_connections = int(result.scalar_one())
        except Exception as e:
            logger.warning("db_max_connections_query_failed", error=str(e))

        logger.info(
            "db_connection_budget",
            pool_mode=settings.DB_POOL_MODE,
            orm_pool_budget=orm_budget,
            checkpointer_pool_budget=settings.CHECKPOINTER_POOL_SIZE,
            per_process_total=per_process,
            pg_max_connections=max_connections,
            note="total usage = per_process_total x uvicorn workers",
        )

        if max_connections is not None and orm_budget is not None and per_process > int(max_connections * 0.8):
            logger.warning(
                "db_connection_budget_exceeds_limit",
                per_process_total=per_process,
                pg_max_connections=max_connections,
                hint="lower POSTGRES_POOL_SIZE/MAX_OVERFLOW/CHECKPOINTER_POOL_SIZE or raise max_connections",
            )

    def init_session_factory(self) -> async_sessionmaker[AsyncSession]:
        """Initialize session factory for creating database sessions.

        Returns:
            async_sessionmaker: Session factory for creating async sessions
        """
        if self._session_factory is not None:
            return self._session_factory

        if self._engine is None:
            self.init_engine()

        self._session_factory = async_sessionmaker(
            bind=self._engine,
            class_=AsyncSession,
            expire_on_commit=False,  # Don't expire objects after commit
            autocommit=False,
            autoflush=False,
        )

        logger.info("database_session_factory_initialized")

        return self._session_factory

    @property
    def engine(self) -> AsyncEngine:
        """Get the database engine, initializing if necessary."""
        if self._engine is None:
            return self.init_engine()
        return self._engine

    @property
    def session_factory(self) -> async_sessionmaker[AsyncSession]:
        """Get the session factory, initializing if necessary."""
        if self._session_factory is None:
            return self.init_session_factory()
        return self._session_factory

    async def create_tables(self) -> None:
        """Create all database tables defined in SQLModel metadata."""
        async with self.engine.begin() as conn:
            await conn.run_sync(SQLModel.metadata.create_all)
        logger.info("database_tables_created")

    async def drop_tables(self) -> None:
        """Drop all database tables. Use with caution!"""
        async with self.engine.begin() as conn:
            await conn.run_sync(SQLModel.metadata.drop_all)
        logger.warning("database_tables_dropped")

    async def close(self) -> None:
        """Close database engine and cleanup connections."""
        if self._engine is not None:
            await self._engine.dispose()
            logger.info("database_engine_closed")
            self._engine = None
            self._session_factory = None

    async def health_check(self) -> bool:
        """Check database connectivity and health.

        Returns:
            bool: True if database is healthy, False otherwise
        """
        try:
            async with self.session_factory() as session:
                # Execute a simple query to verify connection
                result = await session.execute(text("SELECT 1"))
                result.scalar()
            return True
        except Exception as e:
            logger.error("database_health_check_failed", error=str(e), exc_info=True)
            return False


# Global database manager instance
db_manager = DatabaseManager()


async def get_session() -> AsyncGenerator[AsyncSession]:
    """FastAPI dependency for async database sessions.

    Delegates to :func:`get_session_context` so there is exactly ONE transaction
    contract (commit on success, rollback on error, always close) shared by the
    FastAPI dependency and internal context-managed sessions.

    Example:
        ```python
        @app.get("/users")
        async def get_users(session: AsyncSession = Depends(get_session)):
            ...
        ```
    """
    async with get_session_context() as session:
        yield session


@asynccontextmanager
async def get_session_context(auto_commit: bool = False) -> AsyncGenerator[AsyncSession]:
    """Context manager for getting async database sessions.

    Unit-of-Work contract: by default the session is NOT auto-committed on
    exit — service methods own their transaction boundary and must commit
    explicitly, so a mid-request failure never leaves a partially-written DB
    state. Pass ``auto_commit=True`` only for legacy call sites that perform a
    single statement and previously relied on the implicit commit.

    Yields:
        AsyncSession: Async database session

    Example:
        ```python
        async with get_session_context() as session:
            result = await session.execute(select(User))
            users = result.scalars().all()
        ```
    """
    async with db_manager.session_factory() as session:
        try:
            yield session
            if auto_commit:
                await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def init_db() -> None:
    """Initialize database on application startup."""
    db_manager.init_engine()
    db_manager.init_session_factory()

    # Check database health
    is_healthy = await db_manager.health_check()
    if not is_healthy:
        logger.error("database_initialization_failed")
        raise RuntimeError("Failed to connect to database")

    logger.info("database_initialized_successfully")

    # Report the per-process connection budget (and warn if it risks exhaustion)
    await db_manager.log_connection_budget()


async def close_db() -> None:
    """Close database connections on application shutdown."""
    await db_manager.close()


__all__ = [
    "DatabaseManager",
    "db_manager",
    "get_session",
    "get_session_context",
    "init_db",
    "close_db",
]
