#!/usr/bin/env python3
"""Query summary of a shared space or all spaces for the user.

Usage:
    # Query summary for all spaces
    uv run python app/skills/managing-shared-ledgers/scripts/query_space_summary.py

    # Query summary for a specific space
    echo '{"space_id": "uuid"}' | uv run python app/skills/managing-shared-ledgers/scripts/query_space_summary.py
"""

import asyncio
import json
import os
import sys
from datetime import UTC, datetime
from pathlib import Path

# Add project root directory to sys.path
sys.path.append(str(Path(__file__).parent.parent.parent.parent.parent))

from uuid import UUID

from sqlalchemy import func, select

from app.core.database import db_manager  # noqa: E402  # noqa: E402
from app.services.shared_space_service import SharedSpaceService  # noqa: E402


async def main() -> None:
    """Execution entry point for the skill script."""
    # Obtain user identity from environment
    user_uuid_str = os.environ.get("USER_ID")
    if not user_uuid_str:
        print(json.dumps({"success": False, "error": "User context missing"}))
        return

    # Non-blocking check for stdin data
    space_id = None
    import select as select_mod

    if select_mod.select([sys.stdin], [], [], 0.0)[0]:
        try:
            stdin_data = sys.stdin.read().strip()
            if stdin_data:
                params = json.loads(stdin_data)
                space_id = params.get("space_id")
        except (json.JSONDecodeError, ValueError):
            pass

    try:
        user_uuid = UUID(user_uuid_str)
        async with db_manager.session_factory() as session:
            service = SharedSpaceService(session)

            # Fetch all spaces for user
            spaces_result = await service.get_user_spaces(user_uuid)
            spaces = spaces_result.get("spaces", []) if spaces_result else []

            if not spaces:
                print(
                    json.dumps(
                        {"success": True, "message": "You have not joined any shared space", "spaces": [], "total": 0}
                    )
                )
                return

            # Filter by space_id if specified
            if space_id:
                spaces = [s for s in spaces if str(s.get("id")) == str(space_id)]
                if not spaces:
                    print(json.dumps({"success": False, "error": f"Shared space with ID {space_id} not found"}))
                    return

            # Calculate summary statistics for each space
            from app.models.shared_space import SpaceTransaction
            from app.models.transaction import Transaction

            summaries = []
            for space in spaces:
                sid = space.get("id")

                # Query monthly transaction statistics for space
                now = datetime.now(UTC)
                month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

                # Query total expense for current month
                stmt = (
                    select(
                        func.coalesce(func.sum(Transaction.amount), 0).label("total_expense"),
                        func.count(Transaction.id).label("transaction_count"),
                    )
                    .join(SpaceTransaction, Transaction.id == SpaceTransaction.transaction_id)
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

            print(
                json.dumps(
                    {
                        "success": True,
                        "spaces": summaries,
                        "total": len(summaries),
                        "query_time": datetime.now(UTC).isoformat(),
                    },
                    ensure_ascii=False,
                )
            )

    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}))


if __name__ == "__main__":
    asyncio.run(main())
