from datetime import UTC, date, datetime

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
    with pytest.raises(ValueError, match="must start with FREQ="):
        validate_recurrence_rule("INVALID_RULE")

    with pytest.raises(ValueError):
        validate_recurrence_rule("FREQ=INVALID_FREQ")

    with pytest.raises(ValueError):
        validate_recurrence_rule("FREQ=MONTHLY;BYDAY=INVALID_DAY")


def test_calculate_next_execution_historical_start_date(db_session):
    service = RecurringTransactionService(db_session)
    # Start date 3 years ago (approx 1095 days)
    start_date = date(2023, 1, 1)

    next_exec = service._calculate_next_execution(
        rrule_str="FREQ=DAILY",
        start_date=start_date,
    )

    assert next_exec is not None
    assert next_exec > datetime.now(UTC)


def test_calculate_next_execution_month_end_31(db_session):
    service = RecurringTransactionService(db_session)
    start_date = date(2026, 1, 31)

    next_exec = service._calculate_next_execution(
        rrule_str="FREQ=MONTHLY;BYMONTHDAY=31",
        start_date=start_date,
    )

    assert next_exec is not None
    assert next_exec > datetime.now(UTC)


def test_calculate_next_execution_last_day_of_month(db_session):
    service = RecurringTransactionService(db_session)
    start_date = date(2026, 1, 1)

    next_exec = service._calculate_next_execution(
        rrule_str="FREQ=MONTHLY;BYMONTHDAY=-1",
        start_date=start_date,
    )

    assert next_exec is not None
    assert next_exec > datetime.now(UTC)
