"""Add replied_to_user_uuid to transaction_comments for text-based @mention reply targets.

Revision ID: 0013
Revises: 0012
Create Date: 2026-08-11
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "0013"
down_revision: Union[str, None] = "0012"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add replied_to_user_uuid column to transaction_comments."""
    op.add_column(
        "transaction_comments",
        sa.Column(
            "replied_to_user_uuid",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey(
                "users.id",
                ondelete="SET NULL",
                name="fk_transaction_comments_replied_to_user_uuid_users",
            ),
            nullable=True,
        ),
    )
    op.create_index(
        "ix_transaction_comments_replied_to_user_uuid",
        "transaction_comments",
        ["replied_to_user_uuid"],
    )


def downgrade() -> None:
    """Drop replied_to_user_uuid column from transaction_comments."""
    op.drop_index("ix_transaction_comments_replied_to_user_uuid", table_name="transaction_comments")
    op.drop_constraint(
        "fk_transaction_comments_replied_to_user_uuid_users",
        "transaction_comments",
        type_="foreignkey",
    )
    op.drop_column("transaction_comments", "replied_to_user_uuid")
