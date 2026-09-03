#!/usr/bin/env python3
"""Reconcile account balances against the transaction ledger.

Recomputes each account's expected balance as:

    expected = initial_balance + sum(effect(tx) for tx on this account)

using the same snapshot-based conversion rule as the live ledger
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
from app.models.base import utc_now
from app.models.financial_account import FinancialAccount
from app.models.financial_settings import FinancialSettings
from app.models.transaction import Transaction
from app.services.account_balance import ledger_effect_for_account
from app.utils.currency_inference import FALLBACK_CURRENCY

FALLBACK_BASE_CURRENCY = FALLBACK_CURRENCY


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

    # Resolve each account owner's actual base currency (the ledger convention)
    # instead of assuming a global constant.
    base_by_user: dict[UUID, str] = {}
    settings_rows = (
        await session.execute(select(FinancialSettings.user_uuid, FinancialSettings.primary_currency))
    ).all()
    for user_uuid, primary in settings_rows:
        if primary:
            base_by_user[user_uuid] = primary.upper()

    total_diff = Decimal("0")
    skipped = 0
    corrected = 0
    for account in accounts:
        user_base = base_by_user.get(account.user_uuid, FALLBACK_BASE_CURRENCY)
        expected = Decimal(account.initial_balance or 0)
        effects_ok = True
        for tx in by_account.get(account.id, []):
            try:
                expected += await ledger_effect_for_account(tx, account, user_base)
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
