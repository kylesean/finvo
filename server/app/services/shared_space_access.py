"""Shared access-control helpers for shared-space services.

``_verify_membership/_verify_admin/_verify_owner`` were previously copy-pasted
in :class:`SharedSpaceService` and :class:`SharedSpaceSettlementService` (and
implicitly needed by any space-transaction logic). Centralizing them here keeps
the role rules (OWNER > ADMIN > member) in exactly one place.
"""

from __future__ import annotations

from uuid import UUID

from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthorizationError
from app.models.shared_space import SpaceMember


async def verify_membership(db: AsyncSession, space_id: UUID, user_uuid: UUID) -> SpaceMember:
    """Verify user is an accepted member of the space.

    Raises:
        AuthorizationError: If the user is not a member.
    """
    query = select(SpaceMember).where(
        and_(
            SpaceMember.space_id == space_id,
            SpaceMember.user_uuid == user_uuid,
            SpaceMember.status == "ACCEPTED",
        )
    )
    result = await db.execute(query)
    member = result.scalar_one_or_none()

    if not member:
        raise AuthorizationError("you are not a member of this space")
    return member


async def verify_admin(db: AsyncSession, space_id: UUID, user_uuid: UUID) -> SpaceMember:
    """Verify user is the owner or an admin of the space.

    Raises:
        AuthorizationError: If the user is not an owner/admin.
    """
    member = await verify_membership(db, space_id, user_uuid)
    if member.role not in ("OWNER", "ADMIN"):
        raise AuthorizationError("you need admin permissions")
    return member


async def verify_owner(db: AsyncSession, space_id: UUID, user_uuid: UUID) -> SpaceMember:
    """Verify user is the owner of the space.

    Raises:
        AuthorizationError: If the user is not the owner.
    """
    member = await verify_membership(db, space_id, user_uuid)
    if member.role != "OWNER":
        raise AuthorizationError("you need owner permissions")
    return member
