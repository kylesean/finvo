"""Skill Middleware following LangChain official Skills pattern.

This middleware implements progressive skill disclosure as per LangChain docs:
https://docs.langchain.com/oss/python/langchain/multi-agent/skills

Key responsibilities:
1. Inject skill catalog (name + description) into system prompt
2. Register the load_skill tool for on-demand skill loading

Note: tool scoping when a skill is active is resolved by the agent node
(see app.core.langgraph.agent.nodes._resolve_skill_tools), not here.
"""

from __future__ import annotations

from typing import Any

from langchain_core.messages import BaseMessage, SystemMessage

from app.core.langgraph.middleware.base import BaseMiddleware
from app.core.logging import logger
from app.core.skills.loader import SkillLoader


class SkillMiddleware(BaseMiddleware):
    """Middleware that implements LangChain's official Skills pattern.

    This middleware:
    1. Injects skill descriptions into the system prompt (progressive disclosure)
    2. Tracks skill state through before_invoke/after_invoke hooks

    The actual skill loading and tool scoping are handled elsewhere:
    - load_skill tool updates the agent state with skills_loaded/active_skill
    - the agent node derives the scoped toolset from active_skill
    """

    def __init__(self) -> None:
        """Initialize skill middleware with skill catalog."""
        self._skill_loader = SkillLoader()
        self._skills_prompt: str | None = None

        # Pre-build skills prompt
        self._build_skills_catalog()

    def _build_skills_catalog(self) -> None:
        """Build the skills catalog for system prompt injection."""
        skills = self._skill_loader.load_skills()

        if not skills:
            self._skills_prompt = None
            return

        # Build skill list for system prompt
        skills_list = [f"- ID: `{skill.name}` | Description: {skill.description}" for skill in skills]

        self._skills_prompt = "\n".join(skills_list)

        logger.info(
            "skill_middleware_initialized",
            skill_count=len(skills),
        )

    @property
    def name(self) -> str:
        """Middleware identifier."""
        return "skill"

    async def before_invoke(
        self,
        messages: list[BaseMessage],
        config: dict[str, Any],
    ) -> tuple[list[BaseMessage], dict[str, Any]]:
        """Inject skill catalog into system prompt."""
        if not self._skills_prompt:
            return messages, config

        # Build skills addendum for system prompt
        skills_addendum = f"""

## Available Skills

{self._skills_prompt}

IMPORTANT RULE FOR `load_skill`:
When calling `load_skill`, you MUST set `skill_name` EXACTLY to one of the ID strings listed above (e.g., `reviewing-finances`). Do NOT pass script names (like `analyze_spending.py`) or Chinese translated text."""

        # Find and update system message, or insert new one
        updated_messages = list(messages)
        system_found = False

        for i, msg in enumerate(updated_messages):
            if isinstance(msg, SystemMessage):
                # Append skills section to existing system message. Guard against
                # re-appending on retries/resumes where the addendum is already
                # present — each turn's copy is also persisted into the checkpoint.
                existing_content = msg.content
                if isinstance(existing_content, str):
                    if skills_addendum not in existing_content:
                        updated_messages[i] = SystemMessage(content=existing_content + skills_addendum)
                system_found = True
                break

        if not system_found and updated_messages:
            # No system message found, this shouldn't happen with proper setup
            logger.warning("skill_middleware_no_system_message")

        return updated_messages, config

    async def after_invoke(
        self,
        result: dict[str, Any],
        config: dict[str, Any],
    ) -> dict[str, Any]:
        """Check for skill activation and log state.

        The actual skill loading and state updates are handled by the
        load_skill tool via Command. This hook is for logging and
        potential post-processing.
        """
        # Log if a skill was activated in this invocation
        if "active_skill" in result and result.get("active_skill"):
            active_skill = result["active_skill"]
            skills_loaded = result.get("skills_loaded", [])

            logger.info(
                "skill_activated_in_invocation",
                active_skill=active_skill,
                skills_loaded=skills_loaded,
            )

        return result
