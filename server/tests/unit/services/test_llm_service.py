"""Tests for LLMRegistry and Ollama model adaptation."""

import pytest

from app.core.config import settings
from app.services.llm import LLMRegistry


class TestLLMRegistryOllama:
    """Test cases for LLMRegistry Ollama integration."""

    def test_dynamic_ollama_model_creation(self):
        """Test dynamically-created Ollama models use the configured OLLAMA base URL."""
        llm = LLMRegistry.get("ollama:local-model-test")
        assert (
            getattr(llm, "model_name", None) == "local-model-test" or getattr(llm, "model", None) == "local-model-test"
        )
        assert (
            getattr(llm, "openai_api_base", None) == settings.OLLAMA_BASE_URL
            or getattr(llm, "base_url", None) == settings.OLLAMA_BASE_URL
        )

    def test_ollama_prefix_parsing(self):
        """Test parsing models with ollama: and ollama/ prefixes."""
        # Test ollama: prefix
        llm_colon = LLMRegistry.get("ollama:my-custom-model")
        assert (
            getattr(llm_colon, "model_name", None) == "my-custom-model"
            or getattr(llm_colon, "model", None) == "my-custom-model"
        )

        # Test ollama/ prefix
        llm_slash = LLMRegistry.get("ollama/llama3-8b")
        assert (
            getattr(llm_slash, "model_name", None) == "llama3-8b" or getattr(llm_slash, "model", None) == "llama3-8b"
        )

    def test_is_ollama_model_helper(self):
        """Test _is_ollama_model classmethod helper."""
        is_ollama, clean_name = LLMRegistry._is_ollama_model("ollama:qwen2.5:7b")
        assert is_ollama is True
        assert clean_name == "qwen2.5:7b"

        is_ollama, clean_name = LLMRegistry._is_ollama_model("ollama/qwen2.5:7b")
        assert is_ollama is True
        assert clean_name == "qwen2.5:7b"

        # Bare names (no ollama prefix, not in registry) are not ollama models
        is_ollama, clean_name = LLMRegistry._is_ollama_model("some-cloud-model")
        assert is_ollama is False
        assert clean_name == "some-cloud-model"

        is_ollama, clean_name = LLMRegistry._is_ollama_model("gpt-5.6-sol")
        assert is_ollama is False
        assert clean_name == "gpt-5.6-sol"
