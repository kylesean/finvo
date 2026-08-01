"""Prometheus metrics configuration for the application.

This module sets up and configures Prometheus metrics for monitoring the application.
"""

import secrets
from typing import Any

from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest
from starlette.requests import Request
from starlette.responses import Response

from app.core.config import settings

# Request metrics
http_requests_total = Counter("http_requests_total", "Total number of HTTP requests", ["method", "endpoint", "status"])

http_request_duration_seconds = Histogram(
    "http_request_duration_seconds", "HTTP request duration in seconds", ["method", "endpoint"]
)

# Database metrics
db_connections = Gauge("db_connections", "Number of active database connections")

llm_inference_duration_seconds = Histogram(
    "llm_inference_duration_seconds",
    "Time spent processing LLM inference",
    ["model"],
    buckets=[0.1, 0.3, 0.5, 1.0, 2.0, 5.0],
)


llm_stream_duration_seconds = Histogram(
    "llm_stream_duration_seconds",
    "Time spent processing LLM stream inference",
    ["model"],
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0, 10.0],
)


async def metrics_endpoint(request: Request) -> Response:
    """Expose Prometheus metrics in the text exposition format.

    HTTP request metrics are collected by MetricsMiddleware (app.core.middleware).

    If settings.METRICS_TOKEN is set, requests must present it as a Bearer
    token to avoid leaking internal metrics publicly.
    """
    if settings.METRICS_TOKEN:
        auth = request.headers.get("Authorization", "")
        if not secrets.compare_digest(auth, f"Bearer {settings.METRICS_TOKEN}"):
            return Response("Unauthorized", status_code=401)
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


def setup_metrics(app: Any) -> None:
    """Set up Prometheus metrics endpoint.

    Args:
        app: FastAPI application instance
    """
    app.add_route("/metrics", metrics_endpoint, methods=["GET"], include_in_schema=False)
