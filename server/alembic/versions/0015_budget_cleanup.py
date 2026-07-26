"""Budget module cleanup: remove dead fields and add concurrency safety.

Revision ID: 0015
Revises: 0014
Create Date: 2026-07-27

Changes:
- budgets: drop SAVINGS_GOAL columns (target_date, linked_account_id, current_progress)
  and the chk_budgets_type constraint (only EXPENSE_LIMIT remains).
- budget_settings: drop 8 unconsumed notification/anomaly columns and their constraints.
- budget_periods: add unique constraint on (budget_id, period_start) to prevent
  duplicate periods under concurrent requests.
- transactions: add composite index (user_uuid, transaction_at) for efficient
  range-based spending queries that replaced func.date() wrappers.
"""

from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "0015"
down_revision: str | None = "0014"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # -----------------------------------------------------------------------
    # budgets: remove SAVINGS_GOAL related columns
    # -----------------------------------------------------------------------
    op.drop_column("budgets", "target_date")
    op.drop_column("budgets", "linked_account_id")
    op.drop_column("budgets", "current_progress")

    # Drop the type check constraint (only EXPENSE_LIMIT remains; column kept for now)
    op.drop_constraint("chk_budgets_type", "budgets", type_="check")

    # -----------------------------------------------------------------------
    # budget_settings: remove unconsumed notification / anomaly columns
    # -----------------------------------------------------------------------
    op.drop_constraint("chk_budget_settings_overspend", "budget_settings", type_="check")
    op.drop_constraint("chk_budget_settings_week_day", "budget_settings", type_="check")
    op.drop_constraint("chk_budget_settings_anomaly", "budget_settings", type_="check")

    op.drop_column("budget_settings", "overspend_behavior")
    op.drop_column("budget_settings", "weekly_summary_enabled")
    op.drop_column("budget_settings", "weekly_summary_day")
    op.drop_column("budget_settings", "monthly_summary_enabled")
    op.drop_column("budget_settings", "anomaly_detection_enabled")
    op.drop_column("budget_settings", "anomaly_threshold")
    op.drop_column("budget_settings", "quiet_hours_start")
    op.drop_column("budget_settings", "quiet_hours_end")

    # -----------------------------------------------------------------------
    # budget_periods: add unique constraint for concurrency safety
    # -----------------------------------------------------------------------
    op.create_unique_constraint(
        "uq_budget_periods_budget_start",
        "budget_periods",
        ["budget_id", "period_start"],
    )

    # -----------------------------------------------------------------------
    # transactions: composite index for efficient range queries
    # (replaces func.date(transaction_at) which bypassed the single-column index)
    # -----------------------------------------------------------------------
    op.create_index(
        "ix_transactions_user_at",
        "transactions",
        ["user_uuid", "transaction_at"],
    )


def downgrade() -> None:
    # Reverse composite index
    op.drop_index("ix_transactions_user_at", table_name="transactions")

    # Reverse unique constraint
    op.drop_constraint("uq_budget_periods_budget_start", "budget_periods", type_="unique")

    # Reverse budget_settings column drops
    op.add_column(
        "budget_settings",
        sa.Column("quiet_hours_end", sa.Time, nullable=True),
    )
    op.add_column(
        "budget_settings",
        sa.Column("quiet_hours_start", sa.Time, nullable=True),
    )
    op.add_column(
        "budget_settings",
        sa.Column("anomaly_threshold", sa.Numeric(precision=20, scale=8), server_default="500", nullable=False),
    )
    op.add_column(
        "budget_settings",
        sa.Column("anomaly_detection_enabled", sa.Boolean, server_default="true", nullable=False),
    )
    op.add_column(
        "budget_settings",
        sa.Column("monthly_summary_enabled", sa.Boolean, server_default="true", nullable=False),
    )
    op.add_column(
        "budget_settings",
        sa.Column("weekly_summary_day", sa.String(10), server_default="sunday", nullable=False),
    )
    op.add_column(
        "budget_settings",
        sa.Column("weekly_summary_enabled", sa.Boolean, server_default="true", nullable=False),
    )
    op.add_column(
        "budget_settings",
        sa.Column("overspend_behavior", sa.String(20), server_default="WARN", nullable=False),
    )

    op.create_check_constraint(
        "chk_budget_settings_anomaly",
        "budget_settings",
        "anomaly_threshold >= 0",
    )
    op.create_check_constraint(
        "chk_budget_settings_week_day",
        "budget_settings",
        "weekly_summary_day IN ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday')",
    )
    op.create_check_constraint(
        "chk_budget_settings_overspend",
        "budget_settings",
        "overspend_behavior IN ('WARN', 'SUGGEST_REBALANCE')",
    )

    # Reverse budgets column drops
    op.create_check_constraint(
        "chk_budgets_type",
        "budgets",
        "type IN ('EXPENSE_LIMIT', 'SAVINGS_GOAL')",
    )
    op.add_column(
        "budgets",
        sa.Column("current_progress", sa.Numeric(precision=20, scale=8), nullable=True),
    )
    op.add_column(
        "budgets",
        sa.Column("linked_account_id", postgresql.UUID(as_uuid=True), nullable=True),
    )
    op.add_column(
        "budgets",
        sa.Column("target_date", sa.Date, nullable=True),
    )
