"""Budget models for financial budget management.

Includes Budget, BudgetPeriod, and BudgetSettings models.
This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from typing import TYPE_CHECKING
from uuid import UUID, uuid4 as uuid4_factory

import sqlalchemy as sa
from sqlalchemy import Boolean, CheckConstraint, Index, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    from app.models.user import User


# ============================================================================
# Enums
# ============================================================================


class BudgetScope(str, Enum):
    """Budget scope - total or category-specific."""

    TOTAL = "TOTAL"
    CATEGORY = "CATEGORY"


class BudgetType(str, Enum):
    """Budget type."""

    EXPENSE_LIMIT = "EXPENSE_LIMIT"


class BudgetPeriodType(str, Enum):
    """Budget period type."""

    WEEKLY = "WEEKLY"
    BIWEEKLY = "BIWEEKLY"
    MONTHLY = "MONTHLY"
    YEARLY = "YEARLY"


class BudgetSource(str, Enum):
    """Budget creation source."""

    AI_SUGGESTED = "AI_SUGGESTED"
    USER_DEFINED = "USER_DEFINED"


class BudgetStatus(str, Enum):
    """Budget status."""

    ACTIVE = "ACTIVE"
    PAUSED = "PAUSED"
    ARCHIVED = "ARCHIVED"


class BudgetPeriodStatus(str, Enum):
    """Budget period tracking status."""

    ON_TRACK = "ON_TRACK"
    WARNING = "WARNING"
    EXCEEDED = "EXCEEDED"
    ACHIEVED = "ACHIEVED"


# ============================================================================
# Budget Model
# ============================================================================


class Budget(Base):
    """Budget model for managing spending limits.

    Supports both total budgets and category-specific budgets.

    Attributes:
        id: Primary key (UUID)
        owner_uuid: Foreign key to users.uuid
        shared_space_id: Reserved for shared-space collaborative budgets
        name: Budget display name
        type: Always EXPENSE_LIMIT
        scope: TOTAL or CATEGORY
        category_key: Category key for category budgets (NULL for total)
        amount: Budget limit amount
        currency_code: Currency code (default CNY)
        period_type: WEEKLY, BIWEEKLY, MONTHLY, or YEARLY
        period_anchor_day: Day of month/week to start new period (1-31)
        rollover_enabled: Whether unused budget rolls over
        rollover_balance: Current rollover balance (can be negative)
        source: AI_SUGGESTED or USER_DEFINED
        ai_confidence: Confidence score for AI suggestions
        status: ACTIVE, PAUSED, or ARCHIVED
        created_at: Creation timestamp
        updated_at: Last update timestamp
    """

    __tablename__ = "budgets"
    __table_args__ = (
        CheckConstraint("scope IN ('TOTAL', 'CATEGORY')", name="chk_budgets_scope"),
        CheckConstraint("period_type IN ('WEEKLY', 'BIWEEKLY', 'MONTHLY', 'YEARLY')", name="chk_budgets_period_type"),
        CheckConstraint("period_anchor_day >= 1 AND period_anchor_day <= 31", name="chk_budgets_anchor_day"),
        CheckConstraint("source IN ('AI_SUGGESTED', 'USER_DEFINED')", name="chk_budgets_source"),
        CheckConstraint("status IN ('ACTIVE', 'PAUSED', 'ARCHIVED')", name="chk_budgets_status"),
        CheckConstraint("amount >= 0", name="chk_budgets_amount_positive"),
    )

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    owner_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="id")
    shared_space_id: Mapped[UUID | None] = col.uuid_fk(
        "shared_spaces", ondelete="SET NULL", index=True, nullable=True, column="id"
    )

    name: Mapped[str] = mapped_column(String(100))
    type: Mapped[str] = mapped_column(String(20), default="EXPENSE_LIMIT", server_default=sa.text("'EXPENSE_LIMIT'"))
    scope: Mapped[str] = mapped_column(String(20))
    category_key: Mapped[str | None] = mapped_column(String(25), nullable=True, index=True)

    amount: Mapped[Decimal] = col.numeric(precision=20, scale=8)
    currency_code: Mapped[str] = mapped_column(String(3), default="CNY", server_default=sa.text("'CNY'"))

    period_type: Mapped[str] = mapped_column(String(20), default="MONTHLY", server_default=sa.text("'MONTHLY'"))
    period_anchor_day: Mapped[int] = mapped_column(Integer, default=1, server_default=sa.text("1"))

    rollover_enabled: Mapped[bool] = mapped_column(Boolean, default=True, server_default=sa.text("true"))
    rollover_balance: Mapped[Decimal] = col.numeric(precision=20, scale=8, default=Decimal("0"))

    source: Mapped[str] = mapped_column(String(20), default="USER_DEFINED", server_default=sa.text("'USER_DEFINED'"))
    ai_confidence: Mapped[Decimal | None] = col.numeric(precision=5, scale=4, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="ACTIVE", server_default=sa.text("'ACTIVE'"))

    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    owner: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[Budget.owner_uuid]",
        primaryjoin="Budget.owner_uuid == User.id",
    )
    periods: Mapped[list[BudgetPeriod]] = relationship(
        "BudgetPeriod",
        back_populates="budget",
        cascade="all, delete-orphan",
    )

    @property
    def amount_float(self) -> float:
        """Get amount as float."""
        return float(self.amount)

    @property
    def rollover_balance_float(self) -> float:
        """Get rollover balance as float."""
        return float(self.rollover_balance)

    @property
    def is_total_budget(self) -> bool:
        """Check if this is a total budget."""
        return self.scope == BudgetScope.TOTAL.value

    @property
    def is_category_budget(self) -> bool:
        """Check if this is a category-specific budget."""
        return self.scope == BudgetScope.CATEGORY.value

    @property
    def is_active(self) -> bool:
        """Check if budget is active."""
        return self.status == BudgetStatus.ACTIVE.value


# ============================================================================
# BudgetPeriod Model
# ============================================================================


class BudgetPeriod(Base):
    """Budget period tracking model.

    Tracks spending progress for each budget period (week/month/year).

    Attributes:
        id: Primary key (UUID)
        budget_id: Foreign key to budgets
        period_start: Start date of the period
        period_end: End date of the period
        spent_amount: Amount spent in this period
        rollover_in: Amount rolled over from previous period
        rollover_out: Amount to roll over to next period
        adjusted_target: Adjusted budget target (original + rollover_in)
        status: ON_TRACK, WARNING, EXCEEDED, or ACHIEVED
        ai_forecast: AI-predicted end-of-period spending
        notes: Optional notes
        created_at: Creation timestamp
        updated_at: Last update timestamp
    """

    __tablename__ = "budget_periods"
    __table_args__ = (
        CheckConstraint("period_end >= period_start", name="chk_budget_periods_dates"),
        CheckConstraint("status IN ('ON_TRACK', 'WARNING', 'EXCEEDED', 'ACHIEVED')", name="chk_budget_periods_status"),
        CheckConstraint("spent_amount >= 0", name="chk_budget_periods_spent_positive"),
        UniqueConstraint("budget_id", "period_start", name="uq_budget_periods_budget_start"),
        Index("ix_budget_periods_dates", "period_start", "period_end"),
    )

    id: Mapped[UUID] = col.uuid_pk(uuid4_factory)
    budget_id: Mapped[UUID] = col.uuid_fk("budgets", ondelete="CASCADE", index=True, column="id")

    period_start: Mapped[date] = col.date_column()
    period_end: Mapped[date] = col.date_column()

    spent_amount: Mapped[Decimal] = col.numeric(precision=20, scale=8, default=Decimal("0"))
    rollover_in: Mapped[Decimal] = col.numeric(precision=20, scale=8, default=Decimal("0"))
    rollover_out: Mapped[Decimal] = col.numeric(precision=20, scale=8, default=Decimal("0"))
    adjusted_target: Mapped[Decimal] = col.numeric(precision=20, scale=8)

    status: Mapped[str] = mapped_column(String(20), default="ON_TRACK", server_default=sa.text("'ON_TRACK'"))
    ai_forecast: Mapped[Decimal | None] = col.numeric(precision=20, scale=8, nullable=True)

    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    budget: Mapped[Budget | None] = relationship("Budget", back_populates="periods")

    @property
    def spent_amount_float(self) -> float:
        """Get spent amount as float."""
        return float(self.spent_amount)

    @property
    def adjusted_target_float(self) -> float:
        """Get adjusted target as float."""
        return float(self.adjusted_target)

    @property
    def remaining_amount(self) -> Decimal:
        """Calculate remaining budget."""
        return self.adjusted_target - self.spent_amount

    @property
    def remaining_amount_float(self) -> float:
        """Get remaining amount as float."""
        return float(self.remaining_amount)

    @property
    def usage_percentage(self) -> float:
        """Calculate usage percentage."""
        if self.adjusted_target == 0:
            return 0.0
        return float(self.spent_amount / self.adjusted_target * 100)

    @property
    def is_exceeded(self) -> bool:
        """Check if budget is exceeded."""
        return self.spent_amount > self.adjusted_target


# ============================================================================
# BudgetSettings Model
# ============================================================================


class BudgetSettings(Base):
    """User budget threshold preferences.

    One-to-one relationship with User (user_uuid is primary key).

    Attributes:
        user_uuid: Primary key, references users.uuid
        warning_threshold: Percentage threshold for WARNING status (default 70)
        alert_threshold: Percentage threshold for EXCEEDED status (default 90)
        created_at: Creation timestamp
        updated_at: Last update timestamp
    """

    __tablename__ = "budget_settings"
    __table_args__ = (
        CheckConstraint("warning_threshold >= 0 AND warning_threshold <= 100", name="chk_budget_settings_warning"),
        CheckConstraint("alert_threshold >= 0 AND alert_threshold <= 100", name="chk_budget_settings_alert"),
        CheckConstraint("warning_threshold <= alert_threshold", name="chk_budget_settings_thresholds"),
    )

    user_uuid: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        sa.ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )

    warning_threshold: Mapped[int] = mapped_column(Integer, default=70, server_default=sa.text("70"))
    alert_threshold: Mapped[int] = mapped_column(Integer, default=90, server_default=sa.text("90"))
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[BudgetSettings.user_uuid]",
        primaryjoin="BudgetSettings.user_uuid == User.id",
    )
