"""LLM service for managing LLM calls with retries and fallback mechanisms."""

from __future__ import annotations

import logging
import threading
from typing import (
    Any,
    cast,
)

from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import BaseMessage
from langchain_openai import ChatOpenAI
from openai import (
    APIError,
    APITimeoutError,
    OpenAIError,
    RateLimitError,
)
from pydantic import SecretStr
from tenacity import (
    before_sleep_log,
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from app.core.config import settings
from app.core.logging import logger


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

    # Declarative registry: entries carry ``llm_kwargs``; the live
    # ``ChatOpenAI`` instance is materialized into ``entry["llm"]`` by
    # :meth:`_ensure_initialized` on first access.
    _MODELS: list[dict[str, Any]] = [
        {
            "name": "gpt-5.6-sol",
            "capabilities": {"vision": True},
            "llm_kwargs": {
                "model": "gpt-5.6-sol",
                "api_key": SecretStr(settings.OPENAI_API_KEY or "sk-dummy-key-for-init"),
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
                "api_key": SecretStr(settings.OPENAI_API_KEY or "sk-dummy-key-for-init"),
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
                "api_key": SecretStr(settings.OPENAI_API_KEY or "sk-dummy-key-for-init"),
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
                "api_key": SecretStr(settings.QWEN_API_KEY or settings.OPENAI_API_KEY or "sk-dummy-key-for-init"),
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
                "api_key": SecretStr(settings.DOUBAO_API_KEY or settings.OPENAI_API_KEY or "sk-dummy-key-for-init"),
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
                "api_key": SecretStr(settings.DEEPSEEK_API_KEY or settings.OPENAI_API_KEY or "sk-dummy-key-for-init"),
                "base_url": settings.DEEPSEEK_BASE_URL or settings.OPENAI_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": settings.MAX_TOKENS,
                "temperature": settings.DEFAULT_LLM_TEMPERATURE,
            },
        },
        {
            "name": "qwen3.6-genesis-35b",
            "provider": "ollama",
            "capabilities": {"vision": False},
            "llm_kwargs": {
                "model": "qwen3.6-genesis-35b",
                "api_key": SecretStr(settings.OLLAMA_API_KEY or "ollama"),
                "base_url": settings.OLLAMA_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": 512,
                "temperature": 0.1,
                "reasoning_effort": "low",
                "extra_body": {
                    "options": {
                        "num_predict": 512,
                        "num_ctx": 4096,
                    }
                },
            },
        },
        {
            "name": "translategemma:4b-it",
            "provider": "ollama",
            "capabilities": {"vision": False},
            "llm_kwargs": {
                "model": "translategemma:4b-it",
                "api_key": SecretStr(settings.OLLAMA_API_KEY or "ollama"),
                "base_url": settings.OLLAMA_BASE_URL,
                "timeout": settings.LLM_REQUEST_TIMEOUT_SECONDS,
                "max_completion_tokens": 512,
                "temperature": 0.1,
                "extra_body": {
                    "options": {
                        "num_predict": 512,
                        "num_ctx": 4096,
                    }
                },
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
                    cls._initialized = True

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
                settings.OLLAMA_API_KEY or "ollama"
                if is_ollama
                else settings.OPENAI_API_KEY or "sk-dummy-key-for-init"
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
    """Service for managing LLM calls with retries and circular fallback.

    This service handles all LLM interactions with automatic retry logic,
    rate limit handling, and circular fallback through all available models.
    Execution is request-scoped and thread-safe without mutating shared service state.
    """

    def __init__(self) -> None:
        """Initialize the LLM service."""
        self._default_model_index: int = 0
        self._bound_tools: list[Any] = []
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

    @retry(
        stop=stop_after_attempt(settings.MAX_LLM_CALL_RETRIES),
        wait=wait_exponential(multiplier=1, min=2, max=10),
        retry=retry_if_exception_type((RateLimitError, APITimeoutError, APIError)),
        before_sleep=before_sleep_log(logger, logging.WARNING),
        reraise=True,
    )
    async def _call_llm_with_retry(
        self,
        llm: BaseChatModel,
        messages: list[BaseMessage],
    ) -> BaseMessage:
        """Call a specific LLM instance with automatic retry logic.

        Args:
            llm: The LLM model instance for this attempt
            messages: List of messages to send to the LLM

        Returns:
            BaseMessage response from the LLM

        Raises:
            OpenAIError: If all retries for this model fail
        """
        try:
            response = await llm.ainvoke(messages)
            logger.debug("llm_call_successful", message_count=len(messages))
            return response
        except (RateLimitError, APITimeoutError, APIError) as e:
            logger.warning(
                "llm_call_failed_retrying",
                error_type=type(e).__name__,
                error=str(e),
                exc_info=True,
            )
            raise
        except OpenAIError as e:
            logger.error(
                "llm_call_failed",
                error_type=type(e).__name__,
                error=str(e),
            )
            raise

    async def call(
        self,
        messages: list[BaseMessage],
        model_name: str | None = None,
        **model_kwargs: Any,
    ) -> BaseMessage:
        """Call the LLM with the specified messages and circular fallback.

        Execution is request-scoped and thread-safe without mutating shared service state.

        Args:
            messages: List of messages to send to the LLM
            model_name: Optional specific model to use. If None, uses default model.
            **model_kwargs: Optional kwargs to override default model configuration

        Returns:
            BaseMessage response from the LLM

        Raises:
            RuntimeError: If all models fail after retries
        """
        all_names = LLMRegistry.get_all_names()
        total_models = len(all_names)

        # Determine initial model index
        starting_index = self._default_model_index
        if model_name:
            try:
                starting_index = all_names.index(model_name)
            except ValueError:
                starting_index = self._default_model_index

        models_tried = 0
        last_error: Exception | None = None

        while models_tried < total_models:
            current_index = (starting_index + models_tried) % total_models
            current_model_entry = LLMRegistry.get_model_at_index(current_index)
            current_model_name = current_model_entry["name"]

            try:
                if models_tried == 0 and model_name:
                    target_llm = LLMRegistry.get(model_name, **model_kwargs)
                else:
                    target_llm = LLMRegistry.get(current_model_name)

                if self._bound_tools:
                    target_llm = cast(BaseChatModel, target_llm.bind_tools(self._bound_tools))
            except Exception as e:
                logger.error("failed_to_resolve_model_instance", model=current_model_name, error=str(e))
                models_tried += 1
                last_error = e
                continue

            # Log attempt details
            model_id = getattr(target_llm, "model_name", None) or getattr(target_llm, "model", current_model_name)
            base_url = getattr(target_llm, "base_url", "default")
            api_key = getattr(target_llm, "api_key", "")
            # Never log any portion of the credential; expose only whether it is configured.
            api_key_configured = isinstance(api_key, str) and bool(api_key)

            logger.info(
                "attempting_llm_call",
                model=model_id,
                base_url=str(base_url),
                api_key_configured=api_key_configured,
                attempt=models_tried + 1,
            )

            try:
                response = await self._call_llm_with_retry(target_llm, messages)
                return response
            except Exception as e:
                # Any failure of this model is grounds to try the next one in the
                # fallback ring (retries already happened inside the tenacity call).
                last_error = e
                models_tried += 1

                logger.error(
                    "llm_call_failed_after_retries",
                    model=current_model_name,
                    models_tried=models_tried,
                    total_models=total_models,
                    error=str(e),
                )

                if models_tried >= total_models:
                    logger.error(
                        "all_models_failed",
                        models_tried=models_tried,
                        starting_model=all_names[starting_index],
                    )
                    break

        raise RuntimeError(
            f"failed to get response from llm after trying {models_tried} models. last error: {str(last_error)}"
        )

    def get_llm(self, model_name: str | None = None) -> BaseChatModel | None:
        """Get an LLM instance.

        Args:
            model_name: Optional model name. If None, returns default LLM instance.

        Returns:
            BaseChatModel instance or None if default is not initialized
        """
        if model_name:
            target = LLMRegistry.get(model_name)
            if self._bound_tools:
                return cast(BaseChatModel, target.bind_tools(self._bound_tools))
            return target

        if self._llm:
            if self._bound_tools:
                return cast(BaseChatModel, self._llm.bind_tools(self._bound_tools))
            return self._llm

        return None

    def bind_tools(self, tools: list[Any]) -> LLMService:
        """Bind tools to the LLM service in a thread and task-safe, immutable manner.

        Args:
            tools: List of tools to bind

        Returns:
            A new LLMService instance with tools bound without mutating self.
        """
        new_service = LLMService.__new__(LLMService)
        new_service._default_model_index = self._default_model_index
        new_service._bound_tools = list(tools)
        if self._llm:
            new_service._llm = cast(BaseChatModel, self._llm.bind_tools(tools))
        else:
            new_service._llm = None
        return new_service


# Lazy global LLM service singleton.
#
# The underlying LLMService (and with it the registry's ChatOpenAI instances)
# is constructed on first attribute access instead of at import time, so
# importing this module has no side effects. `patch("app.services.llm.llm_service.call", ...)`
# still works: setattr lands on the proxy and shadows the forwarded attribute.
class _LazyLLMService:
    """Thread-safe lazy singleton proxy for :class:`LLMService`."""

    _instance: LLMService | None = None
    _lock = threading.Lock()

    def __getattr__(self, name: str) -> Any:
        return getattr(self._get_instance(), name)

    def _get_instance(self) -> LLMService:
        if _LazyLLMService._instance is None:
            with _LazyLLMService._lock:
                if _LazyLLMService._instance is None:
                    _LazyLLMService._instance = LLMService()
        return _LazyLLMService._instance


llm_service = _LazyLLMService()
