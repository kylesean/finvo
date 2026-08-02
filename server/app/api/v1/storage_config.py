"""Storage configuration API endpoints.

Provides REST API for managing user storage configurations:
- Create storage configs (S3, WebDAV, local)
- List user storage configs
- Update storage configs
- Delete storage configs
"""

from __future__ import annotations

from typing import Any

from fastapi import APIRouter, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, Field

from app.core.aliases import CurrentUser, DbSession
from app.core.exceptions import BusinessError, StorageErrorCode
from app.core.responses import ResponseEnvelope, success_response
from app.models.storage_config import ProviderType
from app.services.storage_config_service import StorageConfigService

router = APIRouter(prefix="/storage-configs", tags=["storage-configs"])


# --- Pydantic Schemas ---


class StorageConfigCreate(BaseModel):
    """Request schema for creating a storage config."""

    provider_type: str = Field(..., description="Provider type: local_uploads, s3_compatible, webdav")
    name: str = Field(..., max_length=100, description="Display name")
    base_path: str = Field(..., max_length=255, description="Root path or bucket name")
    credentials: dict[str, Any] | None = Field(
        default=None, description="Connection credentials (endpoint, access_key, secret_key, etc.)"
    )
    is_readonly: bool = Field(default=True, description="Whether to prevent write operations")


class StorageConfigUpdate(BaseModel):
    """Request schema for updating a storage config."""

    name: str | None = Field(None, max_length=100)
    base_path: str | None = Field(None, max_length=255)
    credentials: dict[str, Any] | None = None
    is_readonly: bool | None = None


class StorageConfigResponse(BaseModel):
    """Response schema for storage config (matches the on-wire camelCase keys)."""

    id: int
    providerType: str
    name: str
    basePath: str
    credentials: dict[str, Any]  # Masked credentials
    isReadonly: bool
    createdAt: str
    updatedAt: str | None

    model_config = ConfigDict(from_attributes=True)


def _config_to_dict(config: Any, service: StorageConfigService) -> dict[str, Any]:
    """Build the camelCase response dict for a storage config (credentials masked).

    Single construction site — the shape used to be copy-pasted in 4 routes.
    """
    return {
        "id": config.id,
        "providerType": config.provider_type,
        "name": config.name,
        "basePath": config.base_path,
        "credentials": service.mask_credentials(config),
        "isReadonly": config.is_readonly,
        "createdAt": config.created_at.isoformat().replace("+00:00", "Z"),
        "updatedAt": config.updated_at.isoformat().replace("+00:00", "Z") if config.updated_at else None,
    }


@router.post("", status_code=status.HTTP_201_CREATED, response_model=ResponseEnvelope[dict[str, Any]])
async def create_storage_config(
    data: StorageConfigCreate,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Create a new storage configuration.

    Creates a storage config for the authenticated user.
    Credentials are encrypted before storage.

    Args:
        data: Storage config details
        current_user: Authenticated user
        db: Database session

    Returns:
        Created storage config (credentials masked)
    """
    service = StorageConfigService(db)

    try:
        config = await service.create(
            user_uuid=current_user.uuid,
            provider_type=data.provider_type,
            name=data.name,
            base_path=data.base_path,
            credentials=data.credentials,
            is_readonly=data.is_readonly,
        )
    except ValueError as e:
        raise BusinessError(message=str(e), status_code=400, error_code=StorageErrorCode.INVALID_PROVIDER_TYPE)

    return success_response(
        data=_config_to_dict(config, service),
        message="Storage configuration created successfully",
    )


@router.get("", response_model=ResponseEnvelope[list[dict[str, Any]]])
async def list_storage_configs(
    current_user: CurrentUser,
    db: DbSession,
    provider_type: str | None = None,
) -> JSONResponse:
    """List all storage configurations for the user.

    Args:
        provider_type: Optional filter by provider type
        current_user: Authenticated user
        db: Database session

    Returns:
        List of storage configs (credentials masked)
    """
    service = StorageConfigService(db)
    configs = await service.get_user_configs(user_uuid=current_user.uuid, provider_type=provider_type)

    return success_response(data=[_config_to_dict(c, service) for c in configs])


@router.get("/{config_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def get_storage_config(
    config_id: int,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Get a specific storage configuration.

    Args:
        config_id: Storage config ID
        current_user: Authenticated user
        db: Database session

    Returns:
        Storage config (credentials masked)
    """
    service = StorageConfigService(db)
    config = await service.get_by_id(config_id, current_user.uuid)

    if not config:
        raise BusinessError(
            message="Storage config not found or access denied",
            status_code=404,
            error_code=StorageErrorCode.CONFIG_NOT_FOUND,
        )

    return success_response(data=_config_to_dict(config, service))


@router.patch("/{config_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def update_storage_config(
    config_id: int,
    data: StorageConfigUpdate,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Update a storage configuration.

    Args:
        config_id: Storage config ID
        data: Fields to update
        current_user: Authenticated user
        db: Database session

    Returns:
        Updated storage config (credentials masked)
    """
    service = StorageConfigService(db)
    config = await service.update(
        config_id=config_id,
        user_uuid=current_user.uuid,
        name=data.name,
        base_path=data.base_path,
        credentials=data.credentials,
        is_readonly=data.is_readonly,
    )

    if not config:
        raise BusinessError(
            message="Storage config not found or access denied",
            status_code=404,
            error_code=StorageErrorCode.CONFIG_NOT_FOUND,
        )

    return success_response(
        data=_config_to_dict(config, service),
        message="Storage configuration updated successfully",
    )


@router.delete("/{config_id}", status_code=status.HTTP_200_OK, response_model=ResponseEnvelope[dict[str, Any]])
async def delete_storage_config(
    config_id: int,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Delete a storage configuration.

    Note: Cannot delete if attachments still reference this config.

    Args:
        config_id: Storage config ID
        current_user: Authenticated user
        db: Database session

    Returns:
        Success message
    """
    service = StorageConfigService(db)

    # In-use (FK) violations are translated into a BusinessError inside the service.
    deleted = await service.delete(config_id, current_user.uuid)

    if not deleted:
        raise BusinessError(
            message="Storage config not found or access denied",
            status_code=404,
            error_code=StorageErrorCode.CONFIG_NOT_FOUND,
        )

    return success_response(data=None, message="Storage configuration deleted successfully")


@router.get("/providers/list", response_model=ResponseEnvelope[list[dict[str, Any]]])
async def list_providers() -> JSONResponse:
    """List available storage provider types.

    Returns:
        List of supported provider types with descriptions
    """
    return success_response(
        data=[
            {
                "type": ProviderType.LOCAL_UPLOADS.value,
                "name": "Local Storage",
                "description": "Server local filesystem storage",
            },
            {
                "type": ProviderType.S3_COMPATIBLE.value,
                "name": "S3 Compatible Storage",
                "description": "Supports AWS S3, MinIO, and other S3-compatible object storage",
            },
            {
                "type": ProviderType.WEBDAV.value,
                "name": "WebDAV",
                "description": "Supports Synology NAS, NextCloud, and other WebDAV protocol storage",
            },
        ]
    )
