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
    """Parse an ISO 8601 time string; None/empty means "now".

    Raises:
        ValueError: If [time_str] is non-empty but unparseable. For a ledger
            tool, silently rewriting a malformed date to "today" books the
            entry on the wrong day with no hint to the user or the model —
            the caller must surface the error so the model can re-ask or
            re-extract (fail loud, never fail silent on money timestamps).
    """
    if not time_str:
        return datetime.now(UTC)
    try:
        return datetime.fromisoformat(time_str.replace("Z", "+00:00"))
    except (ValueError, AttributeError) as e:
        raise ValueError(f"Unparseable transaction time: {time_str!r} (expected ISO 8601)") from e


def money_str(value: Any) -> str:
    """Serialize a money value to a clean decimal string for LLM-facing output.

    Use ``str(Decimal(...))`` normalization (no float precision loss, no
    trailing ``.00000000`` artifacts, no scientific notation). JSON-bound
    GenUI payloads may still use ``float`` where the client expects a number.
    """
    return str(Decimal(str(value)))
