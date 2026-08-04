"""Create user_devices table for push notification tokens.

Revision ID: 0012
Revises: 0011
Create Date: 2026-01-01
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "0012"
down_revision: Union[str, None] = "0011"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Create user_devices table."""
    op.create_table(
        "user_devices",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column(
            "user_uuid",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("device_token", sa.String(500), nullable=False, unique=True),
        sa.Column("platform", sa.String(20), nullable=False, server_default="android"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("device_name", sa.String(100), nullable=True),
        sa.Column("device_model", sa.String(100), nullable=True),
        sa.Column("os_version", sa.String(50), nullable=True),
        sa.Column("app_version", sa.String(50), nullable=True),
        sa.Column("last_active_at", sa.DateTime(timezone=True), nullable=True),
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

    op.create_index("ix_user_devices_user_uuid", "user_devices", ["user_uuid"])


def downgrade() -> None:
    """Drop user_devices table."""
    op.drop_index("ix_user_devices_user_uuid")
    op.drop_table("user_devices")
