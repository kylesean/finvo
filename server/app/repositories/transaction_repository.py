"""Repository for Transaction aggregate operations."""

from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import Select, String, and_, cast, desc, func, or_, select

from app.models.transaction import Transaction
from app.repositories.base import BaseRepository


class TransactionRepository(BaseRepository[Transaction]):
    """Data access for the Transaction aggregate.

    Queries are intentionally parametrized with the owning ``user_uuid`` so
    cross-user access is impossible by construction.
    """

    model = Transaction

    async def get_by_id_for_user(self, transaction_id: UUID, user_uuid: UUID) -> Transaction | None:
        """Get a transaction owned by the given user."""
        result = await self.db.execute(
            select(Transaction).where(
                and_(
                    Transaction.id == transaction_id,
                    Transaction.user_uuid == user_uuid,
                )
            )
        )
        return result.scalar_one_or_none()

    async def list_pending(self, user_uuid: UUID) -> list[Transaction]:
        """List PENDING transactions for a user (newest first)."""
        result = await self.db.execute(
            select(Transaction)
            .where(
                and_(
                    Transaction.user_uuid == user_uuid,
                    Transaction.status == "PENDING",
                )
            )
            .order_by(Transaction.transaction_at.desc())
        )
        return list(result.scalars().all())

    def search_query(
        self,
        user_uuid: UUID,
        *,
        keyword: str | None = None,
        min_amount: Decimal | None = None,
        max_amount: Decimal | None = None,
        category_keys: list[str] | None = None,
        tags: list[str] | None = None,
        start_date: datetime | None = None,
        end_date: datetime | None = None,
        transaction_types: list[str] | None = None,
    ) -> Select[Any]:
        """Build a filtered ``select`` for the user's transactions (newest first).

        Single source of truth for transaction filtering, shared by the
        ``/search`` endpoint (via fastapi-pagination) and
        ``TransactionQueryService.search``. LIKE metacharacters in ``keyword``
        are escaped so user input ``%``/``_`` matches literally; keyword also
        matches ``category_key`` and ``tags`` (JSONB text), mirroring the
        canonical query service behavior. Amounts are compared via
        ``func.abs`` — amounts are stored as absolute values.
        """
        conditions: list[Any] = [Transaction.user_uuid == user_uuid]

        if keyword:
            escaped = keyword.replace("\\", r"\\").replace("%", r"\%").replace("_", r"\_")
            pattern = f"%{escaped}%"
            conditions.append(
                or_(
                    Transaction.description.ilike(pattern, escape="\\"),
                    Transaction.location.ilike(pattern, escape="\\"),
                    Transaction.category_key.ilike(pattern, escape="\\"),
                    cast(Transaction.tags, String).ilike(pattern, escape="\\"),
                )
            )

        if min_amount is not None:
            conditions.append(func.abs(Transaction.amount) >= min_amount)

        if max_amount is not None:
            conditions.append(func.abs(Transaction.amount) <= max_amount)

        if category_keys:
            conditions.append(Transaction.category_key.in_(category_keys))

        if tags:
            # Drop empty segments (e.g. trailing commas in "a,b,") — an empty tag
            # would otherwise produce a meaningless contains([""]) condition.
            for tag in tags:
                conditions.append(Transaction.tags.contains([tag]))

        if start_date is not None:
            conditions.append(Transaction.transaction_at >= start_date)

        if end_date is not None:
            conditions.append(Transaction.transaction_at <= end_date)

        if transaction_types:
            conditions.append(Transaction.type.in_(transaction_types))

        return select(Transaction).where(and_(*conditions)).order_by(desc(Transaction.transaction_at))
