"""Budget API routes for managing user budgets."""

from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, status
from fastapi.responses import JSONResponse

from app.core.dependencies import get_current_user
from app.core.exceptions import BusinessError, CommonErrorCode, NotFoundError, ValidationError
from app.core.responses import success_response
from app.core.service_deps import get_budget_service
from app.models.budget import BudgetScope, BudgetStatus
from app.models.user import User
from app.schemas.budget import (
    BudgetCreateRequest,
    BudgetRebalanceRequest,
    BudgetResponse,
    BudgetSettingsResponse,
    BudgetSettingsUpdateRequest,
    BudgetSuggestion,
    BudgetSummaryResponse,
    BudgetUpdateRequest,
)
from app.services.budget_service import BudgetService

router = APIRouter(prefix="/budgets", tags=["Budget"])


# ============================================================================
# Budget CRUD
# ============================================================================


@router.post("", response_model=BudgetResponse, status_code=status.HTTP_201_CREATED)
async def create_budget(
    request: BudgetCreateRequest,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Create a new budget.

    Creates either a total budget (scope=TOTAL) or a category-specific budget
    (scope=CATEGORY with category_key).

    Only one active total budget and one active category budget per category
    are allowed for each user.
    """
    # Check for duplicate
    existing = await service.get_user_budgets(
        current_user.uuid,
        status=BudgetStatus.ACTIVE,
        scope=BudgetScope(request.scope) if isinstance(request.scope, str) else request.scope,
    )

    for budget in existing:
        if request.scope == BudgetScope.TOTAL and budget.is_total_budget:
            raise BusinessError(
                "Active total budget already exists. Please pause or archive it first.",
                error_code=CommonErrorCode.CONFLICT,
                status_code=409,
            )
        if request.scope == BudgetScope.CATEGORY and budget.category_key == request.category_key:
            raise BusinessError(
                f"Active budget for category '{request.category_key}' already exists.",
                error_code=CommonErrorCode.CONFLICT,
                status_code=409,
            )

    budget = await service.create_budget(current_user.uuid, request)
    period = await service.get_or_create_current_period(budget)

    return success_response(
        data=await service.build_budget_response(budget, period),
        http_status=201,
    )


@router.get("", response_model=list[BudgetResponse])
async def get_budgets(
    scope: str | None = None,
    status_filter: str | None = None,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Get all budgets for the current user."""
    try:
        scope_enum = BudgetScope(scope) if scope else None
        status_enum = BudgetStatus(status_filter) if status_filter else None
    except ValueError:
        raise ValidationError("Invalid scope or status filter")

    budgets = await service.get_user_budgets_with_periods(
        current_user.uuid,
        status=status_enum,
        scope=scope_enum,
    )

    return success_response(data=budgets)


@router.get("/summary", response_model=BudgetSummaryResponse)
async def get_budget_summary(
    include_paused: bool = False,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Get budget summary with budgets and alerts."""
    return success_response(data=await service.get_budget_summary(current_user.uuid, include_paused=include_paused))


@router.get("/suggestions", response_model=list[BudgetSuggestion])
async def get_budget_suggestions(
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Get AI-generated budget suggestions based on historical spending."""
    suggestions = []

    # Total budget suggestion
    total_suggestion = await service.suggest_budget(current_user.uuid)
    suggestions.append(total_suggestion)

    # Category suggestions for problem categories
    problem_categories = await service.detect_problem_categories(current_user.uuid)
    for category_key in problem_categories[:3]:  # Top 3 problem categories
        category_suggestion = await service.suggest_budget(current_user.uuid, category_key=category_key)
        suggestions.append(category_suggestion)

    return success_response(data=suggestions)


@router.get("/{budget_id}", response_model=BudgetResponse)
async def get_budget(
    budget_id: UUID,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Get a specific budget by ID."""
    budget = await service.get_budget(budget_id, current_user.uuid)
    if not budget:
        raise NotFoundError("Budget")

    period = await service.get_or_create_current_period(budget)
    period = await service.update_period_spent_amount(budget, period)

    return success_response(data=await service.build_budget_response(budget, period))


@router.put("/{budget_id}", response_model=BudgetResponse)
async def update_budget(
    budget_id: UUID,
    request: BudgetUpdateRequest,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Update a budget."""
    budget = await service.update_budget(budget_id, current_user.uuid, request)
    if not budget:
        raise NotFoundError("Budget")

    period = await service.get_or_create_current_period(budget)
    period = await service.update_period_spent_amount(budget, period)

    return success_response(data=await service.build_budget_response(budget, period))


@router.delete("/{budget_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_budget(
    budget_id: UUID,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> None:
    """Delete a budget."""
    success = await service.delete_budget(budget_id, current_user.uuid)
    if not success:
        raise NotFoundError("Budget")


# ============================================================================
# Rebalance
# ============================================================================


@router.post("/rebalance", status_code=status.HTTP_200_OK)
async def rebalance_budgets(
    request: BudgetRebalanceRequest,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Rebalance amount between two budgets."""
    result_code = await service.rebalance_with_status(
        request.from_budget_id,
        request.to_budget_id,
        request.amount,
        current_user.uuid,
    )

    if result_code == "INVALID_AMOUNT":
        raise BusinessError(
            "Transfer amount must be greater than zero",
            error_code=CommonErrorCode.VALIDATION_ERROR,
        )
    if result_code == "NOT_FOUND":
        raise NotFoundError("One or more budgets")
    if result_code == "INSUFFICIENT_FUNDS":
        raise BusinessError(
            "Insufficient budget amount to rebalance",
            error_code=CommonErrorCode.VALIDATION_ERROR,
        )

    return success_response(message="Budget rebalanced successfully")


# ============================================================================
# Settings
# ============================================================================


@router.get("/settings/me", response_model=BudgetSettingsResponse)
async def get_budget_settings(
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Get current user's budget settings."""
    settings = await service.get_or_create_settings(current_user.uuid)

    return success_response(
        data=BudgetSettingsResponse(
            user_uuid=settings.user_uuid,
            warning_threshold=settings.warning_threshold,
            alert_threshold=settings.alert_threshold,
        )
    )


@router.put("/settings/me", response_model=BudgetSettingsResponse)
async def update_budget_settings(
    request: BudgetSettingsUpdateRequest,
    current_user: User = Depends(get_current_user),
    service: BudgetService = Depends(get_budget_service),
) -> JSONResponse:
    """Update current user's budget settings."""
    settings = await service.update_settings(current_user.uuid, request)

    return success_response(
        data=BudgetSettingsResponse(
            user_uuid=settings.user_uuid,
            warning_threshold=settings.warning_threshold,
            alert_threshold=settings.alert_threshold,
        )
    )
