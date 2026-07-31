"""Custom exception classes for the application.

This module provides a comprehensive exception hierarchy for handling
various error scenarios in the application. Uses modular StrEnum classes
for type-safe error codes organized by domain.
"""

from enum import StrEnum, auto
from typing import Any

# ============================================================================
# Domain-Specific Error Code Enums
# ============================================================================


class _AutoName(StrEnum):
    """Base class for auto-generating enum values from member names."""

    @staticmethod
    def _generate_next_value_(name: str, start: int, count: int, last_values: list[str]) -> str:
        return name


class CommonErrorCode(_AutoName):
    """Common/generic error codes."""

    SUCCESS = auto()
    SERVER_ERROR = auto()
    SYSTEM_INVALID = auto()
    INTERNAL_ERROR = auto()
    VALIDATION_ERROR = auto()
    NOT_FOUND = auto()
    PERMISSION_DENIED = auto()
    CONFLICT = auto()


class AuthErrorCode(_AutoName):
    """Authentication and authorization error codes."""

    AUTHENTICATE_FAILED = auto()
    AUTH_FAILED = auto()
    EMAIL_WRONG = auto()
    PHONE_NUMBER_WRONG = auto()
    PHONE_NUMBER_REGISTERED = auto()
    EMAIL_REGISTERED = auto()
    SEND_CODE_FAILED = auto()
    CODE_EXPIRED = auto()
    CODE_SEND_TOO_FREQUENTLY = auto()
    UNSUPPORTED_CODE_TYPE = auto()
    USER_NOT_MATCH_PASSWORD = auto()
    USER_NOT_EXIST = auto()
    NO_PREFERENCES_PARAMS = auto()
    INVALID_CLIENT_TIMEZONE = auto()


class FileErrorCode(_AutoName):
    """File upload and storage error codes."""

    NO_FILE_UPLOADED = auto()
    INVALID_FILE_UPLOADED = auto()
    FILE_TOO_LARGE = auto()
    INVALID_FILE_TYPE = auto()
    INVALID_MIME_TYPE = auto()
    INVALID_IMAGE_CONTENT = auto()
    IMAGE_TOO_WIDE = auto()
    IMAGE_TOO_HIGH = auto()
    TOO_MANY_FILES = auto()
    TOTAL_SIZE_TOO_LARGE = auto()
    FILE_READ_ERROR = auto()
    FILESYSTEM_ERROR = auto()
    UPLOAD_VERIFICATION_FAILED = auto()
    UPLOAD_ALL_FAILED = auto()
    INVALID_IMAGE_URLS = auto()
    FILE_NOT_FOUND = auto()
    IMAGE_COMPRESSION_FAILED = auto()


class TransactionErrorCode(_AutoName):
    """Transaction-related error codes."""

    TRANSACTION_COMMENT_NULL = auto()
    INVALID_PARENT_COMMENT_ID = auto()
    STORE_COMMENT_FAILED = auto()
    DELETE_COMMENT_FAILED = auto()
    TRANSACTION_NOT_EXISTS = auto()
    INVALID_RECURRENCE_RULE = auto()
    RECURRENCE_RULE_NOT_FOUND = auto()


class SpaceErrorCode(_AutoName):
    """Shared space error codes."""

    SHARED_SPACE_NOT_EXISTS_OR_NO_ACCESS = auto()
    NO_PERMISSION_TO_INVITE_MEMBERS = auto()
    CANNOT_INVITE_YOURSELF = auto()
    INVITATION_SENT = auto()
    ALREADY_MEMBER_OR_HAS_BEEN_INVITED = auto()
    INVALID_ACTION = auto()
    INVITATION_NOT_EXISTS = auto()
    ONLY_OWNER_CAN_DO = auto()
    OWNER_CANNOT_BE_REMOVED = auto()
    MEMBER_NOT_EXIST = auto()
    NOT_MEMBER_IN_THIS_SPACE = auto()
    OWNER_CANNOT_LEAVE_DIRECTLY = auto()
    INVALID_INVITATION_CODE = auto()
    INVITATION_CODE_EXPIRED_OR_LIMITED = auto()
    TRANSACTION_ALREADY_IN_SPACE = auto()


class AIErrorCode(_AutoName):
    """AI/LLM service error codes."""

    AI_CONTEXT_LIMIT_EXCEEDED = auto()
    CONVERSATION_ID_INVALID = auto()
    CONVERSATION_ID_NOT_OWNER = auto()
    TOKENS_LIMITED = auto()
    NO_USER_MESSAGE = auto()


class StorageErrorCode(_AutoName):
    """Storage configuration error codes."""

    INVALID_PROVIDER_TYPE = auto()
    CONFIG_NOT_FOUND = auto()
    CONFIG_IN_USE = auto()


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
