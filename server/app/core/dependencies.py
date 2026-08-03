"""Dependency injection functions for FastAPI endpoints.

This module provides reusable dependency functions for:
- Database session management
- Redis client access
- User authentication
- Session management
"""

import hashlib
import json
from collections.abc import AsyncGenerator
from typing import Annotated, Any, cast

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.core.database import get_session
from app.core.exceptions import (
    AppException,
    AuthenticationError,
    CommonErrorCode,
    NotFoundError,
)
from app.core.logging import bind_context, logger
from app.models.user import User
from app.utils.auth_utils import (
    get_token_jti,
    get_token_remaining_seconds,
    verify_token,
)

# Security scheme for JWT authentication
security = HTTPBearer()

# Redis key namespace for revoked token jti entries.
_TOKEN_BLACKLIST_PREFIX = "auth:blacklist:"


async def revoke_token(redis_client: Any, token: str) -> bool:
    """Add a token's ``jti`` to the revocation blacklist until it expires.

    Returns True when the token was blacklisted (or Redis is unavailable and
    revocation cannot be recorded). Callers should treat an unavailable Redis
    conservatively: the token stays valid (graceful degradation).
    """
    if redis_client is None:
        logger.warning("token_revocation_redis_unavailable")
        return False
    jti = get_token_jti(token)
    if not jti:
        return False
    ttl = get_token_remaining_seconds(token)
    if ttl is None:
        return False
    try:
        await redis_client.setex(f"{_TOKEN_BLACKLIST_PREFIX}{jti}", ttl, "1")
        return True
    except Exception as e:
        logger.warning("token_revocation_failed", error=str(e))
        return False


async def is_token_revoked(redis_client: Any, token: str) -> bool:
    """Return True if the token's jti is on the revocation blacklist.

    Redis unavailability degrades to "not revoked" (tokens stay valid), which
    matches the project's optional-Redis posture.
    """
    if redis_client is None:
        return False
    jti = get_token_jti(token)
    if not jti:
        return False
    try:
        return bool(await redis_client.exists(f"{_TOKEN_BLACKLIST_PREFIX}{jti}"))
    except Exception as e:
        logger.warning("token_blacklist_check_failed", error=str(e))
        return False


async def _fetch_user(db: AsyncSession, user_uuid: str) -> User | None:
    """Fetch a user by UUID. Returns None if not found."""
    query = select(User).where(User.uuid == user_uuid)
    result = await db.execute(query)
    return result.scalar_one_or_none()


async def get_redis_client() -> AsyncGenerator[Any]:
    """Get Redis client for caching and session management.

    Returns the shared :class:`CacheManager` client backed by a connection
    pool. The singleton client must NOT be closed here — its lifecycle is
    owned by ``cache_manager`` and torn down at app shutdown via
    ``close_cache()``.

    Yields:
        Redis client instance or None if Redis is not configured/unreachable.
    """
    try:
        from app.core.cache import cache_manager

        yield cache_manager.get_client()
    except Exception as e:
        logger.warning("redis_client_unavailable", error=str(e))
        yield None


async def get_current_user_uuid(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
    redis_client: Annotated[Any, Depends(get_redis_client)],
) -> str:
    """Extract and verify user ID from JWT token.

    Args:
        credentials: HTTP authorization credentials containing JWT token
        redis_client: Redis client for token revocation (jti blacklist) checks

    Returns:
        str: User UUID from token

    Raises:
        AuthenticationError: If token is invalid, malformed, or revoked
    """
    try:
        token = credentials.credentials
        user_uuid = verify_token(token)

        if user_uuid is None:
            # Log a non-reversible fingerprint (SHA-256 prefix) for correlation
            # only. Never log raw token fragments: a JWT's first chars are the
            # base64 header (identical across tokens, no diagnostic value) and
            # the payload can carry sensitive claims.
            token_fingerprint = hashlib.sha256(token.encode()).hexdigest()[:12]
            logger.error("invalid_token", token_fingerprint=token_fingerprint, token_length=len(token))
            raise AuthenticationError("Invalid authentication credentials")

        if await is_token_revoked(redis_client, token):
            logger.warning("revoked_token_rejected", user_uuid=user_uuid)
            raise AuthenticationError("Invalid authentication credentials")

        return user_uuid

    except ValueError as ve:
        # A malformed token is an auth failure, not a validation/422 issue —
        # return 401 so callers treat it uniformly with other auth rejections.
        logger.error("token_validation_failed", error=str(ve), exc_info=True)
        raise AuthenticationError("Invalid authentication credentials")


async def get_current_user(
    user_uuid: Annotated[str, Depends(get_current_user_uuid)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> User:
    """Get the current authenticated user from database.

    Args:
        user_uuid: User UUID from JWT token
        db: Database session

    Returns:
        User: The authenticated user object

    Raises:
        NotFoundError: If user not found in database
        AppException: If the database query fails unexpectedly
    """
    try:
        user = await _fetch_user(db, user_uuid)

        if user is None:
            logger.error("user_not_found", user_uuid=user_uuid)
            raise NotFoundError("User")

        # Bind user context for logging
        bind_context(user_uuid=user.uuid)

        return user

    except AppException:
        raise
    except Exception as e:
        logger.error("get_current_user_failed", error=str(e), exc_info=True)
        raise AppException(
            "Failed to retrieve user information",
            status_code=500,
            error_code=CommonErrorCode.INTERNAL_ERROR,
        )


async def require_auth(
    user: Annotated[User, Depends(get_current_user)],
) -> User:
    """Require authentication for an endpoint.

    This is an alias for get_current_user that makes the intent clearer
    when used as a dependency.

    Args:
        user: The authenticated user

    Returns:
        User: The authenticated user object
    """
    return user


class OptionalAuth:
    """Optional authentication dependency.

    Returns the user if authenticated, None otherwise.
    Useful for endpoints that work differently for authenticated vs anonymous users.
    """

    async def __call__(
        self,
        credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(HTTPBearer(auto_error=False))],
        db: Annotated[AsyncSession, Depends(get_session)],
    ) -> User | None:
        """Get current user if authenticated, None otherwise.

        Args:
            credentials: Optional HTTP authorization credentials
            db: Database session

        Returns:
            User | None: User object if authenticated, None otherwise
        """
        if credentials is None:
            return None

        try:
            token = credentials.credentials
            user_uuid = verify_token(token)

            if user_uuid is None:
                return None

            user = await _fetch_user(db, user_uuid)

            if user:
                bind_context(user_uuid=user.uuid)

            return user

        except (ValueError, JWTError) as e:
            # Token-format / JWT-decode failures mean "no valid auth" → anonymous.
            # Other exceptions (DB outage, programming error) MUST propagate so
            # they surface as 5xx instead of silently downgrading authenticated
            # users to anonymous, which would mask real bugs.
            logger.warning("optional_auth_invalid_token", error=str(e))
            return None


# Create instance for use as dependency
optional_auth = OptionalAuth()


async def get_user_session_data(
    user: Annotated[User, Depends(get_current_user)],
    redis_client: Annotated[Any, Depends(get_redis_client)],
) -> dict[str, Any]:
    """Get user session data from Redis.

    Args:
        user: The authenticated user
        redis_client: Redis client

    Returns:
        dict: Session data or empty dict if not found
    """
    if redis_client is None:
        return {}

    try:
        session_key = f"user_session:{user.uuid}"
        session_data = await redis_client.get(session_key)

        if session_data:
            return cast(dict[str, Any], json.loads(session_data.decode()))

        return {}

    except Exception as e:
        logger.warning("get_session_data_failed", user_uuid=user.uuid, error=str(e))
        return {}


async def save_user_session_data(
    session_data: dict[str, Any],
    user: Annotated[User, Depends(get_current_user)],
    redis_client: Annotated[Any, Depends(get_redis_client)],
) -> bool:
    """Save user session data to Redis.

    Args:
        session_data: Data to save in session
        user: The authenticated user
        redis_client: Redis client

    Returns:
        bool: True if saved successfully
    """
    if redis_client is None:
        logger.warning("redis_not_available", message="Session data not saved")
        return False

    try:
        session_key = f"user_session:{user.uuid}"

        # Store session data with 30-day expiration
        await redis_client.setex(
            session_key,
            30 * 24 * 60 * 60,  # 30 days
            json.dumps(session_data),
        )

        logger.info("session_data_saved", user_uuid=user.uuid)
        return True

    except Exception as e:
        logger.error("save_session_data_failed", user_uuid=user.uuid, error=str(e))
        return False
