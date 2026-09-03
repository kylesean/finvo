"""Skill execution least-privilege tests (filesystem_backend.py).

Locks the H3 minimal hardening: child processes get a whitelisted env (never
the server's full environment), execution cwd is the skill's own directory
(not the project root), and output is redacted for credential-shaped content.
"""

import logging
import os
from pathlib import Path
from unittest.mock import patch

import pytest

from app.core.langgraph.tools.filesystem_backend import (
    SimpleFilesystemBackend,
    _redact_sensitive_output,
)
from app.core.skills.loader import SkillLoader

_VALID_CMD = "uv run python app/skills/reviewing-finances/scripts/report.py --month 2026-08"
_SKILL_NAME = "reviewing-finances"


@pytest.fixture()
def backend(tmp_path: Path) -> SimpleFilesystemBackend:
    """Backend rooted at a tmp tree with a real skill script on disk.

    The command validator requires the script file to actually exist
    (L3 check), so tests create the skill layout they reference.
    """
    script_dir = tmp_path / "app" / "skills" / _SKILL_NAME / "scripts"
    script_dir.mkdir(parents=True)
    (script_dir / "report.py").write_text("print('ok')\n", encoding="utf-8")
    return SimpleFilesystemBackend(root_dir=tmp_path)


def _fake_run(captured: dict) -> None:
    def _fake_subprocess_run(command, *args, **kwargs):
        captured["command"] = command
        captured["env"] = kwargs.get("env", {})
        captured["cwd"] = kwargs.get("cwd")

        class FakeResult:
            stdout = ""
            stderr = ""
            returncode = 0

        return FakeResult()

    return _fake_subprocess_run


def test_execute_env_is_whitelisted(backend):
    os.environ["OPENAI_API_KEY"] = "sk-should-not-leak-1234567890abcdef"
    os.environ["JWT_SECRET_KEY"] = "jwt-should-not-leak-1234567890abcdef"
    os.environ["PATH"] = "/usr/bin:/bin"
    captured: dict = {}

    with patch("subprocess.run", side_effect=_fake_run(captured)):
        backend.execute(_VALID_CMD)

    env = captured["env"]
    assert env["PATH"] == "/usr/bin:/bin"
    assert "OPENAI_API_KEY" not in env
    assert "JWT_SECRET_KEY" not in env
    assert "POSTGRES_PASSWORD" not in env


def test_execute_cwd_is_skill_directory_not_project_root(backend):
    captured: dict = {}

    with patch("subprocess.run", side_effect=_fake_run(captured)):
        backend.execute(_VALID_CMD)

    assert captured["cwd"] == (backend.root_dir / "app" / "skills" / _SKILL_NAME).resolve()


def test_execute_redacts_credential_shaped_output(backend):
    captured: dict = {}

    def _fake_run_with_output(command, *args, **kwargs):
        captured["env"] = kwargs.get("env", {})

        class FakeResult:
            stdout = (
                "SKILL OUTPUT OK\nOPENAI_API_KEY=sk-abcdefghijklmnopqrstuvwxyz123456\npassword: superSecret123456\n"
            )
            stderr = ""
            returncode = 0

        return FakeResult()

    with patch("subprocess.run", side_effect=_fake_run_with_output):
        response = backend.execute(_VALID_CMD)

    assert "sk-abcdefghijklmnopqrstuvwxyz123456" not in response.output
    assert "superSecret123456" not in response.output
    assert "SKILL OUTPUT OK" in response.output
    assert "[redacted]" in response.output


def test_execute_keeps_normal_output_untouched(backend):
    def _fake_run_with_output(command, *args, **kwargs):
        class FakeResult:
            stdout = '{"componentType":"table","rows":["groceries","dining"]}'
            stderr = ""
            returncode = 0

        return FakeResult()

    with patch("subprocess.run", side_effect=_fake_run_with_output):
        response = backend.execute(_VALID_CMD)

    assert response.output == '{"componentType":"table","rows":["groceries","dining"]}'


def test_redact_sensitive_output():
    text = (
        "key=sk-abcdefghijklmnopqrstuvwxyz123456 "
        "token=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U "
        "amount=45.00"
    )
    redacted = _redact_sensitive_output(text)
    assert "sk-abcdefghijklmnopqrstuvwxyz123456" not in redacted
    assert "eyJhbGciOiJIUzI1NiJ9" not in redacted
    assert "amount=45.00" in redacted


def test_skill_audit_log_fires_once_per_skill_set(caplog):
    global _logged_skills_signature
    _logged_skills_signature = None

    with caplog.at_level(logging.INFO, logger="app.core.logging"):
        loader = SkillLoader(skills_dir="app/skills")
        loader.load_skills()
        loader.load_skills()

    # Structured records funnel through the app.core.logging logger with the
    # event name and kwargs inside the msg dict (see app.core.logging).
    skill_records = [
        r
        for r in caplog.records
        if isinstance(r.msg, dict) and r.msg.get("event") == "skills_loaded"
    ]
    assert len(skill_records) == 1
    extras = skill_records[0].msg["extra"]
    assert extras["count"] == 4
    assert any("reviewing-finances" in s for s in extras["skills"])
