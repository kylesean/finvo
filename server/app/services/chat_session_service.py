"""Chat session lifecycle: resolution, language detection, memory cadence.

Extracted from ``app/api/v1/chatbot.py`` so the router stays a thin SSE
adapter (the 880-line route previously owned session resolution, language
normalization and the memory-extraction throttle as private helpers, which
made them untestable from the service layer).
"""

from __future__ import annotations

import asyncio
from collections import OrderedDict
from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from app.core.config import settings
from app.core.database import get_session_context
from app.core.dependencies import get_authorized_session
from app.core.logging import logger
from app.models.session import Session
from app.models.user import User
from app.repositories.session_repository import SessionRepository

if TYPE_CHECKING:
    from app.core.langgraph.simple_agent import SimpleLangChainAgent as LangGraphAgent

__all__ = [
    "resolve_chat_session",
    "normalize_app_language",
    "should_extract_memory",
    "update_memory_background",
    "memory_turn_counters",
]

# Memory extraction throttle: 1st turn and every Nth turn per session.
_MEMORY_TURN_COUNTERS: OrderedDict[UUID, int] = OrderedDict()
_MEMORY_TURN_COUNTERS_LOCK = asyncio.Lock()


def memory_turn_counters() -> dict[UUID, int]:
    """Live snapshot of the per-session turn counters (test introspection)."""
    return dict(_MEMORY_TURN_COUNTERS)


async def should_extract_memory(session_id: UUID) -> bool:
    """True on the 1st and every Nth turn; N from settings."""
    every_n = max(1, settings.MEMORY_EXTRACTION_EVERY_N_TURNS)
    async with _MEMORY_TURN_COUNTERS_LOCK:
        count = _MEMORY_TURN_COUNTERS.get(session_id, 0) + 1
        _MEMORY_TURN_COUNTERS[session_id] = count
        _MEMORY_TURN_COUNTERS.move_to_end(session_id)
        while len(_MEMORY_TURN_COUNTERS) > 512:  # bound: drop least-recently-seen sessions
            _MEMORY_TURN_COUNTERS.popitem(last=False)
        return count == 1 or count % every_n == 0


async def update_memory_background(
    agent: LangGraphAgent,
    user_uuid: UUID,
    messages: list[dict],
    session_id: UUID,
) -> None:
    """Update long-term memory in background (fire-and-forget).

    This function runs as a tracked background task (via
    ``background_task_manager``) to avoid blocking the HTTP response after
    streaming completes. The manager holds a strong reference until the task
    finishes and waits for it on application shutdown.
    """
    logger.debug(
        "background_memory_update_started",
        user_uuid=str(user_uuid),
        session_id=str(session_id),
        message_count=len(messages),
    )
    try:
        await agent.update_long_term_memory(
            user_uuid=user_uuid,
            messages=messages,
            session_id=session_id,
            category="conversation",
        )
        logger.debug(
            "background_memory_update_completed",
            user_uuid=str(user_uuid),
            session_id=str(session_id),
        )
    except Exception as e:
        logger.warning(
            "background_memory_update_failed",
            session_id=session_id,
            error=str(e),
        )


async def resolve_chat_session(
    session_id: UUID | None,
    current_user: User,
) -> tuple[Session, bool]:
    """Resolve session for chat: get existing or create new.

    - If session_id is provided: verify ownership and return existing session
    - If session_id is None: create a new session for the user

    Returns:
        tuple[Session, bool]: (Session object, is_new_session flag)

    Raises:
        NotFoundError: If session not found
        AuthorizationError: If access denied
    """
    async with get_session_context(auto_commit=True) as db:
        if session_id:
            session = await get_authorized_session(session_id, current_user, db)
            logger.info(
                "using_existing_session",
                session_id=session.id,
                user_uuid=current_user.uuid,
            )
            return session, False

        new_uuid = uuid4()
        repo = SessionRepository(db)
        session = await repo.create(new_uuid, current_user.uuid, name="New Chat")
        logger.info(
            "created_new_session",
            session_id=new_uuid,
            user_uuid=current_user.uuid,
        )
        return session, True


def normalize_app_language(raw: str) -> str:
    """Normalize an Accept-Language style value to a supported app language.

    Preserves the original code for non-CJK languages (fr, de, es, pt, ...):
    only the primary subtag is kept (e.g. "fr-FR" -> "fr").
    """
    if raw.startswith("zh-TW") or raw.startswith("zh-Hant"):
        return "zh-Hant"
    if raw.startswith("zh"):
        return "zh"
    if raw.startswith("ja"):
        return "ja"
    if raw.startswith("ko"):
        return "ko"
    if raw.startswith("en"):
        return "en"
    return raw.split("-")[0].split("_")[0].lower()
