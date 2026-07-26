"""Add recurring_transaction_id to transactions and index next_execution_at.

Revision ID: 0016
Revises: 0015
Create Date: 2026-07-27

Changes:
- transactions: add recurring_transaction_id (nullable FK to recurring_transactions.id)
  for idempotency protection in the daily generation job.
- recurring_transactions: add index on next_execution_at for efficient daily job query.
"""

from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "0016"
down_revision: str | None = "0015"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add FK column linking generated transactions back to their source rule
    op.add_column(
        "transactions",
        sa.Column(
            "recurring_transaction_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("recurring_transactions.id", ondelete="SET NULL"),
            nullable=True,
        ),
    )
    op.create_index(
        "ix_transactions_recurring_id",
        "transactions",
        ["recurring_transaction_id"],
    )

    # Index for the daily job query: WHERE is_active AND next_execution_at BETWEEN ...
    op.create_index(
        "ix_recurring_next_execution",
        "recurring_transactions",
        ["next_execution_at"],
    )


def downgrade() -> None:
    op.drop_index("ix_recurring_next_execution", table_name="recurring_transactions")
    op.drop_index("ix_transactions_recurring_id", table_name="transactions")
    op.drop_column("transactions", "recurring_transaction_id")
