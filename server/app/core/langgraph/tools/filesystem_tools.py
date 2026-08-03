"""Filesystem Tools Module

Providing system tools via SimpleFilesystemBackend:
- ls: List directory contents
- read_file: Read file content
- write_file: Write to user artifact directory
- execute: Execute shell commands
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

from langchain_core.tools import BaseTool, tool
from pydantic import BaseModel, Field

from app.core.langgraph.tools.filesystem_backend import SimpleFilesystemBackend
from app.core.logging import logger

# Project root directory
PROJECT_ROOT = Path(__file__).parent.parent.parent.parent.parent

# Configure backend using custom SimpleFilesystemBackend
fs_backend = SimpleFilesystemBackend(root_dir=PROJECT_ROOT)

# Sensitive files that must never be exposed to the LLM through read/ls tools.
SENSITIVE_FILE_PATTERN = re.compile(
    r"(^|/)(\.env[^/]*|\.secrets\.baseline|\.git/.*|.*\.pem$|.*\.key$|.*\.p12$|"
    r"credentials[^/]*|.*secret[^/]*|.*token[^/]*|id_rsa.*|\.ssh/.*)$",
    re.IGNORECASE,
)

# Tool output guards: keep what reaches the LLM context bounded regardless of
# what the filesystem contains.
MAX_READ_CHARS = 50_000
MAX_LS_ENTRIES = 200
MAX_EXEC_OUTPUT_CHARS = 30_000
MAX_WRITE_CHARS = 512 * 1024


def _is_sensitive_path(path: str) -> bool:
    """Check whether a path targets sensitive files (env/secrets/keys)."""
    return bool(SENSITIVE_FILE_PATTERN.search(path.replace("\\", "/")))


# --- read_file ---
class ReadFileInput(BaseModel):
    """Input for reading a file."""

    path: str = Field(..., description="Path of the file to read")


@tool("read_file", args_schema=ReadFileInput)
def read_file_tool(path: str) -> str:
    """Read the content of a file (large files are truncated)."""
    if _is_sensitive_path(path):
        logger.warning("read_file_sensitive_blocked", path=path[:200])
        return "Error: reading this file is not allowed"
    try:
        content = fs_backend.read(path)
        if len(content) > MAX_READ_CHARS:
            omitted = len(content) - MAX_READ_CHARS
            return f"{content[:MAX_READ_CHARS]}\n\n... (truncated, {omitted} more chars)"
        return content
    except Exception as e:
        logger.warning("read_file_failed", path=path[:200], error=str(e))
        return "Error reading file"


# --- ls ---
class LsInput(BaseModel):
    """Input for listing directory contents."""

    path: str = Field(".", description="Directory path to list (defaults to current directory)")


@tool("ls", args_schema=LsInput)
def ls_tool(path: str = ".") -> str:
    """List directory contents (capped at a bounded number of entries)."""
    if _is_sensitive_path(path):
        logger.warning("ls_sensitive_blocked", path=path[:200])
        return "Error: listing this path is not allowed"
    try:
        items = fs_backend.ls_info(path)
        output = []
        for item in items:
            if _is_sensitive_path(f"{path}/{item.name}"):
                continue
            type_str = "DIR" if item.is_dir else "FILE"
            output.append(f"{type_str:4} {item.name}")
            if len(output) >= MAX_LS_ENTRIES:
                break
        if len(output) >= MAX_LS_ENTRIES:
            output.append(f"... (listing truncated at {MAX_LS_ENTRIES} entries)")
        return "\n".join(output)
    except Exception as e:
        logger.warning("ls_failed", path=path[:200], error=str(e))
        return "Error listing directory"


# --- write_file ---
class WriteFileInput(BaseModel):
    """Input for writing a file to the artifact directory."""

    path: str = Field(..., description="Relative path for the output file (e.g., 'landing-page.html')")
    content: str = Field(..., description="Content to write to the file")


@tool("write_file", args_schema=WriteFileInput)
def write_file_tool(path: str, content: str) -> Any:
    """Write content to a file in user's artifact directory.

    Files are automatically saved to: artifacts/{user_id}/{path}
    The URL to access the file will be returned.
    """
    from app.core.langgraph.tools import current_user_id

    try:
        user_id = current_user_id.get()
        if not user_id:
            return "Error: User ID not available"

        # Security: writes are sandboxed to artifacts/{user_id}. Reject absolute
        # paths, sensitive targets, and any path that resolves outside the
        # sandbox (e.g. "../../.env").
        if not path or Path(path).is_absolute():
            return "Error: path must be a relative path"
        if _is_sensitive_path(path):
            logger.warning("write_file_sensitive_blocked", path=path[:200])
            return "Error: writing this file is not allowed"
        if len(content) > MAX_WRITE_CHARS:
            return "Error: content too large to write"

        project_root = PROJECT_ROOT.resolve()
        user_artifact_dir = (project_root / "artifacts" / user_id).resolve()
        sandbox_path = (user_artifact_dir / path).resolve()

        # resolve() collapses ".." and symlinks, so a traversal attempt ends
        # up outside the sandbox and is rejected here.
        if not sandbox_path.is_relative_to(user_artifact_dir):
            logger.warning(
                "write_file_path_escape_blocked",
                user_id=user_id,
                path=path[:200],
            )
            return "Error: path escapes the artifact sandbox"

        sandbox_path.parent.mkdir(parents=True, exist_ok=True)
        # fs_backend.write re-resolves against project_root as a second barrier.
        fs_backend.write(str(sandbox_path.relative_to(project_root)), content)

        relative_path = str(sandbox_path.relative_to(project_root))
        access_url = f"/artifacts/{user_id}/{path}"
        return {
            "success": True,
            "message": f"Successfully wrote {len(content)} bytes",
            "path": relative_path,
            "url": access_url,
            "componentType": "artifact_link",
            "artifactUrl": access_url,
            "artifactName": Path(path).name,
        }
    except Exception as e:
        logger.warning("write_file_failed", path=path[:200], error=str(e))
        return "Error writing file"


# --- execute (bash) ---
class ExecuteInput(BaseModel):
    """Input for executing a bash command."""

    command: str = Field(..., description="The bash command to execute")


@tool("execute", args_schema=ExecuteInput)
def execute_tool(command: str) -> Any:
    """Execute a bash command (typically within the app/skills/ directory)."""
    response = fs_backend.execute(command)

    result_data = {"output": response.output, "exit_code": response.exit_code, "success": response.exit_code == 0}

    output = response.output

    # Find JSON payload boundaries
    first_brace = output.find("{")
    last_brace = output.rfind("}")

    if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
        json_candidate = output[first_brace : last_brace + 1]

        try:
            json_output = json.loads(json_candidate)
            if isinstance(json_output, dict):
                result_data.update(json_output)
                result_data["output"] = "(JSON parsed successfully)"
                logger.info(
                    "execute_tool_json_parsed",
                    has_component_type="componentType" in json_output,
                    component_type=json_output.get("componentType"),
                )
        except json.JSONDecodeError as e:
            logger.warning(
                "execute_tool_json_parse_failed",
                error=str(e),
                json_candidate_length=len(json_candidate),
            )
    else:
        logger.debug(
            "execute_tool_no_json_found",
            has_first_brace=first_brace != -1,
            has_last_brace=last_brace != -1,
        )

    # Bound the output that reaches the LLM context: scripts may print
    # arbitrarily much, and the model only needs the tail of a long output.
    # When a JSON payload was parsed, result_data["output"] is a short marker,
    # so only the raw (unparsed) output needs truncating.
    if result_data.get("output") == output and len(output) > MAX_EXEC_OUTPUT_CHARS:
        omitted = len(output) - MAX_EXEC_OUTPUT_CHARS
        result_data["output"] = f"... (truncated, {omitted} chars omitted)\n{output[-MAX_EXEC_OUTPUT_CHARS:]}"

    # Log script failures for observability (LLM decides retry based on error content)
    if response.exit_code != 0:
        logger.warning(
            "execute_tool_script_failed",
            command=command[:100],
            exit_code=response.exit_code,
            error_preview=(result_data.get("error", "") or output[:200]),
        )

    return result_data


# Exported filesystem tools
filesystem_tools: list[BaseTool] = [
    read_file_tool,
    ls_tool,
    write_file_tool,
    execute_tool,
]

tool_names = [t.name for t in filesystem_tools]
logger.debug("filesystem_tools_initialized", tools=tool_names)
