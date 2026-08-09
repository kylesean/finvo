"""Integration tests for member-leave notifications.

When a member leaves a shared space (or is removed by an admin), the other
ACCEPTED members receive a ``member_left`` notification so open clients can
drop the departing member from their member lists in realtime.

Notifications are created by fire-and-forget event-bus handlers running as
background tasks, so assertions poll the DB for a short window instead of
querying immediately after the HTTP response.
"""

import asyncio
from uuid import uuid4

import pytest
from sqlalchemy import select

from app.models.notification import Notification
from app.models.shared_space import SharedSpace, SpaceMember
from app.models.user import User


async def _wait_for_notifications(db_session, *, user_uuid, type_, max_attempts: int = 20):
    """Poll until the background notification handler has written rows."""
    for _ in range(max_attempts):
        rows = (
            (
                await db_session.execute(
                    select(Notification).where(
                        Notification.user_uuid == user_uuid,
                        Notification.type == type_,
                    )
                )
            )
            .scalars()
            .all()
        )
        if rows:
            return rows
        await asyncio.sleep(0.1)
    return []


async def _seed_space(
    db_session,
    owner_uuid,
    *member_uuids,
) -> SharedSpace:
    shared_space = SharedSpace(
        id=uuid4(),
        name="member left notify space",
        creator_uuid=owner_uuid,
    )
    db_session.add(shared_space)
    await db_session.commit()
    db_session.add(
        SpaceMember(
            space_id=shared_space.id,
            user_uuid=owner_uuid,
            role="OWNER",
            status="ACCEPTED",
        )
    )
    for member_uuid in member_uuids:
        db_session.add(
            SpaceMember(
                space_id=shared_space.id,
                user_uuid=member_uuid,
                status="ACCEPTED",
            )
        )
    await db_session.commit()
    return shared_space


@pytest.mark.asyncio
async def test_leave_space_notifies_remaining_members(client_with_auth, db_session, test_user):
    """Leaving a space notifies the remaining accepted members."""
    alice = User(
        uuid=uuid4(),
        username="integration_alice",
        email="alice@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(alice)
    bob = User(
        uuid=uuid4(),
        username="integration_bob",
        email="bob@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(bob)
    await db_session.commit()

    # test_user is the leaver; alice owns the space; bob is a plain member.
    shared_space = await _seed_space(db_session, alice.uuid, test_user.uuid, bob.uuid)

    response = client_with_auth.post(f"/api/v1/shared-spaces/{shared_space.id}/leave")
    assert response.status_code == 200, response.text

    for member in (alice, bob):
        rows = await _wait_for_notifications(db_session, user_uuid=member.uuid, type_="member_left")
        member_rows = [row for row in rows if row.data.get("space_id") == str(shared_space.id)]
        assert len(member_rows) == 1, f"{member.username} must be notified about the leaver"
        assert member_rows[0].data.get("action") == "space_member_left"
        assert member_rows[0].data.get("reason") == "left"
        assert "integration_test_user" in member_rows[0].title


@pytest.mark.asyncio
async def test_remove_member_notifies_remaining_and_removed(client_with_auth, db_session, test_user):
    """Removing a member notifies remaining members and the removed user."""
    alice = User(
        uuid=uuid4(),
        username="integration_alice",
        email="alice@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(alice)
    bob = User(
        uuid=uuid4(),
        username="integration_bob",
        email="bob@example.com",
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(bob)
    await db_session.commit()

    # test_user is the owner/admin; alice is the member removed by the admin;
    # bob is a remaining plain member.
    shared_space = await _seed_space(db_session, test_user.uuid, alice.uuid, bob.uuid)

    response = client_with_auth.delete(f"/api/v1/shared-spaces/{shared_space.id}/members/{alice.uuid}")
    assert response.status_code == 200, response.text

    # Remaining members (bob, and the acting admin test_user) are notified.
    rows = await _wait_for_notifications(db_session, user_uuid=bob.uuid, type_="member_left")
    admin_rows = await _wait_for_notifications(db_session, user_uuid=test_user.uuid, type_="member_left")
    rows = [*rows, *admin_rows]
    space_rows = [row for row in rows if row.data.get("space_id") == str(shared_space.id)]
    informed = {row.user_uuid for row in space_rows}
    assert {bob.uuid, test_user.uuid} <= informed
    assert alice.uuid not in informed
    assert {row.data.get("reason") for row in space_rows} == {"removed"}

    # The removed user receives a personal notification.
    personal = await _wait_for_notifications(db_session, user_uuid=alice.uuid, type_="space_activity")
    assert len(personal) == 1, [p.data for p in personal]
    assert personal[0].data.get("action") == "removed_from_space"
