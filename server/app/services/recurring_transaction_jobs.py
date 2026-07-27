"""Recurring transaction scheduled job functions.

This module contains the actual job logic for processing
recurring transactions. These functions are called by the
scheduler service.
"""

from datetime import UTC, date, datetime, time as dt_time
from decimal import Decimal
from typing import Any, cast as type_cast
from uuid import uuid4

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
    for any recurring transactions scheduled for today.
    Uses UTC-aware datetimes to match the tz-aware next_execution_at column.
    """
    logger.info("processing_due_recurring_transactions_started")

    async with get_session_context() as db:
        try:
            # Use UTC date to stay consistent with tz-aware columns
            today = datetime.now(UTC).date()
            today_start = datetime.combine(today, dt_time.min, tzinfo=UTC)
            today_end = datetime.combine(today, dt_time.max, tzinfo=UTC)

            # Find all active recurring transactions due today
            query = select(RecurringTransaction).where(
                type_cast(
                    Any,
                    and_(
                        type_cast(Any, RecurringTransaction.is_active) == True,  # noqa: E712
                        type_cast(Any, RecurringTransaction.next_execution_at) != None,  # noqa: E711
                        type_cast(Any, RecurringTransaction.next_execution_at) >= today_start,
                        type_cast(Any, RecurringTransaction.next_execution_at) <= today_end,
                    ),
                )
            )

            result = await db.execute(query)
            due_transactions = result.scalars().all()

            processed_count = 0
            skipped_count = 0
            error_count = 0

            for recurring_tx in due_transactions:
                try:
                    # Idempotency: skip if already generated today
                    if await _already_generated_today(db, recurring_tx, today):
                        skipped_count += 1
                        # Still advance the schedule
                        await _update_next_execution(db, recurring_tx)
                        continue

                    await _create_transaction_from_recurring(db, recurring_tx)
                    await _update_next_execution(db, recurring_tx)
                    processed_count += 1
                except Exception as e:
                    error_count += 1
                    logger.error(
                        "recurring_transaction_processing_failed",
                        recurring_id=str(recurring_tx.id),
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


async def _already_generated_today(
    db: AsyncSession,
    recurring_tx: RecurringTransaction,
    today: date,
) -> bool:
    """Check if a transaction was already generated for this rule today.

    Provides idempotency protection against misfire retries or multi-worker races.
    """
    today_start = datetime.combine(today, dt_time.min, tzinfo=UTC)
    today_end = datetime.combine(today, dt_time.max, tzinfo=UTC)

    query = select(func.count()).where(
        type_cast(
            Any,
            and_(
                type_cast(Any, Transaction.recurring_transaction_id) == recurring_tx.id,
                type_cast(Any, Transaction.transaction_at) >= today_start,
                type_cast(Any, Transaction.transaction_at) <= today_end,
            ),
        )
    )
    result = await db.execute(query)
    count = result.scalar() or 0
    return count > 0


async def _create_transaction_from_recurring(
    db: AsyncSession,
    recurring_tx: RecurringTransaction,
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

    user_base = await get_user_base_currency(db, recurring_tx.user_uuid)
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
        raw_input=f"[自动生成] {recurring_tx.description or '周期交易'}",
        transaction_at=recurring_tx.next_execution_at or utc_now(),
        transaction_timezone=recurring_tx.timezone,
        source_account_id=recurring_tx.source_account_id,
        target_account_id=recurring_tx.target_account_id,
        tags=recurring_tx.tags,
        source="RECURRING",
        status=status,
        recurring_transaction_id=recurring_tx.id,
    )

    db.add(transaction)
    recurring_tx.last_generated_at = utc_now()

    logger.info(
        "transaction_created_from_recurring",
        transaction_id=str(transaction.id),
        recurring_id=str(recurring_tx.id),
        amount=str(recurring_tx.amount),
        status=status,
    )

    # Send notification when transaction requires user confirmation
    if status == "PENDING":
        try:
            from app.services.push_service import PushService

            desc = recurring_tx.description or recurring_tx.category_key or ""
            await PushService.send_notification(
                db=db,
                user_uuid=recurring_tx.user_uuid,
                type_="recurring_pending",
                title="recurring_pending",
                content=desc,
                data={
                    "action": "recurring_pending",
                    "transaction_id": str(transaction.id),
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
                transaction_id=str(transaction.id),
                error=str(e),
            )


async def _update_next_execution(
    db: AsyncSession,
    recurring_tx: RecurringTransaction,
) -> None:
    """Update the next execution date for a recurring transaction."""
    service = RecurringTransactionService(db)

    next_execution = service._calculate_next_execution(
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
            recurring_id=str(recurring_tx.id),
        )
