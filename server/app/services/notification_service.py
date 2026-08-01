"""Notification service for user notification query and mutation operations.

Centralises notification persistence so API routes stay thin and the same logic
is reusable (and independently testable) instead of duplicating raw ORM queries
across handlers.
"""

from __future__ import annotations

from uuid import UUID

import structlog
from sqlalchemy import and_, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundError
from app.models.notification import Notification
from app.schemas.notification import NotificationResponse

logger = structlog.get_logger(__name__)


class NotificationService:
    """Encapsulates notification read/write operations for a single session."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def list_notifications(
        self,
        user_uuid: UUID,
        page: int = 1,
        limit: int = 20,
        unread_only: bool = False,
    ) -> tuple[list[NotificationResponse], int, int]:
        """Return (items, total, unread_count) for the user's notifications."""
        filters = [Notification.user_uuid == user_uuid]
        if unread_only:
            filters.append(Notification.is_read.is_(False))

        total_row = await self.db.execute(select(func.count(Notification.id)).where(and_(*filters)))
        total = total_row.scalar() or 0

        unread_row = await self.db.execute(
            select(func.count(Notification.id)).where(
                and_(Notification.user_uuid == user_uuid, Notification.is_read.is_(False))
            )
        )
        unread_count = unread_row.scalar() or 0

        query = (
            select(Notification)
            .where(and_(*filters))
            .order_by(Notification.created_at.desc())
            .offset((page - 1) * limit)
            .limit(limit)
        )
        result = await self.db.execute(query)
        notifications = result.scalars().all()

        items = [
            NotificationResponse(
                id=str(n.id),
                userId=str(user_uuid),
                type=n.type,
                title=n.title,
                message=n.content or "",
                data=n.data,
                isRead=n.is_read,
                createdAt=n.created_at,
                readAt=n.read_at,
            )
            for n in notifications
        ]
        return items, total, unread_count

    async def get_unread_count(self, user_uuid: UUID) -> int:
        """Return the number of unread notifications for the user."""
        result = await self.db.execute(
            select(func.count(Notification.id)).where(
                and_(Notification.user_uuid == user_uuid, Notification.is_read.is_(False))
            )
        )
        return result.scalar() or 0

    async def _get_owned(self, notification_id: int, user_uuid: UUID) -> Notification:
        """Fetch a notification only if it belongs to the given user."""
        result = await self.db.execute(
            select(Notification).where(and_(Notification.id == notification_id, Notification.user_uuid == user_uuid))
        )
        notification = result.scalar_one_or_none()
        if notification is None:
            raise NotFoundError("Notification")
        return notification

    async def mark_as_read(self, notification_id: int, user_uuid: UUID) -> None:
        """Mark a single owned notification as read."""
        notification = await self._get_owned(notification_id, user_uuid)
        notification.mark_as_read()
        await self.db.commit()

    async def mark_all_read(self, user_uuid: UUID) -> None:
        """Mark all of the user's notifications as read."""
        await self.db.execute(
            update(Notification)
            .where(and_(Notification.user_uuid == user_uuid, Notification.is_read.is_(False)))
            .values(is_read=True, read_at=func.now())
        )
        await self.db.commit()

    async def delete(self, notification_id: int, user_uuid: UUID) -> None:
        """Delete a single owned notification."""
        notification = await self._get_owned(notification_id, user_uuid)
        await self.db.delete(notification)
        await self.db.commit()
