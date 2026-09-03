from __future__ import annotations

import os
from dataclasses import dataclass

import yaml

from app.core.logging import logger

# Module-level scan cache: {skills_dir: (signature, skills)}. The signature
# is the sorted (path, mtime_ns) of every SKILL.md under the dir, so edits/
# additions invalidate automatically while repeated per-request loads (the
# loader is instantiated per agent turn) skip the walk + YAML parse.
_scan_cache: dict[str, tuple[tuple[tuple[str, int], ...], list[SkillMetadata]]] = {}


def _scan_signature(skills_dir: str, max_depth: int) -> tuple[tuple[str, int], ...] | None:
    """Collect (path, mtime) for every SKILL.md; None when the dir is missing."""
    if not os.path.exists(skills_dir):
        return None
    found: list[tuple[str, int]] = []

    def _walk(directory: str, depth: int) -> None:
        if depth > max_depth:
            return
        try:
            entries = os.listdir(directory)
        except PermissionError:
            return
        for item in entries:
            item_path = os.path.join(directory, item)
            if os.path.isdir(item_path):
                skill_md = os.path.join(item_path, "SKILL.md")
                if os.path.exists(skill_md):
                    try:
                        found.append((skill_md, os.stat(skill_md).st_mtime_ns))
                    except OSError:
                        pass
                else:
                    _walk(item_path, depth + 1)

    _walk(skills_dir, 0)
    return tuple(sorted(found))


# Module-level cache so the audit log fires once per distinct skill set
# (SkillLoader instances are created per-request/agent-turn).
_logged_skills_signature: tuple[tuple[str, str], ...] | None = None


def _log_skill_audit(skills: list[SkillMetadata]) -> None:
    """Log the loaded skill set once per distinct signature.

    The audit trail answers "what skills are running on this server and
    where did they come from" — the deployment-level trust record for the
    skills-as-trusted-code model (see filesystem_backend.py). Fires only
    when the set changes so per-request loader instances do not spam logs.
    """
    global _logged_skills_signature
    signature = tuple(sorted((skill.name, skill.location) for skill in skills))
    if signature == _logged_skills_signature:
        return
    _logged_skills_signature = signature
    logger.info(
        "skills_loaded",
        extra={
            "count": len(skills),
            "skills": [f"{name}@{location}" for name, location in signature],
        },
    )


@dataclass
class SkillMetadata:
    """Metadata representing a skill loaded from SKILL.md."""

    name: str
    description: str
    location: str
    license: str | None = None
    metadata: dict[str, str] | None = None
    allowed_tools: list[str] | None = None  # Tool whitelist for this skill
    content: str | None = None  # Full SKILL.md content (for activation injection)


class SkillLoader:
    """Loads skills metadata from SKILL.md files following AgentSkills standards."""

    def __init__(self, skills_dir: str = "app/skills"):
        self.skills_dir = skills_dir

    def load_skills(self, max_depth: int = 2) -> list[SkillMetadata]:
        """Load skills from skills directory, supporting nested directories.

        This allows for community skills in subdirectories like:
        - app/skills/finance-analyst/SKILL.md  (local skill)
        - app/skills/community/frontend-design/SKILL.md  (community skill)

        Results are cached on the directory's (path, mtime) signature, so
        per-request loader instances skip the walk + YAML parse until a
        SKILL.md is added, removed, or edited.

        Args:
            max_depth: Maximum depth to search for SKILL.md files (default: 2)
        """
        signature = _scan_signature(self.skills_dir, max_depth)
        if signature is None:
            _log_skill_audit([])
            return []
        cached = _scan_cache.get(self.skills_dir)
        if cached is not None and cached[0] == signature:
            return cached[1]

        skills: list[SkillMetadata] = []
        for skill_md, _mtime in signature:
            metadata = self._parse_skill_md(skill_md)
            if metadata:
                skills.append(metadata)
        skills = sorted(skills, key=lambda x: x.name)
        _scan_cache[self.skills_dir] = (signature, skills)
        _log_skill_audit(skills)
        return skills

    def _parse_skill_md(self, file_path: str) -> SkillMetadata | None:
        try:
            with open(file_path, encoding="utf-8") as f:
                content = f.read()

            # Simple YAML frontmatter extraction
            if content.startswith("---"):
                parts = content.split("---", 2)
                if len(parts) >= 3:
                    frontmatter_str = parts[1]
                    markdown_content = parts[2].strip()  # Extract Markdown body
                    data = yaml.safe_load(frontmatter_str)

                    # Use relative path for better LLM understanding and command construction
                    rel_path = os.path.relpath(file_path)

                    # Parse allowed-tools (AgentSkills.io specification)
                    # Official format: space-delimited string (e.g. "bash search").
                    # A YAML block list is equally common in hand-written skills;
                    # silently ignoring it used to leave the skill loaded but
                    # with NO privileged tools bound, with no hint anywhere.
                    # Reference: https://agentskills.io/specification#allowed-tools-field
                    allowed_tools_raw = data.get("allowed-tools")
                    allowed_tools: list[str] | None = None

                    if isinstance(allowed_tools_raw, str) and allowed_tools_raw.strip():
                        allowed_tools = allowed_tools_raw.split()
                    elif isinstance(allowed_tools_raw, list):
                        allowed_tools = [str(item).strip() for item in allowed_tools_raw if str(item).strip()]
                    elif allowed_tools_raw is not None:
                        logger.warning(
                            "skill_allowed_tools_unparsable",
                            location=rel_path,
                            type=type(allowed_tools_raw).__name__,
                        )

                    return SkillMetadata(
                        name=data.get("name", "unknown"),
                        description=data.get("description", ""),
                        location=rel_path,
                        license=data.get("license"),
                        metadata=data.get("metadata"),
                        allowed_tools=allowed_tools,
                        content=markdown_content,
                    )
            return None
        except Exception as e:
            # Loud failure: a malformed SKILL.md previously vanished without a
            # trace, leaving operators wondering why a skill never loads.
            # Still returns None (one bad skill must not crash the catalog).
            logger.error("skill_parse_failed", extra={"path": file_path, "error": str(e)})
            return None

    def get_catalog_xml(self) -> str:
        """Generates XML skill entries for system prompt injection.

        Returns skill entries without the outer <available_skills> wrapper,
        as the wrapper is defined in the system prompt template itself.

        This follows the AgentSkills.io specification:
        https://agentskills.io/integrate-skills#injecting-into-context
        """
        skills = self.load_skills()
        if not skills:
            return "    <!-- No skills available -->"

        xml_parts = []
        for skill in skills:
            xml_parts.append("    <skill>")
            xml_parts.append(f"      <name>{skill.name}</name>")
            xml_parts.append(f"      <description>{skill.description}</description>")
            xml_parts.append(f"      <location>{skill.location}</location>")
            # Optional: inject extra metadata if needed for routing
            if skill.metadata:
                for k, v in skill.metadata.items():
                    xml_parts.append(f"      <{k}>{v}</{k}>")
            xml_parts.append("    </skill>")

        return "\n".join(xml_parts)

    def get_skill(self, skill_name: str) -> SkillMetadata | None:
        """Get a skill by exact name."""
        skills = self.load_skills()
        if not skills or not skill_name:
            return None

        clean_name = skill_name.strip()
        for skill in skills:
            if skill.name == clean_name:
                return skill

        return None

    def activate_skill_prompt(self, skill_name: str) -> str | None:
        """Generate skill activation prompt fragment.

        Used for dynamic injection into conversation context,
        switching the AI to the specified skill mode.

        Returns:
            Full skill content (Markdown) wrapped in XML tags.
        """
        skill = self.get_skill(skill_name)
        if not skill or not skill.content:
            return None

        # Construct activation prompt
        activation_prompt = f"""<activated_skill name="{skill.name}">
{skill.content}
</activated_skill>

You have activated the **{skill.name}** skill. Follow the instructions above strictly.
"""
        return activation_prompt

    def get_allowed_tools(self, skill_name: str) -> list[str] | None:
        """Get the tool whitelist for a skill.

        Returns the allowed-tools list declared in SKILL.md.

        Returns:
            List of tool names, or None (no restrictions).
        """
        skill = self.get_skill(skill_name)
        if not skill or not skill.allowed_tools:
            return None

        # Return tool names directly (no mapping needed)
        return skill.allowed_tools
