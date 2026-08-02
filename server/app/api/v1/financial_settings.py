"""Financial settings API endpoints."""

from typing import Annotated

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse

from app.core.aliases import CurrentUser
from app.core.responses import ResponseEnvelope, success_response
from app.core.service_deps import get_user_service
from app.schemas.user import (
    FinancialSettingsResponseSchema,
    UpdateFinancialSettingsRequest,
)
from app.services.user_service import UserService

router = APIRouter(prefix="/financial-settings", tags=["financial-settings"])


@router.get("", response_model=ResponseEnvelope[FinancialSettingsResponseSchema])
async def get_financial_settings(
    current_user: CurrentUser,
    user_service: Annotated[UserService, Depends(get_user_service)],
) -> JSONResponse:
    """Get current user's financial settings.

    Args:
        current_user: The authenticated user
        user_service: Injected user service

    Returns:
        Unified response with financial settings
    """
    settings = await user_service.get_financial_settings(current_user.uuid)

    return success_response(
        data=FinancialSettingsResponseSchema(
            safetyThreshold=str(settings.safety_threshold),
            dailyBurnRate=str(settings.daily_burn_rate),
            burnRateMode=settings.burn_rate_mode,
            primaryCurrency=settings.primary_currency,
            monthStartDay=settings.month_start_day,
            updatedAt=settings.updated_at.isoformat() if settings.updated_at else None,
        ),
        message="Financial settings retrieved successfully",
    )


@router.patch("", response_model=ResponseEnvelope[FinancialSettingsResponseSchema])
async def update_financial_settings(
    request: UpdateFinancialSettingsRequest,
    current_user: CurrentUser,
    user_service: Annotated[UserService, Depends(get_user_service)],
) -> JSONResponse:
    """Update current user's financial settings.

    Uses UPSERT to create settings if they don't exist.

    Args:
        request: Settings update data
        current_user: The authenticated user
        user_service: Injected user service

    Returns:
        Unified response with updated financial settings
    """
    settings = await user_service.update_financial_settings(
        user_uuid=current_user.uuid,
        safety_threshold=request.safetyThreshold,
        daily_burn_rate=request.dailyBurnRate,
        burn_rate_mode=request.burnRateMode,
        primary_currency=request.primaryCurrency,
        month_start_day=request.monthStartDay,
    )

    return success_response(
        data=FinancialSettingsResponseSchema(
            safetyThreshold=str(settings.safety_threshold),
            dailyBurnRate=str(settings.daily_burn_rate),
            burnRateMode=settings.burn_rate_mode,
            primaryCurrency=settings.primary_currency,
            monthStartDay=settings.month_start_day,
            updatedAt=settings.updated_at.isoformat() if settings.updated_at else None,
        ),
        message="Financial settings updated successfully",
    )
