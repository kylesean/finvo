"""Domain events and notification handlers for shared space module.

Events are emitted by service layer after successful business operations.
Handlers are registered at app startup and execute asynchronously.
"""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import and_, select

from app.core.database import db_manager
from app.core.events import DomainEvent, event_bus
from app.core.logging import logger

# =============================================================================
# Domain Events
# =============================================================================


async def _notify_recipients(
    recipient_uuids: list[UUID],
    *,
    type_: str,
    title: str,
    content: str,
    data: dict[str, Any],
) -> None:
    """Send a push notification to many space members in parallel.

    Each recipient gets its OWN session because ``AsyncSession`` is not safe to
    share across concurrent tasks; this keeps large spaces from paying N serial
    DB + push round-trips on the event loop (m22).
    """
    from app.services.push_service import PushService

    async def send_one(user_uuid: UUID) -> None:
        async with db_manager.session_factory() as s:
            await PushService.send_notification(
                db=s, user_uuid=user_uuid, type_=type_, title=title, content=content, data=data
            )

    if recipient_uuids:
        # return_exceptions=True so one recipient's failure (e.g. DB hiccup) does
        # not cancel the remaining parallel sends; failures are logged below.
        results = await asyncio.gather(*(send_one(u) for u in recipient_uuids), return_exceptions=True)
        for uuid_, res in zip(recipient_uuids, results, strict=False):
            if isinstance(res, Exception):
                logger.error("recipient_notification_failed", user_uuid=uuid_, error=str(res), exc_info=res)


@dataclass(frozen=True, kw_only=True)
class MemberJoinedEvent(DomainEvent):
    """Emitted when a user successfully joins a shared space."""

    space_id: UUID
    space_name: str
    joined_user_uuid: UUID


@dataclass(frozen=True, kw_only=True)
class TransactionAddedEvent(DomainEvent):
    """Emitted when a transaction is added to a shared space."""

    space_id: UUID
    space_name: str
    transaction_id: UUID
    added_by_user_uuid: UUID
    amount: Decimal
    currency: str
    tx_type: str
    description: str


@dataclass(frozen=True, kw_only=True)
class MemberLeftEvent(DomainEvent):
    """Emitted when a member leaves or is removed from a shared space."""

    space_id: UUID
    space_name: str
    left_user_uuid: UUID
    reason: str = "left"  # "left" (self-initiated) or "removed" (by admin)


# =============================================================================
# Notification Handlers
# =============================================================================


async def handle_member_joined(event: MemberJoinedEvent) -> None:
    """Notify existing members about new join + send welcome to joiner."""
    from app.core.database import db_manager
    from app.models.shared_space import SpaceMember
    from app.models.user import User
    from app.services.push_service import PushService

    async with db_manager.session_factory() as db:
        # Get joining user's display name
        user_query = select(User.username).where(User.uuid == event.joined_user_uuid)
        user_result = await db.execute(user_query)
        username = user_result.scalar_one_or_none() or "Someone"

        # Get other ACCEPTED members
        members_query = select(SpaceMember.user_uuid).where(
            and_(
                SpaceMember.space_id == event.space_id,
                SpaceMember.status == "ACCEPTED",
                SpaceMember.user_uuid != event.joined_user_uuid,
            )
        )
        members_result = await db.execute(members_query)
        recipient_uuids = list(members_result.scalars().all())

        # Notify existing members (in parallel, one session each)
        await _notify_recipients(
            recipient_uuids,
            type_="member_joined",
            title=f"{username} joined your space",
            content=f'{username} joined "{event.space_name}"',
            data={
                "action": "member_joined",
                "space_id": str(event.space_id),
                "space_name": event.space_name,
                "joined_user_id": str(event.joined_user_uuid),
                "joined_username": username,
                "target_path": f"/profile/shared-space/{event.space_id}",
            },
        )

        # Welcome notification to the joining user
        await PushService.send_notification(
            db=db,
            user_uuid=event.joined_user_uuid,
            type_="space_activity",
            title=f'Welcome to "{event.space_name}"',
            content=f'You have successfully joined "{event.space_name}". Start recording shared expenses!',
            data={
                "action": "welcome_to_space",
                "space_id": str(event.space_id),
                "space_name": event.space_name,
                "target_path": f"/profile/shared-space/{event.space_id}",
            },
        )


async def handle_transaction_added(event: TransactionAddedEvent) -> None:
    """Notify other space members about a new transaction."""
    from app.core.database import db_manager
    from app.models.shared_space import SpaceMember
    from app.models.user import User

    async with db_manager.session_factory() as db:
        # Get recording user's display name
        user_query = select(User.username).where(User.uuid == event.added_by_user_uuid)
        user_result = await db.execute(user_query)
        username = user_result.scalar_one_or_none() or "Someone"

        # Get other ACCEPTED members
        members_query = select(SpaceMember.user_uuid).where(
            and_(
                SpaceMember.space_id == event.space_id,
                SpaceMember.status == "ACCEPTED",
                SpaceMember.user_uuid != event.added_by_user_uuid,
            )
        )
        members_result = await db.execute(members_query)
        recipient_uuids = list(members_result.scalars().all())

        if not recipient_uuids:
            return

        # Build notification content
        title = f"{username} recorded a new {event.tx_type}"
        content = f'{username} recorded {event.currency} {event.amount:.2f} in "{event.space_name}"'
        if event.description:
            content += f" ({event.description})"

        await _notify_recipients(
            recipient_uuids,
            type_="transaction",
            title=title,
            content=content,
            data={
                "action": "new_transaction",
                "space_id": str(event.space_id),
                "space_name": event.space_name,
                "transaction_id": str(event.transaction_id),
                "amount": f"{event.amount:.2f}",
                "currency": event.currency,
                "tx_type": event.tx_type,
                "added_by_user_id": str(event.added_by_user_uuid),
                "added_by_username": username,
                "target_path": f"/profile/shared-space/{event.space_id}",
            },
        )


async def handle_member_left(event: MemberLeftEvent) -> None:
    """Notify remaining members when someone leaves / is removed, in realtime."""
    from app.core.database import db_manager
    from app.core.ws_manager import ws_manager
    from app.models.shared_space import SpaceMember
    from app.models.user import User

    async with db_manager.session_factory() as db:
        # Get leaving user's display name
        user_query = select(User.username).where(User.uuid == event.left_user_uuid)
        user_result = await db.execute(user_query)
        username = user_result.scalar_one_or_none() or "Someone"

        # Get remaining ACCEPTED members (excluding the departing member)
        members_query = select(SpaceMember.user_uuid).where(
            and_(
                SpaceMember.space_id == event.space_id,
                SpaceMember.status == "ACCEPTED",
                SpaceMember.user_uuid != event.left_user_uuid,
            )
        )
        members_result = await db.execute(members_query)
        recipient_uuids = list(members_result.scalars().all())

        removed = event.reason == "removed"
        title = f"{username} was removed from the space" if removed else f"{username} left your space"
        content = f'{username} {"was removed from" if removed else "left"} "{event.space_name}"'
        data = {
            "action": "space_member_left",
            "space_id": str(event.space_id),
            "space_name": event.space_name,
            "reason": event.reason,
            "member_user_id": str(event.left_user_uuid),
            "member_username": username,
            "target_path": f"/profile/shared-space/{event.space_id}",
        }

        # DB rows + FCM push for all remaining members (in parallel).
        await _notify_recipients(
            recipient_uuids,
            type_="member_left",
            title=title,
            content=content,
            data=data,
        )

        # Realtime WS push so open clients drop the member immediately
        # without waiting for a manual refresh.
        if recipient_uuids:
            await ws_manager.broadcast(
                [str(u) for u in recipient_uuids],
                {"type": "member_left", "title": title, "message": content, "data": data},
            )

        # When removed by an admin, also notify the removed user personally.
        if removed:
            from app.services.push_service import PushService

            removed_title = f'You were removed from "{event.space_name}"'
            removed_content = f'You no longer have access to "{event.space_name}".'
            await PushService.send_notification(
                db=db,
                user_uuid=event.left_user_uuid,
                type_="space_activity",
                title=removed_title,
                content=removed_content,
                data={
                    "action": "removed_from_space",
                    "space_id": str(event.space_id),
                    "space_name": event.space_name,
                    "target_path": "/profile/shared-space",
                },
            )
            await ws_manager.send_notification(
                str(event.left_user_uuid),
                {
                    "type": "space_activity",
                    "title": removed_title,
                    "message": removed_content,
                    "data": {
                        "action": "removed_from_space",
                        "space_id": str(event.space_id),
                        "space_name": event.space_name,
                        "target_path": "/profile/shared-space",
                    },
                },
            )


# =============================================================================
# Registration
# =============================================================================


def register_space_notification_handlers() -> None:
    """Register all shared-space notification handlers with the event bus.

    Call this once at application startup.
    """
    event_bus.subscribe(MemberJoinedEvent, handle_member_joined)
    event_bus.subscribe(MemberLeftEvent, handle_member_left)
    event_bus.subscribe(TransactionAddedEvent, handle_transaction_added)
