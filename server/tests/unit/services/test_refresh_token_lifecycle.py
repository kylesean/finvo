"""Refresh token lifecycle security tests (H4).

Locks the refresh hardening:
1. Expired refresh tokens are rejected (``exp`` is enforced — previously
   waived by ``verify_token_allow_expired``, so an expired refresh token
   could mint new tokens forever).
2. Refresh rotates server-side: the OLD refresh token is blacklisted before
   the new one is issued, so a stolen token cannot be replayed once the
   legitimate client has rotated past it.
3. Logout revokes the supplied refresh token, so a stolen token does not
   survive the user's logout.

The endpoints are invoked directly (with a fake Redis) rather than through
TestClient so the security logic is tested without HTTP plumbing.
"""

from datetime import UTC, datetime, timedelta
from secrets import token_urlsafe

import jwt
import pytest
from fastapi import Request
from fastapi.security import HTTPAuthorizationCredentials
from starlette.applications import Starlette

from app.api.v1.auth import logout, refresh_access_token_endpoint
from app.core.config import settings
from app.core.exceptions import AuthorizationError
from app.core.limiter import limiter
from app.schemas.auth import LogoutRequest
from app.utils.auth_utils import create_refresh_token, verify_refresh_token

_SUBJECT = "user-1"


class FakeRedis:
    """Minimal in-memory stand-in for the Redis client used by token revoke."""

    def __init__(self) -> None:
        self._store: dict[str, tuple[int, str]] = {}

    async def setex(self, key: str, ttl: int, value: str) -> None:
        self._store[key] = (ttl, value)

    async def exists(self, key: str) -> int:
        return 1 if key in self._store else 0


def _request() -> Request:
    app = Starlette()
    app.state.limiter = limiter
    return Request(
        {
            "type": "http",
            "method": "POST",
            "path": "/api/v1/auth/refresh",
            "headers": [],
            "query_string": b"",
            "server": ("testserver", 80),
            "client": ("127.0.0.1", 1234),
            "app": app,
        }
    )


def _credentials(token: str) -> HTTPAuthorizationCredentials:
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)


def _expired_refresh_token() -> str:
    """A signature-valid refresh token whose exp is in the past."""
    return jwt.encode(
        {
            "type": "refresh",
            "sub": _SUBJECT,
            "exp": datetime.now(UTC) - timedelta(hours=1),
            "iat": datetime.now(UTC) - timedelta(days=2),
            "jti": token_urlsafe(16),
        },
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def _access_token() -> str:
    return jwt.encode(
        {
            "sub": _SUBJECT,
            "exp": datetime.now(UTC) + timedelta(hours=1),
            "iat": datetime.now(UTC),
            "jti": token_urlsafe(16),
        },
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


@pytest.mark.asyncio
async def test_refresh_rejects_expired_token() -> None:
    redis = FakeRedis()
    with pytest.raises(AuthorizationError, match="Invalid or expired refresh token"):
        await refresh_access_token_endpoint(
            request=_request(),
            credentials=_credentials(_expired_refresh_token()),
            redis_client=redis,
        )


@pytest.mark.asyncio
async def test_refresh_rejects_access_token() -> None:
    redis = FakeRedis()
    with pytest.raises(AuthorizationError, match="Invalid or expired refresh token"):
        await refresh_access_token_endpoint(
            request=_request(),
            credentials=_credentials(_access_token()),
            redis_client=redis,
        )


@pytest.mark.asyncio
async def test_refresh_rotates_and_blacklists_old_token() -> None:
    redis = FakeRedis()
    old_token = create_refresh_token(_SUBJECT).access_token

    response = await refresh_access_token_endpoint(
        request=_request(),
        credentials=_credentials(old_token),
        redis_client=redis,
    )

    data = response.body  # JSONResponse — parse via response body
    import json

    payload = json.loads(data)
    assert payload["data"]["token"]
    assert payload["data"]["refresh_token"] != old_token

    # Replay of the consumed refresh token must be rejected.
    with pytest.raises(AuthorizationError, match="Token has been revoked"):
        await refresh_access_token_endpoint(
            request=_request(),
            credentials=_credentials(old_token),
            redis_client=redis,
        )


@pytest.mark.asyncio
async def test_logout_revokes_supplied_refresh_token() -> None:
    redis = FakeRedis()
    refresh = create_refresh_token(_SUBJECT).access_token

    await logout(
        request=_request(),
        credentials=_credentials(_access_token()),
        redis_client=redis,
        body=LogoutRequest(refresh_token=refresh),
    )

    with pytest.raises(AuthorizationError, match="Token has been revoked"):
        await refresh_access_token_endpoint(
            request=_request(),
            credentials=_credentials(refresh),
            redis_client=redis,
        )


@pytest.mark.asyncio
async def test_logout_without_refresh_token_still_revokes_access_token() -> None:
    redis = FakeRedis()
    access = _access_token()

    await logout(
        request=_request(),
        credentials=_credentials(access),
        redis_client=redis,
        body=None,
    )

    from app.core.dependencies import is_token_revoked

    assert await is_token_revoked(redis, access)


class TestVerifyRefreshToken:
    """Unit tests for the strict refresh-token verifier."""

    def test_valid_refresh_token_returns_subject(self) -> None:
        token = create_refresh_token(_SUBJECT).access_token
        assert verify_refresh_token(token) == _SUBJECT

    def test_expired_refresh_token_rejected(self) -> None:
        assert verify_refresh_token(_expired_refresh_token()) is None

    def test_access_token_rejected(self) -> None:
        assert verify_refresh_token(_access_token()) is None

    def test_tampered_token_rejected(self) -> None:
        token = create_refresh_token(_SUBJECT).access_token
        assert verify_refresh_token(token[:-4] + "xxxx") is None

    def test_empty_token_raises_value_error(self) -> None:
        with pytest.raises(ValueError, match="Token must be a non-empty string"):
            verify_refresh_token("")
