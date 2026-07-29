"""Memory Service - Centralized long-term memory management using Mem0.

This service provides:
- User memory CRUD operations
- Memory search with reranking
- Automatic memory extraction from conversations
- Memory lifecycle management (cleanup, archival)

Best Practices Implemented:
1. Memory Hygiene: Regular cleanup of old/irrelevant memories
2. Contextual Metadata: Rich metadata for better retrieval
3. Error Handling: Graceful degradation on failures
4. User Isolation: Memories are strictly scoped by user_id
"""

from __future__ import annotations

import os
from datetime import UTC, datetime
from typing import Any, cast
from uuid import UUID

# Disable mem0 telemetry before import — avoids PostHog client creation and
# duplicate-client warnings. Users can opt back in via MEM0_TELEMETRY=true.
os.environ.setdefault("MEM0_TELEMETRY", "false")

from mem0 import AsyncMemory

from app.core.config import settings
from app.core.logging import logger


class MemoryService:
    """Centralized service for long-term memory management.

    Singleton pattern ensures consistent memory instance across the app.

    Usage:
        service = await MemoryService.get_instance()

        # Add memory from conversation
        await service.add_conversation_memory(
            user_uuid=UUID("..."),
            messages=[{"role": "user", "content": "I prefer dark mode"}],
            session_id=UUID("..."),
        )

        # Search memories
        results = await service.search_memories(
            user_uuid="user-123",
            query="What are my preferences?",
        )

        # Get all memories for a user
        all_memories = await service.get_user_memories(user_uuid=UUID("..."))

        # Delete specific memory
        await service.delete_memory(memory_id="mem-789")
    """

    _instance: MemoryService | None = None
    _memory: AsyncMemory | None = None

    def __init__(self) -> None:
        """Private constructor. Use get_instance() instead."""
        pass

    @property
    def memory(self) -> AsyncMemory:
        """Get the initialized memory instance."""
        if self._memory is None:
            raise RuntimeError("Memory service not initialized")
        return self._memory

    @classmethod
    async def get_instance(cls) -> MemoryService:
        """Get or create the singleton instance.

        Returns:
            MemoryService instance with initialized AsyncMemory
        """
        if cls._instance is None:
            cls._instance = cls()
            await cls._instance._initialize()
        return cls._instance

    async def _initialize(self) -> None:
        """Initialize the AsyncMemory instance with configurable embedder."""
        if self._memory is not None:
            return

        try:
            # Build embedder configuration based on provider
            embedder_config = self._build_embedder_config()

            # Build Mem0 LLM config — must point at the same endpoint as the
            # memory model (e.g. SiliconFlow) rather than api.openai.com.
            llm_config: dict[str, Any] = {
                "model": settings.LONG_TERM_MEMORY_MODEL,
                "api_key": settings.LONG_TERM_MEMORY_MODEL_API_KEY or settings.OPENAI_API_KEY,
            }
            if settings.LONG_TERM_MEMORY_MODEL_BASE_URL:
                llm_config["openai_base_url"] = settings.LONG_TERM_MEMORY_MODEL_BASE_URL

            self._memory = AsyncMemory.from_config(
                config_dict={
                    "vector_store": {
                        "provider": "pgvector",
                        "config": {
                            "collection_name": settings.LONG_TERM_MEMORY_COLLECTION_NAME,
                            "dbname": settings.POSTGRES_DB,
                            "user": settings.POSTGRES_USER,
                            "password": settings.POSTGRES_PASSWORD,
                            "host": settings.POSTGRES_HOST,
                            "port": settings.POSTGRES_PORT,
                            "embedding_model_dims": settings.LONG_TERM_MEMORY_EMBEDDER_DIMS,
                        },
                    },
                    "llm": {
                        "provider": "openai",
                        "config": llm_config,
                    },
                    "embedder": embedder_config,
                }
            )
            logger.info(
                "memory_service_initialized",
                embedder_provider=settings.LONG_TERM_MEMORY_EMBEDDER_PROVIDER,
                embedder_model=settings.LONG_TERM_MEMORY_EMBEDDER_MODEL,
            )
        except Exception as e:
            logger.error("memory_service_init_failed", error=str(e))
            raise

    def _build_embedder_config(self) -> dict[str, Any]:
        """Build embedder configuration based on provider setting.

        Supports:
        - openai: OpenAI or OpenAI-compatible APIs (DeepSeek, SiliconFlow, etc.)
        - ollama: Local Ollama server
        - huggingface: HuggingFace embeddings

        Returns:
            dict: Embedder configuration for Mem0
        """
        provider = settings.LONG_TERM_MEMORY_EMBEDDER_PROVIDER.lower()

        config: dict[str, Any]
        if provider == "ollama":
            # Ollama local embeddings
            config = {
                "provider": "ollama",
                "config": {
                    "model": settings.LONG_TERM_MEMORY_EMBEDDER_MODEL,
                },
            }
            if settings.LONG_TERM_MEMORY_OLLAMA_BASE_URL:
                config["config"]["ollama_base_url"] = settings.LONG_TERM_MEMORY_OLLAMA_BASE_URL

            logger.info(
                "using_ollama_embedder",
                model=settings.LONG_TERM_MEMORY_EMBEDDER_MODEL,
                base_url=settings.LONG_TERM_MEMORY_OLLAMA_BASE_URL,
            )

        elif provider == "huggingface":
            # HuggingFace embeddings
            config = {
                "provider": "huggingface",
                "config": {
                    "model": settings.LONG_TERM_MEMORY_EMBEDDER_MODEL,
                },
            }
            if settings.LONG_TERM_MEMORY_EMBEDDER_API_KEY:
                config["config"]["api_key"] = settings.LONG_TERM_MEMORY_EMBEDDER_API_KEY

            logger.info(
                "using_huggingface_embedder",
                model=settings.LONG_TERM_MEMORY_EMBEDDER_MODEL,
            )

        else:
            # Default: OpenAI or OpenAI-compatible API
            config = {
                "provider": "openai",
                "config": {
                    "model": settings.LONG_TERM_MEMORY_EMBEDDER_MODEL,
                    "api_key": settings.LONG_TERM_MEMORY_EMBEDDER_API_KEY or settings.OPENAI_API_KEY,
                },
            }

            # Support custom base URL for OpenAI-compatible APIs
            base_url = settings.LONG_TERM_MEMORY_EMBEDDER_BASE_URL or settings.OPENAI_BASE_URL
            if base_url:
                config["config"]["openai_base_url"] = base_url

            logger.info(
                "using_openai_embedder",
                model=settings.LONG_TERM_MEMORY_EMBEDDER_MODEL,
                base_url=base_url or "https://api.openai.com/v1",
            )
        return config

    # =========================================================================
    # Core CRUD Operations
    # =========================================================================

    async def add_conversation_memory(
        self,
        user_uuid: UUID,
        messages: list[dict[str, Any]],
        session_id: UUID | None = None,
        category: str = "conversation",
        additional_metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """Add memories from a conversation using Mem0's native fact extraction.

        Delegates extraction entirely to Mem0's internal LLM (LONG_TERM_MEMORY_MODEL),
        which is a standard chat model unaffected by reasoning-mode output quirks.
        This avoids the brittle custom extract_salient_facts pipeline that failed
        when the main llm_service used reasoning models with use_responses_api=True.

        Args:
            user_uuid: User identifier
            messages: List of message dicts with 'role' and 'content'
            session_id: Optional session identifier for context
            category: Memory category hint
            additional_metadata: Extra metadata to store with memories

        Returns:
            dict with operation result
        """
        if not messages:
            return {"success": False, "message": "No messages provided"}

        user_id = str(user_uuid)

        metadata: dict[str, Any] = {
            "category": category,
            "timestamp": datetime.now(UTC).isoformat(),
            "original_message_count": len(messages),
            "memory_type": "extracted_fact",
        }

        if session_id:
            metadata["session_id"] = str(session_id)

        if additional_metadata:
            metadata.update(additional_metadata)

        try:
            # Mem0 native infer=True: passes messages to its own LLM for fact
            # extraction using its built-in FACT_RETRIEVAL_PROMPT.
            # This is the canonical Mem0 usage pattern and avoids any issues
            # with our main llm_service's reasoning model output format.
            result = await self.memory.add(
                messages,
                user_id=user_id,
                metadata=metadata,
                infer=True,
            )

            fact_count = len(result.get("results", [])) if isinstance(result, dict) else 0
            logger.info(
                "salient_memories_added",
                user_uuid=user_id,
                fact_count=fact_count,
                session_id=str(session_id) if session_id else None,
            )

            return {"success": True, "extracted": fact_count > 0, "fact_count": fact_count, "result": result}

        except Exception as e:
            logger.warning(
                "memory_add_failed",
                user_uuid=user_id,
                error=str(e),
            )
            return {"success": False, "error": str(e)}

    async def search_memories(
        self,
        user_uuid: UUID,
        query: str,
        limit: int = 5,
    ) -> list[dict[str, Any]]:
        """Search for relevant memories by vector similarity.

        Searches across all of the user's memories without category filtering.
        Category filtering is intentionally omitted: Mem0's infer=True pipeline
        assigns its own internal categories, which may not match the metadata
        category written at add time. Filtering by category would cause misses.

        Args:
            user_uuid: User identifier
            query: Search query string
            limit: Maximum number of results to return

        Returns:
            List of memory dicts with 'memory', 'score', and 'metadata'
        """
        user_id = str(user_uuid)

        try:
            filters: dict[str, Any] = {"user_id": user_id}

            result = await self.memory.search(
                query=query,
                top_k=limit,
                filters=filters,
                threshold=0.0,
            )

            memories = []
            if result and result.get("results"):
                memories = result["results"]

            logger.debug(
                "memory_search_completed",
                user_uuid=user_id,
                query_length=len(query),
                result_count=len(memories),
            )

            return memories

        except Exception as e:
            logger.warning(
                "memory_search_failed",
                user_uuid=user_id,
                error=str(e),
            )
            return []

    async def get_user_memories(
        self,
        user_uuid: UUID,
        limit: int = 100,
    ) -> list[dict[str, Any]]:
        """Get all memories for a user.

        Args:
            user_uuid: User identifier
            limit: Maximum number of memories to return

        Returns:
            List of all user memories
        """
        user_id = str(user_uuid)

        try:
            result = await self.memory.get_all(user_id=user_id)

            memories = []
            if result and result.get("results"):
                memories = result["results"][:limit]

            logger.debug(
                "memories_retrieved",
                user_uuid=user_id,
                count=len(memories),
            )

            return memories

        except Exception as e:
            logger.warning(
                "get_memories_failed",
                user_uuid=user_id,
                error=str(e),
            )
            return []

    async def get_memory_by_id(
        self,
        memory_id: str,
    ) -> dict[str, Any] | None:
        """Get a specific memory by ID.

        Args:
            memory_id: Memory identifier

        Returns:
            Memory dict or None if not found
        """
        try:
            result = await self.memory.get(memory_id)
            return cast(dict[Any, Any] | None, result)
        except Exception as e:
            logger.warning(
                "get_memory_failed",
                memory_id=memory_id,
                error=str(e),
            )
            return None

    async def update_memory(
        self,
        memory_id: str,
        data: str,
    ) -> bool:
        """Update an existing memory.

        Args:
            memory_id: Memory identifier
            data: New memory content

        Returns:
            True if successful, False otherwise
        """
        try:
            await self.memory.update(memory_id, data=data)
            logger.info("memory_updated", memory_id=memory_id)
            return True
        except Exception as e:
            logger.warning(
                "memory_update_failed",
                memory_id=memory_id,
                error=str(e),
            )
            return False

    async def delete_memory(
        self,
        memory_id: str,
    ) -> bool:
        """Delete a specific memory.

        Args:
            memory_id: Memory identifier

        Returns:
            True if successful, False otherwise
        """
        try:
            await self.memory.delete(memory_id)
            logger.info("memory_deleted", memory_id=memory_id)
            return True
        except Exception as e:
            logger.warning(
                "memory_delete_failed",
                memory_id=memory_id,
                error=str(e),
            )
            return False

    async def delete_all_user_memories(
        self,
        user_uuid: UUID,
    ) -> bool:
        """Delete all memories for a user.

        Args:
            user_uuid: User identifier

        Returns:
            True if successful, False otherwise
        """
        user_id = str(user_uuid)

        try:
            await self.memory.delete_all(user_id=user_id)
            logger.info("all_memories_deleted", user_uuid=user_id)
            return True
        except Exception as e:
            logger.warning(
                "delete_all_memories_failed",
                user_uuid=user_id,
                error=str(e),
            )
            return False

    # =========================================================================
    # Memory Formatting for Prompt Injection
    # =========================================================================

    def format_memories_for_prompt(
        self,
        memories: list[dict[str, Any]],
        max_memories: int = 5,
    ) -> str:
        """Format memories for injection into system prompts.

        Args:
            memories: List of memory dicts
            max_memories: Maximum number of memories to include

        Returns:
            Formatted string for prompt injection
        """
        if not memories:
            return ""

        # Take top N memories
        selected = memories[:max_memories]

        lines = []
        for mem in selected:
            memory_text = mem.get("memory", "")
            if memory_text:
                # Include score if available for debugging
                score = mem.get("score", 0)
                if score > 0:
                    lines.append(f"* {memory_text} (relevance: {score:.2f})")
                else:
                    lines.append(f"* {memory_text}")

        return "\n".join(lines)

    # =========================================================================
    # Memory Analytics
    # =========================================================================

    async def get_memory_stats(
        self,
        user_uuid: UUID,
    ) -> dict[str, Any]:
        """Get memory statistics for a user.

        Args:
            user_uuid: User identifier

        Returns:
            dict with memory count and category breakdown
        """
        memories = await self.get_user_memories(user_uuid, limit=1000)

        # Category breakdown
        categories: dict[str, int] = {}
        for mem in memories:
            meta = mem.get("metadata", {})
            cat = meta.get("category", "unknown")
            categories[cat] = categories.get(cat, 0) + 1

        return {
            "total_count": len(memories),
            "categories": categories,
        }

    # =========================================================================
    # Memory Lifecycle Management
    # =========================================================================

    async def cleanup_old_memories(
        self,
        user_uuid: UUID,
        days_old: int = 180,
        max_memories: int = 500,
    ) -> dict[str, Any]:
        """Clean up old or excess memories for a user.

        Implements two cleanup strategies:
        1. Delete memories older than days_old
        2. Keep only max_memories most recent memories

        This method is safe to call periodically (e.g., via a scheduled job)
        to prevent unbounded memory growth.

        Args:
            user_uuid: User identifier
            days_old: Delete memories older than this (default 180 days)
            max_memories: Maximum memories to keep (default 500)

        Returns:
            dict with cleanup statistics:
            - deleted_count: Number of memories deleted
            - remaining_count: Number of memories after cleanup
            - error: Error message if cleanup failed
        """
        from datetime import timedelta

        user_id = str(user_uuid)
        deleted_count = 0

        try:
            memories = await self.get_user_memories(user_uuid, limit=1000)

            if not memories:
                return {"deleted_count": 0, "remaining_count": 0}

            cutoff_date = datetime.now(UTC) - timedelta(days=days_old)

            # Sort by created_at descending (newest first)
            sorted_memories = sorted(memories, key=lambda x: x.get("created_at", ""), reverse=True)

            # Identify memories to delete
            memories_to_delete = []

            for i, mem in enumerate(sorted_memories):
                # Strategy 1: Exceed max count (always delete excess)
                if i >= max_memories:
                    memories_to_delete.append(mem)
                    continue

                # Strategy 2: Older than cutoff date
                created_at_str = mem.get("created_at", "")
                if created_at_str:
                    try:
                        # Handle various ISO format variations
                        created_at_str = created_at_str.replace("Z", "+00:00")
                        created_at = datetime.fromisoformat(created_at_str)
                        if created_at < cutoff_date:
                            memories_to_delete.append(mem)
                    except ValueError:
                        pass

            # Delete identified memories
            for mem in memories_to_delete:
                mem_id = mem.get("id")
                if mem_id:
                    success = await self.delete_memory(mem_id)
                    if success:
                        deleted_count += 1

            remaining_count = len(memories) - deleted_count

            logger.info(
                "memory_cleanup_completed",
                user_uuid=user_id,
                deleted_count=deleted_count,
                remaining_count=remaining_count,
                days_threshold=days_old,
                max_memories=max_memories,
            )

            return {
                "deleted_count": deleted_count,
                "remaining_count": remaining_count,
            }

        except Exception as e:
            logger.error(
                "memory_cleanup_failed",
                user_uuid=user_id,
                error=str(e),
            )
            return {
                "deleted_count": deleted_count,
                "error": str(e),
            }


# Convenience function for quick access
async def get_memory_service() -> MemoryService:
    """Get the memory service instance.

    Returns:
        MemoryService singleton instance
    """
    return await MemoryService.get_instance()
