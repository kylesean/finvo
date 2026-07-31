"""Utilities for LangGraph tools."""

from __future__ import annotations

from datetime import date, datetime
from typing import Any

from pydantic import BaseModel


def map_to_genui(data: Any) -> Any:
    """Recursively convert data to a GenUI-compatible format.

    1. Pydantic models are converted to dicts (mode='json'), preserving
       the original naming style (camelCase).
    2. Date objects are converted to ISO strings.
    """
    # Pydantic models
    if isinstance(data, BaseModel):
        return data.model_dump(mode="json")

    # Recurse into dicts
    if isinstance(data, dict):
        new_dict = {}
        for k, v in data.items():
            new_dict[k] = map_to_genui(v)
        return new_dict

    # Recurse into lists
    elif isinstance(data, list):
        return [map_to_genui(i) for i in data]

    # Date objects
    elif isinstance(data, (datetime, date)):
        return data.isoformat()

    # Primitives: return as-is
    return data


def genui_response(data: Any, type: str, success: bool = True, message: str | None = None) -> dict[str, Any]:
    """Build a flat GenUI response dictionary.

    Preserves the backend's camelCase naming style for consistency with
    the RESTful API.
    """
    result = {
        "success": success,
        "type": type,
    }

    if message:
        result["message"] = message

    if success and data is not None:
        formatted_data = map_to_genui(data)
        if isinstance(formatted_data, dict):
            # Flatten into the root
            result.update(formatted_data)
        else:
            result["data"] = formatted_data

    return result
