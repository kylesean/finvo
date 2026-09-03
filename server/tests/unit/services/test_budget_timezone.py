"""P2-10 regression: budget period boundaries follow the owner's timezone.

Server-local ``date.today()`` put UTC+8 users' pre-16:00 spending into
"yesterday's" budget period. Period lookup/creation now uses the owner's
local date. Historical periods are intentionally NOT rewritten (documented
in 01-business-flows P2-10): old rows keep server-local boundaries, new
rows use user time.
"""

from datetime import UTC, date, datetime
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.budget import Budget, BudgetPeriod
from app.models.user import User
from app.services.budget_period_service import BudgetPeriodService
from app.services.statistics_scope import user_local_today


class TestUserLocalToday:
    def test_kiritimati_ahead_baker_behind(self) -> None:
        # 2026-09-01 00:30 UTC: Kiritimati (+14) is already Sep 1 14:30,
        # Baker Island (-12) is still Aug 31 12:30.
        now = datetime(2026, 9, 1, 0, 30, tzinfo=UTC)
        assert user_local_today("Pacific/Kiritimati", now_utc=now) == date(2026, 9, 1)
        assert user_local_today("Etc/GMT+12", now_utc=now) == date(2026, 8, 31)

    def test_shanghai_boundary(self) -> None:
        # 2026-08-31 15:59 UTC is still Aug 31 in Shanghai; one minute later
        # it is Sep 1 — the exact window the old server-local math got wrong.
        assert user_local_today("Asia/Shanghai", now_utc=datetime(2026, 8, 31, 15, 59, tzinfo=UTC)) == date(
            2026, 8, 31
        )
        assert user_local_today("Asia/Shanghai", now_utc=datetime(2026, 8, 31, 16, 0, tzinfo=UTC)) == date(2026, 9, 1)

    def test_bad_timezone_falls_back_to_utc(self) -> None:
        now = datetime(2026, 9, 15, 12, 0, tzinfo=UTC)
        assert user_local_today("Not/AZone", now_utc=now) == date(2026, 9, 15)
        assert user_local_today(None, now_utc=now) == date(2026, 9, 15)


class TestBudgetPeriodUsesOwnerTimezone:
    @pytest.mark.asyncio
    async def test_current_period_lookup_uses_mocked_owner_date(self, db_session: AsyncSession, monkeypatch) -> None:
        """Pin the owner's local date and assert the containing period wins,
        regardless of what the server's wall clock says."""
        user = User(
            uuid=uuid4(),
            username=f"tz-{uuid4().hex[:8]}",
            email=f"tz-{uuid4().hex[:8]}@example.com",
            password="hash",
            registration_type="email",
            timezone="Pacific/Kiritimati",
        )
        db_session.add(user)
        await db_session.flush()
        budget = Budget(
            owner_uuid=user.uuid,
            name="tz budget",
            scope="TOTAL",
            amount=Decimal("1000"),
            currency_code="CNY",
        )
        db_session.add(budget)
        await db_session.flush()
        august = BudgetPeriod(
            budget_id=budget.id,
            period_start=date(2026, 8, 1),
            period_end=date(2026, 8, 31),
            adjusted_target=Decimal("1000"),
        )
        september = BudgetPeriod(
            budget_id=budget.id,
            period_start=date(2026, 9, 1),
            period_end=date(2026, 9, 30),
            adjusted_target=Decimal("1000"),
        )
        db_session.add_all([august, september])
        await db_session.commit()

        import app.services.statistics_scope as scope

        # Owner-local Sep 1 -> september, even if the server thinks otherwise.
        monkeypatch.setattr(scope, "user_local_today", lambda *a, **k: date(2026, 9, 1))
        found = await BudgetPeriodService(db_session)._get_current_period(budget)
        assert found is not None and found.period_start == date(2026, 9, 1)

        monkeypatch.setattr(scope, "user_local_today", lambda *a, **k: date(2026, 8, 31))
        found = await BudgetPeriodService(db_session)._get_current_period(budget)
        assert found is not None and found.period_start == date(2026, 8, 1)
