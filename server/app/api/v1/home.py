"""Home page API endpoints.

Provides endpoints for home page data including:
- Total expense summary
- Calendar month heatmap details
"""

from typing import Annotated, Any

from fastapi import APIRouter, Depends, Query
from fastapi.responses import JSONResponse

from app.core.aliases import CurrentUser
from app.core.responses import ResponseEnvelope, success_response
from app.core.service_deps import get_statistics_service
from app.services.statistics_service import StatisticsService

router = APIRouter(prefix="/home", tags=["home"])

StatsService = Annotated[StatisticsService, Depends(get_statistics_service)]


@router.get("/total-expense", response_model=ResponseEnvelope[dict[str, Any]])
async def get_total_expense(
    current_user: CurrentUser,
    service: StatsService,
) -> JSONResponse:
    """Get user's expense summary, including today, month, year, and total expense.

    Returns:
       Unified response format, containing detailed expense statistics
    """
    data = await service.get_total_expense_summary(current_user.uuid)
    return success_response(
        data=data,
        message="Expense statistics retrieved successfully",
    )


@router.get("/calendar-month-details", response_model=ResponseEnvelope[dict[str, Any]])
async def get_calendar_month_details(
    current_user: CurrentUser,
    service: StatsService,
    year: int = Query(..., ge=2000, le=2100, description="Year"),
    month: int = Query(..., ge=1, le=12, description="Month"),
) -> JSONResponse:
    """Get calendar month details for the specified month.

    Args:
        current_user: Current authenticated user
        service: Injected StatisticsService instance
        year: Year
        month: Month

    Returns:
        Unified response format, containing daily expense summary and heat level
    """
    data = await service.get_calendar_month_details(current_user.uuid, year, month)
    return success_response(
        data=data,
        message="Calendar month details retrieved successfully",
    )
