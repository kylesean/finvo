"""Tests for MemoryService filters and cleanup functionality."""

from datetime import UTC, datetime, timedelta
from unittest.mock import AsyncMock

import pytest


class TestMemoryServiceFilters:
    """Test cases for memory search filter functionality.

    NOTE: The legacy `categories` filter parameter was intentionally removed from
    `search_memories` (see memory_service.py:281-292) because Mem0's infer=True
    pipeline assigns its own internal categories that may not match the metadata
    category written at add time. These tests now verify the current API:
    user-scoped search with no category filtering.
    """

    @pytest.fixture
    def mock_memory(self):
        """Create a mock AsyncMemory instance."""
        mock = AsyncMock()
        mock.search = AsyncMock()
        mock.get_all = AsyncMock()
        mock.delete = AsyncMock()
        return mock

    @pytest.mark.asyncio
    async def test_search_passes_user_id_filter(self, mock_memory):
        """Verify search passes a user_id-scoped filter to Mem0."""
        from app.services.memory.memory_service import MemoryService

        # Setup
        service = MemoryService()
        service._memory = mock_memory
        mock_memory.search.return_value = {"results": []}

        # Execute
        await service.search_memories(
            user_uuid="user-123",
            query="test query",
        )

        # Verify Mem0 search called with user_id filter (no category filtering)
        mock_memory.search.assert_called_once()
        call_kwargs = mock_memory.search.call_args[1]
        assert call_kwargs["filters"] == {"user_id": "user-123"}
        assert call_kwargs["query"] == "test query"
        assert call_kwargs["threshold"] == 0.0

    @pytest.mark.asyncio
    async def test_search_respects_limit(self, mock_memory):
        """Verify search passes the limit as top_k to Mem0."""
        from app.services.memory.memory_service import MemoryService

        # Setup
        service = MemoryService()
        service._memory = mock_memory
        mock_memory.search.return_value = {"results": []}

        # Execute with custom limit
        await service.search_memories(
            user_uuid="user-123",
            query="test query",
            limit=10,
        )

        # Verify top_k is forwarded
        mock_memory.search.assert_called_once()
        call_kwargs = mock_memory.search.call_args[1]
        assert call_kwargs["top_k"] == 10

    @pytest.mark.asyncio
    async def test_search_no_category_filter_applied(self, mock_memory):
        """Verify no category-based filtering is applied (intentionally omitted)."""
        from app.services.memory.memory_service import MemoryService

        # Setup
        service = MemoryService()
        service._memory = mock_memory
        mock_memory.search.return_value = {"results": []}

        # Execute
        await service.search_memories(
            user_uuid="user-123",
            query="test query",
        )

        # Verify filters only contain user_id, no category/OR logic
        mock_memory.search.assert_called_once()
        call_kwargs = mock_memory.search.call_args[1]
        filters = call_kwargs["filters"]
        assert "category" not in filters
        assert "OR" not in filters
        assert filters == {"user_id": "user-123"}

    @pytest.mark.asyncio
    async def test_infer_true_in_add(self, mock_memory):
        """Verify infer=True is passed to Mem0 add() for native fact extraction.

        The legacy custom extract_salient_facts pipeline was removed (see
        memory_service.py:220-221); Mem0's internal LLM now handles extraction
        via infer=True, which is the canonical Mem0 usage pattern.
        """
        from app.services.memory.memory_service import MemoryService

        # Setup
        service = MemoryService()
        service._memory = mock_memory
        mock_memory.add = AsyncMock(return_value={"results": [{"id": "mem_1", "memory": "fact"}]})

        # Execute
        await service.add_conversation_memory(
            user_uuid="user-123",
            messages=[{"role": "user", "content": "My budget is 5000"}],
        )

        # Verify infer=True was passed (native Mem0 extraction, not the removed
        # custom extract_salient_facts pipeline)
        mock_memory.add.assert_called_once()
        call_kwargs = mock_memory.add.call_args[1]
        assert call_kwargs.get("infer") is True


class TestMemoryServiceCleanup:
    """Test cases for memory cleanup functionality."""

    @pytest.fixture
    def mock_memory(self):
        """Create a mock AsyncMemory instance."""
        mock = AsyncMock()
        mock.get_all = AsyncMock()
        mock.delete = AsyncMock()
        return mock

    @pytest.mark.asyncio
    async def test_cleanup_old_memories_by_count(self, mock_memory):
        """Verify cleanup deletes excess memories when over limit."""
        from app.services.memory.memory_service import MemoryService

        # Setup - 5 memories, max is 3
        service = MemoryService()
        service._memory = mock_memory

        now = datetime.now(UTC)
        mock_memories = [{"id": f"mem_{i}", "created_at": (now - timedelta(days=i)).isoformat()} for i in range(5)]

        mock_memory.get_all.return_value = {"results": mock_memories}
        mock_memory.delete.return_value = None

        # Execute with max_memories=3
        result = await service.cleanup_old_memories(
            user_uuid="user-123",
            max_memories=3,
            days_old=365,  # High value so time-based cleanup doesn't trigger
        )

        # Should delete 2 oldest memories (mem_3, mem_4)
        assert result["deleted_count"] == 2
        assert result["remaining_count"] == 3

    @pytest.mark.asyncio
    async def test_cleanup_old_memories_by_age(self, mock_memory):
        """Verify cleanup deletes memories older than threshold."""
        from app.services.memory.memory_service import MemoryService

        # Setup - 3 old memories, 2 new ones
        service = MemoryService()
        service._memory = mock_memory

        now = datetime.now(UTC)
        mock_memories = [
            {"id": "mem_new_1", "created_at": (now - timedelta(days=10)).isoformat()},
            {"id": "mem_new_2", "created_at": (now - timedelta(days=20)).isoformat()},
            {"id": "mem_old_1", "created_at": (now - timedelta(days=100)).isoformat()},
            {"id": "mem_old_2", "created_at": (now - timedelta(days=150)).isoformat()},
            {"id": "mem_old_3", "created_at": (now - timedelta(days=200)).isoformat()},
        ]

        mock_memory.get_all.return_value = {"results": mock_memories}
        mock_memory.delete.return_value = None

        # Execute with days_old=90
        result = await service.cleanup_old_memories(
            user_uuid="user-123",
            max_memories=1000,  # High value so count-based cleanup doesn't trigger
            days_old=90,
        )

        # Should delete 3 old memories
        assert result["deleted_count"] == 3
        assert result["remaining_count"] == 2

    @pytest.mark.asyncio
    async def test_cleanup_no_memories(self, mock_memory):
        """Verify cleanup handles empty memory list gracefully."""
        from app.services.memory.memory_service import MemoryService

        # Setup
        service = MemoryService()
        service._memory = mock_memory
        mock_memory.get_all.return_value = {"results": []}

        # Execute
        result = await service.cleanup_old_memories(
            user_uuid="user-123",
        )

        # Should return zeros
        assert result["deleted_count"] == 0
        assert result["remaining_count"] == 0

        # Should not attempt any deletions
        mock_memory.delete.assert_not_called()
