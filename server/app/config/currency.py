"""Centralized currency default constants.

Single Source of Truth for all currency-related defaults across the project.
All models, schemas, and inference logic MUST import from here instead of
hardcoding currency strings.

Design decisions:
- PROJECT_DEFAULT_CURRENCY = "CNY" because the product primarily targets
  Chinese-speaking users (base_locale=zh, DB server_defaults are CNY).
- Currency inference runs ONLY ONCE at registration time (via infer_currency).
  After that, the user's primary_currency is immutable unless explicitly
  changed through the settings API. There is NO background job or login hook
  that re-infers currency from locale.
"""

# The project-wide default currency used as:
# 1. SQLAlchemy model column default (Python-side)
# 2. Fallback when currency inference has no signal (no locale, no timezone)
# 3. UPSERT fallback in user_service when creating settings on-the-fly
PROJECT_DEFAULT_CURRENCY: str = "CNY"
