"""Push Notification Service using Firebase Cloud Messaging (FCM).

Handles registration, device token management, and sending multicast push notifications.
Gracefully falls back to mock/logging mode if Firebase credentials are not configured.
"""

from __future__ import annotations

import asyncio
import logging
from typing import Any
from uuid import UUID

from sqlalchemy import and_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.notification import Notification
from app.models.user_device import UserDevice

logger = logging.getLogger("Finvo.push_service")

# Global flag to track if Firebase Admin is initialized
_firebase_initialized = False

try:
    import firebase_admin
    from firebase_admin import credentials, messaging

    # Try to initialize default app if credentials exist or default app is already present
    if not firebase_admin._apps:
        try:
            # Check default app initialization (e.g., GOOGLE_APPLICATION_CREDENTIALS env var)
            cred = credentials.ApplicationDefault()
            firebase_admin.initialize_app(cred)
            _firebase_initialized = True
            logger.info("Firebase Admin SDK initialized successfully via Application Default Credentials.")
        except Exception as e:
            logger.info(
                f"Firebase Admin SDK not initialized (missing credentials): {e}. Fallback to local notifications mode."
            )
    else:
        _firebase_initialized = True
except ImportError:
    logger.warning("firebase-admin package not installed. Push notifications will be stored in database only.")


class PushService:
    """Service to handle FCM push notifications and token lifecycle."""

    @staticmethod
    async def register_device_token(
        db: AsyncSession,
        user_uuid: UUID,
        device_token: str,
        platform: str = "android",
    ) -> UserDevice:
        """Register or update a device token for a user.

        Args:
            db: Database session
            user_uuid: UUID of the target user
            device_token: FCM device registration token
            platform: Platform name ('ios', 'android', 'web')

        Returns:
            UserDevice: The created or updated UserDevice instance
        """
        # Query existing token
        query = select(UserDevice).where(UserDevice.device_token == device_token)
        result = await db.execute(query)
        device = result.scalar_one_or_none()

        if device:
            device.user_uuid = user_uuid
            device.platform = platform
            device.is_active = True
        else:
            device = UserDevice(
                user_uuid=user_uuid,
                device_token=device_token,
                platform=platform,
                is_active=True,
            )
            db.add(device)

        await db.commit()
        await db.refresh(device)
        return device

    @staticmethod
    async def unregister_device_token(db: AsyncSession, device_token: str) -> bool:
        """Deactivate a device token (e.g. on user logout).

        Args:
            db: Database session
            device_token: Device token to deactivate

        Returns:
            bool: True if token was found and updated
        """
        query = update(UserDevice).where(UserDevice.device_token == device_token).values(is_active=False)
        result = await db.execute(query)
        await db.commit()
        return (getattr(result, "rowcount", 0) or 0) > 0

    @classmethod
    async def send_notification(
        cls,
        db: AsyncSession,
        user_uuid: UUID,
        type_: str,
        title: str,
        content: str | None = None,
        data: dict[str, Any] | None = None,
    ) -> Notification:
        """Create a notification in DB and push it via FCM to active user devices.

        Args:
            db: Database session
            user_uuid: Target user UUID
            type_: Notification type (e.g., 'space_invite', 'bill_comment')
            title: Notification title
            content: Notification text/body
            data: Additional payload JSON (e.g., routing target path)

        Returns:
            Notification: The saved database notification record
        """
        # 1. Save in-app notification record in DB
        notification = Notification(
            user_uuid=user_uuid,
            type=type_,
            title=title,
            content=content,
            data=data,
            is_read=False,
        )
        try:
            db.add(notification)
            await db.commit()
            await db.refresh(notification)
        except Exception as exc:
            await db.rollback()
            logger.error("notification_save_failed: %s", exc)
            raise

        # 2. Fetch active device tokens (non-critical: skip push if query fails)
        try:
            query = select(UserDevice.device_token).where(
                and_(UserDevice.user_uuid == user_uuid, UserDevice.is_active == True)  # noqa: E712
            )
            result = await db.execute(query)
            tokens = list(result.scalars().all())
        except Exception as exc:
            logger.warning("device_tokens_query_failed, push skipped: %s", exc)
            return notification

        if not tokens:
            logger.debug("no_active_tokens for user %s, push skipped", user_uuid)
            return notification

        # 3. Dispatch via FCM if initialized
        if _firebase_initialized:
            try:
                # Convert all payload data values to strings as required by FCM
                string_data = {k: str(v) for k, v in (data or {}).items()}
                string_data["notification_id"] = str(notification.id)

                message = messaging.MulticastMessage(
                    notification=messaging.Notification(
                        title=title,
                        body=content or "",
                    ),
                    data=string_data,
                    tokens=tokens,
                )

                batch_response = await asyncio.to_thread(messaging.send_each_for_multicast, message)
                logger.info(
                    "fcm_multicast_sent user=%s success=%d fail=%d",
                    user_uuid,
                    batch_response.success_count,
                    batch_response.failure_count,
                )

                # Process failed tokens for deactivation
                if batch_response.failure_count > 0:
                    invalid_tokens = []
                    for idx, resp in enumerate(batch_response.responses):
                        if not resp.success:
                            # Token invalid or unregistered
                            invalid_tokens.append(tokens[idx])

                    if invalid_tokens:
                        await db.execute(
                            update(UserDevice)
                            .where(UserDevice.device_token.in_(invalid_tokens))
                            .values(is_active=False)
                        )
                        await db.commit()
            except Exception as exc:
                logger.error("fcm_push_failed: %s", exc)
        else:
            logger.info("[Mock Push] title=%s content=%s tokens=%d", title, content, len(tokens))

        return notification
