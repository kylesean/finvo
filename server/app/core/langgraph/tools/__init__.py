"""Agent toolset: business tools, utilities, skills."""

from __future__ import annotations

from contextvars import ContextVar

from langchain_core.tools.base import BaseTool

from app.core.logging import logger

from .budget_tools import budget_tools
from .context import current_session_language, current_user_id

__all__ = ["current_session_language", "current_user_id", "tools", "business_tools", "utility_tools"]

from .analysis_tools import analysis_tools
from .duckduckgo_search import duckduckgo_search_tool
from .filesystem_tools import filesystem_tools
from .forecast_tools import forecast_tools
from .memory_tools import memory_tools
from .shared_space_tools import shared_space_tools
from .skill_tools import skill_tools
from .transaction_tools import transaction_tools as record_tools
from .transfer_tools import execute_transfer, transfer_tools

transaction_semantic_tools: list[BaseTool] = (
    record_tools + transfer_tools + analysis_tools + forecast_tools + shared_space_tools
)
business_tools: list[BaseTool] = transaction_semantic_tools + budget_tools
utility_tools: list[BaseTool] = [duckduckgo_search_tool]
tools: list[BaseTool] = utility_tools + business_tools + memory_tools + skill_tools

logger.debug("tools_loaded", llm_visible=len(tools))
