"""Add idempotency_key to transactions for duplicate-submission dedup.

Revision ID: 0014
Revises: 0013
Create Date: 2026-09-03
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0014"
down_revision: Union[str, None] = "0013"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add idempotency_key column + per-user unique constraint.

    PostgreSQL unique semantics treat NULLs as distinct, so unkeyed (AI) rows
    never conflict; only keyed submissions dedupe.
    """
    op.add_column(
        "transactions",
        sa.Column("idempotency_key", sa.String(length=120), nullable=True),
    )
    op.create_unique_constraint(
        "uq_transactions_user_idempotency",
        "transactions",
        ["user_uuid", "idempotency_key"],
    )


def downgrade() -> None:
    """Drop the constraint and column."""
    op.drop_constraint("uq_transactions_user_idempotency", "transactions", type_="unique")
    op.drop_column("transactions", "idempotency_key")
