"""Avatar endpoints.

Serves a user's avatar as a single public URL, ``/avatars/{user_uuid}``:

- If the user uploaded a custom avatar, the stored image bytes are returned
  (or an external avatar URL is redirected to).
- Otherwise a deterministic GitHub-style identicon is generated.

The endpoint is intentionally public (no auth). Avatars are non-sensitive,
display-only content, and being unauthenticated lets any image widget
(``NetworkImage``, ``<img>``) load them directly with no token plumbing.

Security boundary: this endpoint never accepts a raw attachment id from the
client. It only accepts a user UUID and resolves, server-side, the attachment
that *that user's* avatar points to (via ``get_file_path`` with the owner's
uuid). Private financial attachments therefore cannot be enumerated or read
through this route — they remain behind the authenticated ``/files/view``.
"""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query, Request, Response
from fastapi.responses import FileResponse, RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.aliases import DbSession
from app.core.config import settings
from app.core.exceptions import NotFoundError
from app.core.limiter import limiter
from app.core.logging import logger
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.services.upload_service import UploadService
from app.utils.identicon import render_identicon_png, render_identicon_svg

router = APIRouter(prefix="/avatars", tags=["avatars"])

_MIN_SIZE = 32
_MAX_SIZE = 512
_DEFAULT_SIZE = 256

# Identicon seed (UUID) is immutable, so the generated pattern never changes.
_IDENTICON_CACHE = "public, max-age=31536000, immutable"
# Uploaded avatars can change, so cache only briefly.
_UPLOAD_CACHE = "public, max-age=300"

_OUR_VIEW_PATH = "/files/view/"


def _attachment_id_from_url(avatar_url: str) -> UUID | None:
    raw_id = avatar_url.rsplit("/", 1)[-1]
    try:
        return UUID(raw_id)
    except ValueError:
        return None


async def _resolve_user(db: AsyncSession, user_uuid: UUID) -> User:
    user = await UserRepository(db).get_by_uuid(user_uuid)
    if user is None:
        raise NotFoundError("User")
    return user


@router.get("/{user_uuid}")
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["avatar"][0])
async def get_avatar(
    request: Request,
    user_uuid: UUID,
    db: DbSession,
    size: Annotated[int, Query(ge=_MIN_SIZE, le=_MAX_SIZE, description="Identicon size in pixels")] = _DEFAULT_SIZE,
) -> Response:
    """Return the user's avatar (uploaded image, redirect, or identicon)."""
    user = await _resolve_user(db, user_uuid)
    avatar_url = user.avatar_url

    if avatar_url:
        is_external = avatar_url.startswith(("http://", "https://")) and _OUR_VIEW_PATH not in avatar_url
        if is_external:
            return RedirectResponse(url=avatar_url, headers={"Cache-Control": _UPLOAD_CACHE})

        attachment_id = _attachment_id_from_url(avatar_url)
        if attachment_id is not None:
            try:
                upload_service = UploadService(db)
                file_path, attachment = await upload_service.get_file_path(
                    attachment_id=attachment_id,
                    user_uuid=user.uuid,
                )
                return FileResponse(
                    path=file_path,
                    media_type=attachment.mime_type or "image/png",
                    headers={"Cache-Control": _UPLOAD_CACHE},
                )
            except Exception as exc:  # noqa: BLE001 - degrade gracefully, never 500 an avatar
                logger.warning(
                    "avatar_upload_unavailable",
                    user_uuid=str(user_uuid),
                    error=str(exc),
                    error_type=type(exc).__name__,
                )

    png = render_identicon_png(str(user_uuid), size=size)
    return Response(content=png, media_type="image/png", headers={"Cache-Control": _IDENTICON_CACHE})


@router.get("/identicon/{user_uuid}.png")
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["avatar"][0])
async def get_identicon_png(
    request: Request,
    user_uuid: UUID,
    size: Annotated[int, Query(ge=_MIN_SIZE, le=_MAX_SIZE, description="Output size in pixels")] = _DEFAULT_SIZE,
) -> Response:
    """Return the generated identicon (ignoring any uploaded avatar) as PNG."""
    png = render_identicon_png(str(user_uuid), size=size)
    return Response(content=png, media_type="image/png", headers={"Cache-Control": _IDENTICON_CACHE})


@router.get("/identicon/{user_uuid}.svg")
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["avatar"][0])
async def get_identicon_svg(request: Request, user_uuid: UUID) -> Response:
    """Return the generated identicon (ignoring any uploaded avatar) as SVG."""
    svg = render_identicon_svg(str(user_uuid))
    return Response(content=svg, media_type="image/svg+xml", headers={"Cache-Control": _IDENTICON_CACHE})
