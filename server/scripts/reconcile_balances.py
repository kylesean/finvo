#!/usr/bin/env python3
"""One-off reconciliation of account balances against the transaction ledger.

Legacy behavior (before the Phase 1 fix) only adjusted balances for TRANSFER
transactions; EXPENSE/INCOME transactions never touched their linked accounts,
so existing balances drifted from the ledger. This script recomputes each
account's expected balance as:

    expected = initial_balance + sum(effect(tx) for tx on this account)

using the same snapshot-based conversion rule as TransactionCRUDService
(EXPENSE deducts source, INCOME credits target, TRANSFER moves source->target,
amounts converted from the transaction snapshot). Only CLEARED transactions
count, matching the ledger convention. Default is dry-run; pass ``--apply``
to write the corrections.

Usage:
    cd server
    uv run python scripts/reconcile_balances.py            # dry run (report only)
    uv run python scripts/reconcile_balances.py --apply    # write corrections
"""

from __future__ import annotations

import argparse
import asyncio
from decimal import Decimal
from uuid import UUID

from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

from app.core.config import settings
from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.models.base import utc_now
from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction
from app.services.exchange_rate_service import exchange_rate_service
from app.utils.currency_utils import BASE_CURRENCY


async def effect_amount(tx: Transaction, account_currency: str) -> Decimal:
    """Snapshot-based conversion mirroring ``_convert_amount_effect``.

    - account currency == tx currency -> ``amount_original`` (exact)
    - account currency == base       -> ``amount`` (snapshot, stable)
    - any other currency             -> live conversion; raises if unavailable
      so the ledger is never silently mislabeled.
    """
    tx_currency = (tx.currency or BASE_CURRENCY).upper()
    target = account_currency.upper()
    if target == tx_currency:
        return abs(tx.amount_original)
    if target == BASE_CURRENCY:
        return abs(tx.amount)

    try:
        converted = await exchange_rate_service.convert(
            amount=abs(tx.amount_original),
            from_currency=tx_currency,
            to_currency=target,
        )
        if converted is not None:
            return Decimal(str(converted))
    except Exception:
        pass

    # Universal snapshot fallback using tx.exchange_rate or tx.amount / tx.amount_original
    if tx.exchange_rate and tx.exchange_rate > 0:
        rate = Decimal(str(tx.exchange_rate))
        if tx_currency == BASE_CURRENCY:
            return abs(tx.amount_original) / rate
        if target == BASE_CURRENCY:
            return abs(tx.amount_original) * rate

    if tx.amount_original and tx.amount and tx.amount_original != Decimal("0"):
        implicit_rate = abs(tx.amount) / abs(tx.amount_original)
        if implicit_rate > Decimal("0"):
            if tx_currency == BASE_CURRENCY:
                return abs(tx.amount_original) / implicit_rate
            if target == BASE_CURRENCY:
                return abs(tx.amount_original) * implicit_rate

    raise ValueError(f"no exchange rate available to convert {tx_currency} -> {target} (tx {tx.id})")


async def ledger_effect(tx: Transaction, account: FinancialAccount) -> Decimal:
    """Signed balance effect of ``tx`` on ``account`` (0 if not linked)."""
    tx_type = (tx.type or "").upper()
    if tx.source_account_id != account.id and tx.target_account_id != account.id:
        return Decimal("0")

    acc_currency = (account.currency_code or PROJECT_DEFAULT_CURRENCY).upper()
    amount = await effect_amount(tx, acc_currency)

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


async def reconcile(session: AsyncSession, apply: bool) -> tuple[int, int, Decimal]:
    """Recompute expected balances, report diffs, optionally write fixes.

    Returns:
        (accounts, corrected, total_diff) summary.
    """
    accounts = (await session.execute(select(FinancialAccount))).scalars().all()
    transactions = (
        (
            await session.execute(
                select(Transaction).where(
                    Transaction.status == "CLEARED",
                    or_(
                        Transaction.source_account_id.is_not(None),
                        Transaction.target_account_id.is_not(None),
                    ),
                ),
            )
        )
        .scalars()
        .all()
    )

    # Index transactions by linked account for O(1) per-account iteration.
    by_account: dict[UUID, list[Transaction]] = {}
    for tx in transactions:
        for acc_id in (tx.source_account_id, tx.target_account_id):
            if acc_id is not None:
                by_account.setdefault(acc_id, []).append(tx)

    total_diff = Decimal("0")
    skipped = 0
    corrected = 0
    for account in accounts:
        expected = Decimal(account.initial_balance or 0)
        effects_ok = True
        for tx in by_account.get(account.id, []):
            try:
                expected += await ledger_effect(tx, account)
            except Exception as e:  # noqa: BLE001 - script-level guard
                print(f"  [skip] account={account.id} tx={tx.id} effect unknown: {e}")
                skipped += 1
                effects_ok = False
                break
        if not effects_ok:
            continue

        current = Decimal(account.current_balance or 0)
        diff = expected - current
        total_diff += diff
        if diff != 0:
            corrected += 1
            print(
                f"{account.id}  {account.name or ''}  {account.currency_code}  "
                f"current={current}  expected={expected}  diff={diff}"
            )
            if apply:
                account.current_balance = expected
                account.updated_at = utc_now()

    if apply:
        await session.commit()
    return len(accounts), corrected, total_diff


async def _run(apply: bool) -> None:
    engine = create_async_engine(settings.database_url)
    try:
        async with AsyncSession(engine, expire_on_commit=False) as session:
            accounts, corrected, total_diff = await reconcile(session, apply)
        action = "applied" if apply else "dry-run (use --apply to write)"
        print(f"\naccounts={accounts} corrected={corrected} total_diff={total_diff}  [{action}]")
    finally:
        await engine.dispose()


def main() -> None:
    parser = argparse.ArgumentParser(description="Reconcile account balances against the ledger")
    parser.add_argument("--apply", action="store_true", help="write corrections (default: report only)")
    args = parser.parse_args()
    asyncio.run(_run(apply=args.apply))


if __name__ == "__main__":
    main()
