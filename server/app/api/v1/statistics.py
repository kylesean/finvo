"""Statistics API endpoints for financial analysis."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query

from app.core.aliases import CurrentUser
from app.core.responses import ResponseEnvelope
from app.core.service_deps import get_statistics_service
from app.schemas.statistics import (
    CashFlowResponse,
    CategoryBreakdownResponse,
    HealthScoreResponse,
    StatisticsOverviewResponse,
    StatisticsQueryParams,
    TopTransactionsResponse,
    TrendDataResponse,
)
from app.services.statistics_service import StatisticsService

router = APIRouter(prefix="/statistics", tags=["statistics"])

# Shared query params (time_range/start_date/end_date/account_types/tz_offset)
# injected via Depends(); parse account_types via params.account_types_list.
StatsParams = Annotated[StatisticsQueryParams, Depends()]
StatsService = Annotated[StatisticsService, Depends(get_statistics_service)]


@router.get("/overview", response_model=ResponseEnvelope[StatisticsOverviewResponse])
async def get_statistics_overview(
    params: StatsParams,
    current_user: CurrentUser,
    service: StatsService,
) -> ResponseEnvelope[StatisticsOverviewResponse]:
    """Get statistics overview including balance, income, expense, and change percentage."""
    result = await service.get_overview(
        user_uuid=current_user.uuid,
        time_range=params.time_range,
        start_date=params.start_date,
        end_date=params.end_date,
        account_types=params.account_types_list,
        tz_offset_minutes=params.tz_offset,
    )

    return ResponseEnvelope(code=0, message="Statistics overview retrieved successfully", data=result)


@router.get("/trends", response_model=ResponseEnvelope[TrendDataResponse])
async def get_trend_data(
    params: StatsParams,
    current_user: CurrentUser,
    service: StatsService,
    transaction_type: str = Query(
        default="expense", pattern="^(expense|income)$", description="Transaction type: expense or income"
    ),
) -> ResponseEnvelope[TrendDataResponse]:
    """Get trend data for chart visualization."""
    result = await service.get_trend_data(
        user_uuid=current_user.uuid,
        time_range=params.time_range,
        transaction_type=transaction_type,
        start_date=params.start_date,
        end_date=params.end_date,
        account_types=params.account_types_list,
    )

    return ResponseEnvelope(code=0, message="Trend data retrieved successfully", data=result)


@router.get("/categories", response_model=ResponseEnvelope[CategoryBreakdownResponse])
async def get_category_breakdown(
    params: StatsParams,
    current_user: CurrentUser,
    service: StatsService,
    transaction_type: str = Query(
        default="expense", pattern="^(expense|income)$", description="Transaction type: expense or income"
    ),
    limit: int = Query(default=10, ge=1, le=50),
) -> ResponseEnvelope[CategoryBreakdownResponse]:
    """Get breakdown by category for specified transaction type."""
    result = await service.get_category_breakdown(
        user_uuid=current_user.uuid,
        time_range=params.time_range,
        start_date=params.start_date,
        end_date=params.end_date,
        account_types=params.account_types_list,
        tz_offset_minutes=params.tz_offset,
        transaction_type=transaction_type,
        limit=limit,
    )

    return ResponseEnvelope(code=0, message="Category breakdown retrieved successfully", data=result)


@router.get("/top-transactions", response_model=ResponseEnvelope[TopTransactionsResponse])
async def get_top_transactions(
    params: StatsParams,
    current_user: CurrentUser,
    service: StatsService,
    transaction_type: str = Query(
        default="expense", pattern="^(expense|income)$", description="Transaction type: expense or income"
    ),
    sort_by: str = Query(default="amount", pattern="^(amount|date)$", description="Sort by: amount or date"),
    page: int = Query(default=1, ge=1),
    size: int = Query(default=10, ge=1, le=50),
) -> ResponseEnvelope[TopTransactionsResponse]:
    """Get top transactions for the period."""
    result = await service.get_top_transactions(
        user_uuid=current_user.uuid,
        time_range=params.time_range,
        start_date=params.start_date,
        end_date=params.end_date,
        account_types=params.account_types_list,
        tz_offset_minutes=params.tz_offset,
        transaction_type=transaction_type,
        sort_by=sort_by,
        page=page,
        size=size,
    )

    return ResponseEnvelope(code=0, message="Top transactions retrieved successfully", data=result)


@router.get("/cash-flow", response_model=ResponseEnvelope[CashFlowResponse])
async def get_cash_flow_analysis(
    params: StatsParams,
    current_user: CurrentUser,
    service: StatsService,
) -> ResponseEnvelope[CashFlowResponse]:
    """Get comprehensive cash flow analysis for the period."""
    result = await service.get_cash_flow(
        user_uuid=current_user.uuid,
        time_range=params.time_range,
        start_date=params.start_date,
        end_date=params.end_date,
        account_types=params.account_types_list,
        tz_offset_minutes=params.tz_offset,
    )

    return ResponseEnvelope(code=0, message="Cash flow analysis retrieved successfully", data=result)


@router.get("/health-score", response_model=ResponseEnvelope[HealthScoreResponse])
async def get_health_score(
    params: StatsParams,
    current_user: CurrentUser,
    service: StatsService,
) -> ResponseEnvelope[HealthScoreResponse]:
    """Get financial health score based on multiple dimensions."""
    result = await service.get_health_score(
        user_uuid=current_user.uuid,
        time_range=params.time_range,
        start_date=params.start_date,
        end_date=params.end_date,
        account_types=params.account_types_list,
        tz_offset_minutes=params.tz_offset,
    )

    return ResponseEnvelope(code=0, message="Health score retrieved successfully", data=result)
