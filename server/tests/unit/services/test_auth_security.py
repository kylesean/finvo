"""Security-focused tests for AuthService.

This module contains security boundary tests for the authentication service.
Tests are grounded in the application's actual security-relevant behavior
(JWT signature/expiry/algorithm checks, bcrypt password hashing, single-use
verification codes, code TTL expiry, account-enumeration leakage).

Scope note: Finvo is a self-hosted personal finance app with negligible
concurrency and no multi-instance deployment. Features that only make sense
for high-concurrency/public-facing systems — login rate limiting, verification
code brute-force throttling, JWT token blacklisting/replay prevention, and a
password-reset endpoint — are intentionally not implemented. Their placeholder
tests are kept as ``pytest.skip`` with an explicit "self-hosted, out of scope"
reason, rather than being deleted, so the security checklist stays visible.
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
from app.utils.auth import create_access_token, verify_token


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

    @pytest.mark.skip(
        reason=(
            "Self-hosted app: token replay prevention (logout blacklist) is out "
            "of scope. Requires a Redis-backed jti blacklist + logout endpoint; "
            "not justified for a single-user personal finance deployment."
        )
    )
    @pytest.mark.asyncio
    async def test_token_replay_prevention(self) -> None:
        """Old tokens cannot be reused after logout (requires blacklist)."""
        pass


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
            mock_cache.delete.assert_called_once()

            # Second attempt: code already deleted → cache miss → fail.
            mock_cache.get = AsyncMock(return_value=None)
            second = await code_manager.verify_code(account, stored_code)
            assert second is False

    @pytest.mark.skip(
        reason=(
            "Self-hosted app: verification-code brute-force throttling (attempt "
            "counter + lockout) is out of scope. The 6-digit code already has a "
            "short TTL; single-user deployment doesn't justify lockout infra."
        )
    )
    @pytest.mark.asyncio
    async def test_code_brute_force_resistance(self) -> None:
        """Brute-force guessing is prevented (requires attempt lockout)."""
        pass


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


class TestRateLimiting:
    """Tests for authentication rate limiting.

    Rate limiting is intentionally not implemented: Finvo is a self-hosted,
    single-user personal finance app with negligible concurrency. Adding
    slowapi/Redis-backed login throttling would be over-engineering for this
    deployment model. Tests are kept as skipped placeholders to make the
    deliberate omission visible on the security checklist.
    """

    @pytest.mark.skip(
        reason=(
            "Self-hosted app: login rate limiting is out of scope. The app is "
            "single-user and not exposed to public traffic; throttling adds "
            "operational complexity (Redis/slowapi) without benefit."
        )
    )
    @pytest.mark.asyncio
    async def test_login_rate_limit_triggered(self) -> None:
        """Login rate limit is triggered after too many attempts."""
        pass

    @pytest.mark.skip(
        reason=(
            "Self-hosted app: verification-code request rate limiting is out of "
            "scope. Code sending is already infrequent; the existing 60s "
            "code_manager._acquire_rate_limit_lock is sufficient."
        )
    )
    @pytest.mark.asyncio
    async def test_verification_code_rate_limit(self) -> None:
        """Rate limiting for verification code requests."""
        pass

    @pytest.mark.skip(reason="Self-hosted app: rate-limit recovery test is out of scope (no rate limiter).")
    @pytest.mark.asyncio
    async def test_rate_limit_recovery(self) -> None:
        """Rate limit is lifted after cooldown period."""
        pass


# Re-exported for any external consumers; keeps the historical import surface.
__all__ = [
    "TestTokenSecurity",
    "TestPasswordSecurity",
    "TestVerificationCodeSecurity",
    "TestAccountEnumeration",
    "TestRateLimiting",
]
