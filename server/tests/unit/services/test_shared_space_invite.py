"""Shared space invite code security tests.

Locks the H2 hardening: invite codes are 8-char confusion-free alphanumeric
(32^8 ~= 1.1e12 combinations instead of the old 10^6 numeric), join errors
fold "not found / inactive / expired" into one message so an attacker cannot
probe which codes exist, and input is normalized (case + whitespace).
"""

from datetime import UTC, datetime, timedelta
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import BusinessError, NotFoundError, SpaceErrorCode
from app.models.shared_space import SharedSpace
from app.models.user import User
from app.services.shared_space_service import SharedSpaceService

_INVITE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


async def _seed_user(db: AsyncSession, username: str, email: str) -> User:
    user = User(uuid=uuid4(), username=username, email=email, password="hash", registration_type="email")
    db.add(user)
    await db.commit()
    return user


async def _seed_space(db: AsyncSession, creator: User, **kwargs) -> SharedSpace:
    space = SharedSpace(
        name="Test Space",
        creator_uuid=creator.id,
        status=kwargs.pop("status", "active"),
        **kwargs,
    )
    db.add(space)
    await db.commit()
    return space


@pytest.mark.asyncio
async def test_generate_invite_code_uses_confusion_free_alphabet(db_session: AsyncSession):
    owner = await _seed_user(db_session, "owner", "owner@example.com")
    service = SharedSpaceService(db_session)
    space = await service.create_space(owner.uuid, "Family")

    invite = await service.generate_invite_code(space.id, owner.uuid)

    code = invite["code"]
    assert len(code) == 8
    assert all(ch in _INVITE_ALPHABET for ch in code), f"code {code!r} contains confusable characters"


@pytest.mark.asyncio
async def test_join_with_valid_code(db_session: AsyncSession):
    owner = await _seed_user(db_session, "owner", "owner@example.com")
    joiner = await _seed_user(db_session, "joiner", "joiner@example.com")
    service = SharedSpaceService(db_session)
    space = await service.create_space(owner.uuid, "Family")
    invite = await service.generate_invite_code(space.id, owner.uuid)

    result = await service.join_with_code(invite["code"], joiner.uuid)

    assert result["id"] == str(space.id)
    assert result["role"] == "MEMBER"


@pytest.mark.asyncio
async def test_join_normalizes_case_and_whitespace(db_session: AsyncSession):
    owner = await _seed_user(db_session, "owner", "owner@example.com")
    joiner = await _seed_user(db_session, "joiner", "joiner@example.com")
    service = SharedSpaceService(db_session)
    space = await service.create_space(owner.uuid, "Family")
    code = (await service.generate_invite_code(space.id, owner.uuid))["code"]

    result = await service.join_with_code(f"  {code.lower()} ", joiner.uuid)

    assert result["id"] == str(space.id)


@pytest.mark.asyncio
async def test_join_with_invalid_code_raises_not_found(db_session: AsyncSession):
    user = await _seed_user(db_session, "user", "user@example.com")
    service = SharedSpaceService(db_session)

    with pytest.raises(NotFoundError, match="invalid or expired invitation code"):
        await service.join_with_code("ZZZZZZZZ", user.uuid)


@pytest.mark.asyncio
async def test_join_with_expired_code_folds_into_same_error(db_session: AsyncSession):
    user = await _seed_user(db_session, "user", "user@example.com")
    await _seed_space(
        db_session,
        creator=user,
        invite_code="ABCD2345",
        invite_code_expires_at=datetime.now(UTC) - timedelta(minutes=1),
    )
    service = SharedSpaceService(db_session)

    with pytest.raises(NotFoundError, match="invalid or expired invitation code"):
        await service.join_with_code("ABCD2345", user.uuid)


@pytest.mark.asyncio
async def test_join_with_archived_space_folds_into_same_error(db_session: AsyncSession):
    user = await _seed_user(db_session, "user", "user@example.com")
    await _seed_space(
        db_session,
        creator=user,
        invite_code="ABCD2345",
        invite_code_expires_at=datetime.now(UTC) + timedelta(days=1),
        status="archived",
    )
    service = SharedSpaceService(db_session)

    with pytest.raises(NotFoundError, match="invalid or expired invitation code"):
        await service.join_with_code("ABCD2345", user.uuid)


@pytest.mark.asyncio
async def test_join_already_member_keeps_distinct_error(db_session: AsyncSession):
    owner = await _seed_user(db_session, "owner", "owner@example.com")
    service = SharedSpaceService(db_session)
    space = await service.create_space(owner.uuid, "Family")
    code = (await service.generate_invite_code(space.id, owner.uuid))["code"]

    with pytest.raises(BusinessError) as exc_info:
        await service.join_with_code(code, owner.uuid)
    assert exc_info.value.error_code == SpaceErrorCode.ALREADY_MEMBER_OR_HAS_BEEN_INVITED


def test_join_space_rate_limit_registered():
    assert "join_space" in settings.RATE_LIMIT_ENDPOINTS
    assert settings.RATE_LIMIT_JOIN_SPACE
