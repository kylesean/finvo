"""Auth API end-to-end integration tests (ENG-P1-2).

Covers the HTTP boundary the service-layer tests never touch: dependency
injection, rate limiting, cookie/header handling, and error-code folding —
register → login → access → refresh (rotation) → logout → revocation.

Conventions:
- The mock verification provider is active in tests (EMAIL/SMS_PROVIDER=mock),
  so registration accepts any code.
- slowapi's in-memory limiter is keyed by client IP ("testclient" for every
  TestClient request), so the limiter store is reset before each test to keep
  tests independent of execution order.
- Redis is absent in tests, so revocation paths use an in-memory FakeRedis
  injected via dependency override (same shape as the unit-level fake).
"""

from __future__ import annotations

from collections.abc import Generator
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient

from app.core.dependencies import get_redis_client
from app.core.limiter import limiter
from app.main import app

AUTH_API = "/api/v1/auth"
_PASSWORD = "Passw0rd1"


class FakeRedis:
    """Minimal in-memory stand-in for the Redis client used by token revoke."""

    def __init__(self) -> None:
        self._store: dict[str, tuple[int, str]] = {}

    async def setex(self, key: str, ttl: int, value: str) -> None:
        self._store[key] = (ttl, value)

    async def exists(self, key: str) -> int:
        return 1 if key in self._store else 0


@pytest.fixture(autouse=True)
def _reset_rate_limiter() -> Generator[None]:
    """Isolate slowapi's in-memory counters between tests (shared TestClient IP)."""
    limiter._storage.reset()
    yield
    limiter._storage.reset()


@pytest.fixture()
def redis_client() -> FakeRedis:
    """Fresh revocation blacklist per test, wired into the app's dependency."""
    fake = FakeRedis()

    async def _override():
        yield fake

    app.dependency_overrides[get_redis_client] = _override
    yield fake
    app.dependency_overrides.pop(get_redis_client, None)


def _unique_email(tag: str) -> str:
    return f"e2e-{tag}-{uuid4().hex[:10]}@example.com"


def _register(client: TestClient, email: str, password: str = _PASSWORD) -> dict:
    response = client.post(
        f"{AUTH_API}/register",
        json={"type": "email", "account": email, "password": password, "code": "123456"},
    )
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["code"] == 0, body
    return body["data"]


def _login(client: TestClient, email: str, password: str = _PASSWORD) -> dict:
    response = client.post(
        f"{AUTH_API}/login",
        json={"type": "email", "account": email, "password": password, "timezone": "Asia/Shanghai"},
    )
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["code"] == 0, body
    return body["data"]


class TestAuthFullChain:
    @pytest.mark.asyncio
    async def test_register_login_access_protected(self, client: TestClient) -> None:
        """Happy path: register → login → Bearer access to a protected route."""
        email = _unique_email("chain")
        reg = _register(client, email)
        assert reg["token"] and reg["refresh_token"]
        assert reg["user"]["email"] == email.lower()

        data = _login(client, email)
        assert data["token"] != reg["token"]

        response = client.get(
            f"{AUTH_API}/sessions",
            headers={"Authorization": f"Bearer {data['token']}"},
        )
        assert response.status_code == 200, response.text
        assert response.json()["code"] == 0

    @pytest.mark.asyncio
    async def test_login_folds_unknown_user_and_bad_password(self, client: TestClient) -> None:
        """Unknown account and wrong password collapse to AUTHENTICATE_FAILED (1000)."""
        email = _unique_email("fold")
        _register(client, email)

        bad_password = client.post(
            f"{AUTH_API}/login",
            json={"type": "email", "account": email, "password": "Wr0ngpass", "timezone": "Asia/Shanghai"},
        )
        unknown_user = client.post(
            f"{AUTH_API}/login",
            json={
                "type": "email",
                "account": _unique_email("ghost"),
                "password": _PASSWORD,
                "timezone": "Asia/Shanghai",
            },
        )
        assert bad_password.json()["code"] == 1000, bad_password.text
        assert unknown_user.json()["code"] == 1000, unknown_user.text
        # Identical messages — no oracle for account existence.
        assert bad_password.json()["message"] == unknown_user.json()["message"]

    @pytest.mark.asyncio
    async def test_register_duplicate_email_keeps_signal(self, client: TestClient) -> None:
        """Register's EMAIL_REGISTERED (1004) is an accepted trade-off — locked here."""
        email = _unique_email("dup")
        _register(client, email)
        response = client.post(
            f"{AUTH_API}/register",
            json={"type": "email", "account": email, "password": _PASSWORD, "code": "123456"},
        )
        assert response.json()["code"] == 1004, response.text

    @pytest.mark.asyncio
    async def test_registration_closed_rejects(self, client: TestClient, monkeypatch) -> None:
        """REGISTRATION_OPEN=false short-circuits before any DB/verification work."""
        from app.core.config import settings

        monkeypatch.setattr(settings, "REGISTRATION_OPEN", False)
        try:
            response = client.post(
                f"{AUTH_API}/register",
                json={"type": "email", "account": _unique_email("closed"), "password": _PASSWORD, "code": ""},
            )
        finally:
            monkeypatch.setattr(settings, "REGISTRATION_OPEN", True)
        assert response.json()["code"] == 1013, response.text


class TestTokenLifecycleHttp:
    @pytest.mark.asyncio
    async def test_refresh_rotates_and_old_token_rejected(self, client: TestClient, redis_client: FakeRedis) -> None:
        """Refresh mints a new pair; the consumed refresh token is rejected on replay."""
        email = _unique_email("rotate")
        data = _register(client, email)
        old_refresh = data["refresh_token"]

        response = client.post(f"{AUTH_API}/refresh", headers={"Authorization": f"Bearer {old_refresh}"})
        assert response.status_code == 200, response.text
        rotated = response.json()["data"]
        assert rotated["token"] and rotated["refresh_token"]
        assert rotated["refresh_token"] != old_refresh

        replay = client.post(f"{AUTH_API}/refresh", headers={"Authorization": f"Bearer {old_refresh}"})
        assert replay.status_code == 403, replay.text

    @pytest.mark.asyncio
    async def test_refresh_token_cannot_access_api(self, client: TestClient) -> None:
        """SEC-P1-2 at the HTTP layer: a refresh token is not an access token."""
        email = _unique_email("typeconf")
        data = _register(client, email)
        response = client.get(
            f"{AUTH_API}/sessions",
            headers={"Authorization": f"Bearer {data['refresh_token']}"},
        )
        assert response.status_code == 401, response.text

    @pytest.mark.asyncio
    async def test_access_token_cannot_refresh(self, client: TestClient) -> None:
        """An access token cannot mint new tokens from /auth/refresh."""
        email = _unique_email("noesc")
        data = _register(client, email)
        response = client.post(f"{AUTH_API}/refresh", headers={"Authorization": f"Bearer {data['token']}"})
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_logout_revokes_both_tokens(self, client: TestClient, redis_client: FakeRedis) -> None:
        """Logout blacklists the access token and the supplied refresh token."""
        email = _unique_email("logout")
        data = _register(client, email)
        access, refresh = data["token"], data["refresh_token"]

        response = client.post(
            f"{AUTH_API}/logout",
            headers={"Authorization": f"Bearer {access}"},
            json={"refresh_token": refresh},
        )
        assert response.status_code == 200, response.text
        body = response.json()
        assert body["data"]["revoked"] is True
        assert body["data"]["refresh_revoked"] is True

        assert client.get(f"{AUTH_API}/sessions", headers={"Authorization": f"Bearer {access}"}).status_code == 401
        assert client.post(f"{AUTH_API}/refresh", headers={"Authorization": f"Bearer {refresh}"}).status_code == 403


class TestAntiEnumerationAndLimits:
    @pytest.mark.asyncio
    async def test_send_code_does_not_enumerate_accounts(self, client: TestClient) -> None:
        """SEC-P2-6: send-code returns success for registered AND new accounts alike."""
        email = _unique_email("enum")
        _register(client, email)

        existing = client.post(f"{AUTH_API}/send-code", json={"type": "email", "account": email})
        fresh = client.post(f"{AUTH_API}/send-code", json={"type": "email", "account": _unique_email("fresh")})
        assert existing.json()["code"] == 0, existing.text
        assert fresh.json()["code"] == 0, fresh.text
        assert existing.json()["message"] == fresh.json()["message"]

    @pytest.mark.asyncio
    async def test_send_code_rate_limited_429(self, client: TestClient) -> None:
        """Endpoint limiter (10/minute) answers 429 — distinct accounts dodge the per-account lock."""
        last_status: int | None = None
        for i in range(11):
            response = client.post(
                f"{AUTH_API}/send-code",
                json={"type": "email", "account": f"e2e-rl-{uuid4().hex[:10]}-{i}@example.com"},
            )
            last_status = response.status_code
        assert last_status == 429, f"expected the 11th send-code to be rate limited, got {last_status}"
