"""Add base_currency to shared_spaces for settlement conversion.

Revision ID: 0015
Revises: 0014
Create Date: 2026-09-03

Members on different base currencies (CNY payer + USD member) made
settlement math meaningless — per-member snapshot values were added directly.
The space now carries a settlement base currency; settlement converts each
transaction (amount_original + currency) into it before splitting.

Nullable for pre-migration rows: the service falls back to the creator's
primary_currency, then PROJECT_DEFAULT_CURRENCY. New spaces set it at creation.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0015"
down_revision: Union[str, None] = "0014"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add base_currency column with ISO-length check."""
    op.add_column(
        "shared_spaces",
        sa.Column("base_currency", sa.String(length=3), nullable=True),
    )
    op.create_check_constraint(
        "ck_shared_spaces_base_currency_len",
        "shared_spaces",
        "base_currency IS NULL OR char_length(base_currency) = 3",
    )


def downgrade() -> None:
    """Drop the check and column."""
    op.drop_constraint("ck_shared_spaces_base_currency_len", "shared_spaces", type_="check")
    op.drop_column("shared_spaces", "base_currency")
