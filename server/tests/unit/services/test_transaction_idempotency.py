"""Idempotent money-moving submissions.

A keyed submission (e.g. ``transfer:{surface_id}`` from the wizard, or the
AI tool's per-run derived ``ai:{thread}:{digest}:{i}`` keys, or a client
UUID on ``POST /transactions/batch``) must book EXACTLY once: a retried or
replayed submission with the same key returns the first result instead of
moving money twice. Unkeyed rows never dedupe — PostgreSQL unique semantics
treat NULLs as distinct.
"""

from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction
from app.models.user import User
from app.services.transaction_service import TransactionService


async def _seed(db: AsyncSession) -> tuple[User, FinancialAccount, FinancialAccount]:
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username=f"idem-{user_uuid.hex[:8]}",
        email=f"idem-{user_uuid.hex[:8]}@example.com",
        password="hash",
        registration_type="email",
    )
    src = FinancialAccount(
        user_uuid=user_uuid,
        name="From",
        nature="ASSET",
        type="BANK",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("1000"),
        status="ACTIVE",
    )
    dst = FinancialAccount(
        user_uuid=user_uuid,
        name="To",
        nature="ASSET",
        type="BANK",
        currency_code="CNY",
        initial_balance=Decimal("0"),
        current_balance=Decimal("0"),
        status="ACTIVE",
    )
    db.add_all([user, src, dst])
    await db.flush()
    return user, src, dst


@pytest.mark.asyncio
async def test_same_key_books_once_and_replays(db_session: AsyncSession) -> None:
    user, src, dst = await _seed(db_session)
    service = TransactionService(db_session)
    key = f"transfer:{uuid4()}"

    first = await service.create_transaction(
        user_uuid=user.uuid,
        amount=Decimal("100"),
        transaction_type="transfer",
        category_key="GENERAL_TRANSFER",
        source_account_id=src.uuid,
        target_account_id=dst.uuid,
        idempotency_key=key,
    )
    second = await service.create_transaction(
        user_uuid=user.uuid,
        amount=Decimal("100"),
        transaction_type="transfer",
        category_key="GENERAL_TRANSFER",
        source_account_id=src.uuid,
        target_account_id=dst.uuid,
        idempotency_key=key,
    )

    assert first["success"] is True
    assert second["success"] is True
    assert second["idempotent_replay"] is True
    assert second["transaction_id"] == first["transaction_id"]
    assert first["idempotent_replay"] is False

    rows = (
        await db_session.execute(
            select(func.count()).select_from(Transaction).where(Transaction.idempotency_key == key)
        )
    ).scalar_one()
    assert rows == 1, "the same key must book exactly one transaction"

    src_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == src.uuid))
    ).scalar_one()
    dst_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == dst.uuid))
    ).scalar_one()
    assert src_row.current_balance == Decimal("900"), "balance effect applied exactly once"
    assert dst_row.current_balance == Decimal("100")


@pytest.mark.asyncio
async def test_different_keys_book_independently(db_session: AsyncSession) -> None:
    user, src, dst = await _seed(db_session)
    service = TransactionService(db_session)

    r1 = await service.create_transaction(
        user_uuid=user.uuid,
        amount=Decimal("50"),
        transaction_type="transfer",
        category_key="GENERAL_TRANSFER",
        source_account_id=src.uuid,
        target_account_id=dst.uuid,
        idempotency_key=f"transfer:{uuid4()}",
    )
    r2 = await service.create_transaction(
        user_uuid=user.uuid,
        amount=Decimal("50"),
        transaction_type="transfer",
        category_key="GENERAL_TRANSFER",
        source_account_id=src.uuid,
        target_account_id=dst.uuid,
        idempotency_key=f"transfer:{uuid4()}",
    )

    assert r1["transaction_id"] != r2["transaction_id"]
    src_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == src.uuid))
    ).scalar_one()
    assert src_row.current_balance == Decimal("900")


@pytest.mark.asyncio
async def test_unkeyed_rows_never_dedupe(db_session: AsyncSession) -> None:
    """AI bookkeeping (no key) must stay unaffected by the constraint."""
    user, src, dst = await _seed(db_session)
    service = TransactionService(db_session)

    for _ in range(3):
        result = await service.create_transaction(
            user_uuid=user.uuid,
            amount=Decimal("10"),
            transaction_type="expense",
            category_key="FOOD",
            source_account_id=src.uuid,
        )
        assert result["idempotent_replay"] is False

    rows = (
        await db_session.execute(
            select(func.count())
            .select_from(Transaction)
            .where(Transaction.type == "EXPENSE", Transaction.user_uuid == user.uuid)
        )
    ).scalar_one()
    assert rows == 3


@pytest.mark.asyncio
async def test_failed_attempt_does_not_poison_the_key(db_session: AsyncSession) -> None:
    """A failed first attempt stores nothing, so the retry books normally."""
    user, src, dst = await _seed(db_session)
    service = TransactionService(db_session)
    key = f"transfer:{uuid4()}"

    # Attempt 1: nonexistent target account -> NotFound, nothing stored.
    from app.core.exceptions import NotFoundError

    with pytest.raises(NotFoundError):
        await service.create_transaction(
            user_uuid=user.uuid,
            amount=Decimal("100"),
            transaction_type="transfer",
            category_key="GENERAL_TRANSFER",
            source_account_id=src.uuid,
            target_account_id=uuid4(),
            idempotency_key=key,
        )

    # Attempt 2 (after the user fixed the target): books normally.
    result = await service.create_transaction(
        user_uuid=user.uuid,
        amount=Decimal("100"),
        transaction_type="transfer",
        category_key="GENERAL_TRANSFER",
        source_account_id=src.uuid,
        target_account_id=dst.uuid,
        idempotency_key=key,
    )
    assert result["success"] is True and result["idempotent_replay"] is False


def _batch_data(src: FinancialAccount, key: str | None, amount: str = "25.50") -> dict:
    item: dict = {
        "amount": amount,
        "currency": "CNY",
        "transaction_type": "expense",
        "category_key": "FOOD",
        "tags": ["lunch"],
    }
    if key is not None:
        item["idempotency_key"] = key
    return {"transactions": [item], "source_account_id": str(src.uuid)}


@pytest.mark.asyncio
async def test_batch_keyed_item_books_once_and_replays(db_session: AsyncSession) -> None:
    """POST /transactions/batch with a per-item key: the client's resubmit
    (double-tap, network retry) replays instead of double-charging."""
    user, src, _ = await _seed(db_session)
    service = TransactionService(db_session)
    key = f"client:{uuid4()}"

    first = await service.create_batch_transactions(user.uuid, _batch_data(src, key))
    assert first["success"] is True and first["count"] == 1 and first["replayed_count"] == 0

    second = await service.create_batch_transactions(user.uuid, _batch_data(src, key))
    assert second["success"] is True
    assert second["count"] == 0, "the replayed submission must not create a row"
    assert second["replayed_count"] == 1

    rows = (
        await db_session.execute(
            select(func.count()).select_from(Transaction).where(Transaction.idempotency_key == key)
        )
    ).scalar_one()
    assert rows == 1

    src_row = (
        await db_session.execute(select(FinancialAccount).where(FinancialAccount.uuid == src.uuid))
    ).scalar_one()
    assert src_row.current_balance == Decimal("974.50"), "balance effect applied exactly once"


@pytest.mark.asyncio
async def test_batch_mixed_keyed_and_unkeyed_items(db_session: AsyncSession) -> None:
    """Only keyed items dedupe; unkeyed items book on every submission."""
    user, src, _ = await _seed(db_session)
    service = TransactionService(db_session)
    key = f"client:{uuid4()}"
    data = _batch_data(src, key)
    data["transactions"].append({"amount": "10", "currency": "CNY", "transaction_type": "expense", "tags": ["coffee"]})

    await service.create_batch_transactions(user.uuid, data)
    second = await service.create_batch_transactions(user.uuid, data)

    assert second["count"] == 1, "only the unkeyed item books again"
    assert second["replayed_count"] == 1, "the keyed item replays"

    rows = (
        await db_session.execute(
            select(func.count())
            .select_from(Transaction)
            .where(Transaction.user_uuid == user.uuid, Transaction.type == "EXPENSE")
        )
    ).scalar_one()
    assert rows == 3, "1 keyed + 2 unkeyed submissions"
