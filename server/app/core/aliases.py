"""Shared FastAPI dependency aliases.

Centralizes the cross-cutting ``Annotated[..., Depends(...)]`` aliases that
every v1 router needs, so each router imports them instead of redefining
``CurrentUser`` / ``DbSession`` locally (the duplicated ones).

Service-specific aliases (e.g. ``TxService``) are NOT centralized here: each
router imports its own service class anyway, a local alias carries full type
information, and centralizing them would require importing service classes at
module top-level in :mod:`app.core.service_deps`, which that module avoids via
lazy imports to prevent circular imports. ``DbSession`` is re-exported from
:mod:`app.core.service_deps` for back-compat with existing imports.
"""

from __future__ import annotations

from typing import Annotated

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_user
from app.models.user import User

# Authenticated user, resolved via JWT verification + DB lookup.
CurrentUser = Annotated[User, Depends(get_current_user)]

# Request-scoped async DB session. Unit-of-Work contract: services own the
# commit; the session is closed by ``get_session`` on exit.
DbSession = Annotated[AsyncSession, Depends(get_session)]
