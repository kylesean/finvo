"""Finance analysis tools (read-only, typed).

Replace the reviewing-finances skill scripts: analyzing past spending and cash
flow are well-defined read-only operations with stable parameters, so they are
typed tool calls instead of LLM-composed shell commands.
"""

from __future__ import annotations

from collections import defaultdict
from datetime import date, datetime, timedelta
from decimal import Decimal
from typing import Any, cast

from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from pydantic import BaseModel, Field

from app.core.database import get_session_context
from app.core.langgraph.tools._helpers import get_user_uuid
from app.services.statistics_service import StatisticsService
from app.services.transaction_query_service import (
    TransactionQueryParams,
    TransactionQueryService,
    TransactionType,
)

# ============================================================================
# analyze_spending
# ============================================================================


def _wow_trend(total: Decimal, prev_total: Decimal) -> dict[str, Any]:
    """Previous-period comparison badge payload (JSON-native floats)."""
    change = total - prev_total
    if prev_total > 0:
        pct = float(change / prev_total * 100)
    else:
        pct = 0.0 if total == 0 else 100.0
    return {
        "change_amount": float(change),
        "change_percent": round(pct, 1),
        "direction": "up" if change > 0 else "down" if change < 0 else "flat",
        "prev_total": float(prev_total),
    }


def _analyze_spending(
    transactions: list[dict[str, Any]],
    days: int = 90,
    prev_total: Decimal | None = None,
) -> dict[str, Any]:
    """Analyze spending patterns from transaction records.

    Returns structured data only — the assistant generates localized text.

    The payload shape is a GenUI contract: ``BudgetAnalysisCard`` validates
    ``total_expense`` (Number), ``period_days`` (Integer), ``by_category``
    (Object), ``trends`` (Object), ``top_spenders`` (List of objects) and
    ``suggestions`` (List of ``{type, category_key?, percentage?, count?}``
    objects). Keep every value JSON-native (float/int/str/list/dict) —
    Decimal/datetime leaks fail client schema validation and the card
    silently never renders.

    Args:
        transactions: Current-window expense/income rows.
        days: Window length; scales the frequent-small-transaction threshold.
        prev_total: Previous equal-length window expense total (base currency).
            When given, emits ``trends.week_over_week`` for short windows where
            month-over-month is meaningless (e.g. a 7-day week).
    """
    if not transactions:
        trends: dict[str, Any] = {}
        if prev_total is not None:
            trends["week_over_week"] = _wow_trend(Decimal("0"), prev_total)
        return {
            "by_category": {},
            "by_month": {},
            "trends": trends,
            "top_spenders": [],
            "suggestions": [],
            "total_expense": 0.0,
            "transaction_count": 0,
            "period_days": days,
        }

    by_category: dict[str, dict[str, Any]] = defaultdict(
        lambda: {"total": Decimal("0"), "count": 0, "transactions": []}
    )
    by_month: dict[str, dict[str, Any]] = defaultdict(lambda: {"total": Decimal("0"), "count": 0})

    all_expenses = []

    for tx in transactions:
        if str(tx.get("type", "")).upper() != "EXPENSE":
            continue

        try:
            amount = abs(Decimal(str(tx.get("amount", 0))))
        except Exception:  # defensive: skip malformed rows, never fail the card
            continue
        category = tx.get("category_key") or "OTHERS"
        # transaction_at is the source of truth (when the money moved);
        # created_at is only a fallback (when the record was booked).
        # Both arrive as ISO strings via TransactionItem, but coerce defensively.
        raw_date = tx.get("transaction_at") or tx.get("created_at") or ""
        tx_date = str(raw_date)[:10] if raw_date else ""
        month = tx_date[:7] if len(tx_date) >= 7 else "unknown"

        by_category[category]["total"] += amount
        by_category[category]["count"] += 1
        by_category[category]["transactions"].append(
            {
                "amount": float(amount),
                "date": tx_date,
                "description": tx.get("description", ""),
            }
        )

        by_month[month]["total"] += amount
        by_month[month]["count"] += 1

        all_expenses.append(
            {
                "amount": float(amount),
                "category": category,
                "description": tx.get("description", ""),
                "date": tx_date,
            }
        )

    total_expense = sum((c["total"] for c in by_category.values()), Decimal("0"))

    category_breakdown = {}
    for cat, data in by_category.items():
        pct = float(data["total"] / total_expense * 100) if total_expense > 0 else 0
        category_breakdown[cat] = {
            "total": float(data["total"]),
            "count": data["count"],
            "percentage": round(pct, 1),
            "avg_per_tx": float(data["total"] / data["count"]) if data["count"] > 0 else 0,
        }

    months = sorted(by_month.keys())
    month_data = {m: {"total": float(by_month[m]["total"]), "count": by_month[m]["count"]} for m in months}

    trends = {}
    if len(months) >= 2:
        last_month = cast(Decimal, by_month[months[-1]]["total"])
        prev_month = cast(Decimal, by_month[months[-2]]["total"])
        change = last_month - prev_month
        change_pct = float(change / prev_month * 100) if prev_month > 0 else 0
        trends["month_over_month"] = {
            "change_amount": float(change),
            "change_percent": round(change_pct, 1),
            "direction": "up" if change > 0 else "down" if change < 0 else "flat",
        }

    if prev_total is not None:
        trends["week_over_week"] = _wow_trend(total_expense, prev_total)

    top_spenders = sorted(all_expenses, key=lambda x: x["amount"], reverse=True)[:5]

    suggestions = []
    sorted_cats = sorted(category_breakdown.items(), key=lambda x: x[1]["total"], reverse=True)

    if sorted_cats:
        top_cat = sorted_cats[0]
        if top_cat[1]["percentage"] > 40:
            suggestions.append(
                {"type": "high_percentage", "category_key": top_cat[0], "percentage": top_cat[1]["percentage"]}
            )

    if trends.get("month_over_month", {}).get("direction") == "up":
        pct = float(trends["month_over_month"]["change_percent"])
        if pct > 20:
            suggestions.append({"type": "monthly_increase", "percentage": pct})

    small_frequent: dict[str, int] = defaultdict(int)
    for tx in all_expenses:
        if tx["amount"] < 50:
            small_frequent[tx["category"]] += 1

    # Scale with the window: 10 hits made sense for the 90-day default, but a
    # 7-day week can never reach it. floor of 3 keeps weekly noise out.
    frequent_threshold = max(3, round(days / 9))
    for cat, count in small_frequent.items():
        if count >= frequent_threshold:
            suggestions.append({"type": "frequent_small", "category_key": cat, "count": count})

    return {
        "by_category": category_breakdown,
        "by_month": month_data,
        "trends": trends,
        "top_spenders": top_spenders,
        "suggestions": suggestions,
        "total_expense": float(total_expense),
        "transaction_count": len(all_expenses),
        "period_days": days,
    }


class AnalyzeSpendingInput(BaseModel):
    """Input for analyze_spending tool."""

    start_date: str | None = Field(
        default=None,
        description="Start date (YYYY-MM-DD). For 'this week' use Monday of the current week; for 'this month' use the 1st.",
    )
    end_date: str | None = Field(default=None, description="End date (YYYY-MM-DD), usually today")
    days: int = Field(default=90, description="Fallback analysis period in days when dates are omitted")
    category: str | None = Field(default=None, description="Optional category key filter (e.g. FOOD_DINING)")


def _parse_ymd(value: str | None) -> date | None:
    """Parse a YYYY-MM-DD (or ISO datetime) string to a date; None on failure."""
    if not value or not isinstance(value, str):
        return None
    try:
        return datetime.fromisoformat(value.strip()[:10]).date()
    except ValueError:
        return None


async def _sum_expense_window(
    service: TransactionQueryService,
    user_uuid_str: str,
    start_iso: str,
    end_iso: str,
    category: str | None = None,
) -> Decimal:
    """Sum base-currency EXPENSE in a window, paging through all rows.

    Previous-period comparison needs a total, not item details — accumulate
    without storing rows to keep the LLM context untouched.
    """
    total = Decimal("0")
    page = 1
    while True:
        params = TransactionQueryParams(
            start_date=start_iso,
            end_date=end_iso,
            transaction_types=[TransactionType.EXPENSE],
            per_page=100,
            page=page,
        )
        if category:
            params.category_keys = [category]
        result = await service.search(user_uuid_str, params)
        for item in result.items:
            try:
                total += abs(Decimal(str(item.amount)))
            except Exception:  # defensive: skip malformed rows
                continue
        if not result.has_more or page >= 10:
            break
        page += 1
    return total


@tool("analyze_spending", args_schema=AnalyzeSpendingInput)
async def analyze_spending(
    start_date: str | None = None,
    end_date: str | None = None,
    days: int = 90,
    category: str | None = None,
    *,
    config: RunnableConfig,
) -> dict[str, Any]:
    """Analyze the user's past spending by category, month and trends.

    USE WHEN the user asks about a spending breakdown, category analysis or
    expense patterns — including "本周消费/this week" (pass Monday→today as
    start_date/end_date). Returns structured data for the GenUI
    BudgetAnalysisCard; the assistant narrates the insights and localizes
    category names. Do NOT substitute search_transactions: it returns a raw
    list without category percentages, trends or suggestions, and its card
    cannot render a breakdown.
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "error": "User not authenticated"}

    try:
        async with get_session_context() as session:
            # "Today" must be the user's local date, not the server's.
            # Single source of truth, shared with DynamicContextMiddleware:
            # per-request config → users.timezone (refreshed at login from the
            # client OS timezone) → Asia/Shanghai. The displayed date the model
            # computes Monday from and this fallback path always agree.
            from app.utils.timezone_utils import resolve_timezone

            user_tz_name = config.get("configurable", {}).get("user_timezone")
            if not user_tz_name:
                try:
                    from app.services.statistics_scope import get_user_timezone

                    user_tz_name = await get_user_timezone(session, user_uuid)
                except Exception:
                    user_tz_name = None
            user_tz = resolve_timezone(user_tz_name, fallback="Asia/Shanghai")
            today = datetime.now(user_tz).date()

            start_d = _parse_ymd(start_date)
            end_d = _parse_ymd(end_date)
            if start_d and end_d:
                if end_d < start_d:
                    start_d, end_d = end_d, start_d
                days = max((end_d - start_d).days + 1, 1)
            else:
                end_d = today
                start_d = end_d - timedelta(days=max(int(days), 1))

            service = TransactionQueryService(session)
            # Amounts are aggregated in the user's base currency (item.amount),
            # so multi-currency ledgers never sum mixed denominations.
            from app.utils.currency_utils import get_user_display_currency

            display_currency = await get_user_display_currency(session, user_uuid)

            # Paginate through the whole window: per_page is capped at 100 by
            # the query params, and truncating at the first page would silently
            # under-report busy weeks. Cap total rows to bound LLM context.
            gathered: list[Any] = []
            page = 1
            total = 0
            while True:
                params = TransactionQueryParams(
                    start_date=start_d.isoformat(),
                    end_date=end_d.isoformat(),
                    transaction_types=[TransactionType.EXPENSE],
                    per_page=100,
                    page=page,
                )
                if category:
                    params.category_keys = [category]
                result = await service.search(str(user_uuid), params)
                total = result.total
                gathered.extend(result.items)
                if not result.has_more or len(gathered) >= 1000 or page >= 10:
                    break
                page += 1

            transactions = [
                {
                    # Occurrence time, NOT record-creation time: backfilled
                    # entries must land in the week the money moved.
                    "transaction_at": item.transaction_at,
                    "created_at": item.created_at,
                    "amount": item.amount,
                    "currency": item.currency,
                    "type": item.type,
                    "category_key": item.category_key,
                    "description": item.description,
                }
                for item in gathered
            ]

            # Short windows (week / two-week views) get a previous-period
            # comparison: month-over-month never fires inside one month, so
            # without this the card shows no trend badge at all.
            prev_total: Decimal | None = None
            if days <= 14:
                prev_end_d = start_d - timedelta(days=1)
                prev_start_d = prev_end_d - timedelta(days=days - 1)
                prev_total = await _sum_expense_window(
                    service,
                    str(user_uuid),
                    prev_start_d.isoformat(),
                    prev_end_d.isoformat(),
                    category,
                )

            analysis = _analyze_spending(transactions, days, prev_total)
            return {
                "success": True,
                "componentType": "BudgetAnalysisCard",
                "title": "Spending Analysis",
                "currency": display_currency,
                "start_date": start_d.isoformat(),
                "end_date": end_d.isoformat(),
                "total": total,
                "truncated": len(gathered) < total,
                **analysis,
            }
    except Exception as e:  # pragma: no cover - defensive
        return {"success": False, "error": str(e)}


# ============================================================================
# analyze_cashflow
# ============================================================================


def _days_to_time_range(days: int) -> str:
    """Convert days to the StatisticsService time_range string."""
    if days <= 7:
        return "week"
    elif days <= 30:
        return "month"
    elif days <= 90:
        return "quarter"
    else:
        return "year"


class AnalyzeCashflowInput(BaseModel):
    """Input for analyze_cashflow tool."""

    days: int = Field(default=90, description="Analysis period in days")
    start_date: str | None = Field(default=None, description="Start date (YYYY-MM-DD)")
    end_date: str | None = Field(default=None, description="End date (YYYY-MM-DD)")


@tool("analyze_cashflow", args_schema=AnalyzeCashflowInput)
async def analyze_cashflow(
    days: int = 90,
    start_date: str | None = None,
    end_date: str | None = None,
    *,
    config: RunnableConfig,
) -> dict[str, Any]:
    """Analyze the user's income vs expense balance and financial health score.

    USE WHEN the user asks about cash flow, savings rate, income/expense
    balance or financial health. Returns data for the GenUI CashFlowCard.
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "error": "User not authenticated"}

    try:
        effective_days = days
        if start_date and end_date:
            try:
                s_date = datetime.fromisoformat(start_date).date()
                e_date = datetime.fromisoformat(end_date).date()
                effective_days = max((e_date - s_date).days, 1)
            except ValueError:
                pass

        time_range = _days_to_time_range(effective_days)

        async with get_session_context() as session:
            service = StatisticsService(session)
            cash_flow = (await service.get_cash_flow(user_uuid=user_uuid, time_range=time_range)).model_dump()
            health_score = (await service.get_health_score(user_uuid=user_uuid, time_range=time_range)).model_dump()

            return {
                "success": True,
                # GenUI signal - CamelCase naming
                "type": "CashFlowCard",
                "componentType": "CashFlowCard",
                "title": "Cash Flow & Health Report",
                "netCashFlow": cash_flow.get("netCashFlow", 0),
                "savingsRate": cash_flow.get("savingsRate", 0),
                "totalIncome": cash_flow.get("totalIncome", 0),
                "totalExpense": cash_flow.get("totalExpense", 0),
                "expenseToIncomeRatio": cash_flow.get("expenseToIncomeRatio", 0),
                "essentialExpenseRatio": cash_flow.get("essentialExpenseRatio", 0),
                "discretionaryExpenseRatio": cash_flow.get("discretionaryExpenseRatio", 0),
                "incomeChangePercent": cash_flow.get("incomeChangePercent", 0),
                "expenseChangePercent": cash_flow.get("expenseChangePercent", 0),
                "savingsRateChange": cash_flow.get("savingsRateChange", 0),
                "healthScore": health_score.get("totalScore", 0),
                "healthGrade": health_score.get("grade", "C"),
                "healthDimensions": health_score.get("dimensions", []),
                "suggestions": health_score.get("suggestions", []),
                # Raw data for the assistant's narrative
                "analysis": cash_flow,
                "health_score": health_score,
            }
    except Exception as e:  # pragma: no cover - defensive
        return {"success": False, "error": str(e)}


# Export
analysis_tools = [analyze_spending, analyze_cashflow]
