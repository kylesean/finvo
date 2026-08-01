"""Repository for Notification aggregate operations."""

from __future__ import annotations

from uuid import UUID

from sqlalchemy import func, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.notification import Notification


class NotificationRepository:
    """Data access for the Notification aggregate."""

    def __init__(self, db: AsyncSession):
        """Initialize with the shared async session."""
        self.db = db

    async def mark_recurring_pending_read(self, user_uuid: UUID, transaction_id: UUID) -> None:
        """Mark the recurring_pending notification for a transaction as read.

        Used when a transaction is confirmed or skipped so the pending
        notification does not linger as unread.
        """
        stmt = (
            update(Notification)
            .where(
                Notification.user_uuid == user_uuid,
                Notification.type == "recurring_pending",
                Notification.is_read == False,  # noqa: E712
                Notification.data["transaction_id"].as_string() == str(transaction_id),
            )
            .values(is_read=True, read_at=func.now())
        )
        await self.db.execute(stmt)
