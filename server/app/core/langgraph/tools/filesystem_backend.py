"""Minimal filesystem backend with command validation.

Provides basic file operations (read, write, ls_info) and validated shell command
execution for LangGraph tools and skills.
"""

from __future__ import annotations

import logging
import os
import re
import subprocess  # nosec B404
from dataclasses import dataclass
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

# Environment allowlist for skill script execution.
#
# Trust model: skills are installed by the deployer and their scripts are
# treated as trusted code — no OS-level sandbox (container/seccomp) is an
# intentional trade-off for the self-hosted home-deployment scenario, where
# sandbox complexity would outweigh the threat it mitigates (see the
# SimpleFilesystemBackend docstring). But scripts do NOT inherit the full
# server environment: a bare `os.environ.copy()` would hand every API key,
# JWT secret and DB password to any script that runs. Exposing only what a
# script plausibly needs implements least privilege without a sandbox.
_EXEC_ENV_ALLOWLIST: tuple[str, ...] = ("PATH", "HOME", "LANG", "LC_ALL", "TZ", "USER_ID")

# Content-level redaction for execute() output. Path-based guards (SENSITIVE_FILE_PATTERN)
# cannot help here: scripts print VALUES, not paths. The pattern targets
# high-entropy credential shapes and key=value assignments with long values;
# it is deliberately conservative to avoid mangling legitimate financial text.
_SENSITIVE_OUTPUT_PATTERN: re.Pattern[str] = re.compile(
    r"sk-[A-Za-z0-9_-]{20,}"  # OpenAI-compatible API keys
    r"|AKIA[0-9A-Z]{16}"  # AWS access key IDs
    r"|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"  # JWTs
    r"|-----BEGIN [A-Z ]*PRIVATE KEY-----"  # PEM private key blocks
    r"|(password|passwd|secret|api[_-]?key|access[_-]?key|token)\s*[=:]\s*[\"']?[A-Za-z0-9+/=_-]{16,}",
    re.IGNORECASE,
)
_SENSITIVE_REDACTION = "[redacted]"


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


# ============================================================================
# Command Validator (Defense-in-Depth)
# ============================================================================

# Dangerous commands that should never be executed
BLOCKED_COMMANDS: set[str] = {
    "rm",
    "rmdir",
    "mkfs",
    "dd",
    "curl",
    "wget",
    "nc",
    "ncat",
    "socat",
    "pip",
    "pip3",
    "npm",
    "yarn",
    "gem",
    "cargo",
    "chmod",
    "chown",
    "chgrp",
    "mount",
    "umount",
    "kill",
    "killall",
    "pkill",
    "shutdown",
    "reboot",
    "halt",
    "useradd",
    "userdel",
    "passwd",
    "su",
    "sudo",
    "ssh",
    "scp",
    "rsync",
    "ftp",
    "sftp",
    "telnet",
    "iptables",
    "ufw",
    "systemctl",
    "service",
    "crontab",
    "at",
    "eval",
    "exec",
    "docker",
    "podman",
    "kubectl",
}

# Shell metacharacters that enable command chaining/injection
SHELL_INJECTION_PATTERN: re.Pattern[str] = re.compile(
    r"[\n&;`]"  # newline, single &, semicolon, backtick
    r"|&&"  # logical AND chaining
    r"|\|\|"  # logical OR chaining
    r"|\$\("  # command substitution $(...)
    r"|\$\{"  # variable expansion ${...}
    r"|<"  # input redirection
    r"|>\s*/"  # redirect to absolute path
    r"|>>"  # append redirect
)

# Allowed pipe pattern: echo '...' | uv run python ...
# The echo payload is restricted to single-quoted text whose characters are
# safe inside a shell (no quotes, backslash, $, backtick, chaining/redirection
# metacharacters). This prevents quote-closing + command substitution attacks
# like: echo ''$(whoami)'' | uv run python ...  (would otherwise pass a
# naive `.*` match and execute $(whoami)).
# An argument to a skill script: either a bare token free of shell
# metacharacters, or a single/double-quoted literal. Quoted arguments are
# accepted because LLMs naturally quote string args (e.g. `--target_hint
# "信用卡"`); the content rules still forbid `$`, backtick, backslash and
# chaining/redirection metacharacters, so no command substitution or
# quote-closing injection is possible inside the quotes.
_SAFE_BARE_ARG: str = r"[^\s;&|<>`\"'\$\\]+"
_SAFE_DQ_ARG: str = r'"[^"`\$\\;&|<>]*"'  # double-quoted literal
_SAFE_SQ_ARG: str = r"'[^'`\$\\;&|<>]*'"  # single-quoted literal
_COMMAND_ARG: str = rf"(?:{_SAFE_BARE_ARG}|{_SAFE_DQ_ARG}|{_SAFE_SQ_ARG})"

ALLOWED_PIPE_PATTERN: re.Pattern[str] = re.compile(
    r"^echo\s+'[^'\\$`;&|<>]*'\s*\|\s*uv\s+run\s+python\s+"
    r"app/skills/[\w-]+/scripts/[\w-]+\.py"
    rf"(?:\s+{_COMMAND_ARG})*$"
)

# Core allowlist pattern: uv run python app/skills/<name>/scripts/<script>.py [args...]
# Anchored with fullmatch semantics: no trailing garbage, and every argument
# must be a bare token or a quoted literal free of injection metacharacters.
ALLOWED_COMMAND_PATTERN: re.Pattern[str] = re.compile(
    r"^uv\s+run\s+python\s+app/skills/[\w-]+/scripts/[\w-]+\.py"
    rf"(?:\s+{_COMMAND_ARG})*$"
)


@dataclass
class ValidationResult:
    """Result of command validation."""

    allowed: bool
    reason: str = ""
    level: str = ""  # Which defense layer caught it


class CommandValidator:
    """Validates commands against a multi-layer allowlist policy.

    Defense layers:
    - L1: Dangerous command blocklist
    - L2: Command structure allowlist (must match uv run python app/skills/...)
    - L3: Script path existence check
    - L4: Shell injection metacharacter detection
    """

    def __init__(self, project_root: Path):
        self.project_root = project_root

    def validate(self, command: str) -> ValidationResult:
        """Validate a command through all defense layers.

        Args:
            command: Raw command string from LLM

        Returns:
            ValidationResult with allowed=True if safe to execute
        """
        command = command.strip()

        if not command:
            return ValidationResult(allowed=False, reason="Empty command", level="L0")

        # Reject multi-line commands outright (newlines enable chaining regardless
        # of what the rest of the validation says).
        if "\n" in command:
            return ValidationResult(allowed=False, reason="Multi-line command detected", level="L4")

        # Determine if this is a piped command (echo '...' | uv run python ...)
        is_piped = "|" in command
        if is_piped:
            return self._validate_piped_command(command)

        return self._validate_simple_command(command)

    def _validate_simple_command(self, command: str) -> ValidationResult:
        """Validate a non-piped command."""
        # L4: Shell injection detection (before anything else)
        injection = SHELL_INJECTION_PATTERN.search(command)
        if injection:
            return ValidationResult(
                allowed=False,
                reason=f"Shell injection detected: '{injection.group()}'",
                level="L4",
            )

        # L1: Dangerous command blocklist
        first_word = command.split()[0].lower() if command.split() else ""
        if first_word in BLOCKED_COMMANDS:
            return ValidationResult(
                allowed=False,
                reason=f"Blocked command: '{first_word}'",
                level="L1",
            )

        # L2: Command structure allowlist (fullmatch: no trailing garbage allowed)
        if not ALLOWED_COMMAND_PATTERN.fullmatch(command):
            return ValidationResult(
                allowed=False,
                reason=f"Command does not match allowlist pattern: '{command[:80]}'",
                level="L2",
            )

        # L3: Script path existence check
        return self._validate_script_path(command)

    def _validate_piped_command(self, command: str) -> ValidationResult:
        """Validate a piped command (echo '...' | uv run python ...)."""
        # L4: Only allow the specific echo pipe pattern (fullmatch: no trailing garbage)
        if not ALLOWED_PIPE_PATTERN.fullmatch(command):
            return ValidationResult(
                allowed=False,
                reason=f"Pipe command does not match allowlist: '{command[:80]}'",
                level="L4",
            )

        # Extract the part after the pipe for further validation
        pipe_idx = command.index("|")
        right_side = command[pipe_idx + 1 :].strip()

        # L1: Check blocked commands on right side
        first_word = right_side.split()[0].lower() if right_side.split() else ""
        if first_word in BLOCKED_COMMANDS:
            return ValidationResult(
                allowed=False,
                reason=f"Blocked command in pipe: '{first_word}'",
                level="L1",
            )

        # L2: Right side must match allowed pattern (fullmatch)
        if not ALLOWED_COMMAND_PATTERN.fullmatch(right_side):
            return ValidationResult(
                allowed=False,
                reason=f"Piped command does not match allowlist: '{right_side[:80]}'",
                level="L2",
            )

        # L3: Script path existence check on right side
        return self._validate_script_path(right_side)

    def _validate_script_path(self, command_part: str) -> ValidationResult:
        """Extract and validate the script path from a command.

        Args:
            command_part: The 'uv run python app/skills/...' portion
        """
        # Extract path: "uv run python <path> [args...]"
        parts = command_part.split()
        if len(parts) < 4:
            return ValidationResult(
                allowed=False,
                reason="Command too short to contain a valid script path",
                level="L3",
            )

        script_path = parts[3]  # "app/skills/<name>/scripts/<script>.py"

        # Ensure it's a .py file under app/skills/
        if not script_path.startswith("app/skills/") or not script_path.endswith(".py"):
            return ValidationResult(
                allowed=False,
                reason=f"Script path not in app/skills/: '{script_path}'",
                level="L3",
            )

        # Verify file actually exists on disk
        full_path = (self.project_root / script_path).resolve()
        if not full_path.exists():
            return ValidationResult(
                allowed=False,
                reason=f"Script file does not exist: '{script_path}'",
                level="L3",
            )

        # Verify resolved path is still within project root (prevent symlink attacks)
        if not full_path.is_relative_to(self.project_root):
            return ValidationResult(
                allowed=False,
                reason=f"Script path escapes project root: '{script_path}'",
                level="L3",
            )

        return ValidationResult(allowed=True)


# ============================================================================
# Filesystem Backend
# ============================================================================


class SimpleFilesystemBackend:
    """Minimal filesystem backend for Skills and File operations.

    Provides:
    - read(): Read file content
    - write(): Write file content
    - ls_info(): List directory contents
    - execute(): Execute validated shell commands

    Security model for ``execute``: skill scripts are trusted code installed
    by the deployer (the self-hosted home scenario does not warrant an
    OS-level sandbox — see the module-level env allowlist comment). The
    mitigations in place are therefore least-privilege, not isolation:
    1. Commands must match a strict allowlist (only ``uv run python
       app/skills/<name>/scripts/<script>.py``).
    2. Child processes get a whitelisted env, never the server's full
       environment.
    3. Execution cwd is the skill's own directory, not the project root.
    4. Output is redacted for credential-shaped content before it can reach
       the LLM/UI.

    If community-skill one-click installation is ever introduced (i.e. skills
    no longer personally installed/reviewed by the deployer), an actual
    sandbox (container/WASI) MUST be added before that ships.
    """

    def __init__(self, root_dir: Path | str):
        """Initialize with root directory.

        Args:
            root_dir: Base directory for all operations
        """
        self.root_dir = Path(root_dir).resolve()
        self.cwd = self.root_dir
        self._validator = CommandValidator(self.root_dir)

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
            try:
                path_obj = path_obj.relative_to(self.root_dir)
            except ValueError:
                path_obj = Path(str(path).lstrip("/"))

        full_path = (self.root_dir / path_obj).resolve()

        if not full_path.is_relative_to(self.root_dir):
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
        """Execute a validated bash command in local environment.

        Commands are validated against a multi-layer allowlist before execution.
        Only skill scripts under app/skills/ are permitted.

        Args:
            command: Command string to execute

        Returns:
            ExecuteResponse with output and exit code (126 if blocked)
        """
        # Validate command before execution
        validation = self._validator.validate(command)
        if not validation.allowed:
            logger.warning(
                "command_blocked",
                extra={
                    "command": command[:100],
                    "reason": validation.reason,
                    "level": validation.level,
                },
            )
            return ExecuteResponse(
                output=f"Command blocked by security policy [{validation.level}]: {validation.reason}",
                exit_code=126,
            )

        try:
            from app.core.langgraph.tools import current_session_language, current_user_id

            # Least privilege: only whitelisted vars reach the child process.
            # Anything the script truly needs must be passed explicitly (e.g.
            # USER_ID below); the server's API keys / JWT / DB credentials are
            # never inherited. See _EXEC_ENV_ALLOWLIST for the rationale.
            env = {name: os.environ[name] for name in _EXEC_ENV_ALLOWLIST if name in os.environ}
            user_id = current_user_id.get()
            if user_id:
                env["USER_ID"] = user_id

            session_lang = current_session_language.get()
            if session_lang:
                env["LANG"] = session_lang

            # Run from the skill's own directory so relative paths in scripts
            # resolve inside the skill, not the project root (where .env and
            # server sources live). The command allowlist keeps the script
            # path anchored to app/skills/, so this is not attacker-influenced.
            exec_cwd = self._skill_dir_for_command(command) or self.cwd

            result = subprocess.run(  # nosec B602 B607
                command,
                shell=True,
                cwd=exec_cwd,
                env=env,
                capture_output=True,
                text=True,
                timeout=30,
            )

            output = _redact_sensitive_output(result.stdout)
            if result.stderr:
                output += f"\nstderr:\n{_redact_sensitive_output(result.stderr)}"

            return ExecuteResponse(output=output, exit_code=result.returncode)

        except subprocess.TimeoutExpired:
            return ExecuteResponse(output="Error: Command execution timed out after 30 seconds", exit_code=124)
        except Exception as e:
            logger.warning("command_execution_error: %s", e)
            return ExecuteResponse(output="Error executing command", exit_code=1)

    def _skill_dir_for_command(self, command: str) -> Path | None:
        """Extract the skill directory from a validated command, if any.

        Returns the resolved ``app/skills/<name>`` directory for the script
        referenced by ``command``, or None when the command does not target a
        skill script. The command has already passed the allowlist at this
        point, so the extracted path is trusted to live under the project
        root; the containment check below is a belt-and-suspenders guard
        against future allowlist drift.
        """
        match = re.search(r"app/skills/([\w-]+)/scripts/", command)
        if not match:
            return None
        skill_dir = (self.root_dir / "app" / "skills" / match.group(1)).resolve()
        if not skill_dir.is_relative_to(self.root_dir):
            return None
        return skill_dir


def _redact_sensitive_output(text: str) -> str:
    """Redact credential-shaped content from script output.

    Guards the LLM/UI from absorbing secrets a script might print (e.g. a
    debug print of an environment variable). Path-level guards do not apply
    here because scripts emit values, not paths.
    """
    return _SENSITIVE_OUTPUT_PATTERN.sub(_SENSITIVE_REDACTION, text)
