"""Repository for ChatSession database operations."""

from __future__ import annotations

import uuid
from typing import TYPE_CHECKING

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.logging import logger

if TYPE_CHECKING:
    from app.models.session import Session as ChatSession


class SessionRepository:
    """Repository for ChatSession CRUD operations.

    Provides async database operations for session management.
    Uses dependency injection pattern - receives session in constructor.
    """

    def __init__(self, db: AsyncSession):
        """Initialize repository with database session.

        Args:
            db: Async database session
        """
        self.db = db

    async def create(
        self,
        session_id: uuid.UUID,
        user_uuid: uuid.UUID,
        name: str = "",
    ) -> ChatSession:
        """Create a new chat session.

        Args:
            session_id: Unique session identifier
            user_uuid: Owner's UUID
            name: Optional session name (defaults to empty string)

        Returns:
            ChatSession: The created session
        """
        from app.models.session import Session as ChatSession

        chat_session = ChatSession(
            id=session_id,
            user_uuid=user_uuid,
            name=name,
        )
        self.db.add(chat_session)
        await self.db.flush()
        await self.db.refresh(chat_session)

        logger.info(
            "session_created",
            session_id=session_id,
            user_uuid=user_uuid,
            name=name,
        )

        return chat_session

    async def get(
        self,
        session_id: uuid.UUID,
    ) -> ChatSession | None:
        """Get a session by ID.

        Args:
            session_id: Session identifier

        Returns:
            ChatSession if found, None otherwise
        """
        from app.models.session import Session as ChatSession

        result = await self.db.execute(select(ChatSession).where(ChatSession.id == session_id))
        return result.scalar_one_or_none()

    async def get_by_user(
        self,
        user_uuid: uuid.UUID,
    ) -> list[ChatSession]:
        """Get all sessions for a user.

        Args:
            user_uuid: User's UUID

        Returns:
            List of ChatSession objects
        """
        from app.models.session import Session as ChatSession

        result = await self.db.execute(
            select(ChatSession).where(ChatSession.user_uuid == user_uuid).order_by(ChatSession.created_at.desc())
        )
        return list(result.scalars().all())

    async def update_name(
        self,
        session_id: uuid.UUID,
        name: str,
    ) -> ChatSession | None:
        """Update a session's name.

        Args:
            session_id: Session identifier
            name: New session name

        Returns:
            Updated ChatSession if found, None otherwise
        """
        from app.models.session import Session as ChatSession

        result = await self.db.execute(select(ChatSession).where(ChatSession.id == session_id))
        chat_session = result.scalar_one_or_none()

        if chat_session:
            chat_session.name = name
            await self.db.flush()
            await self.db.refresh(chat_session)

            logger.info(
                "session_name_updated",
                session_id=session_id,
                name=name,
            )

        return chat_session

    async def delete(
        self,
        session_id: uuid.UUID,
    ) -> bool:
        """Delete a session by ID.

        Args:
            session_id: Session identifier

        Returns:
            True if deleted, False if not found
        """
        from app.models.session import Session as ChatSession

        result = await self.db.execute(delete(ChatSession).where(ChatSession.id == session_id))

        deleted = bool(getattr(result, "rowcount", 0) > 0)
        if deleted:
            logger.info("session_deleted", session_id=session_id)

        return deleted
