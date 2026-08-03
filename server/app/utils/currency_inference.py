"""Infer user's preferred currency from registration context.

This module provides smart currency inference based on locale and timezone
signals collected during user registration. The priority is:
1. Locale (exact match, then prefix match)
2. Timezone
3. Fallback to USD
"""

from __future__ import annotations

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY, SUPPORTED_CURRENCY_CODES

# Mapping: locale (exact or prefix) -> currency code
# Exact keys (e.g. "en_US") are checked first, then prefix keys (e.g. "en")
LOCALE_CURRENCY_MAP: dict[str, str] = {
    # Exact locale matches (higher priority)
    "en_US": "USD",
    "en_GB": "GBP",
    "en_AU": "AUD",
    "en_CA": "CAD",
    "zh_Hant": "TWD",  # Traditional Chinese -> TWD
    "zh_TW": "TWD",
    "zh_HK": "HKD",
    # Prefix matches (lower priority, checked after exact)
    "zh": "CNY",
    "en": "USD",
    "ja": "JPY",
    "ko": "KRW",  # Note: KRW not in supported list, will fallback
    "de": "EUR",
    "fr": "EUR",
    "es": "EUR",
    "it": "EUR",
    "pt": "EUR",
    "ru": "RUB",
    "hi": "INR",
}

# Mapping: IANA timezone -> currency code
TIMEZONE_CURRENCY_MAP: dict[str, str] = {
    "Asia/Shanghai": "CNY",
    "Asia/Chongqing": "CNY",
    "Asia/Urumqi": "CNY",
    "Asia/Taipei": "TWD",
    "Asia/Hong_Kong": "HKD",
    "Asia/Macau": "HKD",
    "Asia/Tokyo": "JPY",
    "Asia/Kolkata": "INR",
    "Asia/Singapore": "USD",  # Singapore uses SGD but not supported; fallback
    "America/New_York": "USD",
    "America/Chicago": "USD",
    "America/Denver": "USD",
    "America/Los_Angeles": "USD",
    "America/Anchorage": "USD",
    "Pacific/Honolulu": "USD",
    "America/Toronto": "CAD",
    "America/Vancouver": "CAD",
    "Europe/London": "GBP",
    "Europe/Paris": "EUR",
    "Europe/Berlin": "EUR",
    "Europe/Madrid": "EUR",
    "Europe/Rome": "EUR",
    "Europe/Amsterdam": "EUR",
    "Europe/Moscow": "RUB",
    "Australia/Sydney": "AUD",
    "Australia/Melbourne": "AUD",
    "Australia/Brisbane": "AUD",
}

# Currencies supported by the application (derived from the single source of
# truth in app.core.constants.currency; members are checked for membership only).
SUPPORTED_CURRENCIES: frozenset[str] = SUPPORTED_CURRENCY_CODES

# Fallback currency when no signal is available (no locale, no timezone match).
# Aligned with PROJECT_DEFAULT_CURRENCY to ensure consistency across all layers.
FALLBACK_CURRENCY: str = PROJECT_DEFAULT_CURRENCY


def infer_currency(locale: str | None = None, timezone: str | None = None) -> str:
    """Infer the user's preferred currency from locale and timezone.

    Priority:
    1. Locale exact match (e.g. "en_US" -> USD)
    2. Locale prefix match (e.g. "zh" from "zh_CN" -> CNY)
    3. Timezone match (e.g. "Asia/Shanghai" -> CNY)
    4. Fallback to USD

    Args:
        locale: User's locale string (e.g. "zh_CN", "en_US", "ja_JP")
        timezone: User's IANA timezone (e.g. "Asia/Shanghai")

    Returns:
        str: Inferred ISO 4217 currency code
    """
    # 1. Try locale
    if locale:
        normalized = locale.replace("-", "_")

        # Exact match first (e.g. "en_US", "zh_Hant")
        if normalized in LOCALE_CURRENCY_MAP:
            candidate = LOCALE_CURRENCY_MAP[normalized]
            if candidate in SUPPORTED_CURRENCIES:
                return candidate

        # Prefix match (e.g. "zh" from "zh_CN")
        prefix = normalized.split("_")[0]
        if prefix in LOCALE_CURRENCY_MAP:
            candidate = LOCALE_CURRENCY_MAP[prefix]
            if candidate in SUPPORTED_CURRENCIES:
                return candidate

    # 2. Try timezone
    if timezone and timezone in TIMEZONE_CURRENCY_MAP:
        candidate = TIMEZONE_CURRENCY_MAP[timezone]
        if candidate in SUPPORTED_CURRENCIES:
            return candidate

    # 3. Fallback
    return FALLBACK_CURRENCY
