"""Dynamic context middleware for injecting runtime context into agent prompts.

This middleware injects dynamic information like current time and user ID
into the system prompt before agent invocation.

The block is appended at the TAIL of the system message (it must run after
SkillMiddleware): provider prompt caching keys on a stable prefix, so the
volatile date sits after the static sections (system.md, skills addendum)
instead of re-tokenizing the whole prompt every turn.

Language handling is intentionally NOT done here — the LLM follows the
system.md language rules ("ALWAYS communicate in the language used by the USER")
and naturally adapts to whatever language the user writes in.
"""

from datetime import datetime
from typing import Any

from langchain_core.messages import BaseMessage, SystemMessage

from app.core.langgraph.middleware.base import BaseMiddleware, inject_system_message
from app.core.logging import logger

_BLOCK_HEADER = "# Dynamic Context"


def _append_system_block(messages: list[BaseMessage], block: str) -> list[BaseMessage]:
    """Append (or refresh) a block at the TAIL of the system message.

    Resumed checkpoints persist the previous turn's block, so the stale copy
    is stripped before the fresh one is appended — exactly one block, always
    the last thing in the system message.
    """
    updated = list(messages)
    if updated and isinstance(updated[0], SystemMessage) and isinstance(updated[0].content, str):
        existing = updated[0].content
        header_at = existing.find(_BLOCK_HEADER)
        if header_at != -1:
            existing = existing[:header_at].rstrip("\n")
        separator = "\n\n" if existing else ""
        updated[0] = SystemMessage(content=f"{existing}{separator}{block}")
        return updated
    # No string system message to append to — fall back to the shared helper.
    return inject_system_message(messages, block)


class DynamicContextMiddleware(BaseMiddleware):
    """Middleware for injecting dynamic context into system prompt.

    Injects:
    - Current timestamp (user timezone aware)
    - User ID (if available)

    Language is NOT injected — the LLM handles it via system.md rules
    and natural adaptation to user input.
    """

    @property
    def name(self) -> str:
        """Middleware name."""
        return "DynamicContextMiddleware"

    async def before_invoke(
        self,
        messages: list[BaseMessage],
        config: dict[str, Any],
    ) -> tuple[list[BaseMessage], dict[str, Any]]:
        """Inject dynamic context before agent invocation."""
        from zoneinfo import ZoneInfo

        context_parts = []
        user_uuid = config.get("configurable", {}).get("user_uuid")

        # Get user timezone from config or default to Asia/Shanghai
        user_timezone = config.get("configurable", {}).get("user_timezone", "Asia/Shanghai")

        # Get current date in user's timezone
        current_time = datetime.now(ZoneInfo(user_timezone))
        time_str = f"{current_time.strftime('%Y-%m-%d (%A)')} [{user_timezone}]"

        context_parts.append(f"Current date: {time_str}")

        # Add user ID if available
        if user_uuid:
            context_parts.append(f"User ID: {user_uuid}")

        # Build context string
        if context_parts:
            context_str = "\n".join(context_parts)
            context_message = f"{_BLOCK_HEADER}\n{context_str}"

            messages = _append_system_block(messages, context_message)

            logger.debug(
                "dynamic_context_injected",
                has_user_uuid=bool(user_uuid),
                timestamp=time_str,
            )

        return messages, config
