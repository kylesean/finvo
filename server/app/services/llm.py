"""LLM service for managing LLM calls with retries and fallback mechanisms."""

from __future__ import annotations

import threading
from typing import (
    Any,
    cast,
)

from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import BaseMessage
from langchain_openai import ChatOpenAI
from pydantic import SecretStr

from app.core.config import settings
from app.core.logging import logger

# Placeholder used when no provider key is configured (ChatOpenAI
# requires a non-empty key); startup warns about it (see D6).
_PLACEHOLDER_API_KEY = "sk-dummy-key-for-init"  # pragma: allowlist secret


class LLMRegistry:
    """Registry of available LLM models with lazily-initialized instances.

    This class maintains a declarative list of LLM configurations and
    provides methods to retrieve them by name with optional argument
    overrides. Model instances are materialized on first access (under a
    lock) instead of at import time, so importing this module constructs no
    ``ChatOpenAI`` objects and settings are read when actually needed.

    Each model entry supports a ``capabilities`` dict declaring feature
    flags such as ``vision`` (multimodal image understanding).  Use
    :meth:`supports_vision` to query the current default model's capability.
    """

    _registry_lock = threading.Lock()
    _initialized = False

    _MODELS: list[dict[str, Any]] = [
        {
            "name": "gpt-5.6-sol",
            "capabilities": {"vision": True},
            "llm_kwargs": {
                "model": "gpt-5.6-sol",
                "api_key": SecretStr(settings.OPENAI_API_KEY or _PLACEHOLDER_API_KEY),
                "base_url": settings.OPENAI_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": settings.MAX_TOKENS,
                "reasoning_effort": "medium",
                "use_responses_api": True,
            },
        },
        {
            "name": "gpt-5.6-terra",
            "capabilities": {"vision": True},
            "llm_kwargs": {
                "model": "gpt-5.6-terra",
                "api_key": SecretStr(settings.OPENAI_API_KEY or _PLACEHOLDER_API_KEY),
                "base_url": settings.OPENAI_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": settings.MAX_TOKENS,
                "reasoning_effort": "low",
                "use_responses_api": True,
            },
        },
        {
            "name": "gpt-5.6-luna",
            "capabilities": {"vision": True},
            "llm_kwargs": {
                "model": "gpt-5.6-luna",
                "api_key": SecretStr(settings.OPENAI_API_KEY or _PLACEHOLDER_API_KEY),
                "base_url": settings.OPENAI_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": settings.MAX_TOKENS,
                "reasoning_effort": "low",
                "use_responses_api": True,
            },
        },
        {
            "name": "qwen3.8-max-preview",
            "capabilities": {"vision": True},
            "llm_kwargs": {
                "model": "qwen3.8-max-preview",
                "api_key": SecretStr(settings.QWEN_API_KEY or settings.OPENAI_API_KEY or _PLACEHOLDER_API_KEY),
                "base_url": settings.QWEN_BASE_URL or settings.OPENAI_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": settings.MAX_TOKENS,
                "reasoning_effort": "low",
                "use_responses_api": True,
            },
        },
        {
            "name": "doubao-seed-1-6-251015",
            "capabilities": {"vision": True},
            "llm_kwargs": {
                "model": "doubao-seed-1-6-251015",
                "api_key": SecretStr(settings.DOUBAO_API_KEY or settings.OPENAI_API_KEY or _PLACEHOLDER_API_KEY),
                "base_url": settings.DOUBAO_BASE_URL or settings.OPENAI_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": settings.MAX_TOKENS,
                "temperature": settings.DEFAULT_LLM_TEMPERATURE,
                "use_responses_api": True,
            },
        },
        {
            "name": "deepseek-v4-flash",
            "capabilities": {"vision": False},
            "llm_kwargs": {
                "model": "deepseek-v4-flash",
                "api_key": SecretStr(settings.DEEPSEEK_API_KEY or settings.OPENAI_API_KEY or _PLACEHOLDER_API_KEY),
                "base_url": settings.DEEPSEEK_BASE_URL or settings.OPENAI_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": settings.MAX_TOKENS,
                "temperature": settings.DEFAULT_LLM_TEMPERATURE,
            },
        },
    ]

    @classmethod
    def _build_llm(cls, entry: dict[str, Any]) -> ChatOpenAI:
        """Construct the ChatOpenAI instance for a declarative registry entry."""
        return ChatOpenAI(**entry["llm_kwargs"])

    @classmethod
    def _ensure_initialized(cls) -> None:
        """Materialize all model instances exactly once (thread-safe)."""
        if not cls._initialized:
            with cls._registry_lock:
                if not cls._initialized:
                    for entry in cls._MODELS:
                        entry["llm"] = cls._build_llm(entry)
                        cls._warn_on_placeholder_key(entry)
                    cls._initialized = True

    @classmethod
    def _warn_on_placeholder_key(cls, entry: dict[str, Any]) -> None:
        """Log a clear startup warning when a model runs with no real key.

        The ChatOpenAI constructor requires a non-empty api_key, so missing
        provider credentials fall back to a placeholder (D6); failing loudly
        at startup beats surfacing as a confusing auth error on the first
        request. Ollama models never have an API key — silence them.
        """
        key = entry["llm_kwargs"].get("api_key")
        key_value = key.get_secret_value() if isinstance(key, SecretStr) else str(key or "")
        if key_value == _PLACEHOLDER_API_KEY and not cls._is_ollama_model(entry["name"])[0]:
            logger.warning(
                "llm_model_has_no_api_key",
                model=entry["name"],
                hint="no provider API key is configured; requests to this model will fail until a key is set",
            )

    @classmethod
    def _llms(cls) -> list[dict[str, Any]]:
        """Return the materialized registry, initializing on first access."""
        cls._ensure_initialized()
        return cls._MODELS

    @classmethod
    def _is_ollama_model(cls, model_name: str) -> tuple[bool, str]:
        """Check if a model name refers to an Ollama model and return the clean model name.

        Args:
            model_name: Model name, possibly prefixed with 'ollama:' or 'ollama/'

        Returns:
            Tuple of (is_ollama, clean_model_name)
        """
        if model_name.startswith("ollama:"):
            return True, model_name[7:]
        if model_name.startswith("ollama/"):
            return True, model_name[7:]

        for entry in cls._llms():
            if entry["name"] == model_name and entry.get("provider") == "ollama":
                return True, model_name

        return False, model_name

    @classmethod
    def get(cls, model_name: str, **kwargs: Any) -> BaseChatModel:
        """Get an LLM by name with optional argument overrides.

        Args:
            model_name: Name of the model to retrieve
            **kwargs: Optional arguments to override default model configuration

        Returns:
            BaseChatModel instance

        Raises:
            ValueError: If model_name is not found in LLMS
        """
        is_ollama, clean_model_name = cls._is_ollama_model(model_name)

        # Find the model in the registry
        model_entry = None
        for entry in cls._llms():
            if entry["name"] in (model_name, clean_model_name):
                model_entry = entry
                break

        # If model not found in registry, create a dynamic entry
        if not model_entry:
            logger.info(
                "model_not_found_in_registry_creating_dynamic", model_name=model_name, clean_name=clean_model_name
            )
            api_key_val = (
                settings.OLLAMA_API_KEY or "ollama" if is_ollama else settings.OPENAI_API_KEY or _PLACEHOLDER_API_KEY
            )
            base_url = settings.OLLAMA_BASE_URL if is_ollama else settings.OPENAI_BASE_URL

            extra_kwargs: dict[str, Any] = {}
            if is_ollama:
                extra_kwargs = {
                    "max_completion_tokens": 512,
                    "temperature": 0.1,
                    "reasoning_effort": "low",
                    "extra_body": {"options": {"num_predict": 512, "num_ctx": 4096}},
                }
            else:
                extra_kwargs = {
                    "max_completion_tokens": settings.MAX_TOKENS,
                    "temperature": settings.DEFAULT_LLM_TEMPERATURE,
                }

            dynamic_llm = ChatOpenAI(
                model=clean_model_name,
                api_key=SecretStr(api_key_val),
                base_url=base_url,
                timeout=settings.LLM_REQUEST_TIMEOUT_SECONDS,
                **extra_kwargs,
            )
            model_entry = {
                "name": model_name,
                "provider": "ollama" if is_ollama else "openai",
                "llm": dynamic_llm,
            }
            # Add to registry so it can be used in fallback loop safely
            with cls._registry_lock:
                # Double-check inside lock to avoid race conditions
                if not any(e["name"] in (model_name, clean_model_name) for e in cls._llms()):
                    cls._llms().append(model_entry)

        # If user provides kwargs, create a new instance with those args
        if kwargs:
            logger.debug("creating_llm_with_custom_args", model_name=model_name, custom_args=list(kwargs.keys()))
            default_api_key = (
                settings.OLLAMA_API_KEY
                if (is_ollama or model_entry.get("provider") == "ollama")
                else settings.OPENAI_API_KEY
            )
            default_base_url = (
                settings.OLLAMA_BASE_URL
                if (is_ollama or model_entry.get("provider") == "ollama")
                else settings.OPENAI_BASE_URL
            )

            merged_kwargs = {
                "api_key": default_api_key,
                "base_url": default_base_url,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                **kwargs,
            }
            return ChatOpenAI(
                model=clean_model_name,
                **merged_kwargs,
            )

        # Return the default instance
        logger.debug("using_default_llm_instance", model_name=model_name)
        from langchain_core.language_models import BaseChatModel

        return cast(BaseChatModel, model_entry["llm"])

    @classmethod
    def get_all_names(cls) -> list[str]:
        """Get all registered LLM names in order.

        Returns:
            List of LLM names
        """
        return [entry["name"] for entry in cls._llms()]

    @classmethod
    def get_model_at_index(cls, index: int) -> dict[str, Any]:
        """Get model entry at specific index.

        Args:
            index: Index of the model in LLMS list

        Returns:
            Model entry dict
        """
        if 0 <= index < len(cls._llms()):
            return cls._llms()[index]
        return cls._llms()[0]  # Wrap around to first model

    @classmethod
    def get_llm_by_index(cls, index: int) -> BaseChatModel:
        """Get the LLM instance at a specific index (wraps around).

        Args:
            index: Index of the model entry

        Returns:
            The configured chat model for that entry
        """
        from langchain_core.language_models import BaseChatModel

        entry = cls.get_model_at_index(index)
        return cast(BaseChatModel, entry["llm"])

    @classmethod
    def supports_vision(cls, model_name: str | None = None) -> bool:
        """Check whether a model supports vision (multimodal image input).

        Resolution order:
        1. Explicit ``LLM_SUPPORTS_VISION`` env override (if set)
        2. ``capabilities.vision`` declared in the registry entry
        3. Default to False for unknown / dynamic models

        Args:
            model_name: Model to check.  Defaults to ``settings.DEFAULT_LLM_MODEL``.

        Returns:
            True if the model can accept ``image_url`` content parts.
        """
        # Env-level override takes highest priority
        if settings.LLM_SUPPORTS_VISION is not None:
            return settings.LLM_SUPPORTS_VISION

        target = model_name or settings.DEFAULT_LLM_MODEL
        for entry in cls._llms():
            if entry["name"] == target:
                caps = entry.get("capabilities", {})
                return bool(caps.get("vision", False))

        # Unknown model – conservative default
        return False


class LLMService:
    """Registry-backed LLM accessor.

    Resolves model instances (with per-model custom args, Ollama dynamic
    registration) and exposes the default instance via ``get_llm``. Retry
    and circular model fallback live in the LangGraph agent nodes
    (app.core.langgraph.agent.nodes), which consume this service.
    """

    def __init__(self) -> None:
        """Initialize the LLM service."""
        self._default_model_index: int = 0
        self._llm: BaseChatModel | None = None

        # Find index of default model in registry
        all_names = LLMRegistry.get_all_names()
        try:
            self._default_model_index = all_names.index(settings.DEFAULT_LLM_MODEL)
            self._llm = LLMRegistry.get(settings.DEFAULT_LLM_MODEL)
            logger.info(
                "llm_service_initialized",
                default_model=settings.DEFAULT_LLM_MODEL,
                model_index=self._default_model_index,
                total_models=len(all_names),
                environment=settings.ENVIRONMENT.value,
            )
        except Exception as e:
            # Default model not found, use first model
            self._default_model_index = 0
            self._llm = LLMRegistry.get_llm_by_index(0)
            logger.warning(
                "default_model_not_found_using_first",
                requested=settings.DEFAULT_LLM_MODEL,
                using=all_names[0] if all_names else "none",
                error=str(e),
            )

    def get_llm(self, model_name: str | None = None) -> BaseChatModel | None:
        """Get an LLM instance.

        Args:
            model_name: Optional model name. If None, returns default LLM instance.

        Returns:
            BaseChatModel instance or None if default is not initialized
        """
        if model_name:
            return LLMRegistry.get(model_name)

        return self._llm


# Lazy global LLM service singleton.
#
# The underlying LLMService (and with it the registry's ChatOpenAI instances)
# is constructed on first attribute access instead of at import time, so
# importing this module has no side effects.
class _LazyLLMService:
    """Thread-safe lazy singleton proxy for :class:`LLMService`."""

    _instance: LLMService | None = None
    _lock = threading.Lock()

    def __getattr__(self, name: str) -> Any:
        return getattr(self._get_instance(), name)

    def _get_instance(self) -> LLMService:
        with self._lock:
            if self._instance is None:
                self._instance = LLMService()
            return self._instance


# Global singleton used across the application
llm_service = _LazyLLMService()
