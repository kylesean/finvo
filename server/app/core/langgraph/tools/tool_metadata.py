"""Tool specs: routing and UI behavior per tool."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class ToolSpec:
    """Routing + UI behavior for one tool."""

    ends_turn: bool = False
    silent: bool = False
    cancellable: bool = True
    cancel_warning: str | None = None


TOOL_SPECS: dict[str, ToolSpec] = {
    "search_transactions": ToolSpec(),
    "list_financial_accounts": ToolSpec(),
    "prepare_transfer": ToolSpec(),
    "analyze_spending": ToolSpec(),
    "analyze_cashflow": ToolSpec(),
    "forecast_balance": ToolSpec(),
    "list_spaces": ToolSpec(),
    "query_space_summary": ToolSpec(),
    "query_budget_status": ToolSpec(),
    "execute": ToolSpec(silent=True),
    "bash": ToolSpec(silent=True),
    "read_file": ToolSpec(silent=True),
    "ls": ToolSpec(silent=True),
    "record_transactions": ToolSpec(
        ends_turn=True,
        cancellable=False,
        cancel_warning="Operation may have been executed, please check account balance",
    ),
    "create_budget": ToolSpec(
        ends_turn=True,
        cancellable=False,
        cancel_warning="Budget may have been created, please refresh to view",
    ),
    "execute_transfer": ToolSpec(
        ends_turn=True,
        silent=True,
        cancellable=False,
        cancel_warning="Transfer may have been executed, please check account balance",
    ),
    "associate_transactions_to_space": ToolSpec(
        ends_turn=True,
        silent=True,
        cancellable=False,
        cancel_warning="Association operation may have been executed",
    ),
    "write_file": ToolSpec(ends_turn=True, silent=True),
}


def get_spec(tool_name: str) -> ToolSpec | None:
    return TOOL_SPECS.get(tool_name)


def should_end_turn(tool_name: str) -> bool:
    spec = get_spec(tool_name)
    return spec.ends_turn if spec else False


def is_silent(tool_name: str) -> bool:
    spec = get_spec(tool_name)
    return spec.silent if spec else False


def is_cancellable(tool_name: str) -> bool:
    spec = get_spec(tool_name)
    return spec.cancellable if spec else False


def cancel_warning(tool_name: str) -> str | None:
    spec = get_spec(tool_name)
    return spec.cancel_warning if spec else None
