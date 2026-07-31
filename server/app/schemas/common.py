"""Common Pydantic schema models for API request/response envelopes."""

from __future__ import annotations

from pydantic import BaseModel, Field


class BaseResponse[T](BaseModel):
    """Generic API response envelope model for OpenAPI documentation."""

    code: int = Field(default=0, description="Business error code (0 indicates success)")
    message: str = Field(default="success", description="Human-readable response message")
    data: T | None = Field(default=None, description="Response payload data")
