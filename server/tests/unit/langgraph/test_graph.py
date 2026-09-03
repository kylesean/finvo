"""Agent wiring: tools, prompt, retry policy."""

import httpx
import openai
import pytest
from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import AIMessage, HumanMessage
from tenacity import AsyncRetrying, retry_if_exception, stop_after_attempt

from app.core.langgraph.agent.nodes import _RETRYABLE, is_retryable


def test_tools_module_imports():
    # Arrange + Act
    from app.core.langgraph.tools import tools

    # Assert
    assert len(tools) > 0
    names = [t.name for t in tools]
    assert len(names) == len(set(names))


def test_system_prompt_loading():
    # Arrange + Act
    from app.core.prompts import get_stable_system_prompt

    prompt = get_stable_system_prompt()

    # Assert
    assert "Finvo" in prompt


class _TokenizerlessModel(BaseChatModel):
    model_name: str = "deepseek-v4-flash"

    @property
    def _llm_type(self) -> str:
        return "tokenizerless"

    def _generate(self, messages, stop=None, run_manager=None, **kwargs):
        raise NotImplementedError

    def get_num_tokens_from_messages(self, messages):  # type: ignore[override]
        raise NotImplementedError(f"no tokenizer for {self.model_name}")


def test_prepare_messages_falls_back_when_tokenizer_unavailable():
    # Arrange
    from app.utils.graph import prepare_messages

    llm = _TokenizerlessModel()
    history = [
        HumanMessage(content="hello"),
        AIMessage(content="hi there"),
        HumanMessage(content="how are you?"),
    ]

    # Act
    result = prepare_messages(history, llm, system_prompt="You are Finvo")

    # Assert
    assert result[0].content == "You are Finvo"
    assert len(result) == 1 + len(history)
    assert result[-1].content == "how are you?"


def _api_error(status: int) -> openai.APIStatusError:
    request = httpx.Request("POST", "https://llm.example/v1/chat/completions")
    response = httpx.Response(status, request=request)
    cls = {
        400: openai.BadRequestError,
        401: openai.AuthenticationError,
        422: openai.UnprocessableEntityError,
        429: openai.RateLimitError,
        500: openai.InternalServerError,
        503: openai.InternalServerError,
    }[status]
    return cls("upstream", response=response, body=None)


def test_retryable_excludes_api_error_base():
    assert openai.APIError not in _RETRYABLE
    assert openai.APIStatusError not in _RETRYABLE


@pytest.mark.parametrize("status", [400, 401, 422])
def test_deterministic_4xx_not_retryable(status: int):
    assert not is_retryable(_api_error(status))


@pytest.mark.parametrize("status", [429, 500, 503])
def test_transient_status_retryable(status: int):
    assert is_retryable(_api_error(status))


def test_connection_and_timeout_retryable():
    assert is_retryable(openai.APIConnectionError(request=httpx.Request("POST", "https://llm.example")))
    assert is_retryable(TimeoutError())
    assert not is_retryable(ValueError("unrelated"))


@pytest.mark.asyncio
async def test_bad_request_fails_on_first_attempt():
    # Arrange
    attempts = 0

    async def fail_400() -> None:
        nonlocal attempts
        attempts += 1
        raise _api_error(400)

    # Act
    with pytest.raises(openai.BadRequestError):
        async for attempt in AsyncRetrying(
            stop=stop_after_attempt(3),
            wait=lambda _: 0,
            retry=retry_if_exception(is_retryable),
            reraise=True,
        ):
            with attempt:
                await fail_400()

    # Assert
    assert attempts == 1


@pytest.mark.asyncio
async def test_rate_limit_retried_to_budget():
    # Arrange
    attempts = 0

    async def fail_429() -> None:
        nonlocal attempts
        attempts += 1
        raise _api_error(429)

    # Act
    with pytest.raises(openai.RateLimitError):
        async for attempt in AsyncRetrying(
            stop=stop_after_attempt(3),
            wait=lambda _: 0,
            retry=retry_if_exception(is_retryable),
            reraise=True,
        ):
            with attempt:
                await fail_429()

    # Assert
    assert attempts == 3
