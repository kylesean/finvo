"""WebDAV storage adapter.

Provides async file operations for WebDAV-compatible storage.
The installed webdav4 version ships only a synchronous httpx-based client
(no ``webdav4.asyncio`` module), so every blocking call is dispatched to a
worker thread via ``asyncio.to_thread`` to keep the event loop responsive.
"""

import asyncio
import uuid
from collections.abc import AsyncGenerator
from datetime import UTC, datetime, timedelta
from pathlib import PurePosixPath
from typing import Any

from app.core.config import settings
from app.core.logging import logger
from app.models.storage_config import StorageConfig
from app.services.storage.adapters.base import (
    StorageAdapter,
    StorageError,
    StorageNotFoundError,
)
from app.utils.auth_utils import create_access_token


class WebDAVAdapter(StorageAdapter):
    """WebDAV storage adapter.

    Supports WebDAV-compatible servers like Synology NAS, NextCloud,
    ownCloud, and other WebDAV-enabled services.

    Credentials format in StorageConfig.credentials:
    {
        "base_url": "https://nas.example.com:5006/webdav",
        "username": "...",
        "password": "..."
    }
    """

    def __init__(self, config: StorageConfig):
        """Initialize WebDAV adapter.

        Args:
            config: StorageConfig with WebDAV credentials
        """
        super().__init__(config)
        self._client: Any = None
        self._credentials: dict[str, Any] = {}

    async def initialize(self) -> None:
        """Initialize WebDAV client.

        Decrypts credentials and creates async WebDAV client.
        """
        try:
            # Decrypt credentials (handles {"_encrypted": ...} wrapper too)
            self._credentials = self._resolve_credentials(self.config.credentials)

            # Import and create client
            from webdav4.client import Client

            self._client = Client(
                base_url=self._credentials.get("base_url", ""),
                auth=(
                    self._credentials.get("username", ""),
                    self._credentials.get("password", ""),
                ),
            )

            self._initialized = True
            logger.info("webdav_adapter_initialized", base_url=self._credentials.get("base_url", "")[:50] + "...")
        except Exception as e:
            logger.error("webdav_adapter_init_failed", error=str(e))
            raise StorageError(f"Failed to initialize WebDAV adapter: {e}")

    def _get_full_path(self, object_key: str) -> str:
        """Combine base_path with object_key.

        Normalizes the joined path (collapses ``..``) and rejects any result
        that escapes the configured storage root.

        Args:
            object_key: Relative object path

        Returns:
            Full WebDAV path

        Raises:
            StorageError: If the resolved path escapes the storage root
        """
        import posixpath

        base = self.config.base_path.rstrip("/")
        normalized = posixpath.normpath(f"{base}/{object_key.lstrip('/')}")

        if normalized != base and not normalized.startswith(base + "/"):
            logger.warning("webdav_path_escape_blocked", object_key=object_key[:200])
            raise StorageError(f"Path escapes storage root: {object_key}")

        return normalized

    def _generate_object_key(self, filename: str) -> str:
        """Generate unique object key.

        Args:
            filename: Original filename

        Returns:
            Generated object key
        """
        now = datetime.now(UTC)
        date_prefix = now.strftime("%Y/%m/%d")

        ext = PurePosixPath(filename).suffix.lower() or ""
        safe_name = "".join(c for c in PurePosixPath(filename).stem if c.isalnum() or c in "-_")[:50]

        unique_id = uuid.uuid4().hex[:12]
        return f"{date_prefix}/{unique_id}_{safe_name}{ext}"

    async def save(
        self,
        file_stream: AsyncGenerator[bytes],
        filename: str,
        content_type: str | None = None,
    ) -> str:
        """Upload file to WebDAV server.

        Args:
            file_stream: Async generator yielding file bytes
            filename: Original filename
            content_type: Optional MIME type

        Returns:
            Object key (relative path)

        Raises:
            StorageReadOnlyError: If storage is read-only
        """
        self._check_writable()

        object_key = self._generate_object_key(filename)
        full_path = self._get_full_path(object_key)

        try:
            # Collect content
            chunks = []
            async for chunk in file_stream:
                chunks.append(chunk)
            content = b"".join(chunks)

            # Ensure parent directories exist
            parent_path = str(PurePosixPath(full_path).parent)
            try:
                await asyncio.to_thread(self._client.mkdir, parent_path)
            except Exception:  # nosec B110
                pass  # Directory might already exist

            # Upload file
            from io import BytesIO

            await asyncio.to_thread(self._client.upload_fileobj, BytesIO(content), full_path)

            logger.info("webdav_file_uploaded", path=full_path, size=len(content))
            return object_key

        except Exception as e:
            logger.error("webdav_upload_failed", path=full_path, error=str(e))
            raise StorageError(f"Failed to upload to WebDAV: {e}")

    async def get_download_url(
        self,
        object_key: str,
        expire_seconds: int = 3600,
        filename: str | None = None,
    ) -> str:
        """Generate signed URL for WebDAV file access.

        WebDAV doesn't support presigned URLs, so we generate a JWT-signed
        URL pointing to our proxy endpoint.

        Args:
            object_key: Object key (relative path)
            expire_seconds: URL validity in seconds
            filename: Optional original filename

        Returns:
            JWT-signed URL
        """
        token_data = {
            "object_key": object_key,
            "storage_config_id": self.config.id,
            "exp": datetime.now(UTC) + timedelta(seconds=expire_seconds),
        }

        if filename:
            token_data["filename"] = filename

        token = create_access_token(
            data={"sub": f"file:{object_key}", "file_access": token_data},
            expires_delta=timedelta(seconds=expire_seconds),
        )

        base_url = getattr(settings, "APP_URL", "http://localhost:8000").rstrip("/")
        return f"{base_url}/api/files/stream?token={token}"

    async def get_stream(
        self,
        object_key: str,
    ) -> AsyncGenerator[bytes]:
        """Stream file from WebDAV server.

        Args:
            object_key: Object key (relative path)

        Yields:
            File content in chunks

        Raises:
            StorageNotFoundError: If file doesn't exist
        """
        full_path = self._get_full_path(object_key)

        try:
            # Check existence
            if not await asyncio.to_thread(self._client.exists, full_path):
                raise StorageNotFoundError(f"File not found: {object_key}")

            # Download to memory and stream
            from io import BytesIO

            buffer = BytesIO()
            await asyncio.to_thread(self._client.download_fileobj, full_path, buffer)
            buffer.seek(0)

            while chunk := buffer.read(8192):
                yield chunk

        except StorageNotFoundError:
            raise
        except Exception as e:
            logger.error("webdav_stream_failed", path=full_path, error=str(e))
            raise StorageError(f"Failed to stream from WebDAV: {e}")

    async def delete(self, object_key: str) -> bool:
        """Delete file from WebDAV server.

        Args:
            object_key: Object key to delete

        Returns:
            True if deleted

        Raises:
            StorageReadOnlyError: If storage is read-only
        """
        self._check_writable()

        full_path = self._get_full_path(object_key)

        try:
            if not await asyncio.to_thread(self._client.exists, full_path):
                return False

            await asyncio.to_thread(self._client.remove, full_path)
            logger.info("webdav_file_deleted", path=full_path)
            return True

        except Exception as e:
            logger.error("webdav_delete_failed", path=full_path, error=str(e))
            raise StorageError(f"Failed to delete from WebDAV: {e}")  # nosec B608

    async def exists(self, object_key: str) -> bool:
        """Check if file exists on WebDAV server.

        Args:
            object_key: Object key to check

        Returns:
            True if exists
        """
        try:
            full_path = self._get_full_path(object_key)
            return bool(await asyncio.to_thread(self._client.exists, full_path))
        except Exception:
            return False

    async def get_file_info(self, object_key: str) -> dict[str, Any] | None:
        """Get file metadata from WebDAV server.

        Args:
            object_key: Object key

        Returns:
            File info dict or None
        """
        try:
            full_path = self._get_full_path(object_key)
            info = await asyncio.to_thread(self._client.info, full_path)
            return {
                "size": info.get("size"),
                "modified": info.get("modified"),
                "content_type": info.get("content_type"),
            }
        except Exception:
            return None
