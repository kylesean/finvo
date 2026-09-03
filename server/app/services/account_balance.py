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
"""

from __future__ import annotations

from decimal import Decimal
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.models.financial_account import FinancialAccount
from app.models.transaction import RecurringTransaction, Transaction
from app.services.exchange_rate_service import exchange_rate_service
from app.utils.currency_utils import get_user_base_currency


async def convert_snapshot_to_currency(
    *,
    amount_original: Decimal | None,
    amount_base: Decimal | None,
    tx_currency: str | None,
    target_currency: str,
    user_base_currency: str,
    exchange_rate: Decimal | None = None,
    tx_id: object = None,
    allow_live_rate: bool = True,
) -> Decimal:
    """Convert a transaction snapshot amount to an account's currency.

    Takes plain values so non-ORM callers (live ledger, scripts) share it
    without fabricating model instances. Raises ``ValueError`` when unresolvable.

    Priority: snapshot-exact branches first (no rate needed), then live
    conversion when allowed, then stored-rate back-derive as outage fallback.
    Stored rates stay behind live ones: they only express tx-base hops, so
    preferring them would misprice third-currency amounts on the happy path.
    Rollback callers pass ``allow_live_rate=False`` and skip on ValueError
    instead of blocking deletes.
    """
    base = user_base_currency.upper()
    tx_cur = (tx_currency or base).upper()
    target = target_currency.upper()
    if target == tx_cur:
        return abs(Decimal(str(amount_original)))
    if target == base:
        return abs(Decimal(str(amount_base)))

    if allow_live_rate:
        try:
            converted = await exchange_rate_service.convert(
                amount=abs(Decimal(str(amount_original))),
                from_currency=tx_cur,
                to_currency=target,
            )
            if converted is not None:
                return Decimal(str(converted))
        except Exception:  # noqa: BLE001 - fall through to stored fallbacks
            pass

    orig = Decimal(str(amount_original or 0))
    base_amt = Decimal(str(amount_base or 0))

    if exchange_rate and Decimal(str(exchange_rate)) > 0:
        rate = Decimal(str(exchange_rate))
        if tx_cur == base:
            return orig / rate
        if target == base:
            return orig * rate

    if base_amt and orig and base_amt != 0:
        implicit_rate = base_amt / orig
        if implicit_rate > 0:
            if tx_cur == base:
                return orig / implicit_rate
            if target == base:
                return orig * implicit_rate

    raise ValueError(f"no exchange rate available to convert {tx_cur} -> {target} (tx {tx_id})")


async def ledger_effect_for_account(
    tx: Transaction,
    account: FinancialAccount,
    user_base_currency: str,
    *,
    allow_live_rate: bool = True,
) -> Decimal:
    """Signed balance effect of a single transaction on an account (0 if not linked)."""
    tx_type = (tx.type or "").upper()
    if tx.source_account_id != account.id and tx.target_account_id != account.id:
        return Decimal("0")

    acc_currency = (account.currency_code or PROJECT_DEFAULT_CURRENCY).upper()
    amount = await convert_snapshot_to_currency(
        amount_original=tx.amount_original,
        amount_base=tx.amount,
        tx_currency=tx.currency,
        target_currency=acc_currency,
        user_base_currency=user_base_currency,
        exchange_rate=tx.exchange_rate,
        tx_id=tx.id,
        allow_live_rate=allow_live_rate,
    )

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
    user_base_currency = await get_user_base_currency(db, account.user_uuid)
    for tx in [*source_txs, *target_txs]:
        try:
            expected += await ledger_effect_for_account(tx, account, user_base_currency)
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
        select(func.count())
        .select_from(Transaction)
        .where((Transaction.source_account_id == account_id) | (Transaction.target_account_id == account_id))
    )
    tx_count = int(result.scalar() or 0)

    result = await db.execute(
        select(func.count())
        .select_from(RecurringTransaction)
        .where(
            (RecurringTransaction.source_account_id == account_id)
            | (RecurringTransaction.target_account_id == account_id)
        )
    )
    recurring_count = int(result.scalar() or 0)

    return {"transactions": tx_count, "recurring": recurring_count}
