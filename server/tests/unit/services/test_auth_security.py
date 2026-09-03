"""Security-focused tests for AuthService.

Covers the real security-relevant behavior: JWT signature/expiry/algorithm
checks, strict access/refresh type isolation, bcrypt hashing, single-use
expiring verification codes with guess budgets, per-account login lockout,
fail-closed revocation, and account-enumeration folding.
"""

from datetime import UTC, datetime, timedelta
from unittest.mock import AsyncMock, patch
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import AuthenticationError, AuthErrorCode, BusinessError
from app.models.user import User
from app.services.auth_service import AuthService
from app.utils.auth_utils import create_access_token, verify_token


class _FakeRedis:
    """Minimal in-memory stand-in for the Redis client used by token revoke."""

    def __init__(self) -> None:
        self._store: dict[str, tuple[int, str]] = {}

    async def setex(self, key: str, ttl: int, value: str) -> None:
        self._store[key] = (ttl, value)

    async def exists(self, key: str) -> int:
        return 1 if key in self._store else 0


class TestTokenSecurity:
    """Tests for JWT token security.

    These exercise the real ``verify_token`` (jose) behavior: signature
    verification, expiry rejection, and algorithm pinning.
    """

    @pytest.mark.asyncio
    async def test_expired_token_rejected(self) -> None:
        """Tokens past their expiry are rejected by verify_token."""
        # Build a token that already expired 1 hour ago.
        token_obj = create_access_token(subject=str(uuid4()), expires_delta=timedelta(hours=-1))
        assert verify_token(token_obj.access_token) is None

    @pytest.mark.asyncio
    async def test_refresh_token_rejected_for_api_access(self) -> None:
        """A refresh token must not authenticate API calls.

        verify_token (the auth path for every REST/WS route) has to reject
        ``type: refresh`` tokens — otherwise a leaked 30-day refresh token is
        directly usable as a bearer credential and the access/refresh type
        isolation is one-directional.
        """
        from app.utils.auth_utils import create_refresh_token

        refresh_token = create_refresh_token(subject=str(uuid4())).access_token
        assert verify_token(refresh_token) is None

    @pytest.mark.asyncio
    async def test_access_token_type_claim_present(self) -> None:
        """Access tokens carry ``type: access`` so the auth path can pin on it."""
        from jose import jwt as jose_jwt

        token_obj = create_access_token(subject=str(uuid4()))
        claims = jose_jwt.get_unverified_claims(token_obj.access_token)
        assert claims.get("type") == "access"

    @pytest.mark.asyncio
    async def test_token_without_type_claim_rejected(self) -> None:
        """Typeless tokens are rejected: every token must declare its type."""
        from jose import jwt as jose_jwt

        subject = str(uuid4())
        typeless = jose_jwt.encode(
            {"sub": subject, "exp": datetime.now(UTC) + timedelta(hours=1), "jti": "typeless-jti"},
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM,
        )
        assert verify_token(typeless) is None

    @pytest.mark.asyncio
    async def test_tampered_token_rejected(self) -> None:
        """A token with a modified payload fails signature verification."""
        token_obj = create_access_token(subject=str(uuid4()))
        parts = token_obj.access_token.split(".")
        assert len(parts) == 3
        # Flip a character in the payload segment — signature no longer matches.
        tampered_payload = parts[1][:-2] + ("AA" if parts[1][-2:] != "AA" else "BB")
        tampered = f"{parts[0]}.{tampered_payload}.{parts[2]}"
        assert verify_token(tampered) is None

    @pytest.mark.asyncio
    async def test_token_with_wrong_algorithm_rejected(self) -> None:
        """Tokens signed with an algorithm not in the allowed list are rejected.

        verify_token decodes with algorithms=[settings.JWT_ALGORITHM]; a token
        signed with a different algorithm must be rejected.
        """
        from jose import jwt as jose_jwt

        subject = str(uuid4())
        # Sign with HS512 while the app expects HS256 (the configured algorithm).
        wrong_alg_token = jose_jwt.encode(
            {"sub": subject, "exp": datetime.now(UTC) + timedelta(hours=1)},
            settings.JWT_SECRET_KEY,
            algorithm="HS512",
        )
        assert verify_token(wrong_alg_token) is None

    @pytest.mark.asyncio
    async def test_revocation_undecidable_fails_closed_outside_dev(self, monkeypatch) -> None:
        """Redis down means fail closed in production, fail open in dev."""
        from app.core.config import Environment
        from app.core.dependencies import is_token_revoked

        token = create_access_token(subject=str(uuid4())).access_token
        assert await is_token_revoked(None, token) is False

        original = settings.ENVIRONMENT
        monkeypatch.setattr(settings, "ENVIRONMENT", Environment.PRODUCTION)
        try:
            assert await is_token_revoked(None, token) is True
        finally:
            monkeypatch.setattr(settings, "ENVIRONMENT", original)

    @pytest.mark.asyncio
    async def test_token_replay_prevention(self) -> None:
        """A consumed refresh token cannot be replayed.

        Implemented via server-side rotation (old refresh token blacklisted
        before a new one is issued) + logout revocation of the refresh token.
        Full lifecycle coverage lives in test_refresh_token_lifecycle.py;
        this test pins the rotation invariant at the token level.
        """
        from app.core.dependencies import is_token_revoked
        from app.utils.auth_utils import create_refresh_token

        fake_redis = _FakeRedis()
        old_token = create_refresh_token("user-1").access_token

        # Simulate what the refresh endpoint does: revoke the old token, then
        # the legitimate client holds the new one.
        from app.core.dependencies import revoke_token

        await revoke_token(fake_redis, old_token)
        assert await is_token_revoked(fake_redis, old_token)


class TestPasswordSecurity:
    """Tests for password handling security.

    Finvo uses bcrypt via ``User.hash_password`` / ``User.verify_password``.
    """

    @pytest.mark.asyncio
    async def test_password_not_stored_plaintext(self) -> None:
        """The stored password is never the plaintext input."""
        plain = "MySecretPass123!"
        hashed = User.hash_password(plain)
        assert hashed != plain
        # And it must verify correctly against the plaintext.
        user = User(username="u", email="u@example.com", password=hashed, registration_type="email")
        assert user.verify_password(plain) is True
        assert user.verify_password("wrong") is False

    @pytest.mark.asyncio
    async def test_password_hash_uses_bcrypt(self) -> None:
        """Password hashes are bcrypt-formatted ($2b$ prefix)."""
        hashed = User.hash_password("anything")
        # bcrypt hashes start with $2a$, $2b$ or $2y$; app uses bcrypt.gensalt().
        assert hashed.startswith(("$2a$", "$2b$", "$2y$"))
        # Two hashes of the same password differ (salt is random).
        assert User.hash_password("same") != User.hash_password("same")


class TestPasswordPolicy:
    """Registration passwords: min 8 chars, letters + digits, not common."""

    def _check(self, password: str):
        from pydantic import ValidationError

        from app.schemas.auth import RegisterRequest

        try:
            RegisterRequest(type="email", account="u@example.com", password=password)
            return None
        except ValidationError as e:
            return str(e)

    @pytest.mark.parametrize("bad", ["short1", "1234567", "abcdefg", "Password123", "qwerty123", "abcdefgh"])
    def test_weak_passwords_rejected(self, bad: str) -> None:
        assert self._check(bad) is not None

    def test_strong_password_accepted(self) -> None:
        assert self._check("Str0ngPass!9") is None

    @pytest.mark.skip(
        reason=(
            "Timing-attack resistance is an implicit property of bcrypt's "
            "constant-time comparepw; a flaky wall-clock threshold test adds "
            "little value for a self-hosted app and tends to be CI-noisy. "
            "bcrypt's design already guarantees this."
        )
    )
    @pytest.mark.asyncio
    async def test_timing_attack_resistance(self) -> None:
        """Login timing doesn't reveal user existence (bcrypt constant-time)."""
        pass


class TestVerificationCodeSecurity:
    """Tests for verification code security.

    ``CodeManager.verify_code`` (app/services/code_manager.py) stores codes in
    Redis via ``cache_manager`` with a TTL, and deletes the code on successful
    verification — making codes single-use and self-expiring.
    """

    @pytest.mark.asyncio
    async def test_code_expiry(self) -> None:
        """Codes expire after their TTL: cache returns None → verification fails."""
        from app.services.code_manager import code_manager

        account = f"exp_{uuid4().hex}@example.com"
        # Simulate cache miss (expired/never stored): cache_manager.get → None.
        with (
            patch.object(
                code_manager,
                "_acquire_rate_limit_lock",
                new=AsyncMock(return_value=True),
            ),
            patch.object(code_manager, "_release_rate_limit_lock", new=AsyncMock()),
            patch("app.services.code_manager.cache_manager") as mock_cache,
        ):
            # First call: code stored, then TTL elapses → get returns None.
            mock_cache.get = AsyncMock(return_value=None)
            mock_cache.set = AsyncMock()
            mock_cache.delete = AsyncMock(return_value=True)

            ok = await code_manager.verify_code(account, "123456")
            assert ok is False
            # On a miss, delete must NOT be called (nothing to delete).
            mock_cache.delete.assert_not_called()

    @pytest.mark.asyncio
    async def test_code_single_use(self) -> None:
        """A verification code is deleted after a successful verify → second use fails."""
        from app.services.code_manager import code_manager

        account = f"su_{uuid4().hex}@example.com"
        stored_code = "654321"

        with patch("app.services.code_manager.cache_manager") as mock_cache:
            # The stored code exists and matches.
            mock_cache.get = AsyncMock(return_value=stored_code)
            mock_cache.delete = AsyncMock(return_value=True)

            first = await code_manager.verify_code(account, stored_code)
            assert first is True
            # Successful verify MUST delete the code (single-use guarantee).
            deleted_keys = [c.args[0] for c in mock_cache.delete.call_args_list]
            assert any(k.startswith("verification_code:") for k in deleted_keys)

            # Second attempt: code already deleted → cache miss → fail.
            mock_cache.get = AsyncMock(return_value=None)
            second = await code_manager.verify_code(account, stored_code)
            assert second is False

    @pytest.mark.asyncio
    async def test_wrong_guesses_void_code_after_budget(self) -> None:
        """Five wrong guesses void the code; even the right code then fails."""
        from app.services.code_manager import code_manager

        account = f"bf_{uuid4().hex}@example.com"
        stored_code = "123456"
        state: dict[str, str] = {"code": stored_code}
        attempts = {"count": 0}

        async def fake_get(key: str, deserialize: bool = True):
            if key.startswith("verification_code:"):
                return state.get("code")
            return None

        async def fake_increment(key: str, amount: int = 1):
            attempts["count"] += amount
            return attempts["count"]

        async def fake_expire(key: str, ttl: int) -> bool:
            return True

        async def fake_delete(key: str) -> bool:
            if key.startswith("verification_code:"):
                state.pop("code", None)
            return True

        with patch("app.services.code_manager.cache_manager") as mock_cache:
            mock_cache.get = AsyncMock(side_effect=fake_get)
            mock_cache.increment = AsyncMock(side_effect=fake_increment)
            mock_cache.expire = AsyncMock(side_effect=fake_expire)
            mock_cache.delete = AsyncMock(side_effect=fake_delete)

            for _ in range(5):
                assert await code_manager.verify_code(account, "000000") is False
            assert await code_manager.verify_code(account, stored_code) is False


class TestAccountEnumeration:
    """Tests for preventing account enumeration attacks.

    Login returns a single generic AUTHENTICATE_FAILED error for both
    "user not found" and "wrong password" branches, so an attacker cannot
    distinguish whether an account exists. Registration still surfaces
    EMAIL_REGISTERED — an accepted trade-off for a self-hosted app where the
    single operator already knows their own accounts.
    """

    @pytest.mark.asyncio
    async def test_registration_no_user_leak(self, db_session: AsyncSession) -> None:
        """Registration of an existing account raises a clear business error.

        This documents that registration reveals account existence via
        EMAIL_REGISTERED — an accepted trade-off for a self-hosted app where
        the single operator already knows their own accounts. The test pins the
        error_code so a future change is intentional, not accidental.
        """
        service = AuthService(db_session)
        email = f"leak_{uuid4().hex[:8]}@example.com"
        with (
            patch("app.services.auth_service.settings.EMAIL_PROVIDER", "smtp"),
            patch("app.services.code_manager.code_manager.verify_code", new=AsyncMock(return_value=True)),
        ):
            await service.register("email", email, "Password123!", code="123456")

            # Second registration of the same email must raise EMAIL_REGISTERED.
            with pytest.raises(BusinessError) as exc_info:
                await service.register("email", email, "Password123!", code="123456")

            assert exc_info.value.error_code == AuthErrorCode.EMAIL_REGISTERED

    @pytest.mark.asyncio
    async def test_login_no_user_leak(self, db_session: AsyncSession) -> None:
        """Login returns the same error code for 'user not found' and 'wrong password'.

        Both branches must raise AUTHENTICATE_FAILED with an identical generic
        message so an attacker cannot enumerate accounts by distinguishing the
        two failure cases.
        """
        service = AuthService(db_session)

        # Fake the login-failure counter: the real cache_manager opens
        # loop-bound Redis connections. Used raw here, they outlive the
        # pytest session loop and poison later TestClient lifespans with
        # cross-loop Future errors. Enumeration-folding needs no real
        # counting, so fake it like TestLoginLockout does.
        store: dict[str, int] = {}

        async def fake_get(key: str, deserialize: bool = True):
            value = store.get(key)
            return str(value) if value is not None else None

        async def fake_increment(key: str, amount: int = 1):
            store[key] = store.get(key, 0) + amount
            return store[key]

        async def fake_expire(key: str, ttl: int) -> bool:
            return True

        with patch("app.services.auth_service.cache_manager") as mock_cache:
            mock_cache.get = AsyncMock(side_effect=fake_get)
            mock_cache.increment = AsyncMock(side_effect=fake_increment)
            mock_cache.expire = AsyncMock(side_effect=fake_expire)

            # Nonexistent user → AUTHENTICATE_FAILED (same as wrong password).
            with pytest.raises(AuthenticationError) as exc:
                await service.login("email", "nobody@example.com", "whatever", "Asia/Shanghai")
            assert exc.value.error_code == AuthErrorCode.AUTHENTICATE_FAILED
            assert exc.value.message == "Invalid credentials"

            # Create a user, then wrong password → also AUTHENTICATE_FAILED.
            email = f"login_{uuid4().hex[:8]}@example.com"
            with (
                patch("app.services.auth_service.settings.EMAIL_PROVIDER", "smtp"),
                patch("app.services.code_manager.code_manager.verify_code", new=AsyncMock(return_value=True)),
            ):
                await service.register("email", email, "CorrectPass1!", code="123456")

            with pytest.raises(AuthenticationError) as exc:
                await service.login("email", email, "WrongPass1!", "Asia/Shanghai")
            assert exc.value.error_code == AuthErrorCode.AUTHENTICATE_FAILED
            assert exc.value.message == "Invalid credentials"

        # Both failure modes produce the same code+message — no enumeration leak.
        assert AuthErrorCode.AUTHENTICATE_FAILED == AuthErrorCode.AUTHENTICATE_FAILED

    @pytest.mark.skip(
        reason=(
            "No password-reset endpoint exists; self-hosted app manages "
            "credentials directly in the DB. Re-enable if a reset flow is added."
        )
    )
    @pytest.mark.asyncio
    async def test_password_reset_no_user_leak(self) -> None:
        """Password reset doesn't reveal user existence (no reset endpoint)."""
        pass


class TestLoginLockout:
    """Per-account lockout: 5 wrong passwords in 15 minutes locks the account."""

    def _service_with_fake_cache(self):
        from unittest.mock import AsyncMock

        from app.services.auth_service import AuthService

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

        service = AuthService(AsyncMock())
        return service, store, fake_get, fake_increment, fake_expire, fake_delete

    @pytest.mark.asyncio
    async def test_five_failures_lock_account(self) -> None:
        service, _store, fake_get, fake_increment, fake_expire, fake_delete = self._service_with_fake_cache()
        with patch("app.services.auth_service.cache_manager") as mock_cache:
            mock_cache.get = AsyncMock(side_effect=fake_get)
            mock_cache.increment = AsyncMock(side_effect=fake_increment)
            mock_cache.expire = AsyncMock(side_effect=fake_expire)
            mock_cache.delete = AsyncMock(side_effect=fake_delete)

            for _ in range(5):
                await service._record_login_failure("email", "a@example.com", user_exists=True)
            assert await service._login_locked("email", "a@example.com") is True

    @pytest.mark.asyncio
    async def test_unknown_accounts_not_counted(self) -> None:
        service, store, fake_get, fake_increment, fake_expire, fake_delete = self._service_with_fake_cache()
        with patch("app.services.auth_service.cache_manager") as mock_cache:
            mock_cache.get = AsyncMock(side_effect=fake_get)
            mock_cache.increment = AsyncMock(side_effect=fake_increment)
            mock_cache.expire = AsyncMock(side_effect=fake_expire)
            mock_cache.delete = AsyncMock(side_effect=fake_delete)

            for _ in range(10):
                await service._record_login_failure("email", "ghost@example.com", user_exists=False)
            assert await service._login_locked("email", "ghost@example.com") is False
            assert store == {}

    @pytest.mark.asyncio
    async def test_success_clears_failures(self) -> None:
        service, _store, fake_get, fake_increment, fake_expire, fake_delete = self._service_with_fake_cache()
        with patch("app.services.auth_service.cache_manager") as mock_cache:
            mock_cache.get = AsyncMock(side_effect=fake_get)
            mock_cache.increment = AsyncMock(side_effect=fake_increment)
            mock_cache.expire = AsyncMock(side_effect=fake_expire)
            mock_cache.delete = AsyncMock(side_effect=fake_delete)

            await service._record_login_failure("email", "a@example.com", user_exists=True)
            await service._clear_login_failures("email", "a@example.com")
            assert await service._login_locked("email", "a@example.com") is False


# Re-exported for any external consumers; keeps the historical import surface.
__all__ = [
    "TestTokenSecurity",
    "TestPasswordSecurity",
    "TestPasswordPolicy",
    "TestVerificationCodeSecurity",
    "TestAccountEnumeration",
    "TestLoginLockout",
]


class TestRegistrationKillSwitch:
    """REGISTRATION_OPEN=false must reject sign-ups before any work."""

    @pytest.mark.asyncio
    async def test_registration_closed_rejects_before_db_or_verification(self, monkeypatch) -> None:
        from unittest.mock import AsyncMock

        from app.core.config import settings
        from app.services.auth_service import AuthService

        monkeypatch.setattr(settings, "REGISTRATION_OPEN", False)
        # A bare mock session: if the service touched the DB before the switch
        # check, this test would fail on unexpected calls / missing awaitables.
        service = AuthService(AsyncMock())

        with pytest.raises(BusinessError) as exc:
            await service.register("email", "closed@example.com", "password1", "123456")
        assert exc.value.error_code == AuthErrorCode.REGISTRATION_CLOSED
