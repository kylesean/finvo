"""Unit tests for currency inference logic.

These tests guard the "inference runs once at registration" contract:
- Locale/timezone signals correctly map to currencies
- Fallback is PROJECT_DEFAULT_CURRENCY (CNY), not USD
- Unsupported currencies gracefully fall through
"""

import pytest

from app.config.currency import PROJECT_DEFAULT_CURRENCY
from app.utils.currency_inference import (
    FALLBACK_CURRENCY,
    SUPPORTED_CURRENCIES,
    infer_currency,
)


class TestInferCurrencyLocale:
    """Test locale-based currency inference."""

    def test_exact_locale_match(self):
        """Exact locale (en_US) should map directly to USD."""
        assert infer_currency(locale="en_US") == "USD"
        assert infer_currency(locale="en_GB") == "GBP"
        assert infer_currency(locale="zh_TW") == "TWD"
        assert infer_currency(locale="zh_HK") == "HKD"

    def test_prefix_locale_match(self):
        """Prefix match: zh_CN -> zh -> CNY, ja_JP -> ja -> JPY."""
        assert infer_currency(locale="zh_CN") == "CNY"
        assert infer_currency(locale="ja_JP") == "JPY"
        assert infer_currency(locale="ko_KR") == "KRW" if "KRW" in SUPPORTED_CURRENCIES else True
        assert infer_currency(locale="de_DE") == "EUR"
        assert infer_currency(locale="fr_FR") == "EUR"

    def test_locale_with_hyphen_normalized(self):
        """Locale with hyphen (zh-Hant) should be normalized to underscore."""
        assert infer_currency(locale="zh-Hant") == "TWD"
        assert infer_currency(locale="en-US") == "USD"


class TestInferCurrencyTimezone:
    """Test timezone-based currency inference (used when locale is absent)."""

    def test_timezone_match(self):
        """Timezone should map to currency when locale is None."""
        assert infer_currency(locale=None, timezone="Asia/Shanghai") == "CNY"
        assert infer_currency(locale=None, timezone="Asia/Tokyo") == "JPY"
        assert infer_currency(locale=None, timezone="America/New_York") == "USD"
        assert infer_currency(locale=None, timezone="Europe/Paris") == "EUR"

    def test_locale_takes_priority_over_timezone(self):
        """Locale should win over timezone when both are provided."""
        # User has English locale but Shanghai timezone -> locale wins -> USD
        assert infer_currency(locale="en_US", timezone="Asia/Shanghai") == "USD"
        # Chinese locale with US timezone -> locale wins -> CNY
        assert infer_currency(locale="zh_CN", timezone="America/New_York") == "CNY"


class TestInferCurrencyFallback:
    """Test fallback behavior when no signal is available."""

    def test_no_signal_falls_back_to_project_default(self):
        """No locale, no timezone -> PROJECT_DEFAULT_CURRENCY (CNY)."""
        result = infer_currency(locale=None, timezone=None)
        assert result == PROJECT_DEFAULT_CURRENCY
        assert result == "CNY"

    def test_fallback_constant_aligned_with_project_default(self):
        """FALLBACK_CURRENCY must always equal PROJECT_DEFAULT_CURRENCY."""
        assert FALLBACK_CURRENCY == PROJECT_DEFAULT_CURRENCY

    def test_unknown_locale_and_timezone_falls_back(self):
        """Completely unknown signals should fall back to CNY."""
        result = infer_currency(locale="xx_YY", timezone="Mars/Olympus")
        assert result == PROJECT_DEFAULT_CURRENCY

    def test_unsupported_currency_in_map_skipped(self):
        """If a map entry points to an unsupported currency, skip to next level.

        Example: ko -> KRW, but if KRW not in SUPPORTED_CURRENCIES,
        should fall through to timezone or fallback.
        """
        # ko maps to KRW; test behavior depends on whether KRW is supported
        result = infer_currency(locale="ko_KR", timezone="Asia/Shanghai")
        if "KRW" not in SUPPORTED_CURRENCIES:
            # KRW unsupported -> falls to timezone -> CNY
            assert result == "CNY"
        else:
            assert result == "KRW"
