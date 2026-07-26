"""Budget schemas for API request/response handling."""

from __future__ import annotations

from datetime import date
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, ValidationInfo, field_validator

# ============================================================================
# Enums (imported from models for consistency)
# ============================================================================
from app.models.budget import (
    BudgetPeriodType,
    BudgetScope,
    BudgetStatus,
)

# ============================================================================
# Request Schemas
# ============================================================================


class BudgetCreateRequest(BaseModel):
    """Request schema for creating a new budget."""

    model_config = ConfigDict(use_enum_values=True)

    name: str | None = Field(
        default=None, max_length=100, description="Budget name. If not provided, will be auto-generated."
    )
    scope: BudgetScope = Field(
        ..., description="Budget scope: TOTAL for overall budget, CATEGORY for category-specific."
    )
    category_key: str | None = Field(
        default=None, max_length=25, description="Category key for category budgets. Required if scope is CATEGORY."
    )
    amount: Decimal = Field(..., gt=0, description="Budget limit amount. Must be greater than 0.")
    period_type: BudgetPeriodType = Field(default=BudgetPeriodType.MONTHLY, description="Budget period type.")
    period_anchor_day: int = Field(
        default=1, ge=1, le=31, description="Day of month to start new period (1-31). Supports salary day mode."
    )
    rollover_enabled: bool = Field(default=True, description="Whether unused budget rolls over to next period.")
    currency_code: str = Field(default="CNY", max_length=3, description="Currency code.")

    @field_validator("category_key")
    @classmethod
    def validate_category_key(cls, v: str | None, info: ValidationInfo) -> str | None:
        """Validate category_key based on scope."""
        scope = info.data.get("scope")
        if scope == BudgetScope.CATEGORY and not v:
            raise ValueError("category_key is required for CATEGORY scope")
        if scope == BudgetScope.TOTAL and v:
            raise ValueError("category_key must be empty for TOTAL scope")
        return v


class BudgetUpdateRequest(BaseModel):
    """Request schema for updating a budget."""

    model_config = ConfigDict(use_enum_values=True)

    name: str | None = Field(default=None, max_length=100)
    amount: Decimal | None = Field(default=None, gt=0)
    rollover_enabled: bool | None = None
    status: BudgetStatus | None = None
    period_anchor_day: int | None = Field(default=None, ge=1, le=31)


class BudgetRebalanceRequest(BaseModel):
    """Request schema for rebalancing between budgets."""

    from_budget_id: UUID = Field(..., description="Source budget ID to transfer from.")
    to_budget_id: UUID = Field(..., description="Target budget ID to transfer to.")
    amount: Decimal = Field(..., gt=0, description="Amount to transfer.")

    @field_validator("to_budget_id")
    @classmethod
    def validate_different_budgets(cls, v: UUID, info: ValidationInfo) -> UUID:
        """Ensure source and target are different."""
        from_id = info.data.get("from_budget_id")
        if from_id and v == from_id:
            raise ValueError("Cannot rebalance to the same budget")
        return v


class BudgetSettingsUpdateRequest(BaseModel):
    """Request schema for updating budget settings."""

    model_config = ConfigDict(use_enum_values=True)

    warning_threshold: int | None = Field(default=None, ge=0, le=100)
    alert_threshold: int | None = Field(default=None, ge=0, le=100)


# ============================================================================
# Response Schemas
# ============================================================================


class BudgetPeriodResponse(BaseModel):
    """Response schema for a budget period."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    period_start: date
    period_end: date
    spent_amount: str
    rollover_in: str
    rollover_out: str
    adjusted_target: str
    remaining_amount: str
    usage_percentage: float
    status: str
    ai_forecast: str | None = None
    notes: str | None = None


class BudgetResponse(BaseModel):
    """Response schema for a budget with current period status.

    Monetary fields are serialized as strings to preserve Decimal precision
    and avoid IEEE-754 floating-point rounding errors.
    """

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    scope: str
    category_key: str | None = None
    amount: str
    currency_code: str
    period_type: str
    period_anchor_day: int
    rollover_enabled: bool
    rollover_balance: str
    source: str
    ai_confidence: float | None = None
    status: str

    # Calculated fields for current period
    spent_amount: str = "0"
    remaining_amount: str = "0"
    usage_percentage: float = 0.0
    period_status: str = "ON_TRACK"
    period_start: date | None = None
    period_end: date | None = None
    ai_forecast: str | None = None

    # Timestamps
    created_at: str | None = None
    updated_at: str | None = None


class BudgetAlert(BaseModel):
    """Budget alert information."""

    budget_id: UUID
    budget_name: str
    category_key: str | None = None
    alert_type: str  # "warning" | "exceeded" | "forecast_exceed"
    message: str
    usage_percentage: float
    remaining_amount: str


class BudgetSummaryResponse(BaseModel):
    """Response schema for budget overview."""

    total_budget: BudgetResponse | None = None
    category_budgets: list[BudgetResponse] = []
    overall_spent: str = "0"
    overall_remaining: str = "0"
    overall_percentage: float = 0.0
    alerts: list[BudgetAlert] = []
    period_start: date | None = None
    period_end: date | None = None


class BudgetSuggestion(BaseModel):
    """AI-generated budget suggestion."""

    scope: str  # TOTAL or CATEGORY
    category_key: str | None = None
    suggested_amount: str
    confidence: float
    reasoning: str
    based_on_months: int = 3


class BudgetSettingsResponse(BaseModel):
    """Response schema for budget settings."""

    model_config = ConfigDict(from_attributes=True)

    user_uuid: UUID
    warning_threshold: int
    alert_threshold: int
