"""Shared Postgres fixtures for DB-backed tests.

Import-and-reexport from a directory ``conftest.py`` to opt that subtree into
database tests::

    from tests.db_fixtures import (
        async_db_engine,
        _clean_tables,
        db_session,
        test_user,
        client,
        client_with_auth,
    )

Directory scoping is the isolation mechanism: subtrees WITHOUT this import
(pure-logic unit tests) can never instantiate the session engine, so no
Postgres container is started for them. Autouse must stay cheap —— anything
expensive is opt-in per directory, never global.
"""

import os
from collections.abc import AsyncGenerator, Generator
from uuid import uuid4

import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.database import get_session, get_session_context
from app.core.dependencies import get_current_user
from app.main import app

# Import all models to ensure they are registered in metadata
from app.models import *  # noqa: F401, F403, E402
from app.models.base import Base  # noqa: F401, E402
from app.models.user import User

# --- Fixtures ---


@pytest_asyncio.fixture(scope="session")
async def async_db_engine() -> AsyncGenerator[AsyncEngine]:
    """PostgreSQL engine for tests (parity with CI).

    When ``DATABASE_URL`` points at a real Postgres (CI provides one via the
    ``services.postgres`` job service) that URL is used directly. Otherwise a
    disposable PostgresContainer is started for the session (local runs).

    ``DATABASE_URL`` is set on the environment so psycopg3-backed components
    (LangGraph checkpointer) resolve to the same database.
    """
    from testcontainers.postgres import PostgresContainer

    provided_url = os.environ.get("DATABASE_URL")
    container: PostgresContainer | None = None
    if provided_url and "sqlite" not in provided_url:
        url = provided_url
    else:
        container = PostgresContainer("postgres:16", driver="asyncpg")
        container.start()
        url = container.get_connection_url()

    engine = create_async_engine(url)

    # Point both the environment and the (already-instantiated) settings object
    # at the test database, so psycopg3-backed components (LangGraph
    # checkpointer) and settings.database_url resolve to the same Postgres.
    os.environ["DATABASE_URL"] = url
    from app.core.config import settings

    settings.DATABASE_URL = url

    # Initialize the schema once per session; per-test isolation is handled by
    # the autouse ``_clean_tables`` fixture (TRUNCATE ... CASCADE), not by
    # transaction rollback.
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    await engine.dispose()
    if container is not None:
        container.stop()


@pytest_asyncio.fixture(scope="function", autouse=True)
async def _clean_tables(async_db_engine: AsyncEngine) -> None:
    """TRUNCATE all tables before each test (CASCADE for FKs).

    The app runs on the TestClient portal loop with its own engine/session, so
    fixture data must be genuinely committed to be visible; per-test isolation
    therefore uses TRUNCATE instead of the old rollback trick.
    """
    from sqlalchemy import text

    from app.models.base import Base

    table_names = ", ".join(f'"{t.name}"' for t in Base.metadata.sorted_tables)
    async with async_db_engine.begin() as conn:
        await conn.execute(text(f"TRUNCATE TABLE {table_names} CASCADE"))


@pytest_asyncio.fixture(scope="function")
async def db_session(async_db_engine: AsyncEngine) -> AsyncGenerator[AsyncSession]:
    """Yields a plain async session bound to the test engine.

    Commits are REAL (SQLAlchemy 2.0 note: a session bound to a pre-begun
    connection transaction would silently no-op on commit — the old
    connection.begin() pattern only worked on SQLite's single shared
    connection). Isolation is provided by the autouse ``_clean_tables``
    fixture (TRUNCATE before each test), not by transaction rollback.
    """
    session_factory = async_sessionmaker(
        bind=async_db_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )

    async with session_factory() as session:
        yield session


@pytest.fixture(scope="function")
def client() -> Generator[TestClient]:
    with TestClient(app) as c:
        yield c


@pytest_asyncio.fixture(scope="function")
async def test_user(db_session: AsyncSession) -> User:
    """Create a test user in the database."""
    user = User(
        uuid=uuid4(),
        username="integration_test_user",
        email="integration@example.com",
        password="hashed_password",
        registration_type="email",
        timezone="Asia/Shanghai",
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)
    return user


@pytest.fixture(scope="function")
def client_with_auth(client: TestClient, test_user: User) -> Generator[TestClient]:
    """Returns a TestClient with authorized user.

    The app runs on the TestClient portal event loop, so its DB sessions come
    from the portal-loop engine (get_session_context) — NOT from the pytest-loop
    ``db_session`` fixture, which would cross event loops on asyncpg. Data
    written via the fixture is visible to the app once committed.
    """

    async def override_get_session():
        async with get_session_context() as session:
            yield session

    async def override_get_current_user():
        return test_user

    app.dependency_overrides[get_session] = override_get_session
    app.dependency_overrides[get_current_user] = override_get_current_user

    yield client

    app.dependency_overrides.clear()
