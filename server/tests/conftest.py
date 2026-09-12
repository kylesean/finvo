import os

os.environ.setdefault("APP_ENV", "test")
os.environ.setdefault("OPENAI_API_KEY", "sk-test-key-for-unit-tests")
os.environ.setdefault("JWT_SECRET_KEY", "test-secret-key")
os.environ.setdefault("ENCRYPTION_KEY", "v3u8eA7-R5i_oX6DozID8lH_l6ApxfGqI8Xh-8o9mG4=")

import pytest
import pytest_asyncio

# --- Cheap global fixtures (autouse must stay cheap) ---
#
# Database fixtures live in tests/db_fixtures.py and are imported ONLY by the
# conftest.py of DB-backed subtrees (unit/services, integration). Pure-logic
# subtrees never import them, so no Postgres container starts there.


@pytest_asyncio.fixture(scope="function", autouse=True)
async def setup_db_manager() -> None:
    """Let the app lifespan build its own engine on the TestClient portal loop.

    The engine is created lazily from DATABASE_URL (the test Postgres) on the
    portal's event loop; resetting per test prevents pool connections created
    on a previous test's portal loop from being reused cross-loop.

    The same applies to the other loop-bound singletons: a test that touches
    the real Redis cache (or checkpointer pool) binds its connections to the
    pytest session loop, and the next TestClient lifespan would reuse them on
    the portal loop ("Future attached to a different loop" on startup PING,
    ValueError on shutdown aclose). Dropping without closing is deliberate:
    closing here would await foreign-loop objects and raise the same error;
    the test process is short-lived so GC reclaims the sockets.
    """
    import asyncio

    from app.core.cache import cache_manager
    from app.core.checkpointer import checkpointer_manager
    from app.core.database import db_manager

    db_manager._engine = None
    db_manager._session_factory = None
    cache_manager._redis = None
    cache_manager._pool = None
    checkpointer_manager._pool = None
    checkpointer_manager._lock = asyncio.Lock()


@pytest.fixture(autouse=True)
def setup_test_env(monkeypatch):
    """Setup test environment variables and core mocks."""
    # 1. Inject mandatory keys to prevent init errors
    monkeypatch.setenv("APP_ENV", "test")
    monkeypatch.delenv("ENVIRONMENT", raising=False)
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
