"""Skill loading tool following LangChain official Skills pattern.

This module implements the load_skill tool as per LangChain documentation:
https://docs.langchain.com/oss/python/langchain/multi-agent/skills-sql-assistant

The tool allows agents to progressively disclose skill content on-demand,
rather than loading everything upfront.
"""

from __future__ import annotations

from typing import Annotated

from langchain_core.messages import ToolMessage
from langchain_core.tools import InjectedToolCallId, tool
from langgraph.types import Command

from app.core.logging import logger
from app.core.skills.loader import SkillLoader

# Singleton skill loader instance
_skill_loader = SkillLoader()


@tool
def load_skill(
    skill_name: str,
    tool_call_id: Annotated[str, InjectedToolCallId],
) -> Command[str]:
    """Load specialized skill content into the conversation context.

    Use this tool when you need detailed instructions, schemas, or workflows
    for a specific domain. The skill will provide comprehensive guidance
    for handling the task.

    Args:
        skill_name: The EXACT ID string of the skill (e.g. 'reviewing-finances', 'forecasting-finances', 'managing-shared-ledgers', 'executing-transfers'). MUST match an ID from Available Skills. Do NOT pass script names or Chinese text.
        tool_call_id: Injected by LangGraph runtime, do not provide manually

    Returns:
        Command that updates state with skill content and tracks loaded skills
    """
    skill = _skill_loader.get_skill(skill_name)

    if not skill:
        # Provide clean guidance notice to LLM for self-correction
        available_skills = _skill_loader.load_skills()
        available_names = [s.name for s in available_skills]

        logger.warning(
            "skill_not_found",
            requested=skill_name,
            available=available_names,
        )

        return Command(
            update={
                "messages": [
                    ToolMessage(
                        content=f"Skill '{skill_name}' not found. Available skills: {available_names}",
                        tool_call_id=tool_call_id,
                    )
                ],
            }
        )

    # Build skill activation content
    skill_content = f"""<activated_skill name="{skill.name}">
{skill.content}
</activated_skill>

You have loaded the **{skill.name}** skill. Follow the instructions above for this task."""

    logger.info(
        "skill_loaded",
        skill=skill.name,
        allowed_tools=skill.allowed_tools,
    )

    # Return Command to update state
    return Command(
        update={
            "messages": [
                ToolMessage(
                    content=skill_content,
                    tool_call_id=tool_call_id,
                )
            ],
            # Track loaded skills for tool constraints
            "skills_loaded": [skill.name],
            # Set active skill for middleware constraints
            "active_skill": skill.name,
        }
    )


@tool
def unload_skill(
    tool_call_id: Annotated[str, InjectedToolCallId],
) -> Command[str]:
    """Leave the currently loaded skill and restore the full toolset.

    Call this tool when the user asks to stop using the loaded skill, switch to
    general-purpose assistance, or the skill is no longer relevant to the task.

    Args:
        tool_call_id: Injected by LangGraph runtime, do not provide manually

    Returns:
        Command that clears the active skill, lifting the tool whitelist
    """
    logger.info("skill_unloaded")

    # LangGraph skips channel updates whose value is None ("no update"), so the
    # empty string is the explicit "clear" marker: `_take_last_skill` stores it
    # verbatim and `_resolve_skill_tools` treats falsy active_skill as no skill.
    return Command(
        update={
            "messages": [
                ToolMessage(
                    content="Skill unloaded. The full toolset is available again.",
                    tool_call_id=tool_call_id,
                )
            ],
            "active_skill": "",
        }
    )


# Export as list for easy registration
skill_tools = [load_skill, unload_skill]
