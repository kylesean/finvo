import os

os.environ.setdefault("APP_ENV", "test")
os.environ.setdefault("OPENAI_API_KEY", "sk-test-key-for-unit-tests")
os.environ.setdefault("JWT_SECRET_KEY", "test-secret-key")
os.environ.setdefault("ENCRYPTION_KEY", "v3u8eA7-R5i_oX6DozID8lH_l6ApxfGqI8Xh-8o9mG4=")

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
    # the db_session fixture (connection-level transaction + rollback).
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    await engine.dispose()
    if container is not None:
        container.stop()


@pytest_asyncio.fixture(scope="function", autouse=True)
async def setup_db_manager() -> None:
    """Let the app lifespan build its own engine on the TestClient portal loop.

    The engine is created lazily from DATABASE_URL (the test Postgres) on the
    portal's event loop; resetting per test prevents pool connections created
    on a previous test's portal loop from being reused cross-loop.
    """
    from app.core.database import db_manager

    db_manager._engine = None
    db_manager._session_factory = None


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


@pytest.fixture(scope="function")
def client() -> Generator[TestClient]:
    with TestClient(app) as c:
        yield c


@pytest.fixture(autouse=True)
def setup_test_env(monkeypatch):
    """Setup test environment variables and core mocks."""
    # 1. Inject mandatory keys to prevent init errors
    monkeypatch.setenv("APP_ENV", "test")
    if not os.environ.get("DATABASE_URL"):
        # Only a fallback: async_db_engine sets a real Postgres URL when present.
        monkeypatch.setenv("DATABASE_URL", "sqlite+aiosqlite:///:memory:")
    monkeypatch.setenv("ENCRYPTION_KEY", "v3u8eA7-R5i_oX6DozID8lH_l6ApxfGqI8Xh-8o9mG4=")
    monkeypatch.setenv("OPENAI_API_KEY", "sk-test-key-for-unit-tests")
    monkeypatch.setenv("JWT_SECRET_KEY", "test-secret-key")

    # 2. Prevent mem0 from actually trying to connect to anything
    from unittest.mock import AsyncMock

    from mem0 import AsyncMemory

    # We mock from_config so MemoryService initialization succeeds seamlessly
    mock_mem0 = AsyncMock(spec=AsyncMemory)
    monkeypatch.setattr(AsyncMemory, "from_config", AsyncMock(return_value=mock_mem0))

    return mock_mem0


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
