"""Unified response envelope for all API endpoints.

This module provides a standardized response format that maintains compatibility
with existing client applications expecting {code, message, data} structure.

Design principles:
1. All responses use the same envelope: {code, message, data}
2. HTTP status codes follow REST semantics for ALL outcomes, including
   business errors (4xx) and server errors (5xx). Success is HTTP 200.
3. The body's 'code' field provides machine-readable detail on top of the
   HTTP status — code=0 means success, non-zero means a business error.
"""

from __future__ import annotations

from typing import Any, TypeVar

from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict

from app.core.exceptions import ERROR_CODE_MAP

T = TypeVar("T")


class ResponseEnvelope[T](BaseModel):
    """Generic response envelope for type-safe API responses.

    This model is used for OpenAPI documentation and type hints.
    It ensures all responses follow the same structure.

    Attributes:
        code: Business status code (0 = success, non-zero = error)
        message: Human-readable message describing the result
        data: Response payload (only present on success)
    """

    code: int
    message: str
    data: T | None = None

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "code": 0,
                "message": "Success",
                "data": {"id": 1, "name": "example"},
            }
        }
    )


def success_response(
    data: Any = None,
    message: str = "Success",
    http_status: int = 200,
) -> JSONResponse:
    """Create a successful response with code=0.

    Args:
        data: Response data (will be JSON-encoded)
        message: Success message
        http_status: HTTP status code (default: 200)

    Returns:
        JSONResponse with standardized envelope

    Example:
        >>> return success_response(data={"user_uuid": 123})
        # Returns: {"code": 0, "message": "Success", "data": {"user_uuid": 123}}
    """
    body: dict[str, Any] = {
        "code": 0,
        "message": message,
    }

    if data is not None:
        body["data"] = jsonable_encoder(data)

    return JSONResponse(status_code=http_status, content=body)


def error_response(
    code: int,
    message: str,
    data: Any = None,
    http_status: int = 400,
) -> JSONResponse:
    """Create an error response with non-zero code.

    Business errors return their proper HTTP 4xx/5xx status; the body carries
    ``code``/``message`` for machine-readable detail. Callers SHOULD pass a
    specific status (404, 422, 403, …) when it is more precise than the
    generic 400 default.

    Args:
        code: Business error code (non-zero)
        message: Error message
        data: Optional error details
        http_status: HTTP status code (default: 400 for a generic client error)

    Returns:
        JSONResponse with standardized envelope

    Example:
        >>> return error_response(code=1001, message="User not found", http_status=404)
        # Returns: {"code": 1001, "message": "User not found"}
    """
    body: dict[str, Any] = {
        "code": code,
        "message": message,
    }

    if data is not None:
        body["data"] = jsonable_encoder(data)

    return JSONResponse(status_code=http_status, content=body)


def get_error_code_int(error_code_str: str) -> int:
    """Convert string error code to integer.

    Args:
        error_code_str: String error code (e.g., "USER_NOT_EXIST")

    Returns:
        Integer error code for client compatibility
    """
    return ERROR_CODE_MAP.get(error_code_str, 500)
