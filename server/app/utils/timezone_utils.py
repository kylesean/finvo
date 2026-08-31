"""Timezone utilities for recurring rule calculations.

Rule and user timezones arrive from user input and legacy data and may be
invalid (typos, offset strings like "+08:00"); a bad timezone must never
crash scheduling — it degrades to the fallback and logs.
"""

from __future__ import annotations

import logging
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

logger = logging.getLogger(__name__)


def resolve_timezone(timezone: str | None, fallback: str = "UTC") -> ZoneInfo:
    """Resolve an IANA timezone name to a ZoneInfo, degrading gracefully.

    Args:
        timezone: IANA name (e.g. "Asia/Shanghai"), possibly None/empty/invalid.
        fallback: IANA name to use when ``timezone`` is unusable (default UTC).

    Returns:
        A valid ZoneInfo — never raises.
    """
    if timezone:
        try:
            return ZoneInfo(timezone)
        except (ZoneInfoNotFoundError, ValueError):
            logger.warning(
                "invalid_timezone_falling_back",
                extra={"timezone": timezone, "fallback": fallback},
            )
    try:
        return ZoneInfo(fallback)
    except (ZoneInfoNotFoundError, ValueError):
        return ZoneInfo("UTC")
