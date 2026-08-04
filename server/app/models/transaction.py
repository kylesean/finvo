"""Transaction models for financial management.

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from typing import TYPE_CHECKING
from uuid import UUID, uuid4 as uuid4_factory

from sqlalchemy import Boolean, DateTime, ForeignKey, Index, Integer, String, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import JSONB, UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship, synonym

from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    from app.models.financial_account import FinancialAccount
    from app.models.user import User


class Transaction(Base):
    """Transaction model for storing financial transactions.

    Attributes:
        id: The primary key (UUID)
        user_uuid: Foreign key to users table (UUID)
        type: Transaction type (e.g., "EXPENSE", "INCOME", "TRANSFER")
        source_account_id: Source financial account ID (foreign key to finance_accounts.id)
        target_account_id: Target financial account ID (foreign key to finance_accounts.id)
        amount_original: Original transaction amount (high precision)
        amount: Transaction amount in base currency (high precision)
        currency: Currency code (e.g., "CNY")
        exchange_rate: Exchange rate used (optional)
        transaction_at: When the transaction occurred
        transaction_timezone: Timezone of the transaction
        tags: List of tags (JSON array)
        location: Transaction location
        latitude: Location latitude
        longitude: Location longitude
        source: Source of transaction (MANUAL, AI, IMPORT, etc.)
        status: Transaction status (CLEARED, PENDING, etc.)
        description: Transaction description
        raw_input: Raw input text from user (for AI-created transactions)
        shared_space_id: Shared space ID (optional)
        created_at: When the record was created
        updated_at: When the record was last updated
        comments: Relationship to transaction comments
        shares: Relationship to transaction shares
    """

    __tablename__ = "transactions"

    # Enforce recurring idempotency at the database layer: a recurring rule must
    # not produce two transactions for the exact same execution timestamp. The
    # DB backstops the application's count-based check (`_already_generated`),
    # guarding against duplicate entries when running multiple workers. NULL
    # ``recurring_transaction_id`` rows (non-recurring) are exempt.
    #
    # The indexes below mirror the production schema (ix_transactions_category,
    # _status, _transaction_at, _user_at) so `alembic autogenerate` does not
    # falsely propose dropping them.
    __table_args__ = (
        UniqueConstraint(
            "recurring_transaction_id",
            "transaction_at",
            name="uq_transactions_recurring_timestamp",
        ),
        Index("ix_transactions_category", "category_key"),
        Index("ix_transactions_status", "status"),
        Index("ix_transactions_transaction_at", "transaction_at"),
        Index("ix_transactions_user_at", "user_uuid", "transaction_at"),
    )

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    uuid = synonym("id")

    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="id")
    type: Mapped[str] = mapped_column(String(20))
    source_account_id: Mapped[UUID | None] = col.uuid_fk(
        "financial_accounts", ondelete="SET NULL", index=True, nullable=True, column="id"
    )
    target_account_id: Mapped[UUID | None] = col.uuid_fk(
        "financial_accounts", ondelete="SET NULL", index=True, nullable=True, column="id"
    )
    amount_original: Mapped[Decimal] = col.numeric(precision=20, scale=8)
    amount: Mapped[Decimal] = col.numeric(precision=20, scale=8)
    currency: Mapped[str] = mapped_column(String(3), default="CNY", server_default=text("'CNY'"))
    exchange_rate: Mapped[Decimal | None] = col.numeric(precision=20, scale=8, nullable=True)
    transaction_at: Mapped[datetime] = col.timestamptz()
    transaction_timezone: Mapped[str] = mapped_column(String(50), default="UTC", server_default=text("'UTC'"))
    tags: Mapped[list[str] | None] = mapped_column(JSONB, nullable=True)
    location: Mapped[str | None] = mapped_column(String(255), nullable=True)
    latitude: Mapped[Decimal | None] = col.numeric(precision=9, scale=6, nullable=True)
    longitude: Mapped[Decimal | None] = col.numeric(precision=9, scale=6, nullable=True)
    source: Mapped[str] = mapped_column(String(20), default="MANUAL", server_default=text("'MANUAL'"))
    status: Mapped[str] = mapped_column(String(20), default="CLEARED", server_default=text("'CLEARED'"))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    raw_input: Mapped[str] = mapped_column(Text, default="", server_default=text("''"))
    category_key: Mapped[str] = mapped_column(String(25), default="", server_default=text("''"))
    subject: Mapped[str] = mapped_column(String(20), default="SELF", server_default=text("'SELF'"))
    intent: Mapped[str] = mapped_column(String(20), default="SURVIVAL", server_default=text("'SURVIVAL'"))
    source_thread_id: Mapped[UUID | None] = col.uuid_column(index=True, nullable=True)
    recurring_transaction_id: Mapped[UUID | None] = col.uuid_fk(
        "recurring_transactions",
        ondelete="SET NULL",
        index=True,
        nullable=True,
        column="id",
    )
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[Transaction.user_uuid]",
        primaryjoin="Transaction.user_uuid == User.id",
    )

    comments: Mapped[list[TransactionComment]] = relationship(
        "TransactionComment",
        back_populates="transaction",
        cascade="all, delete-orphan",
    )
    shares: Mapped[list[TransactionShare]] = relationship(
        "TransactionShare",
        back_populates="transaction",
        cascade="all, delete-orphan",
    )

    source_account: Mapped[FinancialAccount | None] = relationship(
        "FinancialAccount",
        foreign_keys="[Transaction.source_account_id]",
        primaryjoin="Transaction.source_account_id == FinancialAccount.uuid",
    )

    target_account: Mapped[FinancialAccount | None] = relationship(
        "FinancialAccount",
        foreign_keys="[Transaction.target_account_id]",
        primaryjoin="Transaction.target_account_id == FinancialAccount.uuid",
    )

    @property
    def amount_float(self) -> float:
        """Get amount as float."""
        return float(self.amount)

    @property
    def amount_original_float(self) -> float:
        """Get original amount as float."""
        return float(self.amount_original)

    @property
    def absolute_amount(self) -> float:
        """Get absolute value of amount."""
        return abs(float(self.amount))

    @property
    def is_income(self) -> bool:
        """Check if transaction is income."""
        return self.type == "INCOME"

    @property
    def is_expense(self) -> bool:
        """Check if transaction is expense."""
        return self.type == "EXPENSE"

    @property
    def is_transfer(self) -> bool:
        """Check if transaction is transfer."""
        return self.type == "TRANSFER"


class TransactionComment(Base):
    """Transaction comment model for storing comments on transactions."""

    __tablename__ = "transaction_comments"

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    uuid = synonym("id")
    transaction_id: Mapped[UUID] = col.uuid_fk("transactions", ondelete="CASCADE", index=True, column="id")
    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="id")
    parent_comment_id: Mapped[UUID | None] = mapped_column(
        PGUUID(as_uuid=True), ForeignKey("transaction_comments.id", ondelete="CASCADE"), nullable=True
    )
    comment_text: Mapped[str] = mapped_column(Text)
    mentioned_user_ids: Mapped[list[str] | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    transaction: Mapped[Transaction | None] = relationship("Transaction", back_populates="comments")
    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[TransactionComment.user_uuid]",
        primaryjoin="TransactionComment.user_uuid == User.id",
    )


class RecurringTransaction(Base):
    """Recurring transaction model for scheduled transactions (RRULE rules)."""

    __tablename__ = "recurring_transactions"

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    uuid = synonym("id")
    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True)

    type: Mapped[str] = mapped_column(String(20))

    source_account_id: Mapped[UUID | None] = col.uuid_column(nullable=True)
    target_account_id: Mapped[UUID | None] = col.uuid_column(nullable=True)

    amount_type: Mapped[str] = mapped_column(String(20), default="FIXED", server_default=text("'FIXED'"))
    requires_confirmation: Mapped[bool] = mapped_column(Boolean, default=False, server_default=text("false"))
    amount: Mapped[Decimal] = col.numeric(precision=28, scale=8)
    currency: Mapped[str] = mapped_column(String(3), default="CNY", server_default=text("'CNY'"))

    category_key: Mapped[str] = mapped_column(String(50), default="OTHERS", server_default=text("'OTHERS'"))
    tags: Mapped[list[str] | None] = mapped_column(JSONB, nullable=True)

    recurrence_rule: Mapped[str] = mapped_column(String(255))
    timezone: Mapped[str] = mapped_column(String(50), default="Asia/Shanghai", server_default=text("'Asia/Shanghai'"))
    start_date: Mapped[date] = col.date_column()
    end_date: Mapped[date | None] = col.date_column(nullable=True)

    exception_dates: Mapped[list[str] | None] = mapped_column(JSONB, nullable=True)
    last_generated_at: Mapped[datetime | None] = col.datetime_tz(nullable=True)
    next_execution_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True, index=True)

    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, server_default=text("true"), index=True)
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[RecurringTransaction.user_uuid]",
        primaryjoin="RecurringTransaction.user_uuid == User.id",
    )

    @property
    def amount_float(self) -> float:
        """Get amount as float."""
        return float(self.amount)


class TransactionShare(Base):
    """Transaction share model for sharing transactions between users."""

    __tablename__ = "transaction_shares"

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    uuid = synonym("id")

    transaction_id: Mapped[UUID] = col.uuid_fk("transactions", ondelete="CASCADE", column="id")
    sharer_user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", column="id")
    shared_with_user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", column="id")
    can_view: Mapped[bool] = mapped_column(Boolean, default=True, server_default=text("true"))
    shared_at: Mapped[datetime] = col.datetime_tz()
    expires_at: Mapped[datetime] = col.datetime_tz()
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    transaction: Mapped[Transaction | None] = relationship("Transaction", back_populates="shares")
    sharer: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[TransactionShare.sharer_user_uuid]",
        primaryjoin="TransactionShare.sharer_user_uuid == User.id",
    )
    shared_with: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[TransactionShare.shared_with_user_uuid]",
        primaryjoin="TransactionShare.shared_with_user_uuid == User.id",
    )
