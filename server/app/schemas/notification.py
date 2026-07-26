from __future__ import annotations

from datetime import datetime
from enum import StrEnum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class NotificationType(StrEnum):
    """Supported notification types."""

    SYSTEM = "system"
    SPACE_INVITE = "space_invite"
    SPACE_ACTIVITY = "space_activity"
    MEMBER_JOINED = "member_joined"
    MEMBER_LEFT = "member_left"
    BILL_COMMENT = "bill_comment"
    BUDGET_ALERT = "budget_alert"
    TRANSACTION = "transaction"
    RECURRING_PENDING = "recurring_pending"


class NotificationResponse(BaseModel):
    """Response schema for a single notification (camelCase for client)."""

    id: str
    userId: str
    type: str
    title: str
    message: str = ""
    data: dict[str, Any] | None = None
    isRead: bool = False
    createdAt: datetime
    readAt: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class NotificationListResponse(BaseModel):
    """Response schema for notification list."""

    notifications: list[NotificationResponse]
    total: int
    unreadCount: int
    page: int
    limit: int


class RegisterDeviceTokenRequest(BaseModel):
    """Request schema for registering a device token."""

    deviceToken: str = Field(..., min_length=1, max_length=500, description="FCM/APNs device token")
    platform: str = Field(default="android", pattern=r"^(ios|android|web)$", description="Device platform")


class UnregisterDeviceTokenRequest(BaseModel):
    """Request schema for unregistering a device token."""

    deviceToken: str = Field(..., min_length=1, max_length=500, description="FCM/APNs device token")
