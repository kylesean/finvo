"""Ephemeral multimodal helpers for the agent model node.

These helpers build the multimodal (base64 ``image_url``) payload that the *model*
sees, without ever touching the persisted / checkpointed user message. The
checkpoint keeps the compact, truthful user message (plain text + attachment id
references); the model node applies the image parts transiently to the prompt.

This mirrors the official LangChain ``wrap_model_call`` "transient update"
pattern, implemented by hand because this project builds its agent on a custom
LangGraph ``StateGraph`` (the top-level ``langchain`` package / ``create_agent``
middleware is not installed here).
"""

from __future__ import annotations

import asyncio
import base64
from pathlib import Path
from typing import Any
from uuid import UUID

import aiofiles
from sqlalchemy import select

from app.core.config import settings
from app.core.database import get_session_context
from app.core.logging import logger
from app.models.attachment import Attachment

# Single source of truth for image MIME types (also imported by AttachmentMiddleware).
IMAGE_MIME_TYPES = {
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp",
}

# Defense-in-depth caps for the transient multimodal payload. The upload path
# already enforces a 10MB per-file limit, but re-checking total size/count here
# guards against a huge number of small files producing an oversized prompt.
MAX_IMAGE_COUNT = 10
MAX_TOTAL_BYTES = 20 * 1024 * 1024  # 20MB total base64 payload


def _lang_key(lang: str | None) -> str:
    """Normalize a session language tag to a supported message key."""
    key = lang.split("-")[0].lower() if lang else "zh"
    return key if key in {"zh", "en", "ja", "ko"} else "en"


def vision_unsupported_message(lang: str | None) -> str:
    """Localized message shown when an image is sent to a non-vision model."""
    messages = {
        "zh": "当前模型不支持图片识别，无法处理上传的图片。请切换到支持多模态（视觉）的模型，或移除图片后重试。",
        "en": "The current model doesn't support image recognition and can't process the uploaded image(s). Switch to a vision-capable (multimodal) model, or remove the image(s) and try again.",
        "ja": "現在のモデルは画像認識に対応していないため、アップロードされた画像を処理できません。マルチモーダル（ビジョン）対応モデルに切り替えるか、画像を削除して再試行してください。",
        "ko": "현재 모델은 이미지 인식을 지원하지 않아 업로드된 이미지를 처리할 수 없습니다. 비전(멀티모달) 지원 모델로 전환하거나 이미지를 제거한 후 다시 시도해 주세요.",
    }
    return messages[_lang_key(lang)]


def build_multimodal_content(
    user_text: str,
    image_parts: list[dict[str, Any]],
) -> list[str | dict[Any, Any]]:
    """Build a multimodal content list: the user's real text (if any) + images.

    The return type matches ``HumanMessage.content``'s expected list element type
    exactly (``str | dict[Any, Any]``); a narrower ``list[dict[str, Any]]`` trips
    mypy's list-invariance check at the call site.
    """
    text = (user_text or "").strip()
    content: list[str | dict[Any, Any]] = []
    if text:
        content.append({"type": "text", "text": text})
    content.extend(image_parts)
    return content


async def _read_image_as_base64(object_key: str) -> str:
    """Read an image file from disk and encode it as base64."""
    file_path = Path(settings.UPLOAD_DIR) / object_key
    if not await asyncio.to_thread(file_path.exists):
        raise FileNotFoundError(f"Image file not found: {file_path}")
    async with aiofiles.open(file_path, "rb") as f:
        data = await f.read()
    return base64.b64encode(data).decode("utf-8")


def _to_image_part(attachment: Attachment, b64_data: str) -> dict[str, Any]:
    return {
        "type": "image_url",
        "image_url": {
            "url": f"data:{attachment.mime_type};base64,{b64_data}",
            "detail": "auto",
        },
    }


async def image_parts_from_attachments(
    images: list[Attachment],
) -> list[dict[str, Any]]:
    """Base64-encode already-loaded image ``Attachment`` rows into image_url parts."""
    if len(images) > MAX_IMAGE_COUNT:
        logger.warning(
            "image_count_limit_exceeded",
            count=len(images),
            max_count=MAX_IMAGE_COUNT,
        )
        images = images[:MAX_IMAGE_COUNT]

    parts: list[dict[str, Any]] = []
    total_bytes = 0
    for img in images:
        try:
            b64 = await _read_image_as_base64(img.object_key)
            total_bytes += len(b64)
            if total_bytes > MAX_TOTAL_BYTES:
                logger.warning(
                    "image_total_size_limit_exceeded",
                    attachment_id=str(img.id),
                    total_bytes=total_bytes,
                    max_bytes=MAX_TOTAL_BYTES,
                )
                break
            parts.append(_to_image_part(img, b64))
            logger.debug(
                "image_converted_to_base64",
                attachment_id=str(img.id),
                filename=img.filename,
            )
        except Exception as e:
            logger.error(
                "image_conversion_failed",
                attachment_id=str(img.id),
                error=str(e),
            )
    return parts


async def load_image_parts(
    attachment_ids: list[str],
    user_uuid: str | None,
) -> list[dict[str, Any]]:
    """Load attachments by id, keep images only, and return image_url parts.

    This is the resume-time fallback: resume bypasses middleware (it is a
    ``Command``), so the middleware's cached parts are absent from config and the
    model node rebuilds them from the stored attachment id references. Filtering by
    [IMAGE_MIME_TYPES] ensures document ids stored alongside image ids are skipped.
    """
    if not attachment_ids:
        return []

    try:
        uuids = [UUID(aid) for aid in attachment_ids]
    except ValueError:
        # Stored id references should always be valid UUIDs; a corrupt reference
        # must not crash the whole turn — degrade to "no images" instead.
        logger.warning("invalid_attachment_id_reference", attachment_ids=attachment_ids)
        return []

    async with get_session_context() as session:
        conditions: list[Any] = [Attachment.id.in_(uuids)]
        if user_uuid:
            conditions.append(Attachment.user_uuid == user_uuid)
        rows = (await session.execute(select(Attachment).where(*conditions))).scalars().all()

    images = [att for att in rows if att.mime_type in IMAGE_MIME_TYPES]
    return await image_parts_from_attachments(images)
