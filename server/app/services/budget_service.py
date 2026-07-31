"""Budget service for managing budgets and budget periods."""

from __future__ import annotations

from calendar import monthrange
from datetime import (
    UTC,
    date,
    datetime as dt_datetime,
    time as dt_time,
    timedelta,
    timezone,
)
from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import asc, desc, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.logging import logger
from app.models.budget import (
    Budget,
    BudgetPeriod,
    BudgetPeriodStatus,
    BudgetPeriodType,
    BudgetScope,
    BudgetSettings,
    BudgetSource,
    BudgetStatus,
    BudgetType,
)
from app.models.transaction import Transaction
from app.schemas.budget import (
    BudgetAlert,
    BudgetCreateRequest,
    BudgetResponse,
    BudgetSettingsUpdateRequest,
    BudgetSuggestion,
    BudgetSummaryResponse,
    BudgetUpdateRequest,
)

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


class BudgetService:
    """Service for budget management operations."""

    def __init__(self, session: AsyncSession):
        self.session = session

    # ========================================================================
    # CRUD Operations
    # ========================================================================

    async def create_budget(
        self,
        user_uuid: UUID,
        request: BudgetCreateRequest,
        source: BudgetSource = BudgetSource.USER_DEFINED,
        ai_confidence: float | None = None,
    ) -> Budget:
        """Create a new budget.

        Args:
            user_uuid: User UUID
            request: Budget creation request
            source: Creation source (AI or user)
            ai_confidence: AI confidence score if AI-suggested

        Returns:
            Created budget
        """
        # Generate name if not provided
        name = request.name
        if not name:
            if request.scope == BudgetScope.TOTAL:
                # Use a stable key instead of a human-readable English string
                name = "TOTAL"
            else:
                # Use category key as the default name
                name = request.category_key or "CATEGORY"

        budget = Budget(
            owner_uuid=user_uuid,
            name=name,
            type=BudgetType.EXPENSE_LIMIT.value,
            scope=request.scope.value if isinstance(request.scope, BudgetScope) else request.scope,
            category_key=request.category_key,
            amount=request.amount,
            currency_code=request.currency_code,
            period_type=request.period_type.value
            if isinstance(request.period_type, BudgetPeriodType)
            else request.period_type,
            period_anchor_day=request.period_anchor_day,
            rollover_enabled=request.rollover_enabled,
            source=source.value if isinstance(source, BudgetSource) else source,
            ai_confidence=Decimal(str(ai_confidence)) if ai_confidence else None,
            status=BudgetStatus.ACTIVE.value,
        )

        self.session.add(budget)
        await self.session.flush()

        # Create initial period
        period_start, period_end = self._calculate_period_range(
            budget.period_type, budget.period_anchor_day, date.today()
        )

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

        self.session.add(initial_period)
        await self.session.commit()
        await self.session.refresh(budget)

        # Ensure a BudgetSettings row exists so threshold lookups never write on the read path
        await self._ensure_settings_exists(user_uuid)

        logger.info(
            "budget_created",
            budget_id=str(budget.id),
            user_uuid=str(user_uuid),
            scope=budget.scope,
            category_key=budget.category_key,
            amount=str(budget.amount),
        )

        return budget

    async def get_budget(self, budget_id: UUID, user_uuid: UUID) -> Budget | None:
        """Get a budget by ID.

        Args:
            budget_id: Budget ID
            user_uuid: User UUID for authorization

        Returns:
            Budget or None if not found
        """
        result = await self.session.execute(
            select(Budget)
            .options(selectinload(Budget.periods))
            .where(Budget.id == budget_id, Budget.owner_uuid == user_uuid)
        )
        return result.scalar_one_or_none()

    async def get_user_budgets(
        self,
        user_uuid: UUID,
        status: BudgetStatus | None = None,
        scope: BudgetScope | None = None,
    ) -> list[Budget]:
        """Get all budgets for a user.

        Args:
            user_uuid: User UUID
            status: Optional status filter
            scope: Optional scope filter

        Returns:
            List of budgets
        """
        query = select(Budget).options(selectinload(Budget.periods)).where(Budget.owner_uuid == user_uuid)

        if status:
            query = query.where(Budget.status == status.value)
        if scope:
            query = query.where(Budget.scope == scope.value)

        query = query.order_by(asc(Budget.scope), asc(Budget.category_key))

        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def update_budget(
        self,
        budget_id: UUID,
        user_uuid: UUID,
        request: BudgetUpdateRequest,
    ) -> Budget | None:
        """Update a budget.

        Args:
            budget_id: Budget ID
            user_uuid: User UUID for authorization
            request: Update request

        Returns:
            Updated budget or None
        """
        budget = await self.get_budget(budget_id, user_uuid)
        if not budget:
            return None

        # Update fields
        if request.name is not None:
            budget.name = request.name
        if request.amount is not None:
            budget.amount = request.amount
            # Also update current period's adjusted target
            current_period = await self._get_current_period(budget)
            if current_period:
                current_period.adjusted_target = request.amount + current_period.rollover_in
        if request.rollover_enabled is not None:
            budget.rollover_enabled = request.rollover_enabled
        if request.status is not None:
            budget.status = request.status.value if isinstance(request.status, BudgetStatus) else request.status
        if request.period_anchor_day is not None:
            budget.period_anchor_day = request.period_anchor_day

        await self.session.commit()
        await self.session.refresh(budget)

        logger.info(
            "budget_updated",
            budget_id=str(budget_id),
            user_uuid=str(user_uuid),
        )

        return budget

    async def delete_budget(self, budget_id: UUID, user_uuid: UUID) -> bool:
        """Delete a budget.

        Args:
            budget_id: Budget ID
            user_uuid: User UUID for authorization

        Returns:
            True if deleted, False if not found
        """
        budget = await self.get_budget(budget_id, user_uuid)
        if not budget:
            return False

        await self.session.delete(budget)
        await self.session.commit()

        logger.info(
            "budget_deleted",
            budget_id=str(budget_id),
            user_uuid=str(user_uuid),
        )

        return True

    async def rebalance_with_status(
        self,
        from_budget_id: UUID,
        to_budget_id: UUID,
        amount: Decimal,
        user_uuid: UUID,
    ) -> str:
        """Rebalance amount between two budgets with detailed status code.

        Returns:
            'SUCCESS', 'INVALID_AMOUNT', 'NOT_FOUND', or 'INSUFFICIENT_FUNDS'
        """
        if amount <= 0:
            return "INVALID_AMOUNT"

        from_budget = await self.get_budget(from_budget_id, user_uuid)
        to_budget = await self.get_budget(to_budget_id, user_uuid)

        if not from_budget or not to_budget:
            return "NOT_FOUND"

        if from_budget.amount < amount:
            return "INSUFFICIENT_FUNDS"

        # Update budget amounts
        from_budget.amount -= amount
        to_budget.amount += amount

        # Also update current periods
        from_period = await self.get_or_create_current_period(from_budget)
        to_period = await self.get_or_create_current_period(to_budget)

        if from_period:
            from_period.adjusted_target -= amount
            await self.update_period_spent_amount(from_budget, from_period, auto_commit=False)

        if to_period:
            to_period.adjusted_target += amount
            await self.update_period_spent_amount(to_budget, to_period, auto_commit=False)

        await self.session.commit()

        logger.info(
            "budget_rebalanced",
            from_budget_id=str(from_budget_id),
            to_budget_id=str(to_budget_id),
            amount=str(amount),
            user_uuid=str(user_uuid),
        )

        return "SUCCESS"

    async def rebalance(
        self,
        from_budget_id: UUID,
        to_budget_id: UUID,
        amount: Decimal,
        user_uuid: UUID,
    ) -> bool:
        """Rebalance amount between two budgets."""
        status_code = await self.rebalance_with_status(from_budget_id, to_budget_id, amount, user_uuid)
        return status_code == "SUCCESS"

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
                    self.session.add(new_period)
                    await self.session.commit()
                    await self.session.refresh(new_period)
                    prev_period = new_period
                except IntegrityError:
                    await self.session.rollback()
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
            self.session.add(initial_period)
            await self.session.commit()
            await self.session.refresh(initial_period)
            return initial_period
        except IntegrityError:
            await self.session.rollback()
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
    # Budget Summary
    # ========================================================================

    async def get_budget_summary(
        self,
        user_uuid: UUID,
        include_paused: bool = False,
    ) -> BudgetSummaryResponse:
        """Get budget summary for a user.

        Args:
            user_uuid: User UUID
            include_paused: If True, also include paused budgets

        Returns all active (and optionally paused) budgets with current period status.
        """
        # Fetch active budgets
        budgets = await self.get_user_budgets(user_uuid, status=BudgetStatus.ACTIVE)

        # Include paused budgets if requested
        if include_paused:
            paused_budgets = await self.get_user_budgets(user_uuid, status=BudgetStatus.PAUSED)
            budgets = list(budgets) + list(paused_budgets)

        total_budget_response = None
        category_budgets = []
        alerts = []
        category_spent = Decimal("0")
        category_target = Decimal("0")
        period_start = None
        period_end = None

        for budget in budgets:
            period = await self.get_or_create_current_period(budget)
            period = await self.update_period_spent_amount(budget, period, auto_commit=False)

            response = await self.build_budget_response(budget, period)

            if budget.is_total_budget:
                total_budget_response = response
                period_start = period.period_start
                period_end = period.period_end
            else:
                category_budgets.append(response)
                category_spent += period.spent_amount
                category_target += period.adjusted_target

            # Generate alerts
            if period.status == BudgetPeriodStatus.EXCEEDED.value:
                over_amt = period.spent_amount - period.adjusted_target
                alerts.append(
                    BudgetAlert(
                        budget_id=budget.id,
                        budget_name=budget.name,
                        category_key=budget.category_key,
                        alert_type="exceeded",
                        message=f"budget.alert.exceeded|overAmount={over_amt:.2f}",
                        usage_percentage=period.usage_percentage,
                        remaining_amount=str(period.remaining_amount),
                    )
                )
            elif period.status == BudgetPeriodStatus.WARNING.value:
                alerts.append(
                    BudgetAlert(
                        budget_id=budget.id,
                        budget_name=budget.name,
                        category_key=budget.category_key,
                        alert_type="warning",
                        message=f"budget.alert.warning|pct={period.usage_percentage:.0f}|remaining={period.remaining_amount:.2f}",
                        usage_percentage=period.usage_percentage,
                        remaining_amount=str(period.remaining_amount),
                    )
                )

        # Use total budget figures if available to prevent double counting with category budgets
        if total_budget_response:
            overall_spent = Decimal(total_budget_response.spent_amount)
            overall_remaining = Decimal(total_budget_response.remaining_amount)
            overall_pct = total_budget_response.usage_percentage
        else:
            overall_spent = category_spent
            overall_remaining = category_target - category_spent
            overall_pct = float(category_spent / category_target * 100) if category_target > 0 else 0.0

        # Batch commit all period updates at once
        await self.session.commit()

        return BudgetSummaryResponse(
            total_budget=total_budget_response,
            category_budgets=category_budgets,
            overall_spent=str(overall_spent),
            overall_remaining=str(overall_remaining),
            overall_percentage=overall_pct,
            alerts=alerts,
            period_start=period_start,
            period_end=period_end,
        )

    async def build_budget_response(
        self,
        budget: Budget,
        period: BudgetPeriod,
    ) -> BudgetResponse:
        """Build response object for a budget.

        Monetary values are serialized as strings to preserve Decimal precision.
        """
        return BudgetResponse(
            id=budget.id,
            name=budget.name,
            scope=budget.scope,
            category_key=budget.category_key,
            amount=str(budget.amount),
            currency_code=budget.currency_code,
            period_type=budget.period_type,
            period_anchor_day=budget.period_anchor_day,
            rollover_enabled=budget.rollover_enabled,
            rollover_balance=str(budget.rollover_balance),
            source=budget.source,
            ai_confidence=float(budget.ai_confidence) if budget.ai_confidence else None,
            status=budget.status,
            spent_amount=str(period.spent_amount),
            remaining_amount=str(period.remaining_amount),
            usage_percentage=period.usage_percentage,
            period_status=period.status,
            period_start=period.period_start,
            period_end=period.period_end,
            ai_forecast=str(period.ai_forecast) if period.ai_forecast else None,
            created_at=budget.created_at.isoformat() if isinstance(budget.created_at, dt_datetime) else None,
            updated_at=budget.updated_at.isoformat() if isinstance(budget.updated_at, dt_datetime) else None,
        )

    # ========================================================================
    # AI Suggestions
    # ========================================================================

    async def suggest_budget(
        self,
        user_uuid: UUID,
        category_key: str | None = None,
        months: int = 3,
    ) -> BudgetSuggestion:
        """Generate AI budget suggestion based on historical data.

        Args:
            user_uuid: User UUID
            category_key: Optional category for category-specific suggestion
            months: Number of months to analyze

        Returns:
            Budget suggestion
        """
        # Calculate date range
        end_date = date.today()
        start_date = end_date - timedelta(days=months * 30)
        start_dt, end_dt = _date_range_to_dt(start_date, end_date)

        # Get historical spending
        query = select(
            func.sum(Transaction.amount).label("total"),
            func.count(Transaction.id).label("tx_count"),
            func.avg(Transaction.amount).label("avg"),
        ).where(
            Transaction.user_uuid == user_uuid,
            Transaction.type == "EXPENSE",
            Transaction.status == "CLEARED",
            Transaction.transaction_at >= start_dt,
            Transaction.transaction_at < end_dt,
        )

        if category_key:
            query = query.where(Transaction.category_key == category_key)

        result = await self.session.execute(query)
        row = result.one()

        total_spent = Decimal(str(row.total or 0))
        tx_count_val = row.tx_count or 0

        if tx_count_val == 0:
            # No historical data - return structured reasoning for frontend to translate
            return BudgetSuggestion(
                scope=BudgetScope.CATEGORY.value if category_key else BudgetScope.TOTAL.value,
                category_key=category_key,
                suggested_amount="0",
                confidence=0.0,
                # Structured format: key|data for frontend interpolation
                reasoning="budget.suggestion.noData",
                based_on_months=months,
            )

        # Calculate monthly average
        monthly_avg = total_spent / months

        # Add buffer (10-20% based on variance)
        buffer_pct = Decimal("1.15")  # 15% buffer
        suggested_amount = monthly_avg * buffer_pct

        # Calculate confidence based on data quantity
        # More transactions = higher confidence
        confidence = min(0.95, 0.5 + (float(tx_count_val) / 100.0) * 0.45)

        scope = BudgetScope.CATEGORY.value if category_key else BudgetScope.TOTAL.value

        # Return structured reasoning with numeric data
        # Frontend can use: t.budget.suggestion.reasoning({months, monthlyAvg, suggestedAmount})
        reasoning = f"budget.suggestion.reasoning|months={months}|monthlyAvg={monthly_avg:.0f}|suggestedAmount={suggested_amount:.0f}"

        return BudgetSuggestion(
            scope=scope,
            category_key=category_key,
            suggested_amount=str(suggested_amount),
            confidence=confidence,
            reasoning=reasoning,
            based_on_months=months,
        )

    async def detect_problem_categories(
        self,
        user_uuid: UUID,
        months: int = 3,
    ) -> list[str]:
        """Detect categories with high variance that might benefit from budgeting.

        Args:
            user_uuid: User UUID
            months: Number of months to analyze

        Returns:
            List of category keys with high variance
        """
        end_date = date.today()
        start_date = end_date - timedelta(days=months * 30)
        start_dt, end_dt = _date_range_to_dt(start_date, end_date)

        # Get spending by category and month
        query = (
            select(
                Transaction.category_key,
                func.sum(Transaction.amount).label("total"),
                func.count(Transaction.id).label("count"),
            )
            .where(
                Transaction.user_uuid == user_uuid,
                Transaction.type == "EXPENSE",
                Transaction.status == "CLEARED",
                Transaction.transaction_at >= start_dt,
                Transaction.transaction_at < end_dt,
            )
            .group_by(Transaction.category_key)
            .having(func.count(Transaction.id) >= 5)  # At least 5 transactions
            .order_by(desc(func.sum(Transaction.amount)))
        )

        result = await self.session.execute(query)
        rows = result.all()

        # Return top categories by spending
        problem_categories = []
        for row in rows[:5]:  # Top 5 categories
            if row.category_key:
                problem_categories.append(row.category_key)

        return problem_categories

    # ========================================================================
    # Settings
    # ========================================================================

    async def _get_settings(self, user_uuid: UUID) -> BudgetSettings | None:
        """Read-only settings lookup. Returns None if no row exists.

        Used on the hot read path (update_period_spent_amount) to avoid
        triggering an implicit write/commit when the settings row is absent.
        """
        result = await self.session.execute(select(BudgetSettings).where(BudgetSettings.user_uuid == user_uuid))
        return result.scalar_one_or_none()

    async def _ensure_settings_exists(self, user_uuid: UUID) -> BudgetSettings:
        """Create default settings row if it does not exist.

        Called only on write paths (create_budget, update_settings).
        Uses IntegrityError protection for concurrent first-time creation.
        """
        settings = await self._get_settings(user_uuid)
        if settings:
            return settings

        settings = BudgetSettings(user_uuid=user_uuid)
        try:
            self.session.add(settings)
            await self.session.commit()
            await self.session.refresh(settings)
        except IntegrityError:
            await self.session.rollback()
            existing = await self._get_settings(user_uuid)
            if existing:
                return existing
            raise
        return settings

    async def get_or_create_settings(self, user_uuid: UUID) -> BudgetSettings:
        """Public API: get or create budget settings for a user.

        Used by the /settings/me endpoints where a write is acceptable.
        """
        return await self._ensure_settings_exists(user_uuid)

    async def update_settings(
        self,
        user_uuid: UUID,
        request: BudgetSettingsUpdateRequest,
    ) -> BudgetSettings:
        """Update budget settings."""
        settings = await self._ensure_settings_exists(user_uuid)

        for field, value in request.model_dump(exclude_unset=True).items():
            if value is not None:
                setattr(settings, field, value)

        await self.session.commit()
        await self.session.refresh(settings)

        return settings
