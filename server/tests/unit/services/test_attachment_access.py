"""Attachment access is owner-only.

``resolve_attachment`` used to grant read access to co-members of ANY shared
space, for ALL of the owner's attachments — regardless of what the attachment
was. No feature consumes cross-user file access (chat images, transaction
receipts and avatars all resolve for the owner), so the co-membership branch
was pure attack surface: one leaked attachment UUID let a co-member read
private files. These tests pin owner-only semantics.
"""

from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError, FileErrorCode
from app.models.attachment import Attachment
from app.models.shared_space import SharedSpace, SpaceMember
from app.models.user import User
from app.services.upload_service import UploadService


async def _user(db: AsyncSession, tag: str) -> User:
    user = User(
        uuid=uuid4(),
        username=f"{tag}-{uuid4().hex[:8]}",
        email=f"{tag}-{uuid4().hex[:8]}@example.com",
        password="hash",
        registration_type="email",
    )
    db.add(user)
    await db.flush()
    return user


@pytest.fixture()
async def _shared_world(db_session: AsyncSession):
    """Owner + co-member sharing a space + stranger (not in any shared space),
    with a private attachment owned by the owner."""
    owner = await _user(db_session, "owner")
    comember = await _user(db_session, "co")
    stranger = await _user(db_session, "stranger")

    space = SharedSpace(name="family", creator_uuid=owner.uuid)
    db_session.add(space)
    await db_session.flush()
    db_session.add_all(
        [
            SpaceMember(space_id=space.id, user_uuid=owner.uuid),
            SpaceMember(space_id=space.id, user_uuid=comember.uuid),
        ]
    )
    attachment = Attachment(
        id=uuid4(),
        user_uuid=owner.uuid,
        filename="private-receipt.png",
        object_key=f"u/{owner.uuid}/private-receipt.png",
        mime_type="image/png",
    )
    db_session.add(attachment)
    await db_session.commit()
    return owner, comember, stranger, attachment


@pytest.mark.asyncio
async def test_owner_can_resolve_own_attachment(db_session: AsyncSession, _shared_world) -> None:
    owner, _, _, attachment = _shared_world
    resolved = await UploadService(db_session).resolve_attachment(attachment.id, owner.uuid)
    assert resolved.id == attachment.id


@pytest.mark.asyncio
async def test_space_co_member_is_denied(db_session: AsyncSession, _shared_world) -> None:
    """Same shared space no longer grants blanket read access."""
    _, comember, _, attachment = _shared_world
    with pytest.raises(BusinessError) as exc:
        await UploadService(db_session).resolve_attachment(attachment.id, comember.uuid)
    assert exc.value.error_code == FileErrorCode.FILE_NOT_FOUND


@pytest.mark.asyncio
async def test_stranger_is_denied(db_session: AsyncSession, _shared_world) -> None:
    _, _, stranger, attachment = _shared_world
    with pytest.raises(BusinessError) as exc:
        await UploadService(db_session).resolve_attachment(attachment.id, stranger.uuid)
    assert exc.value.error_code == FileErrorCode.FILE_NOT_FOUND
