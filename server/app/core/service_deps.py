"""Request-scoped service factories (FastAPI Depends). [P1-3]"""

from typing import TYPE_CHECKING

from app.core.aliases import DbSession

__all__ = [
    "DbSession",
    "get_auth_service",
    "get_budget_service",
    "get_exchange_rate_service",
    "get_forecast_service",
    "get_notification_service",
    "get_shared_space_service",
    "get_statistics_service",
    "get_storage_config_service",
    "get_transaction_query_service",
    "get_transaction_service",
    "get_upload_service",
    "get_user_service",
]


def get_transaction_service(db: DbSession) -> "TransactionService":
    """[P1-3] Build TransactionService for the request session."""
    from app.services.transaction_service import TransactionService

    return TransactionService(db)


def get_transaction_query_service(db: DbSession) -> "TransactionQueryService":
    """[P1-3] Build TransactionQueryService for the request session."""
    from app.services.transaction_query_service import TransactionQueryService

    return TransactionQueryService(db)


def get_user_service(db: DbSession) -> "UserService":
    """[P1-3] Build UserService for the request session."""
    from app.services.user_service import UserService

    return UserService(db)  # type: ignore[arg-type]  # sqlmodel vs sqlalchemy AsyncSession stubs


def get_auth_service(db: DbSession) -> "AuthService":
    """[P1-3] Build AuthService for the request session."""
    from app.services.auth_service import AuthService

    return AuthService(db)


def get_budget_service(db: DbSession) -> "BudgetService":
    """[P1-3] Build BudgetService for the request session."""
    from app.services.budget_service import BudgetService

    return BudgetService(db)


def get_statistics_service(db: DbSession) -> "StatisticsService":
    """[P1-3] Build StatisticsService for the request session."""
    from app.services.statistics_service import StatisticsService

    return StatisticsService(db)


def get_forecast_service(db: DbSession) -> "ForecastService":
    """[P1-3] Build ForecastService for the request session."""
    from app.services.forecast_service import ForecastService

    return ForecastService(db)


def get_shared_space_service(db: DbSession) -> "SharedSpaceService":
    """[P1-3] Build SharedSpaceService for the request session."""
    from app.services.shared_space_service import SharedSpaceService

    return SharedSpaceService(db)


def get_storage_config_service(db: DbSession) -> "StorageConfigService":
    """[P1-3] Build StorageConfigService for the request session."""
    from app.services.storage_config_service import StorageConfigService

    return StorageConfigService(db)


def get_upload_service(db: DbSession) -> "UploadService":
    """[P1-3] Build UploadService for the request session."""
    from app.services.upload_service import UploadService

    return UploadService(db)


def get_notification_service(db: DbSession) -> "NotificationService":
    """[P1-3] Build NotificationService for the request session."""
    from app.services.notification_service import NotificationService

    return NotificationService(db)


def get_exchange_rate_service() -> "ExchangeRateService":
    """[P1-3] Return the stateless exchange-rate singleton."""
    from app.services.exchange_rate_service import exchange_rate_service

    return exchange_rate_service


if TYPE_CHECKING:
    from app.services.auth_service import AuthService
    from app.services.budget_service import BudgetService
    from app.services.exchange_rate_service import ExchangeRateService
    from app.services.forecast_service import ForecastService
    from app.services.notification_service import NotificationService
    from app.services.shared_space_service import SharedSpaceService
    from app.services.statistics_service import StatisticsService
    from app.services.storage_config_service import StorageConfigService
    from app.services.transaction_query_service import TransactionQueryService
    from app.services.transaction_service import TransactionService
    from app.services.upload_service import UploadService
    from app.services.user_service import UserService
