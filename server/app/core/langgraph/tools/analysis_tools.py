"""Finance analysis tools (read-only, typed).

Replace the reviewing-finances skill scripts: analyzing past spending and cash
flow are well-defined read-only operations with stable parameters, so they are
typed tool calls instead of LLM-composed shell commands.
"""

from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Any, cast

from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from pydantic import BaseModel, Field

from app.core.database import db_manager
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


def _analyze_spending(transactions: list[dict[str, Any]], days: int = 90) -> dict[str, Any]:
    """Analyze spending patterns from transaction records.

    Returns structured data only — the assistant generates localized text.
    """
    if not transactions:
        return {
            "by_category": {},
            "by_month": {},
            "trends": {},
            "top_spenders": [],
            "suggestions": [],
            "total_expense": 0,
        }

    by_category: dict[str, dict[str, Any]] = defaultdict(
        lambda: {"total": Decimal("0"), "count": 0, "transactions": []}
    )
    by_month: dict[str, dict[str, Any]] = defaultdict(lambda: {"total": Decimal("0"), "count": 0})

    all_expenses = []

    for tx in transactions:
        if tx.get("type", "").upper() != "EXPENSE":
            continue

        amount = Decimal(str(tx.get("amount", 0)))
        category = tx.get("category_key", "OTHERS")
        tx_date = tx.get("transaction_at", tx.get("created_at", ""))[:10]
        month = tx_date[:7] if tx_date else "unknown"

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

    for cat, count in small_frequent.items():
        if count >= 10:
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

    start_date: str | None = Field(default=None, description="Start date (YYYY-MM-DD)")
    end_date: str | None = Field(default=None, description="End date (YYYY-MM-DD)")
    days: int = Field(default=90, description="Fallback analysis period in days when dates are omitted")
    category: str | None = Field(default=None, description="Optional category key filter (e.g. FOOD_DINING)")


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
    expense patterns. Returns structured data for the GenUI BudgetAnalysisCard;
    the assistant narrates the insights and localizes category names.
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "error": "User not authenticated"}

    try:
        if start_date and end_date:
            try:
                start = datetime.fromisoformat(start_date).date()
                end = datetime.fromisoformat(end_date).date()
                days = max((end - start).days, 1)
            except ValueError:
                end = datetime.now().date()
                start = end - timedelta(days=days)
        else:
            end = datetime.now().date()
            start = end - timedelta(days=days)

        async with db_manager.session_factory() as session:
            service = TransactionQueryService(session)
            params = TransactionQueryParams(
                start_date=start.isoformat(),
                end_date=end.isoformat(),
                transaction_types=[TransactionType.EXPENSE],
                per_page=100,
            )
            if category:
                params.category_keys = [category]

            result = await service.search(str(user_uuid), params)

            transactions = [
                {
                    "transaction_at": item.created_at,
                    "amount": item.amount_original,
                    "type": item.type,
                    "category_key": item.category_key,
                    "description": item.description,
                }
                for item in result.items
            ]

            analysis = _analyze_spending(transactions, days)
            return {"success": True, "componentType": "BudgetAnalysisCard", "title": "Spending Analysis", **analysis}
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

        async with db_manager.session_factory() as session:
            service = StatisticsService(session)
            cash_flow = (await service.get_cash_flow(user_uuid=user_uuid, time_range=time_range)).model_dump()
            health_score = (await service.get_health_score(user_uuid=user_uuid, time_range=time_range)).model_dump()

            return {
                "success": True,
                # GenUI signal - CamelCase naming
                "type": "CashFlowCard",
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
