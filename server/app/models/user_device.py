"""UserDevice model for storing push notification tokens.

This model manages FCM/APNs device tokens for user push notifications.
A user may own multiple devices (1:N), so this table carries its own UUID
primary key rather than reusing user_uuid (as the 1:1 user_settings table does).
"""

from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from sqlalchemy import Boolean, String, text
from sqlalchemy.orm import Mapped, mapped_column, relationship, synonym

from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    from app.models.user import User


class UserDevice(Base):
    """UserDevice model for storing push notification device tokens.

    A user can have many devices (phone, tablet, browser), so this is a 1:N
    relationship: the table has its own UUID primary key. ``device_token`` is
    globally unique (one token maps to one app install) and is the natural
    lookup key for token lifecycle operations.

    Attributes:
        uuid: Primary key (UUID)
        user_uuid: Foreign key to users.uuid
        device_token: FCM/APNs device registration token (globally unique)
        platform: Platform type ('ios', 'android', 'web')
        is_active: Whether the token is active for sending
        device_name: User-facing device name (optional)
        device_model: Device hardware model (optional)
        os_version: Operating system version (optional)
        app_version: App version (optional)
        last_active_at: Last time the device was seen active (optional)
        created_at: Creation timestamp
        updated_at: Last update timestamp (auto-refreshed on UPDATE)
        user: Relationship to User
    """

    __tablename__ = "user_devices"

    id: Mapped[UUID] = col.uuid_pk(uuid4)
    uuid = synonym("id")

    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="id")
    # unique=True implicitly creates the unique index; do NOT add index=True (redundant).
    device_token: Mapped[str] = mapped_column(String(500), unique=True)
    platform: Mapped[str] = mapped_column(String(20), default="android", server_default=text("'android'"))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, server_default=text("true"))
    device_name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    device_model: Mapped[str | None] = mapped_column(String(100), nullable=True)
    os_version: Mapped[str | None] = mapped_column(String(50), nullable=True)
    app_version: Mapped[str | None] = mapped_column(String(50), nullable=True)
    last_active_at: Mapped[datetime | None] = col.datetime_tz(nullable=True)
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[UserDevice.user_uuid]",
        primaryjoin="UserDevice.user_uuid == User.id",
    )
