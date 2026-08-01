"""Graph utilities for the application.

This module provides utility functions for message processing in LangGraph workflows.
"""

from typing import Any

from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import (
    BaseMessage,
    SystemMessage,
    trim_messages as _trim_messages,
)
from pydantic import BaseModel

from app.core.config import settings
from app.core.logging import logger
from app.schemas import Message


def _dump_message(message: Any) -> dict[str, Any]:
    """Serialize a single message to a dict.

    Accepts Pydantic models (app ``Message`` or LangChain ``BaseMessage``),
    plain dicts, or any other value (coerced to a user-role text message).
    """
    if isinstance(message, BaseModel):
        return message.model_dump()
    if isinstance(message, dict):
        return message
    return {"role": "user", "content": str(message)}


def dump_messages(messages: list[Message | dict[str, Any]]) -> list[dict[str, Any]]:
    """Dump messages to a list of dictionaries.

    Args:
        messages: The messages to dump (can be Message objects or dicts).

    Returns:
        list[dict]: The dumped messages.
    """
    return [_dump_message(message) for message in messages]


def process_llm_response(response: BaseMessage) -> BaseMessage:
    """Process LLM response to handle structured content blocks (e.g., from GPT-5 models).

    GPT-5 models return content as a list of blocks like:
    [
        {'id': '...', 'summary': [], 'type': 'reasoning'},
        {'type': 'text', 'text': 'actual response'}
    ]

    This function extracts the actual text content from such structures.

    Args:
        response: The raw response from the LLM

    Returns:
        BaseMessage with processed content
    """
    if isinstance(response.content, list):
        # Extract text from content blocks
        text_parts = []
        for block in response.content:
            if isinstance(block, dict):
                # Handle text blocks
                if block.get("type") == "text" and "text" in block:
                    text_parts.append(block["text"])
                # Log reasoning blocks for debugging
                elif block.get("type") == "reasoning":
                    logger.debug(
                        "reasoning_block_received",
                        reasoning_id=block.get("id"),
                        has_summary=bool(block.get("summary")),
                    )
            elif isinstance(block, str):
                text_parts.append(block)

        # Join all text parts
        response.content = "".join(text_parts)
        logger.debug(
            "processed_structured_content",
            extracted_length=len(response.content),
        )

    return response


def prepare_messages(
    messages: list[BaseMessage],
    llm: BaseChatModel,
    system_prompt: str,
) -> list[BaseMessage]:
    """Trim messages to fit within the token budget and prepend the system prompt.

    The consolidated ``system_prompt`` is kept untouched (prompt-cache
    friendly); only the non-system history is trimmed, keeping the most recent
    turns. If the model cannot count tokens for an unrecognized content block
    (e.g. GPT-5 reasoning blocks), trimming is skipped rather than failing the
    turn.

    Args:
        messages: The non-system conversation history (BaseMessage list).
        llm: The LLM to use for token counting.
        system_prompt: The stable system prompt.

    Returns:
        list[BaseMessage]: ``[SystemMessage(system_prompt), *trimmed_history]``.
    """
    try:
        trimmed = _trim_messages(
            messages,
            strategy="last",
            token_counter=llm,
            max_tokens=settings.MAX_TOKENS,
            start_on="human",
            include_system=False,
            allow_partial=False,
        )
    except ValueError as e:
        # Handle unrecognized content blocks (e.g., reasoning blocks from GPT-5)
        if "Unrecognized content block type" in str(e):
            logger.warning(
                "token_counting_failed_skipping_trim",
                error=str(e),
                message_count=len(messages),
            )
            trimmed = messages
        else:
            raise

    return [SystemMessage(content=system_prompt), *trimmed]
