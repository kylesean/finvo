"""Rollover savepoint race must not double-count.

When a concurrent worker wins the period insert, the loser's savepoint
rolls back only the failed INSERT — but the in-memory rollover additions
(budget.rollover_balance, prev_period mutations) made EARLIER in the loop
iteration survive on the objects and would double-count on flush. The
except branch resyncs both from the database.
"""

import asyncio
from datetime import date
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession

from app.models.budget import Budget, BudgetPeriod
from app.models.user import User
from app.services.budget_period_service import BudgetPeriodService


async def _seed(db: AsyncSession) -> tuple[User, Budget, BudgetPeriod]:
    user = User(
        uuid=uuid4(),
        username=f"roll-{uuid4().hex[:8]}",
        email=f"roll-{uuid4().hex[:8]}@example.com",
        password="hash",
        registration_type="email",
    )
    db.add(user)
    await db.flush()
    budget = Budget(
        owner_uuid=user.uuid,
        name="roll budget",
        scope="TOTAL",
        amount=Decimal("1000"),
        currency_code="CNY",
        rollover_enabled=True,
        rollover_balance=Decimal("0"),
    )
    db.add(budget)
    await db.flush()
    prev = BudgetPeriod(
        budget_id=budget.id,
        period_start=date(2026, 8, 1),
        period_end=date(2026, 8, 31),
        adjusted_target=Decimal("1000"),
    )
    db.add(prev)
    await db.commit()
    return user, budget, prev


@pytest.mark.asyncio
async def test_lost_rollover_race_discards_phantom_surplus(
    db_session: AsyncSession, async_db_engine: AsyncEngine, monkeypatch
) -> None:
    import app.services.statistics_scope as scope

    _, budget, _prev = await _seed(db_session)
    # Owner-local "today" inside September: the missing Sep period must be built.
    monkeypatch.setattr(scope, "user_local_today", lambda *a, **k: date(2026, 9, 15))
    service = BudgetPeriodService(db_session)

    racer = AsyncSession(async_db_engine, expire_on_commit=False)
    try:
        # Racer holds the (budget_id, Sep-1) unique slot uncommitted: our
        # pre-check passes (MVCC-invisible) but our INSERT blocks on it.
        racer.add(
            BudgetPeriod(
                budget_id=budget.id,
                period_start=date(2026, 9, 1),
                period_end=date(2026, 9, 30),
                adjusted_target=Decimal("1000"),
            )
        )
        await racer.flush()

        task = asyncio.create_task(service.get_or_create_current_period(budget))
        await asyncio.sleep(0.2)
        await racer.commit()

        period = await task
        assert period.period_start == date(2026, 9, 1)

        # THE regression: the phantom surplus computed before the failed
        # insert must NOT survive on the budget object.
        await db_session.refresh(budget)
        assert Decimal(budget.rollover_balance) == Decimal("0")
    finally:
        await racer.close()
