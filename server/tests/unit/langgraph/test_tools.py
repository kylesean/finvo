"""Tests for LangGraph tool functions.

This module contains unit tests for the tool functions used by the
LangGraph agent, including transaction, budget, and transfer tools.
"""

import importlib
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
            assert fields, f"tool {tool.name!r} args schema has no fields"
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
