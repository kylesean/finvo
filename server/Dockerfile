# ==============================================================================
# Stage 1: Builder - Install dependencies and build the application
# ==============================================================================
FROM python:3.13-slim-bookworm AS builder

WORKDIR /app

# Install system dependencies required for building
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager (pinned version for reproducible builds)
COPY --from=ghcr.io/astral-sh/uv:0.11.32 /uv /usr/local/bin/uv

# Set uv environment variables for optimization
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Copy dependency definition files first (for layer caching)
COPY pyproject.toml uv.lock ./

# Install dependencies (frozen, no dev/test groups, no project itself yet)
RUN uv sync --frozen --no-install-project --no-default-groups

# Copy the rest of the application
COPY . .

# Install the project itself
RUN uv sync --frozen --no-default-groups

# ==============================================================================
# Stage 2: Runtime - Minimal production image
# ==============================================================================
FROM python:3.13-slim-bookworm AS runtime

WORKDIR /app

# Install only runtime dependencies (no build tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for security
RUN useradd -m -u 1000 appuser

# Copy virtual environment and application code from builder stage
# Using --chown avoids a separate chown -R layer that would duplicate all files
COPY --chown=appuser:appuser --from=builder /app/.venv /app/.venv
COPY --chown=appuser:appuser --from=builder /app/app /app/app
COPY --chown=appuser:appuser --from=builder /app/alembic /app/alembic
COPY --chown=appuser:appuser --from=builder /app/alembic.ini /app/alembic.ini
COPY --chown=appuser:appuser --from=builder /app/pyproject.toml /app/pyproject.toml
COPY --chown=appuser:appuser --from=builder /app/scripts /app/scripts

# Set environment variables
ARG APP_ENV=production
ENV APP_ENV=${APP_ENV} \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH="/app" \
    PATH="/app/.venv/bin:$PATH"

# Setup directories and permissions (only for dirs not covered by COPY --chown)
RUN mkdir -p /app/logs /app/storage \
    && chmod +x /app/scripts/docker-entrypoint.sh \
    && chown appuser:appuser /app/logs /app/storage

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Entrypoint and default command
ENTRYPOINT ["/app/scripts/docker-entrypoint.sh"]
# Keep workers=1: the in-process scheduler, rate limiter and metrics assume a
# single process. Multiple workers cause duplicate scheduled job execution.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
