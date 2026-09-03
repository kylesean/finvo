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

import jwt
from jwt import PyJWTError as JWTError

from app.core.config import settings
from app.core.logging import logger
from app.schemas.auth import Token


def create_access_token(
    subject: str | UUID | Any = None,
    expires_delta: timedelta | None = None,
    data: dict[str, Any] | None = None,
) -> Token:
    """Create a new access token."""
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
            "jti": secrets.token_urlsafe(16),
            "type": "access",
        }
    )

    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

    logger.info("token_created", subject=subject_str, expires_at=expire.isoformat())

    return Token(access_token=encoded_jwt, expires_at=expire)


def create_refresh_token(subject: str | UUID | Any = None) -> Token:
    """Create a long-lived refresh token for [subject].

    Refresh tokens carry a ``type: "refresh"`` claim so the refresh endpoint can
    distinguish them from access tokens. They are rotated on every refresh and
    can be revoked via the same jti blacklist as access tokens.
    """
    to_encode: dict[str, Any] = {"type": "refresh"}
    if subject:
        to_encode["sub"] = str(subject)
    else:
        to_encode["sub"] = str(to_encode.get("sub", "unknown"))

    expire = datetime.now(UTC) + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update(
        {
            "exp": expire,
            "iat": datetime.now(UTC),
            "jti": secrets.token_urlsafe(16),
        }
    )

    encoded = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    logger.info("refresh_token_created", subject=to_encode["sub"], expires_at=expire.isoformat())
    return Token(access_token=encoded, expires_at=expire)


def is_refresh_token(token: str) -> bool:
    """Return True if [token] is a refresh-type token (signature-valid)."""
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
            options={"verify_exp": False},
        )
        return str(payload.get("type")) == "refresh"
    except JWTError:
        return False


def verify_token(token: str) -> str | None:
    """Verify an access token, return subject UUID. Rejects refresh tokens."""
    if not token or not isinstance(token, str):
        logger.warning("token_invalid_format")
        raise ValueError("Token must be a non-empty string")

    if not re.match(r"^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$", token):
        logger.warning("token_suspicious_format")
        raise ValueError("Token format is invalid - expected JWT format")

    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])

        if payload.get("type") != "access":
            logger.warning("token_not_access_type_rejected")
            return None

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
        claims = jwt.decode(token, options={"verify_signature": False})
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


# NOTE: no unsafe decode helper — use verify_token; debug via jose directly in a REPL.


def verify_refresh_token(token: str) -> str | None:
    """Verify a refresh token, return subject UUID. Rejects access tokens."""
    if not token or not isinstance(token, str):
        logger.warning("token_invalid_format")
        raise ValueError("Token must be a non-empty string")

    if not re.match(r"^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$", token):
        logger.warning("token_suspicious_format")
        raise ValueError("Token format is invalid - expected JWT format")

    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
            options={"verify_exp": True},  # expired refresh tokens must NOT refresh
        )
        if str(payload.get("type")) != "refresh":
            logger.warning("token_not_refresh_type")
            return None
        subject_id = payload.get("sub")
        if not isinstance(subject_id, str):
            logger.warning("token_missing_subject")
            return None
        return subject_id
    except JWTError as e:
        logger.error("token_refresh_verification_failed", error=str(e))
        return None
