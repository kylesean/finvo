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
    """验证 Agent 中间件的行为（目前改为 passive）"""
    # 彻底 Mock 掉 LLM 以避免网络延迟和挂起
    with patch("app.services.llm.llm_service.call", new_callable=AsyncMock) as _:
        from langchain_core.messages import HumanMessage

        from app.core.langgraph.middleware.memory import LongTermMemoryMiddleware

        middleware = LongTermMemoryMiddleware()

        # 此时 check before_invoke 是否由于我们的修改而不再执行检索
        messages = [HumanMessage(content="根据我之前的预算目标建议一下")]
        config = {"configurable": {"user_uuid": str(uuid4())}}

        # 在我们的新设计中，中间件应该直接返回，不做检索
        processed_msgs, _ = await middleware.before_invoke(messages, config)

        # 验证消息没被修改（即没有注入 "# 用户相关记忆"）
        assert len(processed_msgs) == 1
        assert "用户相关记忆" not in processed_msgs[0].content


@pytest.mark.asyncio
async def test_memory_tool_functionality():
    """直接测试 memory 工具的逻辑"""
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
