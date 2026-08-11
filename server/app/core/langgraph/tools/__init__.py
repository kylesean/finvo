"""Tools Module - LangGraph Agent Toolset

Architecture Design:
- LLM Visible Tools: record_transactions, search_transactions, prepare_transfer,
  analyze_spending, analyze_cashflow, forecast_balance, list_spaces,
  query_space_summary, budget, memory, load_skill
- Internal Tools: execute_transfer (GenUI callback execution only, not exposed to LLM)
- Privileged Tools: filesystem_tools (dynamically injected via state["filtered_tools"] when required)

Design Principles:
- Clear tool semantics for autonomous LLM selection
- Unified entry point: record_transactions supports batch mixed-type bookkeeping
- Transfers: prepare_transfer (typed tool) produces the TransferWizard; the UI
  collects account parameters, then execute_transfer runs via direct_execute
- Skills loaded on-demand via load_skill (official Progressive Disclosure pattern)
"""

from __future__ import annotations

from contextvars import ContextVar
from typing import Any

from langchain_core.tools.base import BaseTool

from app.core.logging import logger

from .budget_tools import budget_tools

# User identity and session language storage for request lifecycle
from .context import current_session_language, current_user_id

__all__ = [
    "current_session_language",
    "current_user_id",
    "tools",
    "business_tools",
    "utility_tools",
]
# Read-only domain analytics (typed; replace skill scripts)
from .analysis_tools import analysis_tools
from .duckduckgo_search import duckduckgo_search_tool
from .filesystem_tools import filesystem_tools
from .forecast_tools import forecast_tools
from .memory_tools import memory_tools
from .shared_space_tools import shared_space_tools

# Skills: load_skill tool for progressive disclosure
from .skill_tools import skill_tools

# Unified transaction tools (bookkeeping + queries)
from .transaction_tools import transaction_tools as record_tools
from .transfer_tools import (  # transfer_tools = [prepare_transfer] (LLM-visible); execute_transfer internal
    execute_transfer,
    transfer_tools,
)

# 1. LLM-visible business tools
# - record_transactions: record transactions (supports mixed-type batch)
# - search_transactions: query transactions
# - prepare_transfer: produce the TransferWizard (typed; replaces skill script)
# - analyze_spending / analyze_cashflow / forecast_balance / list_spaces /
#   query_space_summary: typed read-only analytics (replace skill scripts)
# Note: execute_transfer is excluded from this list; hidden from LLM
transaction_semantic_tools: list[BaseTool] = (
    record_tools + transfer_tools + analysis_tools + forecast_tools + shared_space_tools
)

# Business tools
business_tools: list[BaseTool] = transaction_semantic_tools + budget_tools

# 2. General utility tools
utility_tools: list[BaseTool] = [
    duckduckgo_search_tool,
]

# 3. DeepAgents filesystem tools (Privileged tools, dynamically injected via state["filtered_tools"] when required)
# Includes read_file, write_file, ls, execute

# 4. Default toolset exposed to LLM (for standard chat and bookkeeping)
# Includes load_skill for on-demand skill content loading
tools: list[BaseTool] = utility_tools + business_tools + memory_tools + skill_tools

# 5. Skill-exclusive tools (empty: domain operations are typed LLM-visible
# tools; skills only provide knowledge/instructions)
skill_exclusive_tools: dict[str, list[BaseTool]] = {}

# 6. Internal tools (hidden from LLM, used for GenUI callbacks only)
# execute_transfer is exported above for direct execution

logger.debug(
    "tools_loaded",
    llm_visible=len(tools),
    skill_exclusive=sum(len(v) for v in skill_exclusive_tools.values()),
    internal=1,  # execute_transfer
    total=len(tools) + sum(len(v) for v in skill_exclusive_tools.values()) + 1,
)
