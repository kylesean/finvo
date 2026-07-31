"""File upload API endpoints.

Exposes RESTful file upload APIs:
- POST /api/v1/files/upload - Single/multiple file uploads
- GET /api/v1/files/view/{id} - View/download file
- DELETE /api/v1/files/{id} - Delete file
"""

from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, File, Query, UploadFile, status
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_user
from app.core.exceptions import BusinessError
from app.core.logging import logger
from app.core.responses import success_response
from app.models.user import User
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


@router.post("/upload", status_code=status.HTTP_200_OK)
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


@router.get("/view/{attachment_id}", response_class=FileResponse)
async def view_attachment(
    attachment_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
) -> FileResponse:
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


@router.delete("/{attachment_id}", status_code=status.HTTP_200_OK)
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
    except Exception:
        raise BusinessError(
            message="File deletion failed",
            status_code=500,
            error_code="FILE_DELETE_ERROR",
        )


# =============================================================================
# Supported File Types Endpoint
# =============================================================================


@router.get("/supported-types")
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
