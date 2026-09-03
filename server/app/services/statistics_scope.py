"""Single source of truth for user-facing spending statistics scope.

BF-P1-8: the space monthly summary (agent tool) counted PENDING and SYSTEM
lifecycle rows and used a UTC month boundary, while the budget engine filters
to CLEARED + non-SYSTEM. Both paths must share one scope definition so the
agent's "how much did we spend" answer matches the REST statistics endpoint.

Scope rules (aligned with budget_period_service + statistics_service):
- Only ``status == "CLEARED"`` counts as spending (PENDING periodic rows are
  not yet real money).
- Exclude ``source == SYSTEM`` lifecycle audit entries (account-close disposal
  bookkeeping, never user spending).
- Month boundaries are computed in the user's timezone (IANA string from
  ``users.timezone``), not UTC.
"""

from __future__ import annotations

from datetime import UTC, date, datetime
from typing import Any
from uuid import UUID
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.transaction import SYSTEM_TRANSACTION_SOURCE, Transaction

# Re-export so callers import the scope from one place.
__all__ = [
    "SYSTEM_TRANSACTION_SOURCE",
    "settled_spending_conditions",
    "user_month_start_utc",
    "user_local_today",
    "get_user_timezone",
]


def settled_spending_conditions() -> list[Any]:
    """Return the shared CLEARED + non-SYSTEM filter conditions."""
    return [
        Transaction.status == "CLEARED",
        Transaction.source != SYSTEM_TRANSACTION_SOURCE,
    ]


def user_month_start_utc(
    now_utc: datetime,
    user_timezone: str | None,
) -> datetime:
    """Return the current-month start as an aware UTC datetime.

    Args:
        now_utc: Current time (aware UTC).
        user_timezone: IANA timezone string from ``users.timezone``.

    Falls back to a UTC month boundary when the timezone is missing/invalid —
    never raises for a bad profile value.
    """
    if now_utc.tzinfo is None:
        now_utc = now_utc.replace(tzinfo=UTC)
    try:
        tz = ZoneInfo(user_timezone) if user_timezone else ZoneInfo("UTC")
    except (ZoneInfoNotFoundError, ValueError):
        tz = ZoneInfo("UTC")
    local_now = now_utc.astimezone(tz)
    local_start = local_now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    return local_start.astimezone(UTC)


def user_local_today(user_timezone: str | None, *, now_utc: datetime | None = None) -> date:
    """Return "today" as a calendar date in the user's timezone (P2-10).

    Budget period boundaries are date-based; using the server's local date
    puts UTC+8 users' pre-16:00 spending into "yesterday's" budget period.
    Falls back to the UTC date on missing/invalid timezones — never raises
    for a bad profile value.
    """
    now = now_utc or datetime.now(UTC)
    if now.tzinfo is None:
        now = now.replace(tzinfo=UTC)
    try:
        tz = ZoneInfo(user_timezone) if user_timezone else ZoneInfo("UTC")
    except (ZoneInfoNotFoundError, ValueError):
        tz = ZoneInfo("UTC")
    return now.astimezone(tz).date()


async def get_user_timezone(db: AsyncSession, user_uuid: UUID) -> str:
    """Return the user's IANA timezone string ("UTC" when unset/unreadable).

    Never raises: period lookup must not fail because of a profile read.
    """
    try:
        from app.models.user import User

        result = await db.execute(select(User.timezone).where(User.uuid == user_uuid))
        return result.scalar_one_or_none() or "UTC"
    except Exception:  # noqa: BLE001 - fall back to UTC boundary
        return "UTC"
