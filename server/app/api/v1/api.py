"""API v1 router configuration.

This module sets up the main API router and includes all sub-routers for different
endpoints like authentication and chatbot functionality.
"""

from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.avatar import router as avatar_router
from app.api.v1.budget import router as budget_router
from app.api.v1.chatbot import router as chatbot_router
from app.api.v1.exchange_rate import router as exchange_rate_router
from app.api.v1.financial_settings import router as financial_settings_router
from app.api.v1.home import router as home_router
from app.api.v1.memory import router as memory_router
from app.api.v1.notification import router as notification_router
from app.api.v1.shared_space import router as shared_space_router
from app.api.v1.statistics import router as statistics_router
from app.api.v1.storage_config import router as storage_config_router
from app.api.v1.transaction import router as transaction_router
from app.api.v1.upload import router as upload_router
from app.api.v1.user import router as user_router
from app.api.v1.version import router as version_router
from app.api.v1.ws import router as ws_router
from app.core.config import settings

api_router = APIRouter()

# Include routers
api_router.include_router(auth_router)
api_router.include_router(avatar_router)
api_router.include_router(chatbot_router)
api_router.include_router(home_router)
api_router.include_router(storage_config_router)
api_router.include_router(transaction_router)
api_router.include_router(upload_router)
api_router.include_router(user_router)
api_router.include_router(financial_settings_router)
api_router.include_router(statistics_router)
api_router.include_router(shared_space_router)
api_router.include_router(notification_router)
api_router.include_router(exchange_rate_router)
api_router.include_router(memory_router)
api_router.include_router(budget_router)
api_router.include_router(version_router)
api_router.include_router(ws_router)


# NOTE: This endpoint intentionally returns a plain dict (not the unified
# {code, message, data} envelope) because the Flutter client reads
# ``version``/``environment`` directly from the response root in
# ``server_config_service.dart``. The comprehensive ``/health`` endpoint in
# ``main.py`` returns the envelope format and checks backing services; this
# one is a lightweight liveness probe for client server-config discovery.
@api_router.get("/health")
async def health_check() -> dict[str, str]:
    """Lightweight health check for client server-config discovery.

    Returns:
        dict: Health status, version, and environment.
    """
    return {
        "status": "healthy",
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT.value,
    }
