"""Exchange rate API endpoints.

This module provides API endpoints for managing and accessing exchange rate data.
"""

from __future__ import annotations

from decimal import Decimal
from typing import Any

from fastapi import APIRouter, Path, Request, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from app.core.aliases import CurrentUser
from app.core.config import settings
from app.core.limiter import limiter
from app.core.logging import logger
from app.core.responses import ResponseEnvelope, error_response, get_error_code_int, success_response
from app.services.exchange_rate_service import exchange_rate_service

router = APIRouter(prefix="/exchange-rates", tags=["Exchange Rates"])


class ExchangeRateResponse(BaseModel):
    """Exchange rate data response model."""

    base_code: str = Field(description="Base currency code (e.g., USD)")
    last_update_utc: str | None = Field(default=None, description="Last update time in UTC")
    cached_at: str | None = Field(default=None, description="When the data was cached")
    conversion_rates: dict[str, float] = Field(description="Exchange rates for supported currencies")


class ConversionRequest(BaseModel):
    """Currency conversion request model."""

    amount: Decimal = Field(ge=0, description="Amount to convert")
    from_currency: str = Field(min_length=3, max_length=3, description="Source currency code")
    to_currency: str = Field(min_length=3, max_length=3, description="Target currency code")


class ConversionResponse(BaseModel):
    """Currency conversion response model."""

    original_amount: Decimal = Field(description="Original amount")
    from_currency: str = Field(description="Source currency code")
    to_currency: str = Field(description="Target currency code")
    converted_amount: Decimal = Field(description="Converted amount")
    rate: Decimal = Field(description="Exchange rate used for conversion")


@router.get("", response_model=ResponseEnvelope[ExchangeRateResponse])
async def get_exchange_rates(
    _: CurrentUser,
) -> JSONResponse:
    """Get cached exchange rates.

    Returns the latest cached exchange rate data from Redis.
    The data is updated daily at 08:00 Beijing Time (00:00 UTC).

    Returns:
        Response containing exchange rate data
    """
    logger.info("get_exchange_rates_requested")

    data = await exchange_rate_service.get_cached_rates()

    if data is None:
        # Try to fetch fresh data if cache is empty
        logger.info("exchange_rate_cache_empty_fetching")
        await exchange_rate_service.update_cache()
        data = await exchange_rate_service.get_cached_rates()

    if data is None:
        return error_response(
            code=get_error_code_int("SERVER_ERROR"),
            message="Exchange rate data is not available",
            data=None,
            http_status=status.HTTP_503_SERVICE_UNAVAILABLE,
        )

    return success_response(data=data)


@router.get("/rate/{currency}", response_model=ResponseEnvelope[dict[str, Any]])
async def get_single_rate(
    _: CurrentUser,
    currency: str = Path(..., min_length=3, max_length=3, pattern=r"^[A-Za-z]{3}$"),
) -> JSONResponse:
    """Get exchange rate for a specific currency.

    Args:
        currency: Target currency code (e.g., CNY, EUR, JPY)

    Returns:
        Response containing the exchange rate for the specified currency
    """
    currency = currency.upper()
    logger.info("get_single_rate_requested", currency=currency)

    rate = await exchange_rate_service.get_rate(currency)

    if rate is None:
        return error_response(
            code=get_error_code_int("NOT_FOUND"),
            message=f"Exchange rate for {currency} is not available",
            data=None,
            http_status=status.HTTP_404_NOT_FOUND,
        )

    return success_response(
        data={
            "base": "USD",
            "target": currency,
            "rate": rate,
        }
    )


@router.post("/convert", response_model=ResponseEnvelope[ConversionResponse])
async def convert_currency(
    request: ConversionRequest,
    _: CurrentUser,
) -> JSONResponse:
    """Convert amount between currencies.

    Args:
        request: Conversion request containing amount, source and target currencies

    Returns:
        Response containing conversion result
    """
    logger.info(
        "currency_conversion_requested",
        amount=request.amount,
        from_currency=request.from_currency,
        to_currency=request.to_currency,
    )

    converted_amount = await exchange_rate_service.convert(
        amount=request.amount,
        from_currency=request.from_currency,
        to_currency=request.to_currency,
    )

    if converted_amount is None:
        # Distinguish "provider data unavailable" (server-side, 503) from
        # "unknown currency code" (client-side, 400) so the error code actually
        # guides the retry direction.
        data = await exchange_rate_service.get_cached_rates()
        if data is None:
            return error_response(
                code=get_error_code_int("SERVER_ERROR"),
                message="Exchange rate data is unavailable, please try again later",
                data=None,
                http_status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        return error_response(
            code=get_error_code_int("VALIDATION_ERROR"),
            message=f"Unsupported currency code: {request.from_currency}/{request.to_currency}",
            data=None,
            http_status=status.HTTP_400_BAD_REQUEST,
        )

    # Calculate the effective rate
    if request.amount > 0:
        effective_rate = converted_amount / request.amount
    else:
        effective_rate = Decimal("0.0")

    return success_response(
        data={
            "original_amount": request.amount,
            "from_currency": request.from_currency.upper(),
            "to_currency": request.to_currency.upper(),
            "converted_amount": converted_amount,
            "rate": round(effective_rate, 6),
        }
    )


@router.post("/refresh", response_model=ResponseEnvelope[ExchangeRateResponse])
@limiter.limit("1 per minute")
async def refresh_exchange_rates(
    request: Request,
    _: CurrentUser,
) -> JSONResponse:
    """Manually refresh exchange rates.

    Fetches the latest exchange rates from the API and updates the cache.
    This endpoint is rate-limited and should be used sparingly.

    Returns:
        Response indicating success or failure of the refresh operation
    """
    logger.info("exchange_rates_manual_refresh_requested")

    success = await exchange_rate_service.update_cache()

    if success:
        data = await exchange_rate_service.get_cached_rates()
        return success_response(
            data=data,
        )
    else:
        return error_response(
            code=get_error_code_int("SERVER_ERROR"),
            message="Failed to refresh exchange rates",
            data=None,
            http_status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )
