"""Mapping helpers: Transaction ORM/DTO -> API response dict.

Centralizes the amount/currency display logic previously inlined in the
transaction router, so the router stays a thin orchestration layer. The output
shape is governed by :class:`app.schemas.transaction.TransactionResponse`
(camelCase aliases); these helpers build that shape from a Transaction model,
a ``TransactionItem`` DTO, or an already-formatted dict.
"""

from __future__ import annotations

from decimal import Decimal
from typing import Any

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.schemas.transaction import TransactionDisplayValue, TransactionResponse


def _get_attr(obj: Any, snake_case: str, camel_case: str | None = None) -> Any:
    """Get attribute from object or dict, supporting both snake_case and camelCase keys.

    Args:
        obj: The object or dict to extract value from
        snake_case: The snake_case attribute name (for ORM models)
        camel_case: Optional camelCase key name (for dicts), defaults to snake_case

    Returns:
        The attribute value or None
    """
    if camel_case is None:
        camel_case = snake_case
    if isinstance(obj, dict):
        # Explicit key-existence checks: `or`-fallback would silently drop
        # falsy values (0, "", False, []) and fall through to the other key.
        if camel_case in obj:
            return obj[camel_case]
        if snake_case in obj:
            return obj[snake_case]
        return None
    return getattr(obj, snake_case, None)


def _format_datetime(value: Any) -> Any:
    """Format a datetime value to ISO format string."""
    if hasattr(value, "isoformat"):
        return value.isoformat()
    return value


def _to_decimal(val: Any) -> Decimal:
    """Helper to convert float, int, str, or Decimal to Decimal safely."""
    if val is None:
        return Decimal("0.0")
    if isinstance(val, Decimal):
        return val
    return Decimal(str(val))


def _extract_amounts(tx: Any) -> tuple[Decimal, Decimal, str, Any]:
    """Extract amount-related fields from transaction as Decimal.

    Returns:
        Tuple of (amount_val, amount_original, original_currency, stored_exchange_rate)
    """
    raw_original = _get_attr(tx, "amount_original", "amountOriginal") or _get_attr(tx, "amount") or "0.0"
    amount_original = _to_decimal(raw_original)
    original_currency = _get_attr(tx, "currency") or PROJECT_DEFAULT_CURRENCY
    stored_exchange_rate = _get_attr(tx, "exchange_rate", "exchangeRate")
    amount_val = _to_decimal(_get_attr(tx, "amount") or "0.0")

    return amount_val, amount_original, original_currency, stored_exchange_rate


def transaction_to_dict(tx: Any, display_currency: str = PROJECT_DEFAULT_CURRENCY) -> dict[str, Any]:
    """Convert a transaction model/dict/DTO to a ``TransactionResponse``-shaped dict.

    Args:
        tx: Transaction object, dict, or TransactionItem
        display_currency: User's base currency

    Returns:
        Dictionary representation of the transaction with camelCase aliases
        (matches ``TransactionResponse`` serialization aliases).
    """
    from app.services.transaction_query_service import TransactionItem

    # Fast path: already formatted dict
    if isinstance(tx, dict) and ("userUuid" in tx or "display" in tx):
        return tx

    # Check if already converted by service layer
    is_already_converted = isinstance(tx, TransactionItem)

    # Extract core identifiers
    tx_id = str(_get_attr(tx, "id"))
    tx_type = str(_get_attr(tx, "type"))
    user_uuid = str(_get_attr(tx, "user_uuid", "userUuid"))

    # Extract amounts
    amount_val, amount_original, original_currency, stored_exchange_rate = _extract_amounts(tx)

    # Display original currency amount directly
    if not is_already_converted:
        amount_val = amount_original

    # Build typed Pydantic response model, then serialize with camelCase aliases
    response_model = TransactionResponse(
        id=tx_id,
        user_uuid=user_uuid,
        type=tx_type,
        amount=amount_val,
        currency=original_currency,
        amount_base=_to_decimal(_get_attr(tx, "amount") or "0.0"),
        base_currency=display_currency,
        amount_original=amount_original,
        original_currency=original_currency,
        exchange_rate=str(stored_exchange_rate) if stored_exchange_rate else None,
        category_key=_get_attr(tx, "category_key", "categoryKey"),
        description=_get_attr(tx, "description") or "",
        raw_input=_get_attr(tx, "raw_input", "rawInput") or "",
        transaction_at=_format_datetime(_get_attr(tx, "transaction_at", "transactionAt")),
        transaction_timezone=_get_attr(tx, "transaction_timezone", "transactionTimezone") or "Asia/Shanghai",
        created_at=_format_datetime(_get_attr(tx, "created_at", "createdAt")),
        tags=_get_attr(tx, "tags") or [],
        status=_get_attr(tx, "status") or "CLEARED",
        location=_get_attr(tx, "location"),
        source_account_id=str(_get_attr(tx, "source_account_id")) if _get_attr(tx, "source_account_id") else None,
        target_account_id=str(_get_attr(tx, "target_account_id")) if _get_attr(tx, "target_account_id") else None,
        display=TransactionDisplayValue.from_params(amount=amount_val, tx_type=tx_type, currency=original_currency),
    )

    return response_model.model_dump(by_alias=True)
