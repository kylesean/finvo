"""Repository for User aggregate operations."""

from __future__ import annotations

from uuid import UUID

from sqlalchemy import select

from app.models.user import User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    """Data access for the User aggregate."""

    model = User

    async def get_by_uuid(self, user_uuid: UUID) -> User | None:
        """Get a user by their UUID (the users table primary key)."""
        result = await self.db.execute(select(User).where(User.uuid == user_uuid))
        return result.scalar_one_or_none()
