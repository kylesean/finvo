"""Shared-space transaction association tests.

A lost race in ``add_transaction_to_space`` used to call ``db.rollback()`` —
the FULL session rollback — so when the ``(space_id, transaction_id)`` unique
constraint fired mid-UoW, every other uncommitted change in the caller's Unit
of Work was silently discarded (e.g. the transaction the user just created in
the same chat turn vanished while the API reported success). The
``begin_nested`` savepoint confines the rollback to the failed insert alone.
"""

import asyncio
from datetime import UTC, datetime
from decimal import Decimal
from uuid import uuid4

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession

from app.models.shared_space import SharedSpace, SpaceMember, SpaceTransaction
from app.models.transaction import Transaction
from app.models.user import User
from app.services.shared_space_transaction_service import SharedSpaceTransactionService


async def _seed(db: AsyncSession) -> tuple[User, SharedSpace, Transaction]:
    user_uuid = uuid4()
    user = User(
        uuid=user_uuid,
        username=f"space-tx-{user_uuid.hex[:8]}",
        email=f"space-tx-{user_uuid.hex[:8]}@example.com",
        password="hash",
        registration_type="email",
    )
    space = SharedSpace(name="family", creator_uuid=user.uuid, status="active")
    db.add_all([user, space])
    await db.flush()
    db.add_all(
        [
            SpaceMember(space_id=space.id, user_uuid=user.uuid, role="OWNER", status="ACCEPTED"),
            Transaction(
                uuid=uuid4(),
                user_uuid=user.uuid,
                type="EXPENSE",
                amount=Decimal("10"),
                amount_original=Decimal("10"),
                currency="CNY",
                transaction_at=datetime.now(UTC),
                status="CLEARED",
                source="AI",
            ),
        ]
    )
    await db.commit()

    tx = (await db.execute(select(Transaction).where(Transaction.user_uuid == user.uuid))).scalar_one()
    return user, space, tx


@pytest.mark.asyncio
async def test_add_then_readd_is_idempotent(db_session: AsyncSession) -> None:
    """Happy paths: first add succeeds, second hits the pre-check early-return."""
    user, space, tx = await _seed(db_session)
    service = SharedSpaceTransactionService(db_session)

    first = await service.add_transaction_to_space(space.id, user.uuid, tx.uuid)
    assert first.get("already_exists") is not True

    second = await service.add_transaction_to_space(space.id, user.uuid, tx.uuid)
    assert second["already_exists"] is True


@pytest.mark.asyncio
async def test_lost_race_keeps_outer_uow_alive(db_session: AsyncSession, async_db_engine: AsyncEngine) -> None:
    """A concurrent duplicate insert must NOT roll back the caller's UoW.

    Deterministic interleaving: the racer connection inserts the same pair but
    does not commit (invisible to our pre-check via MVCC, while it holds the
    unique-index slot). Our INSERT then blocks on that slot; the racer's commit
    releases it with an IntegrityError inside the service's savepoint.
    """
    user, space, tx = await _seed(db_session)
    service = SharedSpaceTransactionService(db_session)

    # Outer-UoW marker: an uncommitted change in the same session, made before
    # the association — exactly what the old full-rollback destroyed.
    tx.description = "created just before the race"
    await db_session.flush()

    racer = AsyncSession(async_db_engine, expire_on_commit=False)
    try:
        racer.add(SpaceTransaction(space_id=space.id, transaction_id=tx.uuid, added_by_user_uuid=user.uuid))
        await racer.flush()  # index entry locked, uncommitted

        task = asyncio.create_task(service.add_transaction_to_space(space.id, user.uuid, tx.uuid))
        await asyncio.sleep(0.2)  # let the pre-check pass and the INSERT block
        await racer.commit()

        result = await task
        assert result["already_exists"] is True

        # THE regression: the outer-UoW change must have survived the race.
        row = (await db_session.execute(select(Transaction).where(Transaction.uuid == tx.uuid))).scalar_one()
        assert row.description == "created just before the race"
    finally:
        await racer.close()
