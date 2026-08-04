"""Create financial_settings table.

Revision ID: 0011
Revises: 0010
Create Date: 2026-01-01

User financial settings and preferences.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "0011"
down_revision: Union[str, None] = "0010"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Create financial_settings table."""
    op.create_table(
        "financial_settings",
        sa.Column(
            "user_uuid",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            primary_key=True,
        ),
        sa.Column(
            "safety_threshold",
            sa.Numeric(precision=20, scale=8),
            nullable=False,
            server_default="1000.00",
        ),
        sa.Column(
            "daily_burn_rate",
            sa.Numeric(precision=20, scale=8),
            nullable=False,
            server_default="100.00",
        ),
        sa.Column("burn_rate_mode", sa.String(20), nullable=False, server_default="AI_AUTO"),
        sa.Column("primary_currency", sa.String(3), nullable=False, server_default="CNY"),
        sa.Column("month_start_day", sa.Integer, nullable=False, server_default="1"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
    )


def downgrade() -> None:
    """Drop financial_settings table."""
    op.drop_table("financial_settings")
