"""Forecast service for cash flow prediction.

This service implements the hybrid prediction model:
1. Deterministic Layer (recurring_transactions) - 60% weight
2. Probabilistic Layer (historical average) - 40% weight
3. Semantic Layer (scenario simulation from LLM) - contextual

Architecture:
    - Pure business logic, no LLM calls
    - RAG context retrieval for AI feedback preferences
    - Compatible with GenUI streaming via tools layer
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from typing import Any, cast
from uuid import UUID

from sqlalchemy import and_, case, desc, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import logger
from app.models.financial_account import FinancialAccount
from app.models.transaction import RecurringTransaction, Transaction

# Human-readable forecast labels localized per app language.
# Keyed by ``language`` (zh, zh-Hant, ja, ko, en) with an English fallback.
_FORECAST_LOCALE: dict[str, dict[str, str]] = {
    "daily_variable": {
        "zh": "每日预期支出",
        "zh-Hant": "每日預期支出",
        "ja": "日次予測支出",
        "ko": "일일 예상 지출",
        "en": "Daily Expense (Predicted)",
    },
    "warning_negative": {
        "zh": "余额预计在 {month}/{day} 转为负数",
        "zh-Hant": "餘額預計在 {month}/{day} 轉為負數",
        "ja": "{month}/{day} に残高がマイナスになる見込みです",
        "ko": "{month}/{day} 잔액이 마이너스가 될 것으로 예상됩니다",
        "en": "Balance is projected to go negative on {month}/{day}",
    },
    "warning_below_safety": {
        "zh": "余额预计在 {month}/{day} 低于安全阈值",
        "zh-Hant": "餘額預計在 {month}/{day} 低於安全門檻",
        "ja": "{month}/{day} に残高が安全しきい値を下回る見込みです",
        "ko": "{month}/{day} 잔액이 안전 기준 이하로 떨어질 것으로 예상됩니다",
        "en": "Balance is projected to drop below the safety threshold on {month}/{day}",
    },
}


@dataclass
class ForecastEvent:
    """A single event in the cash flow forecast."""

    date: date
    description: str
    amount: Decimal
    event_type: str  # RECURRING, PREDICTED_VARIABLE, SIMULATED
    source_id: str | None = None  # recurring_transaction.id if applicable
    category_key: str | None = None
    confidence: float = 1.0  # 1.0 for deterministic, < 1.0 for predicted


@dataclass
class ForecastDataPoint:
    """A single data point in the forecast time series."""

    date: date
    predicted_balance: Decimal
    lower_bound: Decimal  # Conservative estimate
    upper_bound: Decimal  # Optimistic estimate
    events: list[ForecastEvent] = field(default_factory=list)


@dataclass
class ForecastWarning:
    """A warning about potential financial issues."""

    date: date
    warning_type: str  # BELOW_SAFETY, NEGATIVE_BALANCE
    message: str


@dataclass
class ForecastSummary:
    """Summary statistics for the forecast period."""

    total_recurring_income: Decimal
    total_recurring_expense: Decimal
    predicted_variable_expense: Decimal
    net_change: Decimal

    @property
    def to_dict(self) -> dict[str, Any]:
        """Convert the forecast summary to a serializable dictionary."""
        return {
            "total_recurring_income": float(self.total_recurring_income),
            "total_recurring_expense": float(self.total_recurring_expense),
            "predicted_variable_expense": float(self.predicted_variable_expense),
            "net_change": float(self.net_change),
        }


@dataclass
class CashFlowForecastResult:
    """Complete cash flow forecast result."""

    success: bool
    forecast_period: dict[str, Any]
    current_balance: Decimal
    data_points: list[ForecastDataPoint]
    warnings: list[ForecastWarning]
    summary: ForecastSummary
    user_preferences: list[dict[str, Any]] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "success": self.success,
            "forecast_period": self.forecast_period,
            "current_balance": float(self.current_balance),
            "data_points": [
                {
                    "date": dp.date.isoformat(),
                    "predicted_balance": float(dp.predicted_balance),
                    "lower_bound": float(dp.lower_bound),
                    "upper_bound": float(dp.upper_bound),
                    "events": [
                        {
                            "type": e.event_type,
                            "description": e.description,
                            "amount": float(e.amount),
                            "source_id": e.source_id,
                            "category_key": e.category_key,
                            "confidence": e.confidence,
                        }
                        for e in dp.events
                    ],
                }
                for dp in self.data_points
            ],
            "warnings": [
                {
                    "date": w.date.isoformat(),
                    "type": w.warning_type,
                    "message": w.message,
                }
                for w in self.warnings
            ],
            "summary": self.summary.to_dict,
            "user_preferences": self.user_preferences,
        }


class ForecastService:
    """Service for generating cash flow forecasts.

    Implements the hybrid prediction model:
    - Deterministic Layer: Expand recurring_transactions rules
    - Probabilistic Layer: Historical average spending
    - Semantic Layer: LLM-triggered scenario simulation
    """

    # Confidence interval margin for probabilistic predictions
    CONFIDENCE_MARGIN = Decimal("0.15")  # ±15% for variable spending

    def __init__(self, db: AsyncSession):
        self.db = db

    def _loc(self, key: str, language: str | None, **fmt: object) -> str:
        """Localize a forecast label for the given ``language`` (en fallback)."""
        lang = (language or "zh").strip() or "zh"
        template = _FORECAST_LOCALE.get(key, {}).get(lang) or _FORECAST_LOCALE[key]["en"]
        return template.format(**fmt) if fmt else template

    async def generate_cash_flow_forecast(
        self,
        user_uuid: UUID,
        forecast_days: int = 30,
        scenarios: list[dict[str, Any]] | None = None,
        include_variable_spending: bool = True,
        safety_threshold: Decimal | None = None,
        language: str | None = "zh",
    ) -> CashFlowForecastResult:
        """Generate a complete cash flow forecast.

        Args:
            user_uuid: User's UUID
            forecast_days: Number of days to forecast (default 30, max 90)
            scenarios: Optional list of simulated events from LLM
            include_variable_spending: Whether to include predicted daily spending
            safety_threshold: Optional custom safety threshold, overrides user settings
            language: Session language for localizing labels (zh/zh-Hant/ja/ko/en)

        Returns:
            CashFlowForecastResult with all data points and analysis
        """
        forecast_days = min(max(forecast_days, 7), 90)

        start_date = date.today()
        end_date = start_date + timedelta(days=forecast_days)

        # 1. Get current balance
        current_balance = await self._get_total_balance(user_uuid)

        # 2. Get deterministic events (recurring transactions)
        deterministic_events = await self._get_deterministic_events(user_uuid, start_date, end_date)

        # 3. Get financial settings (safety threshold and manual daily burn rate)
        s_threshold, manual_burn_rate = await self._get_financial_settings(user_uuid)
        if safety_threshold is None:
            safety_threshold = s_threshold

        # 4. Get probabilistic predictions (average daily spending)
        avg_daily_spending = Decimal("0")
        if include_variable_spending:
            avg_daily_spending = await self._get_average_daily_spending(user_uuid, manual_fallback=manual_burn_rate)

        # 5. Process simulated scenarios
        scenario_events = self._process_scenarios(scenarios or [])

        # 6. Build forecast data points
        data_points = self._build_data_points(
            start_date=start_date,
            end_date=end_date,
            current_balance=current_balance,
            deterministic_events=deterministic_events,
            scenario_events=scenario_events,
            avg_daily_spending=avg_daily_spending,
            language=language,
        )

        # 7. Generate warnings
        warnings = self._generate_warnings(
            data_points=data_points,
            safety_threshold=safety_threshold,
            language=language,
        )

        # 8. Calculate summary
        summary = self._calculate_summary(deterministic_events, avg_daily_spending, forecast_days)

        logger.info(
            "forecast_generated",
            user_uuid=str(user_uuid),
            forecast_days=forecast_days,
            deterministic_events=len(deterministic_events),
            scenario_count=len(scenario_events),
            warnings_count=len(warnings),
        )

        return CashFlowForecastResult(
            success=True,
            forecast_period={
                "start": start_date.isoformat(),
                "end": end_date.isoformat(),
                "days": forecast_days,
            },
            current_balance=current_balance,
            data_points=data_points,
            warnings=warnings,
            summary=summary,
        )

    async def _get_total_balance(self, user_uuid: UUID) -> Decimal:
        """Get total balance across all ASSET accounts."""
        query = select(
            func.coalesce(
                func.sum(
                    case(
                        (FinancialAccount.nature == "ASSET", FinancialAccount.current_balance),
                        (FinancialAccount.nature == "LIABILITY", -FinancialAccount.current_balance),
                        else_=Decimal("0"),
                    )
                ),
                Decimal("0"),
            )
        ).where(
            cast(
                Any,
                and_(
                    FinancialAccount.user_uuid == user_uuid,
                    FinancialAccount.status == "ACTIVE",
                    FinancialAccount.include_in_net_worth == True,  # noqa: E712
                ),
            )
        )

        result = await self.db.execute(query)
        return result.scalar() or Decimal("0")

    async def _get_deterministic_events(
        self,
        user_uuid: UUID,
        start_date: date,
        end_date: date,
    ) -> list[ForecastEvent]:
        """Get all deterministic events from recurring transactions."""
        from dateutil.rrule import rrulestr

        query = select(RecurringTransaction).where(
            cast(
                Any,
                and_(
                    RecurringTransaction.user_uuid == user_uuid,
                    RecurringTransaction.is_active == True,  # noqa: E712
                    cast(
                        Any,
                        or_(
                            RecurringTransaction.end_date == None,  # noqa: E711
                            RecurringTransaction.end_date >= start_date,
                        ),
                    ),
                ),
            )
        )

        result = await self.db.execute(query)
        recurring_txs = result.scalars().all()

        events = []

        for tx in recurring_txs:
            try:
                # Parse RRULE and generate occurrences
                dtstart = datetime.combine(tx.start_date, datetime.min.time(), tzinfo=UTC)
                rrule = rrulestr(tx.recurrence_rule, dtstart=dtstart)

                exception_set = set(tx.exception_dates or [])

                for occurrence in rrule:
                    occ_date = occurrence.date()

                    # Skip dates outside range
                    if occ_date < start_date:
                        continue
                    if occ_date > end_date:
                        break

                    # Skip exception dates
                    if occ_date.isoformat() in exception_set:
                        continue

                    # Skip if past end_date of rule
                    if tx.end_date and occ_date > tx.end_date:
                        break

                    # Determine amount sign based on transaction type
                    amount = tx.amount
                    if tx.type == "EXPENSE":
                        amount = -abs(amount)
                    elif tx.type == "INCOME":
                        amount = abs(amount)
                    # TRANSFER: amount stays as-is (could be positive or negative)

                    events.append(
                        ForecastEvent(
                            date=occ_date,
                            description=tx.description or tx.category_key or tx.type,
                            amount=amount,
                            event_type="RECURRING",
                            source_id=str(tx.uuid),
                            category_key=tx.category_key,
                            confidence=1.0,  # Deterministic = 100% confidence
                        )
                    )

            except Exception as e:
                logger.warning(
                    "rrule_parse_error",
                    recurring_id=str(tx.uuid),
                    error=str(e),
                )
                continue

        return events

    async def _get_average_daily_spending(
        self,
        user_uuid: UUID,
        lookback_days: int = 30,
        manual_fallback: Decimal | None = None,
    ) -> Decimal:
        """Calculate predicted daily variable spending using scientific methods.

        Improvements:
        1. Use median instead of mean (robust against outliers)
        2. Exclude recurring transactions (prevents double counting)
        3. Use full time window calculation (lookback_days rather than active spending days only)

        Priority:
        1. If user explicitly configured daily_burn_rate > 0 -> use user setting first
        2. Historical median (if enough data points exist)
        3. System default (100.00)
        """
        # If user manually configured a value, use it as an override
        if manual_fallback is not None and manual_fallback > Decimal("0"):
            logger.debug(
                "forecast_using_user_override", user_uuid=str(user_uuid), daily_burn_rate=float(manual_fallback)
            )
            return -abs(manual_fallback)

        lookback_start = datetime.now(UTC) - timedelta(days=lookback_days)

        # Retrieve recurring transaction amounts for exclusion
        recurring_amounts = set()
        recurring_query = select(RecurringTransaction.amount).where(
            cast(
                Any,
                and_(
                    RecurringTransaction.user_uuid == user_uuid,
                    RecurringTransaction.is_active == True,  # noqa: E712
                    RecurringTransaction.type == "EXPENSE",
                ),
            )
        )
        try:
            result = await self.db.execute(recurring_query)
            for row in result.all():
                # Add recurring amount (allow small tolerance match)
                recurring_amounts.add(float(abs(row[0])))
        except Exception:  # noqa: BLE001
            # Degrade gracefully to "no recurring expenses", but surface the failure.
            logger.warning("recurring_amount_query_failed", user_uuid=str(user_uuid), exc_info=True)

        # Query individual expense transactions (rather than daily aggregates)
        query = (
            select(
                Transaction.amount,
                Transaction.transaction_at,
            )
            .where(
                cast(
                    Any,
                    and_(
                        Transaction.user_uuid == user_uuid,
                        Transaction.type == "EXPENSE",
                        Transaction.status == "CLEARED",
                        Transaction.transaction_at >= lookback_start,
                    ),
                )
            )
            .order_by(Transaction.transaction_at)
        )

        result = await self.db.execute(query)
        transactions = result.all()

        # Filter out recurring transactions by amount matching
        variable_expenses = []
        for tx in transactions:
            tx_amount = float(abs(tx.amount))
            # If amount matches any recurring transaction (allow 1% tolerance), exclude
            is_recurring = (
                any(
                    abs(tx_amount - recurring_amt) / max(recurring_amt, 1) < 0.01
                    for recurring_amt in recurring_amounts
                )
                if recurring_amounts
                else False
            )

            if not is_recurring:
                variable_expenses.append(tx_amount)

        if len(variable_expenses) >= 5:
            # Use median (robust against outliers)
            sorted_expenses = sorted(variable_expenses)
            n = len(sorted_expenses)
            if n % 2 == 0:
                median = (sorted_expenses[n // 2 - 1] + sorted_expenses[n // 2]) / 2
            else:
                median = sorted_expenses[n // 2]

            # Calculate daily average: total variable expense / full lookback days
            total_variable = sum(variable_expenses)
            daily_avg = Decimal(str(total_variable)) / Decimal(str(lookback_days))

            # Use weighted average of median and daily average (higher weight on median)
            avg = Decimal(str(median)) * Decimal("0.4") + daily_avg * Decimal("0.6")

            logger.debug(
                "forecast_using_scientific_method",
                user_uuid=str(user_uuid),
                median=median,
                daily_avg=float(daily_avg),
                weighted_avg=float(avg),
                variable_transactions=len(variable_expenses),
                excluded_recurring=len(transactions) - len(variable_expenses),
            )
        else:
            # Insufficient data, fallback to default
            avg = Decimal("100.00")
            logger.debug(
                "forecast_using_system_default",
                user_uuid=str(user_uuid),
                reason="insufficient_data",
                data_points=len(variable_expenses),
            )

        # Return as negative (expense)
        return -abs(avg)

    def _process_scenarios(
        self,
        scenarios: list[dict[str, Any]],
    ) -> list[ForecastEvent]:
        """Convert LLM-generated scenarios to ForecastEvents."""
        events = []

        for scenario in scenarios:
            try:
                # Parse date
                if isinstance(scenario.get("date"), str):
                    scenario_date = date.fromisoformat(scenario["date"])
                else:
                    scenario_date = scenario.get("date", date.today())

                # Parse amount
                amount = Decimal(str(scenario.get("amount", 0)))

                events.append(
                    ForecastEvent(
                        date=scenario_date,
                        description=scenario.get("description", "Simulated scenario"),
                        amount=amount,
                        event_type="SIMULATED",
                        confidence=0.8,  # Simulated events have lower confidence
                    )
                )

            except Exception as e:
                logger.warning("scenario_parse_error", scenario=scenario, error=str(e))
                continue

        return events

    async def _get_financial_settings(self, user_uuid: UUID) -> tuple[Decimal, Decimal]:
        """Get user's financial settings (safety_threshold, daily_burn_rate)."""
        from app.models.financial_settings import FinancialSettings

        query = select(FinancialSettings.safety_threshold, FinancialSettings.daily_burn_rate).where(
            FinancialSettings.user_uuid == user_uuid
        )

        try:
            result = await self.db.execute(query)
            settings = result.first()
            if settings:
                return settings.safety_threshold, settings.daily_burn_rate
            return Decimal("0"), Decimal("100.00")
        except Exception:
            logger.warning("financial_settings_query_failed", user_uuid=str(user_uuid), exc_info=True)
            return Decimal("0"), Decimal("100.00")

    def _build_data_points(
        self,
        start_date: date,
        end_date: date,
        current_balance: Decimal,
        deterministic_events: list[ForecastEvent],
        scenario_events: list[ForecastEvent],
        avg_daily_spending: Decimal,
        language: str | None = "zh",
    ) -> list[ForecastDataPoint]:
        """Build the complete forecast time series."""
        # Group events by date
        events_by_date: dict[date, list[ForecastEvent]] = {}

        for event in deterministic_events + scenario_events:
            if event.date not in events_by_date:
                events_by_date[event.date] = []
            events_by_date[event.date].append(event)

        # Generate data points
        data_points = []
        running_balance = current_balance
        running_lower = current_balance
        running_upper = current_balance

        current_date = start_date
        while current_date <= end_date:
            # Get events for this day
            day_events = events_by_date.get(current_date, [])

            # Add predicted variable spending (if not already covered by events)
            if avg_daily_spending != Decimal("0"):
                day_events.append(
                    ForecastEvent(
                        date=current_date,
                        description=self._loc("daily_variable", language),
                        amount=avg_daily_spending,
                        event_type="PREDICTED_VARIABLE",
                        confidence=0.7,
                    )
                )

            # Calculate day's net change
            daily_change = sum(e.amount for e in day_events)

            # Calculate confidence interval
            # For variable spending, apply ±15% margin
            variable_amount = sum(abs(e.amount) for e in day_events if e.event_type == "PREDICTED_VARIABLE")
            margin = variable_amount * self.CONFIDENCE_MARGIN

            # Update running balances
            running_balance += daily_change
            running_lower += daily_change - margin
            running_upper += daily_change + margin

            data_points.append(
                ForecastDataPoint(
                    date=current_date,
                    predicted_balance=running_balance,
                    lower_bound=running_lower,
                    upper_bound=running_upper,
                    events=day_events,
                )
            )

            current_date += timedelta(days=1)

        return data_points

    def _generate_warnings(
        self,
        data_points: list[ForecastDataPoint],
        safety_threshold: Decimal,
        language: str | None = "zh",
    ) -> list[ForecastWarning]:
        """Generate warnings for potential financial issues."""
        warnings = []
        warned_below_safety = False
        warned_negative = False

        for dp in data_points:
            # Check for negative balance
            if dp.predicted_balance < 0 and not warned_negative:
                warnings.append(
                    ForecastWarning(
                        date=dp.date,
                        warning_type="NEGATIVE_BALANCE",
                        message=self._loc(
                            "warning_negative",
                            language,
                            month=dp.date.month,
                            day=dp.date.day,
                        ),
                    )
                )
                warned_negative = True

            # Check for below safety threshold
            elif dp.predicted_balance < safety_threshold and dp.predicted_balance >= 0 and not warned_below_safety:
                warnings.append(
                    ForecastWarning(
                        date=dp.date,
                        warning_type="BELOW_SAFETY",
                        message=self._loc(
                            "warning_below_safety",
                            language,
                            month=dp.date.month,
                            day=dp.date.day,
                        ),
                    )
                )
                warned_below_safety = True

        return warnings

    def _calculate_summary(
        self,
        deterministic_events: list[ForecastEvent],
        avg_daily_spending: Decimal,
        forecast_days: int,
    ) -> ForecastSummary:
        """Calculate forecast summary statistics."""
        total_recurring_income = sum((e.amount for e in deterministic_events if e.amount > 0), Decimal("0"))
        total_recurring_expense = abs(sum((e.amount for e in deterministic_events if e.amount < 0), Decimal("0")))
        predicted_variable = abs(avg_daily_spending * forecast_days)

        net_change = total_recurring_income - total_recurring_expense - predicted_variable

        return ForecastSummary(
            total_recurring_income=total_recurring_income,
            total_recurring_expense=total_recurring_expense,
            predicted_variable_expense=predicted_variable,
            net_change=net_change,
        )

    async def simulate_purchase(
        self,
        user_uuid: UUID,
        amount: Decimal,
        purchase_date: date | None = None,
        description: str = "Simulated Purchase",
        language: str | None = "zh",
    ) -> CashFlowForecastResult:
        """Simulate a one-time purchase and show its impact.

        Convenience method for "What if I buy X?" scenarios.
        """
        if purchase_date is None:
            purchase_date = date.today() + timedelta(days=7)

        scenario = {
            "date": purchase_date.isoformat(),
            "amount": -abs(amount),  # Ensure it's negative (expense); keep Decimal precision
            "description": description,
        }

        return await self.generate_cash_flow_forecast(
            user_uuid=user_uuid,
            forecast_days=30,
            scenarios=[scenario],
            language=language,
        )
