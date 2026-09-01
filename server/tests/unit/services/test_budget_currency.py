"""Budget currency normalization tests (A3).

Locks the fix: budget limits are stored in the user's BASE currency — a
budget requested in another currency is converted via the live rate as a
one-time snapshot, so `calculate_spent_amount` (which sums
Transaction.amount, always base currency) compares like-for-like.

Regression scenario: schema default currency is "CNY", so a USD-base user
who creates a budget without an explicit currency previously got a CNY
budget whose target was compared against USD spending — broken warnings.
"""

from decimal import Decimal
from unittest.mock import AsyncMock, patch
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError
from app.models.user import User
from app.schemas.budget import BudgetCreateRequest
from app.services.budget_service import BudgetService
from app.services.exchange_rate_service import exchange_rate_service


async def _seed_user(db: AsyncSession, username: str = "budget_user") -> User:
    user = User(
        uuid=uuid4(),
        username=username,
        email=f"{username}@example.com",
        password="hash",
        registration_type="email",
    )
    db.add(user)
    await db.commit()
    return user


async def _seed_settings(db: AsyncSession, user: User, primary_currency: str) -> None:
    from app.models.financial_settings import FinancialSettings

    db.add(FinancialSettings(user_uuid=user.uuid, primary_currency=primary_currency))
    await db.commit()


class TestBudgetCurrencyNormalization:
    @pytest.mark.asyncio
    async def test_base_currency_budget_unchanged(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        await _seed_settings(db_session, user, "CNY")

        budget = await BudgetService(db_session).create_budget(
            user.uuid,
            BudgetCreateRequest(name="Food", amount=Decimal("1000.0"), scope="CATEGORY", category_key="FOOD"),
        )

        assert budget.currency_code == "CNY"
        assert budget.amount == Decimal("1000.0")

    @pytest.mark.asyncio
    async def test_foreign_currency_budget_converted_to_base(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        await _seed_settings(db_session, user, "CNY")

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=7.2)):
            budget = await BudgetService(db_session).create_budget(
                user.uuid,
                BudgetCreateRequest(name="USD Trip", amount=Decimal("1000.0"), scope="TOTAL", currency_code="USD"),
            )

        # 1000 USD -> 7200 CNY; spent (sum of Transaction.amount, CNY) now
        # compares against the same currency.
        assert budget.currency_code == "CNY"
        assert budget.amount == Decimal("7200.0")

    @pytest.mark.asyncio
    async def test_foreign_currency_budget_raises_when_rate_unavailable(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        await _seed_settings(db_session, user, "CNY")

        async def _raise(*args, **kwargs):
            raise BusinessError("rate unavailable")

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_raise)):
            with pytest.raises(BusinessError, match="exchange rate unavailable"):
                await BudgetService(db_session).create_budget(
                    user.uuid,
                    BudgetCreateRequest(name="USD Trip", amount=Decimal("1000.0"), scope="TOTAL", currency_code="USD"),
                )

    @pytest.mark.asyncio
    async def test_update_budget_renormalizes_currency(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        await _seed_settings(db_session, user, "CNY")
        service = BudgetService(db_session)
        budget = await service.create_budget(
            user.uuid,
            BudgetCreateRequest(name="Food", amount=Decimal("1000.0"), scope="CATEGORY", category_key="FOOD"),
        )

        from app.schemas.budget import BudgetUpdateRequest

        with patch.object(exchange_rate_service, "convert", AsyncMock(return_value=7.0)):
            updated = await service.update_budget(
                budget.id,
                user.uuid,
                BudgetUpdateRequest(amount=Decimal("500.0")),
            )

        assert updated is not None
        # The budget's stored currency was CNY, so the limit stays CNY 500.
        assert updated.amount == Decimal("500.0")
        assert updated.currency_code == "CNY"
