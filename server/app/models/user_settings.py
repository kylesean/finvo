"""User settings model for storing user preferences.

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import ForeignKey, String, text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.models.base import Base, col, utc_now

if TYPE_CHECKING:
    from app.models.user import User


class UserSettings(Base):
    """User settings model for storing user preferences.

    Note: user_uuid is the primary key (no separate id field).

    Attributes:
        user_uuid: Primary key, references users.uuid
        currency: User's preferred currency (default: CNY)
        avg_daily_spending: Estimated average daily spending
        safety_balance_threshold: Minimum safe balance threshold
        created_at: When the settings were created
        updated_at: When the settings were last updated
        user: Relationship to user
    """

    __tablename__ = "user_settings"

    user_uuid: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    currency: Mapped[str] = mapped_column(String(10), default=PROJECT_DEFAULT_CURRENCY, server_default=text("'CNY'"))
    avg_daily_spending: Mapped[Decimal] = col.numeric(
        nullable=False, default=Decimal("100.00"), server_default=text("100.00")
    )
    safety_balance_threshold: Mapped[Decimal] = col.numeric(
        nullable=False, default=Decimal("500.00"), server_default=text("500.00")
    )
    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz(nullable=False, onupdate=utc_now)

    user: Mapped[User | None] = relationship(
        "User",
        back_populates="settings",
        uselist=False,
        foreign_keys="[UserSettings.user_uuid]",
        primaryjoin="UserSettings.user_uuid == User.id",
    )

    @property
    def safety_threshold_float(self) -> float:
        """Get safety threshold as float."""
        return float(self.safety_balance_threshold)

    @property
    def avg_spending_float(self) -> float:
        """Get average spending as float."""
        return float(self.avg_daily_spending)
