from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import select

from app.core.exceptions import BusinessError, TransactionErrorCode
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
    """Regression: update result must serialize amountOriginal as a JSON number.

    TransactionDetailResponse (detail endpoint) once emitted amount_original as
    a str (crud_service str() of the Decimal) while the update result emitted
    float — the same field, two contracts. Lock the update path to float.
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
    # (deliberate GenUI DataModelUpdate contract); the wire TYPE must still be
    # a JSON number, matching the detail/list endpoints.
    assert result["amount_original"] == 200.0
    assert isinstance(result["amount_original"], float), f"got {result['amount_original']!r}"
    assert result["amount"] == 200.0


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
