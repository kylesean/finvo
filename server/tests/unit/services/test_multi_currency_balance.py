"""Multi-currency balance aggregation tests (H5).

Locks the fix for silently summing account balances across currencies:
- statistics get_overview totalBalance must convert each account to the
  user's base currency before summing (previously a raw SUM mixed CNY + USD).
- forecast _get_total_balance must do the same for the starting balance.
- Accounts whose rate is unavailable are skipped (warned) rather than
  polluting the total.
"""

from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError
from app.models.financial_account import FinancialAccount
from app.models.financial_settings import FinancialSettings
from app.models.user import User
from app.services.exchange_rate_service import exchange_rate_service
from app.services.forecast_service import ForecastService
from app.services.statistics_service import StatisticsService


async def _seed_user(db: AsyncSession, base_currency: str = "CNY") -> User:
    user = User(uuid=uuid4(), username="muser", email="muser@example.com", password="hash", registration_type="email")
    db.add(user)
    await db.commit()
    settings = FinancialSettings(user_uuid=user.uuid, primary_currency=base_currency)
    db.add(settings)
    await db.commit()
    return user


async def _seed_account(
    db: AsyncSession,
    user: User,
    *,
    currency: str,
    balance: str,
    nature: str = "ASSET",
) -> FinancialAccount:
    account = FinancialAccount(
        user_uuid=user.uuid,
        name=f"account-{currency}",
        type="CASH",
        nature=nature,
        currency_code=currency,
        current_balance=Decimal(balance),
        status="ACTIVE",
        include_in_net_worth=True,
    )
    db.add(account)
    await db.commit()
    return account


class TestOverviewBalance:
    @pytest.mark.asyncio
    async def test_single_currency_balance_unchanged(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        await _seed_account(db_session, user, currency="CNY", balance="1000.00")
        await _seed_account(db_session, user, currency="CNY", balance="500.00")

        overview = await StatisticsService(db_session).get_overview(user.uuid)

        assert Decimal(overview.totalBalance) == Decimal("1500.00")

    @pytest.mark.asyncio
    async def test_multi_currency_balance_converts_to_base(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, base_currency="CNY")
        await _seed_account(db_session, user, currency="CNY", balance="1000.00")
        await _seed_account(db_session, user, currency="USD", balance="200.00")

        from unittest.mock import AsyncMock, patch

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=7.2)):
            overview = await StatisticsService(db_session).get_overview(user.uuid)

        # 1000 CNY + 200 USD * 7.2 = 2440 CNY — NOT 1200.
        assert Decimal(overview.totalBalance) == Decimal("2440.00")

    @pytest.mark.asyncio
    async def test_unconvertible_account_skipped_not_mixed(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, base_currency="CNY")
        await _seed_account(db_session, user, currency="CNY", balance="1000.00")
        await _seed_account(db_session, user, currency="USD", balance="200.00")

        from unittest.mock import AsyncMock, patch

        async def _raise(*args, **kwargs):
            raise BusinessError("rate unavailable")

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_raise)):
            overview = await StatisticsService(db_session).get_overview(user.uuid)

        # USD account skipped (rate unavailable) — total must not contain a
        # raw 200 USD mixed in as if it were CNY.
        assert Decimal(overview.totalBalance) == Decimal("1000.00")


class TestForecastStartingBalance:
    @pytest.mark.asyncio
    async def test_multi_currency_starting_balance_converts(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, base_currency="CNY")
        await _seed_account(db_session, user, currency="CNY", balance="1000.00")
        await _seed_account(db_session, user, currency="USD", balance="200.00")

        from unittest.mock import AsyncMock, patch

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=7.2)):
            total = await ForecastService(db_session)._get_total_balance(user.uuid)

        assert total == Decimal("2440.00")

    @pytest.mark.asyncio
    async def test_liability_negative_after_conversion(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, base_currency="CNY")
        await _seed_account(db_session, user, currency="CNY", balance="1000.00", nature="ASSET")
        await _seed_account(db_session, user, currency="USD", balance="100.00", nature="LIABILITY")

        from unittest.mock import AsyncMock, patch

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=7.0)):
            total = await ForecastService(db_session)._get_total_balance(user.uuid)

        assert total == Decimal("300.00")  # 1000 - 100*7.0


class TestUserServiceTotalBalance:
    """The accounts-list endpoint must match the statistics/forecast
    convention — convert per account before summing, skip-and-report instead
    of silently mixing currencies."""

    @pytest.mark.asyncio
    async def test_get_financial_accounts_converts_to_base(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, base_currency="CNY")
        await _seed_account(db_session, user, currency="CNY", balance="1000.00")
        await _seed_account(db_session, user, currency="USD", balance="200.00")

        from unittest.mock import AsyncMock, patch

        from app.services.user_service import UserService

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=7.2)):
            result = await UserService(db_session).get_user_financial_accounts(user.uuid)

        # 1000 CNY + 200 USD * 7.2 = 2440 — previously a raw sum returned 1200.
        assert Decimal(result["totalBalance"]) == Decimal("2440.00")
        assert result["unconvertedAccountIds"] == []

    @pytest.mark.asyncio
    async def test_get_financial_accounts_reports_unconvertible(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, base_currency="CNY")
        usd = await _seed_account(db_session, user, currency="USD", balance="200.00")
        await _seed_account(db_session, user, currency="CNY", balance="1000.00")

        from unittest.mock import AsyncMock, patch

        from app.services.user_service import UserService

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=None)):
            result = await UserService(db_session).get_user_financial_accounts(user.uuid)

        # USD account skipped (rate unavailable), NOT mixed in as raw 200 CNY.
        assert Decimal(result["totalBalance"]) == Decimal("1000.00")
        assert result["unconvertedAccountIds"] == [str(usd.id)]
