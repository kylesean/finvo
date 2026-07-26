from typing import Any, cast

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_user
from app.core.responses import error_response, get_error_code_int, success_response
from app.models.notification import Notification
from app.models.user import User
from app.schemas.notification import RegisterDeviceTokenRequest, UnregisterDeviceTokenRequest

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("")
async def get_notifications(
    page: int = 1,
    limit: int = 20,
    unread_only: bool = False,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Get user notifications with pagination."""
    # Base filters
    filters: list[Any] = [Notification.user_uuid == current_user.uuid]
    if unread_only:
        filters.append(Notification.is_read == False)  # noqa: E712

    # Count total
    count_query = select(func.count(cast(Any, Notification.id))).where(and_(*filters))
    count_result = await db.execute(count_query)
    total = count_result.scalar() or 0

    # Get unread count
    unread_count_query = select(func.count(cast(Any, Notification.id))).where(
        and_(cast(Any, Notification.user_uuid == current_user.uuid), cast(Any, Notification.is_read == False))  # noqa: E712
    )
    unread_result = await db.execute(unread_count_query)
    unread_count = unread_result.scalar() or 0

    # Get notifications
    query = (
        select(Notification)
        .where(and_(*filters))
        .order_by(cast(Any, Notification.created_at).desc())
        .offset((page - 1) * limit)
        .limit(limit)
    )
    result = await db.execute(query)
    notifications = result.scalars().all()

    # Convert to response objects
    items = []
    for n in notifications:
        items.append(
            {
                "id": str(n.id),
                "userId": str(current_user.uuid),
                "type": n.type,
                "title": n.title,
                "message": n.content or "",
                "data": n.data,
                "isRead": n.is_read,
                "createdAt": n.created_at,
                "readAt": n.read_at,
            }
        )

    return success_response(
        data={"notifications": items, "total": total, "unreadCount": unread_count, "page": page, "limit": limit}
    )


@router.get("/unread-count")
async def get_unread_count(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Get unread notifications count."""
    query = select(func.count(cast(Any, Notification.id))).where(
        and_(cast(Any, Notification.user_uuid == current_user.uuid), cast(Any, Notification.is_read == False))  # noqa: E712
    )
    result = await db.execute(query)
    count = result.scalar() or 0
    return success_response(data={"count": count})


@router.patch("/{notification_id}/read")
async def mark_as_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Mark notification as read."""
    query = select(Notification).where(
        and_(cast(Any, Notification.id == notification_id), cast(Any, Notification.user_uuid == current_user.uuid))
    )
    result = await db.execute(query)
    notification = result.scalar_one_or_none()

    if not notification:
        return error_response(code=get_error_code_int("NOT_FOUND"), message="Notification not found", http_status=404)

    notification.mark_as_read()
    await db.commit()
    return success_response(data={"message": "Marked as read"})


@router.patch("/mark-all-read")
async def mark_all_read(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Mark all notifications as read."""
    from sqlalchemy import update

    query = (
        update(Notification)
        .where(and_(cast(Any, Notification.user_uuid == current_user.uuid), cast(Any, Notification.is_read == False)))  # noqa: E712
        .values(is_read=True, read_at=func.now())
    )
    await db.execute(query)
    await db.commit()
    return success_response(data={"message": "All marked as read"})


@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Delete a notification."""
    query = select(Notification).where(
        and_(cast(Any, Notification.id == notification_id), cast(Any, Notification.user_uuid == current_user.uuid))
    )
    result = await db.execute(query)
    notification = result.scalar_one_or_none()

    if not notification:
        return error_response(code=get_error_code_int("NOT_FOUND"), message="Notification not found", http_status=404)

    await db.delete(notification)
    await db.commit()
    return success_response(data={"message": "Notification deleted"})


@router.post("/device-token")
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


@router.delete("/device-token")
async def unregister_device_token(
    payload: UnregisterDeviceTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Unregister device token on logout."""
    from app.services.push_service import PushService

    success = await PushService.unregister_device_token(db=db, device_token=payload.deviceToken.strip())
    return success_response(data={"message": "Device token unregistered", "success": success})
