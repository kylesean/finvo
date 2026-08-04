"""Financial settings model for storing user's financial preferences.

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from enum import Enum
from typing import TYPE_CHECKING
from uuid import UUID

import sqlalchemy as sa
from sqlalchemy import Integer, String, text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    from app.models.user import User


class BurnRateMode(str, Enum):
    """Burn rate calculation mode."""

    MANUAL = "MANUAL"
    AI_AUTO = "AI_AUTO"


class FinancialSettings(Base):
    """Financial settings model for storing user's financial preferences.

    This model stores user-specific financial configuration such as
    safety thresholds, daily burn rates, and display preferences.

    Attributes:
        user_uuid: Primary key, references users.uuid
        safety_threshold: Minimum safe balance threshold (default: 1000)
        daily_burn_rate: Daily spending estimate (default: 100)
        burn_rate_mode: How burn rate is calculated (MANUAL or AI_AUTO)
        primary_currency: Default display currency (default: USD)
        month_start_day: Day of month to start calculations (default: 1)
        created_at: Creation timestamp
        updated_at: Last update timestamp
        user: Relationship to user
    """

    __tablename__ = "financial_settings"

    user_uuid: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        sa.ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    safety_threshold: Mapped[Decimal] = col.numeric(
        precision=20, scale=8, default=Decimal("1000.00"), server_default=text("1000.00")
    )
    daily_burn_rate: Mapped[Decimal] = col.numeric(
        precision=20, scale=8, default=Decimal("100.00"), server_default=text("100.00")
    )
    burn_rate_mode: Mapped[BurnRateMode] = mapped_column(
        String(20), default=BurnRateMode.AI_AUTO, server_default=sa.text("'AI_AUTO'")
    )
    primary_currency: Mapped[str] = mapped_column(
        String(3), default=PROJECT_DEFAULT_CURRENCY, server_default=sa.text("'CNY'")
    )
    month_start_day: Mapped[int] = mapped_column(Integer, default=1, server_default=sa.text("1"))
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    user: Mapped[User | None] = relationship(
        "User",
        foreign_keys="[FinancialSettings.user_uuid]",
        primaryjoin="FinancialSettings.user_uuid == User.id",
    )

    @property
    def safety_threshold_float(self) -> float:
        """Get safety threshold as float."""
        return float(self.safety_threshold)

    @property
    def daily_burn_rate_float(self) -> float:
        """Get daily burn rate as float."""
        return float(self.daily_burn_rate)
