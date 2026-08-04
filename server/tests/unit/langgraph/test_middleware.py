"""Tests for LangGraph middleware components.

This module contains unit tests for the middleware chain used in the
LangGraph agent, including context, memory, and validation middleware.
"""

from datetime import datetime
from zoneinfo import ZoneInfo

import pytest
from langchain_core.messages import HumanMessage, SystemMessage

from app.core.langgraph.middleware.attachment import AttachmentMiddleware
from app.core.langgraph.middleware.context import DynamicContextMiddleware
from app.core.langgraph.middleware.memory import LongTermMemoryMiddleware
from app.core.langgraph.middleware.state_validator import StateValidator
from app.schemas.client_state import ClientStateMutation


class TestContextMiddleware:
    """Tests for DynamicContextMiddleware."""

    async def test_context_injection(self):
        """Test that user context is properly injected into agent state."""
        mw = DynamicContextMiddleware()
        assert mw.name == "DynamicContextMiddleware"

        messages, config = await mw.before_invoke(
            [HumanMessage(content="hello")],
            {"configurable": {"user_uuid": "user-123", "user_timezone": "Asia/Shanghai"}},
        )

        assert isinstance(messages[0], SystemMessage)
        content = messages[0].content
        assert "Current date:" in content
        assert "[Asia/Shanghai]" in content
        assert "User ID: user-123" in content

        expected_date = datetime.now(ZoneInfo("Asia/Shanghai")).strftime("%Y-%m-%d (%A)")
        assert expected_date in content

    async def test_context_with_missing_user(self):
        """Test graceful handling when user context is missing."""
        mw = DynamicContextMiddleware()

        messages, config = await mw.before_invoke(
            [HumanMessage(content="hello")],
            {"configurable": {}},
        )

        assert isinstance(messages[0], SystemMessage)
        content = messages[0].content
        assert "Current date:" in content
        assert "User ID" not in content

    async def test_context_appends_to_existing_system_message(self):
        """Test that context is appended to an existing system message."""
        mw = DynamicContextMiddleware()
        system = SystemMessage(content="You are a helpful assistant.")

        messages, _ = await mw.before_invoke(
            [system],
            {"configurable": {"user_uuid": "user-123"}},
        )

        assert isinstance(messages[0], SystemMessage)
        assert "You are a helpful assistant." in messages[0].content
        assert "# Dynamic Context" in messages[0].content

    async def test_context_default_timezone(self):
        """Test fallback timezone when not provided."""
        mw = DynamicContextMiddleware()

        messages, _ = await mw.before_invoke(
            [HumanMessage(content="hello")],
            {"configurable": {}},
        )

        assert "[Asia/Shanghai]" in messages[0].content


class TestMemoryMiddleware:
    """Tests for LongTermMemoryMiddleware (passive no-op mode)."""

    async def test_memory_retrieval(self):
        """Test that the middleware is passive: messages pass through unchanged."""
        mw = LongTermMemoryMiddleware()
        assert mw.name == "LongTermMemoryMiddleware"

        original = [HumanMessage(content="hello"), SystemMessage(content="sys")]
        messages, config = await mw.before_invoke(original, {"configurable": {"user_uuid": "u1"}})

        assert messages == original
        assert config == {"configurable": {"user_uuid": "u1"}}

    async def test_memory_configurable_limits(self):
        """Test that constructor options are stored on the instance."""
        mw = LongTermMemoryMiddleware(max_memories=3, min_relevance_score=0.5, categories=["finance"])

        assert mw.max_memories == 3
        assert mw.min_relevance_score == 0.5
        assert mw.categories == ["finance"]

    async def test_memory_with_new_user(self):
        """Test behavior when user has no config data at all."""
        mw = LongTermMemoryMiddleware()

        original = [HumanMessage(content="hi")]
        messages, config = await mw.before_invoke(original, {})

        assert messages == original
        assert config == {}


class TestStateValidatorMiddleware:
    """Tests for StateValidator."""

    def test_valid_client_state(self):
        """Test that valid client state passes validation."""
        validator = StateValidator()

        result = validator.validate(None)
        assert result.valid

        result = validator.validate(ClientStateMutation(ui_mode="idle"))
        assert result.valid

        result = validator.validate(
            ClientStateMutation(
                ui_mode="direct_execute",
                tool_name="execute_transfer",
                tool_params={
                    "source_account_id": "acc-1",
                    "target_account_id": "acc-2",
                    "amount": "100.50",
                },
            )
        )
        assert result.valid
        assert result.errors == []

    def test_invalid_client_state_degradation(self):
        """Test graceful degradation when client state is invalid."""
        validator = StateValidator()

        result = validator.validate(ClientStateMutation(ui_mode="direct_execute"))
        assert not result.valid
        assert any("requires tool_name" in e for e in result.errors)

        result = validator.validate(ClientStateMutation(ui_mode="direct_execute", tool_name="execute_transfer"))
        assert not result.valid
        assert any("requires tool_params" in e for e in result.errors)

    def test_transfer_validation(self):
        """Test transfer parameter validation rules."""
        validator = StateValidator()

        result = validator.validate(
            ClientStateMutation(
                ui_mode="direct_execute",
                tool_name="execute_transfer",
                tool_params={"target_account_id": "acc-2", "amount": "100"},
            )
        )
        assert not result.valid
        assert "Missing source_account_id" in result.errors
        result = validator.validate(
            ClientStateMutation(
                ui_mode="direct_execute",
                tool_name="execute_transfer",
                tool_params={"source_account_id": "acc-1", "target_account_id": "acc-1", "amount": "100"},
            )
        )
        assert not result.valid
        assert any("cannot equal target_account_id" in e for e in result.errors)

    def test_transfer_amount_validation(self):
        """Test amount validation (positive, numeric, under limit)."""
        validator = StateValidator()

        def validate_amount(amount):
            return validator.validate(
                ClientStateMutation(
                    ui_mode="direct_execute",
                    tool_name="execute_transfer",
                    tool_params={
                        "source_account_id": "acc-1",
                        "target_account_id": "acc-2",
                        "amount": amount,
                    },
                )
            )

        for bad in [None, "", "0", "-5", "abc"]:
            assert not validate_amount(bad).valid, f"amount {bad!r} should be rejected"

        assert validate_amount("1000001").errors == ["Amount exceeds single-transfer limit 1000000"]
        assert validate_amount("999999.99").valid


class TestAttachmentMiddleware:
    """Tests for AttachmentMiddleware."""

    def _middleware(self):
        return AttachmentMiddleware(db_session_factory=lambda: None)

    async def test_no_attachment_ids_passthrough(self):
        """Test that messages pass through unchanged when no attachments requested."""
        mw = self._middleware()
        original = [HumanMessage(content="hello")]

        messages, config = await mw.before_invoke(original, {"configurable": {"user_uuid": "u1"}})

        assert messages == original
        assert config == {"configurable": {"user_uuid": "u1"}}

    async def test_no_user_uuid_passthrough(self):
        """Test graceful handling when user_uuid is missing."""
        mw = self._middleware()
        original = [HumanMessage(content="hello")]

        messages, config = await mw.before_invoke(
            original,
            {"configurable": {"attachment_ids": ["00000000-0000-0000-0000-000000000001"]}},
        )

        assert messages == original
        assert config.get("configurable", {}).get("_has_images") is None

    async def test_missing_attachments_passthrough(self):
        """Test graceful handling when attachments are not found in DB."""
        mw = self._middleware()

        async def no_attachments(*args, **kwargs):
            return []

        mw._load_attachments = no_attachments  # type: ignore[method-assign]
        original = [HumanMessage(content="hello")]

        messages, config = await mw.before_invoke(
            original,
            {"configurable": {"user_uuid": "u1", "attachment_ids": ["00000000-0000-0000-0000-000000000001"]}},
        )

        assert messages == original
        assert config.get("configurable", {}).get("_has_images") is None

    async def test_invalid_attachment_reference(self):
        """Test graceful handling of malformed attachment UUIDs."""
        mw = self._middleware()
        original = [HumanMessage(content="hello")]

        messages, config = await mw.before_invoke(
            original,
            {"configurable": {"user_uuid": "u1", "attachment_ids": ["not-a-uuid"]}},
        )

        assert messages == original
        assert config == {"configurable": {"user_uuid": "u1", "attachment_ids": ["not-a-uuid"]}}
