"""Repository for Transaction aggregate operations."""

from __future__ import annotations

from uuid import UUID

from sqlalchemy import and_, select

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
