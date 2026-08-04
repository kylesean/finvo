"""Session model for storing chat sessions.

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID, uuid4 as uuid4_factory

import sqlalchemy as sa
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, synonym

from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    pass


class Session(Base):
    """Session model for storing chat sessions.

    Attributes:
        id: The primary key (UUID)
        uuid: Alias for id
        user_uuid: User's UUID
        name: Name of the session (defaults to empty string)
        created_at: When the session was created
        updated_at: When the session was updated
    """

    __tablename__ = "sessions"

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    uuid = synonym("id")
    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="id")
    name: Mapped[str] = mapped_column(String(255), default="", server_default=sa.text("''"))
    created_at: Mapped[datetime] = col.timestamptz(index=True)
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)
