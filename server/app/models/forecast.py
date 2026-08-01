"""Forecast related models for financial prediction features.

This module contains models for:
- AccountDailySnapshot: Daily balance snapshots for high-performance time series analysis

This model has been migrated to SQLAlchemy 2.0 with Mapped[...] annotations.
"""

from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

import sqlalchemy as sa
from sqlalchemy import String
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, col


class AccountDailySnapshot(Base):
    """Daily account balance snapshot for time series analysis."""

    __tablename__ = "account_daily_snapshots"

    # Composite primary key (snapshot_date, account_id) — mirrors migration 0011
    __table_args__ = (sa.PrimaryKeyConstraint("snapshot_date", "account_id", name="pk_account_daily_snapshots"),)

    snapshot_date: Mapped[date] = col.date_column()
    account_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        sa.ForeignKey("financial_accounts.id", ondelete="CASCADE"),
    )

    user_uuid: Mapped[UUID] = col.uuid_fk("users", ondelete="CASCADE", index=True, column="uuid")

    balance: Mapped[Decimal] = col.numeric(precision=20, scale=8)
    currency: Mapped[str] = mapped_column(String(3))

    total_incoming: Mapped[Decimal] = col.numeric(precision=20, scale=8, default=Decimal("0"))
    total_outgoing: Mapped[Decimal] = col.numeric(precision=20, scale=8, default=Decimal("0"))
    exchange_rate_snapshot: Mapped[Decimal | None] = col.numeric(precision=20, scale=8, nullable=True)

    created_at: Mapped[datetime] = col.timestamptz()
    updated_at: Mapped[datetime] = col.timestamptz()

    @property
    def net_flow(self) -> Decimal:
        """Calculate net cash flow for the day."""
        return self.total_incoming - self.total_outgoing

    @property
    def balance_float(self) -> float:
        """Get balance as float."""
        return float(self.balance)


__all__ = [
    "AccountDailySnapshot",
]
