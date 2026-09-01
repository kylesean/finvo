"""This file contains the main application entry point."""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path
from typing import (
    Annotated,
    Any,
    cast,
)

from dotenv import load_dotenv
from fastapi import (
    Depends,
    FastAPI,
    Request,
    status,
)
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi_pagination import add_pagination
from langfuse import Langfuse
from slowapi.errors import RateLimitExceeded
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.database import db_manager
from app.core.exceptions import (
    AppException,
)
from app.core.limiter import limiter
from app.core.logging import logger
from app.core.metrics import setup_metrics
from app.core.middlewares import (
    LoggingContextMiddleware,
    MetricsMiddleware,
    SecurityHeadersMiddleware,
)
from app.core.responses import error_response, get_error_code_int, success_response
from app.utils.artifact_signing import verify_artifact_token

load_dotenv()

# Initialize Langfuse
langfuse = Langfuse(
    public_key=settings.LANGFUSE_PUBLIC_KEY,
    secret_key=settings.LANGFUSE_SECRET_KEY,
    host=settings.LANGFUSE_HOST,
)


def _detect_cmdline_workers() -> int:
    """Best-effort detection of ``uvicorn --workers N`` from /proc cmdline.

    Every uvicorn worker process carries the master's arguments, so reading
    our own cmdline is sufficient. Returns 1 when unknown (non-Linux,
    non-uvicorn launch) so the default topology stays silent.
    """
    try:
        with open("/proc/self/cmdline", "rb") as f:
            args = f.read().split(b"\x00")
    except OSError:
        return 1
    for i, arg in enumerate(args):
        if arg in (b"--workers", b"-w"):
            try:
                return max(1, int(args[i + 1]))
            except (IndexError, ValueError):
                return 1
    return 1


def _check_worker_topology() -> None:
    """Fail loudly when the single-process assumption is violated.

    The in-process scheduler (recurring transactions), WebSocket push,
    domain event bus, rate limiter and metrics all assume one worker.
    ``settings.UVICORN_WORKERS`` is the declared contract; the cmdline
    detection catches direct ``uvicorn --workers N`` launches that bypass
    the .env. ``FINVO_MULTI_WORKER=1`` acknowledges a topology where the
    in-process pieces have been replaced (e.g. Redis-backed), suppressing
    the warning.
    """
    workers = max(settings.UVICORN_WORKERS, _detect_cmdline_workers())
    if workers > 1 and not settings.FINVO_MULTI_WORKER:
        logger.warning(
            "single_process_assumption_violated",
            workers=workers,
            hint=(
                "in-process scheduler, WebSocket push, event bus, rate limiter and "
                "metrics assume a single worker; recurring transactions may run "
                "twice and realtime notifications may be silently lost. Set "
                "FINVO_MULTI_WORKER=1 only if the in-process pieces were replaced."
            ),
        )


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Handle application startup and shutdown events."""
    logger.info(
        "application_startup",
        project_name=settings.PROJECT_NAME,
        version=settings.VERSION,
        api_prefix=settings.API_V1_STR,
    )

    _check_worker_topology()

    # Initialize database
    from app.core.database import close_db, init_db

    await init_db()

    # Initialize LangGraph checkpointer pool (psycopg3)
    from app.core.checkpointer import close_checkpointer, init_checkpointer

    await init_checkpointer()

    # In development mode, auto-ensure external dependency tables (LangGraph, Mem0) are initialized
    if settings.is_development:
        try:
            from scripts.bootstrap import run_bootstrap

            await run_bootstrap()
        except Exception as e:
            logger.warning("development_auto_bootstrap_skipped", error=str(e))

    # Initialize Redis cache
    from app.core.cache import close_cache, init_cache

    await init_cache()

    # Initialize application scheduler
    from app.services.scheduler import init_scheduler, shutdown_scheduler

    await init_scheduler()

    # Register domain event handlers (notification system)
    from app.services.notification_handlers import register_space_notification_handlers

    register_space_notification_handlers()

    yield

    # Cleanup connections
    from app.core.background_tasks import background_task_manager

    await background_task_manager.shutdown()
    from app.services.exchange_rate_service import exchange_rate_service
    from app.services.memory.memory_service import MemoryService

    await exchange_rate_service.close()
    await MemoryService.close_instance()
    await shutdown_scheduler()
    await close_cache()
    await close_checkpointer()
    await close_db()
    logger.info("application_shutdown")


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=settings.DESCRIPTION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan,
)

# Add fastapi-pagination support
add_pagination(app)

# Set up Prometheus metrics
setup_metrics(app)

# Add logging context middleware (must be added before other middleware to capture context)
app.add_middleware(LoggingContextMiddleware)

# Add custom metrics middleware
app.add_middleware(MetricsMiddleware)

# Set up rate limiter exception handler
app.state.limiter = limiter


@app.exception_handler(RateLimitExceeded)
async def rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded) -> JSONResponse:
    """Handle rate limit exceeded errors with the unified response envelope.

    Replaces slowapi's stock handler (which returns a bare ``{"error": ...}``
    body and is a private API) so 429 responses keep the {code, message, data}
    format used by every other error path.
    """
    logger.warning(
        "rate_limit_exceeded",
        path=request.url.path,
        method=request.method,
        client_host=request.client.host if request.client else "unknown",
    )
    return error_response(
        code=get_error_code_int("RATE_LIMITED"),
        message=f"Rate limit exceeded: {exc.detail}",
        http_status=status.HTTP_429_TOO_MANY_REQUESTS,
    )


# ============================================================================
# Exception Handlers - Unified Response Format
# ============================================================================


@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    """Handle custom application exceptions.

    Returns unified {code, message, data} format.
    HTTP status code reflects the specific error type (4xx/5xx), while
    the response body contains structured business `code`, `message`, and `data`.

    Args:
        request: The request that caused the exception
        exc: The application exception

    Returns:
        JSONResponse: Unified response envelope
    """
    # Log the exception with context
    logger.error(
        "application_exception",
        error_code=exc.error_code,
        message=exc.message,
        status_code=exc.status_code,
        path=request.url.path,
        method=request.method,
        client_host=request.client.host if request.client else "unknown",
        details=exc.details if exc.details else None,
        exception_type=type(exc).__name__,
    )

    # Convert string error code to integer
    code_int = get_error_code_int(exc.error_code)

    # Use the exception's HTTP status code directly; the body still carries
    # `code`/`message` for machine-readable detail.
    http_status = exc.status_code

    # Include details in data field if present
    data = exc.details if exc.details else None

    return error_response(
        code=code_int,
        message=exc.message,
        data=data,
        http_status=http_status,
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """Handle validation errors from request data.

    Returns unified {code, message, data} format with field errors in data.

    Args:
        request: The request that caused the validation error
        exc: The validation error

    Returns:
        JSONResponse: Unified response envelope
    """
    # Format the errors to be more user-friendly
    formatted_errors = []
    for error in exc.errors():
        # Filter out 'body' from location path
        loc_parts = [str(loc_part) for loc_part in error["loc"] if loc_part != "body"]
        msg = error["msg"]

        # Remove "Value error, " prefix added by Pydantic
        if msg.startswith("Value error, "):
            msg = msg[len("Value error, ") :]

        # For model_validator errors, check if message contains "field_name: message" format
        if not loc_parts and ": " in msg:
            # Extract field name from message like "account: Invalid email format"
            parts = msg.split(": ", 1)
            if len(parts) == 2 and parts[0].isidentifier():
                loc_parts = [parts[0]]
                msg = parts[1]

        field = " -> ".join(loc_parts) if loc_parts else "_root"
        formatted_errors.append({"field": field, "message": msg})

    # For _root errors, add non-sensitive diagnostic metadata only. We must
    # NOT log the raw request body here: auth endpoints put passwords /
    # verification codes in the body, and persisting them to logs would leak
    # credentials. Capture only size/type (and field errors, already handled).
    log_extra: dict[str, Any] = {}
    if any(err["field"] == "_root" for err in formatted_errors):
        try:
            content_type = request.headers.get("content-type", "")
            log_extra["content_type"] = content_type
            body_len = int(request.headers.get("content-length", "0") or 0)
            # Fall back to actually measuring when the header is absent (chunked).
            log_extra["body_length"] = body_len or len(await request.body())
        except Exception as e:
            log_extra["body_read_error"] = str(e)

    # Log the validation error
    logger.warning(
        "validation_error",
        client_host=request.client.host if request.client else "unknown",
        path=request.url.path,
        method=request.method,
        errors=formatted_errors,
        **log_extra,
    )

    return error_response(
        code=get_error_code_int("VALIDATION_ERROR"),
        message="Validation error",
        data={"field_errors": formatted_errors},
        http_status=status.HTTP_422_UNPROCESSABLE_CONTENT,
    )


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException) -> JSONResponse:
    """Handle HTTP exceptions (404, 405, etc).

    Returns unified {code, message, data} format.

    Args:
        request: The request that caused the exception
        exc: The HTTP exception

    Returns:
        JSONResponse: Unified response envelope
    """
    logger.warning(
        "http_exception",
        status_code=exc.status_code,
        detail=exc.detail,
        path=request.url.path,
        method=request.method,
        client_host=request.client.host if request.client else "unknown",
    )

    # Map HTTP status codes to business error codes; anything not listed keeps
    # its HTTP status so the client still sees a meaningful, distinguishable code.
    error_code_map = {
        404: get_error_code_int("NOT_FOUND"),
        403: get_error_code_int("PERMISSION_DENIED"),
        401: get_error_code_int("AUTH_FAILED"),
        409: get_error_code_int("CONFLICT"),
        422: get_error_code_int("VALIDATION_ERROR"),
    }

    code = error_code_map.get(exc.status_code, exc.status_code)

    return error_response(
        code=code,
        message=str(exc.detail),
        http_status=exc.status_code,
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Handle all unhandled exceptions.

    Returns unified {code, message, data} format.

    Args:
        request: The request that caused the exception
        exc: The unhandled exception

    Returns:
        JSONResponse: Unified response envelope
    """
    # Log the full exception with traceback
    logger.exception(
        "unhandled_exception",
        exception_type=type(exc).__name__,
        exception_message=str(exc),
        path=request.url.path,
        method=request.method,
        client_host=request.client.host if request.client else "unknown",
    )

    # Prepare error data
    data = None
    if settings.DEBUG:
        data = {
            "exception_type": type(exc).__name__,
            "exception_message": str(exc),
        }

    return error_response(
        code=get_error_code_int("INTERNAL_ERROR"),
        message="An internal error occurred",
        data=data,
        http_status=status.HTTP_500_INTERNAL_SERVER_ERROR,
    )


# Set up CORS middleware
# Security: never combine `allow_credentials=True` with a wildcard origin.
# - If origins are restricted to an explicit list → credentials are safe.
# - If origins contain "*" (e.g. dev default) → credentials must be disabled
#   (browsers reject the combination anyway, and silently disabling prevents
#   accidental credential leakage if a wildcard slips into production config).
_allowed_origins = settings.allowed_origins_list
_allow_credentials = not (len(_allowed_origins) == 1 and _allowed_origins[0] == "*")
app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins,
    allow_credentials=_allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)
logger.info(
    "cors_configured",
    origins=_allowed_origins,
    allow_credentials=_allow_credentials,
)

# Add security headers middleware (XSS protection, clickjacking, etc.)
app.add_middleware(SecurityHeadersMiddleware)

# Include API router
app.include_router(api_router, prefix=settings.API_V1_STR)

# Artifact files (skill write_file output) are served ONLY through the
# authenticated endpoint below — never via an anonymous StaticFiles mount:
# artifacts can contain attacker-influenced HTML, and an anonymous mount
# would (a) expose any known URL to the whole network and (b) let that HTML
# execute scripts in the app's origin (stored XSS). The endpoint accepts
# either a signed capability URL (short-lived JWT from write_file) or the
# owner's Bearer access token.
_artifacts_dir = Path(__file__).parent.parent / "artifacts"
_artifacts_dir.mkdir(parents=True, exist_ok=True)
_artifact_security = HTTPBearer(auto_error=False)
_ARTIFACT_SANDBOX_CSP = "sandbox; default-src 'none'; style-src 'unsafe-inline'; img-src data: https:; media-src data:"


@app.get("/artifacts/{user_id}/{artifact_path:path}")
async def get_artifact(
    user_id: str,
    artifact_path: str,
    token: str = "",
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_artifact_security)] = None,
) -> FileResponse:
    """Serve an artifact file to its owner only.

    Two access channels (either is sufficient):
    1. ``?token=`` — short-lived capability JWT issued by write_file, bound
       to user_id + path (see utils/artifact_signing.py).
    2. Bearer access token of the artifact owner.
    """
    from app.core.exceptions import AuthenticationError, NotFoundError
    from app.utils.auth_utils import verify_token

    access_ok = False
    if token:
        verified = verify_artifact_token(token)
        if verified is not None and verified[0] == user_id and verified[1] == artifact_path:
            access_ok = True
    elif credentials:
        try:
            access_ok = verify_token(credentials.credentials) == user_id
        except ValueError:
            access_ok = False

    if not access_ok:
        raise AuthenticationError("Not authorized to access this artifact")

    # Path traversal guard: resolve within the user's artifact sandbox.
    user_artifacts = (_artifacts_dir / user_id).resolve()
    target = (user_artifacts / artifact_path).resolve()
    if not target.is_relative_to(user_artifacts) or not target.is_file():
        raise NotFoundError("Artifact not found")

    # sandbox CSP: even if the artifact HTML contains injected scripts, they
    # cannot execute nor reach the app's origin (no same-origin, no scripts).
    return FileResponse(
        target,
        headers={
            "Content-Security-Policy": _ARTIFACT_SANDBOX_CSP,
            "Cache-Control": "private, max-age=300",
        },
    )


@app.get("/")
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["root"][0])
async def root(request: Request) -> JSONResponse:
    """Root endpoint returning basic API information."""
    logger.info("root_endpoint_called")
    body = {
        "name": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "healthy",
        "environment": settings.ENVIRONMENT.value,
        "swagger_url": "/docs",
        "redoc_url": "/redoc",
    }
    return JSONResponse(status_code=status.HTTP_200_OK, content=body)


@app.get("/health")
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["health"][0])
async def health_check(request: Request) -> JSONResponse:
    """Health check endpoint with environment-specific information.

    Returns:
        JSONResponse: Unified response with health status
    """
    logger.info("health_check_called")

    # Check database connectivity
    db_healthy = await db_manager.health_check()

    # Check LangGraph checkpointer pool (psycopg3)
    from app.core.checkpointer import checkpointer_manager

    checkpointer_healthy = await checkpointer_manager.health_check()

    # Check Redis connectivity
    from app.core.cache import cache_manager

    redis_healthy = await cache_manager.health_check()

    # Check scheduler status
    from app.services.scheduler import app_scheduler

    scheduler_running = app_scheduler.is_running()

    # Redis is optional; database and checkpointer are required for core features
    all_healthy = db_healthy and checkpointer_healthy

    health_data = {
        "status": "healthy" if all_healthy else "degraded",
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT.value,
        "components": {
            "api": "healthy",
            "database": "healthy" if db_healthy else "unhealthy",
            "checkpointer": "healthy" if checkpointer_healthy else "unhealthy",
            "cache": "healthy" if redis_healthy else "unhealthy",
            "scheduler": "running" if scheduler_running else "stopped",
        },
        "timestamp": datetime.now().isoformat(),
    }

    # If any component is unhealthy, set the appropriate status code
    http_status = status.HTTP_200_OK if all_healthy else status.HTTP_503_SERVICE_UNAVAILABLE

    return success_response(data=health_data, http_status=http_status)
