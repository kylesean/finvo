"""JWT secret fail-fast guard tests (see config.py:_validate_jwt_secret).

The guard must run for every Settings() construction: production/staging with
an insecure or too-short secret must refuse to start. This regression test
locks the behavior that was previously silently dead code (the check lived
after a `return` inside the `is_production` property).
"""

import logging
import os

import pytest

from app.core.config import Environment, Settings

_WEAK_DEFAULT = "change-this-secret-key-in-production"
_STRONG = "a" * 64


def _make_settings(monkeypatch, app_env: str, jwt_secret: str) -> Settings:
    monkeypatch.setenv("APP_ENV", app_env)
    monkeypatch.setenv("JWT_SECRET_KEY", jwt_secret)
    # Real verification providers so the (separate) provider guard doesn't fire
    # in JWT-guard tests; the provider guard has its own tests below.
    monkeypatch.setenv("SMS_PROVIDER", "aliyun")
    monkeypatch.setenv("EMAIL_PROVIDER", "smtp")
    return Settings()


def test_production_with_default_secret_raises(monkeypatch):
    with pytest.raises(RuntimeError, match="JWT_SECRET_KEY"):
        _make_settings(monkeypatch, "production", _WEAK_DEFAULT)


def test_production_with_short_secret_raises(monkeypatch):
    with pytest.raises(RuntimeError, match="JWT_SECRET_KEY"):
        _make_settings(monkeypatch, "production", "short-secret")


def test_staging_with_default_secret_raises(monkeypatch):
    with pytest.raises(RuntimeError, match="JWT_SECRET_KEY"):
        _make_settings(monkeypatch, "staging", _WEAK_DEFAULT)


def test_production_with_strong_secret_passes(monkeypatch):
    settings = _make_settings(monkeypatch, "production", _STRONG)
    assert settings.ENVIRONMENT == Environment.PRODUCTION


def test_development_with_default_secret_warns_not_raises(monkeypatch, caplog):
    with caplog.at_level(logging.WARNING, logger="config"):
        settings = _make_settings(monkeypatch, "development", _WEAK_DEFAULT)
    assert settings.ENVIRONMENT == Environment.DEVELOPMENT
    assert any("JWT_SECRET_KEY" in record.message for record in caplog.records)


def test_socks_proxy_variable_normalized(monkeypatch):
    monkeypatch.setenv("HTTP_PROXY", "socks://127.0.0.1:1080")
    _make_settings(monkeypatch, "development", _STRONG)
    assert os.environ["HTTP_PROXY"] == "socks5://127.0.0.1:1080"


# ---------------------------------------------------------------------------
# Verification provider fail-fast guard (SEC-P1-3, config.py:_validate_verification_providers)
#
# The shipped defaults skip code verification entirely ("mock"); a public
# deployment that forgets to configure a real provider must refuse to boot
# instead of letting anyone register and spend the operator's LLM budget.
# ---------------------------------------------------------------------------


def test_production_with_mock_providers_raises(monkeypatch):
    monkeypatch.setenv("APP_ENV", "production")
    monkeypatch.setenv("JWT_SECRET_KEY", _STRONG)
    # SMS/EMAIL left at their "mock" defaults on purpose.
    with pytest.raises(RuntimeError, match="verification provider"):
        Settings()


def test_staging_with_mock_providers_raises(monkeypatch):
    monkeypatch.setenv("APP_ENV", "staging")
    monkeypatch.setenv("JWT_SECRET_KEY", _STRONG)
    with pytest.raises(RuntimeError, match="verification provider"):
        Settings()


def test_production_with_real_providers_passes(monkeypatch):
    settings = _make_settings(monkeypatch, "production", _STRONG)
    assert settings.ENVIRONMENT == Environment.PRODUCTION


def test_development_with_mock_providers_allowed(monkeypatch):
    """Local dev keeps the zero-config mock experience."""
    monkeypatch.setenv("APP_ENV", "development")
    monkeypatch.setenv("JWT_SECRET_KEY", _STRONG)
    settings = Settings()
    assert settings.SMS_PROVIDER == "mock"
    assert settings.EMAIL_PROVIDER == "mock"


def test_registration_open_by_default(monkeypatch):
    settings = _make_settings(monkeypatch, "development", _STRONG)
    assert settings.REGISTRATION_OPEN is True
