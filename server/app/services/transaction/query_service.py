"""Transaction query service — Facade-internal query helper.

This slim ``TransactionQueryService`` exposes ``get_transaction_feed`` /
``search_transactions`` and is consumed **only** by the ``TransactionService``
Facade (``transaction_service.py``) and re-exported from
``app/services/transaction/__init__.py``.

A fuller-featured ``TransactionQueryService`` (``search()`` +
``TransactionQueryParams``) lives at
``app/services/transaction_query_service.py`` and is used directly by API
endpoints, LangGraph tools and skills. The two have different APIs and are
intentionally not merged; see the docstring there for rationale.
"""

from datetime import UTC, datetime, timedelta
from typing import Any, cast as type_cast
from uuid import UUID

import structlog
from sqlalchemy import desc, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.transaction import Transaction
from app.schemas.transaction import TransactionDisplayValue
from app.utils.currency_utils import get_user_display_currency

logger = structlog.get_logger(__name__)


class TransactionFacadeQueryHelper:
    """Service helper for transaction query and search operations within Facade."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_transaction_feed(
        self,
        user_uuid: UUID,
        date_filter: str | None = None,
        type_filter: str = "all",
        page: int = 1,
        limit: int = 10,
    ) -> dict[str, Any]:
        """Retrieve transaction feed list (displaying original currency amount)."""
        # 1. Obtain user's primary currency (for baseCurrency field)
        display_currency = await get_user_display_currency(self.db, user_uuid)

        # 2. Construct query
        query = select(Transaction).where(Transaction.user_uuid == user_uuid)

        # Date filtering.
        # Use a half-open [start, end) datetime range instead of wrapping the column in
        # func.date(...), so the b-tree index on transaction_at is used.
        if date_filter:
            try:
                filter_date = datetime.strptime(date_filter, "%Y-%m-%d").date()
                start_dt = datetime.combine(filter_date, datetime.min.time(), tzinfo=UTC)
                query = query.where(
                    Transaction.transaction_at >= start_dt,
                    Transaction.transaction_at < start_dt + timedelta(days=1),
                )
            except ValueError:
                logger.warning("invalid_date_format", date_filter=date_filter)

        # Type filtering
        if type_filter == "income":
            query = query.where(Transaction.type == "INCOME")
        elif type_filter == "expense":
            query = query.where(Transaction.type == "EXPENSE")

        # Ordering
        query = query.order_by(desc(Transaction.transaction_at), desc(Transaction.id))

        # Count total
        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        # Pagination
        offset = (page - 1) * limit
        query = query.offset(offset).limit(limit)

        # Execute query
        result = await self.db.execute(query)
        transactions = result.scalars().all()

        # 3. Assemble response items displaying original currency amounts
        data = []
        for tx in transactions:
            # Display original currency amount directly
            amount_val = float(tx.amount_original)
            original_currency = (tx.currency or display_currency).upper()

            data.append(
                {
                    "id": str(tx.id),
                    "userUuid": str(tx.user_uuid),
                    "type": tx.type,
                    "amount": amount_val,
                    "amountBase": float(tx.amount),
                    "currency": original_currency,
                    "baseCurrency": display_currency,
                    "exchangeRate": str(tx.exchange_rate) if tx.exchange_rate else None,
                    "categoryKey": tx.category_key,
                    "description": tx.description,
                    "transactionAt": tx.transaction_at.isoformat(),
                    "tags": tx.tags or [],
                    "createdAt": tx.created_at.isoformat(),
                    "updatedAt": tx.updated_at.isoformat() if tx.updated_at else None,
                    "display": TransactionDisplayValue.from_params(
                        amount=tx.amount_original, tx_type=tx.type, currency=original_currency
                    ).model_dump(),
                }
            )

        return {
            "data": data,
            "meta": {
                "total": total,
                "current_page": page,
                "per_page": limit,
                "last_page": (total + limit - 1) // limit if total > 0 else 1,
                "has_more": total > page * limit,
            },
        }

    async def search_transactions(self, user_uuid: UUID, filters: dict[str, Any]) -> dict[str, Any]:
        """Search transaction records.

        Args:
            user_uuid: User UUID
            filters: Search filter parameters

        Returns:
            Dictionary containing search results and pagination metadata
        """
        # Base query
        query = select(Transaction).where(Transaction.user_uuid == user_uuid)

        # Keyword search
        if keyword := filters.get("keyword"):
            # Escape LIKE metacharacters so user input `%`/`_`/`\` match literally
            # instead of acting as wildcards.
            escaped = keyword.replace("\\", "\\\\").replace("%", r"\%").replace("_", r"\_")
            query = query.where(
                type_cast(
                    Any,
                    or_(
                        Transaction.description.ilike(f"%{escaped}%", escape="\\"),
                        Transaction.location.ilike(f"%{escaped}%", escape="\\"),
                    ),
                )
            )

        # Amount range
        if min_amount := filters.get("min_amount"):
            query = query.where(Transaction.amount >= min_amount)
        if max_amount := filters.get("max_amount"):
            query = query.where(Transaction.amount <= max_amount)

        # Category filter
        if categories := filters.get("categories"):
            query = query.where(Transaction.category_key.in_(categories))

        # Tag filter
        if tags := filters.get("tags"):
            for tag in tags:
                query = query.where(Transaction.tags.contains([tag]))

        # Date range
        if start_date := filters.get("start_date"):
            try:
                start_dt = datetime.strptime(start_date, "%Y-%m-%d")
                query = query.where(Transaction.transaction_at >= start_dt)
            except ValueError:
                logger.warning("invalid_start_date_format", start_date=start_date)

        if end_date := filters.get("end_date"):
            try:
                end_dt = datetime.strptime(end_date, "%Y-%m-%d")
                query = query.where(Transaction.transaction_at <= end_dt)
            except ValueError:
                logger.warning("invalid_end_date_format", end_date=end_date)

        # Income/Expense filter — match on the `type` column (amounts are stored
        # as positive values), not on amount sign which never varies.
        if type_val := filters.get("type"):
            normalized = str(type_val).upper()
            if normalized in ("INCOME", "EXPENSE", "TRANSFER"):
                query = query.where(Transaction.type == normalized)
            else:
                logger.warning("invalid_transaction_type_filter", type_val=type_val)

        # Ordering
        query = query.order_by(desc(Transaction.transaction_at))

        # Pagination parameters
        page = filters.get("page", 1)
        per_page = filters.get("per_page", 10)
        offset = (page - 1) * per_page

        # Calculate total
        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        # Execute paginated query
        query = query.offset(offset).limit(per_page)
        result = await self.db.execute(query)
        transactions = result.scalars().all()

        return {
            "data": [
                {
                    "id": tx.id,
                    "user_uuid": tx.user_uuid,
                    "amount": str(tx.amount),
                    "category_key": tx.category_key,
                    "description": tx.description,
                    "transaction_at": tx.transaction_at.isoformat(),
                    "tags": tx.tags or [],
                    "created_at": tx.created_at.isoformat(),
                    "updated_at": tx.updated_at.isoformat() if tx.updated_at else None,
                }
                for tx in transactions
            ],
            "meta": {
                "total": total,
                "current_page": page,
                "per_page": per_page,
                "last_page": (total + per_page - 1) // per_page if total > 0 else 1,
                "has_more": total > page * per_page,
            },
        }
