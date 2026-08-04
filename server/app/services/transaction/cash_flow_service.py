"""Cash flow service for forecasting and analysis."""

from datetime import UTC, datetime, timedelta
from decimal import Decimal
from typing import TYPE_CHECKING, Any
from uuid import UUID

import structlog
from sqlalchemy import and_, case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.financial_account import FinancialAccount
from app.models.transaction import RecurringTransaction, Transaction

if TYPE_CHECKING:
    from app.services.transaction.recurring_service import RecurringTransactionService

logger = structlog.get_logger(__name__)


class CashFlowService:
    """Service for cash flow forecasting and analysis."""

    def __init__(self, db: AsyncSession, recurring_service: "RecurringTransactionService"):
        self.db = db
        self._recurring = recurring_service

    async def forecast_cash_flow(
        self,
        user_uuid: UUID,
        forecast_days: int = 60,
        granularity: str = "daily",
        scenarios: list[dict[str, Any]] | None = None,
    ) -> dict[str, Any]:
        """Forecast future cash flow.

        All money is normalized to the user's base currency before aggregation:
        - ``FinancialAccount.current_balance`` is stored per-account currency,
          converted here via live rates;
        - ``Transaction.amount`` is already denominated in the user's base
          currency (no conversion);
        - ``RecurringTransaction.amount`` is in the original currency, converted
          via ``convert_to_user_base``.
        Unavailable rates skip the affected account/event (with a warning)
        rather than silently summing mixed currencies.
        """
        from app.models.financial_settings import FinancialSettings
        from app.utils.currency_utils import get_user_base_currency

        user_base_currency = await get_user_base_currency(self.db, user_uuid)

        # 1. Get base data
        # Get user settings (change to read FinancialSettings)
        settings_query = select(FinancialSettings).where(FinancialSettings.user_uuid == user_uuid)
        settings_result = await self.db.execute(settings_query)
        settings = settings_result.scalar_one_or_none()
        safety_threshold = settings.safety_threshold if settings else Decimal("0.00")

        # Current total balance: assets (ASSET) count positive, liabilities
        # (LIABILITY) negative. Each account's balance is in its own currency,
        # so convert to the user's base currency before summing.
        accounts_query = select(
            FinancialAccount.uuid,
            FinancialAccount.nature,
            FinancialAccount.current_balance,
            FinancialAccount.currency_code,
        ).where(
            and_(
                FinancialAccount.user_uuid == user_uuid,
                FinancialAccount.status == "ACTIVE",
                FinancialAccount.include_in_net_worth,
            )
        )
        accounts_result = await self.db.execute(accounts_query)

        current_balance = Decimal("0.00")
        for account_id, nature, balance, currency_code in accounts_result.all():
            balance = balance or Decimal("0.00")
            converted = await self._to_user_base(balance, currency_code or user_base_currency, user_base_currency)
            if converted is None:
                logger.warning(
                    "forecast_account_skipped_conversion",
                    user_uuid=str(user_uuid),
                    account_id=str(account_id),
                    currency=currency_code,
                )
                continue
            current_balance += converted if nature == "ASSET" else -converted

        # Calculate average daily consumption (past 30 days of expense records).
        # Transaction.amount is stored in the user's base currency; expense is
        # identified by type and amounts are positive.
        thirty_days_ago = datetime.now(UTC) - timedelta(days=30)
        # First get the daily total expenses
        daily_expense_query = (
            select(
                func.date(Transaction.transaction_at).label("tx_date"),
                func.sum(Transaction.amount).label("daily_total"),
            )
            .where(
                and_(
                    Transaction.user_uuid == user_uuid,
                    Transaction.type == "EXPENSE",
                    Transaction.transaction_at >= thirty_days_ago,
                )
            )
            .group_by(func.date(Transaction.transaction_at))
        )

        daily_expense_result = await self.db.execute(daily_expense_query)
        daily_expenses = daily_expense_result.all()

        # Average daily spending is the positive mean over the last 30 days;
        # with no history we do not fabricate spending — the forecast simply
        # carries the current balance forward.
        avg_daily_spending: Decimal = Decimal("0.00")
        if daily_expenses:
            total_spending = sum((row.daily_total or Decimal("0.00")) for row in daily_expenses)
            avg_daily_spending = total_spending / Decimal(max(len(daily_expenses), 1))

        # 2. Aggregate all future events
        events_by_date: dict[str, list[dict[str, Any]]] = {}
        start_date = datetime.now(UTC).date()
        forecast_end_date = start_date + timedelta(days=forecast_days)

        # a. Process recurring events
        recurring_query = select(RecurringTransaction).where(
            and_(
                RecurringTransaction.user_uuid == user_uuid,
                RecurringTransaction.is_active,
            )
        )
        recurring_result = await self.db.execute(recurring_query)
        recurring_txs = recurring_result.scalars().all()

        for tx in recurring_txs:
            try:
                # Recurring amounts are in the original currency: normalize to
                # the user's base currency, then sign by type (EXPENSE reduces
                # the balance, INCOME increases it, TRANSFER is net-neutral and
                # is skipped).
                base_amount = await self._to_user_base(tx.amount, tx.currency, user_base_currency)
                if base_amount is None:
                    logger.warning(
                        "forecast_recurring_skipped_conversion",
                        tx_id=str(tx.uuid),
                        currency=tx.currency,
                    )
                    continue
                if tx.type == "TRANSFER":
                    continue
                signed_amount = base_amount if tx.type == "INCOME" else -base_amount

                # Get exception_dates list
                exception_dates_list = tx.exception_dates or []
                exception_dates_set = set(exception_dates_list)

                occurrences = self._recurring.parse_rrule_occurrences(
                    tx.recurrence_rule,
                    tx.start_date,
                    tx.end_date,
                    start_date,
                    forecast_end_date,
                )
                for occ_date in occurrences:
                    date_str = occ_date.isoformat()
                    # Skip excluded dates
                    if date_str in exception_dates_set:
                        continue
                    if date_str not in events_by_date:
                        events_by_date[date_str] = []
                    events_by_date[date_str].append(
                        {
                            "description": tx.description or "Recurring transaction",
                            "amount": str(signed_amount),
                        }
                    )
            except Exception as e:
                logger.error("recurring_tx_processing_failed", tx_id=str(tx.uuid), error=str(e))
                continue

        # b. Process scenario events
        if scenarios:
            for scenario in scenarios:
                date_str = scenario["date"]
                if date_str not in events_by_date:
                    events_by_date[date_str] = []
                events_by_date[date_str].append(
                    {
                        "description": scenario["description"],
                        "amount": str(Decimal(str(scenario["amount"]))),
                    }
                )

        # 3. Loop through daily balance calculation
        raw_daily_breakdown = []
        balance = current_balance

        for i in range(forecast_days):
            current_date = start_date + timedelta(days=i)
            date_str = current_date.isoformat()

            daily_events = events_by_date.get(date_str, []).copy()
            if avg_daily_spending != 0:
                daily_events.append(
                    {
                        "description": "Daily Expense (Predicted)",
                        "amount": str(-avg_daily_spending),
                    }
                )

            daily_net = Decimal("0.00")
            for event in daily_events:
                daily_net += Decimal(event["amount"])

            balance += daily_net

            raw_daily_breakdown.append(
                {
                    "date": date_str,
                    "closingBalance": str(balance),
                    "events": daily_events,
                }
            )

        # 4. Aggregate results based on granularity parameter
        aggregated_breakdown = self._aggregate_breakdown(raw_daily_breakdown, granularity)

        # 5. Calculate warnings and summary information
        warnings = self._calculate_warnings(raw_daily_breakdown, safety_threshold)
        summary = self._calculate_summary(str(current_balance), raw_daily_breakdown)

        return {
            "dailyBreakdown": aggregated_breakdown,
            "warnings": warnings,
            "summary": summary,
        }

    async def _to_user_base(
        self,
        amount: Decimal,
        currency: str,
        user_base_currency: str,
    ) -> Decimal | None:
        """Convert an amount to the user's base currency, or None if unavailable."""
        if (currency or user_base_currency).upper() == user_base_currency.upper():
            return amount
        try:
            from app.utils.currency_utils import convert_to_user_base

            base_amount, _ = await convert_to_user_base(amount, currency, user_base_currency)
            return base_amount
        except Exception as e:
            logger.warning(
                "forecast_conversion_failed",
                amount=str(amount),
                currency=currency,
                user_base_currency=user_base_currency,
                error=str(e),
            )
            return None

    def _aggregate_breakdown(self, daily_breakdown: list[dict[str, Any]], granularity: str) -> list[dict[str, Any]]:
        """Aggregate data based on granularity parameter

        Args:
            daily_breakdown: List of daily details
            granularity: Granularity ('daily', 'weekly', 'monthly')

        Returns:
            Aggregated details list
        """
        if granularity == "daily" or not daily_breakdown:
            return daily_breakdown

        from collections import defaultdict

        grouped_data = defaultdict(list)

        for day in daily_breakdown:
            date_obj = datetime.fromisoformat(day["date"])

            if granularity == "weekly":
                # Use ISO week number as group key
                group_key = date_obj.strftime("%Y-W%W")
            elif granularity == "monthly":
                # Use year-month as group key
                group_key = date_obj.strftime("%Y-%m")
            else:
                group_key = day["date"]

            grouped_data[group_key].append(day)

        # Format aggregated results
        aggregated = []
        for _group_key, days_in_group in grouped_data.items():
            last_day_data = days_in_group[-1]

            # Collect all key events (exclude daily spending prediction)
            all_events = []
            for day in days_in_group:
                for event in day["events"]:
                    if event["description"] != "Daily Expense (Predicted)":
                        all_events.append(event)

            aggregated.append(
                {
                    "date": last_day_data["date"],
                    "closingBalance": last_day_data["closingBalance"],
                    "events": all_events,
                }
            )

        return aggregated

    def _calculate_warnings(
        self, raw_daily_breakdown: list[dict[str, Any]], safety_threshold: Decimal
    ) -> list[dict[str, Any]]:
        """Calculate warning information

        Args:
            raw_daily_breakdown: Original daily details
            safety_threshold: Safety threshold

        Returns:
            Warning list
        """
        warnings = {}
        threshold = safety_threshold

        for day in raw_daily_breakdown:
            balance = Decimal(day["closingBalance"])
            if balance < threshold:
                date_obj = datetime.fromisoformat(day["date"])
                date_str = day["date"]
                warnings[date_str] = {
                    "date": date_str,
                    "message": f"After {date_obj.month}/{date_obj.day}, your balance will drop below the safety threshold.",
                }

        return list(warnings.values())

    def _calculate_summary(self, start_balance: str, raw_daily_breakdown: list[dict[str, Any]]) -> dict[str, Any]:
        """Calculate summary information

        Args:
            start_balance: Starting balance
            raw_daily_breakdown: Original daily details

        Returns:
            Summary dictionary
        """
        if not raw_daily_breakdown:
            return {
                "startBalance": start_balance,
                "endBalance": start_balance,
                "totalIncome": "0.00",
                "totalExpense": "0.00",
            }

        total_income = Decimal("0.00")
        total_expense = Decimal("0.00")

        for day in raw_daily_breakdown:
            for event in day["events"]:
                amount = Decimal(event["amount"])
                if amount > 0:
                    total_income += amount
                else:
                    total_expense += amount

        return {
            "startBalance": start_balance,
            "endBalance": raw_daily_breakdown[-1]["closingBalance"],
            "totalIncome": str(total_income),
            "totalExpense": str(total_expense),
        }
