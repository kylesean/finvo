"""This file contains the authentication utilities for the application."""

from __future__ import annotations

import re
import secrets
from datetime import (
    UTC,
    datetime,
    timedelta,
)
from typing import Any
from uuid import UUID

from jose import (
    JWTError,
    jwt,
)

from app.core.config import settings
from app.core.logging import logger
from app.schemas.auth import Token


def create_access_token(
    subject: str | UUID | Any = None,
    expires_delta: timedelta | None = None,
    data: dict[str, Any] | None = None,
) -> Token:
    """Create a new access token.

    Args:
        subject: The subject (user UUID). Can be str or UUID.
        expires_delta: Optional expiration time delta.
        data: Optional additional data to include in the token.
    """
    to_encode = data.copy() if data else {}

    if subject:
        # Convert UUID to string if needed
        subject_str = str(subject)
        to_encode["sub"] = subject_str
    else:
        subject_str = str(to_encode.get("sub", "unknown"))

    if expires_delta:
        expire = datetime.now(UTC) + expires_delta
    else:
        expire = datetime.now(UTC) + timedelta(days=settings.JWT_ACCESS_TOKEN_EXPIRE_DAYS)

    to_encode.update(
        {
            "exp": expire,
            "iat": datetime.now(UTC),
            # Unique random token identifier — enables future revocation by jti
            "jti": secrets.token_urlsafe(16),
        }
    )

    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

    logger.info("token_created", subject=subject_str, expires_at=expire.isoformat())

    return Token(access_token=encoded_jwt, expires_at=expire)


def verify_token(token: str) -> str | None:
    """Verify a JWT token and return the subject (user UUID).

    Args:
        token: The JWT token to verify.

    Returns:
        str | None: The subject ID if token is valid, None otherwise.

    Raises:
        ValueError: If the token format is invalid
    """
    if not token or not isinstance(token, str):
        logger.warning("token_invalid_format")
        raise ValueError("Token must be a non-empty string")

    # Basic format validation before attempting decode
    if not re.match(r"^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$", token):
        logger.warning("token_suspicious_format")
        raise ValueError("Token format is invalid - expected JWT format")

    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])

        subject_id: str | None = payload.get("sub")
        if subject_id is None:
            logger.warning("token_missing_subject")
            return None

        logger.debug("token_verified", subject=subject_id)
        return subject_id

    except JWTError as e:
        logger.error("token_verification_failed", error=str(e))
        return None


def get_token_claims(token: str) -> dict[str, Any]:
    """Extract unverified claims from a token.

    Used only for revocation bookkeeping (jti/exp lookups) on already-validated
    tokens — never for authentication decisions.
    """
    try:
        claims = jwt.get_unverified_claims(token)
        return claims if isinstance(claims, dict) else {}
    except JWTError:
        return {}


def get_token_jti(token: str) -> str | None:
    """Return the token's ``jti`` claim (for blacklist lookup) or None."""
    jti = get_token_claims(token).get("jti")
    return jti if isinstance(jti, str) else None


def get_token_remaining_seconds(token: str) -> int | None:
    """Return the number of seconds until the token expires (>= 0), or None.

    Used as the TTL for blacklist entries so revoked tokens stay blocked only
    until they would have expired anyway.
    """
    exp = get_token_claims(token).get("exp")
    if not isinstance(exp, (int, float)):
        return None
    remaining = int(exp) - int(datetime.now(UTC).timestamp())
    return max(remaining, 0)


def refresh_token(old_token: str) -> Token | None:
    """Refresh an existing JWT token.

    Args:
        old_token: The existing JWT token to refresh.

    Returns:
        Token | None: A new token if the old token is valid, None otherwise.

    Raises:
        ValueError: If the token format is invalid
    """
    # Verify the old token first
    user_uuid = verify_token(old_token)
    if user_uuid is None:
        logger.warning("token_refresh_failed_invalid_token")
        return None

    # Create a new token with the same user UUID as subject
    new_token = create_access_token(user_uuid)

    logger.info("token_refreshed", user_uuid=user_uuid, expires_at=new_token.expires_at.isoformat())

    return new_token


# NOTE: The unsafe `decode_token_payload` (signature verification bypass) was
# removed — it had zero call sites and invited misuse. Use `verify_token` for
# all authentication paths; for debugging, decode with jose directly in a REPL.
