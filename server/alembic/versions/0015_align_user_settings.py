"""Align user_settings table with the ORM model.

Revision ID: 0015
Revises: 0014
Create Date: 2026-08-01

The 0002 migration created user_settings with an autoincrement ``id`` primary
key and columns ``primary_currency`` / ``average_daily_spending`` /
``safety_balance``, while the ORM model (app/models/user_settings.py) uses
``user_uuid`` as the primary key and columns ``currency`` /
``avg_daily_spending`` / ``safety_balance_threshold``. The drift broke every
ORM read/write on the table. This migration transforms the table to match the
model (the runtime source of truth).
"""

from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa

from alembic import op

revision: str = "0015"
down_revision: str | None = "0014"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Align user_settings columns and primary key with the ORM model."""
    # Backfill NULLs before tightening nullability
    op.execute("UPDATE user_settings SET timezone = 'Asia/Shanghai' WHERE timezone IS NULL")
    op.execute("UPDATE user_settings SET average_daily_spending = '100.00' WHERE average_daily_spending IS NULL")
    op.execute("UPDATE user_settings SET safety_balance = '500.00' WHERE safety_balance IS NULL")

    # Rename columns to the model names
    op.alter_column("user_settings", "primary_currency", new_column_name="currency")
    op.alter_column("user_settings", "average_daily_spending", new_column_name="avg_daily_spending")
    op.alter_column("user_settings", "safety_balance", new_column_name="safety_balance_threshold")

    # Switch primary key from id -> user_uuid and drop the id column/sequence
    op.execute("ALTER TABLE user_settings DROP CONSTRAINT IF EXISTS user_settings_pkey")
    op.drop_column("user_settings", "id")
    op.execute("DROP SEQUENCE IF EXISTS user_settings_id_seq CASCADE")
    op.create_primary_key("pk_user_settings", "user_settings", ["user_uuid"])

    # The PK on user_uuid makes the old index redundant — drop it to match the model
    op.drop_index("ix_user_settings_user_uuid", table_name="user_settings")

    # Align column types / nullability with the model
    op.alter_column("user_settings", "currency", existing_type=sa.String(3), type_=sa.String(10))
    op.alter_column("user_settings", "timezone", existing_type=sa.String(50), type_=sa.String(100), nullable=False)
    op.alter_column("user_settings", "avg_daily_spending", existing_type=sa.String(20), type_=sa.String())
    op.alter_column("user_settings", "safety_balance_threshold", existing_type=sa.String(20), type_=sa.String())

    # Remove server defaults the model does not declare (ORM provides Python-side defaults)
    op.alter_column("user_settings", "currency", server_default=None)
    op.alter_column("user_settings", "timezone", server_default=None)


def downgrade() -> None:
    """Restore the original 0002 schema (id primary key + legacy column names)."""
    # Restore defaults dropped in upgrade
    op.alter_column("user_settings", "currency", server_default="CNY")
    op.alter_column("user_settings", "timezone", server_default="Asia/Shanghai")

    # Swap primary key back to an id column
    op.execute("DROP SEQUENCE IF EXISTS user_settings_id_seq")
    op.execute("CREATE SEQUENCE user_settings_id_seq")
    op.add_column(
        "user_settings",
        sa.Column("id", sa.Integer, nullable=False, server_default=sa.text("nextval('user_settings_id_seq')")),
    )
    op.execute("ALTER TABLE user_settings DROP CONSTRAINT IF EXISTS pk_user_settings")
    op.create_primary_key("user_settings_pkey", "user_settings", ["id"])
    op.alter_column("user_settings", "id", server_default=None)

    # Restore column names / types
    op.alter_column("user_settings", "currency", existing_type=sa.String(10), type_=sa.String(3))
    op.alter_column("user_settings", "timezone", existing_type=sa.String(100), type_=sa.String(50), nullable=True)
    op.alter_column(
        "user_settings", "avg_daily_spending", existing_type=sa.String(), type_=sa.String(20), nullable=True
    )
    op.alter_column(
        "user_settings",
        "safety_balance_threshold",
        existing_type=sa.String(),
        type_=sa.String(20),
        nullable=True,
    )
    op.alter_column("user_settings", "currency", new_column_name="primary_currency")
    op.alter_column("user_settings", "avg_daily_spending", new_column_name="average_daily_spending")
    op.alter_column("user_settings", "safety_balance_threshold", new_column_name="safety_balance")
    op.create_index("ix_user_settings_user_uuid", "user_settings", ["user_uuid"])
