"""Transaction Query Service — full-featured query implementation.

This module hosts the canonical ``TransactionQueryService`` used directly by
API endpoints (``api/v1/transaction.py``), LangGraph tools
(``transaction_tools.py``), ``service_deps.py`` and the skills layer
(``analyze_spending.py``). Its API centers on ``search()`` +
``TransactionQueryParams``.

This module is the **single** query implementation: the former facade-internal
``TransactionFacadeQueryHelper`` (``app/services/transaction/query_service.py``)
was removed because its ``get_transaction_feed`` / ``search_transactions`` had
no production callers — only the facade delegating into it and a unit test.

Best practice: Business logic lives here, not in API routes or tool definitions.
"""

from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from enum import Enum
from typing import Any
from uuid import UUID

from dateutil import parser as dateutil_parser, tz
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import db_manager
from app.core.logging import logger
from app.models.transaction import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.schemas.transaction import TransactionDisplayValue
from app.utils.currency_utils import get_user_display_currency

# ============================================================================
# Enums
# ============================================================================


class TransactionType(str, Enum):
    """Transaction type enum."""

    EXPENSE = "EXPENSE"
    INCOME = "INCOME"
    TRANSFER = "TRANSFER"


# ============================================================================
# Response Models with Computed Fields
# ============================================================================

# TransactionDisplayValue has been moved to app.schemas.transaction


class TransactionItem(BaseModel):
    """Response model for a single transaction record."""

    id: str
    user_uuid: str
    type: str
    amount: Decimal
    amount_original: Decimal
    currency: str
    category_key: str | None = None
    description: str | None = None
    transaction_at: str
    transaction_timezone: str
    location: str | None = None
    tags: list[str] | None = None
    source: str
    status: str
    raw_input: str | None = None
    source_account_id: str | None = None
    target_account_id: str | None = None
    created_at: str | None = None
    updated_at: str | None = None
    display: TransactionDisplayValue

    @classmethod
    def from_transaction(cls, tx: Transaction, display_currency: str = "CNY") -> TransactionItem:
        """Create a response model instance from a Transaction model.

        Displays original currency amount while preserving currency context.

        Args:
            tx: Transaction model instance.
            display_currency: User primary currency.
        """
        original_currency = (tx.currency or display_currency).upper()
        amount_orig = (
            tx.amount_original if isinstance(tx.amount_original, Decimal) else Decimal(str(tx.amount_original))
        )
        amount_val = tx.amount if isinstance(tx.amount, Decimal) else Decimal(str(tx.amount or "0.0"))

        return cls(
            id=str(tx.uuid),
            user_uuid=str(tx.user_uuid),
            type=tx.type,
            amount=amount_val,
            amount_original=amount_orig,
            currency=original_currency,
            category_key=tx.category_key,
            description=tx.description or "",
            transaction_at=tx.transaction_at.isoformat() if tx.transaction_at else "",
            transaction_timezone=tx.transaction_timezone,
            location=tx.location,
            tags=tx.tags,
            source=tx.source,
            status=tx.status,
            raw_input=tx.raw_input,
            source_account_id=str(tx.source_account_id) if tx.source_account_id else None,
            target_account_id=str(tx.target_account_id) if tx.target_account_id else None,
            created_at=tx.created_at.isoformat() if tx.created_at else None,
            updated_at=tx.updated_at.isoformat() if tx.updated_at else None,
            display=TransactionDisplayValue.from_params(
                amount=amount_orig, tx_type=tx.type, currency=original_currency
            ),
        )


class TransactionQueryResult(BaseModel):
    """Transaction query result model."""

    items: list[TransactionItem]
    total: int
    page: int
    per_page: int
    pages: int
    has_more: bool


# ============================================================================
# Query Parameters
# ============================================================================


class TransactionQueryParams(BaseModel):
    """Transaction query parameters model."""

    keyword: str | None = Field(
        default=None, description="Keyword search across description, location, category_key, and tags"
    )
    min_amount: Decimal | None = Field(default=None, description="Minimum amount (absolute value)")
    max_amount: Decimal | None = Field(default=None, description="Maximum amount (absolute value)")
    transaction_types: list[TransactionType] | None = Field(default=None, description="List of transaction types")
    category_keys: list[str] | None = Field(default=None, description="List of category keys")
    tags: list[str] | None = Field(default=None, description="List of tags")
    start_date: str | None = Field(default=None, description="Start date (ISO 8601)")
    end_date: str | None = Field(default=None, description="End date (ISO 8601)")
    date: str | None = Field(default=None, description="Specific date (YYYY-MM-DD), used for home calendar")
    page: int = Field(default=1, ge=1, description="Page number")
    per_page: int = Field(default=20, ge=1, le=100, description="Items per page")


# ============================================================================
# Service Implementation
# ============================================================================


def _parse_date_to_utc(date_str: str, end_of_day: bool = False) -> datetime | None:
    """Parse a date string into a UTC datetime object.

    Uses dateutil.parser to handle various date formats including:
    - ISO 8601 with timezone offset: 2025-12-25T00:00:00+08:00
    - ISO 8601 UTC: 2025-12-25T00:00:00Z
    - Plain date: 2025-12-25 (defaults to 00:00:00 UTC)

    Args:
        date_str: Date string to parse.
        end_of_day: If True, set time to 23:59:59.999999 UTC.

    Returns:
        UTC datetime object, or None if parsing fails.
    """
    if not date_str:
        return None

    try:
        # dateutil automatically handles various formats including 'Z' suffix
        dt = dateutil_parser.parse(date_str)

        # If naive datetime, assume UTC
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=tz.UTC)
        else:
            # Convert timezone to UTC
            dt = dt.astimezone(tz.UTC)

        # Set to end of day
        if end_of_day:
            dt = dt.replace(hour=23, minute=59, second=59, microsecond=999999)

        return dt

    except (ValueError, TypeError):
        return None


class TransactionQueryService:
    """Transaction Query Service - Core business logic for transaction queries.

    Usage:
        # In API routes:
        service = TransactionQueryService(db_session)
        result = await service.search(user_uuid, params)

        # In LangGraph tools:
        async with db_manager.session_factory() as session:
            service = TransactionQueryService(session)
            result = await service.search(user_uuid, params)
    """

    def __init__(self, db: AsyncSession):
        """Initialize service.

        Args:
            db: Async database session.
        """
        self.db = db

    async def search(self, user_uuid: str, params: TransactionQueryParams) -> TransactionQueryResult:
        """Search transaction records with filtering and pagination.

        Args:
            user_uuid: User UUID string.
            params: Query parameters.

        Returns:
            TransactionQueryResult containing paginated transaction list.
        """
        try:
            # Delegate filtered-statement building to the repository (single
            # source of truth, shared with the /search endpoint).
            start_dt: datetime | None = _parse_date_to_utc(params.start_date) if params.start_date else None
            end_dt: datetime | None = _parse_date_to_utc(params.end_date, end_of_day=True) if params.end_date else None

            # Specific date filter (used for home calendar) narrows the range.
            if params.date:
                day_start = _parse_date_to_utc(params.date)
                day_end = _parse_date_to_utc(params.date, end_of_day=True)
                if day_start is not None:
                    start_dt = day_start if start_dt is None else max(start_dt, day_start)
                if day_end is not None:
                    end_dt = day_end if end_dt is None else min(end_dt, day_end)

            stmt = TransactionRepository(self.db).search_query(
                UUID(user_uuid),
                keyword=params.keyword.strip() if params.keyword else None,
                min_amount=params.min_amount,
                max_amount=params.max_amount,
                category_keys=params.category_keys,
                tags=params.tags,
                start_date=start_dt,
                end_date=end_dt,
                transaction_types=[t.value for t in params.transaction_types] if params.transaction_types else None,
            )

            # Count total matching items
            count_stmt = select(func.count()).select_from(stmt.subquery())
            total_result = await self.db.execute(count_stmt)
            total = total_result.scalar() or 0

            # Calculate pagination
            pages = (total + params.per_page - 1) // params.per_page if total > 0 else 0
            has_more = params.page < pages

            # Pagination (ordering is applied by the repository builder)
            stmt = stmt.offset((params.page - 1) * params.per_page).limit(params.per_page)

            # Execute query
            result = await self.db.execute(stmt)
            transactions = result.scalars().all()

            # Get user primary currency
            display_currency = await get_user_display_currency(self.db, UUID(user_uuid))

            # Convert to response models (display original currency amount)
            items = [TransactionItem.from_transaction(tx, display_currency=display_currency) for tx in transactions]

            logger.debug(
                "transaction_query_complete",
                user_uuid=user_uuid,
                total=total,
                page=params.page,
                returned=len(items),
            )

            return TransactionQueryResult(
                items=items, total=total, page=params.page, per_page=params.per_page, pages=pages, has_more=has_more
            )

        except Exception as e:
            logger.error(
                "transaction_query_failed",
                user_uuid=user_uuid,
                error=str(e),
                exc_info=True,
            )
            raise

    async def get_feed(
        self,
        user_uuid: str,
        date: str | None = None,
        transaction_type: TransactionType | None = None,
        page: int = 1,
        per_page: int = 20,
    ) -> TransactionQueryResult:
        """Get home page transaction feed.

        Args:
            user_uuid: User UUID string.
            date: Optional date filter (YYYY-MM-DD).
            transaction_type: Optional transaction type filter.
            page: Page number.
            per_page: Number of items per page.

        Returns:
            TransactionQueryResult
        """
        params = TransactionQueryParams(
            date=date, transaction_types=[transaction_type] if transaction_type else None, page=page, per_page=per_page
        )
        return await self.search(user_uuid, params)


# ============================================================================
# Singleton for use in LangGraph tools
# ============================================================================


async def query_transactions(user_uuid: str, params: TransactionQueryParams) -> TransactionQueryResult:
    """Convenience function for use in LangGraph tools.

    Automatically creates a database session and executes the search query.

    Args:
        user_uuid: User UUID string.
        params: Query parameters.

    Returns:
        TransactionQueryResult
    """
    async with db_manager.session_factory() as session:
        service = TransactionQueryService(session)
        return await service.search(user_uuid, params)
