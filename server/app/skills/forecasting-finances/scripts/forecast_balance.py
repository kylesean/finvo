#!/usr/bin/env python3
"""Balance Forecast Script - Cash Flow Prediction

This script uses ForecastService to predict future cash flow.
It follows AgentSkills.io best practice: scripts call services for data.

Usage:
    uv run python app/skills/forecasting-finances/scripts/forecast_balance.py --days 30
    uv run python app/skills/forecasting-finances/scripts/forecast_balance.py --simulate-purchase --amount 5000 --description "iPhone"

Environment:
    USER_ID: Required. User UUID (injected by execute tool).

Output (JSON):
    {
        "success": true,
        "type": "CashFlowForecastChart",  # GenUI component type
        ...forecast data...
    }

Note:
    No aiInsight field - LLM generates insights in user's language.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import sys
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any
from uuid import UUID


def json_serializer(obj: Any) -> Any:
    """JSON serializer for objects not serializable by default."""
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Type {type(obj)} not serializable")


# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent.parent))

from app.core.database import db_manager  # noqa: E402  # noqa: E402
from app.services.forecast_service import ForecastService  # noqa: E402  # noqa: E402


async def main() -> None:
    """Execution entry point for the skill script."""
    parser = argparse.ArgumentParser(description="Forecast cash flow")
    parser.add_argument("--days", type=int, default=30, help="Forecast period in days")
    parser.add_argument("--simulate-purchase", action="store_true", help="Simulate a purchase")
    parser.add_argument("--amount", type=float, default=0, help="Purchase amount")
    parser.add_argument("--description", type=str, default="Purchase", help="Purchase description")
    args = parser.parse_args()

    # Get user ID from environment
    user_id = os.environ.get("USER_ID")
    if not user_id:
        print(json.dumps({"success": False, "error": "USER_ID environment variable not set"}, ensure_ascii=False))
        sys.exit(1)

    try:
        user_uuid = UUID(user_id)

        async with db_manager.session_factory() as session:
            service = ForecastService(session)

            if args.simulate_purchase and args.amount > 0:
                # Simulate purchase impact
                purchase_date = date.today()

                result = await service.simulate_purchase(
                    user_uuid=user_uuid,
                    amount=Decimal(str(args.amount)),
                    purchase_date=purchase_date,
                    description=args.description,
                )

                # Convert to dict
                result_dict = result.to_dict()

                # Add purchase info
                result_dict["purchase_analysis"] = {
                    "purchase_date": purchase_date.isoformat(),
                    "purchase_amount": -abs(args.amount),
                    "description": args.description,
                }

            else:
                # Standard forecast
                result = await service.generate_cash_flow_forecast(
                    user_uuid=user_uuid,
                    forecast_days=args.days,
                )

                # Convert to dict
                result_dict = result.to_dict()

            # Check for insufficient data scenario:
            # No balance + no recurring events + no historical spending = new/empty user
            first_day_events = result.data_points[0].events if result.data_points else []
            has_meaningful_data = (
                result.current_balance != Decimal("0")
                or len(first_day_events) > 1  # more than just default daily spending
                or result.summary.total_recurring_income > Decimal("0")
                or result.summary.total_recurring_expense > Decimal("0")
            )

            # Output with GenUI signal
            # Note: No aiInsight - LLM generates insights in user's language
            output = {
                "success": True,
                # GenUI signal - CamelCase naming
                "type": "CashFlowForecastChart",
                "title": "未来财务趋势预测",
                # Forecast data
                **result_dict,
            }

            # Add guidance for empty/new user scenario
            if not has_meaningful_data:
                output["data_quality"] = "insufficient"
                output["guidance"] = (
                    "当前账户没有足够的财务数据来生成有意义的预测。"
                    "建议用户先添加账户余额或记录一些交易后，再使用预测功能。"
                )

            print(json.dumps(output, ensure_ascii=False, indent=2, default=json_serializer))

    except Exception as e:
        error_msg = str(e)
        # Provide structured error info to help LLM understand the failure
        print(
            json.dumps(
                {
                    "success": False,
                    "error": error_msg,
                    "error_type": type(e).__name__,
                    "retryable": False,
                    "suggestion": "此错误为确定性错误，重试不会产生不同结果。请根据错误信息向用户解释情况。",
                },
                ensure_ascii=False,
            )
        )
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
