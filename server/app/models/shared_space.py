"""Shared space models for collaborative financial management.

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID, uuid4 as uuid4_factory

import sqlalchemy as sa
from sqlalchemy import String, Text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    from app.models.transaction import Transaction
    from app.models.user import User


class SharedSpace(Base):
    """Shared space model for collaborative financial tracking."""

    __tablename__ = "shared_spaces"

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    name: Mapped[str] = mapped_column(String(50))
    creator_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", column="id", index=True)
    status: Mapped[str] = mapped_column(String(50), default="ACTIVE", server_default=sa.text("'ACTIVE'"))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    invite_code: Mapped[str | None] = mapped_column(String(20), nullable=True)
    invite_code_expires_at: Mapped[datetime | None] = col.datetime_tz(nullable=True)
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    creator: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[SharedSpace.creator_uuid]",
        primaryjoin="SharedSpace.creator_uuid == User.id",
    )
    members: Mapped[list[SpaceMember]] = relationship(
        "SpaceMember",
        back_populates="space",
        cascade="all, delete-orphan",
    )
    space_transactions: Mapped[list[SpaceTransaction]] = relationship(
        "SpaceTransaction",
        back_populates="space",
        cascade="all, delete-orphan",
    )


class SpaceMember(Base):
    """Space member model for tracking members in shared spaces."""

    __tablename__ = "space_members"

    space_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        sa.ForeignKey("shared_spaces.id", ondelete="CASCADE"),
        primary_key=True,
        index=True,
    )
    user_uuid: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        sa.ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
        index=True,
    )
    role: Mapped[str] = mapped_column(String(50), default="MEMBER", server_default=sa.text("'MEMBER'"))
    status: Mapped[str] = mapped_column(String(50), default="ACCEPTED", server_default=sa.text("'ACCEPTED'"))
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    space: Mapped[SharedSpace | None] = relationship("SharedSpace", back_populates="members")
    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[SpaceMember.user_uuid]",
        primaryjoin="SpaceMember.user_uuid == User.id",
    )


class SpaceTransaction(Base):
    """Space transaction model for associating transactions with shared spaces."""

    __tablename__ = "space_transactions"

    # A transaction can be associated with a space only once; the DB constraint
    # backstops the service's check-then-insert against concurrent duplicates.
    __table_args__ = (sa.UniqueConstraint("space_id", "transaction_id", name="uq_space_transactions_space_tx"),)

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    # shared_spaces PK is still `id` (pending migration to `uuid`); pin until then.
    space_id: Mapped[UUID] = col.uuid_fk("shared_spaces", ondelete="NO ACTION", column="id", index=True)
    transaction_id: Mapped[UUID] = col.uuid_fk("transactions", ondelete="CASCADE", index=True)
    added_by_user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", column="id")
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    space: Mapped[SharedSpace | None] = relationship("SharedSpace", back_populates="space_transactions")
    transaction: Mapped[Transaction | None] = relationship(
        "Transaction",
        foreign_keys="[SpaceTransaction.transaction_id]",
    )
    added_by: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[SpaceTransaction.added_by_user_uuid]",
        primaryjoin="SpaceTransaction.added_by_user_uuid == User.id",
    )
