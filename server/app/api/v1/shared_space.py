"""Shared space API endpoints."""

from typing import Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from fastapi.responses import JSONResponse

from app.core.aliases import CurrentUser
from app.core.responses import ResponseEnvelope, success_response
from app.core.service_deps import get_shared_space_service
from app.schemas.shared_space import (
    AddTransactionToSpaceRequest,
    CreateSpaceRequest,
    GenerateInviteCodeRequest,
    JoinWithCodeRequest,
    UpdateMemberRoleRequest,
    UpdateSpaceRequest,
)
from app.services.shared_space_service import SharedSpaceService

router = APIRouter(prefix="/shared-spaces", tags=["shared-spaces"])


@router.get("", response_model=ResponseEnvelope[dict[str, Any]])
async def get_shared_spaces(
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
) -> JSONResponse:
    """Get user's shared spaces.

    Returns a list of shared spaces that the current user is a member of.
    """
    spaces = await service.get_user_spaces(current_user.uuid, page, limit)
    return success_response(data=spaces)


@router.post("", response_model=ResponseEnvelope[dict[str, Any]])
async def create_shared_space(
    request: CreateSpaceRequest,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Create a new shared space.

    Creates a new shared space, with the creator automatically becoming the owner.
    """
    space = await service.create_space(
        user_uuid=current_user.uuid,
        name=request.name,
        description=request.description,
    )

    # Get full space details
    space_dict = await service.get_space_detail(space.id, current_user.uuid)
    return success_response(data=space_dict)


@router.get("/{space_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def get_shared_space_detail(
    space_id: UUID,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Get shared space details.

    Returns the details of a specific shared space, including member list and transaction statistics.
    """
    space_dict = await service.get_space_detail(space_id, current_user.uuid)
    return success_response(data=space_dict)


@router.put("/{space_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def update_shared_space(
    space_id: UUID,
    request: UpdateSpaceRequest,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Update shared space info.

    Updates the information of a specific shared space (only for administrators/creators).
    """
    space_dict = await service.update_space(
        space_id=space_id,
        user_uuid=current_user.uuid,
        name=request.name,
        description=request.description,
        status=request.status,
    )
    return success_response(data=space_dict)


@router.delete("/{space_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def delete_shared_space(
    space_id: UUID,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Delete a shared space.

    Deletes a specific shared space (only for creators).
    """
    await service.delete_space(space_id, current_user.uuid)
    return success_response(data={"message": "Space deleted successfully"})


@router.post("/{space_id}/invite-code", response_model=ResponseEnvelope[dict[str, Any]])
async def generate_invite_code(
    space_id: UUID,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
    request: GenerateInviteCodeRequest | None = None,
) -> JSONResponse:
    """Generate an invite code.

    Generates an invite code for inviting others to join the space.
    Optional body allows the caller to set the expiration window.
    """
    invite = await service.generate_invite_code(
        space_id=space_id,
        user_uuid=current_user.uuid,
        expires_days=request.expires_days if request else 1,
    )
    return success_response(data=invite)


@router.post("/join-with-code", response_model=ResponseEnvelope[dict[str, Any]])
async def join_space_with_code(
    request: JoinWithCodeRequest,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Joins a shared space using an invite code."""
    space_dict = await service.join_with_code(request.code, current_user.uuid)
    return success_response(data=space_dict)


@router.post("/{space_id}/leave", response_model=ResponseEnvelope[dict[str, Any]])
async def leave_space(
    space_id: UUID,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Leave a shared space."""
    await service.leave_space(space_id, current_user.uuid)
    return success_response(data={"message": "Leave space successfully"})


@router.delete("/{space_id}/members/{user_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def remove_member(
    space_id: UUID,
    user_id: UUID,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Remove a member from the space (only for administrators/creators)."""
    await service.remove_member(space_id, current_user.uuid, user_id)
    return success_response(data={"message": "Remove member successfully"})


@router.put("/{space_id}/members/{user_id}/role", response_model=ResponseEnvelope[dict[str, Any]])
async def update_member_role(
    space_id: UUID,
    user_id: UUID,
    request: UpdateMemberRoleRequest,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Update a member's role (owner only)."""
    result = await service.update_member_role(
        space_id=space_id,
        user_uuid=current_user.uuid,
        target_user_uuid=user_id,
        new_role=request.role,
    )
    return success_response(data=result)


@router.get("/{space_id}/settlement", response_model=ResponseEnvelope[dict[str, Any]])
async def get_space_settlement(
    space_id: UUID,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Get settlement info for the space."""
    settlement = await service.get_settlement(space_id, current_user.uuid)
    return success_response(data=settlement)


@router.get("/{space_id}/transactions", response_model=ResponseEnvelope[list[dict[str, Any]]])
async def get_space_transactions(
    space_id: UUID,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
) -> JSONResponse:
    """Get transactions in the space."""
    transactions = await service.get_space_transactions(
        space_id=space_id,
        user_uuid=current_user.uuid,
        page=page,
        limit=limit,
    )
    return success_response(data=transactions)


@router.post("/{space_id}/transactions", response_model=ResponseEnvelope[dict[str, Any]])
async def add_transaction_to_space(
    space_id: UUID,
    request: AddTransactionToSpaceRequest,
    current_user: CurrentUser,
    service: SharedSpaceService = Depends(get_shared_space_service),
) -> JSONResponse:
    """Add a transaction to the space."""
    result = await service.add_transaction_to_space(
        space_id=space_id,
        user_uuid=current_user.uuid,
        transaction_id=request.transaction_id,
    )
    return success_response(data=result)
