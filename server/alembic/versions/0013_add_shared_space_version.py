"""Add optimistic-lock version column to shared_spaces (C3).

Revision ID: 0013
Revises: 0012
Create Date: 2026-09-01
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0013"
down_revision: Union[str, None] = "0012"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add version column for optimistic concurrency control."""
    op.add_column(
        "shared_spaces",
        sa.Column("version", sa.Integer(), nullable=False, server_default="0"),
    )


def downgrade() -> None:
    """Drop version column."""
    op.drop_column("shared_spaces", "version")
