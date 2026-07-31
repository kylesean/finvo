"""Statistics API endpoints for financial analysis."""

from fastapi import APIRouter, Depends, Query
from fastapi.responses import JSONResponse

from app.core.dependencies import get_current_user
from app.core.responses import success_response
from app.core.service_deps import get_statistics_service
from app.models.user import User
from app.services.statistics_service import StatisticsService

router = APIRouter(prefix="/statistics", tags=["statistics"])


@router.get("/overview")
async def get_statistics_overview(
    time_range: str = Query(default="month", description="Time range: week, month, year, or custom"),
    start_date: str | None = Query(default=None, description="Start date for custom range (ISO 8601)"),
    end_date: str | None = Query(default=None, description="End date for custom range (ISO 8601)"),
    account_types: str | None = Query(default=None, description="Comma-separated account types to filter"),
    tz_offset: int | None = Query(default=None, description="Timezone offset in minutes"),
    current_user: User = Depends(get_current_user),
    service: StatisticsService = Depends(get_statistics_service),
) -> JSONResponse:
    """Get statistics overview including balance, income, expense, and change percentage."""
    account_type_list = [t.strip() for t in account_types.split(",")] if account_types else None

    result = await service.get_overview(
        user_uuid=current_user.uuid,
        time_range=time_range,
        start_date=start_date,
        end_date=end_date,
        account_types=account_type_list,
        tz_offset_minutes=tz_offset,
    )

    return success_response(data=result.model_dump(), message="Statistics overview retrieved successfully")


@router.get("/trends")
async def get_trend_data(
    time_range: str = Query(default="month"),
    transaction_type: str = Query(default="expense", description="Transaction type: expense or income"),
    start_date: str | None = Query(default=None),
    end_date: str | None = Query(default=None),
    account_types: str | None = Query(default=None),
    current_user: User = Depends(get_current_user),
    service: StatisticsService = Depends(get_statistics_service),
) -> JSONResponse:
    """Get trend data for chart visualization."""
    account_type_list = [t.strip() for t in account_types.split(",")] if account_types else None

    result = await service.get_trend_data(
        user_uuid=current_user.uuid,
        time_range=time_range,
        transaction_type=transaction_type,
        start_date=start_date,
        end_date=end_date,
        account_types=account_type_list,
    )

    return success_response(data=result.model_dump(), message="Trend data retrieved successfully")


@router.get("/categories")
async def get_category_breakdown(
    time_range: str = Query(default="month"),
    start_date: str | None = Query(default=None),
    end_date: str | None = Query(default=None),
    account_types: str | None = Query(default=None),
    transaction_type: str = Query(default="expense", description="Transaction type: expense or income"),
    limit: int = Query(default=10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    service: StatisticsService = Depends(get_statistics_service),
) -> JSONResponse:
    """Get breakdown by category for specified transaction type."""
    account_type_list = [t.strip() for t in account_types.split(",")] if account_types else None

    result = await service.get_category_breakdown(
        user_uuid=current_user.uuid,
        time_range=time_range,
        start_date=start_date,
        end_date=end_date,
        account_types=account_type_list,
        transaction_type=transaction_type,
        limit=limit,
    )

    return success_response(data=result.model_dump(), message="Category breakdown retrieved successfully")


@router.get("/top-transactions")
async def get_top_transactions(
    time_range: str = Query(default="month"),
    start_date: str | None = Query(default=None),
    end_date: str | None = Query(default=None),
    account_types: str | None = Query(default=None),
    transaction_type: str = Query(default="expense", description="Transaction type: expense or income"),
    sort_by: str = Query(default="amount", description="Sort by: amount or date"),
    page: int = Query(default=1, ge=1),
    size: int = Query(default=10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    service: StatisticsService = Depends(get_statistics_service),
) -> JSONResponse:
    """Get top transactions for the period."""
    account_type_list = [t.strip() for t in account_types.split(",")] if account_types else None

    result = await service.get_top_transactions(
        user_uuid=current_user.uuid,
        time_range=time_range,
        start_date=start_date,
        end_date=end_date,
        account_types=account_type_list,
        transaction_type=transaction_type,
        sort_by=sort_by,
        page=page,
        size=size,
    )

    return success_response(data=result.model_dump(), message="Top transactions retrieved successfully")


@router.get("/cash-flow")
async def get_cash_flow_analysis(
    time_range: str = Query(default="month"),
    start_date: str | None = Query(default=None),
    end_date: str | None = Query(default=None),
    account_types: str | None = Query(default=None),
    current_user: User = Depends(get_current_user),
    service: StatisticsService = Depends(get_statistics_service),
) -> JSONResponse:
    """Get comprehensive cash flow analysis for the period."""
    account_type_list = [t.strip() for t in account_types.split(",")] if account_types else None

    result = await service.get_cash_flow(
        user_uuid=current_user.uuid,
        time_range=time_range,
        start_date=start_date,
        end_date=end_date,
        account_types=account_type_list,
    )

    return success_response(data=result.model_dump(), message="Cash flow analysis retrieved successfully")


@router.get("/health-score")
async def get_health_score(
    time_range: str = Query(default="month"),
    start_date: str | None = Query(default=None),
    end_date: str | None = Query(default=None),
    account_types: str | None = Query(default=None),
    current_user: User = Depends(get_current_user),
    service: StatisticsService = Depends(get_statistics_service),
) -> JSONResponse:
    """Get financial health score based on multiple dimensions."""
    account_type_list = [t.strip() for t in account_types.split(",")] if account_types else None

    result = await service.get_health_score(
        user_uuid=current_user.uuid,
        time_range=time_range,
        start_date=start_date,
        end_date=end_date,
        account_types=account_type_list,
    )

    return success_response(data=result.model_dump(), message="Health score retrieved successfully")
