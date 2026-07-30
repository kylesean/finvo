from datetime import UTC, datetime, timedelta
from decimal import Decimal
from typing import Any, cast as type_cast
from uuid import UUID

from sqlalchemy import and_, case, desc, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction
from app.schemas.statistics import (
    CashFlowResponse,
    CategoryBreakdownItem,
    CategoryBreakdownResponse,
    HealthScoreDimension,
    HealthScoreResponse,
    StatisticsOverviewResponse,
    TopTransactionItem,
    TopTransactionsResponse,
    TrendDataPoint,
    TrendDataResponse,
)
from app.utils.currency_utils import get_user_display_currency


class StatisticsService:
    """Service for calculating financial statistics."""

    def __init__(self, db: AsyncSession):
        self.db = db

    def _build_account_filter(
        self,
        user_uuid: UUID,
        account_types: list[str] | None,
    ) -> Any:
        """Build account type filter subquery if account_types is provided."""
        if not account_types:
            return None
        # Return a subquery for filtering by account type
        return select(FinancialAccount.id).where(
            FinancialAccount.user_uuid == user_uuid,
            FinancialAccount.type.in_(account_types),
        )

    def _calc_change_percent(self, prev: Decimal, current: Decimal) -> float:
        """Safely calculate change percentage between two values."""
        if prev == 0 and current == 0:
            return 0.0
        if prev == 0:
            return 100.0 if current > 0 else -100.0
        return float((current - prev) / abs(prev) * 100)

    def _get_date_range(
        self,
        time_range: str,
        start_date: str | None = None,
        end_date: str | None = None,
        tz_offset_minutes: int | None = None,
    ) -> tuple[datetime, datetime]:
        """Calculate date range based on time_range parameter and optional client timezone offset."""
        now_utc = datetime.now(UTC)

        if tz_offset_minutes is not None:
            # Shift UTC now to client local time for boundary calculations
            local_now = now_utc + timedelta(minutes=tz_offset_minutes)
        else:
            local_now = now_utc

        if time_range == "week":
            # Start of current week (Monday) to end of current week (Sunday) in local time
            local_start = local_now - timedelta(days=local_now.weekday())
            local_start = local_start.replace(hour=0, minute=0, second=0, microsecond=0)
            local_end = local_start + timedelta(days=6, hours=23, minutes=59, seconds=59, microseconds=999999)
        elif time_range == "month":
            local_start = local_now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            if local_now.month == 12:
                next_month = local_now.replace(year=local_now.year + 1, month=1, day=1)
            else:
                next_month = local_now.replace(month=local_now.month + 1, day=1)
            local_end = next_month - timedelta(microseconds=1)
        elif time_range == "year":
            local_start = local_now.replace(month=1, day=1, hour=0, minute=0, second=0, microsecond=0)
            local_end = local_now.replace(month=12, day=31, hour=23, minute=59, second=59, microsecond=999999)
        elif time_range == "custom" and start_date and end_date:
            start_utc = datetime.fromisoformat(start_date.replace("Z", "+00:00"))
            end_utc = datetime.fromisoformat(end_date.replace("Z", "+00:00"))
            return start_utc, end_utc
        else:
            local_start = local_now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            if local_now.month == 12:
                next_month = local_now.replace(year=local_now.year + 1, month=1, day=1)
            else:
                next_month = local_now.replace(month=local_now.month + 1, day=1)
            local_end = next_month - timedelta(microseconds=1)

        if tz_offset_minutes is not None:
            # Convert local boundaries back to UTC
            start_utc = local_start - timedelta(minutes=tz_offset_minutes)
            end_utc = local_end - timedelta(minutes=tz_offset_minutes)
        else:
            start_utc = local_start
            end_utc = local_end

        return start_utc, end_utc

    def _get_previous_period_range(
        self,
        start: datetime,
        end: datetime,
    ) -> tuple[datetime, datetime]:
        """Get the previous period range for comparison."""
        duration = end - start
        prev_end = start - timedelta(seconds=1)
        prev_start = prev_end - duration
        return prev_start, prev_end

    async def get_overview(
        self,
        user_uuid: UUID,
        time_range: str = "month",
        start_date: str | None = None,
        end_date: str | None = None,
        account_types: list[str] | None = None,
        tz_offset_minutes: int | None = None,
    ) -> StatisticsOverviewResponse:
        """Get statistics overview for the period."""
        period_start, period_end = self._get_date_range(time_range, start_date, end_date, tz_offset_minutes)
        prev_start, prev_end = self._get_previous_period_range(period_start, period_end)

        # Build base query conditions
        base_conditions: list[Any] = [
            Transaction.user_uuid == user_uuid,
            Transaction.transaction_at >= period_start,
            Transaction.transaction_at <= period_end,
        ]

        # Apply account type filter if specified
        account_filter = self._build_account_filter(user_uuid, account_types)
        if account_filter is not None:
            base_conditions.append(Transaction.source_account_id.in_(account_filter))

        # Single-query conditional aggregation for income and expense
        totals_query = select(
            func.coalesce(
                func.sum(case((Transaction.type == "INCOME", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("income"),
            func.coalesce(
                func.sum(case((Transaction.type == "EXPENSE", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("expense"),
        ).where(and_(*[c for c in base_conditions]))

        totals_result = await self.db.execute(totals_query)
        totals_row = totals_result.one()

        total_income = Decimal(str(totals_row.income or 0))
        total_expense = Decimal(str(totals_row.expense or 0))

        # Get total balance from financial accounts
        balance_conditions: list[Any] = [
            FinancialAccount.user_uuid == user_uuid,
            FinancialAccount.status == "ACTIVE",
            FinancialAccount.include_in_net_worth == True,  # noqa: E712
        ]
        # Also filter balance by account types if specified
        if account_types:
            balance_conditions.append(FinancialAccount.type.in_(account_types))

        balance_query = select(
            func.coalesce(
                func.sum(
                    case(
                        (FinancialAccount.nature == "ASSET", FinancialAccount.current_balance),
                        else_=-FinancialAccount.current_balance,
                    )
                ),
                0,
            )
        ).where(and_(*[cond for cond in balance_conditions]))
        balance_result = await self.db.execute(balance_query)
        total_balance = Decimal(str(balance_result.scalar() or 0))

        # Calculate previous period for comparison with single-query conditional aggregation
        prev_conditions: list[Any] = [
            Transaction.user_uuid == user_uuid,
            Transaction.transaction_at >= prev_start,
            Transaction.transaction_at <= prev_end,
        ]
        if account_filter is not None:
            prev_conditions.append(Transaction.source_account_id.in_(account_filter))

        prev_totals_query = select(
            func.coalesce(
                func.sum(case((Transaction.type == "INCOME", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("income"),
            func.coalesce(
                func.sum(case((Transaction.type == "EXPENSE", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("expense"),
        ).where(and_(*[c for c in prev_conditions]))

        prev_totals_result = await self.db.execute(prev_totals_query)
        prev_totals_row = prev_totals_result.one()

        prev_income = Decimal(str(prev_totals_row.income or 0))
        prev_expense = Decimal(str(prev_totals_row.expense or 0))

        # Amounts are already in user's base currency - no conversion needed
        display_currency = await get_user_display_currency(self.db, user_uuid)

        # Calculate separate change percentages using helper method
        prev_net = prev_income - prev_expense
        current_net = total_income - total_expense

        income_change = self._calc_change_percent(prev_income, total_income)
        expense_change = self._calc_change_percent(prev_expense, total_expense)
        net_change = self._calc_change_percent(prev_net, current_net)

        return StatisticsOverviewResponse(
            totalBalance=f"{total_balance:.2f}",
            totalIncome=f"{total_income:.2f}",
            totalExpense=f"{total_expense:.2f}",
            incomeChangePercent=round(income_change, 1),
            expenseChangePercent=round(expense_change, 1),
            netChangePercent=round(net_change, 1),
            balanceNote=f"实时资产余额 ({display_currency})",
            periodStart=period_start,
            periodEnd=period_end,
        )

    async def get_trend_data(
        self,
        user_uuid: UUID,
        time_range: str = "month",
        transaction_type: str = "expense",
        start_date: str | None = None,
        end_date: str | None = None,
        account_types: list[str] | None = None,
        tz_offset_minutes: int | None = None,
    ) -> TrendDataResponse:
        """Get trend data for chart visualization."""
        period_start, period_end = self._get_date_range(time_range, start_date, end_date, tz_offset_minutes)

        tx_type = transaction_type.upper()

        # Determine grouping granularity based on time range
        if time_range == "week":
            date_trunc = func.date_trunc("day", Transaction.transaction_at)
        elif time_range == "month":
            date_trunc = func.date_trunc("day", Transaction.transaction_at)
        elif time_range == "year":
            date_trunc = func.date_trunc("month", Transaction.transaction_at)
        else:
            date_trunc = func.date_trunc("day", Transaction.transaction_at)

        # Build base conditions
        base_conditions: list[Any] = [
            Transaction.user_uuid == user_uuid,
            Transaction.type == tx_type,
            Transaction.transaction_at >= period_start,
            Transaction.transaction_at <= period_end,
        ]

        # Apply account type filter if specified
        account_filter = self._build_account_filter(user_uuid, account_types)
        if account_filter is not None:
            base_conditions.append(Transaction.source_account_id.in_(account_filter))

        # Query aggregated data
        query = (
            select(date_trunc.label("point_date"), func.sum(Transaction.amount).label("total"))
            .where(and_(*[c for c in base_conditions]))
            .group_by(date_trunc)
            .order_by(date_trunc)
        )

        result = await self.db.execute(query)
        rows = result.all()

        # Build date to amount map from aggregated rows
        date_amount_map: dict[str, Decimal] = {}
        for row in rows:
            point_dt = row.point_date
            if point_dt:
                if time_range == "year":
                    key = point_dt.strftime("%Y-%m")
                else:
                    key = point_dt.strftime("%Y-%m-%d")
                date_amount_map[key] = Decimal(str(row.total or 0))

        # Generate complete date sequence from period_start to period_end
        data_points = []
        current = period_start

        while current <= period_end:
            if time_range == "year":
                date_key = current.strftime("%Y-%m")
                label_str = current.strftime("%Y-%m")
                amount = date_amount_map.get(date_key, Decimal("0"))
                data_points.append(
                    TrendDataPoint(
                        date=date_key,
                        amount=f"{amount:.2f}",
                        label=label_str,
                    )
                )
                # Move to next month
                if current.month == 12:
                    current = current.replace(year=current.year + 1, month=1)
                else:
                    current = current.replace(month=current.month + 1)
            else:
                date_key = current.strftime("%Y-%m-%d")
                label_str = current.strftime("%m/%d")
                amount = date_amount_map.get(date_key, Decimal("0"))
                data_points.append(
                    TrendDataPoint(
                        date=date_key,
                        amount=f"{amount:.2f}",
                        label=label_str,
                    )
                )
                # Move to next day
                current = current + timedelta(days=1)

        return TrendDataResponse(
            dataPoints=data_points,
            timeRange=time_range,
            transactionType=transaction_type.lower(),
        )

    async def get_category_breakdown(
        self,
        user_uuid: UUID,
        time_range: str = "month",
        start_date: str | None = None,
        end_date: str | None = None,
        account_types: list[str] | None = None,
        transaction_type: str = "expense",
        limit: int = 10,
        tz_offset_minutes: int | None = None,
    ) -> CategoryBreakdownResponse:
        """Get breakdown by category for specified transaction type."""
        period_start, period_end = self._get_date_range(time_range, start_date, end_date, tz_offset_minutes)

        tx_type = transaction_type.upper()

        # Build base conditions
        base_conditions: list[Any] = [
            Transaction.user_uuid == user_uuid,
            Transaction.type == tx_type,
            Transaction.transaction_at >= period_start,
            Transaction.transaction_at <= period_end,
        ]

        # Apply account type filter if specified
        account_filter = self._build_account_filter(user_uuid, account_types)
        if account_filter is not None:
            base_conditions.append(Transaction.source_account_id.in_(account_filter))

        # Query category totals for expenses
        query = (
            select(Transaction.category_key, func.sum(Transaction.amount).label("total"))
            .where(and_(*[c for c in base_conditions]))
            .group_by(Transaction.category_key)
            .order_by(desc(func.sum(Transaction.amount)))
            .limit(limit)
        )

        result = await self.db.execute(query)
        rows = result.all()

        # Calculate total for percentages
        grand_total = sum(Decimal(str(row.total)) for row in rows)

        items = []
        for row in rows:
            category_key = row.category_key or "OTHERS"
            amount = Decimal(str(row.total))

            percentage = float(amount / grand_total * 100) if grand_total > 0 else 0.0

            items.append(
                CategoryBreakdownItem(
                    categoryKey=category_key,
                    categoryName=category_key,  # Client should translate
                    amount=f"{amount:.2f}",
                    percentage=round(percentage, 1),
                    color="",  # Client should determine color
                    icon="",  # Client should determine icon
                )
            )

        return CategoryBreakdownResponse(
            items=items,
            total=f"{grand_total:.2f}",
        )

    async def get_top_transactions(
        self,
        user_uuid: UUID,
        time_range: str = "month",
        start_date: str | None = None,
        end_date: str | None = None,
        account_types: list[str] | None = None,
        transaction_type: str = "expense",
        sort_by: str = "amount",
        page: int = 1,
        size: int = 10,
        tz_offset_minutes: int | None = None,
    ) -> TopTransactionsResponse:
        """Get top transactions for the period."""
        period_start, period_end = self._get_date_range(time_range, start_date, end_date, tz_offset_minutes)

        tx_type = transaction_type.upper()

        # Build base conditions
        base_conditions: list[Any] = [
            Transaction.user_uuid == user_uuid,
            Transaction.type == tx_type,
            Transaction.transaction_at >= period_start,
            Transaction.transaction_at <= period_end,
        ]

        # Apply account type filter if specified
        account_filter = self._build_account_filter(user_uuid, account_types)
        if account_filter is not None:
            base_conditions.append(Transaction.source_account_id.in_(account_filter))

        # Build query
        query = select(Transaction).where(and_(*[c for c in base_conditions]))

        # Apply sorting
        if sort_by == "date":
            query = query.order_by(desc(Transaction.transaction_at))
        else:  # default to amount
            query = query.order_by(desc(Transaction.amount))

        # Get total count
        count_query = select(func.count()).select_from(query.subquery())
        total_count_result = await self.db.execute(count_query)
        total_count = total_count_result.scalar() or 0

        # Apply pagination
        query = query.offset((page - 1) * size).limit(size)

        result = await self.db.execute(query)
        transactions = result.scalars().all()

        items = []
        for tx in transactions:
            category_key = tx.category_key or "OTHERS"

            items.append(
                TopTransactionItem(
                    id=str(tx.id),
                    description=tx.description or tx.raw_input or "",
                    amount=f"{Decimal(str(tx.amount)):.2f}",
                    categoryKey=category_key,
                    categoryName=category_key,  # Client should translate
                    transactionAt=tx.transaction_at,
                    icon="",  # Client should determine icon
                )
            )

        return TopTransactionsResponse(
            items=items,
            sortBy=sort_by,
            total=total_count,
            page=page,
            pageSize=size,
            hasMore=total_count > (page * size),
        )

    # Essential expense categories (housing, food, transport, medical)
    ESSENTIAL_CATEGORIES = {"HOUSING_UTILITIES", "FOOD_DINING", "TRANSPORTATION", "MEDICAL_HEALTH"}
    # Discretionary expense categories (entertainment, shopping)
    DISCRETIONARY_CATEGORIES = {"ENTERTAINMENT", "SHOPPING_RETAIL"}

    async def get_cash_flow(
        self,
        user_uuid: UUID,
        time_range: str = "month",
        start_date: str | None = None,
        end_date: str | None = None,
        account_types: list[str] | None = None,
        tz_offset_minutes: int | None = None,
    ) -> CashFlowResponse:
        """Get comprehensive cash flow analysis for the period."""
        period_start, period_end = self._get_date_range(time_range, start_date, end_date, tz_offset_minutes)
        prev_start, prev_end = self._get_previous_period_range(period_start, period_end)

        # Build base query conditions
        base_conditions: list[Any] = [
            Transaction.user_uuid == user_uuid,
            Transaction.transaction_at >= period_start,
            Transaction.transaction_at <= period_end,
        ]

        # Apply account type filter if specified
        account_filter = self._build_account_filter(user_uuid, account_types)
        if account_filter is not None:
            base_conditions.append(Transaction.source_account_id.in_(account_filter))

        # Single-query conditional aggregation for current period totals
        totals_query = select(
            func.coalesce(
                func.sum(case((Transaction.type == "INCOME", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("income"),
            func.coalesce(
                func.sum(case((Transaction.type == "EXPENSE", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("expense"),
        ).where(and_(*[c for c in base_conditions]))

        totals_result = await self.db.execute(totals_query)
        totals_row = totals_result.one()

        total_income = Decimal(str(totals_row.income or 0))
        total_expense = Decimal(str(totals_row.expense or 0))

        # Single-query conditional aggregation for previous period
        prev_conditions: list[Any] = [
            Transaction.user_uuid == user_uuid,
            Transaction.transaction_at >= prev_start,
            Transaction.transaction_at <= prev_end,
        ]
        if account_filter is not None:
            prev_conditions.append(Transaction.source_account_id.in_(account_filter))

        prev_totals_query = select(
            func.coalesce(
                func.sum(case((Transaction.type == "INCOME", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("income"),
            func.coalesce(
                func.sum(case((Transaction.type == "EXPENSE", Transaction.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("expense"),
        ).where(and_(*[c for c in prev_conditions]))

        prev_totals_result = await self.db.execute(prev_totals_query)
        prev_totals_row = prev_totals_result.one()

        prev_income = Decimal(str(prev_totals_row.income or 0))
        prev_expense = Decimal(str(prev_totals_row.expense or 0))

        net_cash_flow = total_income - total_expense

        # Calculate savings rate and expense ratio
        if total_income > 0:
            savings_rate = float((total_income - total_expense) / total_income * 100)
            expense_to_income_ratio = float(total_expense / total_income * 100)
        else:
            savings_rate = 0.0 if total_expense == 0 else -100.0
            expense_to_income_ratio = 100.0 if total_expense > 0 else 0.0

        # Calculate category-based expense ratios
        essential_expense = Decimal("0")
        discretionary_expense = Decimal("0")

        if total_expense > 0:
            # Query essential expenses (already in user's base currency)
            essential_query = select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                type_cast(
                    Any,
                    and_(
                        *[c for c in base_conditions],
                        Transaction.type == "EXPENSE",
                        Transaction.category_key.in_(self.ESSENTIAL_CATEGORIES),
                    ),
                )
            )
            essential_result = await self.db.execute(essential_query)
            essential_expense = Decimal(str(essential_result.scalar() or 0))

            # Query discretionary expenses
            discretionary_query = select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                type_cast(
                    Any,
                    and_(
                        *[c for c in base_conditions],
                        Transaction.type == "EXPENSE",
                        Transaction.category_key.in_(self.DISCRETIONARY_CATEGORIES),
                    ),
                )
            )
            discretionary_result = await self.db.execute(discretionary_query)
            discretionary_expense = Decimal(str(discretionary_result.scalar() or 0))

        # Calculate ratios (all values already in same base currency)
        essential_ratio = float(essential_expense / total_expense * 100) if total_expense > 0 else 0.0
        discretionary_ratio = float(discretionary_expense / total_expense * 100) if total_expense > 0 else 0.0

        # Calculate previous savings rate
        if prev_income > 0:
            prev_savings_rate = float((prev_income - prev_expense) / prev_income * 100)
        else:
            prev_savings_rate = 0.0 if prev_expense == 0 else -100.0

        # Calculate change percentages
        income_change = self._calc_change_percent(prev_income, total_income)
        expense_change = self._calc_change_percent(prev_expense, total_expense)
        savings_rate_change = savings_rate - prev_savings_rate

        return CashFlowResponse(
            totalIncome=f"{total_income:.2f}",
            totalExpense=f"{total_expense:.2f}",
            netCashFlow=f"{net_cash_flow:.2f}",
            savingsRate=round(savings_rate, 1),
            expenseToIncomeRatio=round(expense_to_income_ratio, 1),
            essentialExpenseRatio=round(essential_ratio, 1),
            discretionaryExpenseRatio=round(discretionary_ratio, 1),
            incomeChangePercent=round(income_change, 1),
            expenseChangePercent=round(expense_change, 1),
            savingsRateChange=round(savings_rate_change, 1),
            periodStart=period_start,
            periodEnd=period_end,
        )

    async def get_health_score(
        self,
        user_uuid: UUID,
        time_range: str = "month",
        start_date: str | None = None,
        end_date: str | None = None,
        account_types: list[str] | None = None,
        tz_offset_minutes: int | None = None,
    ) -> HealthScoreResponse:
        """Calculate comprehensive financial health score based on multiple dimensions."""
        # First get cash flow data as base
        cash_flow = await self.get_cash_flow(
            user_uuid, time_range, start_date, end_date, account_types, tz_offset_minutes
        )

        period_start, period_end = self._get_date_range(time_range, start_date, end_date, tz_offset_minutes)

        dimensions = []
        suggestions = []

        # Dimension 1: Savings Rate (weight: 40%)
        # Excellent: 30%+, Good: 15-29%, Fair: 5-14%, Poor: <5%
        savings_rate = cash_flow.savingsRate
        if savings_rate >= 30:
            savings_score = 100
            savings_status = "excellent"
        elif savings_rate >= 20:
            savings_score = 85
            savings_status = "good"
        elif savings_rate >= 10:
            savings_score = 70
            savings_status = "fair"
        elif savings_rate >= 0:
            savings_score = 50
            savings_status = "fair"
            suggestions.append("储蓄率较低，建议减少非必要支出以提高储蓄")
        else:
            savings_score = int(round(max(0, 30 + savings_rate)))  # Negative savings
            savings_status = "poor"
            suggestions.append("支出超过收入，需要紧急调整预算或增加收入")

        dimensions.append(
            HealthScoreDimension(
                name="储蓄能力",
                score=savings_score,
                weight=0.4,
                description=f"储蓄率 {savings_rate:.1f}%",
                status=savings_status,
            )
        )

        # Dimension 2: Expense Control (weight: 35%)
        # Based on essential vs discretionary ratio
        essential_ratio = cash_flow.essentialExpenseRatio
        discretionary_ratio = cash_flow.discretionaryExpenseRatio

        # Ideal: essential 50-70%, discretionary <20%
        if essential_ratio >= 50 and discretionary_ratio <= 20:
            expense_score = 100
            expense_status = "excellent"
        elif essential_ratio >= 40 and discretionary_ratio <= 30:
            expense_score = 80
            expense_status = "good"
        elif discretionary_ratio <= 40:
            expense_score = 60
            expense_status = "fair"
            suggestions.append("可选消费占比较高，考虑制定预算控制娱乐和购物支出")
        else:
            expense_score = 40
            expense_status = "poor"
            suggestions.append("支出结构不合理，必要支出不足或可选消费过高")

        dimensions.append(
            HealthScoreDimension(
                name="支出控制",
                score=expense_score,
                weight=0.35,
                description=f"必要支出 {essential_ratio:.1f}%，可选消费 {discretionary_ratio:.1f}%",
                status=expense_status,
            )
        )

        # Dimension 3: Income Stability (weight: 25%)
        # Based on income change vs previous period
        income_change = cash_flow.incomeChangePercent
        if income_change >= 10:
            income_score = 100
            income_status = "excellent"
        elif income_change >= 0:
            income_score = 85
            income_status = "good"
        elif income_change >= -10:
            income_score = 65
            income_status = "fair"
            suggestions.append("收入有所下降，建议开拓额外收入来源")
        else:
            income_score = int(round(max(30, 50 + income_change)))
            income_status = "poor"
            suggestions.append("收入显著下降，需要评估职业发展或寻找新收入机会")

        dimensions.append(
            HealthScoreDimension(
                name="收入稳定性",
                score=income_score,
                weight=0.25,
                description=f"同比变化 {income_change:+.1f}%",
                status=income_status,
            )
        )

        # Calculate total weighted score
        total_score = sum(d.score * d.weight for d in dimensions)
        total_score = int(round(total_score))

        # Determine grade
        if total_score >= 90:
            grade = "A"
        elif total_score >= 75:
            grade = "B"
        elif total_score >= 60:
            grade = "C"
        elif total_score >= 45:
            grade = "D"
        else:
            grade = "F"

        return HealthScoreResponse(
            totalScore=total_score,
            grade=grade,
            dimensions=dimensions,
            suggestions=suggestions[:3],  # Limit to top 3 suggestions
            periodStart=period_start,
            periodEnd=period_end,
        )
