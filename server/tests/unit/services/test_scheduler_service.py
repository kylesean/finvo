from contextlib import asynccontextmanager
from datetime import date, datetime
from decimal import Decimal
from unittest.mock import patch
from uuid import uuid4

import pytest
from sqlalchemy import select

from app.models.transaction import RecurringTransaction, Transaction
from app.models.user import User
from app.services.recurring_transaction_jobs import process_due_transactions


@pytest.mark.asyncio
async def test_process_due_transactions(db_session):
    # 1. Setup User
    user = User(uuid=uuid4(), username="sched_user", email="sched@e.com", password="pwd", registration_type="email")
    db_session.add(user)

    # 2. Setup Due Recurring Transaction
    # Due today (start from yesterday to ensure stable next_execution calculation)
    from datetime import timedelta

    start = date.today() - timedelta(days=1)
    rt = RecurringTransaction(
        id=uuid4(),
        user_uuid=user.uuid,
        type="EXPENSE",
        amount=Decimal("100.0"),
        currency="CNY",
        category_key="FOOD",
        recurrence_rule="FREQ=DAILY;INTERVAL=1",
        start_date=start,
        next_execution_at=datetime.combine(date.today(), datetime.min.time()),
        is_active=True,
        amount_type="FIXED",
        requires_confirmation=False,
        timezone="UTC",
    )
    db_session.add(rt)
    await db_session.commit()

    # 3. Patch get_session_context
    @asynccontextmanager
    async def mock_ctx():
        # Prevent actual commit from closing the session/transaction
        # We mock commit to do flush instead
        with patch.object(db_session, "commit", side_effect=db_session.flush):
            yield db_session

    with patch("app.services.recurring_transaction_jobs.get_session_context", side_effect=mock_ctx):
        # 4. Action - Call the function directly
        await process_due_transactions()

        # 5. Assert
        # Check transaction created
        query = select(Transaction).where(Transaction.source == "RECURRING")
        result = await db_session.execute(query)
        txs = result.scalars().all()
        assert len(txs) == 1
        # User-base-currency model: amount is converted to user's base currency.
        # Since no FinancialSettings exists, fallback is USD. CNY -> USD conversion applies.
        # amount_original preserves the original 100.0 CNY.
        assert txs[0].amount_original == Decimal("100.0")
        assert txs[0].currency == "CNY"
        # amount is the USD equivalent (converted at write time with rate snapshot)
        assert txs[0].amount > 0
        # exchange_rate snapshot should be stored
        assert txs[0].exchange_rate is not None

        # Check rt updated
        await db_session.refresh(rt)
        assert rt.last_generated_at is not None
        # next_execution_at should be tomorrow
        assert rt.next_execution_at.date() > start
