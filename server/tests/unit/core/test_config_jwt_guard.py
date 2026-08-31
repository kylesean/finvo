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
