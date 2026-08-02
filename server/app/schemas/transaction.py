"""Transaction schemas for request/response validation."""

from datetime import datetime
from decimal import Decimal
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


# Request schemas
class TransactionDisplayValue(BaseModel):
    """Unified display format for financial amounts.

    The client should render these fields directly without any logic.
    Compact formatting (万/亿 vs K/M) is handled by client based on user's Locale.

    Fields:
    - sign: '+', '-', or empty
    - value: Plain formatted amount with 2 decimals, e.g., '1234.56'
    - valueFormatted: With thousand separators, e.g., '1,234.56'
    - currencySymbol: e.g., '¥' or '$'
    - fullString: Complete display string, e.g., '- ¥1,234.56'
    """

    sign: str = Field(description="Symbol: '+', '-', or empty")
    value: str = Field(description="Plain formatted amount, e.g., '1234.56'")
    valueFormatted: str = Field(description="With thousand separators, e.g., '1,234.56'")
    currencySymbol: str = Field(description="Currency symbol, e.g., '¥' or '$'")
    fullString: str = Field(description="Complete string with separators, e.g., '- ¥1,234.56'")

    model_config = ConfigDict(populate_by_name=True)

    @classmethod
    def from_params(cls, amount: Decimal, tx_type: str, currency: str = "CNY") -> "TransactionDisplayValue":
        """Factory method to create display value from raw parameters."""
        # 1. Determine Sign
        tx_type_upper = tx_type.upper()
        if tx_type_upper == "INCOME":
            sign = "+"
        elif tx_type_upper == "EXPENSE":
            sign = "-"
        else:
            sign = ""

        # 2. Format Value (plain)
        abs_amount = abs(amount)
        value_str = f"{abs_amount:.2f}"

        # 3. Format Value with thousand separators
        value_formatted = f"{abs_amount:,.2f}"

        # 4. Map Currency Symbol
        currency_map = {
            "CNY": "¥",
            "USD": "$",
            "EUR": "€",
            "GBP": "£",
            "JPY": "¥",
            "CAD": "C$",
            "AUD": "A$",
            "INR": "₹",
            "RUB": "₽",
            "HKD": "HK$",
            "TWD": "NT$",
        }
        symbol = currency_map.get(currency.upper(), currency or "¥")

        # 5. Build Full String (with thousand separators)
        if sign:
            full = f"{sign} {symbol}{value_formatted}"
        else:
            full = f"{symbol}{value_formatted}"

        return cls(sign=sign, value=value_str, valueFormatted=value_formatted, currencySymbol=symbol, fullString=full)


class UpdateAccountRequest(BaseModel):
    """Request schema to update a transaction's associated account."""

    account_id: str | None = Field(None, description="Associated account ID; pass null to disassociate")


class UpdateBatchAccountRequest(BaseModel):
    """Request schema to batch update transactions' associated account."""

    transaction_ids: list[str] = Field(..., description="List of transaction IDs")
    account_id: str | None = Field(..., description="Associated account ID")


class CreateTransactionItem(BaseModel):
    """Information for creating a single transaction.

    Each transaction should have descriptive tags detailing its specific content.
    Example: "Coffee $25, Lunch $35" should produce:
    - Transaction 1: tags=["coffee", "beverage"], amount=25
    - Transaction 2: tags=["bento", "lunch"], amount=35
    """

    amount: str = Field(..., description="Transaction amount")
    tags: list[str] = Field(
        ...,
        min_length=1,
        description="""[Required] Specific tags describing the item content.
Tags for each transaction should accurately reflect the expense.
Examples:
- "Coffee" -> ["coffee", "beverage"]
- "Burger" -> ["burger", "lunch"]
- "Taxi" -> ["taxi", "commute"]""",
    )
    transaction_type: Literal["expense", "income", "transfer"] = Field(default="expense")
    category_key: str = Field(default="OTHERS")
    raw_input: str | None = Field(None, description="Raw input text snippet corresponding to this transaction")

    @field_validator("amount")
    @classmethod
    def validate_amount(cls, v: str) -> str:
        """Validate amount is a positive number."""
        try:
            decimal_val = Decimal(v)
        except Exception as e:
            raise ValueError(f"Invalid amount format: {e}") from e
        if decimal_val <= 0:
            raise ValueError("Amount must be positive")
        return f"{decimal_val:.8f}"


class BatchCreateTransactionRequest(BaseModel):
    """Request schema to batch create transactions."""

    transactions: list[CreateTransactionItem] = Field(..., min_length=1)
    source_account_id: str | None = Field(None, description="Optional global associated account ID")


class TransactionSearchRequest(BaseModel):
    """Request schema to search transactions."""

    keyword: str | None = None
    min_amount: str | None = Field(None, description="Minimum amount as string")
    max_amount: str | None = Field(None, description="Maximum amount as string")
    categories: list[str] | None = None
    payment_methods: list[str] | None = None
    tags: list[str] | None = None
    start_date: str | None = None
    end_date: str | None = None
    page: int = Field(default=1, ge=1)
    per_page: int = Field(default=10, ge=1, le=100)

    @field_validator("min_amount", "max_amount")
    @classmethod
    def validate_amount(cls, v: str | None) -> str | None:
        """Validate amount string if provided."""
        if v is None:
            return None
        try:
            Decimal(v)  # Just validate, don't normalize for search
            return v
        except Exception as e:
            raise ValueError(f"Invalid amount format: {e}")


class RecurringTransactionCreateRequest(BaseModel):
    """create recurring transaction request"""

    # Required fields
    type: str = Field(..., description="Transaction type: EXPENSE, INCOME, TRANSFER")
    amount: str = Field(..., description="Transaction amount as string")
    recurrence_rule: str = Field(..., description="RRULE format", alias="recurrenceRule")
    start_date: str = Field(..., description="YYYY-MM-DD", alias="startDate")

    # Optional account references
    source_account_id: str | None = Field(None, description="Source account UUID", alias="sourceAccountId")
    target_account_id: str | None = Field(None, description="Target account UUID", alias="targetAccountId")

    # Amount settings
    amount_type: str = Field(default="FIXED", description="FIXED or ESTIMATE", alias="amountType")
    requires_confirmation: bool = Field(
        default=False, description="Requires confirmation before generating", alias="requiresConfirmation"
    )
    currency: str = Field(default="CNY", description="Currency code (CNY, USD, JPY, etc.)")

    # Classification
    category_key: str | None = Field(default="OTHERS", description="Category key", alias="categoryKey")
    tags: list[str] | None = Field(default=None, description="Tags list")

    # Rule settings
    timezone: str = Field(default="Asia/Shanghai", description="Timezone for the rule")
    end_date: str | None = Field(default=None, alias="endDate")  # YYYY-MM-DD
    exception_dates: list[str] | None = Field(default=None, alias="exceptionDates")

    # Metadata
    description: str | None = None
    is_active: bool = Field(default=True, alias="isActive")

    model_config = ConfigDict(populate_by_name=True)

    @field_validator("amount")
    @classmethod
    def validate_amount(cls, v: str) -> str:
        """Validate and normalize amount string."""
        try:
            decimal_val = Decimal(v)
            return f"{decimal_val:.8f}"
        except Exception as e:
            raise ValueError(f"Invalid amount format: {e}")

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: str) -> str:
        """Validate transaction type."""
        valid_types = {"EXPENSE", "INCOME", "TRANSFER"}
        if v.upper() not in valid_types:
            raise ValueError(f"Type must be one of: {', '.join(valid_types)}")
        return v.upper()

    @field_validator("amount_type")
    @classmethod
    def validate_amount_type(cls, v: str) -> str:
        """Validate amount type."""
        valid_types = {"FIXED", "ESTIMATE"}
        if v.upper() not in valid_types:
            raise ValueError(f"Amount type must be one of: {', '.join(valid_types)}")
        return v.upper()


# Alias for backward compatibility
RecurringTransactionCreate = RecurringTransactionCreateRequest


class RecurringTransactionUpdateRequest(BaseModel):
    """update recurring transaction request"""

    # Transaction type
    type: str | None = None

    # Account references
    source_account_id: str | None = None
    target_account_id: str | None = None

    # Amount settings
    amount_type: str | None = None
    requires_confirmation: bool | None = None
    amount: str | None = None
    currency: str | None = None

    # Classification
    category_key: str | None = None
    tags: list[str] | None = None

    # Rule settings
    recurrence_rule: str | None = None
    timezone: str | None = None
    start_date: str | None = None
    end_date: str | None = None
    exception_dates: list[str] | None = None

    # Execution control
    next_execution_at: str | None = None

    # Metadata
    description: str | None = None
    is_active: bool | None = None

    @field_validator("amount")
    @classmethod
    def validate_amount(cls, v: str | None) -> str | None:
        """Validate and normalize amount string if provided."""
        if v is None:
            return None
        try:
            decimal_val = Decimal(v)
            return f"{decimal_val:.8f}"
        except Exception as e:
            raise ValueError(f"Invalid amount format: {e}")

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: str | None) -> str | None:
        """Validate transaction type if provided."""
        if v is None:
            return None
        valid_types = {"EXPENSE", "INCOME", "TRANSFER"}
        if v.upper() not in valid_types:
            raise ValueError(f"Type must be one of: {', '.join(valid_types)}")
        return v.upper()

    @field_validator("amount_type")
    @classmethod
    def validate_amount_type(cls, v: str | None) -> str | None:
        """Validate amount type if provided."""
        if v is None:
            return None
        valid_types = {"FIXED", "ESTIMATE"}
        if v.upper() not in valid_types:
            raise ValueError(f"Amount type must be one of: {', '.join(valid_types)}")
        return v.upper()


class CashFlowForecastRequest(BaseModel):
    """cash flow forecast request"""

    forecast_days: int = Field(default=60, ge=1, le=365)
    granularity: str = Field(default="daily")
    scenarios: list[dict[str, Any]] | None = None

    @field_validator("granularity")
    @classmethod
    def validate_granularity(cls, v: str) -> str:
        """Validate granularity"""
        if v not in ["daily", "weekly", "monthly"]:
            raise ValueError("granularity must be one of: daily, weekly, monthly")
        return v


class CommentCreateRequest(BaseModel):
    """create comment request"""

    comment_text: str = Field(min_length=1)
    parent_comment_id: int | None = None
    mentioned_user_ids: list[str] | None = None  # UUIDs of mentioned users


# Response schemas
class TransactionResponse(BaseModel):
    """Transaction response schema with calculated display fields and camelCase aliases."""

    id: str
    user_uuid: str = Field(..., serialization_alias="userUuid")
    type: str  # EXPENSE, INCOME, TRANSFER
    amount: Decimal
    currency: str
    amount_base: Decimal = Field(Decimal("0.0"), serialization_alias="amountBase")
    base_currency: str = Field("CNY", serialization_alias="baseCurrency")
    amount_original: Decimal = Field(Decimal("0.0"), serialization_alias="amountOriginal")
    original_currency: str = Field("CNY", serialization_alias="originalCurrency")
    exchange_rate: str | None = Field(None, serialization_alias="exchangeRate")
    category_key: str | None = Field(None, serialization_alias="categoryKey")
    description: str = ""
    raw_input: str = Field("", serialization_alias="rawInput")
    transaction_at: str | None = Field(None, serialization_alias="transactionAt")
    transaction_timezone: str = Field("Asia/Shanghai", serialization_alias="transactionTimezone")
    created_at: str | None = Field(None, serialization_alias="createdAt")
    tags: list[str] = Field(default_factory=list)
    status: str = "CLEARED"
    location: str | None = None
    source_account_id: str | None = Field(None, serialization_alias="sourceAccountId")
    target_account_id: str | None = Field(None, serialization_alias="targetAccountId")
    display: TransactionDisplayValue

    model_config = ConfigDict(populate_by_name=True, from_attributes=True)


class TransactionDetailResponse(BaseModel):
    """transaction detail response"""

    id: str  # UUID as string
    user_uuid: str
    type: str
    amount: str
    amount_original: str
    currency: str
    exchange_rate: str | None
    category_key: str
    description: str | None
    transaction_at: datetime
    transaction_timezone: str
    tags: list[str] | None
    location: str | None
    latitude: str | None
    longitude: str | None
    source: str
    status: str
    raw_input: str
    source_account_id: str | None = None  # UUID as string
    target_account_id: str | None = None  # UUID as string
    shared_space_id: int | None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class CommentResponse(BaseModel):
    """comment response"""

    id: str
    transaction_id: str
    user_uuid: str
    user_name: str
    user_avatar_url: str
    parent_comment_id: str | None
    comment_text: str
    replied_to_user_uuid: str | None
    replied_to_user_name: str | None
    created_at: str
    updated_at: str | None


class RecurringTransactionResponse(BaseModel):
    """recurring transaction response"""

    id: str  # UUID as string
    user_uuid: str  # UUID as string

    # Transaction type
    type: str  # EXPENSE, INCOME, TRANSFER

    # Account references
    source_account_id: str | None = None
    target_account_id: str | None = None

    # Amount settings
    amount_type: str
    requires_confirmation: bool
    amount: str
    currency: str

    # Classification
    category_key: str | None
    tags: list[str] | None

    # Rule settings
    recurrence_rule: str
    timezone: str
    start_date: str
    end_date: str | None
    exception_dates: list[str] | None

    # Execution control
    last_generated_at: datetime | None
    next_execution_at: datetime | None

    # Metadata
    description: str | None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ForecastDayBreakdown(BaseModel):
    """forecast day breakdown"""

    date: str
    closingBalance: str
    events: list[dict[str, Any]]


class ForecastWarning(BaseModel):
    """forecast warning"""

    date: str
    message: str


class ForecastSummary(BaseModel):
    """forecast summary"""

    startBalance: str
    endBalance: str
    totalIncome: str
    totalExpense: str


class CashFlowForecastResponse(BaseModel):
    """cash flow forecast response"""

    dailyBreakdown: list[ForecastDayBreakdown]
    warnings: list[ForecastWarning]
    summary: ForecastSummary


class PaginatedTransactionResponse(BaseModel):
    """paginated transaction response"""

    data: list[TransactionResponse]
    meta: dict[str, Any]


class TransactionFeedResponse(BaseModel):
    """Paginated transaction feed returned by ``GET /transactions``.

    Matches the existing on-wire shape (``items`` + pagination fields) so the
    response_model can be typed without a client-breaking change.
    """

    items: list[TransactionResponse]
    page: int
    size: int
    total: int
    pages: int
    has_more: bool = Field(serialization_alias="hasMore")

    model_config = ConfigDict(populate_by_name=True)
