"""Regression tests for statistics aggregation semantics.

Focus: lifecycle audit entries (source=SYSTEM, e.g. account-close disposal)
must never pollute user-facing income/expense analytics — they are balance
bookkeeping, not real spending/income.
"""

from datetime import UTC, datetime
from decimal import Decimal
from uuid import uuid4

import pytest

from app.models.transaction import Transaction
from app.models.user import User
from app.services.statistics_service import StatisticsService


@pytest.mark.asyncio
async def test_total_expense_summary_excludes_system_transactions(db_session):
    """The home total-expense summary must exclude close-disposal writeoffs."""
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username="stat_system",
        email="statsys@example.com",
        password="hash",
        registration_type="email",
    )
    db_session.add(user)

    now = datetime.now(UTC)
    db_session.add_all(
        [
            Transaction(
                uuid=uuid4(),
                user_uuid=user_uuid,
                type="EXPENSE",
                amount=Decimal("50.0"),
                amount_original=Decimal("50.0"),
                currency="CNY",
                transaction_at=now,
                category_key="FOOD",
                status="CLEARED",
            ),
            Transaction(
                uuid=uuid4(),
                user_uuid=user_uuid,
                type="EXPENSE",
                amount=Decimal("586000.0"),
                amount_original=Decimal("586000.0"),
                currency="CNY",
                transaction_at=now,
                category_key="OTHERS",
                status="CLEARED",
                source="SYSTEM",
            ),
        ]
    )
    await db_session.commit()

    service = StatisticsService(db_session)
    summary = await service.get_total_expense_summary(user_uuid)

    assert Decimal(summary["total_expense"]) == Decimal("50.0"), "SYSTEM writeoff must not inflate total expense"
    assert Decimal(summary["month_expense"]) == Decimal("50.0")
