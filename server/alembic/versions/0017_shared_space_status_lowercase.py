"""Unify shared_spaces.status to lowercase with a CHECK constraint.

Revision ID: 0017
Revises: 0016
Create Date: 2026-09-03

The service writes lowercase ("active") while the column default was
uppercase ("ACTIVE"), so any out-of-service write produced rows the
service filters could never see. Status is now lowercase everywhere,
backed by a CHECK constraint and a single enum source.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0017"
down_revision: Union[str, None] = "0016"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Lowercase existing rows, fix the default, add the CHECK."""
    op.execute("UPDATE shared_spaces SET status = LOWER(status) WHERE status <> LOWER(status)")
    op.alter_column("shared_spaces", "status", server_default=sa.text("'active'"))
    op.create_check_constraint(
        "ck_shared_spaces_status",
        "shared_spaces",
        "status IN ('active', 'archived')",
    )


def downgrade() -> None:
    """Drop the CHECK and restore the previous default."""
    op.drop_constraint("ck_shared_spaces_status", "shared_spaces", type_="check")
    op.alter_column("shared_spaces", "status", server_default=sa.text("'ACTIVE'"))
