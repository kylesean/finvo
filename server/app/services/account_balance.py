"""Shared ledger-effect helpers for financial account balances.

The ledger invariant used across the codebase (mirrors
``scripts/reconcile_balances.py`` and ``TransactionCRUDService.ledger``):

    current_balance = initial_balance + Σ signed_effect(cleared tx on account)

- EXPENSE  deducts  the source account
- INCOME   credits  the target account
- TRANSFER moves     source -> target

Amounts are converted to the account's own currency using the transaction's
snapshot (exact when currencies match, snapshot ``amount`` when the account
currency is the base currency, live conversion otherwise, with a snapshot
fallback derived from ``exchange_rate`` / implicit rate).

These helpers are the single source of truth for balance derivation so
account lifecycle operations (save / merge / close) never drift from the
transaction ledger.

This module deliberately reuses the exact conversion semantics of
``scripts/reconcile_balances.py`` — keep the two in sync.
"""

from __future__ import annotations

from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.models.financial_account import FinancialAccount
from app.models.transaction import RecurringTransaction, Transaction
from app.services.exchange_rate_service import exchange_rate_service
from app.utils.currency_utils import BASE_CURRENCY


async def tx_effect_amount(tx: Transaction, account_currency: str) -> Decimal:
    """Convert a transaction's absolute amount into the account currency.

    Snapshot-based conversion mirroring ``scripts/reconcile_balances.py``:

    - account currency == tx currency -> ``amount_original`` (exact)
    - account currency == base       -> ``amount`` (snapshot, stable)
    - any other currency             -> live conversion; falls back to the
      snapshot rate when conversion is unavailable and raises only if no
      usable rate exists at all, so the ledger is never silently mislabeled.
    """
    tx_currency = (tx.currency or BASE_CURRENCY).upper()
    target = account_currency.upper()
    if target == tx_currency:
        return abs(Decimal(str(tx.amount_original)))
    if target == BASE_CURRENCY:
        return abs(Decimal(str(tx.amount)))

    try:
        converted = await exchange_rate_service.convert(
            amount=abs(Decimal(str(tx.amount_original))),
            from_currency=tx_currency,
            to_currency=target,
        )
        if converted is not None:
            return Decimal(str(converted))
    except Exception:  # noqa: BLE001 - fall through to snapshot fallbacks
        pass

    tx_amount = Decimal(str(tx.amount_original or 0))
    base_amount = Decimal(str(tx.amount or 0))

    if tx.exchange_rate and Decimal(str(tx.exchange_rate)) > 0:
        rate = Decimal(str(tx.exchange_rate))
        if tx_currency == BASE_CURRENCY:
            return tx_amount / rate
        if target == BASE_CURRENCY:
            return tx_amount * rate

    if base_amount and tx_amount and base_amount != 0:
        implicit_rate = base_amount / tx_amount
        if implicit_rate > 0:
            if tx_currency == BASE_CURRENCY:
                return tx_amount / implicit_rate
            if target == BASE_CURRENCY:
                return tx_amount * implicit_rate

    raise ValueError(f"no exchange rate available to convert {tx_currency} -> {target} (tx {tx.id})")


async def tx_ledger_effect(tx: Transaction, account: FinancialAccount) -> Decimal:
    """Signed balance effect of a single transaction on an account (0 if not linked)."""
    tx_type = (tx.type or "").upper()
    if tx.source_account_id != account.id and tx.target_account_id != account.id:
        return Decimal("0")

    acc_currency = (account.currency_code or PROJECT_DEFAULT_CURRENCY).upper()
    amount = await tx_effect_amount(tx, acc_currency)

    if tx_type == "EXPENSE":
        return -amount if tx.source_account_id == account.id else Decimal("0")
    if tx_type == "INCOME":
        return amount if tx.target_account_id == account.id else Decimal("0")
    if tx_type == "TRANSFER":
        effect = Decimal("0")
        if tx.source_account_id == account.id:
            effect -= amount
        if tx.target_account_id == account.id:
            effect += amount
        return effect
    return Decimal("0")


async def compute_expected_balance(
    db: AsyncSession,
    account: FinancialAccount,
) -> tuple[Decimal, bool]:
    """Compute the ledger-derived expected balance for an account.

    Returns:
        (expected_balance, all_effects_known)
        ``all_effects_known=False`` when any linked transaction lacks a usable
        exchange rate — callers should then fall back to a safe approximation
        instead of overwriting a real balance with a partial sum.
    """
    result = await db.execute(
        select(Transaction).where(
            Transaction.status == "CLEARED",
            Transaction.source_account_id == account.id,
        )
    )
    source_txs = result.scalars().all()
    result = await db.execute(
        select(Transaction).where(
            Transaction.status == "CLEARED",
            Transaction.target_account_id == account.id,
        )
    )
    target_txs = result.scalars().all()

    expected = Decimal(account.initial_balance or 0)
    for tx in [*source_txs, *target_txs]:
        try:
            expected += await tx_ledger_effect(tx, account)
        except ValueError:
            return Decimal(account.current_balance or 0), False
    return expected, True


async def recompute_account_balance(db: AsyncSession, account: FinancialAccount) -> Decimal:
    """Recompute and persist an account's balance from its transaction ledger.

    Falls back to keeping the current balance (no write) when the ledger cannot
    be fully derived (missing exchange rate). Returns the resulting balance.
    """
    expected, known = await compute_expected_balance(db, account)
    if known:
        account.current_balance = expected
    return Decimal(account.current_balance or 0)


async def count_account_references(db: AsyncSession, account_id: UUID) -> dict[str, int]:
    """Count references to an account from transactions and recurring rules.

    Transactions reference accounts via ``source_account_id`` / ``target_account_id``
    (FK ``ondelete=SET NULL`` today); recurring rules reference them too. Any
    reference means a physical delete would silently corrupt history.
    """
    result = await db.execute(
        select(func.count()).select_from(Transaction).where(
            (Transaction.source_account_id == account_id)
            | (Transaction.target_account_id == account_id)
        )
    )
    tx_count = int(result.scalar() or 0)

    result = await db.execute(
        select(func.count()).select_from(RecurringTransaction).where(
            (RecurringTransaction.source_account_id == account_id)
            | (RecurringTransaction.target_account_id == account_id)
        )
    )
    recurring_count = int(result.scalar() or 0)

    return {"transactions": tx_count, "recurring": recurring_count}
