"""Service for budget period management operations."""

from __future__ import annotations

from calendar import monthrange
from datetime import (
    UTC,
    date,
    datetime as dt_datetime,
    time as dt_time,
    timedelta,
)
from decimal import Decimal
from uuid import UUID

from sqlalchemy import desc, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.budget import (
    Budget,
    BudgetPeriod,
    BudgetPeriodStatus,
    BudgetPeriodType,
    BudgetSettings,
)
from app.models.transaction import Transaction

# Default threshold values used when no BudgetSettings row exists yet.
# These match the DB column defaults and avoid a write on the read path.
_DEFAULT_WARNING_THRESHOLD = 70
_DEFAULT_ALERT_THRESHOLD = 90


def _date_range_to_dt(period_start: date, period_end: date) -> tuple[dt_datetime, dt_datetime]:
    """Convert an inclusive date range to a half-open [start, end) datetime range.

    Using direct column comparisons (no func.date() wrapping) allows the
    B-tree index on transaction_at to be used efficiently.
    """
    start_dt = dt_datetime.combine(period_start, dt_time.min, tzinfo=UTC)
    end_dt = dt_datetime.combine(period_end + timedelta(days=1), dt_time.min, tzinfo=UTC)
    return start_dt, end_dt


class BudgetPeriodService:
    """Service for budget period management operations."""

    def __init__(self, session: AsyncSession):
        self.session = session

    # ========================================================================
    # Period Management
    # ========================================================================

    async def _get_current_period(self, budget: Budget) -> BudgetPeriod | None:
        """Get current active period for a budget."""
        today = date.today()

        result = await self.session.execute(
            select(BudgetPeriod).where(
                BudgetPeriod.budget_id == budget.id,
                BudgetPeriod.period_start <= today,
                BudgetPeriod.period_end >= today,
            )
        )
        return result.scalar_one_or_none()

    async def get_or_create_current_period(self, budget: Budget) -> BudgetPeriod:
        """Get current period, creating if necessary.

        Handles rollover from previous period, capping surplus at >= 0 to prevent
        deficit debt compounding. Iteratively fills missing intermediate periods
        if multiple periods have elapsed.
        """
        current_period = await self._get_current_period(budget)

        if current_period:
            return current_period

        today = date.today()

        # Get latest existing period for rollover
        result = await self.session.execute(
            select(BudgetPeriod)
            .where(BudgetPeriod.budget_id == budget.id)
            .order_by(desc(BudgetPeriod.period_end))
            .limit(1)
        )
        prev_period = result.scalar_one_or_none()

        # Sequentially step forward through missing periods if inactive across multi-period gaps
        if prev_period and prev_period.period_end < today:
            reference_date = prev_period.period_end + timedelta(days=1)
            while reference_date <= today:
                p_start, p_end = self._calculate_period_range(
                    budget.period_type, budget.period_anchor_day, reference_date
                )

                # Check if intermediate period exists
                check_res = await self.session.execute(
                    select(BudgetPeriod).where(
                        BudgetPeriod.budget_id == budget.id,
                        BudgetPeriod.period_start == p_start,
                    )
                )
                existing_p = check_res.scalar_one_or_none()
                if existing_p:
                    prev_period = existing_p
                    reference_date = p_end + timedelta(days=1)
                    continue

                rollover_in = Decimal("0")
                if budget.rollover_enabled and prev_period:
                    unused = prev_period.adjusted_target - prev_period.spent_amount
                    surplus = max(unused, Decimal("0"))
                    rollover_in = surplus
                    prev_period.rollover_out = surplus
                    budget.rollover_balance = budget.rollover_balance + surplus

                new_period = BudgetPeriod(
                    budget_id=budget.id,
                    period_start=p_start,
                    period_end=p_end,
                    spent_amount=Decimal("0"),
                    rollover_in=rollover_in,
                    rollover_out=Decimal("0"),
                    adjusted_target=budget.amount + rollover_in,
                    status=BudgetPeriodStatus.ON_TRACK.value,
                )

                try:
                    # Nested transaction: on IntegrityError only the savepoint is
                    # rolled back, so caller modifications (e.g. rebalance amount
                    # adjustments) made in the outer transaction survive.
                    async with self.session.begin_nested():
                        self.session.add(new_period)
                        await self.session.flush()
                    await self.session.commit()
                    prev_period = new_period
                except IntegrityError:
                    ex_res = await self.session.execute(
                        select(BudgetPeriod).where(
                            BudgetPeriod.budget_id == budget.id,
                            BudgetPeriod.period_start == p_start,
                        )
                    )
                    prev_period = ex_res.scalar_one_or_none() or prev_period

                reference_date = p_end + timedelta(days=1)

            final_period = await self._get_current_period(budget)
            if final_period:
                return final_period

        # Initial period creation
        period_start, period_end = self._calculate_period_range(budget.period_type, budget.period_anchor_day, today)
        initial_period = BudgetPeriod(
            budget_id=budget.id,
            period_start=period_start,
            period_end=period_end,
            spent_amount=Decimal("0"),
            rollover_in=Decimal("0"),
            rollover_out=Decimal("0"),
            adjusted_target=budget.amount,
            status=BudgetPeriodStatus.ON_TRACK.value,
        )

        try:
            # Nested transaction: IntegrityError only rolls back the savepoint,
            # preserving caller modifications in the outer transaction.
            async with self.session.begin_nested():
                self.session.add(initial_period)
                await self.session.flush()
            await self.session.commit()
            return initial_period
        except IntegrityError:
            existing = await self._get_current_period(budget)
            if existing:
                return existing
            raise

    def _calculate_period_range(
        self,
        period_type: str,
        anchor_day: int,
        reference_date: date,
    ) -> tuple[date, date]:
        """Calculate period start and end dates.

        Args:
            period_type: WEEKLY, BIWEEKLY, MONTHLY, or YEARLY
            anchor_day: Day of period to anchor on
            reference_date: Reference date to calculate from

        Returns:
            Tuple of (period_start, period_end)
        """
        if period_type == BudgetPeriodType.MONTHLY.value:
            # Monthly: anchor_day to anchor_day-1 next month
            year = reference_date.year
            month = reference_date.month

            # Clamp anchor_day to valid day in month
            max_day = monthrange(year, month)[1]
            actual_anchor = min(anchor_day, max_day)

            if reference_date.day >= actual_anchor:
                # Current period started this month
                period_start = date(year, month, actual_anchor)
                # End is next month
                if month == 12:
                    next_year, next_month = year + 1, 1
                else:
                    next_year, next_month = year, month + 1
                next_max_day = monthrange(next_year, next_month)[1]
                next_anchor = min(anchor_day, next_max_day)
                period_end = date(next_year, next_month, next_anchor) - timedelta(days=1)
            else:
                # Current period started last month
                if month == 1:
                    prev_year, prev_month = year - 1, 12
                else:
                    prev_year, prev_month = year, month - 1
                prev_max_day = monthrange(prev_year, prev_month)[1]
                prev_anchor = min(anchor_day, prev_max_day)
                period_start = date(prev_year, prev_month, prev_anchor)
                period_end = date(year, month, actual_anchor) - timedelta(days=1)

        elif period_type == BudgetPeriodType.WEEKLY.value:
            # Weekly: anchor_day is day of week (1=Monday, 7=Sunday)
            days_since_anchor = (reference_date.weekday() - (anchor_day - 1)) % 7
            period_start = reference_date - timedelta(days=days_since_anchor)
            period_end = period_start + timedelta(days=6)

        elif period_type == BudgetPeriodType.BIWEEKLY.value:
            # Biweekly: every 2 weeks starting from anchor_day
            days_since_anchor = (reference_date.weekday() - (anchor_day - 1)) % 7
            period_start = reference_date - timedelta(days=days_since_anchor)
            # Adjust to 2-week cycle (use week number)
            week_num = period_start.isocalendar()[1]
            if week_num % 2 == 1:
                period_start -= timedelta(days=7)
            period_end = period_start + timedelta(days=13)

        elif period_type == BudgetPeriodType.YEARLY.value:
            # Yearly: Jan 1 to Dec 31
            period_start = date(reference_date.year, 1, 1)
            period_end = date(reference_date.year, 12, 31)

        else:
            # Default to monthly
            period_start = date(reference_date.year, reference_date.month, 1)
            period_end = date(
                reference_date.year + (1 if reference_date.month == 12 else 0), (reference_date.month % 12) + 1, 1
            ) - timedelta(days=1)

        return period_start, period_end

    # ========================================================================
    # Spending Calculation
    # ========================================================================

    async def calculate_spent_amount(
        self,
        user_uuid: UUID,
        period_start: date,
        period_end: date,
        category_key: str | None = None,
    ) -> Decimal:
        """Calculate total spending for a period.

        Args:
            user_uuid: User UUID
            period_start: Period start date
            period_end: Period end date
            category_key: Optional category filter

        Returns:
            Total spent amount
        """
        start_dt, end_dt = _date_range_to_dt(period_start, period_end)
        query = select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.user_uuid == user_uuid,
            Transaction.type == "EXPENSE",
            Transaction.status == "CLEARED",
            Transaction.transaction_at >= start_dt,
            Transaction.transaction_at < end_dt,
        )

        if category_key:
            query = query.where(Transaction.category_key == category_key)

        result = await self.session.execute(query)
        spent = result.scalar_one()
        # Design intent: Amount is stored as a positive value; transaction type distinguishes income/expense.
        # Use abs() to ensure compatibility with potential historical negative values.
        return abs(Decimal(str(spent))) if spent else Decimal("0")

    async def update_period_spent_amount(
        self,
        budget: Budget,
        period: BudgetPeriod,
        *,
        auto_commit: bool = True,
    ) -> BudgetPeriod:
        """Update spent amount and status for a period.

        Args:
            budget: The budget instance.
            period: The budget period to update.
            auto_commit: Whether to commit immediately. Set to False when
                calling in a loop to batch commits for better performance.
        """
        spent = await self.calculate_spent_amount(
            budget.owner_uuid,
            period.period_start,
            period.period_end,
            budget.category_key,
        )

        period.spent_amount = spent

        # Read thresholds without triggering a write on the read path
        settings = await self._get_settings(budget.owner_uuid)
        warning_threshold = settings.warning_threshold if settings else _DEFAULT_WARNING_THRESHOLD
        alert_threshold = settings.alert_threshold if settings else _DEFAULT_ALERT_THRESHOLD
        usage_pct = period.usage_percentage

        if spent > period.adjusted_target:
            period.status = BudgetPeriodStatus.EXCEEDED.value
        elif usage_pct >= alert_threshold:
            period.status = BudgetPeriodStatus.EXCEEDED.value
        elif usage_pct >= warning_threshold:
            period.status = BudgetPeriodStatus.WARNING.value
        else:
            period.status = BudgetPeriodStatus.ON_TRACK.value

        if auto_commit:
            await self.session.commit()
        return period

    # ========================================================================
    # Settings (shared read-only lookup)
    # ========================================================================

    async def _get_settings(self, user_uuid: UUID) -> BudgetSettings | None:
        """Read-only settings lookup. Returns None if no row exists.

        Used on the hot read path (update_period_spent_amount) to avoid
        triggering an implicit write/commit when the settings row is absent.
        """
        result = await self.session.execute(select(BudgetSettings).where(BudgetSettings.user_uuid == user_uuid))
        return result.scalar_one_or_none()
