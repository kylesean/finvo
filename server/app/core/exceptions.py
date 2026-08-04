"""Custom exception classes for the application.

This module provides a comprehensive exception hierarchy for handling
various error scenarios in the application. Error codes are organized by
domain as ``_ErrorCode`` enums: each member's string value is the
machine-readable code (its name) and it carries the client-facing integer
code as ``int_code``. ``ERROR_CODE_MAP`` is derived from these enums, so
adding a member is the only change needed to register a new code.
"""

from __future__ import annotations

from enum import Enum
from typing import Any

# ============================================================================
# Domain-Specific Error Code Enums
# ============================================================================


class _ErrorCode(str, Enum):
    """Base for domain error code enums.

    Each member is defined as ``NAME = ("NAME", int_code)``. The member
    behaves as a string equal to its name (so it works as an
    ``ERROR_CODE_MAP`` key and compares equal to itself) and exposes the
    numeric code via ``int_code``. This makes the enums the single source
    of truth for both the string and integer codes.
    """

    int_code: int

    def __new__(cls, value: str, int_code: int) -> _ErrorCode:
        obj = str.__new__(cls, value)
        obj._value_ = value
        obj.int_code = int_code
        return obj

    def __str__(self) -> str:
        return str(self._value_)


class CommonErrorCode(_ErrorCode):
    """Common/generic error codes."""

    SUCCESS = ("SUCCESS", 0)
    SERVER_ERROR = ("SERVER_ERROR", 500)
    SYSTEM_INVALID = ("SYSTEM_INVALID", 501)
    INTERNAL_ERROR = ("INTERNAL_ERROR", 500)
    VALIDATION_ERROR = ("VALIDATION_ERROR", 999)
    NOT_FOUND = ("NOT_FOUND", 404)
    PERMISSION_DENIED = ("PERMISSION_DENIED", 403)
    CONFLICT = ("CONFLICT", 409)
    RATE_LIMITED = ("RATE_LIMITED", 429)


class AuthErrorCode(_ErrorCode):
    """Authentication and authorization error codes."""

    AUTHENTICATE_FAILED = ("AUTHENTICATE_FAILED", 1000)
    AUTH_FAILED = ("AUTH_FAILED", 401)
    EMAIL_WRONG = ("EMAIL_WRONG", 1001)
    PHONE_NUMBER_WRONG = ("PHONE_NUMBER_WRONG", 1002)
    PHONE_NUMBER_REGISTERED = ("PHONE_NUMBER_REGISTERED", 1003)
    EMAIL_REGISTERED = ("EMAIL_REGISTERED", 1004)
    SEND_CODE_FAILED = ("SEND_CODE_FAILED", 1005)
    CODE_EXPIRED = ("CODE_EXPIRED", 1006)
    CODE_SEND_TOO_FREQUENTLY = ("CODE_SEND_TOO_FREQUENTLY", 1007)
    UNSUPPORTED_CODE_TYPE = ("UNSUPPORTED_CODE_TYPE", 1008)
    USER_NOT_MATCH_PASSWORD = ("USER_NOT_MATCH_PASSWORD", 1009)
    USER_NOT_EXIST = ("USER_NOT_EXIST", 1010)
    NO_PREFERENCES_PARAMS = ("NO_PREFERENCES_PARAMS", 1011)
    INVALID_CLIENT_TIMEZONE = ("INVALID_CLIENT_TIMEZONE", 1012)


class FileErrorCode(_ErrorCode):
    """File upload and storage error codes."""

    NO_FILE_UPLOADED = ("NO_FILE_UPLOADED", 4001)
    INVALID_FILE_UPLOADED = ("INVALID_FILE_UPLOADED", 4002)
    FILE_TOO_LARGE = ("FILE_TOO_LARGE", 4003)
    INVALID_FILE_TYPE = ("INVALID_FILE_TYPE", 4004)
    INVALID_MIME_TYPE = ("INVALID_MIME_TYPE", 4005)
    INVALID_IMAGE_CONTENT = ("INVALID_IMAGE_CONTENT", 4006)
    IMAGE_TOO_WIDE = ("IMAGE_TOO_WIDE", 4007)
    IMAGE_TOO_HIGH = ("IMAGE_TOO_HIGH", 4008)
    TOO_MANY_FILES = ("TOO_MANY_FILES", 4009)
    TOTAL_SIZE_TOO_LARGE = ("TOTAL_SIZE_TOO_LARGE", 4010)
    FILE_READ_ERROR = ("FILE_READ_ERROR", 4011)
    FILESYSTEM_ERROR = ("FILESYSTEM_ERROR", 4012)
    UPLOAD_VERIFICATION_FAILED = ("UPLOAD_VERIFICATION_FAILED", 4013)
    UPLOAD_ALL_FAILED = ("UPLOAD_ALL_FAILED", 4014)
    INVALID_IMAGE_URLS = ("INVALID_IMAGE_URLS", 4015)
    FILE_NOT_FOUND = ("FILE_NOT_FOUND", 4016)
    IMAGE_COMPRESSION_FAILED = ("IMAGE_COMPRESSION_FAILED", 4017)
    FILE_ACCESS_ERROR = ("FILE_ACCESS_ERROR", 4018)
    FILE_DELETE_ERROR = ("FILE_DELETE_ERROR", 4019)
    NO_FILES = ("NO_FILES", 4020)
    FILE_EMPTY = ("FILE_EMPTY", 4021)
    INVALID_FILENAME = ("INVALID_FILENAME", 4022)


class TransactionErrorCode(_ErrorCode):
    """Transaction-related error codes."""

    TRANSACTION_COMMENT_NULL = ("TRANSACTION_COMMENT_NULL", 3000)
    INVALID_PARENT_COMMENT_ID = ("INVALID_PARENT_COMMENT_ID", 3001)
    STORE_COMMENT_FAILED = ("STORE_COMMENT_FAILED", 3002)
    DELETE_COMMENT_FAILED = ("DELETE_COMMENT_FAILED", 3003)
    TRANSACTION_NOT_EXISTS = ("TRANSACTION_NOT_EXISTS", 3004)
    INVALID_ACCOUNT_ID = ("INVALID_ACCOUNT_ID", 3005)
    EXCHANGE_RATE_UNAVAILABLE = ("EXCHANGE_RATE_UNAVAILABLE", 3006)
    INVALID_RECURRENCE_RULE = ("INVALID_RECURRENCE_RULE", 3200)
    RECURRENCE_RULE_NOT_FOUND = ("RECURRENCE_RULE_NOT_FOUND", 3201)


class SpaceErrorCode(_ErrorCode):
    """Shared space error codes."""

    SHARED_SPACE_NOT_EXISTS_OR_NO_ACCESS = ("SHARED_SPACE_NOT_EXISTS_OR_NO_ACCESS", 3100)
    NO_PERMISSION_TO_INVITE_MEMBERS = ("NO_PERMISSION_TO_INVITE_MEMBERS", 3101)
    CANNOT_INVITE_YOURSELF = ("CANNOT_INVITE_YOURSELF", 3102)
    INVITATION_SENT = ("INVITATION_SENT", 3103)
    ALREADY_MEMBER_OR_HAS_BEEN_INVITED = ("ALREADY_MEMBER_OR_HAS_BEEN_INVITED", 3104)
    INVALID_ACTION = ("INVALID_ACTION", 3105)
    INVITATION_NOT_EXISTS = ("INVITATION_NOT_EXISTS", 3106)
    ONLY_OWNER_CAN_DO = ("ONLY_OWNER_CAN_DO", 3107)
    OWNER_CANNOT_BE_REMOVED = ("OWNER_CANNOT_BE_REMOVED", 3108)
    MEMBER_NOT_EXIST = ("MEMBER_NOT_EXIST", 3109)
    NOT_MEMBER_IN_THIS_SPACE = ("NOT_MEMBER_IN_THIS_SPACE", 3110)
    OWNER_CANNOT_LEAVE_DIRECTLY = ("OWNER_CANNOT_LEAVE_DIRECTLY", 3111)
    INVALID_INVITATION_CODE = ("INVALID_INVITATION_CODE", 3112)
    INVITATION_CODE_EXPIRED_OR_LIMITED = ("INVITATION_CODE_EXPIRED_OR_LIMITED", 3113)
    TRANSACTION_ALREADY_IN_SPACE = ("TRANSACTION_ALREADY_IN_SPACE", 3114)


class AIErrorCode(_ErrorCode):
    """AI/LLM service error codes."""

    AI_CONTEXT_LIMIT_EXCEEDED = ("AI_CONTEXT_LIMIT_EXCEEDED", 9000)
    CONVERSATION_ID_INVALID = ("CONVERSATION_ID_INVALID", 9001)
    CONVERSATION_ID_NOT_OWNER = ("CONVERSATION_ID_NOT_OWNER", 9002)
    TOKENS_LIMITED = ("TOKENS_LIMITED", 9003)
    NO_USER_MESSAGE = ("NO_USER_MESSAGE", 9004)


class StorageErrorCode(_ErrorCode):
    """Storage configuration error codes."""

    INVALID_PROVIDER_TYPE = ("INVALID_PROVIDER_TYPE", 4500)
    CONFIG_NOT_FOUND = ("CONFIG_NOT_FOUND", 4501)
    CONFIG_IN_USE = ("CONFIG_IN_USE", 4502)


# Source-of-truth tuple for deriving ERROR_CODE_MAP; keep in sync with the
# ErrorCodeType union below.
_ALL_ERROR_CODE_ENUMS = (
    CommonErrorCode,
    AuthErrorCode,
    FileErrorCode,
    TransactionErrorCode,
    SpaceErrorCode,
    AIErrorCode,
    StorageErrorCode,
)

# Derived single-source mapping from the string code (member name) to the
# client-facing integer code (member int_code). Adding an enum member is the
# only change needed to register a new code.
ERROR_CODE_MAP: dict[str, int] = {
    member.name: member.int_code for enum_cls in _ALL_ERROR_CODE_ENUMS for member in enum_cls
}


# ============================================================================
# Type Aliases
# ============================================================================

# Union of all domain error code enums (for type hints on exception constructors)
ErrorCodeType = (
    CommonErrorCode
    | AuthErrorCode
    | FileErrorCode
    | TransactionErrorCode
    | SpaceErrorCode
    | AIErrorCode
    | StorageErrorCode
)


# ============================================================================
# Exception Classes
# ============================================================================


class AppException(Exception):
    """Base application exception.

    Attributes:
        message: Human-readable error message.
        status_code: HTTP status code.
        error_code: Machine-readable error code.
        details: Additional context.
    """

    def __init__(
        self,
        message: str,
        status_code: int = 500,
        error_code: ErrorCodeType | str = CommonErrorCode.INTERNAL_ERROR,
        details: dict[str, Any] | None = None,
    ):
        self.message = message
        self.status_code = status_code
        self.error_code = error_code if isinstance(error_code, str) else error_code.value
        self.details = details or {}
        super().__init__(message)

    def __repr__(self) -> str:
        """Return a string representation of the exception."""
        return f"<{self.__class__.__name__}(message={self.message!r}, code={self.error_code!r})>"

    def to_dict(self) -> dict[str, Any]:
        """Convert exception to dictionary for JSON response."""
        result: dict[str, Any] = {"code": self.error_code, "message": self.message}
        if self.details:
            result["details"] = self.details
        return result


class AuthenticationError(AppException):
    """Authentication error (401)."""

    def __init__(
        self,
        message: str = "Authentication failed",
        error_code: ErrorCodeType | str = AuthErrorCode.AUTH_FAILED,
        details: dict[str, Any] | None = None,
    ):
        super().__init__(message, status_code=401, error_code=error_code, details=details)


class AuthorizationError(AppException):
    """Authorization error (403)."""

    def __init__(
        self,
        message: str = "Permission denied",
        error_code: ErrorCodeType | str = CommonErrorCode.PERMISSION_DENIED,
        details: dict[str, Any] | None = None,
    ):
        super().__init__(message, status_code=403, error_code=error_code, details=details)


class ValidationError(AppException):
    """Request validation error (422)."""

    def __init__(
        self,
        message: str,
        field_errors: dict[str, str] | None = None,
        error_code: ErrorCodeType | str = CommonErrorCode.VALIDATION_ERROR,
    ):
        details = {"field_errors": field_errors} if field_errors else {}
        super().__init__(message, status_code=422, error_code=error_code, details=details)
        self.field_errors = field_errors or {}


class NotFoundError(AppException):
    """Resource not found error (404)."""

    def __init__(
        self,
        resource: str,
        error_code: ErrorCodeType | str = CommonErrorCode.NOT_FOUND,
        details: dict[str, Any] | None = None,
    ):
        message = f"{resource} not found"
        super().__init__(message, status_code=404, error_code=error_code, details=details)


class BusinessError(AppException):
    """Business logic error (400)."""

    def __init__(
        self,
        message: str,
        error_code: ErrorCodeType | str,
        status_code: int = 400,
        details: dict[str, Any] | None = None,
    ):
        super().__init__(message, status_code=status_code, error_code=error_code, details=details)


class FileUploadError(AppException):
    """File upload error (400)."""

    def __init__(
        self,
        message: str,
        error_code: ErrorCodeType | str = FileErrorCode.INVALID_FILE_UPLOADED,
        details: dict[str, Any] | None = None,
    ):
        super().__init__(message, status_code=400, error_code=error_code, details=details)


class AIServiceError(AppException):
    """AI/LLM service error."""

    def __init__(
        self,
        message: str,
        error_code: ErrorCodeType | str = CommonErrorCode.SERVER_ERROR,
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        super().__init__(message, status_code=status_code, error_code=error_code, details=details)


class DatabaseError(AppException):
    """Database operation error (500)."""

    def __init__(
        self,
        message: str,
        error_code: ErrorCodeType | str = CommonErrorCode.SERVER_ERROR,
        details: dict[str, Any] | None = None,
    ):
        super().__init__(message, status_code=500, error_code=error_code, details=details)


def to_client_error(exc: Exception, fallback: str = "An internal error occurred") -> str:
    """Map an exception to a client/LLM-safe message.

    ``AppException`` carries an intentional user-facing message that can be
    surfaced; every other exception is reduced to a generic message so internal
    details (paths, SQL, stack traces) are never leaked to clients, the LLM, or
    persisted checkpoints. Callers must log the full exception separately
    (``logger.error(..., exc_info=True)``).
    """
    if isinstance(exc, AppException):
        return exc.message
    return fallback
