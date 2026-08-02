"""Dynamic context middleware for injecting runtime context into agent prompts.

This middleware injects dynamic information like current time and user ID
into the system prompt before agent invocation.

Language handling is intentionally NOT done here — the LLM follows the
system.md language rules ("ALWAYS communicate in the language used by the USER")
and naturally adapts to whatever language the user writes in.
"""

from datetime import datetime
from typing import Any

from langchain_core.messages import BaseMessage

from app.core.langgraph.middleware.base import BaseMiddleware, inject_system_message
from app.core.logging import logger


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
            context_message = f"# Dynamic Context\n{context_str}"

            messages = inject_system_message(messages, context_message)

            logger.debug(
                "dynamic_context_injected",
                has_user_uuid=bool(user_uuid),
                timestamp=time_str,
            )

        return messages, config
