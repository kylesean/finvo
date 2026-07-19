"""Minimal filesystem backend without deepagents dependency.

Provides basic file operations (read, write, ls_info) and shell command execution
for LangGraph tools and skills.
"""

from __future__ import annotations

import os
import subprocess  # nosec B404
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class FileInfo:
    """Information about a file or directory."""

    name: str
    is_dir: bool
    size: int | None = None


@dataclass
class ExecuteResponse:
    """Response from command execution."""

    output: str
    exit_code: int


class SimpleFilesystemBackend:
    """Minimal filesystem backend for Skills and File operations.

    Replaces deepagents.backends.filesystem with a simple pathlib-based implementation.

    Provides:
    - read(): Read file content
    - write(): Write file content
    - ls_info(): List directory contents
    - execute(): Execute shell commands
    """

    def __init__(self, root_dir: Path | str):
        """Initialize with root directory.

        Args:
            root_dir: Base directory for all operations
        """
        self.root_dir = Path(root_dir).resolve()
        self.cwd = self.root_dir

    def _resolve_path(self, path: str) -> Path:
        """Safely resolve path within root_dir.

        Args:
            path: Relative or absolute path

        Returns:
            Resolved absolute path

        Raises:
            ValueError: If path attempts to escape root_dir
        """
        path_obj = Path(path)
        if path_obj.is_absolute():
            # If path is absolute, make it relative to root_dir if possible
            try:
                path_obj = path_obj.relative_to(self.root_dir)
            except ValueError:
                # Remove leading slash and resolve relative to root
                path_obj = Path(str(path).lstrip("/"))

        full_path = (self.root_dir / path_obj).resolve()

        # Security check: Ensure path does not escape root_dir
        if not str(full_path).startswith(str(self.root_dir)):
            raise ValueError(f"Path traversal not allowed: {path}")

        return full_path

    def read(self, path: str, offset: int = 0, limit: int | None = None) -> str:
        """Read file content.

        Args:
            path: File path relative to root_dir
            offset: Line offset (0-based)
            limit: Maximum lines to read

        Returns:
            File content as string
        """
        file_path = self._resolve_path(path)

        if not file_path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        if file_path.is_dir():
            raise IsADirectoryError(f"Cannot read directory: {path}")

        content = file_path.read_text(encoding="utf-8")

        if offset > 0 or limit is not None:
            lines = content.splitlines(keepends=True)
            if offset > 0:
                lines = lines[offset:]
            if limit is not None:
                lines = lines[:limit]
            content = "".join(lines)

        return content

    def write(self, path: str, content: str) -> dict[str, Any]:
        """Write content to file.

        Args:
            path: File path relative to root_dir
            content: Content to write

        Returns:
            Dict with path and success status
        """
        file_path = self._resolve_path(path)

        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content, encoding="utf-8")

        return {"path": str(file_path.relative_to(self.root_dir)), "success": True}

    def ls_info(self, path: str = ".") -> list[FileInfo]:
        """List directory contents with detailed info.

        Args:
            path: Directory path relative to root_dir

        Returns:
            List of FileInfo objects
        """
        dir_path = self._resolve_path(path)

        if not dir_path.exists():
            raise FileNotFoundError(f"Directory not found: {path}")

        if not dir_path.is_dir():
            raise NotADirectoryError(f"Not a directory: {path}")

        result = []
        for item in sorted(dir_path.iterdir(), key=lambda x: (not x.is_dir(), x.name)):
            try:
                size = item.stat().st_size if item.is_file() else None
                result.append(FileInfo(name=item.name, is_dir=item.is_dir(), size=size))
            except PermissionError:
                continue

        return result

    def execute(self, command: str) -> ExecuteResponse:
        """Execute a bash command in local environment.

        Args:
            command: Command string to execute

        Returns:
            ExecuteResponse with output and exit code
        """
        try:
            from app.core.langgraph.tools import current_session_language, current_user_id

            env = os.environ.copy()
            user_id = current_user_id.get()
            if user_id:
                env["USER_ID"] = user_id

            session_lang = current_session_language.get()
            if session_lang:
                env["LANG"] = session_lang

            result = subprocess.run(  # nosec B602 B607
                command,
                shell=True,
                cwd=self.cwd,
                env=env,
                capture_output=True,
                text=True,
                timeout=30,
            )

            output = result.stdout
            if result.stderr:
                output += f"\nstderr:\n{result.stderr}"

            return ExecuteResponse(output=output, exit_code=result.returncode)

        except subprocess.TimeoutExpired:
            return ExecuteResponse(output="Error: Command execution timed out after 30 seconds", exit_code=124)
        except Exception as e:
            return ExecuteResponse(output=f"Error executing command: {str(e)}", exit_code=1)
