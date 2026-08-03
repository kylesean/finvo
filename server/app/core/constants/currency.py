"""Centralized currency default constants.

Single Source of Truth for all currency-related defaults across the project.
All models, schemas, and inference logic MUST import from here instead of
hardcoding currency strings.

Design decisions:
- PROJECT_DEFAULT_CURRENCY = "CNY" because the product primarily targets
  Chinese-speaking users (base_locale=zh, DB server_defaults are CNY).
- Currency inference runs ONLY ONCE at registration time (via infer_currency).
  After that, the user's primary_currency is immutable unless explicitly
  changed through the settings API. There is NO background job or login hook
  that re-infers currency from locale.
"""

# The project-wide default currency used as:
# 1. SQLAlchemy model column default (Python-side)
# 2. Fallback when currency inference has no signal (no locale, no timezone)
# 3. UPSERT fallback in user_service when creating settings on-the-fly
PROJECT_DEFAULT_CURRENCY: str = "CNY"

# Rich metadata for every supported currency. This is THE single source of
# truth for the currency list; both display output (symbols/names) and
# inference membership derive from it (see currency_utils / currency_inference).
SUPPORTED_CURRENCIES: list[dict[str, str]] = [
    {"code": "USD", "name": "US Dollar", "symbol": "$", "flag": "🇺🇸"},
    {"code": "CNY", "name": "Chinese Yuan", "symbol": "¥", "flag": "🇨🇳"},
    {"code": "EUR", "name": "Euro", "symbol": "€", "flag": "🇪🇺"},
    {"code": "GBP", "name": "British Pound", "symbol": "£", "flag": "🇬🇧"},
    {"code": "JPY", "name": "Japanese Yen", "symbol": "¥", "flag": "🇯🇵"},
    {"code": "CAD", "name": "Canadian Dollar", "symbol": "C$", "flag": "🇨🇦"},
    {"code": "AUD", "name": "Australian Dollar", "symbol": "A$", "flag": "🇦🇺"},
    {"code": "INR", "name": "Indian Rupee", "symbol": "₹", "flag": "🇮🇳"},
    {"code": "RUB", "name": "Russian Ruble", "symbol": "₽", "flag": "🇷🇺"},
    {"code": "HKD", "name": "Hong Kong Dollar", "symbol": "HK$", "flag": "🇭🇰"},
    {"code": "TWD", "name": "New Taiwan Dollar", "symbol": "NT$", "flag": "🇹🇼"},
]

# Canonical set of supported currency codes (derived, used for membership checks).
SUPPORTED_CURRENCY_CODES: frozenset[str] = frozenset(c["code"] for c in SUPPORTED_CURRENCIES)

# Code -> display symbol (derived).
CURRENCY_SYMBOLS: dict[str, str] = {c["code"]: c["symbol"] for c in SUPPORTED_CURRENCIES}
