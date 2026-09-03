"""BF-P1-6 (space settlement base currency) + BF-P1-8 (monthly scope) regressions.

P1-6: members on different bases mixed snapshot values directly. Settlement now
converts each transaction (amount_original + currency) into the space's
base_currency before splitting; missing rates raise instead of mixing.
P1-8: space monthly summary counted PENDING/SYSTEM rows on a UTC boundary;
it now shares the CLEARED + non-SYSTEM scope with the budget engine and uses
the user's timezone month start.
"""

from datetime import UTC, datetime
from decimal import Decimal
from unittest.mock import AsyncMock, patch
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError
from app.models.financial_settings import FinancialSettings
from app.models.shared_space import SharedSpace, SpaceMember, SpaceTransaction
from app.models.transaction import Transaction
from app.models.user import User
from app.services.exchange_rate_service import exchange_rate_service
from app.services.shared_space_service import SharedSpaceService
from app.services.shared_space_settlement_service import SharedSpaceSettlementService
from app.services.statistics_scope import settled_spending_conditions, user_month_start_utc


async def _seed_user(
    db: AsyncSession,
    *,
    base_currency: str = "CNY",
    timezone: str = "Asia/Shanghai",
    username: str | None = None,
) -> User:
    tag = username or f"u-{uuid4().hex[:8]}"
    user = User(
        uuid=uuid4(),
        username=tag,
        email=f"{tag}@example.com",
        password="hash",
        registration_type="email",
        timezone=timezone,
    )
    db.add(user)
    await db.flush()
    db.add(FinancialSettings(user_uuid=user.uuid, primary_currency=base_currency))
    await db.commit()
    await db.refresh(user)
    return user


async def _seed_space(db: AsyncSession, creator: User, **kwargs) -> SharedSpace:
    service = SharedSpaceService(db)
    space = await service.create_space(creator.uuid, kwargs.get("name", "family"))
    await db.commit()
    await db.refresh(space)
    return space


async def _add_member(db: AsyncSession, space: SharedSpace, user: User) -> None:
    db.add(SpaceMember(space_id=space.id, user_uuid=user.uuid, role="MEMBER", status="ACCEPTED"))
    await db.commit()


def _tx(
    owner: User,
    *,
    amount_original: str,
    currency: str,
    amount_base: str | None = None,
    status: str = "CLEARED",
    source: str = "MANUAL",
) -> Transaction:
    return Transaction(
        uuid=uuid4(),
        user_uuid=owner.uuid,
        type="EXPENSE",
        amount=Decimal(amount_base if amount_base is not None else amount_original),
        amount_original=Decimal(amount_original),
        currency=currency,
        transaction_at=datetime.now(UTC),
        status=status,
        source=source,
    )


async def _link(db: AsyncSession, space: SharedSpace, by: User, tx: Transaction) -> None:
    db.add(tx)
    await db.flush()
    db.add(SpaceTransaction(space_id=space.id, transaction_id=tx.uuid, added_by_user_uuid=by.uuid))
    await db.commit()


class TestSpaceBaseCurrency:
    @pytest.mark.asyncio
    async def test_create_space_inherits_creator_primary(self, db_session: AsyncSession) -> None:
        creator = await _seed_user(db_session, base_currency="USD")
        space = await _seed_space(db_session, creator)
        assert space.base_currency == "USD"

    @pytest.mark.asyncio
    async def test_create_space_defaults_cny_without_settings(self, db_session: AsyncSession) -> None:
        user = User(
            uuid=uuid4(),
            username=f"noset-{uuid4().hex[:6]}",
            email=f"noset-{uuid4().hex[:6]}@example.com",
            password="hash",
            registration_type="email",
        )
        db_session.add(user)
        await db_session.commit()
        space = await _seed_space(db_session, user)
        assert (space.base_currency or "CNY").upper() == "CNY"


class TestSettlementConversion:
    @pytest.mark.asyncio
    async def test_mixed_currency_balances_in_space_base(self, db_session: AsyncSession) -> None:
        """CNY payer (720 CNY) + USD payer (100 USD @7.2) are equal in CNY base."""
        cny_user = await _seed_user(db_session, base_currency="CNY")
        usd_user = await _seed_user(db_session, base_currency="USD")
        space = await _seed_space(db_session, cny_user)
        assert space.base_currency == "CNY"
        await _add_member(db_session, space, usd_user)

        await _link(db_session, space, cny_user, _tx(cny_user, amount_original="720", currency="CNY"))
        await _link(
            db_session,
            space,
            usd_user,
            _tx(usd_user, amount_original="100", currency="USD", amount_base="100"),
        )

        async def _convert(*, amount, from_currency, to_currency, **_kwargs):
            assert to_currency == "CNY"
            if from_currency == "USD":
                return Decimal(str(amount)) * Decimal("7.2")
            return Decimal(str(amount))

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_convert)):
            settlement = await SharedSpaceSettlementService(db_session).get_settlement(space.id, cny_user.uuid)

        assert settlement["baseCurrency"] == "CNY"
        # 720 + 720 = 1440 in base; each member's fair share is 720 -> settled.
        assert Decimal(settlement["totalAmount"]) == Decimal("1440.00")
        assert settlement["isSettled"] is True
        assert settlement["items"] == []

    @pytest.mark.asyncio
    async def test_settlement_raises_on_missing_rate(self, db_session: AsyncSession) -> None:
        cny_user = await _seed_user(db_session, base_currency="CNY")
        usd_user = await _seed_user(db_session, base_currency="USD")
        space = await _seed_space(db_session, cny_user)
        await _add_member(db_session, space, usd_user)
        await _link(
            db_session,
            space,
            usd_user,
            _tx(usd_user, amount_original="50", currency="USD", amount_base="50"),
        )

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=None)):
            with pytest.raises(BusinessError):
                await SharedSpaceSettlementService(db_session).get_settlement(space.id, cny_user.uuid)

    @pytest.mark.asyncio
    async def test_settlement_ignores_pending_and_system(self, db_session: AsyncSession) -> None:
        """PENDING periodic rows + SYSTEM disposal rows must not move balances."""
        user = await _seed_user(db_session, base_currency="CNY")
        space = await _seed_space(db_session, user)

        await _link(db_session, space, user, _tx(user, amount_original="100", currency="CNY"))
        await _link(db_session, space, user, _tx(user, amount_original="1000", currency="CNY", status="PENDING"))
        await _link(db_session, space, user, _tx(user, amount_original="1000", currency="CNY", source="SYSTEM"))

        settlement = await SharedSpaceSettlementService(db_session).get_settlement(space.id, user.uuid)
        # Single member: payer's share equals what they paid -> always settled,
        # but the total must only count the one CLEARED user row.
        assert Decimal(settlement["totalAmount"]) == Decimal("100.00")
        assert settlement["isSettled"] is True


class TestStatisticsScope:
    def test_month_start_uses_user_timezone(self) -> None:
        # 2026-09-01 00:30 in Shanghai is still 2026-08-31 in UTC. A UTC month
        # boundary would wrongly open September; the user boundary stays August.
        now_utc = datetime(2026, 9, 1, 0, 30, tzinfo=UTC)
        shanghai_start = user_month_start_utc(now_utc, "Asia/Shanghai")
        utc_start = user_month_start_utc(now_utc, "UTC")
        assert (shanghai_start.year, shanghai_start.month) == (2026, 8)
        assert (utc_start.year, utc_start.month) == (2026, 9)

    def test_month_start_falls_back_on_bad_timezone(self) -> None:
        now_utc = datetime(2026, 9, 15, 12, 0, tzinfo=UTC)
        start = user_month_start_utc(now_utc, "Not/AZone")
        assert (start.year, start.month) == (2026, 9)

    def test_scope_conditions_match_budget(self) -> None:
        """The shared scope must contain the CLEARED + non-SYSTEM rule."""
        from sqlalchemy.dialects import postgresql

        conds = settled_spending_conditions()
        assert len(conds) == 2
        compiled = " ".join(
            str(c.compile(dialect=postgresql.dialect(), compile_kwargs={"literal_binds": True})) for c in conds
        )
        assert "CLEARED" in compiled
        assert "SYSTEM" in compiled

    @pytest.mark.asyncio
    async def test_space_stats_exclude_pending_and_system(self, db_session: AsyncSession) -> None:
        """Service totals share the budget scope (CLEARED + non-SYSTEM)."""
        user = await _seed_user(db_session, base_currency="CNY")
        space = await _seed_space(db_session, user)
        await _link(db_session, space, user, _tx(user, amount_original="100", currency="CNY"))
        await _link(db_session, space, user, _tx(user, amount_original="500", currency="CNY", status="PENDING"))
        await _link(db_session, space, user, _tx(user, amount_original="500", currency="CNY", source="SYSTEM"))

        service = SharedSpaceService(db_session)
        stats = await service._get_space_financial_stats(space.id)
        assert stats["total_expense"] == Decimal("100")
        assert stats["member_contributions"][user.uuid] == Decimal("100")
