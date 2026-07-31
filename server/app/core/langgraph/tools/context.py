"""Context variables for LangGraph tools to avoid circular imports."""

from contextvars import ContextVar

# Used to store user identity within the request lifecycle
current_user_id: ContextVar[str] = ContextVar("current_user_id", default="")

# Used to store session language within the request lifecycle
current_session_language: ContextVar[str] = ContextVar("current_session_language", default="zh")
