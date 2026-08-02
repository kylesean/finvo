"""File upload service.

Best practice: Separate file processing and database operations.
1. Process all files first (validation, compression, saving to disk/S3)
2. Batch insert database records once
3. Single database commit
"""

from __future__ import annotations

import hashlib
import io
import mimetypes
import uuid
from collections.abc import AsyncGenerator
from datetime import UTC, datetime
from pathlib import Path
from typing import Any
from uuid import UUID

import aiofiles
import aiofiles.os
from fastapi import UploadFile
from PIL import Image
from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.concurrency import run_in_threadpool

from app.core.config import settings
from app.core.exceptions import BusinessError
from app.core.logging import logger
from app.models.attachment import Attachment
from app.models.shared_space import SpaceMember
from app.models.storage_config import ProviderType, StorageConfig
from app.services.storage.adapters.base import StorageAdapter
from app.services.storage.adapters.factory import StorageAdapterFactory

# ============================================================================
# File Type Configuration
# ============================================================================

IMAGE_EXTENSIONS = {"jpg", "jpeg", "png", "gif", "webp", "bmp", "ico", "svg"}
IMAGE_MIME_TYPES = {
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp",
    "image/bmp",
    "image/x-icon",
    "image/svg+xml",
}

DOCUMENT_EXTENSIONS = {
    "pdf",
    "doc",
    "docx",
    "xls",
    "xlsx",
    "ppt",
    "pptx",
    "txt",
    "md",
    "csv",
    "json",
    "xml",
    "html",
    "htm",
    "rtf",
    "odt",
    "ods",
    "odp",
}
DOCUMENT_MIME_TYPES = {
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.ms-powerpoint",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "text/plain",
    "text/markdown",
    "text/csv",
    "application/json",
    "application/xml",
    "text/xml",
    "text/html",
    "application/rtf",
    "application/vnd.oasis.opendocument.text",
    "application/vnd.oasis.opendocument.spreadsheet",
    "application/vnd.oasis.opendocument.presentation",
}

ALLOWED_EXTENSIONS = IMAGE_EXTENSIONS | DOCUMENT_EXTENSIONS
ALLOWED_MIME_TYPES = IMAGE_MIME_TYPES | DOCUMENT_MIME_TYPES
COMPRESSIBLE_FORMATS = {"jpg", "jpeg", "png", "webp"}


class UploadService:
    """File upload service supporting local storage and S3-compatible storage.

    Automatically selects storage backend based on settings.STORAGE_PROVIDER:
    - local_uploads: Local filesystem
    - s3_compatible: S3 compatible storage (Supabase, MinIO, AWS S3)
    """

    MAX_FILE_SIZE: int = settings.MAX_UPLOAD_SIZE
    UPLOAD_DIR: Path = settings.UPLOAD_DIR
    IMAGE_MAX_WIDTH: int = 1920
    IMAGE_MAX_HEIGHT: int = 1920
    IMAGE_QUALITY: int = 85

    def __init__(self, db: AsyncSession):
        self.db = db
        self._adapter: StorageAdapter | None = None
        self._provider_type: str | None = None

    async def upload_files(
        self,
        files: list[UploadFile],
        user_uuid: UUID,
        compress: bool = True,
        thread_id: UUID | None = None,
    ) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
        """Batch upload files.

        Pipeline:
        1. Process files (file I/O, no DB operations)
        2. Batch create DB records in single commit

        Args:
            files: List of upload files
            user_uuid: User UUID
            compress: Whether to compress images
            thread_id: Optional session thread ID

        Returns:
            Tuple of (successful_list, failed_list)
        """
        # Phase 1: Retrieve storage config and initialize adapter
        storage_config_id, storage_config = await self._get_or_create_storage_config(user_uuid)
        self._adapter = await StorageAdapterFactory.create(storage_config)
        # Resolve the provider from the per-user config actually in use, not the
        # global settings default (they can differ for a configured user).
        self._provider_type = storage_config.provider_type

        # Phase 2: Process all files (pure file I/O)
        processed = []  # Successfully processed file metadata
        failed = []  # Failed files

        for file in files:
            try:
                file_info = await self._process_and_save_file(
                    file=file,
                    user_uuid=user_uuid,
                    compress=compress,
                )
                processed.append(file_info)
            except BusinessError as e:
                failed.append(
                    {
                        "filename": file.filename,
                        "error": e.message,
                        "errorCode": e.error_code,
                    }
                )
            except Exception as e:
                logger.error("file_process_error", filename=file.filename, error=str(e))
                failed.append(
                    {
                        "filename": file.filename,
                        "error": "File processing failed",
                        "errorCode": "PROCESS_FAILED",
                    }
                )

        if not processed:
            return [], failed

        # Phase 3: Batch create database records
        attachments = []
        for info in processed:
            attachment = Attachment(
                user_uuid=user_uuid,
                storage_config_id=storage_config_id,
                thread_id=thread_id,
                filename=info["filename"],
                object_key=info["object_key"],
                mime_type=info["mime_type"],
                size=info["size"],
                hash=info["hash"],
            )
            attachments.append(attachment)

        self.db.add_all(attachments)
        try:
            await self.db.commit()
        except Exception:
            await self.db.rollback()
            # DB records failed to persist, so the physical files already written
            # in Phase 2 would be orphaned. Best-effort delete them before rethrowing.
            if self._adapter is not None:
                for info in processed:
                    try:
                        await self._adapter.delete(info["object_key"])
                    except Exception as del_exc:  # noqa: BLE001
                        logger.error("orphan_file_cleanup_failed", object_key=info["object_key"], error=str(del_exc))
            raise

        # Refresh for IDs
        for att in attachments:
            await self.db.refresh(att)

        # Phase 4: Construct results
        successful = []

        for i, att in enumerate(attachments):
            info = processed[i]
            att_id = str(att.id)
            # Build the download URL from the actual storage backend (local → signed
            # /api/v1/files/stream URL, S3 → presigned URL) so every backend yields a
            # working link instead of always pointing at the local-disk view route.
            try:
                uri = await self._adapter.get_download_url(object_key=info["object_key"], filename=info["filename"])
            except Exception as e:  # noqa: BLE001
                logger.error("download_url_generation_failed", object_key=info["object_key"], error=str(e))
                uri = ""
            successful.append(
                {
                    "id": att_id,
                    "attachmentId": att_id,
                    "originalName": info["filename"],
                    "filename": info["filename"],
                    "objectKey": info["object_key"],
                    "uri": uri,
                    "size": info["size"],
                    "mimeType": info["mime_type"],
                    "hash": info["hash"],
                    "compressed": info["compressed"],
                    "threadId": str(thread_id) if thread_id else None,
                }
            )

        logger.info(
            "batch_upload_completed",
            user_uuid=user_uuid,
            total=len(files),
            successful=len(successful),
            failed=len(failed),
        )

        return successful, failed

    async def _get_or_create_storage_config(self, user_uuid: UUID) -> tuple[int | None, StorageConfig]:
        """Obtain or create user's default storage configuration.

        Selects storage backend type based on settings.STORAGE_PROVIDER.

        Args:
            user_uuid: User UUID

        Returns:
            Tuple[config_id, StorageConfig]
        """
        target_provider = settings.STORAGE_PROVIDER

        stmt = select(StorageConfig).where(
            StorageConfig.user_uuid == user_uuid,
            StorageConfig.provider_type == target_provider,
        )
        result = await self.db.execute(stmt)
        config = result.scalar_one_or_none()

        if config:
            return config.id, config

        # Create new configuration
        if target_provider == ProviderType.S3_COMPATIBLE.value:
            from app.utils.encryption import credential_encryption

            # Server-side S3 credentials are stored encrypted (Fernet) — never
            # plaintext in the DB (contract shared with StorageConfigService).
            new_config = StorageConfig(
                user_uuid=user_uuid,
                provider_type=target_provider,
                name="S3 Storage",
                base_path=settings.S3_BUCKET,
                credentials={
                    "_encrypted": credential_encryption.encrypt_credentials(
                        {
                            "endpoint_url": settings.S3_ENDPOINT,
                            "access_key": settings.S3_ACCESS_KEY,
                            "secret_key": settings.S3_SECRET_KEY,
                            "region": settings.S3_REGION,
                        }
                    ),
                },
                is_readonly=False,
            )
        else:
            new_config = StorageConfig(
                user_uuid=user_uuid,
                provider_type=ProviderType.LOCAL_UPLOADS.value,
                name="Local Storage",
                base_path=str(self.UPLOAD_DIR),
                is_readonly=False,
            )

        self.db.add(new_config)
        await self.db.commit()
        await self.db.refresh(new_config)

        logger.info(
            "storage_config_created",
            user_uuid=user_uuid,
            config_id=new_config.id,
            provider=target_provider,
        )
        return new_config.id, new_config

    async def _process_and_save_file(
        self,
        file: UploadFile,
        user_uuid: UUID,
        compress: bool,
    ) -> dict[str, Any]:
        """Process and save individual file (supporting local and S3 storage adapters).

        Returns:
            Dictionary containing processed file metadata
        """
        upload_id = f"up_{uuid.uuid4().hex[:8]}"

        # 1. Validate and read file content
        content = await self._validate_and_read(file)

        # 2. Extract file extension and MIME type
        filename = file.filename or "unnamed_file"
        extension = self._get_extension(filename)
        mime_type = file.content_type
        guessed_type, _ = mimetypes.guess_type(filename)
        if guessed_type:
            mime_type = guessed_type

        # 3. Compress image if requested (flag reflects whether compression actually
        #    succeeded — a failure returns the original bytes untouched)
        compressed = False
        if compress and extension.lower() in COMPRESSIBLE_FORMATS:
            content, compressed = await run_in_threadpool(self._compress_image, content, extension)

        # 4. Compute file hash
        file_hash = hashlib.sha256(content).hexdigest()

        # 5. Generate storage object key
        object_key = self._generate_object_key(extension, upload_id)

        # 6. Save file payload according to adapter backend
        if self._adapter is not None and self._provider_type != "local_uploads":

            async def content_generator() -> AsyncGenerator[bytes]:
                yield content

            object_key = await self._adapter.save(
                file_stream=content_generator(),
                filename=filename,
                content_type=mime_type,
            )
            logger.debug(
                "file_saved_via_adapter",
                upload_id=upload_id,
                filename=file.filename,
                size=len(content),
                provider=self._provider_type,
            )
        else:
            file_path = self.UPLOAD_DIR / object_key
            await aiofiles.os.makedirs(file_path.parent, exist_ok=True)
            async with aiofiles.open(file_path, "wb") as f:
                await f.write(content)
            logger.debug(
                "file_saved_locally",
                upload_id=upload_id,
                filename=file.filename,
                size=len(content),
            )

        return {
            "filename": file.filename,
            "object_key": object_key,
            "mime_type": mime_type,
            "size": len(content),
            "hash": file_hash,
            "compressed": compressed,
        }

    # =========================================================================
    # Public Methods
    # =========================================================================

    async def _resolve_attachment(self, attachment_id: UUID, user_uuid: UUID) -> Attachment:
        """Load an attachment and enforce owner / shared-space access."""
        stmt = select(Attachment).where(Attachment.id == attachment_id)
        result = await self.db.execute(stmt)
        attachment = result.scalar_one_or_none()

        if not attachment:
            raise BusinessError(
                message="Attachment not found or access denied",
                status_code=404,
                error_code="FILE_NOT_FOUND",
            )

        # Validate access permission: owner or shared space co-member
        if attachment.user_uuid != user_uuid:
            shared_space_stmt = (
                select(SpaceMember.space_id)
                .where(
                    and_(
                        SpaceMember.user_uuid == user_uuid,
                        SpaceMember.status == "ACCEPTED",
                    )
                )
                .intersect(
                    select(SpaceMember.space_id).where(
                        and_(
                            SpaceMember.user_uuid == attachment.user_uuid,
                            SpaceMember.status == "ACCEPTED",
                        )
                    )
                )
            )
            shared_space_res = await self.db.execute(shared_space_stmt)
            if not shared_space_res.first():
                raise BusinessError(
                    message="Attachment not found or access denied",
                    status_code=404,
                    error_code="FILE_NOT_FOUND",
                )

        return attachment

    async def _get_attachment_adapter(self, attachment: Attachment) -> tuple[StorageAdapter | None, str | None]:
        """Resolve the storage adapter + provider type for an attachment's config.

        Returns ``(None, None)`` for legacy attachments without a config, which
        are treated as local files.
        """
        if attachment.storage_config_id is None:
            return None, None
        config = await self.db.get(StorageConfig, attachment.storage_config_id)
        if config is None:
            return None, None
        adapter = await StorageAdapterFactory.create(config)
        return adapter, config.provider_type

    async def get_file_path(self, attachment_id: UUID, user_uuid: UUID) -> tuple[Path, Attachment]:
        """Obtain local file path for attachment.

        Only valid for local storage. Remote (S3/WebDAV) attachments must be
        served through their adapter-issued signed URL instead — see
        ``_get_attachment_adapter``.

        Args:
            attachment_id: Attachment ID
            user_uuid: User UUID
        """
        attachment = await self._resolve_attachment(attachment_id, user_uuid)

        _, provider_type = await self._get_attachment_adapter(attachment)
        if provider_type and provider_type != ProviderType.LOCAL_UPLOADS.value:
            raise BusinessError(
                message="File is stored on remote storage; use the signed URL",
                status_code=404,
                error_code="FILE_NOT_FOUND",
            )

        file_path = (self.UPLOAD_DIR / attachment.object_key).resolve()

        if not file_path.exists():
            raise BusinessError(
                message="File not found",
                status_code=404,
                error_code="FILE_NOT_FOUND",
            )

        return file_path, attachment

    async def delete_file(self, attachment_id: UUID, user_uuid: UUID) -> bool:
        """Delete attachment file (through its storage backend) and DB record."""
        attachment = await self._resolve_attachment(attachment_id, user_uuid)

        adapter, provider_type = await self._get_attachment_adapter(attachment)
        if provider_type and provider_type != ProviderType.LOCAL_UPLOADS.value:
            # Remote backend: delete the object via the adapter so no orphaned
            # object is left behind on S3/WebDAV.
            if adapter is not None:
                await adapter.delete(attachment.object_key)
        else:
            file_path = (self.UPLOAD_DIR / attachment.object_key).resolve()
            if file_path.exists():
                await aiofiles.os.remove(file_path)

        await self.db.delete(attachment)
        await self.db.commit()
        return True

    # =========================================================================
    # Private Helper Methods
    # =========================================================================

    async def _validate_and_read(self, file: UploadFile) -> bytes:
        """Validate and read upload file content."""
        if not file.filename:
            raise BusinessError(
                message="Filename must not be empty",
                status_code=400,
                error_code="INVALID_FILENAME",
            )

        extension = self._get_extension(file.filename)
        if extension.lower() not in ALLOWED_EXTENSIONS:
            raise BusinessError(
                message=f"Unsupported file type: .{extension}",
                status_code=400,
                error_code="INVALID_FILE_TYPE",
            )

        content = bytearray()
        _read_chunk_size = 1024 * 1024  # 1MB chunks bound peak memory to ~MAX_FILE_SIZE
        while True:
            chunk = await file.read(_read_chunk_size)
            if not chunk:
                break
            content.extend(chunk)
            if len(content) > self.MAX_FILE_SIZE:
                size_mb = self.MAX_FILE_SIZE / (1024 * 1024)
                raise BusinessError(
                    message=f"File size exceeds limit ({size_mb:.1f}MB)",
                    status_code=400,
                    error_code="FILE_TOO_LARGE",
                )

        if len(content) == 0:
            raise BusinessError(
                message="File content is empty",
                status_code=400,
                error_code="FILE_EMPTY",
            )

        return bytes(content)

    def _get_extension(self, filename: str) -> str:
        """Extract lower-case file extension."""
        if "." not in filename:
            return ""
        return filename.rsplit(".", 1)[-1].lower()

    def _generate_object_key(self, extension: str, upload_id: str) -> str:
        """Generate storage object key."""
        now = datetime.now(UTC)
        date_path = now.strftime("%Y/%m/%d")
        unique_suffix = uuid.uuid4().hex[:12]
        return f"{date_path}/{upload_id}_{unique_suffix}.{extension}"

    def _compress_image(self, content: bytes, extension: str) -> tuple[bytes, bool]:
        """Compress image bytes synchronously.

        Returns:
            Tuple of (content, was_compressed): on any failure the ORIGINAL bytes
            are returned with ``was_compressed=False`` so callers can report the
            result accurately instead of claiming compression that did not happen.
        """
        try:
            image: Image.Image = Image.open(io.BytesIO(content))
            original_width, original_height = image.size

            if original_width > self.IMAGE_MAX_WIDTH or original_height > self.IMAGE_MAX_HEIGHT:
                ratio = original_width / original_height
                if original_width > original_height:
                    new_width = self.IMAGE_MAX_WIDTH
                    new_height = int(new_width / ratio)
                else:
                    new_height = self.IMAGE_MAX_HEIGHT
                    new_width = int(new_height * ratio)
                image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)

            if image.mode == "RGBA" and extension.lower() in ("jpg", "jpeg"):
                background = Image.new("RGB", image.size, (255, 255, 255))
                background.paste(image, mask=image.split()[3])
                image = background

            buffer = io.BytesIO()
            format_map = {"jpg": "JPEG", "jpeg": "JPEG", "png": "PNG", "webp": "WEBP"}
            save_format = format_map.get(extension.lower(), "PNG")

            save_kwargs = {}
            if save_format == "JPEG":
                save_kwargs = {"quality": self.IMAGE_QUALITY, "optimize": True}
            elif save_format == "PNG":
                save_kwargs = {"optimize": True}
            elif save_format == "WEBP":
                save_kwargs = {"quality": self.IMAGE_QUALITY}

            image.save(buffer, format=save_format, **save_kwargs)
            compressed = buffer.getvalue()
            return compressed, True

        except Exception as e:
            logger.warning("compression_failed", error=str(e))
            return content, False
