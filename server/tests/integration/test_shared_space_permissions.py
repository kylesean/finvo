"""Shared space permission matrix integration tests.

Covers the authorization matrix end-to-end at the API boundary (and
service boundary for the owner/member positive controls):

- Non-member (eve) hitting every space endpoint -> 403.
- Plain member (bob) attempting admin/owner-only actions -> 403.
- Owner (alice) passing all actions (positive control).

These negative cases were the biggest coverage gap: previously only happy
paths existed, so an IDOR or missing verify_* call would have gone
unnoticed.
"""

from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthorizationError
from app.models.shared_space import SharedSpace, SpaceMember
from app.models.user import User
from app.services.shared_space_service import SharedSpaceService

SPACE_API = "/api/v1/shared-spaces"


async def _seed_user(db_session: AsyncSession, username: str, email: str) -> User:
    user = User(
        uuid=uuid4(),
        username=username,
        email=email,
        password="hashed_password",
        registration_type="email",
    )
    db_session.add(user)
    await db_session.commit()
    return user


async def _seed_space(db_session: AsyncSession, owner: User, members: list[User]) -> SharedSpace:
    space = SharedSpace(
        id=uuid4(),
        name="permission matrix space",
        creator_uuid=owner.uuid,
    )
    db_session.add(space)
    await db_session.commit()
    db_session.add(
        SpaceMember(
            space_id=space.id,
            user_uuid=owner.uuid,
            role="OWNER",
            status="ACCEPTED",
        )
    )
    for member in members:
        db_session.add(
            SpaceMember(
                space_id=space.id,
                user_uuid=member.uuid,
                role="MEMBER",
                status="ACCEPTED",
            )
        )
    await db_session.commit()
    return space


@pytest.mark.asyncio
async def _seed_scenario(db_session: AsyncSession):
    """alice owns the space, bob is a member, test_user (eve) is NOT a member."""
    alice = await _seed_user(db_session, "matrix_alice", "matrix_alice@example.com")
    bob = await _seed_user(db_session, "matrix_bob", "matrix_bob@example.com")
    space = await _seed_space(db_session, alice, [bob])
    return alice, bob, space


class TestNonMemberRejected:
    """test_user is not a member of the space — every endpoint must 403."""

    @pytest.mark.asyncio
    async def test_non_member_cannot_view_space_detail(self, client_with_auth, db_session, test_user):
        _, _, space = await _seed_scenario(db_session)
        response = client_with_auth.get(f"{SPACE_API}/{space.id}")
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_non_member_cannot_list_space_transactions(self, client_with_auth, db_session, test_user):
        _, _, space = await _seed_scenario(db_session)
        response = client_with_auth.get(f"{SPACE_API}/{space.id}/transactions")
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_non_member_cannot_view_settlement(self, client_with_auth, db_session, test_user):
        _, _, space = await _seed_scenario(db_session)
        response = client_with_auth.get(f"{SPACE_API}/{space.id}/settlement")
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_non_member_cannot_generate_invite_code(self, client_with_auth, db_session, test_user):
        _, _, space = await _seed_scenario(db_session)
        response = client_with_auth.post(f"{SPACE_API}/{space.id}/invite-code")
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_non_member_cannot_update_space(self, client_with_auth, db_session, test_user):
        _, _, space = await _seed_scenario(db_session)
        response = client_with_auth.put(f"{SPACE_API}/{space.id}", json={"name": "hijacked"})
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_non_member_cannot_delete_space(self, client_with_auth, db_session, test_user):
        _, _, space = await _seed_scenario(db_session)
        response = client_with_auth.delete(f"{SPACE_API}/{space.id}")
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_non_member_cannot_update_member_role(self, client_with_auth, db_session, test_user):
        _, bob, space = await _seed_scenario(db_session)
        response = client_with_auth.put(f"{SPACE_API}/{space.id}/members/{bob.uuid}/role", json={"role": "ADMIN"})
        assert response.status_code == 403, response.text

    @pytest.mark.asyncio
    async def test_non_member_cannot_remove_member(self, client_with_auth, db_session, test_user):
        _, bob, space = await _seed_scenario(db_session)
        response = client_with_auth.delete(f"{SPACE_API}/{space.id}/members/{bob.uuid}")
        assert response.status_code == 403, response.text


class TestMemberRejected:
    """bob is a plain member — admin/owner-only actions must be rejected."""

    @pytest.mark.asyncio
    async def test_member_cannot_admin_actions(self, db_session: AsyncSession):
        alice, bob, space = await _seed_scenario(db_session)
        service = SharedSpaceService(db_session)

        with pytest.raises(AuthorizationError):
            await service.update_space(space.id, bob.uuid, name="hijacked")
        with pytest.raises(AuthorizationError):
            await service.generate_invite_code(space.id, bob.uuid)
        with pytest.raises(AuthorizationError):
            await service.remove_member(space.id, bob.uuid, alice.uuid)

    @pytest.mark.asyncio
    async def test_member_cannot_owner_actions(self, db_session: AsyncSession):
        _, bob, space = await _seed_scenario(db_session)
        service = SharedSpaceService(db_session)

        with pytest.raises(AuthorizationError):
            await service.delete_space(space.id, bob.uuid)
        with pytest.raises(AuthorizationError):
            await service.update_member_role(space.id, bob.uuid, bob.uuid, "OWNER")

    @pytest.mark.asyncio
    async def test_member_cannot_access_space_they_do_not_belong_to(self, db_session: AsyncSession):
        """IDOR variant: bob is a member of space A but tries to read space B."""
        alice, bob, _ = await _seed_scenario(db_session)
        other_owner = await _seed_user(db_session, "matrix_other", "matrix_other@example.com")
        space_b = await _seed_space(db_session, other_owner, [])

        service = SharedSpaceService(db_session)

        # bob is NOT a member of space B.
        with pytest.raises(AuthorizationError):
            await service.get_space_detail(space_b.id, bob.uuid)


class TestOwnerPositiveControl:
    """alice (OWNER) passes every action — guards against over-broad tests."""

    @pytest.mark.asyncio
    async def test_owner_can_all_actions(self, db_session: AsyncSession):
        alice, bob, space = await _seed_scenario(db_session)
        service = SharedSpaceService(db_session)

        detail = await service.get_space_detail(space.id, alice.uuid)
        assert detail["id"] == str(space.id)

        invite = await service.generate_invite_code(space.id, alice.uuid)
        assert len(invite["code"]) == 8

        await service.update_space(space.id, alice.uuid, name="renamed")
        await service.update_member_role(space.id, alice.uuid, bob.uuid, "ADMIN")
        assert await service.delete_space(space.id, alice.uuid) is True
