"""Custom middleware for tracking metrics and other cross-cutting concerns."""

import time
import uuid
from collections.abc import Callable
from typing import Any

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response

from app.core.logging import (
    bind_context,
    clear_context,
)
from app.core.metrics import (
    http_request_duration_seconds,
    http_requests_total,
)


def _route_label(request: Request) -> str:
    """Normalize a request to its route template for use as a metrics label.

    Using the raw ``request.url.path`` as the Prometheus ``endpoint`` label would
    produce one time-series per distinct path-parameter value (e.g. every
    transaction id in ``/api/v1/transactions/{id}``), ballooning memory and TSDB
    storage. Prefer the matched route template (``/api/v1/transactions/{}``) and
    fall back to the raw path only when no route matched (static files, mounted
    apps, streaming endpoints).
    """
    route = request.scope.get("route")
    if route is not None and getattr(route, "path", None):
        return str(route.path)
    return request.url.path


class MetricsMiddleware(BaseHTTPMiddleware):
    """Middleware for tracking HTTP request metrics."""

    async def dispatch(self, request: Request, call_next: Callable[..., Any]) -> Response:
        """Track metrics for each request.

        Args:
            request: The incoming request
            call_next: The next middleware or route handler

        Returns:
            Response: The response from the application
        """
        start_time = time.time()

        try:
            response: Response = await call_next(request)
            status_code = response.status_code
        except Exception:
            status_code = 500
            raise
        finally:
            duration = time.time() - start_time

            # Record metrics
            endpoint = _route_label(request)
            http_requests_total.labels(method=request.method, endpoint=endpoint, status=status_code).inc()

            http_request_duration_seconds.labels(method=request.method, endpoint=endpoint).observe(duration)

        return response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Middleware for adding security headers to all responses.

    This middleware adds essential security headers to protect against:
    - XSS (Cross-Site Scripting) attacks
    - Clickjacking attacks
    - MIME type sniffing attacks
    - Information leakage
    """

    async def dispatch(self, request: Request, call_next: Callable[..., Any]) -> Response:
        """Add security headers to each response.

        Args:
            request: The incoming request
            call_next: The next middleware or route handler

        Returns:
            Response: The response with security headers added
        """
        response: Response = await call_next(request)

        # XSS Protection - Enables browser's built-in XSS filter
        # Note: Deprecated in modern browsers but still useful for legacy support
        response.headers["X-XSS-Protection"] = "1; mode=block"

        # Prevent MIME type sniffing - stops browsers from guessing content type
        response.headers["X-Content-Type-Options"] = "nosniff"

        # Clickjacking protection - prevents embedding in iframes
        # SAMEORIGIN allows same-origin embedding (for internal tools if needed)
        response.headers["X-Frame-Options"] = "SAMEORIGIN"

        # Content Security Policy - restrict resource loading sources
        # This is a basic policy; adjust based on your frontend requirements
        response.headers["Content-Security-Policy"] = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline' 'unsafe-eval'; "
            "style-src 'self' 'unsafe-inline'; "
            "img-src 'self' data: https:; "
            "font-src 'self' data:; "
            "connect-src 'self' https:; "
            "frame-ancestors 'self';"
        )

        # Referrer Policy - controls information sent in Referer header
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"

        # Permissions Policy - disable unnecessary browser features
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=(), payment=(), usb=()"

        # Cache control for API responses - prevent caching of sensitive data
        # Only apply to API routes, not static files. Endpoints that serve
        # deterministic public content (e.g. generated identicon avatars) may
        # opt out by setting their own Cache-Control header explicitly.
        if request.url.path.startswith("/api/") and "Cache-Control" not in response.headers:
            response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, private"
            response.headers["Pragma"] = "no-cache"

        return response


class LoggingContextMiddleware(BaseHTTPMiddleware):
    """Bind request_id to the logging context for each request.

    ``user_uuid`` is bound separately by the ``get_current_user`` dependency
    once the authenticated user is resolved; this middleware does not decode
    the JWT.
    """

    async def dispatch(self, request: Request, call_next: Callable[..., Any]) -> Response:
        """Bind a request_id to the logging context for each request.

        Args:
            request: The incoming request
            call_next: The next middleware or route handler

        Returns:
            Response: The response from the application
        """
        try:
            # Clear any existing context from previous requests
            clear_context()

            # Generate unique request ID
            request_id = str(uuid.uuid4())
            bind_context(
                request_id=request_id,
                method=request.method,
                path=request.url.path,
                client_host=request.client.host if request.client else "unknown",
            )

            # Process the request. Authenticated user_uuid is bound to the
            # logging context by the get_current_user dependency, not here.
            response: Response = await call_next(request)

            # Add request_id to response headers for tracing
            response.headers["X-Request-ID"] = request_id

            return response

        finally:
            # Always clear context after request is complete to avoid leaking to other requests
            clear_context()
