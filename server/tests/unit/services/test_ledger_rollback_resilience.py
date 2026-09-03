"""Ledger regression: single conversion core + outage-proof rollback.

- Live ledger, lifecycle recompute and the reconcile script share one
  conversion rule (no more three-way drift).
- Deleting a cross-currency transaction during a rate outage succeeds and
  reverses symmetrically (snapshot branches need no live rate).
- Hops even the snapshot cannot express are skipped with a log on the
  rollback path instead of failing the delete.
"""

from datetime import UTC, datetime
from decimal import Decimal
from unittest.mock import AsyncMock, patch
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.financial_account import FinancialAccount
from app.models.financial_settings import FinancialSettings
from app.models.transaction import Transaction
from app.models.user import User
from app.services.account_balance import (
    compute_expected_balance,
    convert_snapshot_to_currency,
    ledger_effect_for_account,
)
from app.services.exchange_rate_service import exchange_rate_service
from app.services.transaction.crud_service import TransactionCRUDService
from app.services.transaction.ledger_service import TransactionLedgerService


async def _seed_user(db: AsyncSession, base: str = "CNY") -> User:
    tag = f"p29-{uuid4().hex[:8]}"
    user = User(uuid=uuid4(), username=tag, email=f"{tag}@example.com", password="hash", registration_type="email")
    db.add(user)
    await db.flush()
    db.add(FinancialSettings(user_uuid=user.uuid, primary_currency=base))
    await db.commit()
    await db.refresh(user)
    return user


async def _seed_account(db: AsyncSession, user: User, currency: str, balance: str) -> FinancialAccount:
    account = FinancialAccount(
        user_uuid=user.uuid,
        name=f"acct-{currency}-{uuid4().hex[:6]}",
        type="CASH",
        nature="ASSET",
        currency_code=currency,
        initial_balance=Decimal(balance),
        current_balance=Decimal(balance),
        status="ACTIVE",
        include_in_net_worth=True,
    )
    db.add(account)
    await db.commit()
    await db.refresh(account)
    return account


def _tx(owner: User, account: FinancialAccount, *, original: str, currency: str, base: str) -> Transaction:
    return Transaction(
        uuid=uuid4(),
        user_uuid=owner.uuid,
        type="EXPENSE",
        source_account_id=account.uuid,
        amount=Decimal(base),
        amount_original=Decimal(original),
        currency=currency,
        transaction_at=datetime.now(UTC),
        status="CLEARED",
        source="MANUAL",
    )


def _boom(*args, **kwargs):
    raise AssertionError("live rate must not be consulted on this path")


class TestOutageProofDelete:
    @pytest.mark.asyncio
    async def test_delete_cross_currency_tx_symmetric_without_live_rate(self, db_session: AsyncSession) -> None:
        """USD tx on a USD account (CNY base): create/apply then delete with
        the rate service exploding — balances must round-trip exactly."""
        user = await _seed_user(db_session, "CNY")
        account = await _seed_account(db_session, user, "USD", "1000.00")
        crud = TransactionCRUDService(db_session)
        tx = _tx(user, account, original="100", currency="USD", base="720")
        db_session.add(tx)
        await db_session.commit()

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_boom)):
            await crud.ledger.apply_transaction_balance_effect(
                tx,
                user.uuid,
                sign=1,
                source_account_id=account.uuid,
                target_account_id=None,
                for_update=True,
            )
            await db_session.flush()
            await db_session.refresh(account)
            assert Decimal(account.current_balance) == Decimal("900.00")

            assert await crud.delete_transaction(tx.uuid, user.uuid) is True
            await db_session.refresh(account)
            assert Decimal(account.current_balance) == Decimal("1000.00")

    @pytest.mark.asyncio
    async def test_delete_skips_unresolvable_third_currency_hop(self, db_session: AsyncSession) -> None:
        """USD tx booked against a EUR account (CNY base) with no snapshot
        rate and a dead rate service: delete must still succeed (drift left
        for reconcile), never 500."""
        user = await _seed_user(db_session, "CNY")
        account = await _seed_account(db_session, user, "EUR", "1000.00")
        crud = TransactionCRUDService(db_session)
        tx = _tx(user, account, original="100", currency="USD", base="720")
        tx.exchange_rate = None
        db_session.add(tx)
        await db_session.commit()

        async def _live_90(*, amount, from_currency, to_currency, **_kw):
            assert (from_currency, to_currency) == ("USD", "EUR")
            return Decimal("90.00")

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_live_90)):
            await crud.ledger.apply_transaction_balance_effect(
                tx,
                user.uuid,
                sign=1,
                source_account_id=account.uuid,
                target_account_id=None,
                for_update=True,
            )
            await db_session.flush()
            await db_session.refresh(account)
            assert Decimal(account.current_balance) == Decimal("910.00")

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_boom)):
            assert await crud.delete_transaction(tx.uuid, user.uuid) is True
            await db_session.refresh(account)
            # Unresolvable hop skipped: balance keeps the applied effect so
            # the reconcile script can flag the drift (no silent mislabel).
            assert Decimal(account.current_balance) == Decimal("910.00")


class TestCanonicalCore:
    @pytest.mark.asyncio
    async def test_snapshot_branches_never_touch_live_rate(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, "CNY")
        account = await _seed_account(db_session, user, "USD", "0")
        tx = _tx(user, account, original="100", currency="USD", base="720")
        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_boom)):
            assert await convert_snapshot_to_currency(
                amount_original=tx.amount_original,
                amount_base=tx.amount,
                tx_currency=tx.currency,
                target_currency="USD",
                user_base_currency="CNY",
            ) == Decimal("100")
            assert await convert_snapshot_to_currency(
                amount_original=tx.amount_original,
                amount_base=tx.amount,
                tx_currency=tx.currency,
                target_currency="CNY",
                user_base_currency="CNY",
            ) == Decimal("720")
            assert await ledger_effect_for_account(tx, account, "CNY") == Decimal("-100")

    @pytest.mark.asyncio
    async def test_live_used_when_allowed_unavailable_when_forbidden(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session, "CNY")
        account = await _seed_account(db_session, user, "EUR", "0")
        tx = _tx(user, account, original="100", currency="USD", base="720")
        tx.exchange_rate = None

        async def _live(*, amount, from_currency, to_currency, **_kw):
            return Decimal("90.00")

        ledger = TransactionLedgerService(db_session)
        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_live)):
            got = await ledger.convert_snapshot_amount(
                amount_original=Decimal("100"),
                amount_base=Decimal("720"),
                tx_currency="USD",
                target_currency="EUR",
                user_base_currency="CNY",
            )
            assert got == Decimal("90.00")

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_boom)):
            # Rollback mode: no live, no usable snapshot hop -> ValueError
            # (the ledger translates to BusinessError; delete path skips).
            with pytest.raises(ValueError):
                await _forbidden(tx)

    @pytest.mark.asyncio
    async def test_ledger_lifecycle_and_reconcile_agree(self, db_session: AsyncSession) -> None:
        """Live apply, lifecycle recompute and the reconcile math agree on one tx."""
        from scripts.reconcile_balances import FALLBACK_BASE_CURRENCY

        assert FALLBACK_BASE_CURRENCY  # script resolves per-user base with this fallback
        user = await _seed_user(db_session, "CNY")
        account = await _seed_account(db_session, user, "USD", "1000.00")
        crud = TransactionCRUDService(db_session)
        tx = _tx(user, account, original="100", currency="USD", base="720")
        db_session.add(tx)
        await db_session.commit()

        with patch.object(exchange_rate_service, "convert", AsyncMock(side_effect=_boom)):
            await crud.ledger.apply_transaction_balance_effect(
                tx, user.uuid, sign=1, source_account_id=account.uuid, target_account_id=None, for_update=True
            )
            await db_session.flush()
            await db_session.refresh(account)
            assert Decimal(account.current_balance) == Decimal("900.00")

            expected, known = await compute_expected_balance(db_session, account)
            assert known is True
            assert expected == Decimal(account.current_balance)
            assert await ledger_effect_for_account(tx, account, "CNY") == Decimal("-100")


async def _forbidden(tx: Transaction) -> Decimal:
    from app.services.account_balance import convert_snapshot_to_currency

    return await convert_snapshot_to_currency(
        amount_original=tx.amount_original,
        amount_base=tx.amount,
        tx_currency=tx.currency,
        target_currency="EUR",
        user_base_currency="CNY",
        allow_live_rate=False,
    )
