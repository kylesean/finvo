"""Tests for LangGraph Agent Architecture

Verifies tool loading and system prompts.
"""

import asyncio

import httpx
import openai
import pytest
from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import AIMessage, HumanMessage
from tenacity import AsyncRetrying, retry_if_exception, stop_after_attempt

from app.core.langgraph.agent.nodes import _AGENT_RETRYABLE_TYPES, _is_retryable_llm_error


def test_tools_module_imports():
    """Test that tool modules are imported correctly."""
    from app.core.langgraph.tools import skill_exclusive_tools, tools

    assert tools is not None
    assert skill_exclusive_tools is not None
    # skill_exclusive_tools is now empty since skills moved to script-based execution
    assert isinstance(skill_exclusive_tools, dict)


def test_system_prompt_loading():
    """Test that the system prompt loads correctly."""
    from app.core.prompts import get_stable_system_prompt

    prompt = get_stable_system_prompt()
    assert prompt is not None
    assert "You are Finvo" in prompt or "Finvo" in prompt


class _TokenizerlessModel(BaseChatModel):
    """Stand-in for providers (e.g. DeepSeek) that expose no tokenizer to LangChain."""

    model_name: str = "deepseek-v4-flash"

    @property
    def _llm_type(self) -> str:  # pragma: no cover - unused by the test path
        return "tokenizerless"

    def _generate(self, messages, stop=None, run_manager=None, **kwargs):  # pragma: no cover
        raise NotImplementedError

    def get_num_tokens_from_messages(self, messages):  # type: ignore[override]
        raise NotImplementedError(
            f"get_num_tokens_from_messages() is not presently implemented for model {self.model_name}"
        )


def test_prepare_messages_falls_back_when_tokenizer_unavailable():
    """prepare_messages must not crash when the model raises NotImplementedError.

    Regression for the stream_processor_error caused by DeepSeek
    (deepseek-v4-flash) lacking get_num_tokens_from_messages — trimming falls
    back to a cl100k_base approximation instead of propagating the error.
    """
    from app.utils.graph import prepare_messages

    llm = _TokenizerlessModel()
    history = [
        HumanMessage(content="hello"),
        AIMessage(content="hi there"),
        HumanMessage(content="how are you?"),
    ]

    result = prepare_messages(history, llm, system_prompt="You are Finvo")

    # System prompt is always prepended, untouched.
    assert result[0].content == "You are Finvo"
    # History is preserved (fallback counter keeps trimming functional, not destructive).
    assert len(result) == 1 + len(history)
    assert result[-1].content == "how are you?"


# ---------------------------------------------------------------------------
# Regression: LLM retry policy must not retry deterministic 4xx errors (AG-P1-1)
#
# _AGENT_RETRYABLE previously contained the openai.APIError base class; since
# RateLimit/Timeout/Connection errors are all APIError subclasses, 400 bad
# request / 401 bad key / 422 context overflow were retried three exponential
# backoff rounds before surfacing. The tuple now pins the transient subset.
# ---------------------------------------------------------------------------

def _api_error(status: int) -> openai.APIStatusError:
    request = httpx.Request("POST", "https://llm.example/v1/chat/completions")
    response = httpx.Response(status, request=request)
    cls = {
        400: openai.BadRequestError,
        401: openai.AuthenticationError,
        422: openai.UnprocessableEntityError,
        429: openai.RateLimitError,
        500: openai.InternalServerError,
        # the openai client maps every >= 500 without a dedicated class to
        # InternalServerError (there is no separate 503 type)
        503: openai.InternalServerError,
    }[status]
    return cls("upstream", response=response, body=None)


def test_retryable_policy_excludes_api_error_base():
    assert openai.APIError not in _AGENT_RETRYABLE_TYPES
    assert openai.APIStatusError not in _AGENT_RETRYABLE_TYPES


def test_deterministic_4xx_errors_are_not_retryable():
    for status in (400, 401, 422):
        assert not _is_retryable_llm_error(_api_error(status)), f"HTTP {status} must not be retried"


def test_transient_errors_are_retryable():
    assert _is_retryable_llm_error(_api_error(429))
    assert _is_retryable_llm_error(_api_error(500))
    assert _is_retryable_llm_error(_api_error(503))
    assert _is_retryable_llm_error(openai.APIConnectionError(request=httpx.Request("POST", "https://llm.example")))
    assert _is_retryable_llm_error(TimeoutError())
    assert not _is_retryable_llm_error(ValueError("unrelated"))


@pytest.mark.asyncio
async def test_bad_request_propagates_on_first_attempt():
    """A deterministic 4xx fails the turn immediately (no backoff rounds)."""
    attempts = 0

    async def fail_400() -> None:
        nonlocal attempts
        attempts += 1
        raise _api_error(400)

    with pytest.raises(openai.BadRequestError):
        async for attempt in AsyncRetrying(
            stop=stop_after_attempt(3),
            wait=lambda _: 0,  # no sleeping in tests
            retry=retry_if_exception(_is_retryable_llm_error),
            reraise=True,
        ):
            with attempt:
                await fail_400()
    assert attempts == 1


@pytest.mark.asyncio
async def test_rate_limit_error_is_retried():
    """A transient 429 is retried up to the attempt budget."""
    attempts = 0

    async def fail_429() -> None:
        nonlocal attempts
        attempts += 1
        raise _api_error(429)

    with pytest.raises(openai.RateLimitError):
        async for attempt in AsyncRetrying(
            stop=stop_after_attempt(3),
            wait=lambda _: 0,
            retry=retry_if_exception(_is_retryable_llm_error),
            reraise=True,
        ):
            with attempt:
                await fail_429()
    assert attempts == 3
