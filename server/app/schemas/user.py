"""Pydantic schemas for user management endpoints."""

from __future__ import annotations

from decimal import Decimal
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.models.financial_settings import BurnRateMode
from app.schemas.transaction import TransactionDisplayValue

# =============================================================================
# Financial Account Schemas
# =============================================================================


class FinancialAccountItem(BaseModel):
    """Schema for a single financial account item.

    Attributes:
        name: Account name (e.g., "Checking Account")
        nature: Account nature ('ASSET' or 'LIABILITY')
        type: Account type (e.g., 'CASH', 'DEPOSIT', 'CREDIT_CARD')
        initialBalance: Initial balance amount
        currencyCode: Currency code (default: 'CNY')
        includeInNetWorth: Whether to include in net worth calculation
        status: Account status (default: 'ACTIVE')
    """

    id: UUID | None = Field(default=None, description="Account ID (present when updating an existing account, absent when creating a new one)")
    name: str = Field(..., description="Account name", max_length=100)
    nature: Literal["ASSET", "LIABILITY"] = Field(..., description="Account nature")
    type: (
        Literal["CASH", "DEPOSIT", "E_MONEY", "INVESTMENT", "RECEIVABLE", "CREDIT_CARD", "LOAN", "PAYABLE"] | None
    ) = Field(None, description="Account type", max_length=50)
    initialBalance: str = Field(default="0", description="Initial balance", alias="initial_balance")
    currentBalance: str = Field(default="0", description="Current balance", alias="current_balance")
    currencyCode: str = Field(default="CNY", description="Currency code", alias="currency_code", max_length=3)
    includeInNetWorth: bool = Field(
        default=True, description="Include in net worth calculation", alias="include_in_net_worth"
    )
    includeInCashFlow: bool = Field(
        default=False, description="Include in cash flow forecast", alias="include_in_cash_flow"
    )
    display: TransactionDisplayValue | None = Field(None, description="Display value object")
    status: Literal["ACTIVE", "INACTIVE", "CLOSED"] = Field(default="ACTIVE", description="Account status")

    model_config = ConfigDict(populate_by_name=True)

    @field_validator("initialBalance")
    @classmethod
    def validate_balance(cls, v: str) -> str:
        """Validate balance is a valid decimal string.

        Args:
            v: Balance string to validate

        Returns:
            str: Validated balance string

        Raises:
            ValueError: If balance is invalid
        """
        try:
            decimal_val = Decimal(v)
            return f"{decimal_val:.8f}"  # 8 decimal places to match DB precision
        except Exception as e:
            raise ValueError(f"Invalid balance format: {e}")

    @field_validator("currentBalance")
    @classmethod
    def validate_current_balance(cls, v: str) -> str:
        """Validate current balance is a valid decimal string."""
        try:
            decimal_val = Decimal(v)
            return f"{decimal_val:.8f}"
        except Exception as e:
            raise ValueError(f"Invalid balance format: {e}")

    @field_validator("nature")
    @classmethod
    def validate_nature(cls, v: str) -> str:
        """Validate nature is either ASSET or LIABILITY."""
        if v not in ("ASSET", "LIABILITY"):
            raise ValueError("nature must be 'ASSET' or 'LIABILITY'")
        return v


class SaveFinancialAccountsRequest(BaseModel):
    """Request schema for saving financial accounts.

    Attributes:
        accounts: List of financial account items
    """

    accounts: list[FinancialAccountItem] = Field(..., description="List of financial accounts")

    @field_validator("accounts")
    @classmethod
    def validate_accounts_not_empty(cls, v: list[FinancialAccountItem]) -> list[FinancialAccountItem]:
        """Validate that accounts list is not empty.

        Args:
            v: List of accounts to validate

        Returns:
            List[FinancialAccountItem]: Validated accounts list

        Raises:
            ValueError: If accounts list is empty
        """
        if not v:
            raise ValueError("Accounts list cannot be empty")
        return v


class FinancialAccountResponse(BaseModel):
    """Response schema for a single financial account.

    Attributes:
        id: Account ID (UUID)
        name: Account name
        nature: Account nature
        type: Account type
        currencyCode: Currency code
        initialBalance: Initial balance
        includeInNetWorth: Whether included in net worth
        status: Account status
        createdAt: Creation timestamp
        updatedAt: Last update timestamp
    """

    id: str  # UUID as string
    name: str
    nature: str
    type: str | None = None
    currencyCode: str
    initialBalance: str
    currentBalance: str = "0"
    includeInNetWorth: bool
    includeInCashFlow: bool = False
    display: TransactionDisplayValue | None = None
    status: str = Field(default="ACTIVE")
    createdAt: str | None = None
    updatedAt: str | None = None


class FinancialAccountsResponse(BaseModel):
    """Response schema for get financial accounts endpoint.

    Attributes:
        accounts: List of financial accounts
        totalBalance: Net worth (assets - liabilities)
        lastUpdatedAt: ISO 8601 timestamp of last update
    """

    accounts: list[FinancialAccountResponse]
    totalBalance: str
    lastUpdatedAt: str


class SaveFinancialAccountsResponse(BaseModel):
    """Response schema for save financial accounts endpoint.

    Attributes:
        totalBalance: Net worth after saving
        lastUpdatedAt: ISO 8601 timestamp of save operation
    """

    totalBalance: str
    lastUpdatedAt: str


class CreateFinancialAccountRequest(BaseModel):
    """Request schema for creating a single financial account."""

    id: UUID | None = Field(default=None, description="Account ID (present when updating an existing account, absent when creating a new one)")
    name: str = Field(..., description="Account name", max_length=100)
    nature: Literal["ASSET", "LIABILITY"] = Field(..., description="Account nature")
    type: (
        Literal["CASH", "DEPOSIT", "E_MONEY", "INVESTMENT", "RECEIVABLE", "CREDIT_CARD", "LOAN", "PAYABLE"] | None
    ) = Field(None, description="Account type", max_length=50)
    initialBalance: str = Field(default="0", description="Initial balance")
    currentBalance: str = Field(default="0", description="Current balance")
    currencyCode: str = Field(default="CNY", description="Currency code", max_length=3)
    includeInNetWorth: bool = Field(default=True, description="Include in net worth calculation")
    includeInCashFlow: bool = Field(default=False, description="Include in cash flow forecast")
    status: Literal["ACTIVE", "INACTIVE", "CLOSED"] = Field(default="ACTIVE", description="Account status")

    @field_validator("initialBalance")
    @classmethod
    def validate_balance(cls, v: str) -> str:
        """Validate that the balance string is a valid decimal format."""
        try:
            decimal_val = Decimal(v)
            return f"{decimal_val:.8f}"
        except Exception as e:
            raise ValueError(f"Invalid balance format: {e}")


class UpdateFinancialAccountRequest(BaseModel):
    """Request schema for updating a financial account."""

    name: str | None = Field(None, max_length=100)
    nature: Literal["ASSET", "LIABILITY"] | None = None
    type: (
        Literal["CASH", "DEPOSIT", "E_MONEY", "INVESTMENT", "RECEIVABLE", "CREDIT_CARD", "LOAN", "PAYABLE"] | None
    ) = Field(None, max_length=50)
    initialBalance: str | None = None
    currentBalance: str | None = None
    currencyCode: str | None = Field(None, max_length=3)
    includeInNetWorth: bool | None = None
    includeInCashFlow: bool | None = None
    status: Literal["ACTIVE", "INACTIVE"] | None = None  # CLOSED is managed via POST .../close

    @field_validator("initialBalance", "currentBalance")
    @classmethod
    def validate_balance(cls, v: str | None) -> str | None:
        """Validate that the balance string is a valid decimal format or None."""
        if v is None:
            return v
        try:
            decimal_val = Decimal(v)
            return f"{decimal_val:.8f}"
        except Exception as e:
            raise ValueError(f"Invalid balance format: {e}")


# =============================================================================
# Financial Account Lifecycle Schemas (merge / close)
# =============================================================================


class MergeFinancialAccountsRequest(BaseModel):
    """Request schema for merging one account into another.

    Semantics: the source account's transactions / recurring rules are
    re-pointed to the target account, the source is deleted, and the target's
    balance is recomputed from the ledger. This is the "I created the wrong /
    duplicate account" correction path — no money actually moves, so no
    TRANSFER transaction is generated.
    """

    target_account_id: UUID = Field(..., description="Target account to merge the source into")


class CloseFinancialAccountRequest(BaseModel):
    """Request schema for closing (archiving) an account.

    Semantics: archive keeps all historical transactions linked to the account
    and freezes its balance snapshot; the account no longer appears in new
    transaction account pickers or net worth.

    ``disposal`` decides how a non-zero balance is handled before closing:
    - ``keep``     — freeze the balance as-is (user accepts the snapshot)
    - ``transfer`` — generate a TRANSFER to ``target_account_id`` (real money moved)
    - ``writeoff`` — generate an EXPENSE/INCOME write-off entry
    """

    disposal: Literal["keep", "transfer", "writeoff"] = Field(
        default="keep", description="How to dispose of the remaining balance before closing"
    )
    target_account_id: UUID | None = Field(
        default=None, description="Required when disposal is 'transfer'"
    )

    @model_validator(mode="after")
    def validate_disposal(self) -> CloseFinancialAccountRequest:
        """Require a target account when transferring the balance out."""
        if self.disposal == "transfer" and self.target_account_id is None:
            raise ValueError("target_account_id is required when disposal is 'transfer'")
        if self.disposal == "keep" or self.disposal == "writeoff":
            self.target_account_id = None
        return self


class MergeFinancialAccountsResponse(BaseModel):
    """Response schema for a successful account merge."""

    source_id: str = Field(..., description="Deleted source account ID")
    target_id: str = Field(..., description="Surviving target account ID")
    moved_transactions: int = Field(..., description="Transactions re-pointed to the target")
    moved_recurring: int = Field(..., description="Recurring rules re-pointed to the target")
    target_currency: str = Field(..., description="Currency of the merged account")
    target_balance: str = Field(..., description="Recomputed balance of the merged account")


class CloseFinancialAccountResponse(BaseModel):
    """Response schema for a successful account close."""

    account_id: str = Field(..., description="Closed account ID")
    status: str = Field(..., description="New account status (CLOSED)")
    disposal: str = Field(..., description="Effective disposal applied (keep/transfer/writeoff)")
    transaction_id: str | None = Field(None, description="Generated disposal transaction, if any")
    final_balance: str = Field(..., description="Balance snapshot after closing")


# =============================================================================
# Financial Safety Line Schemas
# =============================================================================


class FinancialSafetyLineRequest(BaseModel):
    """Request schema for updating financial safety line.

    Attributes:
        safetyBalanceThreshold: The safety threshold value
        threshold: Alias for safetyBalanceThreshold (for compatibility)
    """

    safetyBalanceThreshold: str = Field(..., description="Safety balance threshold", alias="threshold")

    model_config = ConfigDict(populate_by_name=True)  # Allow both field names

    @field_validator("safetyBalanceThreshold")
    @classmethod
    def validate_threshold(cls, v: str) -> str:
        """Validate threshold is a valid decimal string.

        Args:
            v: Threshold string to validate

        Returns:
            str: Validated threshold string

        Raises:
            ValueError: If threshold is invalid
        """
        try:
            decimal_val = Decimal(v)
            if decimal_val < 0:
                raise ValueError("Threshold must be non-negative")
            return f"{decimal_val:.2f}"
        except Exception as e:
            raise ValueError(f"Invalid threshold format: {e}")


class FinancialSafetyLineResponse(BaseModel):
    """Response schema for financial safety line update.

    Attributes:
        safetyBalanceThreshold: The updated threshold value
        updatedAt: ISO 8601 timestamp of update
    """

    safetyBalanceThreshold: str
    updatedAt: str | None = None


# =============================================================================
# Onboarding Schemas
# =============================================================================


class OnboardingStatusResponse(BaseModel):
    """Response schema for onboarding status check.

    Attributes:
        isCompleted: Whether onboarding is complete
    """

    isCompleted: bool


# =============================================================================
# User Settings Schemas
# =============================================================================


class UserSettingsRequest(BaseModel):
    """Request schema for updating user settings.

    Attributes:
        safetyBalanceThreshold: Optional safety threshold
        estimatedAvgDailySpending: Optional estimated daily spending
    """

    safetyBalanceThreshold: str | None = Field(None, description="Safety balance threshold")
    estimatedAvgDailySpending: str | None = Field(None, description="Estimated average daily spending")

    @field_validator("safetyBalanceThreshold", "estimatedAvgDailySpending")
    @classmethod
    def validate_decimal_fields(cls, v: str | None) -> str | None:
        """Validate decimal fields.

        Args:
            v: Value to validate

        Returns:
            str | None: Validated value

        Raises:
            ValueError: If value is invalid
        """
        if v is None:
            return v
        try:
            decimal_val = Decimal(v)
            if decimal_val < 0:
                raise ValueError("Value must be non-negative")
            return f"{decimal_val:.2f}"
        except Exception as e:
            raise ValueError(f"Invalid decimal format: {e}")

    @model_validator(mode="after")
    def validate_at_least_one_field(self) -> UserSettingsRequest:
        """Validate that at least one field is provided.

        Returns:
            UserSettingsRequest: The validated instance

        Raises:
            ValueError: If no fields are provided
        """
        if self.safetyBalanceThreshold is None and self.estimatedAvgDailySpending is None:
            raise ValueError("At least one field must be provided")
        return self


class UserSettingsResponse(BaseModel):
    """Response schema for user settings.

    Attributes:
        defaultCurrency: Default currency (placeholder, not implemented yet)
        timezone: User's timezone (placeholder, not implemented yet)
        estimatedAvgDailySpending: Estimated average daily spending
        safetyBalanceThreshold: Safety balance threshold
        createdAt: ISO 8601 timestamp of creation
        updatedAt: ISO 8601 timestamp of last update
    """

    defaultCurrency: str = "USD"  # Placeholder
    timezone: str = "Asia/Shanghai"  # Placeholder
    estimatedAvgDailySpending: str
    safetyBalanceThreshold: str
    createdAt: str
    updatedAt: str | None = None


# =============================================================================
# User Info Schemas
# =============================================================================


class UserInfoResponse(BaseModel):
    """Response schema for user information.

    Attributes:
        id: User's UUID
        email: User's email
        mobile: User's mobile number
        username: User's username
        avatarUrl: User's avatar URL
        createdAt: Account creation timestamp
        updatedAt: Last update timestamp
        clientLastLoginAt: Last login timestamp
    """

    id: str
    email: str | None = None
    mobile: str | None = None
    username: str
    avatarUrl: str | None = None
    createdAt: str
    updatedAt: str | None = None
    clientLastLoginAt: str | None = None


class UpdateUserProfileRequest(BaseModel):
    """Request schema for updating user profile.

    Attributes:
        username: New username (optional)
        avatarUrl: New avatar URL (optional)
    """

    username: str | None = Field(None, min_length=1, max_length=50, description="User's display name")
    avatarUrl: str | None = Field(None, max_length=500, description="Avatar image URL")

    @model_validator(mode="after")
    def validate_at_least_one_field(self) -> UpdateUserProfileRequest:
        """Validate that at least one field is provided."""
        if self.username is None and self.avatarUrl is None:
            raise ValueError("At least one field (username or avatarUrl) must be provided")
        return self


# =============================================================================
# Financial Settings Schemas (NEW)
# =============================================================================


class FinancialSettingsResponseSchema(BaseModel):
    """Response schema for financial settings.

    Attributes:
        safetyThreshold: Minimum safe balance threshold
        dailyBurnRate: Daily spending estimate
        burnRateMode: How burn rate is calculated (MANUAL or AI_AUTO)
        primaryCurrency: Default display currency
        monthStartDay: Day of month to start calculations
        updatedAt: Last update timestamp
    """

    safetyThreshold: str
    dailyBurnRate: str
    burnRateMode: BurnRateMode = BurnRateMode.AI_AUTO
    primaryCurrency: str = "USD"
    monthStartDay: int = 1
    updatedAt: str | None = None


class UpdateFinancialSettingsRequest(BaseModel):
    """Request schema for updating financial settings.

    All fields are optional - only provided fields will be updated.
    """

    safetyThreshold: str | None = Field(None, description="Minimum safe balance threshold")
    dailyBurnRate: str | None = Field(None, description="Daily spending estimate")
    burnRateMode: BurnRateMode | None = Field(None, description="Burn rate mode")
    primaryCurrency: str | None = Field(None, max_length=3, description="Primary currency code")
    monthStartDay: int | None = Field(None, ge=1, le=31, description="Month start day")

    @field_validator("safetyThreshold", "dailyBurnRate")
    @classmethod
    def validate_decimal_fields(cls, v: str | None) -> str | None:
        """Validate decimal fields."""
        if v is None:
            return v
        try:
            decimal_val = Decimal(v)
            if decimal_val < 0:
                raise ValueError("Value must be non-negative")
            return f"{decimal_val:.8f}"
        except Exception as e:
            raise ValueError(f"Invalid decimal format: {e}")

    @model_validator(mode="after")
    def validate_at_least_one_field(self) -> UpdateFinancialSettingsRequest:
        """Validate that at least one field is provided."""
        if all(
            v is None
            for v in [
                self.safetyThreshold,
                self.dailyBurnRate,
                self.burnRateMode,
                self.primaryCurrency,
                self.monthStartDay,
            ]
        ):
            raise ValueError("At least one field must be provided")
        return self
