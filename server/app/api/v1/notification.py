from typing import Any
from uuid import UUID

from fastapi import APIRouter, Query
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.aliases import CurrentUser, DbSession
from app.core.responses import ResponseEnvelope, success_response
from app.schemas.notification import (
    NotificationListResponse,
    RegisterDeviceTokenRequest,
    UnregisterDeviceTokenRequest,
)
from app.services.notification_service import NotificationService
from app.services.push_service import PushService

router = APIRouter(prefix="/notifications", tags=["notifications"])


def _service(db: AsyncSession) -> NotificationService:
    """Build a NotificationService bound to the request session."""
    return NotificationService(db)


@router.get("", response_model=ResponseEnvelope[NotificationListResponse])
async def get_notifications(
    current_user: CurrentUser,
    db: DbSession,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    unread_only: bool = False,
) -> JSONResponse:
    """Get user notifications with pagination."""
    service = _service(db)
    items, total, unread_count = await service.list_notifications(
        user_uuid=current_user.uuid,
        page=page,
        limit=limit,
        unread_only=unread_only,
    )
    response = NotificationListResponse(
        notifications=items,
        total=total,
        unreadCount=unread_count,
        page=page,
        limit=limit,
    )
    return success_response(data=response.model_dump(mode="json"))


@router.get("/unread-count", response_model=ResponseEnvelope[dict[str, Any]])
async def get_unread_count(
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Get unread notifications count."""
    count = await _service(db).get_unread_count(current_user.uuid)
    return success_response(data={"count": count})


@router.patch("/{notification_id:uuid}/read", response_model=ResponseEnvelope[dict[str, Any]])
async def mark_as_read(
    notification_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Mark notification as read."""
    await _service(db).mark_as_read(notification_id, current_user.uuid)
    return success_response(data={"message": "Marked as read"})


@router.patch("/mark-all-read", response_model=ResponseEnvelope[dict[str, Any]])
async def mark_all_read(
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Mark all notifications as read."""
    await _service(db).mark_all_read(current_user.uuid)
    return success_response(data={"message": "All marked as read"})


@router.delete("/{notification_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
async def delete_notification(
    notification_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Delete a notification."""
    await _service(db).delete(notification_id, current_user.uuid)
    return success_response(data={"message": "Notification deleted"})


@router.post("/device-token", response_model=ResponseEnvelope[dict[str, Any]])
async def register_device_token(
    payload: RegisterDeviceTokenRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Register or update user FCM device token."""
    device = await PushService.register_device_token(
        db=db,
        user_uuid=current_user.uuid,
        device_token=payload.deviceToken.strip(),
        platform=payload.platform,
    )
    return success_response(
        data={"message": "Device token registered", "id": str(device.uuid), "platform": device.platform}
    )


@router.delete("/device-token", response_model=ResponseEnvelope[dict[str, Any]])
async def unregister_device_token(
    payload: UnregisterDeviceTokenRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Unregister device token on logout."""
    success = await PushService.unregister_device_token(
        db=db,
        device_token=payload.deviceToken.strip(),
        user_uuid=current_user.uuid,
    )
    return success_response(data={"message": "Device token unregistered", "success": success})
