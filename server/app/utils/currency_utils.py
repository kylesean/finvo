"""Currency utilities for multi-currency support.

This module provides helper functions for currency conversion
and user display currency preferences.

Architecture (user-base-currency model):
- Each user's base currency is their ``financial_settings.primary_currency``.
- ``Transaction.amount`` stores the equivalent in the user's base currency.
- ``Transaction.exchange_rate`` is a snapshot: 1 unit of original currency = X units of base currency.
- Aggregations (SUM) operate directly on ``amount`` without real-time conversion.
"""

from __future__ import annotations

from decimal import Decimal
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants.currency import CURRENCY_SYMBOLS, SUPPORTED_CURRENCIES
from app.core.exceptions import BusinessError
from app.core.logging import logger

# Re-exported from the single source of truth (app.core.constants.currency) so callers
# importing these from currency_utils keep working without a second definition.
__all__ = [
    "BASE_CURRENCY",
    "get_user_base_currency",
    "get_user_display_currency",
    "convert_to_user_base",
    "convert_to_display_currency",
    "get_currency_symbol",
    "SUPPORTED_CURRENCIES",
]

# ---------------------------------------------------------------------------
# Deprecated: kept only for backward compatibility with exchange_rate_service
# internal USD-hub logic. Do NOT use in new code.
# ---------------------------------------------------------------------------
BASE_CURRENCY = "USD"


async def get_user_base_currency(db: AsyncSession, user_uuid: UUID) -> str:
    """Get user's base (primary) currency from financial settings.

    This is the Single Source of Truth for the user's ledger currency.
    All ``Transaction.amount`` values are denominated in this currency.

    Args:
        db: Database session
        user_uuid: User's UUID

    Returns:
        str: ISO 4217 currency code (falls back to USD)
    """
    from app.models.financial_settings import FinancialSettings
    from app.utils.currency_inference import FALLBACK_CURRENCY

    try:
        result = await db.execute(
            select(FinancialSettings.primary_currency).where(FinancialSettings.user_uuid == user_uuid)
        )
        currency = result.scalar_one_or_none()
        return currency or FALLBACK_CURRENCY
    except Exception as e:
        logger.warning(
            "get_user_base_currency_failed",
            user_uuid=str(user_uuid),
            error=str(e),
        )
        return FALLBACK_CURRENCY


# Alias: display currency IS the base currency in the new architecture.
get_user_display_currency = get_user_base_currency


async def convert_to_user_base(
    amount: Decimal,
    from_currency: str,
    user_base_currency: str,
) -> tuple[Decimal, Decimal]:
    """Convert an original amount to the user's base currency with a rate snapshot.

    Args:
        amount: Original amount (positive, in ``from_currency``)
        from_currency: ISO code of the original currency
        user_base_currency: User's base currency code

    Returns:
        Tuple of (base_amount, exchange_rate) where exchange_rate is
        "1 unit of from_currency = X units of user_base_currency".

    Raises:
        BusinessError: If the exchange rate is unavailable. Callers must not
            silently book the original amount at rate 1.0 — that would mislabel
            the currency in the ledger and corrupt aggregations.
    """
    if from_currency.upper() == user_base_currency.upper():
        return amount, Decimal("1.0")

    if amount == 0:
        return Decimal("0"), Decimal("1.0")

    try:
        from app.services.exchange_rate_service import exchange_rate_service

        rate = await exchange_rate_service.convert(
            amount=1.0,
            from_currency=from_currency,
            to_currency=user_base_currency,
        )

        if rate is not None:
            exchange_rate = Decimal(str(rate))
            base_amount = amount * exchange_rate
            return base_amount, exchange_rate

        raise BusinessError(
            f"Unable to get exchange rate from {from_currency} to {user_base_currency}, please try again later",
            "EXCHANGE_RATE_UNAVAILABLE",
        )

    except BusinessError:
        raise
    except Exception as e:
        logger.error(
            "convert_to_user_base_error",
            error=str(e),
            from_currency=from_currency,
            user_base_currency=user_base_currency,
        )
        raise BusinessError(
            f"Unable to get exchange rate from {from_currency} to {user_base_currency}, please try again later",
            "EXCHANGE_RATE_UNAVAILABLE",
        ) from e


async def convert_to_display_currency(
    amount: Decimal,
    from_currency: str,
    to_currency: str,
) -> Decimal:
    """Convert amount from one currency to another (general-purpose).

    Args:
        amount: Amount to convert
        from_currency: Source currency code
        to_currency: Target currency code

    Returns:
        Decimal: Converted amount (original if conversion fails)
    """
    if from_currency.upper() == to_currency.upper():
        return amount

    try:
        from app.services.exchange_rate_service import exchange_rate_service

        converted = await exchange_rate_service.convert(
            amount=float(amount),
            from_currency=from_currency,
            to_currency=to_currency,
        )

        if converted is not None:
            return Decimal(str(converted))

        logger.warning(
            "currency_conversion_failed",
            from_currency=from_currency,
            to_currency=to_currency,
            amount=str(amount),
        )
        return amount

    except Exception as e:
        logger.error(
            "currency_conversion_error",
            error=str(e),
            from_currency=from_currency,
            to_currency=to_currency,
        )
        return amount


def get_currency_symbol(currency_code: str) -> str:
    """Get currency symbol for display.

    Args:
        currency_code: ISO 4217 currency code

    Returns:
        str: Currency symbol (falls back to the code itself if unknown)
    """
    return CURRENCY_SYMBOLS.get(currency_code.upper(), currency_code)
