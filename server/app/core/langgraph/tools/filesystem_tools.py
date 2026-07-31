"""Filesystem Tools Module

Providing system tools via SimpleFilesystemBackend:
- ls: List directory contents
- read_file: Read file content
- write_file: Write to user artifact directory
- execute: Execute shell commands
"""

from __future__ import annotations

import json
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


# --- read_file ---
class ReadFileInput(BaseModel):
    """Input for reading a file."""

    path: str = Field(..., description="Path of the file to read")


@tool("read_file", args_schema=ReadFileInput)
def read_file_tool(path: str) -> str:
    """Read the content of a file."""
    try:
        content = fs_backend.read(path)
        return content
    except Exception as e:
        return f"Error reading file: {str(e)}"


# --- ls ---
class LsInput(BaseModel):
    """Input for listing directory contents."""

    path: str = Field(".", description="Directory path to list (defaults to current directory)")


@tool("ls", args_schema=LsInput)
def ls_tool(path: str = ".") -> str:
    """List directory contents."""
    try:
        items = fs_backend.ls_info(path)
        output = []
        for item in items:
            type_str = "DIR" if item.is_dir else "FILE"
            output.append(f"{type_str:4} {item.name}")
        return "\n".join(output)
    except Exception as e:
        return f"Error listing directory: {str(e)}"


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

        # Build user artifact path
        user_artifact_dir = Path("artifacts") / user_id
        full_path = user_artifact_dir / path
        full_path.parent.mkdir(parents=True, exist_ok=True)

        relative_path = str(full_path)
        fs_backend.write(relative_path, content)

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
        return f"Error writing file: {str(e)}"


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
