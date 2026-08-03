"""Shared helpers for LangGraph tools.

Centralizes the config-extraction and parsing helpers that individual tool
modules previously copy-pasted (``_get_user_uuid``, ``_get_user_uuid_str``,
``_get_thread_id``, ``_parse_time``). Import these instead of redefining them.
"""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any

from langchain_core.runnables import RunnableConfig


def get_user_uuid(config: RunnableConfig) -> uuid.UUID | None:
    """Extract user UUID from configuration."""
    val = config.get("configurable", {}).get("user_uuid")
    if val is None:
        return None
    return uuid.UUID(val) if isinstance(val, str) else val


def get_user_uuid_str(config: RunnableConfig) -> str | None:
    """Extract user UUID string from configuration."""
    val = config.get("configurable", {}).get("user_uuid")
    if val is None:
        return None
    return str(val) if isinstance(val, uuid.UUID) else val


def get_thread_id(config: RunnableConfig) -> str | None:
    """Extract thread_id (session_id) from configuration for message anchor."""
    return config.get("configurable", {}).get("thread_id")


def parse_time(time_str: str | None) -> datetime:
    """Parse a time string, returning the current UTC time if parsing fails."""
    if not time_str:
        return datetime.now(UTC)
    try:
        return datetime.fromisoformat(time_str.replace("Z", "+00:00"))
    except (ValueError, AttributeError):
        return datetime.now(UTC)


def money_str(value: Any) -> str:
    """Serialize a money value to a clean decimal string for LLM-facing output.

    Use ``str(Decimal(...))`` normalization (no float precision loss, no
    trailing ``.00000000`` artifacts, no scientific notation). JSON-bound
    GenUI payloads may still use ``float`` where the client expects a number.
    """
    return str(Decimal(str(value)))
