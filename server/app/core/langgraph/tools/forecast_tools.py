"""Balance forecast tool (read-only, typed).

Replaces the forecasting-finances skill script: predicting future balance is a
well-defined read-only operation, so it is a typed tool call instead of an
LLM-composed shell command.
"""

from __future__ import annotations

from datetime import date
from decimal import Decimal
from typing import Any

from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from pydantic import BaseModel, Field

from app.core.database import db_manager
from app.core.langgraph.tools._helpers import get_user_uuid
from app.core.langgraph.tools.context import current_session_language
from app.services.forecast_service import ForecastService

# Localized component title keyed by language (zh, zh-Hant, ja, ko, en).
_FORECAST_TITLE: dict[str, str] = {
    "zh": "未来余额预测",
    "zh-Hant": "未來餘額預測",
    "ja": "将来残高予測",
    "ko": "미래 잔액 예측",
    "en": "Financial Cash Flow Forecast",
}


class ForecastBalanceInput(BaseModel):
    """Input for forecast_balance tool."""

    days: int = Field(default=30, description="Forecast period in days")
    simulate_purchase: bool = Field(default=False, description="Simulate the impact of a purchase")
    amount: float = Field(default=0, description="Purchase amount for the simulation")
    description: str = Field(default="Purchase", description="Purchase description")


@tool("forecast_balance", args_schema=ForecastBalanceInput)
async def forecast_balance(
    days: int = 30,
    simulate_purchase: bool = False,
    amount: float = 0,
    description: str = "Purchase",
    *,
    config: RunnableConfig,
) -> dict[str, Any]:
    """Predict the user's future balance and evaluate purchase affordability.

    USE WHEN the user asks about a balance forecast, future projection, "can I
    afford X" or a purchase simulation. Returns data for the GenUI
    CashFlowForecastChart.
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "error": "User not authenticated"}

    language = current_session_language.get() or "zh"
    title = _FORECAST_TITLE.get(language, _FORECAST_TITLE["en"])

    try:
        async with db_manager.session_factory() as session:
            service = ForecastService(session)

            if simulate_purchase and amount > 0:
                purchase_date = date.today()
                result = await service.simulate_purchase(
                    user_uuid=user_uuid,
                    amount=Decimal(str(amount)),
                    purchase_date=purchase_date,
                    description=description,
                    language=language,
                )
                result_dict = result.to_dict()
                result_dict["purchase_analysis"] = {
                    "purchase_date": purchase_date.isoformat(),
                    "purchase_amount": -abs(amount),
                    "description": description,
                }
            else:
                result = await service.generate_cash_flow_forecast(
                    user_uuid=user_uuid,
                    forecast_days=days,
                    language=language,
                )
                result_dict = result.to_dict()

            # Insufficient data = new/empty user (no balance, no recurring, no history)
            first_day_events = result.data_points[0].events if result.data_points else []
            has_meaningful_data = (
                result.current_balance != Decimal("0")
                or len(first_day_events) > 1  # more than just default daily spending
                or result.summary.total_recurring_income > Decimal("0")
                or result.summary.total_recurring_expense > Decimal("0")
            )

            output: dict[str, Any] = {
                "success": True,
                # GenUI signal - CamelCase naming
                "type": "CashFlowForecastChart",
                "title": title,
                **result_dict,
            }

            if not has_meaningful_data:
                output["data_quality"] = "insufficient"
                output["guidance"] = (
                    "There is insufficient financial data in the current account to generate a meaningful forecast. "
                    "Recommend adding account balances or recording transactions before using the forecast feature."
                )

            return output
    except Exception as e:  # pragma: no cover - defensive
        return {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__,
            "retryable": False,
        }


# Export
forecast_tools = [forecast_balance]
