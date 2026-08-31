"""Signed artifact URL helpers.

Artifact files (skill ``write_file`` output) can contain attacker-influenced
HTML, so they must never be served anonymously and must never execute scripts
in the app's origin. URLs are short-lived JWTs bound to the owning user and
the exact path — the same capability-token pattern as the upload
``/stream`` endpoint (upload.py).

Security properties:
- The token is bound to ``user_id`` and ``path``: a token for one artifact
  cannot be replayed against another user's or another file.
- ``exp`` is enforced server-side on every request.
- No token -> the request must present a valid Bearer access token instead.
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Any

from jose import JWTError, jwt

from app.core.config import settings

_ARTIFACT_TOKEN_TYPE = "artifact"


def sign_artifact_url(user_id: str, path: str) -> str:
    """Return the signed capability URL for an artifact file.

    The signed URL is valid for ``FILE_URL_EXPIRE_SECONDS`` (same budget as
    file-stream tokens), then the client must re-request it (e.g. ask the
    agent to regenerate the report).
    """
    expire = datetime.now(UTC) + timedelta(seconds=settings.FILE_URL_EXPIRE_SECONDS)
    payload = {
        "type": _ARTIFACT_TOKEN_TYPE,
        "user_id": user_id,
        "path": path,
        "exp": expire,
        "iat": datetime.now(UTC),
    }
    encoded = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return str(encoded)


def verify_artifact_token(token: str) -> tuple[str, str] | None:
    """Verify an artifact capability token.

    Returns ``(user_id, path)`` when the token is signature-valid, of the
    artifact type, and not expired; None otherwise.
    """
    try:
        payload: dict[str, Any] = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
            options={"verify_exp": True},
        )
    except JWTError:
        return None
    if payload.get("type") != _ARTIFACT_TOKEN_TYPE:
        return None
    user_id = payload.get("user_id")
    path = payload.get("path")
    if not isinstance(user_id, str) or not isinstance(path, str):
        return None
    return user_id, path
