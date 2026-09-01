"""Memory cleanup scheduled job functions.

This module contains the actual job logic for cleaning up
old user memories. These functions are called by the
scheduler service.
"""

from sqlalchemy import select

from app.core.database import get_session_context
from app.core.logging import logger
from app.models.user import User


async def cleanup_all_user_memories() -> None:
    """Clean up old memories for all active users.

    This job runs daily to prevent unbounded memory growth.
    It applies two cleanup strategies:
    1. Delete memories older than 180 days
    2. Keep only the most recent 500 memories per user
    """
    from app.services.memory import get_memory_service

    logger.info("memory_cleanup_started")

    total_deleted = 0
    users_processed = 0
    errors = 0

    try:
        memory_service = await get_memory_service()

        # Keyset pagination: fetch users in bounded batches instead of
        # materializing the whole users table at once (D3).
        _BATCH = 1000
        last_uuid = None
        while True:
            async with get_session_context() as db:
                query = select(User.uuid).order_by(User.uuid).limit(_BATCH)
                if last_uuid is not None:
                    query = query.where(User.uuid > last_uuid)
                rows = (await db.execute(query)).fetchall()
            if not rows:
                break
            for (user_uuid,) in rows:
                try:
                    cleanup_result = await memory_service.cleanup_old_memories(
                        user_uuid=user_uuid,
                        days_old=180,
                        max_memories=500,
                    )

                    if cleanup_result.get("deleted_count", 0) > 0:
                        total_deleted += cleanup_result["deleted_count"]
                        logger.debug(
                            "user_memory_cleaned",
                            user_uuid=str(user_uuid),
                            deleted_count=cleanup_result["deleted_count"],
                        )

                    users_processed += 1

                except Exception as e:
                    errors += 1
                    logger.warning(
                        "user_memory_cleanup_failed",
                        user_uuid=str(user_uuid),
                        error=str(e),
                    )
            last_uuid = rows[-1][0]
            if len(rows) < _BATCH:
                break

        logger.info(
            "memory_cleanup_completed",
            users_processed=users_processed,
            total_deleted=total_deleted,
            errors=errors,
        )

    except Exception as e:
        logger.error(
            "memory_cleanup_job_failed",
            error=str(e),
        )
