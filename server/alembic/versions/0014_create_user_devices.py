"""Create user_devices table.

Revision ID: 0014
Revises: 0013
Create Date: 2026-07-26

Push notification device token management for FCM/APNs.
"""

from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "0014"
down_revision: str | None = "0013"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Create user_devices table."""
    op.create_table(
        "user_devices",
        sa.Column("id", sa.Integer, primary_key=True, autoincrement=True),
        sa.Column(
            "user_uuid",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.uuid", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("device_token", sa.String(500), nullable=False, unique=True),
        sa.Column("platform", sa.String(20), nullable=False, server_default="android"),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="true"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True),
    )

    op.create_index("ix_user_devices_user_uuid", "user_devices", ["user_uuid"])
    op.create_index("ix_user_devices_device_token", "user_devices", ["device_token"], unique=True)
    op.create_index("ix_user_devices_is_active", "user_devices", ["is_active"])


def downgrade() -> None:
    """Drop user_devices table."""
    op.drop_table("user_devices")
