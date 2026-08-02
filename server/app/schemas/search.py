"""Search-related schemas for conversation search API."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel


class HighlightRange(BaseModel):
    """Highlight range for search result text."""

    start: int = Field(..., description="Start index of highlight")
    end: int = Field(..., description="End index of highlight")
    field: str = Field(..., description="Field name: 'title' or 'snippet'")


class SearchResult(BaseModel):
    """Search result item from conversation search."""

    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        json_schema_extra={
            "example": {
                "id": "session-uuid",
                "title": "Conversation about bookkeeping",
                "snippet": "Bookkeeping assistant can help you...",
                "messageId": None,
                "createdAt": "2024-01-01T00:00:00Z",
                "updatedAt": "2024-01-01T00:00:00Z",
                "highlights": [{"start": 2, "end": 4, "field": "title"}],
            }
        },
    )

    id: str = Field(..., description="Session ID")
    title: str = Field(..., description="Session title")
    snippet: str = Field(..., description="Matching content snippet")
    message_id: str | None = Field(None, description="Message ID if applicable")
    created_at: datetime | None = Field(None, description="Creation time")
    updated_at: datetime | None = Field(None, description="Last update time")
    highlights: list[HighlightRange] = Field(default_factory=list, description="Highlight ranges")
