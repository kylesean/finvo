"""Shared space ownership transfer + optimistic locking tests.

Locks:
- transfer_ownership: the owner can hand the space to an accepted member;
  the former owner drops to MEMBER and can no longer act as owner. This is
  the exit path leave_space advertises (previously only delete-and-recreate
  existed).
- Optimistic locking: name/role writes accept an expectedVersion and reject
  stale writes with ConflictError (409) instead of silently overwriting;
  omitting it keeps the previous overwrite semantics for old clients.
- remove_member purge_transactions: optionally deletes the removed
  member's SpaceTransaction associations so remaining members lose sight of
  their spending detail.
"""

from datetime import UTC, datetime
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthorizationError, BusinessError, ConflictError, NotFoundError
from app.models.shared_space import SharedSpace, SpaceMember, SpaceTransaction
from app.models.transaction import Transaction
from app.models.user import User
from app.services.shared_space_service import SharedSpaceService


async def _seed_user(db: AsyncSession, username: str, email: str) -> User:
    suffix = uuid4().hex[:8]
    user = User(
        uuid=uuid4(),
        username=f"{username}_{suffix}",
        email=f"{email.split('@')[0]}+{suffix}@{email.split('@')[1]}",
        password="hash",
        registration_type="email",
    )
    db.add(user)
    await db.commit()
    return user


async def _seed_space_with_members(db: AsyncSession) -> tuple[SharedSpace, User, User, SharedSpaceService]:
    owner = await _seed_user(db, "owner", "owner@example.com")
    member = await _seed_user(db, "member", "member@example.com")
    service = SharedSpaceService(db)
    space = await service.create_space(owner.uuid, "Family")

    # Add member via join path
    invite = await service.generate_invite_code(space.id, owner.uuid)
    await service.join_with_code(invite["code"], member.uuid)
    return space, owner, member, service


@pytest.mark.asyncio
async def test_transfer_ownership_swaps_roles(db_session: AsyncSession) -> None:
    space, owner, member, service = await _seed_space_with_members(db_session)

    result = await service.transfer_ownership(space.id, owner.uuid, member.uuid)

    assert result["role"] == "MEMBER"
    # Reload roles from DB
    q = await db_session.execute(__import__("sqlalchemy").select(SpaceMember).where(SpaceMember.space_id == space.id))
    members = {m.user_uuid: m.role for m in q.scalars().all()}
    assert members[owner.uuid] == "MEMBER"
    assert members[member.uuid] == "OWNER"

    # Former owner can no longer act as owner: transferring again raises
    with pytest.raises(AuthorizationError):
        await service.transfer_ownership(space.id, owner.uuid, member.uuid)
    # New owner can transfer back
    await service.transfer_ownership(space.id, member.uuid, owner.uuid)


@pytest.mark.asyncio
async def test_transfer_ownership_requires_accepted_member(db_session: AsyncSession) -> None:
    space, owner, member, service = await _seed_space_with_members(db_session)

    # Non-member cannot receive ownership
    outsider = await _seed_user(db_session, "outsider", "outsider@example.com")
    with pytest.raises(NotFoundError):
        await service.transfer_ownership(space.id, owner.uuid, outsider.uuid)

    # Transferring to yourself is rejected
    with pytest.raises(BusinessError):
        await service.transfer_ownership(space.id, owner.uuid, owner.uuid)

    # Non-owner cannot transfer
    with pytest.raises(AuthorizationError):
        await service.transfer_ownership(space.id, member.uuid, owner.uuid)


@pytest.mark.asyncio
async def test_version_bumps_on_metadata_writes(db_session: AsyncSession) -> None:
    space, owner, member, service = await _seed_space_with_members(db_session)
    await db_session.refresh(space)

    v0 = space.version

    await service.update_space(space.id, owner.uuid, name="Family 2")
    reloaded = await db_session.get(SharedSpace, space.id)
    assert reloaded.version == v0 + 1

    await service.update_member_role(space.id, owner.uuid, member.uuid, "ADMIN")
    await db_session.refresh(reloaded)
    assert reloaded.version == v0 + 2

    await service.transfer_ownership(space.id, owner.uuid, member.uuid)
    await db_session.refresh(reloaded)
    assert reloaded.version == v0 + 3


@pytest.mark.asyncio
async def test_stale_write_rejected_with_conflict(db_session: AsyncSession) -> None:
    space, owner, member, service = await _seed_space_with_members(db_session)
    await db_session.refresh(space)
    v = space.version

    # Concurrent writer bumps the version between read and write
    await service.update_space(space.id, owner.uuid, name="Concurrent edit")

    with pytest.raises(ConflictError):
        await service.update_space(space.id, owner.uuid, name="Stale edit", expected_version=v)

    with pytest.raises(ConflictError):
        await service.transfer_ownership(space.id, owner.uuid, member.uuid, expected_version=v)


@pytest.mark.asyncio
async def test_remove_member_purge_removes_their_transactions(db_session: AsyncSession) -> None:
    space, owner, member, service = await _seed_space_with_members(db_session)

    # Both users add an expense to the space
    async def _add_tx(user: User, amount: str, space: SharedSpace) -> SpaceTransaction:
        tx = Transaction(
            uuid=uuid4(),
            user_uuid=user.uuid,
            type="EXPENSE",
            amount=Decimal(amount),
            amount_original=Decimal(amount),
            currency="CNY",
            transaction_at=datetime.now(UTC),
            status="CLEARED",
        )
        db_session.add(tx)
        await db_session.flush()
        st = SpaceTransaction(
            id=uuid4(),
            space_id=space.id,
            transaction_id=tx.id,
            added_by_user_uuid=user.uuid,
        )
        db_session.add(st)
        await db_session.flush()
        return st

    await _add_tx(owner, "100.00", space)
    member_tx = await _add_tx(member, "50.00", space)

    # Default: transactions stay
    await service.remove_member(space.id, owner.uuid, member.uuid)
    assert await db_session.get(SpaceTransaction, member_tx.id) is not None

    # Purge: the removed member's associations vanish
    space2, owner2, member2, service2 = await _seed_space_with_members(db_session)
    member_tx2 = await _add_tx(member2, "25.00", space2)
    await service2.remove_member(space2.id, owner2.uuid, member2.uuid, purge_transactions=True)
    # Force reload: the identity map may still hold the pre-delete object.
    # Capture the id first — expire_all() makes attribute access lazy again.
    tx2_id = member_tx2.id
    db_session.expire_all()
    from sqlalchemy import select as sa_select

    remaining = await db_session.execute(sa_select(SpaceTransaction).where(SpaceTransaction.id == tx2_id))
    assert remaining.scalar_one_or_none() is None
