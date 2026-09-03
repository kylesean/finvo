"""Shared-space status vocabulary: lowercase everywhere, CHECK-backed."""

from uuid import uuid4

import pytest
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants.space_constants import SpaceStatus
from app.models.shared_space import SharedSpace
from app.models.user import User
from app.services.shared_space_service import SharedSpaceService


async def _seed_user(db: AsyncSession) -> User:
    tag = uuid4().hex[:8]
    user = User(
        uuid=uuid4(),
        username=f"status_{tag}",
        email=f"status_{tag}@example.com",
        password="hash",
        registration_type="email",
    )
    db.add(user)
    await db.commit()
    return user


class TestSpaceStatus:
    @pytest.mark.asyncio
    async def test_create_uses_lowercase_active(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)

        space = await SharedSpaceService(db_session).create_space(user.uuid, "Family")

        assert space.status == SpaceStatus.ACTIVE.value == "active"

    @pytest.mark.asyncio
    async def test_archive_hides_space_from_list(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        service = SharedSpaceService(db_session)
        space = await service.create_space(user.uuid, "Family")

        await service.update_space(space.id, user.uuid, status=SpaceStatus.ARCHIVED)
        await db_session.refresh(space)

        assert space.status == "archived"
        assert (await service.get_user_spaces(user.uuid))["total"] == 0

    @pytest.mark.asyncio
    async def test_update_rejects_unknown_status(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        service = SharedSpaceService(db_session)
        space = await service.create_space(user.uuid, "Family")

        with pytest.raises(ValueError):
            await service.update_space(space.id, user.uuid, status="BOGUS")

    @pytest.mark.asyncio
    async def test_check_rejects_uppercase_write(self, db_session: AsyncSession) -> None:
        user = await _seed_user(db_session)
        db_session.add(
            SharedSpace(name="Drift", creator_uuid=user.uuid, status="ACTIVE"),
        )

        with pytest.raises(IntegrityError):
            await db_session.flush()
