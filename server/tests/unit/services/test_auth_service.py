from unittest.mock import AsyncMock, patch
from uuid import uuid4

import pytest

from app.core.exceptions import AuthenticationError, BusinessError
from app.models.user import User
from app.services.auth_service import AuthService


@pytest.fixture(autouse=True)
def _fake_login_counter_cache():
    """Isolate the login-failure counter from real Redis.

    The real cache_manager opens loop-bound Redis connections that outlive the
    pytest session loop and poison later TestClient lifespans ("Future
    attached to a different loop"), and its counters persist across pytest
    runs (TRUNCATE only clears Postgres), making lockout tests order- and
    history-dependent. None of these tests assert on real counting, so an
    in-memory fake is the correct isolation boundary.
    """
    store: dict[str, int] = {}

    async def fake_get(key: str, deserialize: bool = True):
        value = store.get(key)
        return str(value) if value is not None else None

    async def fake_increment(key: str, amount: int = 1):
        store[key] = store.get(key, 0) + amount
        return store[key]

    async def fake_expire(key: str, ttl: int) -> bool:
        return True

    async def fake_delete(key: str) -> bool:
        store.pop(key, None)
        return True

    with patch("app.services.auth_service.cache_manager") as mock_cache:
        mock_cache.get = AsyncMock(side_effect=fake_get)
        mock_cache.increment = AsyncMock(side_effect=fake_increment)
        mock_cache.expire = AsyncMock(side_effect=fake_expire)
        mock_cache.delete = AsyncMock(side_effect=fake_delete)
        yield mock_cache


@pytest.mark.asyncio
async def test_register_success(db_session):
    # Setup
    service = AuthService(db_session)
    email = "newuser@example.com"
    password = "securepassword"
    code = "123456"

    # Mock verify_code to return True
    # We patch the verify_code method of the global code_manager instance
    with patch("app.services.code_manager.code_manager.verify_code", new_callable=AsyncMock) as mock_verify:
        mock_verify.return_value = True

        # Action
        user = await service.register("email", email, password, code)

        # Assert
        assert user is not None
        assert user.email == email
        assert user.verify_password(password)

        # Verify DB persistence
        db_user = await service.is_account_exists("email", email)
        assert db_user is True


@pytest.mark.asyncio
async def test_register_invalid_code(db_session):
    # Setup
    service = AuthService(db_session)
    email = "badcode@example.com"
    password = "securepassword"
    code = "000000"

    # EMAIL_PROVIDER defaults to "mock", which short-circuits the code check
    # (see auth_service.py:139-141). Force a non-mock provider so the invalid-code
    # branch is actually exercised.
    with (
        patch("app.services.auth_service.settings.EMAIL_PROVIDER", "smtp"),
        patch("app.services.code_manager.code_manager.verify_code", new_callable=AsyncMock) as mock_verify,
    ):
        mock_verify.return_value = False

        # Action & Assert
        with pytest.raises(BusinessError, match="Verification code is invalid or expired"):
            await service.register("email", email, password, code)


@pytest.mark.asyncio
async def test_login_success(db_session):
    # Setup: Create user
    service = AuthService(db_session)
    email = "loginuser@example.com"
    password = "loginpass"

    # Create user manually
    user = User(
        uuid=uuid4(),
        username="login_user",
        email=email,
        password=User.hash_password(password),
        registration_type="email",
    )
    db_session.add(user)
    await db_session.commit()

    # Fake the login-failure counter: the real cache_manager opens loop-bound
    # Redis connections on the pytest loop that poison later TestClient
    # lifespans ("Future attached to a different loop"). Login success only
    # clears the counter, so a dict-backed fake is faithful.
    with patch("app.services.auth_service.cache_manager") as mock_cache:
        mock_cache.get = AsyncMock(return_value=None)
        mock_cache.delete = AsyncMock(return_value=True)

        # Action
        user_obj, token = await service.login("email", email, password, "UTC")

    # Assert
    assert user_obj.uuid == user.uuid
    assert token is not None
    assert len(token) > 10


@pytest.mark.asyncio
async def test_login_failure_wrong_password(db_session):
    # Setup
    service = AuthService(db_session)
    email = "failuser@example.com"
    password = "correctpass"

    user = User(
        uuid=uuid4(),
        username="fail_user",
        email=email,
        password=User.hash_password(password),
        registration_type="email",
    )
    db_session.add(user)
    await db_session.commit()

    # Fake the login-failure counter (same reason as test_login_success):
    # a real INCR would also persist in Redis across runs, so this fixed-email
    # test would lock itself out after 5 suite runs and flake.
    store: dict[str, int] = {}

    async def fake_get(key: str, deserialize: bool = True):
        value = store.get(key)
        return str(value) if value is not None else None

    async def fake_increment(key: str, amount: int = 1):
        store[key] = store.get(key, 0) + amount
        return store[key]

    with patch("app.services.auth_service.cache_manager") as mock_cache:
        mock_cache.get = AsyncMock(side_effect=fake_get)
        mock_cache.increment = AsyncMock(side_effect=fake_increment)
        mock_cache.expire = AsyncMock(return_value=True)

        # Action & Assert
        # Security: login returns a generic "Invalid credentials" message for both
        # wrong-password and user-not-found to prevent account enumeration.
        with pytest.raises(AuthenticationError, match="Invalid credentials"):
            await service.login("email", email, "wrongpass", "UTC")


@pytest.mark.asyncio
async def test_login_failure_user_not_found(db_session):
    service = AuthService(db_session)
    # Fake the lock check: the real cache_manager would bind Redis connections
    # to the pytest loop and poison later TestClient lifespans. Unknown
    # accounts are never counted, so get→None is faithful.
    with patch("app.services.auth_service.cache_manager") as mock_cache:
        mock_cache.get = AsyncMock(return_value=None)
        # Security: same generic message as wrong-password — no enumeration leak.
        with pytest.raises(AuthenticationError, match="Invalid credentials"):
            await service.login("email", "nonexistent@example.com", "pass", "UTC")
