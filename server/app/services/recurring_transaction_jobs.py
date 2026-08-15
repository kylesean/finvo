"""Recurring transaction scheduled job functions.

This module contains the actual job logic for processing
recurring transactions. These functions are called by the
scheduler service.
"""

from datetime import UTC, datetime
from decimal import Decimal
from typing import Any, cast as type_cast
from uuid import UUID, uuid4

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session_context
from app.core.logging import logger
from app.models.transaction import RecurringTransaction, Transaction
from app.services.transaction.recurring_service import RecurringTransactionService

# Maximum iterations when scanning rrule occurrences to prevent infinite loops
# on rules without UNTIL/COUNT that start far in the past.
_MAX_RRULE_ITERATIONS = 1000


async def process_due_transactions() -> None:
    """Process all recurring transactions due today.

    This job runs daily and creates actual transaction records
    for any recurring transactions whose next_execution_at has arrived.
    Uses exact next_execution_at matching for idempotency — timezone-independent.
    """
    logger.info("processing_due_recurring_transactions_started")

    async with get_session_context() as db:
        try:
            now = datetime.now(UTC)

            # Find all active recurring transactions whose next_execution_at <= now
            query = select(RecurringTransaction).where(
                type_cast(
                    Any,
                    and_(
                        RecurringTransaction.is_active == True,  # noqa: E712
                        RecurringTransaction.next_execution_at != None,  # noqa: E711
                        RecurringTransaction.next_execution_at <= now,
                    ),
                )
            )

            result = await db.execute(query)
            due_transactions = result.scalars().all()

            processed_count = 0
            skipped_count = 0
            error_count = 0

            # Caches to prevent N+1 DB queries per due item
            user_base_cache: dict[UUID, str] = {}

            for recurring_tx in due_transactions:
                try:
                    # S-C: per-item savepoint. The ledger balance effect raises
                    # when a cross-currency rate is unavailable (never silently
                    # mislabels) — without a savepoint that failure would still
                    # commit the transaction insert at the end of the loop,
                    # orphaning a transaction that has no balance effect and is
                    # then blocked forever by the _already_generated dedup.
                    # Rolling back to the savepoint keeps the item atomic: the
                    # transaction is not created and the next run retries it.
                    async with db.begin_nested():
                        # Idempotency: skip if already generated for this exact execution point
                        if await _already_generated(db, recurring_tx):
                            skipped_count += 1
                            # Still advance the schedule
                            await _update_next_execution(db, recurring_tx)
                            continue

                        await _create_transaction_from_recurring(db, recurring_tx, user_base_cache=user_base_cache)
                        await _update_next_execution(db, recurring_tx)
                        processed_count += 1
                except Exception as e:
                    error_count += 1
                    logger.error(
                        "recurring_transaction_processing_failed",
                        recurring_id=str(recurring_tx.uuid),
                        error=str(e),
                    )

            await db.commit()

            logger.info(
                "processing_due_recurring_transactions_completed",
                processed=processed_count,
                skipped=skipped_count,
                errors=error_count,
                total=len(due_transactions),
            )

        except Exception as e:
            logger.error(
                "processing_due_recurring_transactions_failed",
                error=str(e),
            )
            await db.rollback()


async def _already_generated(
    db: AsyncSession,
    recurring_tx: RecurringTransaction,
) -> bool:
    """Check if a transaction was already generated for this exact next_execution_at.

    Uses precise timestamp matching (not date-range) so it is fully
    timezone-independent: the same next_execution_at value will never
    produce duplicate transactions regardless of server timezone.
    """
    if recurring_tx.next_execution_at is None:
        return False

    query = select(func.count()).where(
        type_cast(
            Any,
            and_(
                Transaction.recurring_transaction_id == recurring_tx.uuid,
                Transaction.transaction_at == recurring_tx.next_execution_at,
            ),
        )
    )
    result = await db.execute(query)
    count = result.scalar() or 0
    return count > 0


async def _apply_recurring_balance_effect(
    db: AsyncSession,
    recurring_tx: RecurringTransaction,
    transaction: Transaction,
) -> None:
    """Apply the ledger balance effect for an auto-confirmed recurring transaction.

    S-C: replaces the previous manual balance adjustment. The ledger service is
    the single source of truth — it converts via the transaction's snapshot
    with the user's REAL base currency (never silently books ``amount_base`` as
    the account currency) and takes a row lock (``for_update``) so a concurrent
    balance edit cannot lose an update.
    """
    from app.services.transaction.ledger_service import TransactionLedgerService

    ledger = TransactionLedgerService(db)
    tx_type = transaction.type.upper() if transaction.type else "EXPENSE"

    if tx_type == "EXPENSE":
        await ledger.apply_transaction_balance_effect(
            transaction,
            recurring_tx.user_uuid,
            sign=1,
            source_account_id=transaction.source_account_id,
            target_account_id=None,
            for_update=True,
        )
    elif tx_type == "INCOME":
        # Preserve the legacy fallback: an income rule with no target account
        # credits the source account.
        target_id = transaction.target_account_id or transaction.source_account_id
        await ledger.apply_transaction_balance_effect(
            transaction,
            recurring_tx.user_uuid,
            sign=1,
            source_account_id=None,
            target_account_id=target_id,
            for_update=True,
        )
    elif tx_type == "TRANSFER":
        await ledger.apply_transaction_balance_effect(
            transaction,
            recurring_tx.user_uuid,
            sign=1,
            source_account_id=transaction.source_account_id,
            target_account_id=transaction.target_account_id,
            for_update=True,
        )


async def _create_transaction_from_recurring(
    db: AsyncSession,
    recurring_tx: RecurringTransaction,
    user_base_cache: dict[UUID, str] | None = None,
) -> None:
    """Create an actual transaction from a recurring transaction rule.

    If requires_confirmation is True, the transaction is created with
    status='PENDING' so the user can review it before it affects totals.
    """
    from app.models.base import utc_now
    from app.utils.currency_utils import convert_to_user_base, get_user_base_currency

    # Currency conversion: convert to user's base currency with rate snapshot
    amount_original = recurring_tx.amount
    currency = recurring_tx.currency.upper()

    user_uuid = recurring_tx.user_uuid
    if user_base_cache is not None and user_uuid in user_base_cache:
        user_base = user_base_cache[user_uuid]
    else:
        user_base = await get_user_base_currency(db, user_uuid)
        if user_base_cache is not None:
            user_base_cache[user_uuid] = user_base

    base_amount, exchange_rate = await convert_to_user_base(abs(amount_original), currency, user_base)
    amount = base_amount.quantize(Decimal("0.00000001"))

    # requires_confirmation → PENDING (user must approve); otherwise CONFIRMED
    status = "PENDING" if recurring_tx.requires_confirmation else "CONFIRMED"

    transaction = Transaction(
        id=uuid4(),
        user_uuid=recurring_tx.user_uuid,
        type=recurring_tx.type,
        amount_original=amount_original,
        amount=amount,
        currency=currency,
        exchange_rate=exchange_rate,
        category_key=recurring_tx.category_key,
        description=recurring_tx.description,
        raw_input=f"[Auto Generated] {recurring_tx.description or 'Recurring Transaction'}",
        transaction_at=recurring_tx.next_execution_at or utc_now(),
        transaction_timezone=recurring_tx.timezone,
        source_account_id=recurring_tx.source_account_id,
        target_account_id=recurring_tx.target_account_id,
        tags=recurring_tx.tags,
        source="RECURRING",
        status=status,
        recurring_transaction_id=recurring_tx.uuid,
    )

    db.add(transaction)

    # Immediately adjust linked account balances if transaction is automatically confirmed
    if status == "CONFIRMED":
        await _apply_recurring_balance_effect(db, recurring_tx, transaction)

    recurring_tx.last_generated_at = utc_now()

    logger.info(
        "transaction_created_from_recurring",
        transaction_id=str(transaction.uuid),
        recurring_id=str(recurring_tx.uuid),
        amount=str(recurring_tx.amount),
        status=status,
    )

    # Send notification when transaction requires user confirmation
    if status == "PENDING":
        try:
            from app.services.push_service import PushService

            desc = recurring_tx.description or ""
            # Use a SEPARATE session for the notification: send_notification commits
            # (and rolls back on error) its session, which must not touch the job's
            # still-pending transaction insert below.
            async with get_session_context() as notif_db:
                await PushService.send_notification(
                    db=notif_db,
                    user_uuid=recurring_tx.user_uuid,
                    type_="recurring_pending",
                    title="recurring_pending",
                    content=desc,
                    data={
                        "action": "recurring_pending",
                        "transaction_id": str(transaction.uuid),
                        "amount": str(amount_original),
                        "currency": currency,
                        "category_key": recurring_tx.category_key or "",
                        "description": desc,
                        "target_path": "/finance/recurring-transactions",
                    },
                )
        except Exception as e:
            # Non-critical: notification failure should not block transaction creation
            logger.warning(
                "recurring_pending_notification_failed",
                transaction_id=str(transaction.uuid),
                error=str(e),
            )


async def _update_next_execution(
    db: AsyncSession,
    recurring_tx: RecurringTransaction,
) -> None:
    """Update the next execution date for a recurring transaction."""
    service = RecurringTransactionService(db)

    next_execution = service.calculate_next_execution(
        recurring_tx.recurrence_rule,
        recurring_tx.start_date,
        recurring_tx.end_date,
        recurring_tx.exception_dates,
    )

    recurring_tx.next_execution_at = next_execution

    if next_execution is None:
        recurring_tx.is_active = False
        logger.info(
            "recurring_transaction_completed",
            recurring_id=str(recurring_tx.uuid),
        )
