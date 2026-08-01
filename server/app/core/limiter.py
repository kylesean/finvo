"""Rate limiting configuration for the application.

This module configures rate limiting using slowapi, with default limits
defined in the application settings. Rate limits are applied based on
remote IP addresses.
"""

from typing import Any

from slowapi import Limiter

from app.core.config import settings


def get_client_ip(request: Any) -> str:
    """Resolve the real client IP for rate limiting.

    Uses the trusted ``X-Forwarded-For`` client address only when the service is
    explicitly running behind a trusted reverse proxy (``settings.BEHIND_PROXY``).
    Otherwise it falls back to the direct socket peer, so untrusted clients
    cannot spoof the header to bypass limits.
    """
    if settings.BEHIND_PROXY:
        forwarded = request.headers.get("x-forwarded-for") if request.headers else None
        if forwarded:
            # x-forwarded-for: <client>, <proxy1>, ... — leftmost is the client.
            return str(forwarded).split(",")[0].strip()
    client = getattr(request, "client", None)
    return getattr(client, "host", None) or "unknown"


# Initialize rate limiter
limiter = Limiter(
    key_func=get_client_ip, default_limits=[limit.strip() for limit in settings.RATE_LIMIT_DEFAULT.split(",")]
)
