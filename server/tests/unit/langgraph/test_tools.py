"""Tests for LangGraph tool functions.

This module contains unit tests for the tool functions used by the
LangGraph agent, including transaction, budget, and transfer tools.
"""

import importlib
from datetime import UTC, datetime
from pathlib import Path

import pytest

from app.core.langgraph.tools import current_user_id
from app.core.langgraph.tools.filesystem_backend import CommandValidator, SimpleFilesystemBackend

# NOTE: the package re-exports `filesystem_tools` as a list, so a plain
# `import ... as ft` resolves to the list; fetch the module explicitly.
ft = importlib.import_module("app.core.langgraph.tools.filesystem_tools")


class TestTransactionTools:
    """Tests for transaction-related tools."""

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_create_transaction_success(self):
        """Test successful transaction creation via tool."""
        # TODO: Implement test
        # 1. Mock database session
        # 2. Call create_transaction tool
        # 3. Verify transaction is created with correct fields
        pass

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_create_transaction_invalid_amount(self):
        """Test transaction creation with invalid amount."""
        pass

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_query_transactions_with_filters(self):
        """Test querying transactions with various filters."""
        pass

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_delete_transaction_authorization(self):
        """Test that users can only delete their own transactions."""
        pass


class TestBudgetTools:
    """Tests for budget-related tools."""

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_create_budget_success(self):
        """Test successful budget creation via tool."""
        pass

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_get_budget_summary(self):
        """Test retrieving budget summary with spending calculations."""
        pass

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_budget_alert_generation(self):
        """Test that alerts are generated when budget thresholds are exceeded."""
        pass


class TestTransferTools:
    """Tests for account transfer tools."""

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_prepare_transfer(self):
        """Test transfer preparation with account matching."""
        pass

    def test_execute_transfer_input_accepts_currency(self):
        """BF-P0-2 regression: the wizard-confirmed currency must survive validation.

        The client sends ``currency`` in toolParams; before the fix the schema
        had no such field and Pydantic silently dropped it, so every transfer
        was booked as CNY regardless of what the user confirmed.
        """
        from decimal import Decimal

        from app.core.langgraph.tools.transfer_tools import ExecuteTransferInput

        params = {
            "source_account_id": "0b8f9d1e-1111-4a2a-9c9c-000000000001",
            "target_account_id": "0b8f9d1e-1111-4a2a-9c9c-000000000002",
            "amount": "100.00",
            "currency": "USD",
            # The full client payload also carries extra keys — must stay tolerated.
            "surface_id": "surface_1",
        }
        parsed = ExecuteTransferInput.model_validate(params)
        assert parsed.currency == "USD"
        assert parsed.amount == "100.00000000"

    def test_execute_transfer_input_currency_optional(self):
        from app.core.langgraph.tools.transfer_tools import ExecuteTransferInput

        parsed = ExecuteTransferInput.model_validate(
            {
                "source_account_id": "0b8f9d1e-1111-4a2a-9c9c-000000000001",
                "target_account_id": "0b8f9d1e-1111-4a2a-9c9c-000000000002",
                "amount": "12.5",
            }
        )
        assert parsed.currency is None

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_execute_transfer_success(self):
        """Test successful transfer execution between accounts."""
        pass

    @pytest.mark.skip(reason="Skeleton - implement in future iteration")
    async def test_transfer_insufficient_balance(self):
        """Test transfer rejection when source account has insufficient balance."""
        pass


class TestToolMetadata:
    """Tests for tool metadata and registration."""

    def test_all_tools_have_descriptions(self):
        """Test that all tools have proper descriptions for LLM."""
        from app.core.langgraph.tools import tools

        assert len(tools) > 0
        for tool in tools:
            assert tool.name, f"tool {tool!r} has no name"
            assert tool.description, f"tool {tool.name!r} has no description"
            assert len(tool.description) > 10, f"tool {tool.name!r} description too short"

    def test_tool_parameter_types(self):
        """Test that tool parameters have correct type annotations."""
        from app.core.langgraph.tools import tools

        for tool in tools:
            if tool.args_schema is None:
                continue
            fields = tool.args_schema.model_fields
            # Tools may legitimately expose no user-facing parameters when they
            # only consume injected runtime args (e.g. list_spaces), so only
            # validate annotations for parameters that actually exist.
            if not fields:
                continue
            for name, field in fields.items():
                assert field.annotation is not None, f"tool {tool.name!r} parameter {name!r} has no type annotation"

    def test_tool_names_unique(self):
        """Test that tool names are unique across the registry."""
        from app.core.langgraph.tools import tools

        names = [t.name for t in tools]
        duplicates = {n for n in names if names.count(n) > 1}
        assert not duplicates, f"duplicate tool names: {duplicates}"


class TestWriteFileSandbox:
    """Security tests for the write_file tool sandbox (C1)."""

    def _call_write(self, path: str, tmp_path: Path) -> object:
        """Invoke write_file_tool with PROJECT_ROOT/fs_backend pointed at tmp_path."""
        backend = SimpleFilesystemBackend(tmp_path)

        original_root = ft.PROJECT_ROOT
        original_backend = ft.fs_backend
        ft.PROJECT_ROOT = tmp_path
        ft.fs_backend = backend
        token = current_user_id.set("user-1")
        try:
            return ft.write_file_tool.invoke({"path": path, "content": "payload"})
        finally:
            ft.PROJECT_ROOT = original_root
            ft.fs_backend = original_backend
            current_user_id.reset(token)

    def test_rejects_path_traversal(self, tmp_path: Path) -> None:
        """../../evil.txt must not escape the artifacts sandbox."""
        result = self._call_write("../../evil.txt", tmp_path)
        assert isinstance(result, str)
        assert not (tmp_path / "evil.txt").exists()

    def test_rejects_absolute_path(self, tmp_path: Path) -> None:
        """Absolute paths must be rejected outright."""
        result = self._call_write(str(tmp_path / "evil.txt"), tmp_path)
        assert isinstance(result, str)
        assert not (tmp_path / "evil.txt").exists()

    def test_rejects_sensitive_path(self, tmp_path: Path) -> None:
        """Paths targeting .env/keys must be rejected."""
        result = self._call_write("../../.env", tmp_path)
        assert isinstance(result, str)
        assert not (tmp_path / ".env").exists()

    def test_allows_sandboxed_path(self, tmp_path: Path) -> None:
        """A normal relative path inside the sandbox is written successfully."""
        result = self._call_write("sub/page.html", tmp_path)
        assert isinstance(result, dict)
        assert result.get("success") is True
        assert (tmp_path / "artifacts" / "user-1" / "sub" / "page.html").exists()


class TestCommandValidatorSecurity:
    """Security tests for the shell command validator (C2)."""

    _ATTACKS = [
        "echo ''$(whoami)'' | uv run python app/skills/x/scripts/y.py",
        "echo 'a'$(whoami)'b' | uv run python app/skills/x/scripts/y.py",
        'echo "$(whoami)" | uv run python app/skills/x/scripts/y.py',
        "echo 'a'; rm -rf / | uv run python app/skills/x/scripts/y.py",
        "echo '`id`' | uv run python app/skills/x/scripts/y.py",
        "echo 'a\\'$(id)' | uv run python app/skills/x/scripts/y.py",
    ]

    def test_injection_attempts_blocked(self) -> None:
        """Quote-closing and command-substitution payloads must be rejected."""
        validator = CommandValidator(Path("/tmp"))
        for cmd in self._ATTACKS:
            assert not validator.validate(cmd).allowed, f"attack slipped through: {cmd}"

    def test_legit_pipe_allowed(self, tmp_path: Path) -> None:
        """The documented JSON echo pipe usage must still pass validation."""
        script = tmp_path / "app" / "skills" / "managing-shared-ledgers" / "scripts" / "query_space_summary.py"
        script.parent.mkdir(parents=True)
        script.write_text("", encoding="utf-8")

        validator = CommandValidator(tmp_path)
        result = validator.validate(
            'echo \'{"space_id": "uuid-string"}\' | '
            "uv run python app/skills/managing-shared-ledgers/scripts/query_space_summary.py"
        )
        assert result.allowed, result.reason

    def test_quoted_skill_args_allowed(self, tmp_path: Path) -> None:
        """LLM-style quoted string arguments (e.g. --target_hint "信用卡") must pass.

        LLMs naturally quote string args (the SKILL.md examples do too); before
        this was allowed those commands were rejected by the allowlist and
        surfaced as a generic "operation failed" tool block.
        """
        script = tmp_path / "app" / "skills" / "executing-transfers" / "scripts" / "prepare_transfer.py"
        script.parent.mkdir(parents=True)
        script.write_text("", encoding="utf-8")

        validator = CommandValidator(tmp_path)
        legit_cmds = [
            "uv run python app/skills/executing-transfers/scripts/prepare_transfer.py "
            '--amount 300 --target_hint "信用卡账户"',
            "uv run python app/skills/executing-transfers/scripts/prepare_transfer.py "
            "--tags '转账,日常' --amount \"300\"",
            'uv run python app/skills/executing-transfers/scripts/prepare_transfer.py --target_hint "工资 卡"',
        ]
        for cmd in legit_cmds:
            assert validator.validate(cmd).allowed, f"legit command rejected: {cmd}"

        attack_cmds = [
            'uv run python app/skills/executing-transfers/scripts/prepare_transfer.py --target_hint "x$(whoami)"',
            "uv run python app/skills/executing-transfers/scripts/prepare_transfer.py --target_hint x`id`",
            'uv run python app/skills/executing-transfers/scripts/prepare_transfer.py --target_hint "a&b"',
        ]
        for cmd in attack_cmds:
            assert not validator.validate(cmd).allowed, f"attack slipped through: {cmd}"


class TestParseTime:
    """AG-P1-3 regression: an unparseable timestamp must fail loud.

    parse_time used to silently fall back to "now" for garbage input, so
    "yestday" booked entries on the wrong day with no error anywhere.
    """

    def test_none_and_empty_fall_back_to_now(self) -> None:
        from app.core.langgraph.tools._helpers import parse_time

        parsed_none = parse_time(None)
        parsed_empty = parse_time("")
        now = datetime.now(UTC)
        # both calls must return an aware datetime near "now"
        assert parsed_none.tzinfo is not None and parsed_empty.tzinfo is not None
        assert abs((parsed_none - now).total_seconds()) < 5
        assert abs((parsed_empty - now).total_seconds()) < 5

    def test_valid_iso8601_parses(self) -> None:
        from app.core.langgraph.tools._helpers import parse_time

        assert parse_time("2026-09-01T10:00:00+00:00") == datetime(2026, 9, 1, 10, 0, 0, tzinfo=UTC)
        assert parse_time("2026-09-01T10:00:00Z") == datetime(2026, 9, 1, 10, 0, 0, tzinfo=UTC)

    def test_unparseable_raises_value_error(self) -> None:
        from app.core.langgraph.tools._helpers import parse_time

        with pytest.raises(ValueError, match="Unparseable transaction time"):
            parse_time("yestday")
        with pytest.raises(ValueError, match="Unparseable transaction time"):
            parse_time("2026-13-40")

    @pytest.mark.asyncio
    async def test_record_transactions_returns_structured_error(self) -> None:
        """The tool surfaces a model-readable error instead of booking "now"."""
        from uuid import uuid4

        from app.core.langgraph.tools.transaction_tools import record_transactions

        result = await record_transactions.ainvoke(
            {
                "transactions": [
                    {"amount": "10", "type": "expense", "tags": ["lunch"], "category_key": "OTHERS"}
                ],
                "transaction_at": "yestday",
            },
            config={"configurable": {"user_uuid": str(uuid4())}},
        )
        assert result["success"] is False
        assert result["error"] == "unparseable_time"
        assert result["raw"] == "yestday"

    @pytest.mark.asyncio
    async def test_execute_transfer_returns_structured_error(self) -> None:
        from uuid import uuid4

        from app.core.langgraph.tools.transfer_tools import execute_transfer

        result = await execute_transfer.ainvoke(
            {
                "source_account_id": "0b8f9d1e-1111-4a2a-9c9c-000000000001",
                "target_account_id": "0b8f9d1e-1111-4a2a-9c9c-000000000002",
                "amount": "10.00",
                "transaction_at": "not-a-date",
            },
            config={"configurable": {"user_uuid": str(uuid4())}},
        )
        assert result["success"] is False
        assert result["error"] == "unparseable_time"


class TestReadLsUserSandbox:
    """Security tests: read_file/ls are scoped to artifacts/{user_id} (SEC-P0-1).

    Previously they could read the ENTIRE project root (guarded only by a
    sensitive-filename blacklist), letting a user's agent enumerate and read
    other users' artifacts/uploads on a shared deployment.
    """

    def _patch_fs(self, tmp_path: Path, user: str | None = "user-1") -> list:
        backend = SimpleFilesystemBackend(tmp_path)
        original_root = ft.PROJECT_ROOT
        original_backend = ft.fs_backend
        ft.PROJECT_ROOT = tmp_path
        ft.fs_backend = backend
        token = current_user_id.set(user) if user else None
        return [original_root, original_backend, token]

    def _restore_fs(self, saved: list) -> None:
        ft.PROJECT_ROOT = saved[0]
        ft.fs_backend = saved[1]
        if saved[2] is not None:
            current_user_id.reset(saved[2])

    def test_read_requires_user_context(self, tmp_path: Path) -> None:
        saved = self._patch_fs(tmp_path, user=None)
        try:
            assert ft.read_file_tool.invoke({"path": "hello.txt"}) == "Error: User ID not available"
        finally:
            self._restore_fs(saved)

    def test_read_rejects_absolute_and_traversal(self, tmp_path: Path) -> None:
        (tmp_path / "outside.txt").write_text("top secret project file")
        saved = self._patch_fs(tmp_path)
        try:
            assert "Error" in ft.read_file_tool.invoke({"path": str(tmp_path / "outside.txt")})
            assert "Error" in ft.read_file_tool.invoke({"path": "../../outside.txt"})
            assert "top secret project file" not in ft.read_file_tool.invoke({"path": "../../outside.txt"})
        finally:
            self._restore_fs(saved)

    def test_read_own_artifact_succeeds(self, tmp_path: Path) -> None:
        sandbox_file = tmp_path / "artifacts" / "user-1" / "hello.txt"
        sandbox_file.parent.mkdir(parents=True)
        sandbox_file.write_text("hello artifact")

        saved = self._patch_fs(tmp_path)
        try:
            assert ft.read_file_tool.invoke({"path": "hello.txt"}) == "hello artifact"
        finally:
            self._restore_fs(saved)

    def test_read_cannot_reach_other_user_artifacts(self, tmp_path: Path) -> None:
        other = tmp_path / "artifacts" / "user-2"
        other.mkdir(parents=True)
        (other / "notes.txt").write_text("user-2 private notes")

        saved = self._patch_fs(tmp_path)  # current user is user-1
        try:
            result = ft.read_file_tool.invoke({"path": "../user-2/notes.txt"})
            assert "user-2 private notes" not in result
        finally:
            self._restore_fs(saved)

    def test_ls_scoped_to_sandbox(self, tmp_path: Path) -> None:
        sandbox = tmp_path / "artifacts" / "user-1"
        sandbox.mkdir(parents=True)
        (sandbox / "report.md").write_text("# report")
        (tmp_path / "artifacts" / "user-2").mkdir()
        (tmp_path / "artifacts" / "user-2" / "leak.txt").write_text("should not appear")

        saved = self._patch_fs(tmp_path)
        try:
            listing = ft.ls_tool.invoke({"path": "."})
            assert "report.md" in listing
            assert "leak.txt" not in listing
            assert "Error" not in listing
        finally:
            self._restore_fs(saved)
