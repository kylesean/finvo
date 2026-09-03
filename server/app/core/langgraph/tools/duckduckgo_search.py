"""DuckDuckGo search tool for LangGraph.

This module provides a DuckDuckGo search tool that can be used with LangGraph
to perform web searches. It returns up to 10 search results and handles errors
gracefully.

Web results are untrusted data — the exported tool delimits its
output in an ``<untrusted_data source="web-search">`` block so result text
can never smuggle instructions into the context. The tool keeps the
upstream name (``duckduckgo_results_json``) so routing by name is unaffected.
"""

from langchain_community.tools import DuckDuckGoSearchResults
from langchain_core.tools import tool

from app.core.prompts.untrusted import wrap_untrusted

_raw_duckduckgo_search = DuckDuckGoSearchResults(num_results=10, handle_tool_error=True)


@tool("duckduckgo_results_json")
async def duckduckgo_search_tool(query: str) -> str:
    """Search the web with DuckDuckGo (results are untrusted data)."""
    raw = await _raw_duckduckgo_search.ainvoke({"query": query})
    return wrap_untrusted(str(raw), source="web-search")
