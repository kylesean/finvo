"""This file contains the authentication schema for the application."""

import re
from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    field_validator,
    model_validator,
)


class Token(BaseModel):
    """Token model for authentication.

    Attributes:
        access_token: The JWT access token.
        token_type: The type of token (always "bearer").
        expires_at: The token expiration timestamp.
    """

    access_token: str = Field(..., description="The JWT access token")
    token_type: str = Field(default="bearer", description="The type of token")
    expires_at: datetime = Field(..., description="The token expiration timestamp")


def _validate_email(email: str) -> bool:
    """Validate email format (local@domain.tld)."""
    return bool(re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", email))


def _validate_mobile(mobile: str) -> bool:
    """Validate Chinese mobile number format."""
    return bool(re.match(r"^1[3-9]\d{9}$", mobile))


_WEAK_PASSWORDS = frozenset(
    {
        "password",
        "password1",
        "password12",
        "password123",
        "password1234",
        "12345678",
        "123456789",
        "1234567890",
        "qwerty123",
        "1q2w3e4r",
        "1qaz2wsx",
        "abc12345",
        "abcd1234",
        "letmein1",
        "welcome1",
        "admin123",
        "root1234",
        "test1234",
        "demo1234",
        "changeme1",
        "finvo123",
        "money123",
        "caifu123",
    }
)


class SendCodeRequest(BaseModel):
    """Request model for sending verification code.

    Attributes:
        type: Account type ('email' or 'mobile')
        account: Email address or mobile number
    """

    model_config = ConfigDict(json_schema_extra={"examples": [{"type": "email", "account": "user@example.com"}]})

    type: Literal["email", "mobile"] = Field(..., description="Account type", examples=["email"])
    account: str = Field(..., description="Email address or mobile number", examples=["user@example.com"])

    @field_validator("account")
    @classmethod
    def validate_account_not_empty(cls, v: str) -> str:
        """Validate account is not empty."""
        if not v or not v.strip():
            raise ValueError("Account cannot be empty")
        return v.strip()

    @model_validator(mode="after")
    def validate_account_format(self) -> "SendCodeRequest":
        """Validate account format based on type."""
        if self.type == "email" and not _validate_email(self.account):
            raise ValueError("account: Invalid email format")
        elif self.type == "mobile" and not _validate_mobile(self.account):
            raise ValueError("account: Invalid mobile number format")
        return self


class RegisterRequest(BaseModel):
    """Request model for user registration."""

    model_config = ConfigDict(
        validate_default=True,
        json_schema_extra={
            "examples": [
                {
                    "type": "email",
                    "account": "user@example.com",
                    "password": "password123",  # pragma: allowlist secret
                    "code": "123456",
                    "timezone": "Asia/Shanghai",
                }
            ]
        },
    )

    type: Literal["email", "mobile"] = Field(..., description="Account type", examples=["email"])
    account: str = Field(..., description="Email address or mobile number", examples=["user@example.com"])
    password: str = Field(
        ...,
        min_length=8,
        max_length=64,
        description="User's password (8-64 chars, letters + digits, not a common password)",
        examples=["password123"],
    )
    code: str = Field(default="", description="Verification code (Optional in current dev mode)", examples=["123456"])
    timezone: str = Field(default="Asia/Shanghai", description="User's timezone", examples=["Asia/Shanghai"])
    locale: str | None = Field(
        default=None,
        description="Device locale for smart currency defaults (e.g., 'zh_CN', 'en_US', 'ja_JP')",
        examples=["zh_CN", "en_US"],
    )

    @field_validator("account")
    @classmethod
    def validate_account_not_empty(cls, v: str) -> str:
        """Validate account is not empty."""
        if not v or not v.strip():
            raise ValueError("Account cannot be empty")
        return v.strip()

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """Letters + digits, not a common/pattern password."""
        if not re.search(r"[a-zA-Z]", v):
            raise ValueError("Password must contain at least one letter")
        if not re.search(r"[0-9]", v):
            raise ValueError("Password must contain at least one number")
        lowered = v.lower()
        if lowered in _WEAK_PASSWORDS or lowered in {p + "123" for p in ("password", "qwerty")}:
            raise ValueError("Password is too common")
        if len(set(lowered)) == 1 or lowered in ("abcdefgh", "12345678", "87654321"):
            raise ValueError("Password is too common")
        return v

    @model_validator(mode="after")
    def validate_account_format(self) -> "RegisterRequest":
        """Validate account format based on type."""
        if self.type == "email" and not _validate_email(self.account):
            raise ValueError("account: Invalid email format")
        elif self.type == "mobile" and not _validate_mobile(self.account):
            raise ValueError("account: Invalid mobile number format")
        return self


class LoginRequest(BaseModel):
    """Request model for user login.

    Attributes:
        type: Account type ('email' or 'mobile')
        account: Email address or mobile number
        password: User's password
        timezone: User's timezone
    """

    model_config = ConfigDict(
        json_schema_extra={
            "examples": [{"type": "email", "account": "jkx@qq.com", "password": "123456", "timezone": "Asia/Shanghai"}]
        }
    )

    type: Literal["email", "mobile"] = Field(..., description="Account type", examples=["email"])
    account: str = Field(..., description="Email address or mobile number", examples=["jkx@qq.com"])
    password: str = Field(..., description="User's password", examples=["123456"])
    timezone: str = Field(..., description="User's timezone", examples=["Asia/Shanghai"])

    @model_validator(mode="after")
    def validate_account_format(self) -> "LoginRequest":
        """Validate account format based on type (reuses the shared helpers)."""
        if self.type == "email" and not _validate_email(self.account):
            raise ValueError("Invalid email format")
        if self.type == "mobile" and not _validate_mobile(self.account):
            raise ValueError("Invalid mobile number format")
        return self


class UserInfo(BaseModel):
    """User information model.

    Attributes:
        id: User's UUID
        email: User's email
        mobile: User's mobile number
        username: User's username
        avatarUrl: User's avatar URL
        createdAt: Account creation timestamp
        updatedAt: Last update timestamp
        clientLastLoginAt: Last login timestamp
    """

    id: UUID = Field(..., description="User's UUID")
    email: str | None = Field(None, description="User's email")
    mobile: str | None = Field(None, description="User's mobile number")
    username: str = Field(..., description="User's username")
    avatarUrl: str | None = Field(None, description="User's avatar URL")
    createdAt: str = Field(..., description="Account creation timestamp (ISO 8601)")
    updatedAt: str | None = Field(None, description="Last update timestamp (ISO 8601)")
    clientLastLoginAt: str | None = Field(None, description="Last login timestamp (ISO 8601)")


class AuthResponse(BaseModel):
    """Response model for authentication endpoints (register/login).

    Attributes:
        token: JWT authentication token
        user: User information
    """

    token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(
        ...,
        description=(
            "Long-lived JWT refresh token, used to obtain new access tokens "
            "without re-authentication. Rotated on each refresh."
        ),
    )
    user: UserInfo = Field(..., description="User information")


class UpdateSessionNameRequest(BaseModel):
    """Request model for renaming a chat session.

    Attributes:
        name: The new session name
    """

    model_config = ConfigDict(json_schema_extra={"examples": [{"name": "Trip to Tokyo"}]})

    name: str = Field(..., min_length=1, max_length=100, description="The new session name")


class LogoutRequest(BaseModel):
    """Request model for logout.

    Attributes:
        refresh_token: The client's current refresh token, revoked server-side
            so a stolen token cannot survive logout. Optional: clients that
            never received one (or already rotated past it) may omit it.
    """

    refresh_token: str | None = Field(
        default=None,
        max_length=4096,
        description="Current refresh token to revoke server-side",
    )
