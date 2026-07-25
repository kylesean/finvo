"""Attachment processing middleware for multimodal LLM interactions.

This middleware handles image and document attachments in chat messages:
- Images: Routed through Vision Pipeline with graceful degradation
  - multimodal: Converted to base64 and injected as image_url content
  - placeholder: Replaced with descriptive text when LLM lacks vision support
- Documents: Text extraction for context injection (Phase 2)

Vision Pipeline Strategy:
    1. Check LLM vision capability via LLMRegistry.supports_vision()
    2. If supported → inject as multimodal content (image_url)
    3. If not supported → graceful degradation with text placeholder

Based on LangChain 1.0 middleware best practices.
"""

from __future__ import annotations

import base64
from pathlib import Path
from typing import Any, cast
from uuid import UUID

import aiofiles
from langchain_core.messages import BaseMessage, HumanMessage
from sqlalchemy import select

from app.core.config import settings
from app.core.langgraph.middleware.base import BaseMiddleware
from app.core.logging import logger
from app.models.attachment import Attachment


class AttachmentMiddleware(BaseMiddleware):
    """Middleware for processing message attachments.

    This middleware:
    1. Extracts attachment references from the config
    2. Loads attachment metadata from database
    3. Classifies attachments (image/document)
    4. For images: routes through Vision Pipeline with capability detection
       - multimodal LLM → base64 image_url injection
       - non-multimodal LLM → text placeholder degradation
    5. For documents: extracts text for context (Phase 2)

    Follows LangChain 1.0 middleware best practices.
    """

    name = "AttachmentMiddleware"

    # Supported image MIME types for multimodal LLM
    IMAGE_MIME_TYPES = {
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp",
    }

    # Supported document MIME types (Phase 2)
    DOCUMENT_MIME_TYPES = {
        "application/pdf",
        "text/plain",
        "text/markdown",
    }

    def __init__(self, db_session_factory: Any) -> None:
        """Initialize with database session factory.

        Args:
            db_session_factory: Callable that returns AsyncSession
        """
        self.db_session_factory = db_session_factory

    async def before_invoke(
        self,
        messages: list[BaseMessage],
        config: dict[str, Any],
    ) -> tuple[list[BaseMessage], dict[str, Any]]:
        """Process attachments before agent invocation.

        Args:
            messages: List of messages to send to agent
            config: Configuration dict for agent invocation

        Returns:
            Modified (messages, config) tuple with attachments processed
        """
        # Extract attachment IDs from config
        attachment_ids = config.get("configurable", {}).get("attachment_ids", [])
        user_uuid = config.get("configurable", {}).get("user_uuid")

        if not attachment_ids:
            logger.debug("attachment_middleware_skipped_no_attachments")
            return messages, config

        if not user_uuid:
            logger.warning("attachment_middleware_skipped_no_user_uuid")
            return messages, config

        # Get thread_id (session_id) from config for attachment linking
        thread_id = config.get("configurable", {}).get("thread_id")

        try:
            # Load attachments from database and update thread_id
            attachments = await self._load_attachments(attachment_ids, user_uuid, thread_id=thread_id)

            if not attachments:
                logger.warning(
                    "attachment_middleware_no_attachments_found",
                    requested_ids=attachment_ids,
                    user_uuid=user_uuid,
                )
                return messages, config

            # Classify attachments
            images, documents = self._classify_attachments(attachments)

            # Process images via Vision Pipeline (capability-aware)
            if images:
                vision_strategy = self._resolve_vision_strategy()
                messages = await self._inject_images(messages, images, vision_strategy)
                logger.info(
                    "attachment_images_injected",
                    image_count=len(images),
                    strategy=vision_strategy,
                    user_uuid=user_uuid,
                )

            # Register documents for RAG tool (Phase 2+)
            if documents:
                config = await self._register_documents(config, documents)
                logger.info(
                    "attachment_documents_registered",
                    document_count=len(documents),
                    user_uuid=user_uuid,
                )

            return messages, config

        except Exception as e:
            logger.error(
                "attachment_middleware_failed",
                error=str(e),
                attachment_ids=attachment_ids,
                user_uuid=user_uuid,
            )
            # Continue without attachments on error
            return messages, config

    async def _load_attachments(
        self,
        attachment_ids: list[str],
        user_uuid: str,
        thread_id: str | None = None,
    ) -> list[Attachment]:
        """Load attachments from database and optionally link to thread.

        Args:
            attachment_ids: List of attachment UUIDs
            user_uuid: User UUID for authorization
            thread_id: Optional thread/session ID to link attachments to

        Returns:
            List of Attachment objects
        """
        async with self.db_session_factory() as session:
            # Convert string IDs to UUIDs
            uuids = [UUID(aid) for aid in attachment_ids]

            # Query by user_uuid (string)
            stmt = select(Attachment).where(
                cast(Any, Attachment.id).in_(uuids),
                cast(Any, Attachment.user_uuid == user_uuid),
            )
            result = await session.execute(stmt)
            attachments = list(result.scalars().all())

            # Update thread_id for attachments that don't have one yet
            if thread_id and attachments:
                thread_id_str = str(thread_id)  # Ensure thread_id is string
                for att in attachments:
                    if att.thread_id is None:
                        att.thread_id = thread_id_str
                await session.commit()
                logger.info(
                    "attachments_linked_to_thread",
                    thread_id=thread_id,
                    attachment_count=len(attachments),
                )

            logger.debug(
                "attachments_loaded",
                requested=len(attachment_ids),
                found=len(attachments),
                thread_id=thread_id,
            )

            return attachments

    def _classify_attachments(
        self,
        attachments: list[Attachment],
    ) -> tuple[list[Attachment], list[Attachment]]:
        """Classify attachments into images and documents.

        Args:
            attachments: List of attachments to classify

        Returns:
            Tuple of (images, documents)
        """
        images = []
        documents = []

        for att in attachments:
            if att.mime_type in self.IMAGE_MIME_TYPES:
                images.append(att)
            elif att.mime_type in self.DOCUMENT_MIME_TYPES:
                documents.append(att)
            else:
                logger.debug(
                    "attachment_type_unknown",
                    attachment_id=str(att.id),
                    mime_type=att.mime_type,
                )

        return images, documents

    def _resolve_vision_strategy(self) -> str:
        """Determine the vision processing strategy based on LLM capabilities.

        Resolution order:
        1. LLMRegistry.supports_vision() checks env override + capabilities
        2. Returns 'multimodal' if vision is supported
        3. Returns 'placeholder' for graceful degradation

        Future (V2): Will support 'ocr' strategy when OCR_SERVICE_URL is configured.

        Returns:
            Strategy string: 'multimodal' | 'placeholder'
        """
        from app.services.llm import LLMRegistry

        if LLMRegistry.supports_vision():
            return "multimodal"

        # V2: OCR service integration point (pending settings.OCR_SERVICE_URL)

        return "placeholder"

    async def _inject_images(
        self,
        messages: list[BaseMessage],
        images: list[Attachment],
        strategy: str = "multimodal",
    ) -> list[BaseMessage]:
        """Inject image attachments into messages using the resolved strategy.

        Strategies:
        - multimodal: Convert to base64, inject as image_url content parts
        - placeholder: Replace with descriptive text (graceful degradation)

        Args:
            messages: List of messages
            images: List of image attachments
            strategy: Vision processing strategy

        Returns:
            Modified messages with image content injected
        """
        if strategy == "multimodal":
            return await self._inject_images_multimodal(messages, images)
        else:
            return self._inject_images_placeholder(messages, images)

    async def _inject_images_multimodal(
        self,
        messages: list[BaseMessage],
        images: list[Attachment],
    ) -> list[BaseMessage]:
        """Convert images to base64 and inject as multimodal content.

        For cloud LLMs (OpenAI, etc.), we must use base64 since
        they cannot access localhost URLs.

        Args:
            messages: List of messages
            images: List of image attachments

        Returns:
            Modified messages with multimodal content
        """
        # Build image parts
        image_parts = []
        for img in images:
            try:
                b64_data = await self._read_image_as_base64(img)
                image_parts.append(
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:{img.mime_type};base64,{b64_data}",
                            "detail": "auto",
                        },
                    }
                )
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

        if not image_parts:
            return messages

        # Default instruction when user sends image(s) without text (i18n)
        # Business context: In a personal finance app, image-only messages are
        # most likely receipts, invoices, or payment screenshots. The default
        # intent is to recognize and record the transaction.
        _IMAGE_ONLY_PROMPTS: dict[str, str] = {
            "zh": "请识别这张图片中的消费凭证信息（商户名称、金额、日期、消费类别），并帮我记录这笔账单。如果图片中包含多笔交易，请逐条记录。",
            "en": "Please recognize the transaction details in this image (merchant name, amount, date, spending category) and record it for me. If there are multiple transactions, record each one separately.",
            "ja": "この画像の消費証憑情報（店舗名、金額、日付、カテゴリ）を認識し、この取引を記録してください。複数の取引がある場合は、それぞれ個別に記録してください。",
            "ko": "이 이미지의 소비 증빙 정보(상호명, 금액, 날짜, 지출 카테고리)를 인식하고 이 거래를 기록해 주세요. 여러 건의 거래가 있으면 각각 기록해 주세요.",
        }

        from app.core.langgraph.tools.context import current_session_language

        lang = current_session_language.get()
        lang_key = lang.split("-")[0].lower() if lang else "zh"
        if lang_key not in _IMAGE_ONLY_PROMPTS:
            lang_key = "en"

        # Find last user message and convert to multimodal
        for i in range(len(messages) - 1, -1, -1):
            msg = messages[i]
            if isinstance(msg, HumanMessage):
                # Convert to multimodal format
                text_content = msg.content if isinstance(msg.content, str) else str(msg.content)

                # If user sent image(s) without text, provide a default instruction
                if not text_content.strip():
                    text_content = _IMAGE_ONLY_PROMPTS[lang_key]

                multimodal_content = [
                    {"type": "text", "text": text_content},
                    *image_parts,
                ]

                # save attachment_ids to additional_kwargs，used for frontend rendering
                attachment_ids = [str(img.id) for img in images]
                messages[i] = HumanMessage(
                    content=cast(Any, multimodal_content),
                    additional_kwargs={
                        **getattr(msg, "additional_kwargs", {}),
                        "attachment_ids": attachment_ids,
                    },
                )
                break

        return messages

    # Vision degradation placeholder messages (i18n)
    # Context: In a personal finance app, images are likely receipts/invoices.
    # The hint helps the LLM provide domain-relevant guidance even without vision.
    _VISION_PLACEHOLDER_MESSAGES: dict[str, dict[str, str]] = {
        "zh": {
            "single": "[用户发送了一张图片: {filename}（可能是消费小票、发票或支付截图）。当前模型不支持图片识别，无法查看图片内容。请告知用户切换到支持多模态的模型以启用拍照记账功能。]",
            "multiple": "[用户发送了 {count} 张图片: {filenames}（可能是消费凭证）。当前模型不支持图片识别，无法查看图片内容。请告知用户切换到支持多模态的模型以启用拍照记账功能。]",
        },
        "en": {
            "single": "[User sent an image: {filename} (likely a receipt, invoice, or payment screenshot). The current model does not support image recognition. Please inform the user to switch to a multimodal model to enable photo-based bookkeeping.]",
            "multiple": "[User sent {count} images: {filenames} (likely financial documents). The current model does not support image recognition. Please inform the user to switch to a multimodal model to enable photo-based bookkeeping.]",
        },
        "ja": {
            "single": "[ユーザーが画像を送信しました: {filename}（領収書、請求書、または決済スクリーンショットの可能性があります）。現在のモデルは画像認識に対応していません。写真記帳機能を有効にするには、マルチモーダルモデルに切り替えるようユーザーにお知らせください。]",
            "multiple": "[ユーザーが {count} 枚の画像を送信しました: {filenames}（消費証憑の可能性があります）。現在のモデルは画像認識に対応していません。写真記帳機能を有効にするには、マルチモーダルモデルに切り替えるようユーザーにお知らせください。]",
        },
        "ko": {
            "single": "[사용자가 이미지를 보냈습니다: {filename} (영수증, 청구서 또는 결제 스크린샷일 가능성). 현재 모델은 이미지 인식을 지원하지 않습니다. 사진 가계부 기능을 사용하려면 멀티모달 모델로 전환하도록 사용자에게 안내해 주세요.]",
            "multiple": "[사용자가 {count}장의 이미지를 보냈습니다: {filenames} (소비 증빙일 가능성). 현재 모델은 이미지 인식을 지원하지 않습니다. 사진 가계부 기능을 사용하려면 멀티모달 모델로 전환하도록 사용자에게 안내해 주세요.]",
        },
    }

    def _inject_images_placeholder(
        self,
        messages: list[BaseMessage],
        images: list[Attachment],
    ) -> list[BaseMessage]:
        """Degrade gracefully: replace images with descriptive text placeholder.

        When the configured LLM does not support vision (multimodal image input),
        we inject a localized text hint so the model is aware an image was sent,
        and preserve attachment_ids for frontend rendering.

        The placeholder message is localized based on the current session language
        (from X-App-Language header via current_session_language ContextVar).

        Args:
            messages: List of messages
            images: List of image attachments

        Returns:
            Modified messages with text placeholder
        """
        from app.core.langgraph.tools.context import current_session_language

        # Resolve session language for i18n
        lang = current_session_language.get()
        # Normalize: zh-Hant → zh, en-US → en, etc.
        lang_key = lang.split("-")[0].lower() if lang else "zh"
        if lang_key not in self._VISION_PLACEHOLDER_MESSAGES:
            lang_key = "en"  # Fallback to English for unsupported languages

        templates = self._VISION_PLACEHOLDER_MESSAGES[lang_key]

        # Build localized placeholder text
        filenames = [img.filename or f"image_{i}.jpg" for i, img in enumerate(images)]
        if len(filenames) == 1:
            placeholder_text = templates["single"].format(filename=filenames[0])
        else:
            names_str = ", ".join(filenames)
            placeholder_text = templates["multiple"].format(count=len(filenames), filenames=names_str)

        # Find last user message and append placeholder
        for i in range(len(messages) - 1, -1, -1):
            msg = messages[i]
            if isinstance(msg, HumanMessage):
                text_content = msg.content if isinstance(msg.content, str) else str(msg.content)
                # If user sent image(s) without text, use placeholder directly
                if text_content.strip():
                    degraded_content = f"{text_content}\n\n{placeholder_text}"
                else:
                    degraded_content = placeholder_text

                # Preserve attachment_ids for frontend rendering
                attachment_ids = [str(img.id) for img in images]
                messages[i] = HumanMessage(
                    content=degraded_content,
                    additional_kwargs={
                        **getattr(msg, "additional_kwargs", {}),
                        "attachment_ids": attachment_ids,
                        "vision_degraded": True,
                    },
                )
                break

        logger.info(
            "vision_degraded_placeholder_injected",
            image_count=len(images),
            language=lang_key,
            reason="llm_does_not_support_vision",
        )
        return messages

    async def _read_image_as_base64(self, attachment: Attachment) -> str:
        """Read image file and encode as base64.

        Args:
            attachment: Image attachment

        Returns:
            Base64 encoded string
        """
        file_path = Path(settings.UPLOAD_DIR) / attachment.object_key

        if not file_path.exists():
            raise FileNotFoundError(f"Image file not found: {file_path}")

        async with aiofiles.open(file_path, "rb") as f:
            content = await f.read()

        return base64.b64encode(content).decode("utf-8")

    async def _register_documents(
        self,
        config: dict[str, Any],
        documents: list[Attachment],
    ) -> dict[str, Any]:
        """Register documents in config for RAG tool access.

        Phase 2: Simple text extraction
        Phase 3: Vector store integration

        Args:
            config: Current config dict
            documents: List of document attachments

        Returns:
            Modified config with documents registered
        """
        doc_contexts = []

        for doc in documents:
            try:
                # Phase 2: Simple text extraction
                text = await self._extract_document_text(doc)
                doc_contexts.append(
                    {
                        "id": str(doc.id),
                        "filename": doc.filename,
                        "mime_type": doc.mime_type,
                        "text": text[:4000],  # Limit context length
                    }
                )
            except Exception as e:
                logger.error(
                    "document_extraction_failed",
                    attachment_id=str(doc.id),
                    error=str(e),
                )

        if doc_contexts:
            config.setdefault("configurable", {})
            config["configurable"]["available_documents"] = doc_contexts

        return config

    async def _extract_document_text(self, attachment: Attachment) -> str:
        """Extract text from document.

        Currently supports:
        - Plain text (.txt)
        - Markdown (.md)
        - PDF (Phase 2+, requires additional library)

        Args:
            attachment: Document attachment

        Returns:
            Extracted text content
        """
        file_path = Path(settings.UPLOAD_DIR) / attachment.object_key

        if not file_path.exists():
            raise FileNotFoundError(f"Document file not found: {file_path}")

        # Plain text and markdown
        if attachment.mime_type in {"text/plain", "text/markdown"}:
            async with aiofiles.open(file_path, encoding="utf-8") as f:
                return await f.read()

        # PDF - placeholder for Phase 2
        if attachment.mime_type == "application/pdf":
            return f"[PDF 文档: {attachment.filename},PDF 解析功能即将上线]"

        return f"[文档: {attachment.filename}]"
