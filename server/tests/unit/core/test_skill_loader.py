"""Skill loader cache + loud parse failures."""

import logging

from app.core.skills import loader as loader_module
from app.core.skills.loader import SkillLoader

_VALID_SKILL = """---
name: test-skill
description: A test skill.
---

# Test Skill
"""


def _write_skill(tmp_path, name: str = "demo", body: str = _VALID_SKILL) -> None:
    skill_dir = tmp_path / name
    skill_dir.mkdir()
    (skill_dir / "SKILL.md").write_text(body, encoding="utf-8")


class TestSkillLoaderCache:
    def test_second_load_skips_rescan(self, tmp_path, monkeypatch) -> None:
        _write_skill(tmp_path)
        loader = SkillLoader(str(tmp_path))

        first = loader.load_skills()
        assert [s.name for s in first] == ["test-skill"]

        # Break the parser: a cached second load must not even call it.
        monkeypatch.setattr(loader, "_parse_skill_md", lambda *a, **k: (_ for _ in ()).throw(AssertionError()))
        second = loader.load_skills()
        assert [s.name for s in second] == ["test-skill"]

    def test_edit_invalidates_cache(self, tmp_path) -> None:
        import os
        import time

        _write_skill(tmp_path)
        loader = SkillLoader(str(tmp_path))
        assert len(loader.load_skills()) == 1

        # mtime change (content identical) forces a rescan.
        skill_md = tmp_path / "demo" / "SKILL.md"
        new_mtime = time.time() + 5
        os.utime(skill_md, (new_mtime, new_mtime))
        assert len(loader.load_skills()) == 1
        # Cache was refreshed, not just bypassed: signature matches again.
        assert loader_module._scan_cache[str(tmp_path)][0] == loader_module._scan_signature(str(tmp_path), 2)


class TestSkillParseFailureIsLoud:
    def test_malformed_skill_logs_error_not_silent(self, tmp_path, caplog) -> None:
        _write_skill(tmp_path, body="---\nname: [unclosed\ndescription: x\n---\nbody\n")
        # Bypass the scan cache so the malformed file is actually parsed.
        loader_module._scan_cache.pop(str(tmp_path), None)
        with caplog.at_level(logging.ERROR, logger="app.core.skills.loader"):
            skills = SkillLoader(str(tmp_path)).load_skills()
        assert skills == []
        assert any("skill_parse_failed" in r.message for r in caplog.records)
