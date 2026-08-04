"""Searchable message model for full-text search.

This table implements the "dual-write" pattern for efficient message content search.
Messages are synced here from LangGraph checkpoints for fast PostgreSQL full-text search.

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID, uuid4 as uuid4_factory

from sqlalchemy import Index, String, text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    pass


class SearchableMessage(Base):
    """Searchable message for full-text search.

    This is a "flat" table optimized for search, separate from LangGraph's
    checkpoint storage. Messages are dual-written here during chat processing.

    Attributes:
        id: UUID primary key
        thread_id: LangGraph thread_id (same as session_id)
        user_uuid: Owner's UUID for access control
        role: Message role - 'user' or 'assistant'
        content: Message text content for search
        created_at: When the message was created
        updated_at: When the record was last updated
    """

    __tablename__ = "searchable_messages"

    # GIN index on to_tsvector('simple', content) must be declared here so
    # alembic autogenerate knows it is ORM-managed and does not propose dropping it.
    __table_args__ = (
        Index(
            "ix_searchable_messages_content_gin",
            text("to_tsvector('simple', content)"),
            postgresql_using="gin",
        ),
    )

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    # sessions PK is still `id` (pending migration to `uuid`); pin until then.
    thread_id: Mapped[UUID] = col.uuid_fk("sessions", ondelete="CASCADE", index=True, column="id")
    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="id")
    role: Mapped[str] = mapped_column(String(20))
    content: Mapped[str] = col.text_column()
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)
