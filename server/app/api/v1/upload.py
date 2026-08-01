"""File upload API endpoints.

Exposes RESTful file upload APIs:
- POST /api/v1/files/upload - Single/multiple file uploads
- GET /api/v1/files/view/{id} - View/download file
- DELETE /api/v1/files/{id} - Delete file
"""

from __future__ import annotations

import mimetypes
from typing import Any
from urllib.parse import quote
from uuid import UUID

from fastapi import APIRouter, Depends, File, Query, UploadFile, status
from fastapi.responses import FileResponse, JSONResponse, RedirectResponse, Response, StreamingResponse
from jose import JWTError, jwt
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import get_session
from app.core.dependencies import get_current_user
from app.core.exceptions import BusinessError
from app.core.logging import logger
from app.core.responses import ResponseEnvelope, success_response
from app.models.storage_config import StorageConfig
from app.models.user import User
from app.services.storage.adapters.factory import StorageAdapterFactory
from app.services.upload_service import (
    ALLOWED_EXTENSIONS,
    DOCUMENT_EXTENSIONS,
    IMAGE_EXTENSIONS,
    UploadService,
)

router = APIRouter(prefix="/files", tags=["files"])


# =============================================================================
# Response Schemas
# =============================================================================


class UploadResultItem(BaseModel):
    """Single file upload result item schema."""

    id: str  # UUID
    attachmentId: str  # UUID
    originalName: str
    filename: str
    fileKey: str
    uri: str
    size: int
    mimeType: str
    hash: str
    compressed: bool
    threadId: str | None = None


class UploadFailureItem(BaseModel):
    """Failed upload item schema."""

    filename: str
    error: str
    errorCode: str


class UploadSummary(BaseModel):
    """Upload batch summary schema."""

    total: int
    successfulCount: int
    failedCount: int


class UploadResponse(BaseModel):
    """Upload API response schema."""

    summary: UploadSummary
    uploads: list[UploadResultItem]
    failures: list[UploadFailureItem]


# =============================================================================
# Upload Endpoints
# =============================================================================


@router.post("/upload", status_code=status.HTTP_200_OK, response_model=ResponseEnvelope[UploadResponse])
async def upload_files(
    files: list[UploadFile] = File(
        ...,
        alias="files[]",
        description="Files to upload. Supported formats: images (jpg/png/gif/webp etc.), documents (pdf/doc/docx/xls/xlsx/ppt/pptx/txt/md etc.)",
    ),
    compress: bool = Query(default=True, description="Whether to compress images (jpg/jpeg/png/webp only)"),
    thread_id: UUID | None = Query(default=None, alias="threadId", description="Associated session thread ID"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Upload one or more files.

    Supports concurrent upload of multiple files, processing each file independently.

    **Supported File Types:**

    - **Images**: jpg, jpeg, png, gif, webp, bmp, ico, svg
    - **Documents**: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, md, csv, json, xml, html, rtf, odt, ods, odp

    **Request Example:**

    ```
    POST /api/v1/files/upload
    Content-Type: multipart/form-data

    files[]: (binary)
    files[]: (binary)
    compress: true
    threadId: conv_xxx
    ```

    **Response Example:**

    ```json
    {
        "summary": {
            "total": 2,
            "successfulCount": 2,
            "failedCount": 0
        },
        "uploads": [
            {
                "id": "1",
                "attachmentId": "1",
                "originalName": "photo.jpg",
                "filename": "photo.jpg",
                "fileKey": "2024/12/05/up_xxx_yyy.jpg",
                "uri": "http://localhost:8000/api/v1/files/view/1",
                "size": 102400,
                "mimeType": "image/jpeg",
                "hash": "sha256...",
                "compressed": true
            }
        ],
        "failures": []
    }
    ```

    Args:
        files: File list (multipart/form-data, field name: files[])
        compress: Whether to compress images
        thread_id: Optional session thread ID
        current_user: Currently authenticated user
        db: Database session

    Returns:
        JSONResponse containing upload results

    Raises:
        400: All file uploads failed
        401: Unauthorized
        413: File too large
    """
    # Validate file count
    if not files:
        raise BusinessError(
            message="Please select at least one file",
            status_code=400,
            error_code="NO_FILES",
        )

    if len(files) > 20:
        raise BusinessError(
            message="Maximum 20 files per upload",
            status_code=400,
            error_code="TOO_MANY_FILES",
        )

    # Batch upload: process files first, then write DB records
    upload_service = UploadService(db)
    successful, failed = await upload_service.upload_files(
        files=files,
        user_uuid=current_user.uuid,
        compress=compress,
        thread_id=thread_id,
    )

    # Check for total failure
    if not successful and failed:
        raise BusinessError(
            message="All file uploads failed",
            status_code=400,
            error_code="UPLOAD_ALL_FAILED",
        )

    return success_response(
        data={
            "summary": {
                "total": len(files),
                "successfulCount": len(successful),
                "failedCount": len(failed),
            },
            "uploads": successful,
            "failures": failed,
        },
        message="Upload completed",
    )


# =============================================================================
# View/Download Endpoints
# =============================================================================


def _content_disposition(filename: str, mime_type: str) -> str:
    """Build an RFC 5987-aware Content-Disposition header for a stored file."""
    if mime_type == "image/svg+xml":
        disposition = "attachment"  # SVG can embed <script> -> force download
    elif mime_type.startswith("image/") or mime_type == "application/pdf":
        disposition = "inline"
    else:
        disposition = "attachment"

    try:
        filename.encode("ascii")
        return f'{disposition}; filename="{filename}"'
    except UnicodeEncodeError:
        return f"{disposition}; filename*=UTF-8''{quote(filename)}"


@router.get("/stream")
async def stream_file(token: str = "", db: AsyncSession = Depends(get_session)) -> StreamingResponse:
    """Stream a stored file from its signed capability URL.

    This is the endpoint referenced by adapter-issued ``get_download_url``
    (e.g. the local adapter's ``/api/v1/files/stream?token=...``). It validates
    the short-lived signed token, resolves the ownership storage config, and
    streams the object through the correct backend — so both local and
    remote (S3/WebDAV) uploads are retrievable instead of 404ing.
    """
    from uuid import UUID as _UUID

    if not token:
        raise BusinessError("Missing token", status_code=401, error_code="AUTH_FAILED")
    try:
        payload: dict[str, Any] = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
    except JWTError as e:
        logger.warning("stream_token_invalid", error=str(e))
        raise BusinessError("Invalid token", status_code=401, error_code="AUTH_FAILED")

    fa = payload.get("file_access")
    if not isinstance(fa, dict):
        raise BusinessError("Invalid token payload", status_code=401, error_code="AUTH_FAILED")

    object_key = fa.get("object_key")
    storage_config_id = fa.get("storage_config_id")
    filename = str(fa.get("filename") or str(object_key or "").split("/")[-1] or "file")
    if not object_key or not storage_config_id:
        raise BusinessError("Invalid token payload", status_code=401, error_code="AUTH_FAILED")

    try:
        sc = await db.get(StorageConfig, _UUID(str(storage_config_id)))
    except (ValueError, TypeError):
        raise BusinessError("Invalid storage config", status_code=404, error_code="FILE_NOT_FOUND")
    if sc is None:
        raise BusinessError("Storage config not found", status_code=404, error_code="FILE_NOT_FOUND")

    adapter = await StorageAdapterFactory.create(sc)
    if not await adapter.exists(object_key):
        raise BusinessError("File not found", status_code=404, error_code="FILE_NOT_FOUND")

    mime_type = mimetypes.guess_type(filename)[0] or "application/octet-stream"
    return StreamingResponse(
        adapter.get_stream(object_key),
        media_type=mime_type,
        headers={
            "Content-Disposition": _content_disposition(filename, mime_type),
            "Cache-Control": "private, max-age=300",
        },
    )


@router.get("/view/{attachment_id}", response_class=FileResponse)
async def view_attachment(
    attachment_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> Response:
    """View or download attachment file.

    Returns file according to MIME type:
    - Image/PDF: Inline display in browser
    - Other files: Download as attachment

    Args:
        attachment_id: Attachment ID
        current_user: Currently authenticated user
        db: Database session

    Returns:
        FileResponse content stream

    Raises:
        404: File not found or access denied
    """
    upload_service = UploadService(db)

    # Resolve attachment + storage backend. Remote (S3/WebDAV) files are
    # served through the adapter-issued signed URL (redirect); local files are
    # streamed from disk via FileResponse.
    attachment = await upload_service._resolve_attachment(attachment_id, current_user.uuid)
    adapter, provider_type = await upload_service._get_attachment_adapter(attachment)
    if provider_type and provider_type != "local_uploads" and adapter is not None:
        signed_url = await adapter.get_download_url(
            attachment.object_key,
            filename=attachment.filename,
        )
        return RedirectResponse(url=signed_url)

    try:
        file_path, attachment = await upload_service.get_file_path(
            attachment_id=attachment_id,
            user_uuid=current_user.uuid,
        )

        # Determine Content-Disposition header
        mime_type = attachment.mime_type or "application/octet-stream"
        if mime_type == "image/svg+xml":
            # Security: SVG can embed <script> tags -> store-and-reflect XSS when served inline.
            # Force download; never render SVG inline in browser.
            disposition = "attachment"
        elif mime_type.startswith("image/") or mime_type == "application/pdf":
            disposition = "inline"
        else:
            disposition = "attachment"

        # Encode non-ASCII filenames per RFC 5987
        from urllib.parse import quote

        filename = attachment.filename

        # Create ASCII-safe filename for compatibility
        try:
            filename.encode("ascii")
            # Pure ASCII filename, use directly
            content_disposition = f'{disposition}; filename="{filename}"'
        except UnicodeEncodeError:
            # Filename contains non-ASCII characters, use RFC 5987 encoding
            encoded_filename = quote(filename)
            content_disposition = f"{disposition}; filename*=UTF-8''{encoded_filename}"

        return FileResponse(
            path=file_path,
            filename=filename,
            media_type=mime_type,
            headers={"Content-Disposition": content_disposition},
        )

    except BusinessError:
        raise
    except Exception as e:
        logger.error(
            "file_view_error",
            attachment_id=attachment_id,
            error=str(e),
            error_type=type(e).__name__,
        )
        raise BusinessError(
            message="File access failed",
            status_code=500,
            error_code="FILE_ACCESS_ERROR",
        )


# =============================================================================
# Delete Endpoints
# =============================================================================


@router.delete("/{attachment_id}", status_code=status.HTTP_200_OK, response_model=ResponseEnvelope[dict[str, Any]])
async def delete_file(
    attachment_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> JSONResponse:
    """Delete file.

    Removes physical file and database attachment record.

    Args:
        attachment_id: Attachment ID
        current_user: Currently authenticated user
        db: Database session

    Returns:
        JSONResponse success response

    Raises:
        404: File not found or access denied
    """
    upload_service = UploadService(db)

    try:
        await upload_service.delete_file(
            attachment_id=attachment_id,
            user_uuid=current_user.uuid,
        )

        return success_response(
            data=None,
            message="File deleted successfully",
        )

    except BusinessError:
        raise
    except Exception as e:
        logger.error(
            "file_delete_failed",
            attachment_id=str(attachment_id),
            error=str(e),
            exc_info=True,
        )
        raise BusinessError(
            message="File deletion failed",
            status_code=500,
            error_code="FILE_DELETE_ERROR",
        ) from e


# =============================================================================
# Supported File Types Endpoint
# =============================================================================


@router.get("/supported-types", response_model=ResponseEnvelope[dict[str, Any]])
async def get_supported_types() -> JSONResponse:
    """Retrieve supported file types list.

    Returns:
        Supported file extensions and MIME types
    """
    return success_response(
        data={
            "imageExtensions": sorted(IMAGE_EXTENSIONS),
            "documentExtensions": sorted(DOCUMENT_EXTENSIONS),
            "allExtensions": sorted(ALLOWED_EXTENSIONS),
        },
        message="Supported file types",
    )
