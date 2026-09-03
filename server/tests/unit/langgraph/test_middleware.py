"""Middleware: context, attachments, skill catalog, state validation."""

from datetime import datetime
from zoneinfo import ZoneInfo

from langchain_core.messages import HumanMessage, SystemMessage

from app.core.langgraph.middleware.attachment import AttachmentMiddleware
from app.core.langgraph.middleware.context import DynamicContextMiddleware
from app.core.langgraph.middleware.state_validator import StateValidator
from app.schemas.client_state import ClientStateMutation


class TestContextMiddleware:
    async def test_injects_date_timezone_and_user(self):
        # Arrange
        mw = DynamicContextMiddleware()

        # Act
        messages, _ = await mw.before_invoke(
            [HumanMessage(content="hello")],
            {"configurable": {"user_uuid": "user-123", "user_timezone": "Asia/Shanghai"}},
        )

        # Assert
        assert isinstance(messages[0], SystemMessage)
        assert "Current date:" in messages[0].content
        assert "[Asia/Shanghai]" in messages[0].content
        assert "User ID: user-123" in messages[0].content
        expected = datetime.now(ZoneInfo("Asia/Shanghai")).strftime("%Y-%m-%d (%A)")
        assert expected in messages[0].content

    async def test_missing_user_omits_user_line(self):
        # Arrange
        mw = DynamicContextMiddleware()

        # Act
        messages, _ = await mw.before_invoke([HumanMessage(content="hello")], {"configurable": {}})

        # Assert
        assert "Current date:" in messages[0].content
        assert "User ID" not in messages[0].content

    async def test_appends_to_existing_system_message(self):
        # Arrange
        mw = DynamicContextMiddleware()

        # Act
        messages, _ = await mw.before_invoke(
            [SystemMessage(content="You are a helpful assistant.")],
            {"configurable": {"user_uuid": "user-123"}},
        )

        # Assert
        assert "You are a helpful assistant." in messages[0].content
        assert "# Dynamic Context" in messages[0].content


class TestStateValidator:
    def test_accepts_idle_and_valid_direct_execute(self):
        # Arrange
        validator = StateValidator()

        # Act + Assert
        assert validator.validate(None).valid
        assert validator.validate(ClientStateMutation(ui_mode="idle")).valid
        assert validator.validate(
            ClientStateMutation(
                ui_mode="direct_execute",
                tool_name="execute_transfer",
                tool_params={
                    "source_account_id": "acc-1",
                    "target_account_id": "acc-2",
                    "amount": "100.50",
                },
            )
        ).valid

    def test_rejects_direct_execute_without_tool(self):
        # Arrange
        validator = StateValidator()

        # Act
        result = validator.validate(ClientStateMutation(ui_mode="direct_execute"))

        # Assert
        assert not result.valid
        assert any("requires tool_name" in e for e in result.errors)

    def test_rejects_same_source_and_target(self):
        # Arrange
        validator = StateValidator()

        # Act
        result = validator.validate(
            ClientStateMutation(
                ui_mode="direct_execute",
                tool_name="execute_transfer",
                tool_params={"source_account_id": "acc-1", "target_account_id": "acc-1", "amount": "100"},
            )
        )

        # Assert
        assert not result.valid

    def test_rejects_bad_amounts(self):
        # Arrange
        validator = StateValidator()

        def check(amount):
            return validator.validate(
                ClientStateMutation(
                    ui_mode="direct_execute",
                    tool_name="execute_transfer",
                    tool_params={"source_account_id": "acc-1", "target_account_id": "acc-2", "amount": amount},
                )
            )

        # Act + Assert
        for bad in [None, "", "0", "-5", "abc"]:
            assert not check(bad).valid
        assert check("1000001").errors == ["Amount exceeds single-transfer limit 1000000"]
        assert check("999999.99").valid


class TestAttachmentMiddleware:
    def _middleware(self):
        return AttachmentMiddleware(db_session_factory=lambda: None)

    async def test_passthrough_without_attachment_ids(self):
        # Arrange
        mw = self._middleware()
        original = [HumanMessage(content="hello")]

        # Act
        messages, config = await mw.before_invoke(original, {"configurable": {"user_uuid": "u1"}})

        # Assert
        assert messages == original
        assert config == {"configurable": {"user_uuid": "u1"}}

    async def test_passthrough_without_user(self):
        # Arrange
        mw = self._middleware()

        # Act
        messages, _ = await mw.before_invoke(
            [HumanMessage(content="hello")],
            {"configurable": {"attachment_ids": ["00000000-0000-0000-0000-000000000001"]}},
        )

        # Assert
        assert messages[0].content == "hello"

    async def test_passthrough_on_malformed_uuid(self):
        # Arrange
        mw = self._middleware()

        # Act
        messages, _ = await mw.before_invoke(
            [HumanMessage(content="hello")],
            {"configurable": {"user_uuid": "u1", "attachment_ids": ["not-a-uuid"]}},
        )

        # Assert
        assert messages[0].content == "hello"
