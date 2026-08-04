"""Create users and user_settings tables.

Revision ID: 0002
Revises: 0001
Create Date: 2026-01-01

Core user authentication and profile tables.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "0002"
down_revision: Union[str, None] = "0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Create users and user_settings tables."""

    # =========================================================================
    # users - Core user authentication table
    # =========================================================================
    op.create_table(
        "users",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("username", sa.String(50), nullable=False),
        sa.Column("email", sa.String(255), nullable=True),
        sa.Column("mobile", sa.String(20), nullable=True),
        sa.Column("password", sa.String(255), nullable=False),
        sa.Column("avatar_url", sa.String(500), nullable=True),
        sa.Column("timezone", sa.String(100), nullable=False, server_default="UTC"),
        sa.Column(
            "registration_type",
            sa.String(20),
            nullable=False,
            server_default="email",
        ),
        sa.Column("last_login_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("last_login_ip", postgresql.INET, nullable=True),
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

    # Named unique constraints aligned with ORM naming convention (uq_<table>_<col>).
    # No separate index: unique constraint already provides an index for lookups.
    op.create_unique_constraint("uq_users_email", "users", ["email"])
    op.create_unique_constraint("uq_users_mobile", "users", ["mobile"])

    # =========================================================================
    # user_settings - User preferences
    # =========================================================================
    op.create_table(
        "user_settings",
        sa.Column(
            "user_uuid",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            primary_key=True,
        ),
        sa.Column("currency", sa.String(10), nullable=False, server_default="CNY"),
        sa.Column("avg_daily_spending", sa.Numeric(precision=20, scale=8), nullable=False, server_default="100.00"),
        sa.Column("safety_balance_threshold", sa.Numeric(precision=20, scale=8), nullable=False, server_default="500.00"),
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
    """Drop users and user_settings tables."""
    op.drop_table("user_settings")
    op.drop_constraint("uq_users_mobile", "users", type_="unique")
    op.drop_constraint("uq_users_email", "users", type_="unique")
    op.drop_table("users")
