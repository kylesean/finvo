"""Shared tool helpers."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any

from langchain_core.runnables import RunnableConfig


def get_user_uuid(config: RunnableConfig) -> uuid.UUID | None:
    val = config.get("configurable", {}).get("user_uuid")
    if val is None:
        return None
    return uuid.UUID(val) if isinstance(val, str) else val


def get_user_uuid_str(config: RunnableConfig) -> str | None:
    val = config.get("configurable", {}).get("user_uuid")
    if val is None:
        return None
    return str(val) if isinstance(val, uuid.UUID) else val


def get_thread_id(config: RunnableConfig) -> str | None:
    return config.get("configurable", {}).get("thread_id")


def parse_time(time_str: str | None) -> datetime:
    """ISO 8601 string to datetime. None/empty means now. Bad input raises."""
    if not time_str:
        return datetime.now(UTC)
    try:
        return datetime.fromisoformat(time_str.replace("Z", "+00:00"))
    except (ValueError, AttributeError) as e:
        raise ValueError(f"Unparseable transaction time: {time_str!r} (expected ISO 8601)") from e


def money_str(value: Any) -> str:
    """Decimal-normalized money string without float artifacts."""
    return str(Decimal(str(value)))
