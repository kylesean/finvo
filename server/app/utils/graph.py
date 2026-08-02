"""Graph utilities for the application.

This module provides utility functions for message processing in LangGraph workflows.
"""

from collections.abc import Callable
from functools import lru_cache
from typing import Any

from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import (
    BaseMessage,
    HumanMessage,
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


@lru_cache(maxsize=1)
def _cl100k_encoder() -> Any | None:
    """Return a cached tiktoken ``cl100k_base`` encoder, or None if tiktoken is missing."""
    try:
        import tiktoken
    except ImportError:
        return None
    return tiktoken.get_encoding("cl100k_base")


def _approx_token_count(messages: list[BaseMessage]) -> int:
    """Approximate token count for models without a LangChain-accessible tokenizer.

    Uses ``cl100k_base`` (a reasonable BPE approximation for OpenAI-compatible
    models such as DeepSeek whose provider exposes no tokenizer to LangChain);
    falls back to a 4-chars-per-token heuristic if tiktoken is unavailable.
    Counts text inside multimodal content blocks and ignores non-text blocks.
    """
    enc = _cl100k_encoder()
    total = 0
    for msg in messages:
        # 4-token per-message overhead mirrors BaseChatModel's default accounting.
        total += 4
        content = msg.content
        if isinstance(content, str):
            total += len(enc.encode(content)) if enc is not None else len(content) // 4
        elif isinstance(content, list):
            for block in content:
                text: str | None = None
                if isinstance(block, str):
                    text = block
                elif isinstance(block, dict) and isinstance(block.get("text"), str):
                    text = block["text"]
                if text:
                    total += len(enc.encode(text)) if enc is not None else len(text) // 4
    return total


def _make_token_counter(
    llm: BaseChatModel,
) -> BaseChatModel | Callable[[list[BaseMessage]], int]:
    """Return a token_counter for ``trim_messages``.

    Probes the model's native token counting once. Models whose provider
    exposes no tokenizer to LangChain (e.g. DeepSeek) raise
    ``NotImplementedError`` from ``get_num_tokens_from_messages`` and fall back
    to :func:`_approx_token_count`, so history trimming still bounds the prompt
    instead of crashing the turn.
    """
    try:
        llm.get_num_tokens_from_messages([HumanMessage(content="probe")])
        return llm
    except NotImplementedError:
        logger.info(
            "model_tokenizer_unavailable_using_fallback",
            model=getattr(llm, "model_name", "unknown"),
        )
        return _approx_token_count


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
        # Official LangGraph recommended configuration: `start_on="human"` +
        # `end_on=("human", "tool")` keeps a valid conversational window so the
        # model never sees a half-cut turn (e.g. an AIMessage with tool_calls
        # but no following ToolMessage). `include_system=False` keeps the
        # consolidated system prompt untouched (added by the caller).
        trimmed = _trim_messages(
            messages,
            strategy="last",
            token_counter=_make_token_counter(llm),
            max_tokens=settings.MAX_HISTORY_TOKENS,
            start_on="human",
            end_on=("human", "tool"),
            include_system=False,
            allow_partial=False,
        )
    except ValueError as e:
        # Skip trimming for unrecognized content blocks (e.g. GPT-5 reasoning
        # blocks) instead of failing the turn.
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
