"""Transfer preparation service.

Builds the TransferWizard component data for the GenUI transfer flow: lists the
user's transfer-eligible (asset) accounts, resolves account hints by silent
unique preselection, and returns a friendly guidance state when transfers are
not possible. Used by the typed ``prepare_transfer`` tool.

This replaces the old skill script (``prepare_transfer.py``): preparing a
transfer is a well-defined operation, so it is a typed tool call instead of an
LLM-composed shell command.
"""

from __future__ import annotations

from typing import Any
from uuid import UUID

from app.core.database import db_manager
from app.services.account_service import AccountService


def fuzzy_match_account(accounts: list[Any], hint: str) -> list[str]:
    """Find account IDs that match the given hint (name or type)."""
    if not hint:
        return []

    hint = hint.lower().strip()
    matches = []

    for acc in accounts:
        name = acc.name.lower()
        acc_type = (acc.type or "").lower()
        # Match name or type
        if hint in name or hint in acc_type:
            matches.append(str(acc.uuid))

    return matches


async def build_transfer_wizard_data(
    user_uuid: UUID,
    amount: float | None = None,
    source_hint: str | None = None,
    target_hint: str | None = None,
    memo: str | None = None,
    tags: list[str] | None = None,
    currency: str | None = None,
) -> dict[str, Any]:
    """Build the TransferWizard component data (never fails on account issues).

    Returns a dict with camelCase keys for GenUI consistency:
    - Normal: ``success=true`` with the full asset-account lists and optional
      silent preselection (unique hint match only).
    - Insufficient accounts: ``success=true`` with empty lists plus a
      ``guidance`` code (``NO_ACCOUNTS`` / ``SINGLE_ACCOUNT``) so the UI renders
      a friendly guidance state instead of a failed tool call.
    """
    async with db_manager.session_factory() as session:
        account_service = AccountService(session)
        # Fetch ALL accounts (assets filtered here for more control)
        all_accounts = await account_service.list_user_accounts(user_uuid)

        # 1. Filter Asset Accounts Only
        asset_accounts = [acc for acc in all_accounts if acc.nature == "ASSET"]

        # 2. Eligibility check. Never fail the tool call here (a success:false
        # result surfaces a scary "operation failed" tool block); return
        # guidance so the UI shows a friendly empty state instead.
        guidance = None
        if not asset_accounts:
            guidance = "NO_ACCOUNTS"
        elif len(asset_accounts) == 1:
            guidance = "SINGLE_ACCOUNT"

        # 3. Format accounts for UI (empty when accounts are insufficient,
        # since the wizard then shows guidance instead of selectable lists).
        formatted_accounts = []
        if not guidance:
            for acc in asset_accounts:
                formatted_accounts.append(
                    {
                        "id": str(acc.uuid),
                        "name": acc.name,
                        "type": acc.type or "UNKNOWN",
                        "balance": float(acc.current_balance),
                        "currency": acc.currency_code or "CNY",
                    }
                )

        # 4. Silent preselection: only when a hint uniquely matches exactly one
        # account. Ambiguous or no match leaves the account unselected — the
        # wizard always shows the full list for the user to choose from.
        suggested_source_id = None
        suggested_target_id = None
        if not guidance:
            if source_hint:
                matches = fuzzy_match_account(asset_accounts, source_hint)
                if len(matches) == 1:
                    suggested_source_id = matches[0]
            if target_hint:
                matches = fuzzy_match_account(asset_accounts, target_hint)
                if len(matches) == 1:
                    suggested_target_id = matches[0]

        return {
            "success": True,
            "componentType": "TransferWizard",
            "sourceAccounts": formatted_accounts,
            "targetAccounts": formatted_accounts,
            "preselectedSourceId": suggested_source_id,
            "preselectedTargetId": suggested_target_id,
            "amount": max(0.0, float(amount or 0.0)),
            "memo": memo or "",
            "tags": tags or [],
            "currency": currency or "CNY",
            # Guidance code for the UI empty state: "NO_ACCOUNTS" |
            # "SINGLE_ACCOUNT", null when the wizard is fully usable.
            "guidance": guidance,
        }
