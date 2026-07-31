from unittest.mock import AsyncMock, patch
from uuid import UUID, uuid4

import pytest

from app.core.langgraph.tools.context import current_user_id
from app.services.memory.memory_service import MemoryService


@pytest.mark.asyncio
async def test_memory_extraction_boundary():
    """Verify fact extraction boundary: valuable messages get extracted, noise is ignored.

    With the new MemoryService API (memory_service.py:208-279), fact extraction is
    delegated to Mem0's internal LLM via `infer=True`. We mock the Mem0 `add()`
    method to simulate the extraction outcome:
      - valuable chat  → Mem0 returns extracted facts  → `extracted` is True
      - noise (lookup) → Mem0 returns no facts          → `extracted` is False

    This avoids hitting a real LLM or pgvector backend during integration testing.
    """
    service = MemoryService()
    service._memory = AsyncMock()

    # Scenario 1: conversation with long-term value → Mem0 extracts a fact
    service._memory.add = AsyncMock(
        return_value={"results": [{"id": "mem_1", "memory": "Has a mortgage with ICBC paying 8000 per month"}]}
    )
    valuable_chat = [
        {"role": "user", "content": "我的房贷是在工行办的，每个月要还 8000 元。"},
        {"role": "assistant", "content": "好的，我已经记下了您的房贷信息。"},
    ]
    result = await service.add_conversation_memory(UUID(int=0), valuable_chat)
    assert result["success"] is True
    assert result["extracted"] is True
    assert result["fact_count"] == 1
    # Verify infer=True is passed (Mem0 native extraction, not the removed custom pipeline)
    assert service._memory.add.call_args[1].get("infer") is True

    # Scenario 2: pure transient command (noise) → Mem0 extracts nothing
    service._memory.add = AsyncMock(return_value={"results": []})
    result_noise = await service.add_conversation_memory(UUID(int=1), [{"role": "user", "content": "查查余额"}])
    assert result_noise["success"] is True
    assert result_noise["extracted"] is False
    assert result_noise["fact_count"] == 0


@pytest.mark.asyncio
async def test_agent_proactive_memory_tool_call():
    """Verify Agent memory middleware behavior (currently configured as passive)."""
    # Fully mock LLM calls to avoid network latency and hangs
    with patch("app.services.llm.llm_service.call", new_callable=AsyncMock) as _:
        from langchain_core.messages import HumanMessage

        from app.core.langgraph.middleware.memory import LongTermMemoryMiddleware

        middleware = LongTermMemoryMiddleware()

        # Verify before_invoke no longer executes retrieval
        messages = [HumanMessage(content="Give me suggestions based on my budget goals")]
        config = {"configurable": {"user_uuid": str(uuid4())}}

        # Middleware should return directly without performing active retrieval
        processed_msgs, _ = await middleware.before_invoke(messages, config)

        # Verify message was not mutated (i.e., no "# User Memories" injected)
        assert len(processed_msgs) == 1
        assert "User Memories" not in processed_msgs[0].content


@pytest.mark.asyncio
async def test_memory_tool_functionality():
    """Directly test memory tool functionality."""
    from app.core.langgraph.tools.memory_tools import search_personal_context

    user_id = str(uuid4())
    current_user_id.set(user_id)

    with patch(
        "app.services.memory.memory_service.MemoryService.search_memories", new_callable=AsyncMock
    ) as mock_search:
        mock_search.return_value = [{"memory": "User wants to save 5000 per month", "score": 0.9}]

        result = await search_personal_context.ainvoke({"query": "budget caps"})
        assert "save 5000 per month" in result
        assert "Found the following" in result
