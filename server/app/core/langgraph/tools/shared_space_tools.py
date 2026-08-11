"""Shared space tools (read-only, typed).

Replace the managing-shared-ledgers skill scripts: listing spaces and querying
space summaries are well-defined read-only operations, so they are typed tool
calls instead of LLM-composed shell commands.
"""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any

from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from pydantic import BaseModel, Field
from sqlalchemy import func, select

from app.core.database import db_manager
from app.core.langgraph.tools._helpers import get_user_uuid
from app.services.shared_space_service import SharedSpaceService


@tool("list_spaces")
async def list_spaces(*, config: RunnableConfig) -> dict[str, Any]:
    """List the shared spaces the user belongs to.

    USE WHEN the user asks about shared spaces, family/team ledgers or
    collaborative accounts ("we/us" context).
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "error": "User not authenticated"}

    try:
        async with db_manager.session_factory() as session:
            service = SharedSpaceService(session)
            result = await service.get_user_spaces(user_uuid)
            spaces = result.get("spaces", []) if result else []
            return {"success": True, "spaces": spaces}
    except Exception as e:  # pragma: no cover - defensive
        return {"success": False, "error": str(e)}


class QuerySpaceSummaryInput(BaseModel):
    """Input for query_space_summary tool."""

    space_id: str | None = Field(
        default=None, description="Optional shared space ID; omit to summarize all the user's spaces"
    )


@tool("query_space_summary", args_schema=QuerySpaceSummaryInput)
async def query_space_summary(
    space_id: str | None = None,
    *,
    config: RunnableConfig,
) -> dict[str, Any]:
    """Summarize current-month spending for a shared space (or all of them).

    USE WHEN the user asks "how much did we spend this month" or a space
    summary. Returns per-space this-month totals and transaction counts.
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "error": "User not authenticated"}

    try:
        async with db_manager.session_factory() as session:
            service = SharedSpaceService(session)
            spaces_result = await service.get_user_spaces(user_uuid)
            spaces = spaces_result.get("spaces", []) if spaces_result else []

            if not spaces:
                return {
                    "success": True,
                    "message": "You have not joined any shared space",
                    "spaces": [],
                    "total": 0,
                }

            if space_id:
                spaces = [s for s in spaces if str(s.get("id")) == str(space_id)]
                if not spaces:
                    return {"success": False, "error": f"Shared space with ID {space_id} not found"}

            from app.models.shared_space import SpaceTransaction
            from app.models.transaction import Transaction

            now = datetime.now(UTC)
            month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

            summaries = []
            for space in spaces:
                sid = space.get("id")

                stmt = (
                    select(
                        func.coalesce(func.sum(Transaction.amount), 0).label("total_expense"),
                        func.count(Transaction.uuid).label("transaction_count"),
                    )
                    .join(SpaceTransaction, Transaction.uuid == SpaceTransaction.transaction_id)
                    .where(
                        SpaceTransaction.space_id == sid,
                        Transaction.transaction_at >= month_start,
                        Transaction.type == "EXPENSE",
                    )
                )
                result = await session.execute(stmt)
                stats = result.first()

                if stats:
                    total_expense = float(stats.total_expense or 0)
                    tx_count = stats.transaction_count or 0
                else:
                    total_expense = 0.0
                    tx_count = 0

                summaries.append(
                    {
                        "id": str(sid),
                        "name": space.get("name"),
                        "role": space.get("role"),
                        "thisMonth": {
                            "totalExpense": total_expense,
                            "transactionCount": tx_count,
                            "period": f"{now.year}-{now.month:02d}",
                        },
                    }
                )

            return {
                "success": True,
                "spaces": summaries,
                "total": len(summaries),
                "query_time": now.isoformat(),
            }
    except Exception as e:  # pragma: no cover - defensive
        return {"success": False, "error": str(e)}


# Export
shared_space_tools = [list_spaces, query_space_summary]
