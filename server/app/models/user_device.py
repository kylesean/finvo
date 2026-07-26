"""UserDevice model for storing push notification tokens.

This model manages FCM/APNs device tokens for user push notifications.
"""

from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, col

if TYPE_CHECKING:
    from app.models.user import User


class UserDevice(Base):
    """UserDevice model for storing push notification device tokens.

    Attributes:
        id: Primary key
        user_uuid: Foreign key to users.uuid
        device_token: FCM/APNs device registration token
        platform: Platform type ('ios', 'android', 'web')
        is_active: Whether the token is active for sending
        created_at: Creation timestamp
        updated_at: Last update timestamp
        user: Relationship to User
    """

    __tablename__ = "user_devices"

    id: Mapped[int | None] = mapped_column(primary_key=True, autoincrement=True)
    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="uuid")
    device_token: Mapped[str] = mapped_column(String(500), unique=True, index=True)
    platform: Mapped[str] = mapped_column(String(20), default="android")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True)
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime | None] = col.timestamptz(nullable=True)

    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[UserDevice.user_uuid]",
        primaryjoin="UserDevice.user_uuid == User.uuid",
    )
