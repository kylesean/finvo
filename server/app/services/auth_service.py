"""Authentication service for user registration, login, and verification code management.

This module provides the core authentication business logic including:
- User registration with verification code validation
- User login with password verification and JWT generation
- Verification code sending and validation
- Account existence checking
"""

from __future__ import annotations

import re
import secrets
import uuid
from typing import Any, cast

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from uuid_utils import uuid7

from app.core.config import settings
from app.core.exceptions import AuthenticationError, AuthErrorCode, BusinessError
from app.core.logging import logger
from app.models.base import utc_now
from app.models.user import User
from app.utils.auth_utils import create_access_token


class AuthService:
    """Authentication service for handling user authentication operations.

    This service manages:
    - User registration with verification code validation
    - User login with password verification
    - Verification code generation, storage, and validation
    - Account existence checking
    """

    def __init__(self, db_session: AsyncSession):
        """Initialize the authentication service.

        Args:
            db_session: Async database session
        """
        self.db = db_session

    async def send_verification_code(self, account_type: str, account: str) -> bool:
        """Send verification code to the specified account.

        1. Check if the account already exists.
        2. Send the verification code asynchronously via a background task.

        Args:
            account_type: Type of account ('email' or 'mobile')
            account: Email address or mobile number

        Returns:
            bool: True (returns immediately; the code is sent in the background)

        Raises:
            BusinessError: If account already exists
        """
        from app.core.background_tasks import background_task_manager
        from app.services.code_manager import code_manager

        if await self.is_account_exists(account_type, account):
            if account_type == "email":
                raise BusinessError(message="Email already registered", error_code=AuthErrorCode.EMAIL_REGISTERED)
            else:
                raise BusinessError(
                    message="Mobile number already registered", error_code=AuthErrorCode.PHONE_NUMBER_REGISTERED
                )

        await background_task_manager.run_in_background(code_manager.send_code, account_type, account)

        logger.info(
            "verification_code_job_queued",
            account_type=account_type,
            account=account[:3] + "***",  # Mask account for privacy
        )

        return True

    async def verify_code(self, account: str, code: str) -> bool:
        """Verify the verification code for an account.

        Args:
            account: Email address or mobile number
            code: 6-digit verification code

        Returns:
            bool: True if code is valid, False otherwise
        """
        from app.services.code_manager import code_manager

        return await code_manager.verify_code(account, code)

    async def register(
        self,
        account_type: str,
        account: str,
        password: str,
        code: str,
        timezone: str = "Asia/Shanghai",
        client_ip: str | None = None,
        locale: str | None = None,
    ) -> User:
        """Register a new user.

        Args:
            account_type: Type of account ('email' or 'mobile')
            account: Email address or mobile number
            password: Plain text password (will be hashed)
            code: 6-digit verification code
            timezone: User's timezone
            client_ip: Client IP address
            locale: User's preferred locale

        Returns:
            User: The created user object

        Raises:
            ValueError: If verification code is invalid or account already exists
        """
        # Normalize the account once, up front: emails are case-insensitive, so
        # strip + lowercase before the existence check and before storage. The
        # old Pydantic model validators are gone (models are plain SQLAlchemy),
        # so this normalization is now the single source of truth.
        if account_type == "email":
            account = account.strip().lower()
        else:
            account = account.strip()

        # Check if account already exists first (before verifying code)
        if await self.is_account_exists(account_type, account):
            if account_type == "email":
                raise BusinessError(message="Email already registered", error_code=AuthErrorCode.EMAIL_REGISTERED)
            else:
                raise BusinessError(
                    message="Mobile number already registered", error_code=AuthErrorCode.PHONE_NUMBER_REGISTERED
                )

        # Verify the code (skip when provider is mock — no real code is sent)
        provider = settings.EMAIL_PROVIDER if account_type == "email" else settings.SMS_PROVIDER
        if provider == "mock":
            # Mock mode bypasses real code verification; log it for auditability so
            # a misconfigured env doesn't silently allow unverified registrations.
            logger.warning("registration_code_verification_skipped_mock_provider", account_type=account_type)
        elif not await self.verify_code(account, code):
            raise BusinessError("Verification code is invalid or expired", error_code=AuthErrorCode.CODE_EXPIRED)

        # Generate unique UUID
        user_uuid = self._generate_uuid()

        # Generate username derived from account (i18n-friendly)
        username = self._generate_username(account, account_type)

        # Hash password
        hashed_password = User.hash_password(password)

        # Create user data
        user_data = {
            "id": user_uuid,
            "username": username,
            "password": hashed_password,
            "timezone": timezone,
            "registration_type": account_type,
            "last_login_at": utc_now(),
        }

        # Set client IP if provided (validation happens in model)
        if client_ip:
            user_data["last_login_ip"] = client_ip

        # Set email or mobile based on type
        if account_type == "email":
            user_data["email"] = account
        else:
            user_data["mobile"] = account

        # Create user.
        # Flush (not commit) so the INSERT is sent within the current transaction
        # and `user.uuid` is populated, but nothing is persisted yet. The financial
        # settings creation below runs in the SAME transaction; if it raises, both
        # inserts roll back together — no half-registered user. The single commit
        # point is after settings creation.
        user = User(**user_data)
        self.db.add(user)
        try:
            await self.db.flush()
        except IntegrityError:
            # Race: another request created the same email/mobile between the
            # is_account_exists check above and this INSERT (unique constraint).
            await self.db.rollback()
            if account_type == "email":
                raise BusinessError(message="Email already registered", error_code=AuthErrorCode.EMAIL_REGISTERED)
            raise BusinessError(
                message="Mobile number already registered", error_code=AuthErrorCode.PHONE_NUMBER_REGISTERED
            )
        await self.db.refresh(user)

        # Create default financial settings for the new user.
        # IMPORTANT: Currency inference runs ONLY HERE (once at registration).
        # Do NOT add login hooks, background jobs, or periodic tasks that
        # re-infer currency from locale — the user's primary_currency is
        # immutable after registration unless explicitly changed via the
        # financial-settings API.
        await self._create_default_financial_settings(user.uuid, locale=locale, timezone=timezone)

        # Single commit point: user + financial settings are atomic.
        await self.db.commit()

        logger.info("user_registered", user_uuid=user.uuid, account_type=account_type)

        return user

    async def _create_default_financial_settings(
        self, user_uuid: Any, locale: str | None = None, timezone: str | None = None
    ) -> None:
        """Create default financial settings for a new user.

        Currency is inferred from locale/timezone when available.
        This method is called EXACTLY ONCE during registration.
        It must NOT be called from login, scheduled jobs, or any other path.

        Runs within the caller's transaction and does NOT commit. If this
        raises, the caller (:meth:`register`) rolls back so the user and its
        financial settings are either both persisted or neither.

        Args:
            user_uuid: The user's UUID
            locale: User's locale (e.g. "zh_CN")
            timezone: User's IANA timezone (e.g. "Asia/Shanghai")

        Raises:
            Exception: Propagates any failure from settings creation so the
                caller's transaction rolls back atomically.
        """
        from app.services.user_service import UserService

        # sqlmodel.AsyncSession is a thin subclass of sqlalchemy.AsyncSession;
        # the type mismatch is only in the stubs, not at runtime.
        user_service = UserService(self.db)  # type: ignore[arg-type]
        await user_service.create_default_financial_settings(user_uuid, locale=locale, timezone=timezone, commit=False)
        logger.info("default_financial_settings_created", user_uuid=str(user_uuid))

    async def login(
        self, account_type: str, account: str, password: str, timezone: str, client_ip: str | None = None
    ) -> tuple[User, str]:
        """Authenticate user and generate JWT token.

        Args:
            account_type: Type of account ('email' or 'mobile')
            account: Email address or mobile number
            password: Plain text password
            timezone: User's timezone
            client_ip: Client IP address

        Returns:
            Tuple[User, str]: User object and JWT token

        Raises:
            ValueError: If credentials are invalid
        """
        # Find user by account
        query = select(User)
        if account_type == "email":
            query = query.where(User.email == account)
        else:
            query = query.where(User.mobile == account)

        result = await self.db.execute(query)
        user = result.scalar_one_or_none()

        # Verify password.
        # Security: use a single generic message + error code for both "user not found"
        # and "wrong password" branches to prevent account enumeration via distinguishable
        # error responses. The original USER_NOT_EXIST / USER_NOT_MATCH_PASSWORD codes are
        # intentionally collapsed into AUTHENTICATE_FAILED here.
        if not user or not user.verify_password(password):
            raise AuthenticationError(
                message="Invalid credentials",
                error_code=AuthErrorCode.AUTHENTICATE_FAILED,
            )

        # Update user login information
        if user.timezone != timezone:
            user.timezone = timezone

        if client_ip:
            user.last_login_ip = client_ip

        # Always update last login time
        user.last_login_at = utc_now()

        await self.db.commit()
        await self.db.refresh(user)

        # Generate JWT token using user UUID
        token_obj = create_access_token(user.uuid)
        token = token_obj.access_token

        logger.info("user_logged_in", user_uuid=user.uuid, account_type=account_type)

        return user, token

    async def is_account_exists(self, account_type: str, account: str) -> bool:
        """Check if an account already exists.

        Args:
            account_type: Type of account ('email' or 'mobile')
            account: Email address or mobile number

        Returns:
            bool: True if account exists, False otherwise
        """
        query = select(User)
        if account_type == "email":
            query = query.where(User.email == account)
        else:
            query = query.where(User.mobile == account)

        result = await self.db.execute(query)
        user = result.scalar_one_or_none()

        return user is not None

    # Private helper methods

    def _generate_uuid(self) -> uuid.UUID:
        """Generate a unique UUID v7 for user.

        UUID v7 format: time-ordered UUID with millisecond precision timestamp.

        Returns:
            uuid.UUID: UUID v7 object
        """
        return cast(uuid.UUID, uuid7())

    def _generate_username(self, account: str, account_type: str) -> str:
        """Generate a user-friendly username derived from the account.

        Strategy (inspired by GitLab/Grafana/Discourse):
        - Email: use the local part (before @) as base, sanitized
        - Mobile: use masked digits as base
        - Append a short random suffix for uniqueness feel

        The result is language-neutral and works across all locales.

        Args:
            account: Email address or mobile number
            account_type: 'email' or 'mobile'

        Returns:
            str: Generated username (max 30 chars)
        """
        max_len = 30
        suffix_len = 5  # e.g. "_a3x7"

        if account_type == "email":
            # Extract local part: "john.doe@gmail.com" -> "john.doe"
            local_part = account.split("@")[0]
            # Replace dots, hyphens, plus signs with underscore
            base = re.sub(r"[.+\-]", "_", local_part)
            # Keep only alphanumeric and underscore
            base = re.sub(r"[^a-zA-Z0-9_]", "", base)
            # Collapse consecutive underscores
            base = re.sub(r"_+", "_", base).strip("_")
        else:
            # Mobile: use last 4 digits as base
            digits = re.sub(r"\D", "", account)
            base = f"user_{digits[-4:]}" if len(digits) >= 4 else "user"

        # Truncate base to leave room for suffix
        base = base[: max_len - suffix_len].rstrip("_")

        # If base is too short or empty, use a generic prefix
        if len(base) < 2:
            base = "user"

        # Generate a short alphanumeric suffix (lowercase)
        alphabet = "abcdefghjkmnpqrstuvwxyz23456789"  # pragma: allowlist secret
        suffix = "".join(alphabet[secrets.randbelow(len(alphabet))] for _ in range(suffix_len - 1))

        return f"{base}_{suffix}"
