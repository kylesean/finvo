"""Add CHECK constraints for transaction type/status.

Revision ID: 0016
Revises: 0015
Create Date: 2026-09-03

Bare String columns let any casing/typo into the ledger. Code only ever writes:
- type: EXPENSE / INCOME / TRANSFER
- status: CLEARED / PENDING / CONFIRMED
`source` stays unconstrained on purpose (MANUAL, AI, IMPORT, ... — open set).
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0016"
down_revision: Union[str, None] = "0015"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add type/status CHECK constraints to transactions."""
    op.create_check_constraint(
        "ck_transactions_type",
        "transactions",
        "type IN ('EXPENSE', 'INCOME', 'TRANSFER')",
    )
    op.create_check_constraint(
        "ck_transactions_status",
        "transactions",
        "status IN ('CLEARED', 'PENDING', 'CONFIRMED')",
    )


def downgrade() -> None:
    """Drop the CHECK constraints."""
    op.drop_constraint("ck_transactions_status", "transactions", type_="check")
    op.drop_constraint("ck_transactions_type", "transactions", type_="check")
