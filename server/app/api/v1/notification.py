from typing import Any

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_user
from app.core.responses import ResponseEnvelope, success_response
from app.models.user import User
from app.schemas.notification import (
    NotificationListResponse,
    RegisterDeviceTokenRequest,
    UnregisterDeviceTokenRequest,
)
from app.services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["notifications"])


def _service(db: AsyncSession) -> NotificationService:
    """Build a NotificationService bound to the request session."""
    return NotificationService(db)


@router.get("", response_model=ResponseEnvelope[NotificationListResponse])
async def get_notifications(
    page: int = 1,
    limit: int = 20,
    unread_only: bool = False,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
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
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Get unread notifications count."""
    count = await _service(db).get_unread_count(current_user.uuid)
    return success_response(data={"count": count})


@router.patch("/{notification_id}/read", response_model=ResponseEnvelope[dict[str, Any]])
async def mark_as_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Mark notification as read."""
    await _service(db).mark_as_read(notification_id, current_user.uuid)
    return success_response(data={"message": "Marked as read"})


@router.patch("/mark-all-read", response_model=ResponseEnvelope[dict[str, Any]])
async def mark_all_read(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Mark all notifications as read."""
    await _service(db).mark_all_read(current_user.uuid)
    return success_response(data={"message": "All marked as read"})


@router.delete("/{notification_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def delete_notification(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Delete a notification."""
    await _service(db).delete(notification_id, current_user.uuid)
    return success_response(data={"message": "Notification deleted"})


@router.post("/device-token", response_model=ResponseEnvelope[dict[str, Any]])
async def register_device_token(
    payload: RegisterDeviceTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Register or update user FCM device token."""
    from app.services.push_service import PushService

    device = await PushService.register_device_token(
        db=db,
        user_uuid=current_user.uuid,
        device_token=payload.deviceToken.strip(),
        platform=payload.platform,
    )
    return success_response(data={"message": "Device token registered", "id": device.id, "platform": device.platform})


@router.delete("/device-token", response_model=ResponseEnvelope[dict[str, Any]])
async def unregister_device_token(
    payload: UnregisterDeviceTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Unregister device token on logout."""
    from app.services.push_service import PushService

    success = await PushService.unregister_device_token(db=db, device_token=payload.deviceToken.strip())
    return success_response(data={"message": "Device token unregistered", "success": success})
