"""Application configuration management.

This module handles environment-specific configuration loading, parsing, and management
for the application. It includes environment detection, .env file loading, and
configuration value parsing using Pydantic Settings.
"""

from __future__ import annotations

import logging
import os
from enum import Enum
from pathlib import Path
from typing import Any, Literal
from urllib.parse import quote_plus

from dotenv import load_dotenv
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Use stdlib logger here to avoid circular import with app.core.logging (which imports settings)
_logger = logging.getLogger("config")


# Define environment types
class Environment(str, Enum):
    """Application environment types.

    Defines the possible environments the application can run in:
    development, staging, production, and test.
    """

    DEVELOPMENT = "development"
    STAGING = "staging"
    PRODUCTION = "production"
    TEST = "test"


# Determine environment
def get_environment() -> Environment:
    """Get the current environment.

    Returns:
        Environment: The current environment (development, staging, production, or test)
    """
    match os.getenv("APP_ENV", "development").lower():
        case "production" | "prod":
            return Environment.PRODUCTION
        case "staging" | "stage":
            return Environment.STAGING
        case "test":
            return Environment.TEST
        case _:
            return Environment.DEVELOPMENT


# Load appropriate .env file based on environment
def load_env_file() -> str | None:
    """Load environment-specific .env file with priority:
    1. .env (the main user-config)
    2. .env.{env} (environment-specific override)
    3. .env.local (local developer override)
    """
    env = get_environment()
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))

    # Priority order
    env_files = [
        os.path.join(base_dir, ".env"),
        os.path.join(base_dir, f".env.{env.value}"),
        os.path.join(base_dir, ".env.local"),
    ]

    # Load all existing env files in reverse priority (so highest priority loads last and overrides)
    loaded_any = False
    for env_file in reversed(env_files):
        if os.path.isfile(env_file):
            load_dotenv(dotenv_path=env_file, override=True)
            loaded_any = True

    return ".env" if loaded_any else None


ENV_FILE = load_env_file()


def _read_version() -> str:
    """Read version from root VERSION, server VERSION, or pyproject.toml (single source of truth).

    Falls back gracefully if files are not found (e.g. minimal container environments).
    """
    # 1. Try project root VERSION (4 levels up from config.py: server/app/core/config.py -> root)
    root_version_file = Path(__file__).resolve().parents[3] / "VERSION"
    if root_version_file.exists():
        try:
            return root_version_file.read_text(encoding="utf-8").strip()
        except OSError:
            pass

    # 2. Try server VERSION (2 levels up from config.py: server/app/core/config.py -> server)
    server_version_file = Path(__file__).resolve().parents[2] / "VERSION"
    if server_version_file.exists():
        try:
            return server_version_file.read_text(encoding="utf-8").strip()
        except OSError:
            pass

    # 3. Try pyproject.toml in server directory
    pyproject_file = Path(__file__).resolve().parents[2] / "pyproject.toml"
    if pyproject_file.exists():
        try:
            content = pyproject_file.read_text(encoding="utf-8")
            for line in content.splitlines():
                line_str = line.strip()
                if line_str.startswith("version ="):
                    return line_str.split("=")[1].strip().strip("\"'")
        except OSError:
            pass

    return "0.1.2-alpha"


class Settings(BaseSettings):
    """Application settings using Pydantic Settings.

    Automatically loads configuration from environment variables and .env files.
    Provides type validation and environment-specific defaults.
    """

    model_config = SettingsConfigDict(
        env_file=ENV_FILE,
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
        # Don't try to parse JSON for these fields
        env_parse_none_str="null",
    )

    # Environment
    ENVIRONMENT: Environment = Field(default_factory=get_environment)

    # Application Settings
    PROJECT_NAME: str = "Finvo"
    VERSION: str = _read_version()
    # Minimum client version the server still supports (see api/v1/version.py).
    MIN_SUPPORTED_CLIENT_VERSION: str = "0.1.0"
    DESCRIPTION: str = "AI-powered expense tracking and financial management system"
    API_V1_STR: str = "/api/v1"
    DEBUG: bool = False

    # CORS Settings
    ALLOWED_ORIGINS: str = "*"

    # Langfuse Configuration
    LANGFUSE_PUBLIC_KEY: str = ""
    LANGFUSE_SECRET_KEY: str = ""
    LANGFUSE_HOST: str = "https://cloud.langfuse.com"

    # LLM Configuration
    DEFAULT_LLM_MODEL: str = "gpt-5.6-luna"
    DEFAULT_LLM_TEMPERATURE: float = 0.2
    MAX_TOKENS: int = 2000  # LLM output generation cap (per response)
    # Dedicated budget for trimming conversation history fed to the model.
    # Must be independent of MAX_TOKENS (output cap) — a 2000-token history is
    # far too small for tool-calling turns whose ToolMessages (e.g. forecast
    # JSON) alone can exceed it, which previously caused `trim_messages` to
    # return an empty list and strip ALL context from the model's turn.
    MAX_HISTORY_TOKENS: int = 24000
    MAX_LLM_CALL_RETRIES: int = 3
    # Per-request timeout for LLM upstream HTTP calls (connect+read). Prevents a
    # dead upstream from hanging requests for minutes. Each model call within a
    # stream is bounded separately, so this does not cut off valid streaming.
    LLM_REQUEST_TIMEOUT_SECONDS: float = 120.0

    # Vision / Multimodal Configuration
    # None = auto-detect from LLMRegistry capabilities declaration
    # True/False = force override (useful when using custom OpenAI-compatible endpoints)
    LLM_SUPPORTS_VISION: bool | None = None

    # --- Per-Provider Credentials ---
    # OpenAI
    OPENAI_API_KEY: str = Field(default="", validation_alias="OPENAI_API_KEY")
    OPENAI_BASE_URL: str | None = Field(default=None, validation_alias="OPENAI_BASE_URL")

    # DeepSeek
    DEEPSEEK_API_KEY: str | None = Field(default=None, validation_alias="DEEPSEEK_API_KEY")
    DEEPSEEK_BASE_URL: str | None = Field(
        default=None,
        validation_alias="DEEPSEEK_BASE_URL",
        description="e.g. https://api.deepseek.com/v1",
    )

    # Qwen
    QWEN_API_KEY: str | None = Field(default=None, validation_alias="QWEN_API_KEY")
    QWEN_BASE_URL: str | None = Field(
        default=None,
        validation_alias="QWEN_BASE_URL",
        description="e.g. https://token-plan.cn-beijing.maas.aliyuncs.com/compatible-mode/v1",
    )

    # Doubao
    DOUBAO_API_KEY: str | None = Field(default=None, validation_alias="DOUBAO_API_KEY")
    DOUBAO_BASE_URL: str | None = Field(
        default=None,
        validation_alias="DOUBAO_BASE_URL",
        description="e.g. https://ark.cn-beijing.volces.com/api/v3",
    )

    # Ollama
    OLLAMA_API_KEY: str = Field(default="ollama", validation_alias="OLLAMA_API_KEY")
    OLLAMA_BASE_URL: str = Field(
        default="http://localhost:11434/v1",
        validation_alias="OLLAMA_BASE_URL",
        description="e.g. http://localhost:11434/v1",
    )

    # Long term memory Configuration (Mem0)
    # Supported Embedder Providers: "openai", "ollama", "huggingface", "azure_openai"
    LONG_TERM_MEMORY_MODEL: str = "deepseek-v4-flash"  # LLM for memory extraction
    LONG_TERM_MEMORY_MODEL_API_KEY: str | None = None  # API key for memory LLM (falls back to OPENAI_API_KEY)
    LONG_TERM_MEMORY_MODEL_BASE_URL: str | None = None  # Base URL for memory LLM (e.g. https://api.siliconflow.cn/v1)
    LONG_TERM_MEMORY_EMBEDDER_PROVIDER: str = "openai"  # openai, ollama, huggingface
    LONG_TERM_MEMORY_EMBEDDER_MODEL: str = "text-embedding-3-small"
    LONG_TERM_MEMORY_EMBEDDER_DIMS: int = 1024  # Embedding dimensions
    LONG_TERM_MEMORY_COLLECTION_NAME: str = "longterm_memory"
    LONG_TERM_MEMORY_EMBEDDER_API_KEY: str | None = None  # For openai/huggingface
    LONG_TERM_MEMORY_EMBEDDER_BASE_URL: str | None = None  # For openai-compatible APIs
    LONG_TERM_MEMORY_OLLAMA_BASE_URL: str | None = None  # For ollama: http://localhost:11434

    # JWT Configuration
    # NOTE: default is an insecure placeholder; production must override via env var
    # (enforced in model_post_init — see fail-fast check below)
    JWT_SECRET_KEY: str = Field(default="change-this-secret-key-in-production")
    JWT_ALGORITHM: str = "HS256"
    # 7-day lifetime limits the damage window of a leaked token. Revocation
    # (jti-based blacklist) is tracked as P1/M7 in CODE_REVIEW_OPTIMIZATION.md.
    JWT_ACCESS_TOKEN_EXPIRE_DAYS: int = 7

    # Base Directory
    BASE_DIR: Path = Field(default=Path(__file__).parent.parent.parent)

    # Logging Configuration
    LOG_DIR: Path = Field(default_factory=lambda: Path(__file__).parent.parent.parent / "logs")
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"  # "json" or "console"

    # PostgresSQL Configuration
    DATABASE_URL: str | None = None
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "Finvo"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"

    # ORM (SQLAlchemy) connection pool
    POSTGRES_POOL_SIZE: int = 10  # Warm connections kept open per process
    POSTGRES_MAX_OVERFLOW: int = 5  # Extra connections allowed under burst
    POSTGRES_POOL_TIMEOUT: int = 30  # Seconds to wait for a free connection before failing
    POSTGRES_POOL_RECYCLE: int = 1800  # Recycle connections older than this (survives DB restarts)
    POSTGRES_POOL_PRE_PING: bool = True  # Verify connection liveness before checkout
    # Pool mode: "queue" (default) reuses connections in-process.
    # Use "null" ONLY when a transaction-level external pooler sits in front of
    # PostgreSQL (e.g. PgBouncer or Supabase Supavisor in transaction mode).
    DB_POOL_MODE: Literal["queue", "null"] = "queue"

    # LangGraph checkpointer (psycopg3) connection pool, independent from the ORM pool
    CHECKPOINTER_POOL_SIZE: int = 10

    CHECKPOINT_TABLES: list[str] = ["checkpoint_blobs", "checkpoint_writes", "checkpoints"]

    # Redis Configuration
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    REDIS_PASSWORD: str | None = None
    REDIS_POOL_SIZE: int = 10

    # Exchange Rate API Configuration
    EXCHANGE_RATE_API_URL: str | None = None  # e.g., https://v6.exchangerate-api.com/v6/{API_KEY}/latest/USD
    EXCHANGE_RATE_CACHE_KEY: str = "exchange_rates:usd"  # Redis key for caching exchange rates
    EXCHANGE_RATE_CACHE_TTL: int = 86400  # Cache TTL in seconds (24 hours)
    EXCHANGE_RATE_CRON_HOUR: int = 0  # Hour to run the scheduled update (UTC)
    EXCHANGE_RATE_CRON_MINUTE: int = 0  # Minute to run the scheduled update (UTC)

    # File Upload Configuration
    UPLOAD_DIR: Path = Field(default_factory=lambda: Path(__file__).parent.parent.parent / "storage" / "uploads")
    MAX_UPLOAD_SIZE: int = 10485760  # 10MB
    ALLOWED_MIME_TYPES: str = "image/jpeg,image/png,image/webp,application/pdf"

    # Storage Provider Configuration
    # Options: local_uploads (default), s3_compatible
    STORAGE_PROVIDER: str = "local_uploads"

    # S3 Compatible Storage (Supabase, MinIO, AWS S3)
    # Required when STORAGE_PROVIDER=s3_compatible
    S3_ENDPOINT: str | None = None
    S3_ACCESS_KEY: str | None = None
    S3_SECRET_KEY: str | None = None
    S3_BUCKET: str = "Finvo-data"
    S3_REGION: str = "us-east-1"

    # Storage System Configuration
    ENCRYPTION_KEY: str | None = None  # Fernet key for credential encryption
    FILE_URL_EXPIRE_SECONDS: int = 3600  # Signed URL expiration time
    APP_URL: str = "http://localhost:8000"  # Base URL for signed URLs

    # Rate Limiting Configuration
    RATE_LIMIT_DEFAULT: str = "200 per day,50 per hour"
    RATE_LIMIT_CHAT: str = "30 per minute"
    RATE_LIMIT_CHAT_STREAM: str = "20 per minute"
    RATE_LIMIT_MESSAGES: str = "50 per minute"
    RATE_LIMIT_LOGIN: str = "20 per minute"
    RATE_LIMIT_REGISTER: str = "10 per hour"
    RATE_LIMIT_SEND_CODE: str = "10 per minute"

    # Set to True only when running behind a trusted reverse proxy that strips
    # untrusted X-Forwarded-For headers. Enables rate limiting / IP logging to
    # use the real client IP; keeps spoofing attempts ineffective otherwise.
    BEHIND_PROXY: bool = False

    @property
    def RATE_LIMIT_ENDPOINTS(self) -> dict[str, list[str]]:
        """Get rate limit configuration for endpoints."""
        return {
            "root": [self.RATE_LIMIT_DEFAULT],
            "health": [self.RATE_LIMIT_DEFAULT],
            "avatar": [self.RATE_LIMIT_DEFAULT],
            "register": [self.RATE_LIMIT_REGISTER],
            "login": [self.RATE_LIMIT_LOGIN],
            "send_code": [self.RATE_LIMIT_SEND_CODE],
            "chat": [self.RATE_LIMIT_CHAT],
            "chat_stream": [self.RATE_LIMIT_CHAT_STREAM],
            "messages": [self.RATE_LIMIT_MESSAGES],
        }

    # Verification Code Settings
    CODE_EXPIRY_SECONDS: int = 300  # 5 minutes
    SMS_PROVIDER: str = "mock"  # mock, aliyun, twilio
    EMAIL_PROVIDER: str = "mock"  # mock, smtp

    # SMTP Settings
    SMTP_HOST: str = "localhost"
    SMTP_PORT: int = 587
    SMTP_USER: str | None = None
    SMTP_PASSWORD: str | None = None
    SMTP_FROM_EMAIL: str = "noreply@localhost"
    SMTP_FROM_NAME: str = "Finvo"

    # Evaluation Configuration
    EVALUATION_LLM: str = "deepseek-v4-flash"
    EVALUATION_BASE_URL: str = "https://api.openai.com/v1"
    EVALUATION_API_KEY: str | None = None
    EVALUATION_SLEEP_TIME: int = 10

    # Monitoring
    ENABLE_METRICS: bool = False
    METRICS_PORT: int = 9090
    # Bearer token required to access /metrics when set (leave empty to keep open)
    METRICS_TOKEN: str = ""

    @property
    def allowed_origins_list(self) -> list[str]:
        """Get CORS origins as a list."""
        if isinstance(self.ALLOWED_ORIGINS, list):
            return self.ALLOWED_ORIGINS
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",") if origin.strip()]

    @property
    def allowed_mime_types_list(self) -> list[str]:
        """Get allowed MIME types as a list."""
        if isinstance(self.ALLOWED_MIME_TYPES, list):
            return self.ALLOWED_MIME_TYPES
        return [mime.strip() for mime in self.ALLOWED_MIME_TYPES.split(",") if mime.strip()]

    @field_validator("LOG_DIR", "UPLOAD_DIR", mode="before")
    @classmethod
    def parse_path(cls, v: str | Path) -> Path:
        """Convert string to Path object."""
        if isinstance(v, Path):
            return v
        return Path(v)

    @property
    def database_url(self) -> str:
        """Get PostgresSQL database URL for SQLAlchemy."""
        if self.DATABASE_URL:
            url = self.DATABASE_URL
            if url.startswith("postgresql://"):
                return url.replace("postgresql://", "postgresql+asyncpg://", 1)
            elif url.startswith("postgres://"):
                return url.replace("postgres://", "postgresql+asyncpg://", 1)
            return url
        return (
            f"postgresql+asyncpg://{quote_plus(self.POSTGRES_USER)}:{quote_plus(self.POSTGRES_PASSWORD)}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def checkpointer_database_url(self) -> str:
        """Get PostgresSQL database URL for psycopg3 (LangGraph checkpointer)."""
        if self.DATABASE_URL:
            url = self.DATABASE_URL
            if "+asyncpg" in url:
                url = url.replace("+asyncpg", "", 1)
            elif "+psycopg" in url:
                url = url.replace("+psycopg", "", 1)
            return url
        return (
            "postgresql://"
            f"{quote_plus(self.POSTGRES_USER)}:{quote_plus(self.POSTGRES_PASSWORD)}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def database_url_sync(self) -> str:
        """Get PostgresSQL database URL for synchronous operations (Alembic)."""
        if self.DATABASE_URL:
            url = self.DATABASE_URL
            if "+asyncpg" in url:
                url = url.replace("+asyncpg", "+psycopg", 1)
            elif "+psycopg" not in url:
                url = url.replace("postgresql://", "postgresql+psycopg://", 1)
            return url
        return (
            f"postgresql+psycopg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def redis_url(self) -> str:
        """Get Redis connection URL."""
        if self.REDIS_PASSWORD:
            return f"redis://:{self.REDIS_PASSWORD}@{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"
        return f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"

    def model_post_init(self, _: Any, /) -> None:
        """Apply environment-specific settings after initialization."""
        # Handle aliases for LLM settings if not established by Pydantic
        # This provides a fallback if the user uses legacy naming like OPENAI_API_BASE
        if not self.OPENAI_BASE_URL:
            self.OPENAI_BASE_URL = os.getenv("OPENAI_API_BASE")

        if not self.OPENAI_API_KEY:
            # Legacy generic LLM_API_KEY env var — still honored but deprecated.
            # NOTE: DEEPSEEK_API_KEY is intentionally NOT aliased here. It is its
            # own Settings field (see above) and is consumed directly by the
            # DeepSeek provider in llm.py. Silently copying a DeepSeek key into
            # OPENAI_API_KEY would let the OpenAI provider accidentally
            # authenticate with a DeepSeek credential, routing requests to the
            # wrong provider. Set OPENAI_API_KEY explicitly for the OpenAI-
            # compatible endpoint.
            legacy_llm_key = os.getenv("LLM_API_KEY")
            if legacy_llm_key:
                import warnings

                warnings.warn(
                    "LLM_API_KEY is deprecated; set OPENAI_API_KEY explicitly for "
                    "the OpenAI-compatible endpoint. LLM_API_KEY support will be "
                    "removed in a future release.",
                    DeprecationWarning,
                    stacklevel=2,
                )
                self.OPENAI_API_KEY = legacy_llm_key

        # Apply environment-specific overrides
        if self.ENVIRONMENT == Environment.DEVELOPMENT:
            if "DEBUG" not in os.environ:
                self.DEBUG = True
            if "LOG_LEVEL" not in os.environ:
                self.LOG_LEVEL = "DEBUG"
            if "LOG_FORMAT" not in os.environ:
                self.LOG_FORMAT = "console"
        elif self.ENVIRONMENT == Environment.PRODUCTION:
            if "DEBUG" not in os.environ:
                self.DEBUG = False
            if "LOG_LEVEL" not in os.environ:
                self.LOG_LEVEL = "WARNING"
        elif self.ENVIRONMENT == Environment.STAGING:
            if "DEBUG" not in os.environ:
                self.DEBUG = False
            if "LOG_LEVEL" not in os.environ:
                self.LOG_LEVEL = "INFO"

        # Ensure directories exist
        self.LOG_DIR.mkdir(parents=True, exist_ok=True)
        self.UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

        # JWT secret fail-fast: production must not use the insecure default placeholder.
        # Mirrors the ENCRYPTION_KEY guard in app/utils/encryption.py:_initialize().
        _JWT_INSECURE_DEFAULT = "change-this-secret-key-in-production"
        if self.ENVIRONMENT in (Environment.PRODUCTION, Environment.STAGING):
            if self.JWT_SECRET_KEY == _JWT_INSECURE_DEFAULT:
                raise RuntimeError(
                    "CRITICAL: JWT_SECRET_KEY must be set to a strong, unique value in "
                    f"{self.ENVIRONMENT.value}! Generate one using: "
                    'python -c "import secrets; print(secrets.token_urlsafe(32))"'
                )
        else:
            if self.JWT_SECRET_KEY == _JWT_INSECURE_DEFAULT:
                _logger.warning(
                    "JWT_SECRET_KEY is using insecure default. "
                    "Set a strong value via env var — NEVER use the default in production!"
                )

        # Sanitize proxy environment variables to prevent Pydantic validation errors
        # Change socks:// to socks5:// as "socks" is not a recognized scheme by httpx/pydantic
        for proxy_var in ["HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy"]:
            val = os.environ.get(proxy_var)
            if val and val.startswith("socks://"):
                new_val = val.replace("socks://", "socks5://", 1)
                os.environ[proxy_var] = new_val


# Create settings instance
settings = Settings()
