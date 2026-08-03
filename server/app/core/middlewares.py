"""Custom ASGI middleware for metrics, security headers, and logging context.

Implemented as pure ASGI middleware (instead of ``BaseHTTPMiddleware``) so
streaming responses (SSE, file downloads) pass through without buffering:
``BaseHTTPMiddleware`` wraps the response body and can interfere with
``StreamingResponse``, which is the core transport for the AI chat stream.
"""

from __future__ import annotations

import time
import uuid
from typing import Any

from starlette.datastructures import MutableHeaders
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from app.core.logging import (
    bind_context,
    clear_context,
)
from app.core.metrics import (
    http_request_duration_seconds,
    http_requests_total,
)


def _route_label(scope: Scope) -> str:
    """Normalize a request to its route template for use as a metrics label.

    Using the raw ``scope["path"]`` as the Prometheus ``endpoint`` label would
    produce one time-series per distinct path-parameter value (e.g. every
    transaction id in ``/api/v1/transactions/{id}``), ballooning memory and TSDB
    storage. Prefer the matched route template (``/api/v1/transactions/{}``) and
    fall back to the raw path only when no route matched (static files, mounted
    apps, streaming endpoints). The route is written into the scope by the
    router, so it is only available after the inner app has run.
    """
    route = scope.get("route")
    if route is not None and getattr(route, "path", None):
        return str(route.path)
    return str(scope.get("path", ""))


class MetricsMiddleware:
    """ASGI middleware for tracking HTTP request metrics."""

    def __init__(self, app: ASGIApp) -> None:
        """Initialize with the wrapped application."""
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        """Track metrics for each HTTP request."""
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        start_time = time.time()
        status_code = 500
        method = scope.get("method", "")

        async def send_wrapper(message: Message) -> None:
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = message["status"]
            await send(message)

        try:
            await self.app(scope, receive, send_wrapper)
        except Exception:
            status_code = 500
            raise
        finally:
            duration = time.time() - start_time

            endpoint = _route_label(scope)
            http_requests_total.labels(method=method, endpoint=endpoint, status=status_code).inc()
            http_request_duration_seconds.labels(method=method, endpoint=endpoint).observe(duration)


class SecurityHeadersMiddleware:
    """ASGI middleware for adding security headers to all responses."""

    def __init__(self, app: ASGIApp) -> None:
        """Initialize with the wrapped application."""
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        """Add security headers to each response."""
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        path = scope.get("path", "")

        async def send_wrapper(message: Message) -> None:
            if message["type"] == "http.response.start":
                headers = MutableHeaders(scope=message)
                # XSS Protection - Enables browser's built-in XSS filter
                # Note: Deprecated in modern browsers but still useful for legacy support
                headers["X-XSS-Protection"] = "1; mode=block"

                # Prevent MIME type sniffing - stops browsers from guessing content type
                headers["X-Content-Type-Options"] = "nosniff"

                # Clickjacking protection - prevents embedding in iframes
                # SAMEORIGIN allows same-origin embedding (for internal tools if needed)
                headers["X-Frame-Options"] = "SAMEORIGIN"

                # Content Security Policy - restrict resource loading sources
                # This is a basic policy; adjust based on your frontend requirements
                headers["Content-Security-Policy"] = (
                    "default-src 'self'; "
                    "script-src 'self' 'unsafe-inline' 'unsafe-eval'; "
                    "style-src 'self' 'unsafe-inline'; "
                    "img-src 'self' data: https:; "
                    "font-src 'self' data:; "
                    "connect-src 'self' https:; "
                    "frame-ancestors 'self';"
                )

                # Referrer Policy - controls information sent in Referer header
                headers["Referrer-Policy"] = "strict-origin-when-cross-origin"

                # Permissions Policy - disable unnecessary browser features
                headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=(), payment=(), usb=()"

                # Cache control for API responses - prevent caching of sensitive data
                # Only apply to API routes, not static files. Endpoints that serve
                # deterministic public content (e.g. generated identicon avatars) may
                # opt out by setting their own Cache-Control header explicitly.
                if path.startswith("/api/") and "Cache-Control" not in headers:
                    headers["Cache-Control"] = "no-store, no-cache, must-revalidate, private"
                    headers["Pragma"] = "no-cache"
            await send(message)

        await self.app(scope, receive, send_wrapper)


class LoggingContextMiddleware:
    """Bind request_id to the logging context for each request.

    ``user_uuid`` is bound separately by the ``get_current_user`` dependency
    once the authenticated user is resolved; this middleware does not decode
    the JWT.
    """

    def __init__(self, app: ASGIApp) -> None:
        """Initialize with the wrapped application."""
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        """Bind a request_id to the logging context for each request."""
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        request_id = str(uuid.uuid4())
        client = scope.get("client")
        try:
            # Clear any existing context from previous requests
            clear_context()

            bind_context(
                request_id=request_id,
                method=scope.get("method", ""),
                path=scope.get("path", ""),
                client_host=client[0] if client else "unknown",
            )

            async def send_wrapper(message: Message) -> None:
                # Add request_id to response headers for tracing
                if message["type"] == "http.response.start":
                    MutableHeaders(scope=message)["X-Request-ID"] = request_id
                await send(message)

            await self.app(scope, receive, send_wrapper)
        finally:
            # Always clear context after request is complete to avoid leaking to other requests
            clear_context()
