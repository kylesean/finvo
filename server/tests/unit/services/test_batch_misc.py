"""Batch normalization, currency-grouped summary, string money in the
transfer wizard, and the actually-emitted title_update.

- Batch path upper-cases category_key like the single path (was: raw LLM
  casing persisted, drifting analytics).
- record_transactions summary groups by currency, never summing across
  currencies into one number.
- prepare_transfer emits string balances/amounts (was: float(); strings keep
  cents on large values).
- New chat sessions emit title_update (was: generated+saved but never sent,
  while the client already handles the event).
"""

from decimal import Decimal
from unittest.mock import AsyncMock, patch
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.financial_account import FinancialAccount
from app.models.financial_settings import FinancialSettings
from app.models.user import User
from app.services.exchange_rate_service import exchange_rate_service


async def _seed_user(db: AsyncSession, base: str = "CNY") -> User:
    tag = f"e-{uuid4().hex[:8]}"
    user = User(uuid=uuid4(), username=tag, email=f"{tag}@example.com", password="hash", registration_type="email")
    db.add(user)
    await db.flush()
    db.add(FinancialSettings(user_uuid=user.uuid, primary_currency=base))
    await db.commit()
    await db.refresh(user)
    return user


class TestBatchNormalization:
    @pytest.mark.asyncio
    async def test_batch_category_key_uppercased_like_single_path(self, db_session: AsyncSession) -> None:
        from sqlalchemy import select

        from app.models.transaction import Transaction
        from app.services.transaction.crud_service import TransactionCRUDService

        user = await _seed_user(db_session)
        result = await TransactionCRUDService(db_session).create_batch_transactions(
            user.uuid,
            {"transactions": [{"amount": "10", "transaction_type": "EXPENSE", "category_key": "food"}]},
        )
        assert result["success"] is True
        row = (await db_session.execute(select(Transaction).where(Transaction.user_uuid == user.uuid))).scalar_one()
        assert row.category_key == "FOOD"


class TestCurrencyGroupedSummary:
    @pytest.mark.asyncio
    async def test_summary_groups_by_currency(self, db_session: AsyncSession) -> None:
        from app.core.langgraph.tools.transaction_tools import record_transactions

        user = await _seed_user(db_session, "CNY")

        async def _rate_72(*, amount, from_currency, to_currency, **_kw):
            if from_currency == to_currency:
                return Decimal(str(amount))
            assert (from_currency, to_currency) == ("USD", "CNY")
            return Decimal(str(amount)) * Decimal("7.2")

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_rate_72)):
            result = await record_transactions.ainvoke(
                {
                    "transactions": [
                        {
                            "amount": "100",
                            "type": "expense",
                            "currency": "CNY",
                            "category_key": "FOOD_DINING",
                            "tags": ["lunch"],
                        },
                        {
                            "amount": "10",
                            "type": "expense",
                            "currency": "USD",
                            "category_key": "FOOD_DINING",
                            "tags": ["lunch"],
                        },
                        {
                            "amount": "50",
                            "type": "income",
                            "currency": "CNY",
                            "category_key": "SALARY_WAGE",
                            "tags": ["pay"],
                        },
                    ],
                },
                config={"configurable": {"user_uuid": str(user.uuid)}},
            )
        assert result["success"] is True
        summary = result["summary"]
        assert summary["mixed_currencies"] is True
        assert summary["by_currency"]["CNY"] == {"expense": "100.00", "income": "50.00"}
        assert summary["by_currency"]["USD"] == {"expense": "10.00", "income": "0.00"}
        assert summary["expense_count"] == 2 and summary["income_count"] == 1
        assert "expense_total" not in summary and "net" not in summary


class TestTransferWizardStringMoney:
    @pytest.mark.asyncio
    async def test_balances_and_amount_are_strings(self, db_session: AsyncSession) -> None:
        from app.services.transfer_prep_service import build_transfer_wizard_data

        user = await _seed_user(db_session, "CNY")
        for name, currency, balance in (("cash", "CNY", "123456789.12"), ("usd", "USD", "100.50")):
            db_session.add(
                FinancialAccount(
                    user_uuid=user.uuid,
                    name=f"{name}-{uuid4().hex[:6]}",
                    type="CASH",
                    nature="ASSET",
                    currency_code=currency,
                    initial_balance=Decimal(balance),
                    current_balance=Decimal(balance),
                    status="ACTIVE",
                    include_in_net_worth=True,
                )
            )
        await db_session.commit()

        data = await build_transfer_wizard_data(user.uuid, amount=100.5)
        assert data["success"] is True
        assert isinstance(data["amount"], str)
        for acc in data["sourceAccounts"]:
            assert isinstance(acc["balance"], str), acc
        balances = {acc["currency"]: acc["balance"] for acc in data["sourceAccounts"]}
        # Cents survive the round trip (float would smear 123456789.12).
        assert Decimal(balances["CNY"]) == Decimal("123456789.12")


class TestTitleUpdateEmitted:
    @pytest.mark.asyncio
    async def test_new_session_stream_contains_title_update(
        self, client, db_session: AsyncSession, test_user: User
    ) -> None:
        """A fresh chat turn must emit session_init + title_update."""
        import json

        from app.core.database import get_session, get_session_context
        from app.core.dependencies import get_current_user
        from app.main import app

        class _FakeAgent:
            async def get_genui_stream(self, *args, **kwargs):
                if False:
                    yield None

        async def override_get_session():
            async with get_session_context() as session:
                yield session

        async def override_get_current_user():
            return test_user

        import app.api.v1.chatbot as chatbot_module

        app.dependency_overrides[get_session] = override_get_session
        app.dependency_overrides[get_current_user] = override_get_current_user
        real_agent = chatbot_module.get_agent
        chatbot_module.get_agent = lambda: _FakeAgent()
        try:
            response = client.post(
                "/api/v1/chatbot/chat/stream",
                json={"messages": [{"role": "user", "content": "记一笔午餐100元"}]},
            )
        finally:
            chatbot_module.get_agent = real_agent
            app.dependency_overrides.clear()

        assert response.status_code == 200, response.text[:500]
        frames = [
            json.loads(line[len("data: ") :]) for line in response.text.splitlines() if line.startswith("data: ")
        ]
        types = [f.get("type") for f in frames]
        assert "session_init" in types
        assert "title_update" in types, types
        title_frame = next(f for f in frames if f.get("type") == "title_update")
        assert title_frame.get("title"), title_frame
