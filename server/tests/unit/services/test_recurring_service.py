import calendar
from datetime import UTC, date, datetime, time
from zoneinfo import ZoneInfo

import pytest

from app.core.exceptions import BusinessError
from app.services.transaction.recurring_service import (
    RecurringTransactionService,
    validate_recurrence_rule,
)


def test_validate_recurrence_rule_valid():
    assert validate_recurrence_rule("FREQ=MONTHLY;BYMONTHDAY=1") == "FREQ=MONTHLY;BYMONTHDAY=1"
    assert validate_recurrence_rule("FREQ=WEEKLY;BYDAY=MO,WE") == "FREQ=WEEKLY;BYDAY=MO,WE"
    assert validate_recurrence_rule("FREQ=MONTHLY;BYMONTHDAY=-1") == "FREQ=MONTHLY;BYMONTHDAY=-1"


def test_validate_recurrence_rule_invalid():
    with pytest.raises(BusinessError, match="must start with FREQ="):
        validate_recurrence_rule("INVALID_RULE")

    with pytest.raises(BusinessError):
        validate_recurrence_rule("FREQ=INVALID_FREQ")

    with pytest.raises(BusinessError):
        validate_recurrence_rule("FREQ=MONTHLY;BYDAY=INVALID_DAY")


def test_calculate_next_execution_historical_start_date(db_session):
    service = RecurringTransactionService(db_session)
    # Start date 3 years ago (approx 1095 days)
    start_date = date(2023, 1, 1)

    next_exec = service.calculate_next_execution(
        rrule_str="FREQ=DAILY",
        start_date=start_date,
    )

    assert next_exec is not None
    assert next_exec > datetime.now(UTC)


def test_calculate_next_execution_month_end_31(db_session):
    service = RecurringTransactionService(db_session)
    start_date = date(2026, 1, 31)

    next_exec = service.calculate_next_execution(
        rrule_str="FREQ=MONTHLY;BYMONTHDAY=31",
        start_date=start_date,
    )

    assert next_exec is not None
    assert next_exec > datetime.now(UTC)


def test_calculate_next_execution_last_day_of_month(db_session):
    service = RecurringTransactionService(db_session)
    start_date = date(2026, 1, 1)

    next_exec = service.calculate_next_execution(
        rrule_str="FREQ=MONTHLY;BYMONTHDAY=-1",
        start_date=start_date,
    )

    assert next_exec is not None
    assert next_exec > datetime.now(UTC)


# =========================================================================
# Timezone anchoring (A2): "the 1st of each month" must be the 1st in the
# RULE's local calendar, not UTC's. All day math happens in the rule
# timezone; the stored instant is UTC.
# =========================================================================


def _next_first_of_month(service, timezone: str) -> datetime:
    """Next occurrence of "monthly on the 1st" for a rule in [timezone]."""
    return service.calculate_next_execution(
        rrule_str="FREQ=MONTHLY;BYMONTHDAY=1",
        start_date=date(2020, 1, 1),
        timezone=timezone,
    )


def test_timezone_anchor_shanghai_aligns_local_calendar(db_session):
    """UTC+8 rule fires at LOCAL midnight on the 1st, stored as UTC.

    Before the fix the rule was anchored at UTC midnight: the local instant
    came out at 08:00 local — same day, wrong hour (and the stored instant
    was 8h late vs local semantics).
    """
    service = RecurringTransactionService(db_session)
    shanghai = _next_first_of_month(service, "Asia/Shanghai")

    local = shanghai.astimezone(ZoneInfo("Asia/Shanghai"))
    assert local.day == 1
    assert local.time() == time(0, 0)
    # Stored instant == local midnight converted to UTC (round-trip).
    assert shanghai == local.astimezone(UTC)


def test_timezone_anchor_new_york_keeps_local_date(db_session):
    """UTC-5 rule must NOT fire on the previous calendar day (DST-aware).

    Before the fix a UTC-anchored "the 1st" resolved to 20:00/21:00 on the
    PREVIOUS day for New York users. local.day == 1 catches that regression
    regardless of DST.
    """
    service = RecurringTransactionService(db_session)
    new_york = _next_first_of_month(service, "America/New_York")

    local = new_york.astimezone(ZoneInfo("America/New_York"))
    assert local.day == 1
    assert local.time() == time(0, 0)
    assert new_york == local.astimezone(UTC)


def test_timezone_month_end_clamp_in_local_calendar(db_session):
    """BYMONTHDAY=31 clamps to the local month's last day (e.g. Sep 30)."""
    service = RecurringTransactionService(db_session)
    next_exec = service.calculate_next_execution(
        rrule_str="FREQ=MONTHLY;BYMONTHDAY=31",
        start_date=date(2020, 1, 31),
        timezone="Asia/Shanghai",
    )

    local = next_exec.astimezone(ZoneInfo("Asia/Shanghai"))
    last_day = calendar.monthrange(local.year, local.month)[1]
    assert local.day == last_day
    assert local.time() == time(0, 0)


def test_invalid_timezone_falls_back_to_utc(db_session):
    """A junk timezone (e.g. legacy "+08:00") must not crash scheduling."""
    service = RecurringTransactionService(db_session)
    junk_tz = _next_first_of_month(service, "+08:00")
    utc = _next_first_of_month(service, "UTC")

    assert junk_tz is not None
    # Fallback == UTC anchoring, which is local midnight in the UTC calendar.
    assert junk_tz.astimezone(ZoneInfo("UTC")).time() == time(0, 0)
    assert junk_tz == utc
