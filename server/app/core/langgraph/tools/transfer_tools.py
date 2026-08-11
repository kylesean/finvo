"""Transfer Tools

Two distinct tools, used at different stages of the transfer flow:

- ``prepare_transfer`` (LLM-visible, typed): lists the user's transfer-eligible
  (asset) accounts and produces the TransferWizard UI component. Replaces the
  old skill script — a well-defined operation should be a typed tool call, not
  an LLM-composed shell command.
- ``execute_transfer`` (internal, GenUI-only): executes a confirmed transfer.
  Requires source/target account IDs provided by the TransferWizard UI and is
  triggered via direct_execute, bypassing the LLM.
"""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any

from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from pydantic import BaseModel, Field, field_validator

from app.core.database import db_manager
from app.core.exceptions import to_client_error
from app.core.langgraph.tools._helpers import get_thread_id, get_user_uuid, parse_time
from app.core.logging import logger
from app.services.transaction_service import TransactionService
from app.services.transfer_prep_service import build_transfer_wizard_data


class PrepareTransferInput(BaseModel):
    """Input for prepare_transfer tool."""

    amount: float | None = Field(default=None, description="Transfer amount (optional; the wizard has an input field)")
    source_hint: str | None = Field(
        default=None,
        description="Keyword hint for the source account (its name or type), extracted from the user's message",
    )
    target_hint: str | None = Field(
        default=None,
        description="Keyword hint for the target account (its name or type), extracted from the user's message",
    )
    memo: str | None = Field(default=None, description="Optional transfer note/memo")
    tags: list[str] = Field(default_factory=list, description="Tags extracted from the user's message")
    currency: str | None = Field(default=None, description="Currency code (defaults to CNY)")


@tool("prepare_transfer", args_schema=PrepareTransferInput)
async def prepare_transfer(
    amount: float | None = None,
    source_hint: str | None = None,
    target_hint: str | None = None,
    memo: str | None = None,
    tags: list[str] | None = None,
    currency: str | None = None,
    *,
    config: RunnableConfig,
) -> dict[str, Any]:
    """Prepare an account-to-account transfer by producing the TransferWizard UI component.

    USE WHEN the user asks to transfer money between their own accounts. Lists
    the user's transfer-eligible (asset) accounts and optionally preselects the
    source/target based on hints from the user's message. The wizard collects
    the final source, target and amount from the user before execution.

    Never assume an account exists — pass only hints from the user's message.
    The wizard always shows the selectable accounts; if an account is not
    transfer-eligible it simply will not appear in the list.
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "message": "User not authenticated"}

    return await build_transfer_wizard_data(
        user_uuid=user_uuid,
        amount=amount,
        source_hint=source_hint,
        target_hint=target_hint,
        memo=memo,
        tags=tags or [],
        currency=currency,
    )


class ExecuteTransferInput(BaseModel):
    """Input for execute_transfer tool."""

    source_account_id: str = Field(..., description="ID of the source account (provided by UI)")
    target_account_id: str = Field(..., description="ID of the target account (provided by UI)")
    amount: str = Field(..., description="Transfer amount as a string, e.g. '100.00'")

    @field_validator("amount", mode="before")
    @classmethod
    def validate_amount(cls, v: Any) -> str:
        """Validate amount is a positive number.

        Values that round to zero at the 8-decimal precision (e.g. 1e-9) or
        below half the minimum precision are rejected instead of silently
        creating a 0-amount transaction.
        """
        if isinstance(v, (int, float, Decimal)):
            v = str(v)
        elif not isinstance(v, str):
            raise ValueError(f"Invalid amount type: {type(v)}")

        try:
            decimal_val = Decimal(v)
        except Exception as e:
            raise ValueError(f"Invalid amount format: {e}") from e
        if decimal_val <= 0:
            raise ValueError("Amount must be positive")
        rounded = f"{decimal_val:.8f}"
        if Decimal(rounded) <= 0:
            raise ValueError("Amount is too small (minimum 0.00000001)")
        return rounded

    memo: str = Field(default="", description="Optional transfer memo/note")
    raw_input: str | None = Field(
        default=None, description="Original user input text (e.g. '转账'), used as the transaction's raw input"
    )
    tags: list[str] = Field(
        default_factory=list,
        description="Tags generated by the LLM from the user's message (e.g. '转账'), stored on the transaction",
    )
    transaction_at: str | None = Field(
        default=None, description="Transaction time in ISO 8601 format (defaults to current time)"
    )
    surface_id: str | None = Field(default=None, description="GenUI surface ID for in-place updates")


@tool("execute_transfer", args_schema=ExecuteTransferInput)
async def execute_transfer(
    source_account_id: str,
    target_account_id: str,
    amount: str,
    memo: str = "",
    raw_input: str | None = None,
    tags: list[str] | None = None,
    transaction_at: str | None = None,
    surface_id: str | None = None,
    *,
    config: RunnableConfig,
) -> dict[str, Any]:
    """Execute a transfer between two accounts.

    IMPORTANT: This tool requires specific account IDs, which should be provided by the
    TransferWizard UI (prepared via the ``prepare_transfer`` tool). This tool is
    internal — triggered by direct_execute, never exposed to the LLM.
    """
    user_uuid = get_user_uuid(config)
    if not user_uuid:
        return {"success": False, "message": "User not authenticated"}

    # Validate account IDs
    if source_account_id == target_account_id:
        return {"success": False, "message": "Source and target accounts cannot be the same"}

    tx_time = parse_time(transaction_at)

    # Tags are LLM-generated from the user's message (like record_transactions),
    # carried through the TransferWizard. Fall back to the memo as a single tag
    # only when the LLM extracted nothing. Never hardcode an English tag.
    final_tags = tags or ([memo] if memo else [])

    async with db_manager.session_factory() as session:
        service = TransactionService(session)

        try:
            result = await service.create_transaction(
                user_uuid=user_uuid,  # Already UUID object
                amount=Decimal(amount),
                transaction_type="transfer",
                transaction_at=tx_time,
                category_key="GENERAL_TRANSFER",
                # Preserve the user's original input (e.g. "转账"); fall back to
                # the memo. Never hardcode an English fallback here.
                raw_input=raw_input or memo,
                source_account_id=uuid.UUID(source_account_id),
                target_account_id=uuid.UUID(target_account_id),
                tags=final_tags,
                source_thread_id=uuid.UUID(tid) if (tid := get_thread_id(config)) else None,
            )

            result["componentType"] = "TransferReceipt"
            return result

        except Exception as e:
            logger.error("execute_transfer_failed", error=str(e), exc_info=True)
            return {"success": False, "message": f"Transfer failed: {to_client_error(e)}"}


# Export: prepare_transfer is LLM-visible; execute_transfer stays internal
# (imported by name for the GenUI direct_execute registry).
transfer_tools = [prepare_transfer]
