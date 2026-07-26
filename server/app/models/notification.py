"""Notification model for user notifications.

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING, Any
from uuid import UUID

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    from app.models.user import User


class Notification(Base):
    """Notification model for storing user notifications.

    Attributes:
        id: The primary key
        user_uuid: Foreign key to users.uuid
        type: Notification type
        title: Notification title
        content: Notification content (optional)
        data: Additional JSON data (optional)
        is_read: Whether the notification has been read
        read_at: When the notification was read
        created_at: When the notification was created
        updated_at: When the notification was last updated
        user: Relationship to user
    """

    __tablename__ = "notifications"

    id: Mapped[int | None] = mapped_column(primary_key=True, autoincrement=True)
    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="uuid")
    type: Mapped[str] = mapped_column(String(50))
    title: Mapped[str] = mapped_column(String(255))
    content: Mapped[str | None] = mapped_column(String, nullable=True)
    data: Mapped[dict[str, Any] | None] = col.jsonb_column(nullable=True)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    read_at: Mapped[datetime | None] = col.datetime_tz(nullable=True)
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime | None] = col.timestamptz(nullable=True)

    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[Notification.user_uuid]",
        primaryjoin="Notification.user_uuid == User.uuid",
    )

    def mark_as_read(self) -> None:
        """Mark this notification as read."""
        self.is_read = True
        self.read_at = utc_now()
        self.updated_at = utc_now()

    @property
    def is_unread(self) -> bool:
        """Check if notification is unread.

        Returns:
            bool: True if notification is unread
        """
        return not self.is_read
