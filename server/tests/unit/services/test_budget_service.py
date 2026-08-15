from datetime import UTC, date, datetime
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.base import Base
from app.models.budget import Budget, BudgetPeriodStatus
from app.models.transaction import Transaction
from app.models.user import User
from app.schemas.budget import BudgetCreateRequest
from app.services.budget_service import BudgetService


@pytest.mark.asyncio
async def test_create_budget(db_session):
    # 1. Setup User
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="budget_user", email="budget@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    # 2. Setup Service
    service = BudgetService(db_session)

    # 3. Create Budget
    request = BudgetCreateRequest(
        name="Food Budget",
        amount=1000.0,
        scope="CATEGORY",
        category_key="FOOD",
        period_type="MONTHLY",
        currency_code="CNY",
    )

    budget = await service.create_budget(user_uuid, request)

    # 4. Verify Budget Created
    assert budget is not None
    assert budget.name == "Food Budget"
    assert budget.amount == Decimal("1000.0")
    assert budget.owner_uuid == user_uuid

    # 5. Verify Initial Period Created
    # We need to refresh/load periods because create_budget commits internally
    await db_session.refresh(budget, ["periods"])
    assert len(budget.periods) == 1

    period = budget.periods[0]
    assert period.adjusted_target == Decimal("1000.0")
    assert period.status == BudgetPeriodStatus.ON_TRACK.value

    # Check if period covers today
    today = date.today()
    assert period.period_start <= today <= period.period_end


@pytest.mark.asyncio
async def test_calculate_spent_amount(db_session):
    # 1. Setup User
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="spender", email="spender@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    # 2. Create Transactions (2 expenses in FOOD, 1 in TRANSPORT)
    today = datetime.now(UTC)

    t1 = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("50.0"),
        amount_original=Decimal("50.0"),
        currency="CNY",
        transaction_at=today,
        category_key="FOOD",
        status="CLEARED",
        raw_input="lunch",
    )
    t2 = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("30.0"),
        amount_original=Decimal("30.0"),
        currency="CNY",
        transaction_at=today,
        category_key="FOOD",
        status="CLEARED",
        raw_input="snack",
    )
    t3 = Transaction(  # Different category
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("20.0"),
        amount_original=Decimal("20.0"),
        currency="CNY",
        transaction_at=today,
        category_key="TRANSPORT",
        status="CLEARED",
        raw_input="bus",
    )
    # Income shouldn't count
    t4 = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="INCOME",
        amount=Decimal("1000.0"),
        amount_original=Decimal("1000.0"),
        currency="CNY",
        transaction_at=today,
        category_key="SALARY",
        status="CLEARED",
        raw_input="salary",
    )

    db_session.add_all([t1, t2, t3, t4])
    await db_session.commit()

    # 3. Test Calculation
    service = BudgetService(db_session)

    # Calculate for FOOD
    start_date = today.date()
    end_date = today.date()

    spent_food = await service.calculate_spent_amount(user_uuid, start_date, end_date, category_key="FOOD")
    assert spent_food == Decimal("80.0")  # 50 + 30

    # Calculate Total (all categories)
    spent_total = await service.calculate_spent_amount(user_uuid, start_date, end_date, category_key=None)
    assert spent_total == Decimal("100.0")  # 50 + 30 + 20


@pytest.mark.asyncio
async def test_calculate_spent_amount_excludes_system_transactions(db_session):
    """Regression: close-disposal entries (source=SYSTEM) must not count as spending.

    A writeoff booked at account close is balance bookkeeping (the money is
    gone from the account, not spent by the user); including it in the budget's
    spent amount would turn the remaining amount negative.
    """
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="system_tx", email="system@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    today = datetime.now(UTC)
    normal = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("50.0"),
        amount_original=Decimal("50.0"),
        currency="CNY",
        transaction_at=today,
        category_key="FOOD",
        status="CLEARED",
    )
    system = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("586000.0"),
        amount_original=Decimal("586000.0"),
        currency="CNY",
        transaction_at=today,
        category_key="OTHERS",
        status="CLEARED",
        source="SYSTEM",
    )
    db_session.add_all([normal, system])
    await db_session.commit()

    service = BudgetService(db_session)
    start_date = today.date()
    end_date = today.date()

    spent = await service.calculate_spent_amount(user_uuid, start_date, end_date, category_key=None)
    assert spent == Decimal("50.0"), "SYSTEM disposal entries must not count as budget spending"


@pytest.mark.asyncio
async def test_budget_suggestion_excludes_system_transactions(db_session):
    """Regression: budget suggestions must not be skewed by lifecycle writeoffs."""
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username="suggestion_tx",
        email="suggest@example.com",
        password="hash",
        registration_type="email",
    )
    db_session.add(user)
    await db_session.commit()

    today = datetime.now(UTC)
    system = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("586000.0"),
        amount_original=Decimal("586000.0"),
        currency="CNY",
        transaction_at=today,
        category_key="OTHERS",
        status="CLEARED",
        source="SYSTEM",
    )
    db_session.add(system)
    await db_session.commit()

    service = BudgetService(db_session)
    suggestion = await service.suggest_budget(user_uuid, months=1, category_key=None)
    assert Decimal(suggestion.suggested_amount) == Decimal("0"), (
        "a lone SYSTEM writeoff must not fabricate a budget suggestion"
    )


@pytest.mark.asyncio
async def test_update_period_status(db_session):
    # 1. Setup User and Budget
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="status_user", email="status@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    service = BudgetService(db_session)
    request = BudgetCreateRequest(name="Small Budget", amount=100.0, scope="CATEGORY", category_key="TEST")
    budget = await service.create_budget(user_uuid, request)
    await db_session.refresh(budget, ["periods"])
    period = budget.periods[0]

    # 2. Add transaction that exceeds budget
    tx = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("150.0"),
        amount_original=Decimal("150.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        category_key="TEST",
        status="CLEARED",
        raw_input="big expense",
    )
    db_session.add(tx)
    await db_session.commit()

    # 3. Update Period
    updated_period = await service.update_period_spent_amount(budget, period)

    # 4. Verify Status
    assert updated_period.spent_amount == Decimal("150.0")
    assert updated_period.status == BudgetPeriodStatus.EXCEEDED.value


@pytest.mark.asyncio
async def test_rebalance_with_status(db_session):
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="rebalance_user", email="reb@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    service = BudgetService(db_session)
    b1 = await service.create_budget(
        user_uuid,
        BudgetCreateRequest(name="Category A", amount=1000.0, scope="CATEGORY", category_key="FOOD"),
    )
    b2 = await service.create_budget(
        user_uuid,
        BudgetCreateRequest(name="Category B", amount=500.0, scope="CATEGORY", category_key="TRANSPORT"),
    )

    # Test insufficient funds
    status_insufficient = await service.rebalance_with_status(b1.id, b2.id, Decimal("1500.0"), user_uuid)
    assert status_insufficient == "INSUFFICIENT_FUNDS"

    # Test valid transfer
    status_success = await service.rebalance_with_status(b1.id, b2.id, Decimal("300.0"), user_uuid)
    assert status_success == "SUCCESS"

    await db_session.refresh(b1)
    await db_session.refresh(b2)
    assert b1.amount == Decimal("700.0")
    assert b2.amount == Decimal("800.0")


@pytest.mark.asyncio
async def test_budget_summary_deduplication(db_session):
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="summary_user", email="sum@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    service = BudgetService(db_session)
    # Create total budget (5000) and category budget (1000)
    await service.create_budget(
        user_uuid,
        BudgetCreateRequest(name="Total", amount=5000.0, scope="TOTAL"),
    )
    await service.create_budget(
        user_uuid,
        BudgetCreateRequest(name="Food", amount=1000.0, scope="CATEGORY", category_key="FOOD"),
    )

    summary = await service.get_budget_summary(user_uuid)
    assert summary.total_budget is not None
    # Compare as Decimal: SQLite renders NUMERIC with trailing zeros
    # (e.g. "5000.00000000") while PostgreSQL renders "5000". Decimal comparison
    # normalizes the cross-backend precision difference.
    assert Decimal(summary.overall_spent) == Decimal("0")
    assert Decimal(summary.overall_remaining) == Decimal("5000")


@pytest.mark.asyncio
async def test_rebalance_concurrent_no_overdraw(async_db_engine):
    """Concurrent rebalances must never drive a budget below zero.

    The debit is a single conditional UPDATE (``amount >= transfer`` is the
    balance check itself), so the number of SUCCESS results can never exceed
    ``floor(balance / amount)`` — even when readers race ahead of writers.
    Each task gets its own session/connection against the shared Postgres test
    database, so the tasks genuinely contend via row locks.
    """
    import asyncio

    from sqlalchemy.ext.asyncio import async_sessionmaker

    from app.models.user import User

    session_factory = async_sessionmaker(bind=async_db_engine, class_=AsyncSession, expire_on_commit=False)

    user_uuid = uuid4()
    async with session_factory() as session:
        session.add(
            User(
                uuid=user_uuid,
                username="conc_user",
                email="conc@example.com",
                password="hash",
                registration_type="email",
            )
        )
        await session.commit()

        service = BudgetService(session)
        source = await service.create_budget(
            user_uuid,
            BudgetCreateRequest(name="Source", amount=1000.0, scope="CATEGORY", category_key="FOOD"),
        )
        sink = await service.create_budget(
            user_uuid,
            BudgetCreateRequest(name="Sink", amount=1.0, scope="CATEGORY", category_key="TRANSPORT"),
        )

    async def attempt(_i: int) -> str:
        async with session_factory() as session:
            return await BudgetService(session).rebalance_with_status(source.id, sink.id, Decimal("100.0"), user_uuid)

    statuses = await asyncio.gather(*(attempt(i) for i in range(12)))

    assert statuses.count("SUCCESS") == 10, statuses
    assert statuses.count("INSUFFICIENT_FUNDS") == 2, statuses

    async with session_factory() as session:
        final_source = await session.get(Budget, source.id)
        final_sink = await session.get(Budget, sink.id)
        assert final_source.amount == Decimal("0.0")
        assert final_sink.amount == Decimal("1001.0")
