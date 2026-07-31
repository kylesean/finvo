"""Tests for LLMRegistry and Ollama model adaptation."""

import pytest

from app.core.config import settings
from app.services.llm import LLMRegistry


class TestLLMRegistryOllama:
    """Test cases for LLMRegistry Ollama integration."""

    def test_registered_ollama_models(self):
        """Test retrieving registered Ollama models."""
        llm = LLMRegistry.get("qwen3.6-genesis-35b")
        assert (
            getattr(llm, "model_name", None) == "qwen3.6-genesis-35b"
            or getattr(llm, "model", None) == "qwen3.6-genesis-35b"
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

        is_ollama, clean_name = LLMRegistry._is_ollama_model("ollama/deepseek-r1")
        assert is_ollama is True
        assert clean_name == "deepseek-r1"

        is_ollama, clean_name = LLMRegistry._is_ollama_model("qwen3.6-genesis-35b")
        assert is_ollama is True
        assert clean_name == "qwen3.6-genesis-35b"

        is_ollama, clean_name = LLMRegistry._is_ollama_model("gpt-5.6-sol")
        assert is_ollama is False
        assert clean_name == "gpt-5.6-sol"


class TestLLMServiceConcurrency:
    """Test cases for LLMService concurrency safety and request isolation."""

    @pytest.mark.asyncio
    async def test_request_scoped_fallback_isolation(self, monkeypatch):
        """Test that model fallback in one task does not mutate shared LLMService state."""
        import asyncio
        from unittest.mock import AsyncMock

        from langchain_core.messages import AIMessage, HumanMessage
        from openai import OpenAIError

        from app.services.llm import LLMService

        service = LLMService()
        initial_llm = service.get_llm()

        fail_count = 0

        async def mock_call_llm_with_retry(llm_inst, messages):
            nonlocal fail_count
            # The default model call fails with OpenAIError to trigger fallback
            model_id = getattr(llm_inst, "model_name", None) or getattr(llm_inst, "model", "")
            if model_id == settings.DEFAULT_LLM_MODEL:
                fail_count += 1
                raise OpenAIError("Simulated provider failure")
            return AIMessage(content="Fallback model response")

        monkeypatch.setattr(service, "_call_llm_with_retry", mock_call_llm_with_retry)

        # Task A: triggers fallback
        res_a = await service.call([HumanMessage(content="hello")])
        assert res_a.content == "Fallback model response"
        assert fail_count > 0

        # Verify shared service state was NOT mutated
        after_llm = service.get_llm()
        assert initial_llm == after_llm

    def test_bind_tools_immutability(self):
        """Test that calling bind_tools returns a new LLMService instance without mutating the original instance."""
        from langchain_core.tools import tool

        from app.services.llm import LLMService

        @tool
        def dummy_tool(x: int) -> int:
            """Dummy tool."""
            return x

        service = LLMService()
        assert service._bound_tools == []

        bound_service = service.bind_tools([dummy_tool])

        # Original service must remain unmutated
        assert service._bound_tools == []
        assert bound_service is not service
        assert len(bound_service._bound_tools) == 1
        assert bound_service._bound_tools[0] == dummy_tool
