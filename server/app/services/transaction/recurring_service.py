"""Recurring transaction service for scheduled transactions."""

import calendar
import re
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal, InvalidOperation
from typing import Any
from uuid import UUID

import structlog
from dateutil.rrule import rrulestr
from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.core.exceptions import BusinessError, CommonErrorCode, TransactionErrorCode
from app.models.base import utc_now
from app.models.transaction import RecurringTransaction

logger = structlog.get_logger(__name__)


def validate_recurrence_rule(v: str) -> str:
    """Validate RRULE format. Standalone function (not a model decorator).

    Args:
        v: The RRULE string to validate.

    Returns:
        The normalized (uppercased, stripped) rule string.

    Raises:
        BusinessError: If the rule is invalid (error_code =
            TransactionErrorCode.INVALID_RECURRENCE_RULE).
    """
    if not v or not v.strip():
        raise BusinessError(
            message="Recurrence rule cannot be empty",
            error_code=TransactionErrorCode.INVALID_RECURRENCE_RULE,
        )

    rule = v.strip().upper()

    if not rule.startswith("FREQ="):
        raise BusinessError(
            message="Invalid RRULE format: must start with FREQ=",
            error_code=TransactionErrorCode.INVALID_RECURRENCE_RULE,
        )

    valid_freqs = {"DAILY", "WEEKLY", "MONTHLY", "YEARLY"}
    freq_part = rule.split(";")[0].replace("FREQ=", "")
    if freq_part not in valid_freqs:
        raise BusinessError(
            message=f"Invalid frequency: {freq_part}. Must be one of {valid_freqs}",
            error_code=TransactionErrorCode.INVALID_RECURRENCE_RULE,
        )

    # Validate parseability with rrulestr
    try:
        rule_str = rule if rule.startswith("RRULE:") else f"RRULE:{rule}"
        rrulestr(rule_str, dtstart=datetime.now(UTC))
    except Exception as e:
        raise BusinessError(
            message=f"Invalid recurrence rule string: {e}",
            error_code=TransactionErrorCode.INVALID_RECURRENCE_RULE,
        ) from e

    return rule


def validate_transaction_type(v: str) -> str:
    """Validate transaction type.

    Raises:
        BusinessError: If the type is not one of EXPENSE/INCOME/TRANSFER.
    """
    valid_types = {"EXPENSE", "INCOME", "TRANSFER"}
    if v.upper() not in valid_types:
        raise BusinessError(
            message=f"Type must be one of: {', '.join(valid_types)}",
            error_code=CommonErrorCode.VALIDATION_ERROR,
        )
    return v.upper()


class RecurringTransactionService:
    """Service for recurring transaction operations."""

    # Safety cap for skipping exception dates recursively; prevents unbounded
    # recursion if a rule's every candidate date is excluded.
    _MAX_EXCEPTION_RECURSION = 100

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_recurring_transaction(self, user_uuid: UUID, data: dict[str, Any]) -> dict[str, Any]:
        """Create a recurring transaction rule.

        Args:
            user_uuid: User UUID
            data: Recurring transaction input data

        Returns:
            Dictionary representation of created recurring transaction
        """
        # Explicitly validate RRULE to ensure data integrity
        if "recurrence_rule" in data:
            validate_recurrence_rule(data["recurrence_rule"])

        # Validate type
        if "type" in data:
            validate_transaction_type(data["type"])

        # Validate/parse the date/account/amount inputs defensively: this
        # service receives raw dicts from the API schema and LLM tools alike,
        # and an unguarded strptime/UUID/Decimal parse would surface as a 500.
        try:
            start_date = datetime.strptime(data["start_date"], "%Y-%m-%d").date()
            end_date = datetime.strptime(data["end_date"], "%Y-%m-%d").date() if data.get("end_date") else None
            source_account_uuid = UUID(str(data["source_account_id"])) if data.get("source_account_id") else None
            target_account_uuid = UUID(str(data["target_account_id"])) if data.get("target_account_id") else None
            amount_dec = Decimal(str(data["amount"]))
        except (KeyError, ValueError, TypeError, InvalidOperation) as e:
            raise BusinessError(
                f"Invalid recurring transaction data: {e}",
                error_code=CommonErrorCode.VALIDATION_ERROR,
            ) from e

        if amount_dec <= 0:
            raise BusinessError("Amount must be greater than 0", error_code=CommonErrorCode.VALIDATION_ERROR)

        exception_dates = data.get("exception_dates", [])

        # Calculate next execution date
        next_execution = self.calculate_next_execution(
            data["recurrence_rule"],
            start_date,
            end_date,
            exception_dates,
        )

        recurring_tx = RecurringTransaction(
            user_uuid=user_uuid,
            type=data["type"],
            source_account_id=source_account_uuid,
            target_account_id=target_account_uuid,
            amount_type=data.get("amount_type", "FIXED"),
            requires_confirmation=data.get("requires_confirmation", False),
            amount=amount_dec,
            currency=data.get("currency") or PROJECT_DEFAULT_CURRENCY,
            category_key=data.get("category_key", "OTHERS"),
            tags=data.get("tags"),
            recurrence_rule=data["recurrence_rule"],
            timezone=data.get("timezone"),
            start_date=start_date,
            end_date=end_date,
            exception_dates=exception_dates,
            description=data.get("description"),
            is_active=data.get("is_active", True),
            next_execution_at=next_execution,
        )

        self.db.add(recurring_tx)
        await self.db.commit()
        await self.db.refresh(recurring_tx)

        return self._recurring_tx_to_dict(recurring_tx)

    def calculate_next_execution(
        self,
        rrule_str: str,
        start_date: date,
        end_date: date | None = None,
        exception_dates: list[str] | None = None,
        _depth: int = 0,
    ) -> datetime | None:
        """Calculate next execution date.

        Args:
            rrule_str: RRULE string (UNTIL must include UTC timezone marker Z)
            start_date: Rule start date
            end_date: Optional rule end date
            exception_dates: List of excluded date strings
            _depth: Internal recursion depth guard when skipping exception dates

        Returns:
            Next execution datetime (UTC), or None if unavailable
        """
        # Guard against unbounded recursion when every candidate date is an
        # exception (or the rule yields an endless chain of skipped dates).
        if _depth >= self._MAX_EXCEPTION_RECURSION:
            logger.warning("next_execution_exception_recursion_limit", rrule=rrule_str, start=start_date)
            return None
        try:
            # Use UTC timezone to match UNTIL in RRULE
            dtstart = datetime.combine(start_date, datetime.min.time(), tzinfo=UTC)
            rule_formatted = rrule_str if rrule_str.startswith("RRULE:") else f"RRULE:{rrule_str}"
            rrule = rrulestr(rule_formatted, dtstart=dtstart)

            now = datetime.now(UTC)
            exception_set = set(exception_dates or [])

            # Index forward from current time to prevent infinite loop over historical starting points
            next_occ = rrule.after(now, inc=False)

            # Month-End Alignment Strategy:
            # If FREQ=MONTHLY and BYMONTHDAY specified (e.g., 29, 30, 31),
            # dateutil skips months with fewer days (e.g. Feb without 31st).
            # Check for candidate dates matching the last day of the month.
            if "FREQ=MONTHLY" in rrule_str.upper() and "BYMONTHDAY=" in rrule_str.upper():
                match = re.search(r"BYMONTHDAY=(-?\d+)", rrule_str.upper())
                if match:
                    target_day = int(match.group(1))
                    if target_day > 28:
                        cur_year = now.year
                        cur_month = now.month
                        for _ in range(12):
                            max_days = calendar.monthrange(cur_year, cur_month)[1]
                            clamped_day = min(target_day, max_days)
                            cand_date = date(cur_year, cur_month, clamped_day)
                            cand_dt = datetime.combine(cand_date, datetime.min.time(), tzinfo=UTC)

                            if cand_dt > now and cand_date >= start_date:
                                if end_date and cand_date > end_date:
                                    break
                                if cand_date.isoformat() not in exception_set:
                                    if next_occ is None or cand_dt < next_occ:
                                        next_occ = cand_dt
                                    break

                            if cur_month == 12:
                                cur_year += 1
                                cur_month = 1
                            else:
                                cur_month += 1

            if next_occ is None:
                return None

            if end_date and next_occ.date() > end_date:
                return None

            if next_occ.date().isoformat() in exception_set:
                # Exception date match: skip and recursively find next valid execution
                return self.calculate_next_execution(
                    rrule_str,
                    next_occ.date(),
                    end_date,
                    exception_dates,
                    _depth=_depth + 1,
                )

            return next_occ
        except Exception as e:
            logger.warning("next_execution_calculation_failed", error=str(e))
            return None

    def _recurring_tx_to_dict(self, recurring_tx: RecurringTransaction) -> dict[str, Any]:
        """Convert RecurringTransaction model to dict response."""
        return {
            "id": str(recurring_tx.uuid),
            "user_uuid": str(recurring_tx.user_uuid),
            "type": recurring_tx.type,
            "source_account_id": str(recurring_tx.source_account_id) if recurring_tx.source_account_id else None,
            "target_account_id": str(recurring_tx.target_account_id) if recurring_tx.target_account_id else None,
            "amount_type": recurring_tx.amount_type,
            "requires_confirmation": recurring_tx.requires_confirmation,
            "amount": str(recurring_tx.amount),
            "currency": recurring_tx.currency,
            "category_key": recurring_tx.category_key,
            "tags": recurring_tx.tags,
            "recurrence_rule": recurring_tx.recurrence_rule,
            "timezone": recurring_tx.timezone,
            "start_date": recurring_tx.start_date.isoformat(),
            "end_date": recurring_tx.end_date.isoformat() if recurring_tx.end_date else None,
            "exception_dates": recurring_tx.exception_dates or [],
            "last_generated_at": recurring_tx.last_generated_at.isoformat()
            if recurring_tx.last_generated_at
            else None,
            "next_execution_at": recurring_tx.next_execution_at.isoformat()
            if recurring_tx.next_execution_at
            else None,
            "description": recurring_tx.description,
            "is_active": recurring_tx.is_active,
            "created_at": recurring_tx.created_at.isoformat(),
            "updated_at": recurring_tx.updated_at.isoformat() if recurring_tx.updated_at else None,
        }

    async def list_recurring_transactions(
        self, user_uuid: UUID, type_filter: str | None = None, is_active: bool | None = None
    ) -> list[dict[str, Any]]:
        """List recurring transactions for user.

        Args:
            user_uuid: User UUID
            type_filter: Optional type filter (EXPENSE, INCOME, TRANSFER)
            is_active: Optional active status filter

        Returns:
            List of recurring transaction dictionaries
        """
        # Construct query
        query = select(RecurringTransaction).where(RecurringTransaction.user_uuid == user_uuid)

        # Type filter
        if type_filter:
            query = query.where(RecurringTransaction.type == type_filter.upper())

        # Active status filter
        if is_active is not None:
            query = query.where(RecurringTransaction.is_active == is_active)

        # Order by created_at descending
        query = query.order_by(RecurringTransaction.created_at.desc())

        result = await self.db.execute(query)
        recurring_txs = result.scalars().all()

        return [self._recurring_tx_to_dict(tx) for tx in recurring_txs]

    async def _get_owned(self, recurring_id: UUID, user_uuid: UUID) -> RecurringTransaction | None:
        """Fetch a recurring transaction scoped to its owner."""
        query = select(RecurringTransaction).where(
            and_(
                RecurringTransaction.uuid == recurring_id,
                RecurringTransaction.user_uuid == user_uuid,
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_recurring_transaction(self, recurring_id: UUID, user_uuid: UUID) -> dict[str, Any] | None:
        """Retrieve recurring transaction detail.

        Args:
            recurring_id: Recurring transaction UUID
            user_uuid: User UUID

        Returns:
            Recurring transaction dictionary, or None if not found
        """
        recurring_tx = await self._get_owned(recurring_id, user_uuid)
        if not recurring_tx:
            return None

        return self._recurring_tx_to_dict(recurring_tx)

    async def update_recurring_transaction(
        self, recurring_id: UUID, user_uuid: UUID, data: dict[str, Any]
    ) -> dict[str, Any] | None:
        """Update recurring transaction.

        Args:
            recurring_id: Recurring transaction UUID
            user_uuid: User UUID
            data: Update dataset

        Returns:
            Updated recurring transaction dictionary, or None if not found
        """
        recurring_tx = await self._get_owned(recurring_id, user_uuid)
        if not recurring_tx:
            return None

        # Re-validate mutating fields on update — the create path validates
        # RRULE/type, but the update path previously assigned them raw.
        if "recurrence_rule" in data:
            validate_recurrence_rule(data["recurrence_rule"])
        if "type" in data:
            validate_transaction_type(data["type"])

        # Defensive parse of date/amount inputs (see create_recurring_transaction).
        try:
            if "amount" in data:
                new_amount = Decimal(str(data["amount"]))
                if new_amount <= 0:
                    raise BusinessError(
                        "Amount must be greater than 0",
                        error_code=CommonErrorCode.VALIDATION_ERROR,
                    )
                recurring_tx.amount = new_amount
            if "source_account_id" in data:
                recurring_tx.source_account_id = (
                    UUID(str(data["source_account_id"])) if data["source_account_id"] else None
                )
            if "target_account_id" in data:
                recurring_tx.target_account_id = (
                    UUID(str(data["target_account_id"])) if data["target_account_id"] else None
                )
            if "start_date" in data:
                recurring_tx.start_date = datetime.strptime(data["start_date"], "%Y-%m-%d").date()
            if "end_date" in data:
                recurring_tx.end_date = (
                    datetime.strptime(data["end_date"], "%Y-%m-%d").date() if data["end_date"] else None
                )
        except (ValueError, TypeError, InvalidOperation) as e:
            raise BusinessError(
                f"Invalid recurring transaction data: {e}",
                error_code=CommonErrorCode.VALIDATION_ERROR,
            ) from e

        # Update attributes
        if "amount_type" in data:
            recurring_tx.amount_type = data["amount_type"]
        if "requires_confirmation" in data:
            recurring_tx.requires_confirmation = data["requires_confirmation"]
        if "currency" in data:
            recurring_tx.currency = data["currency"]
        if "category_key" in data:
            recurring_tx.category_key = data["category_key"]
        if "tags" in data:
            recurring_tx.tags = data["tags"]
        if "recurrence_rule" in data:
            recurring_tx.recurrence_rule = data["recurrence_rule"]
        if "timezone" in data:
            recurring_tx.timezone = data["timezone"]
        if "exception_dates" in data:
            recurring_tx.exception_dates = data["exception_dates"]
        if "description" in data:
            recurring_tx.description = data["description"]
        if "is_active" in data:
            recurring_tx.is_active = data["is_active"]

        # Recalculate next execution date if rule, dates or active state change
        should_recalculate = any(
            key in data for key in ["recurrence_rule", "start_date", "end_date", "exception_dates", "is_active"]
        )

        if should_recalculate and recurring_tx.is_active:
            recurring_tx.next_execution_at = self.calculate_next_execution(
                recurring_tx.recurrence_rule,
                recurring_tx.start_date,
                recurring_tx.end_date,
                recurring_tx.exception_dates,
            )
        elif not recurring_tx.is_active:
            # Clear next execution date when disabled
            recurring_tx.next_execution_at = None

        recurring_tx.updated_at = utc_now()

        await self.db.commit()
        await self.db.refresh(recurring_tx)

        return self._recurring_tx_to_dict(recurring_tx)

    async def delete_recurring_transaction(self, recurring_id: UUID, user_uuid: UUID) -> bool:
        """Delete recurring transaction.

        Args:
            recurring_id: Recurring transaction UUID
            user_uuid: User UUID

        Returns:
            Boolean indicating whether deletion succeeded
        """
        recurring_tx = await self._get_owned(recurring_id, user_uuid)
        if not recurring_tx:
            return False

        await self.db.delete(recurring_tx)
        await self.db.commit()

        return True

    def parse_rrule_occurrences(
        self,
        rrule_string: str,
        start_date: date,
        end_date: date | None,
        forecast_start: date,
        forecast_end: date,
    ) -> list[date]:
        """Parse RRULE and generate dates within specified range.

        Args:
            rrule_string: RRULE string (UNTIL must include UTC timezone marker Z)
            start_date: Rule start date
            end_date: Rule end date
            forecast_start: Forecast start date
            forecast_end: Forecast end date

        Returns:
            List of occurrence dates
        """
        try:
            dtstart = datetime.combine(start_date, datetime.min.time(), tzinfo=UTC)
            rrule = rrulestr(rrule_string, dtstart=dtstart)

            actual_end = forecast_end
            if end_date and end_date < forecast_end:
                actual_end = end_date

            occurrences = []

            # Jump directly into the forecast window with rrule.between() instead of
            # iterating from dtstart. The old loop consumed its 1000-iteration budget on
            # occurrences before forecast_start, silently dropping ALL recurring events
            # for rules older than ~1000 days (e.g. a 3-year-old DAILY rule).
            start_dt = datetime.combine(forecast_start, datetime.min.time(), tzinfo=UTC)
            end_dt = datetime.combine(actual_end + timedelta(days=1), datetime.min.time(), tzinfo=UTC)
            occurrences = [d.date() for d in rrule.between(start_dt, end_dt, inc=False)]

            # between(inc=False) is exclusive on the lower bound; preserve the original
            # semantics of including forecast_start itself when it is an occurrence.
            if start_dt in rrule and (not occurrences or occurrences[0] != forecast_start):
                occurrences.insert(0, forecast_start)

            return occurrences
        except Exception as e:
            logger.error("rrule_parse_failed", rrule=rrule_string, error=str(e))
            return []
