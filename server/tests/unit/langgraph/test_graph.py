"""Tests for LangGraph Agent Architecture

Verifies tool loading and system prompts.
"""

from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import AIMessage, HumanMessage


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
