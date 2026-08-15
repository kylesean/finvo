"""Regression tests for the financial-account lifecycle redesign.

Covers the UPSERT save semantics (identity + balance preservation), the
guarded delete, the merge (correction) path, and the close (archive) path
with balance disposal. See the design discussion: accounts are balance
carriers + transaction dimensions, so history is never silently destroyed —
removal is either a no-history physical delete, a merge (wrong/duplicate), or
a close (real-life account termination).
"""

from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from sqlalchemy import func, select

from app.core.exceptions import BusinessError, NotFoundError, ValidationError
from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction
from app.models.user import User
from app.services.user_service import UserService


async def _mk_user(db) -> UUID:
    user = User(
        uuid=uuid4(),
        username=f"u_{uuid4().hex[:8]}",
        email=f"{uuid4().hex}@example.com",
        password="hash",
        registration_type="email",
    )
    db.add(user)
    await db.commit()
    return user.uuid


async def _mk_account(db, user_uuid: str, *, name="Acc", nature="ASSET", currency="CNY",
                      initial: str = "0", current: str = "0", status="ACTIVE") -> dict:
    service = UserService(db)
    data = {
        "name": name,
        "nature": nature,
        "type": "CASH",
        "initialBalance": initial,
        "currentBalance": current,
        "currencyCode": currency,
        "includeInNetWorth": True,
        "status": status,
    }
    result = await service.create_financial_account(user_uuid, data)
    pid = UUID(result["id"])
    return {"id": result["id"], "uuid": pid, **result}


@pytest.mark.asyncio
async def test_save_upserts_existing_account_preserving_identity_and_balances(db_session):
    user_uuid = await _mk_user(db_session)
    created = await _mk_account(db_session, user_uuid, name="A", initial="100", current="150")

    # Re-save the same account (e.g. the client round-trips the full list after
    # editing the name). Identity must be preserved, balances must NOT be
    # reset, and unrelated accounts must survive.
    await _mk_account(db_session, user_uuid, name="B", initial="50", current="50")

    service = UserService(db_session)
    await service.save_financial_accounts(
        user_uuid,
        [{"id": created["id"], "name": "A renamed", "nature": "ASSET", "type": "CASH",
          "initialBalance": "100", "currentBalance": "150", "currencyCode": "CNY",
          "includeInNetWorth": True, "status": "ACTIVE"}],
    )

    rows = (await db_session.execute(select(FinancialAccount))).scalars().all()
    by_name = {r.name: r for r in rows}
    assert "A renamed" in by_name and "B" in by_name, "absent accounts must not be deleted"
    a = by_name["A renamed"]
    assert str(a.id) == created["id"], "account identity must be preserved on upsert"
    assert a.initial_balance == Decimal("100")
    assert a.current_balance == Decimal("150"), "transaction-driven balance must be preserved"


@pytest.mark.asyncio
async def test_save_creates_new_account_when_no_id(db_session):
    user_uuid = await _mk_user(db_session)
    service = UserService(db_session)
    await service.save_financial_accounts(
        user_uuid,
        [{"name": "Cash", "nature": "ASSET", "type": "CASH",
          "initialBalance": "0", "currentBalance": "0", "currencyCode": "CNY",
          "includeInNetWorth": True, "status": "ACTIVE"}],
    )
    rows = (await db_session.execute(select(FinancialAccount))).scalars().all()
    assert len(rows) == 1
    assert rows[0].name == "Cash"


@pytest.mark.asyncio
async def test_update_initial_balance_shifts_current_balance(db_session):
    user_uuid = await _mk_user(db_session)
    created = await _mk_account(db_session, user_uuid, name="A", initial="100", current="150")

    service = UserService(db_session)
    await service.update_financial_account(
        user_uuid, created["uuid"], {"initialBalance": "200"}
    )
    row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == created["uuid"])
    )).scalar_one()
    assert row.initial_balance == Decimal("200")
    assert row.current_balance == Decimal("250"), "delta of +100 must carry into current"


@pytest.mark.asyncio
async def test_update_current_balance_is_authoritative(db_session):
    user_uuid = await _mk_user(db_session)
    created = await _mk_account(db_session, user_uuid, name="A", initial="100", current="150")

    service = UserService(db_session)
    await service.update_financial_account(user_uuid, created["uuid"], {"currentBalance": "999"})
    row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == created["uuid"])
    )).scalar_one()
    assert row.current_balance == Decimal("999")
    assert row.initial_balance == Decimal("100")


@pytest.mark.asyncio
async def test_update_rejects_closed_status(db_session):
    user_uuid = await _mk_user(db_session)
    created = await _mk_account(db_session, user_uuid, name="A")

    service = UserService(db_session)
    with pytest.raises(ValidationError):
        await service.update_financial_account(user_uuid, created["uuid"], {"status": "CLOSED"})


@pytest.mark.asyncio
async def test_delete_empty_account_succeeds(db_session):
    user_uuid = await _mk_user(db_session)
    created = await _mk_account(db_session, user_uuid, name="A", initial="0", current="0")

    service = UserService(db_session)
    assert await service.delete_financial_account(user_uuid, created["uuid"]) is True
    rows = (await db_session.execute(select(FinancialAccount))).scalars().all()
    assert rows == []


@pytest.mark.asyncio
async def test_delete_referenced_account_conflicts(db_session):
    user_uuid = await _mk_user(db_session)
    created = await _mk_account(db_session, user_uuid, name="A", initial="0", current="0")

    tx = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("10"),
        amount_original=Decimal("10"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source_account_id=created["uuid"],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )
    db_session.add(tx)
    await db_session.commit()

    service = UserService(db_session)
    with pytest.raises(BusinessError) as excinfo:
        await service.delete_financial_account(user_uuid, created["uuid"])
    assert excinfo.value.status_code == 409
    assert excinfo.value.details["transactions"] == 1


@pytest.mark.asyncio
async def test_delete_non_zero_balance_conflicts(db_session):
    user_uuid = await _mk_user(db_session)
    created = await _mk_account(db_session, user_uuid, name="A", initial="0", current="88")

    service = UserService(db_session)
    with pytest.raises(BusinessError) as excinfo:
        await service.delete_financial_account(user_uuid, created["uuid"])
    assert excinfo.value.status_code == 409
    assert "balance" in excinfo.value.details


@pytest.mark.asyncio
async def test_merge_repoints_transactions_and_recomputes_from_ledger(db_session):
    user_uuid = await _mk_user(db_session)
    # A: opened with 100, one expense of 20 -> ledger balance 80
    a = await _mk_account(db_session, user_uuid, name="A", initial="100", current="80")
    b = await _mk_account(db_session, user_uuid, name="B", initial="50", current="50")

    tx = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("20"),
        amount_original=Decimal("20"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source_account_id=a["uuid"],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )
    db_session.add(tx)
    await db_session.commit()

    service = UserService(db_session)
    result = await service.merge_financial_accounts(user_uuid, a["uuid"], b["uuid"])

    assert result["moved_transactions"] == 1
    assert result["target_id"] == b["id"]

    rows = (await db_session.execute(select(FinancialAccount))).scalars().all()
    assert len(rows) == 1 and str(rows[0].id) == b["id"], "source account must be deleted"

    tx_row = (await db_session.execute(select(Transaction))).scalar_one()
    assert str(tx_row.source_account_id) == b["id"], "transaction must be re-pointed"

    # Ledger-derived: initial_B(50) + effect(-20) = 30 — NOT additive (50+80).
    assert rows[0].current_balance == Decimal("30")


@pytest.mark.asyncio
async def test_merge_rejects_cross_currency_and_closed_target(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", currency="CNY", initial="100", current="100")
    b_usd = await _mk_account(db_session, user_uuid, name="B", currency="USD", initial="10", current="10")
    b_closed = await _mk_account(db_session, user_uuid, name="C", currency="CNY", initial="0", current="0", status="CLOSED")

    service = UserService(db_session)
    with pytest.raises(BusinessError):
        await service.merge_financial_accounts(user_uuid, a["uuid"], b_usd["uuid"])
    with pytest.raises(BusinessError):
        await service.merge_financial_accounts(user_uuid, a["uuid"], b_closed["uuid"])


@pytest.mark.asyncio
async def test_merge_requires_different_accounts(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", initial="100", current="100")
    service = UserService(db_session)
    with pytest.raises(BusinessError):
        await service.merge_financial_accounts(user_uuid, a["uuid"], a["uuid"])


@pytest.mark.asyncio
async def test_close_keep_freezes_snapshot_keeps_history(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", initial="100", current="88")
    tx = Transaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        amount=Decimal("12"),
        amount_original=Decimal("12"),
        currency="CNY",
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source_account_id=a["uuid"],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )
    db_session.add(tx)
    await db_session.commit()

    service = UserService(db_session)
    result = await service.close_financial_account(user_uuid, a["uuid"], disposal="keep")
    assert result["status"] == "CLOSED"
    assert result["disposal"] == "keep"

    row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == a["uuid"])
    )).scalar_one()
    assert row.status == "CLOSED"
    assert row.current_balance == Decimal("88"), "snapshot frozen"
    tx_count = (await db_session.execute(select(func.count()).select_from(Transaction))).scalar()
    assert tx_count == 1, "history must survive closing"


@pytest.mark.asyncio
async def test_close_writeoff_generates_expense_and_zeroes_balance(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", initial="100", current="100")

    service = UserService(db_session)
    result = await service.close_financial_account(user_uuid, a["uuid"], disposal="writeoff")
    assert result["status"] == "CLOSED"
    assert result["disposal"] == "writeoff"

    row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == a["uuid"])
    )).scalar_one()
    assert row.current_balance == Decimal("0"), "write-off must zero the balance via the ledger"

    tx_row = (await db_session.execute(select(Transaction))).scalar_one()
    assert tx_row.type == "EXPENSE"
    assert tx_row.amount_original == Decimal("100")


@pytest.mark.asyncio
async def test_close_transfer_moves_balance_to_target(db_session):
    user_uuid = await _mk_user(db_session)
    src = await _mk_account(db_session, user_uuid, name="A", initial="100", current="100")
    dst = await _mk_account(db_session, user_uuid, name="B", initial="50", current="50")

    service = UserService(db_session)
    result = await service.close_financial_account(
        user_uuid, src["uuid"], disposal="transfer", target_account_id=dst["uuid"]
    )
    assert result["status"] == "CLOSED"
    assert result["disposal"] == "transfer"

    src_row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == src["uuid"])
    )).scalar_one()
    dst_row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == dst["uuid"])
    )).scalar_one()
    assert src_row.status == "CLOSED"
    assert src_row.current_balance == Decimal("0")
    assert dst_row.current_balance == Decimal("150")

    tx_row = (await db_session.execute(select(Transaction))).scalar_one()
    assert tx_row.type == "TRANSFER"
    assert str(tx_row.source_account_id) == src["id"]
    assert str(tx_row.target_account_id) == dst["id"]


@pytest.mark.asyncio
async def test_close_transfer_requires_target_and_rejects_closed(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", initial="100", current="100")
    closed = await _mk_account(db_session, user_uuid, name="C", initial="0", current="0", status="CLOSED")

    service = UserService(db_session)
    with pytest.raises(ValidationError):
        await service.close_financial_account(user_uuid, a["uuid"], disposal="transfer", target_account_id=None)
    with pytest.raises(ValidationError):
        await service.close_financial_account(user_uuid, a["uuid"], disposal="transfer", target_account_id=closed["uuid"])


@pytest.mark.asyncio
async def test_close_already_closed_rejected(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", initial="0", current="0", status="CLOSED")

    service = UserService(db_session)
    with pytest.raises(ValidationError):
        await service.close_financial_account(user_uuid, a["uuid"], disposal="keep")


@pytest.mark.asyncio
async def test_close_unknown_account_not_found(db_session):
    user_uuid = await _mk_user(db_session)
    service = UserService(db_session)
    with pytest.raises(NotFoundError):
        await service.close_financial_account(user_uuid, uuid4(), disposal="keep")


@pytest.mark.asyncio
async def test_close_blocked_by_recurring_rule(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", initial="0", current="0")

    from datetime import date

    from app.models.transaction import RecurringTransaction

    rule = RecurringTransaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        source_account_id=a["uuid"],
        amount=Decimal("50"),
        currency="CNY",
        recurrence_rule="FREQ=MONTHLY",
        start_date=date.today(),
        is_active=True,
    )
    db_session.add(rule)
    await db_session.commit()

    service = UserService(db_session)
    with pytest.raises(BusinessError) as excinfo:
        await service.close_financial_account(user_uuid, a["uuid"], disposal="keep")
    assert excinfo.value.status_code == 409
    assert excinfo.value.details["recurring"] == 1

    # Nothing may have changed
    row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == a["uuid"])
    )).scalar_one()
    assert row.status == "ACTIVE"


@pytest.mark.asyncio
async def test_merge_repoints_recurring_rules(db_session):
    user_uuid = await _mk_user(db_session)
    a = await _mk_account(db_session, user_uuid, name="A", initial="100", current="100")
    b = await _mk_account(db_session, user_uuid, name="B", initial="50", current="50")

    from datetime import date

    from app.models.transaction import RecurringTransaction

    rule = RecurringTransaction(
        uuid=uuid4(),
        user_uuid=user_uuid,
        type="EXPENSE",
        source_account_id=a["uuid"],
        amount=Decimal("50"),
        currency="CNY",
        recurrence_rule="FREQ=MONTHLY",
        start_date=date.today(),
        is_active=True,
    )
    db_session.add(rule)
    await db_session.commit()

    service = UserService(db_session)
    result = await service.merge_financial_accounts(user_uuid, a["uuid"], b["uuid"])
    assert result["moved_recurring"] == 1

    rule_row = (await db_session.execute(select(RecurringTransaction))).scalar_one()
    assert str(rule_row.source_account_id) == b["uuid"]


@pytest.mark.asyncio
async def test_close_liability_writeoff_zeroes_balance_via_income(db_session):
    """Liability balances are stored negative (owed money). Writing them off
    must credit the closing account through an INCOME entry so the balance
    returns to zero instead of growing more negative."""
    user_uuid = await _mk_user(db_session)
    acc = await _mk_account(db_session, user_uuid, name="Card", nature="LIABILITY",
                            initial="0", current="-3000")

    service = UserService(db_session)
    result = await service.close_financial_account(user_uuid, acc["uuid"], disposal="writeoff")

    assert result["status"] == "CLOSED"
    assert Decimal(result["final_balance"]) == 0

    tx = (await db_session.execute(
        select(Transaction).where(Transaction.source_account_id == acc["uuid"])
        .union(select(Transaction).where(Transaction.target_account_id == acc["uuid"]))
    )).scalars().first()
    assert tx is not None
    assert tx.type == "INCOME"
    assert str(tx.target_account_id) == acc["uuid"], "income must credit the closing account as target"

    row = (await db_session.execute(
        select(FinancialAccount).where(FinancialAccount.uuid == acc["uuid"])
    )).scalar_one()
    assert row.current_balance == 0


@pytest.mark.asyncio
async def test_close_liability_transfer_moves_debt_to_target(db_session):
    """Closing a liability with a negative balance transfers the DEBT to the
    chosen account (closing account becomes the transfer target), zeroing it."""
    user_uuid = await _mk_user(db_session)
    acc = await _mk_account(db_session, user_uuid, name="Card", nature="LIABILITY",
                            initial="0", current="-3000")
    target = await _mk_account(db_session, user_uuid, name="Other", nature="LIABILITY",
                               initial="0", current="0")

    service = UserService(db_session)
    result = await service.close_financial_account(
        user_uuid, acc["uuid"], disposal="transfer", target_account_id=target["uuid"],
    )

    assert Decimal(result["final_balance"]) == 0
    tx = (await db_session.execute(select(Transaction))).scalars().first()
    assert tx.type == "TRANSFER"
    assert str(tx.source_account_id) == target["uuid"], "debt moves FROM the chosen target"
    assert str(tx.target_account_id) == acc["uuid"], "closing account RECEIVES the debt (returns to zero)"

    rows = {str(r.uuid): r for r in (await db_session.execute(select(FinancialAccount))).scalars()}
    assert rows[acc["uuid"]].current_balance == 0
    assert rows[target["uuid"]].current_balance == Decimal("-3000"), "debt now sits on the target"
