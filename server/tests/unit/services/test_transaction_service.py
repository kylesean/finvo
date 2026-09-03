from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from app.core.exceptions import BusinessError, CommonErrorCode, TransactionErrorCode
from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction
from app.models.user import User
from app.services.transaction_query_service import TransactionQueryService
from app.services.transaction_service import TransactionService


@pytest.mark.asyncio
async def test_create_transaction_simple(db_session):
    # 1. Setup User
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="test_user", email="test@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    # 2. Setup Service
    service = TransactionService(db_session)

    # 3. Execute
    result = await service.create_transaction(
        user_uuid=user_uuid,
        amount=Decimal("100"),
        category_key="FOOD",
        raw_input="lunch 100",
        transaction_type="expense",
        tags=["food", "lunch"],
    )

    # 4. Verify Response
    assert result["success"] is True
    assert result["amount"] == 100.0
    assert result["category_key"] == "FOOD"
    assert result["type"] == "EXPENSE"
    assert result["tags"] == ["food", "lunch"]

    # 5. Verify DB
    tx_id = UUID(result["transaction_id"])  # Cast to UUID object
    query = select(Transaction).where(Transaction.uuid == tx_id)
    db_result = await db_session.execute(query)
    tx_record = db_result.scalar_one()

    assert tx_record is not None
    assert tx_record.user_uuid == user_uuid
    # User-base-currency model: amount_original preserves original CNY amount,
    # amount is converted to user's base currency (USD fallback since no FinancialSettings)
    assert float(tx_record.amount_original) == 100.0
    assert tx_record.currency == "CNY"
    # amount is the USD equivalent (converted at write time)
    assert float(tx_record.amount) > 0
    assert tx_record.exchange_rate is not None
    assert tx_record.category_key == "FOOD"
    assert tx_record.tags == ["food", "lunch"]


@pytest.mark.asyncio
async def test_get_transaction_feed_pagination(db_session):
    # 1. Setup User
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="test_user_2", email="test2@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    # 2. Create 15 dummy transactions
    for i in range(15):
        tx = Transaction(
            uuid=uuid4(),
            user_uuid=user_uuid,
            type="EXPENSE",
            amount=Decimal(10.0 + i),
            amount_original=Decimal(10.0 + i),
            currency="CNY",
            transaction_at=datetime.now(UTC),
            status="CLEARED",
        )
        db_session.add(tx)
    await db_session.commit()

    # 3. Test Pagination (Page 1, limit 10)
    service = TransactionQueryService(db_session)
    result_p1 = await service.get_feed(user_uuid=str(user_uuid), page=1, per_page=10)

    assert len(result_p1.items) == 10
    assert result_p1.total == 15
    assert result_p1.has_more is True

    # 4. Test Pagination (Page 2, limit 10)
    result_p2 = await service.get_feed(user_uuid=str(user_uuid), page=2, per_page=10)

    assert len(result_p2.items) == 5
    assert result_p2.has_more is False


@pytest.mark.asyncio
async def test_delete_transaction(db_session):
    # 1. Setup User
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="test_user_3", email="test3@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)
    await db_session.commit()

    # 2. Create Transaction
    tx_id = uuid4()
    tx = Transaction(
        uuid=tx_id,
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("50.0"),
        amount_original=Decimal("50.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
    )
    db_session.add(tx)
    await db_session.commit()

    # 3. Delete
    service = TransactionService(db_session)
    success = await service.delete_transaction(tx_id, user_uuid)

    assert success is True

    # 4. Verify Gone
    query = select(Transaction).where(Transaction.uuid == tx_id)
    db_result = await db_session.execute(query)
    assert db_result.scalar_one_or_none() is None


@pytest.mark.asyncio
async def test_update_transaction_amount_original_is_float(db_session):
    """Contract: amount fields serialize as strings (Decimal) everywhere.

    Amounts must never round-trip through float on the wire: 0.1+0.2-class
    drift would leak into the UI. The detail, update and list endpoints all
    emit the same string shape; floats are reserved for chart-only fields
    (ratios/percentages), never money.
    """
    # 1. Setup User + Transaction (CNY base == fallback, no rate network call)
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="test_user_4", email="test4@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)

    tx_id = uuid4()
    tx = Transaction(
        uuid=tx_id,
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("50.0"),
        amount_original=Decimal("50.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
    )
    db_session.add(tx)
    await db_session.commit()

    # 2. Update via service (serializes by alias)
    service = TransactionService(db_session)
    result = await service.update_transaction(
        transaction_id=tx_id,
        user_uuid=user_uuid,
        amount=Decimal("200"),
    )

    # 3. Assert
    # Note: TransactionUpdateResult keeps the snake_case key `amount_original`
    # (deliberate GenUI DataModelUpdate contract); the value must stay a
    # Decimal so the wire serializes losslessly as a string (never a float,
    # which would smuggle 0.1+0.2-class drift into the UI).
    assert result["amount_original"] == Decimal("200.00000000")
    assert isinstance(result["amount_original"], Decimal), f"got {result['amount_original']!r}"
    assert str(result["amount_original"]) == "200.00000000"
    assert str(result["amount"]) == "200.00000000"


@pytest.mark.asyncio
async def test_system_transaction_is_readonly(db_session):
    """Regression: close-disposal entries (source=SYSTEM) must be immutable.

    Editing, deleting or re-associating a system transaction would silently
    undo a lifecycle balance disposal (e.g. resurrect a CLOSED account's
    zeroed balance), so all three mutation paths must reject it with
    TRANSACTION_SYSTEM_READONLY.
    """
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid, username="test_user_sys", email="sys@example.com", password="hash", registration_type="email"
    )
    db_session.add(user)

    tx_id = uuid4()
    tx = Transaction(
        uuid=tx_id,
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("50.0"),
        amount_original=Decimal("50.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source="SYSTEM",
    )
    db_session.add(tx)
    await db_session.commit()

    service = TransactionService(db_session)

    with pytest.raises(BusinessError) as exc:
        await service.update_transaction(
            transaction_id=tx_id,
            user_uuid=user_uuid,
            amount=Decimal("100"),
        )
    assert exc.value.error_code == TransactionErrorCode.TRANSACTION_SYSTEM_READONLY.value

    with pytest.raises(BusinessError) as exc:
        await service.delete_transaction(tx_id, user_uuid)
    assert exc.value.error_code == TransactionErrorCode.TRANSACTION_SYSTEM_READONLY.value

    with pytest.raises(BusinessError) as exc:
        await service.update_transaction_account(tx_id, user_uuid, uuid4())
    assert exc.value.error_code == TransactionErrorCode.TRANSACTION_SYSTEM_READONLY.value

    # The row itself must survive all rejected mutations
    row = (await db_session.execute(select(Transaction).where(Transaction.uuid == tx_id))).scalar_one()
    assert row.amount_original == Decimal("50.0")


@pytest.mark.asyncio
async def test_account_relink_rejects_closed_account(db_session):
    """Re-association must reject CLOSED accounts even when called directly.

    The client filters ACTIVE accounts in its picker; this guard enforces the
    same rule server-side so a CLOSED account's disposed balance can never be
    resurrected through the API.
    """
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username="test_user_relink",
        email="relink@example.com",
        password="hash",
        registration_type="email",
    )
    db_session.add(user)

    active = FinancialAccount(
        user_uuid=user_uuid,
        name="Active",
        nature="ASSET",
        type="CASH",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("0"),
        status="ACTIVE",
    )
    closed = FinancialAccount(
        user_uuid=user_uuid,
        name="Closed",
        nature="ASSET",
        type="CASH",
        currency_code="CNY",
        initial_balance=Decimal("100"),
        current_balance=Decimal("0"),
        status="CLOSED",
    )
    db_session.add_all([active, closed])

    tx_id = uuid4()
    tx = Transaction(
        uuid=tx_id,
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("50.0"),
        amount_original=Decimal("50.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source="AI",
    )
    db_session.add(tx)
    await db_session.commit()

    service = TransactionService(db_session)

    # CLOSED account -> rejected
    with pytest.raises(BusinessError) as exc:
        await service.update_transaction_account(tx_id, user_uuid, closed.uuid)
    assert exc.value.error_code == TransactionErrorCode.TRANSACTION_ACCOUNT_LINK_CLOSED.value

    # Unowned/missing account -> rejected as invalid
    with pytest.raises(BusinessError) as exc:
        await service.update_transaction_account(tx_id, user_uuid, uuid4())
    assert exc.value.error_code == TransactionErrorCode.INVALID_ACCOUNT_ID.value

    # ACTIVE account -> accepted, association applied with balance effect
    result = await service.update_transaction_account(tx_id, user_uuid, active.uuid)
    assert result["sourceAccountId"] == str(active.uuid)
    active_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == active.uuid))
    ).scalar_one()
    assert active_row.current_balance == Decimal("-50.0"), "EXPENSE debits the source account"


# ---------------------------------------------------------------------------
# Regression: INCOME account re-association direction (BF-P0-1)
#
# _rollback_old_account_balance / _apply_new_account_balance book on the
# source side for EXPENSE/TRANSFER but on the TARGET side for INCOME
# (direction=+1). Omitting direction defaulted to -1 and inverted both legs:
# the old account was credited again and the new one debited (2x misbooking).
# ---------------------------------------------------------------------------


async def _seed_income_relink_fixture(db_session):
    """User + two ACTIVE CNY accounts + a CLEARED income tx linked to account A."""
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username="test_user_income_relink",
        email="income_relink@example.com",
        password="hash",
        registration_type="email",
    )
    db_session.add(user)

    account_a = FinancialAccount(
        user_uuid=user_uuid,
        name="Old Target",
        nature="ASSET",
        type="BANK",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("500"),
        status="ACTIVE",
    )
    account_b = FinancialAccount(
        user_uuid=user_uuid,
        name="New Target",
        nature="ASSET",
        type="BANK",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("300"),
        status="ACTIVE",
    )
    db_session.add_all([account_a, account_b])
    # Flush first: ids are assigned at insert time, and the transaction below
    # must capture the real account uuid (not None) as its target link.
    await db_session.flush()

    tx_id = uuid4()
    tx = Transaction(
        uuid=tx_id,
        user_uuid=user_uuid,
        type="INCOME",
        amount=Decimal("100.0"),
        amount_original=Decimal("100.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source="AI",
        target_account_id=account_a.uuid,
    )
    db_session.add(tx)
    await db_session.commit()
    return user_uuid, tx_id, account_a, account_b


@pytest.mark.asyncio
async def test_income_relink_debits_old_and_credits_new(db_session):
    """INCOME relink A→B: A loses the 100 it was credited, B gains exactly 100."""
    user_uuid, tx_id, account_a, account_b = await _seed_income_relink_fixture(db_session)

    service = TransactionService(db_session)
    result = await service.update_transaction_account(tx_id, user_uuid, account_b.uuid)

    assert result["targetAccountId"] == str(account_b.uuid)
    a_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == account_a.uuid))
    ).scalar_one()
    b_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == account_b.uuid))
    ).scalar_one()
    assert a_row.current_balance == Decimal("400.0"), "old target must be debited once (-100)"
    assert b_row.current_balance == Decimal("400.0"), "new target must be credited once (+100)"


@pytest.mark.asyncio
async def test_income_relink_unlink_credits_reversed(db_session):
    """INCOME unlink (account_id=None): only the old target is debited."""
    user_uuid, tx_id, account_a, _account_b = await _seed_income_relink_fixture(db_session)

    service = TransactionService(db_session)
    await service.update_transaction_account(tx_id, user_uuid, None)

    a_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == account_a.uuid))
    ).scalar_one()
    assert a_row.current_balance == Decimal("400.0"), "unlink must remove exactly the original +100"


@pytest.mark.asyncio
async def test_expense_relink_still_debits_new_and_credits_old(db_session):
    """EXPENSE relink keeps the historical convention: old credited back, new debited."""
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username="test_user_expense_relink",
        email="expense_relink@example.com",
        password="hash",
        registration_type="email",
    )
    db_session.add(user)
    account_a = FinancialAccount(
        user_uuid=user_uuid,
        name="Old Source",
        nature="ASSET",
        type="CASH",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("200"),
        status="ACTIVE",
    )
    account_b = FinancialAccount(
        user_uuid=user_uuid,
        name="New Source",
        nature="ASSET",
        type="CASH",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("1000"),
        status="ACTIVE",
    )
    db_session.add_all([account_a, account_b])
    await db_session.flush()  # assign ids before referencing account_b.uuid

    tx_id = uuid4()
    tx = Transaction(
        uuid=tx_id,
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("50.0"),
        amount_original=Decimal("50.0"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source="AI",
        source_account_id=account_a.uuid,
    )
    db_session.add(tx)
    await db_session.commit()

    service = TransactionService(db_session)
    await service.update_transaction_account(tx_id, user_uuid, account_b.uuid)

    a_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == account_a.uuid))
    ).scalar_one()
    b_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == account_b.uuid))
    ).scalar_one()
    assert a_row.current_balance == Decimal("250.0"), "old source must be credited back (+50)"
    assert b_row.current_balance == Decimal("950.0"), "new source must be debited (-50)"


# ---------------------------------------------------------------------------
# Regression: batch creation drops target_account_id / transaction_at (BF-P1-3)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_batch_income_books_target_account_and_stated_time(db_session):
    """AI batch path must honor target_account_id and transaction_at.

    "昨天工资 5000 到招行卡" used to lose the receipt account (no balance effect)
    and rewrite the date to now().
    """
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username="test_user_batch_income",
        email="batch_income@example.com",
        password="hash",
        registration_type="email",
    )
    db_session.add(user)
    target = FinancialAccount(
        user_uuid=user_uuid,
        name="Bank",
        nature="ASSET",
        type="BANK",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("1000"),
        status="ACTIVE",
    )
    db_session.add(target)
    await db_session.commit()

    stated_time = datetime.now(UTC).replace(microsecond=0)
    service = TransactionService(db_session)
    result = await service.create_batch_transactions(
        user_uuid=user_uuid,
        data={
            "transactions": [
                {"amount": "5000", "transaction_type": "income", "currency": "CNY", "raw_input": "工资"},
            ],
            "target_account_id": str(target.uuid),
            "transaction_at": stated_time.isoformat(),
        },
    )

    assert result["success"] is True
    assert result["count"] == 1

    tx = (
        await db_session.execute(select(Transaction).where(Transaction.uuid == UUID(result["transactions"][0]["id"])))
    ).scalar_one()
    assert tx.type == "INCOME"
    assert tx.target_account_id == target.uuid, "income must link the receipt account"
    assert tx.transaction_at == stated_time, "stated booking time must be preserved"
    assert tx.status == "CLEARED"

    target_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == target.uuid))
    ).scalar_one()
    assert target_row.current_balance == Decimal("6000"), "INCOME books +5000 on the target account"


@pytest.mark.asyncio
async def test_batch_invalid_transaction_at_rejected(db_session):
    """A malformed transaction_at fails loud instead of silently booking today."""
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username="test_user_batch_badtime",
        email="batch_badtime@example.com",
        password="hash",
        registration_type="email",
    )
    db_session.add(user)
    await db_session.commit()

    service = TransactionService(db_session)
    with pytest.raises(BusinessError) as exc:
        await service.create_batch_transactions(
            user_uuid=user_uuid,
            data={
                "transactions": [{"amount": "10", "transaction_type": "expense"}],
                "transaction_at": "not-a-date",
            },
        )
    assert exc.value.error_code == CommonErrorCode.VALIDATION_ERROR
