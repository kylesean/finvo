"""Shared space schemas for request/response validation."""

from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

# ============================================================================
# Request Schemas
# ============================================================================


class CreateSpaceRequest(BaseModel):
    """Request schema for creating a shared space."""

    name: str = Field(..., min_length=1, max_length=255, description="Space name")
    description: str | None = Field(None, max_length=255, description="Space description")


class UpdateSpaceRequest(BaseModel):
    """Request schema for updating a shared space."""

    name: str | None = Field(None, min_length=1, max_length=255, description="Space name")
    description: str | None = Field(None, max_length=255, description="Space description")
    status: str | None = Field(None, pattern="^(active|archived)$", description="Space status")


class GenerateInviteCodeRequest(BaseModel):
    """Request schema for generating an invite code."""

    max_uses: int = Field(default=1, ge=1, le=100, description="Maximum number of uses")
    expires_days: int = Field(default=7, ge=1, le=30, description="Expiration in days")


class JoinWithCodeRequest(BaseModel):
    """Request schema for joining a space with invite code."""

    code: str = Field(..., min_length=1, max_length=50, description="Invite code")


class AddTransactionToSpaceRequest(BaseModel):
    """Request schema for adding a transaction to a space."""

    transaction_id: UUID = Field(..., description="Transaction ID")


class UpdateMemberRoleRequest(BaseModel):
    """Request schema for updating a member's role."""

    role: str = Field(..., pattern="^(ADMIN|MEMBER)$", description="New role: ADMIN or MEMBER")


# ============================================================================
# Response Schemas
# ============================================================================


class SpaceCreatorResponse(BaseModel):
    """Response schema for space creator info."""

    id: str = Field(..., description="User ID")
    username: str = Field(..., description="Username")
    avatar_url: str | None = Field(None, description="Avatar URL")

    model_config = ConfigDict(from_attributes=True)


class SpaceMemberResponse(BaseModel):
    """Response schema for space member info."""

    user_id: str = Field(..., description="User UUID")
    username: str = Field(..., description="Username")
    avatar_url: str | None = Field(None, description="Avatar URL")
    role: str = Field(..., description="Member role")
    status: str = Field(..., description="Member status")
    created_at: datetime | None = Field(None, description="Join timestamp")
    contribution_amount: str = Field(default="0.00", description="Member total expense contribution")

    model_config = ConfigDict(from_attributes=True)


class SharedSpaceResponse(BaseModel):
    """Response schema for shared space."""

    id: str = Field(..., description="Space ID")
    name: str = Field(..., description="Space name")
    description: str | None = Field(None, description="Space description")
    creator: SpaceCreatorResponse = Field(..., description="Creator information")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    members: list[SpaceMemberResponse] | None = Field(None, description="List of space members")
    transaction_count: int = Field(default=0, description="Number of transactions")
    current_invite_code: str | None = Field(None, description="Current invite code")
    invite_code_expires_at: datetime | None = Field(None, description="Invite code expiration timestamp")
    total_expense: str = Field(default="0.00", description="Total cumulative expense in space")

    model_config = ConfigDict(from_attributes=True)


class InviteCodeResponse(BaseModel):
    """Response schema for invite code."""

    code: str = Field(..., description="Invite code")
    space_id: str = Field(..., description="Space ID")
    space_name: str = Field(..., description="Space name")
    expires_at: datetime | None = Field(None, description="Expiration timestamp")
    created_at: datetime = Field(..., description="Creation timestamp")
    created_by: str = Field(..., description="Creator username")
    max_uses: int = Field(..., description="Maximum allowed uses")
    uses: int = Field(..., description="Current use count")

    model_config = ConfigDict(from_attributes=True)


class SettlementItemResponse(BaseModel):
    """Response schema for a single settlement item."""

    from_user_id: str = Field(..., description="Payer user ID")
    from_username: str = Field(..., description="Payer username")
    to_user_id: str = Field(..., description="Payee user ID")
    to_username: str = Field(..., description="Payee username")
    amount: str = Field(..., description="Settlement amount")


class SettlementResponse(BaseModel):
    """Response schema for settlement info."""

    space_id: str = Field(..., description="Space ID")
    items: list[SettlementItemResponse] = Field(..., description="List of settlement items")
    total_amount: str = Field(..., description="Total settlement amount")
    calculated_at: datetime = Field(..., description="Calculation timestamp")
    is_settled: bool = Field(default=False, description="Whether settlement is complete")


class SpaceTransactionResponse(BaseModel):
    """Response schema for a transaction in a space."""

    id: str = Field(..., description="Transaction ID")
    type: str = Field(..., description="Transaction type")
    amount: str = Field(..., description="Amount")
    currency: str = Field(..., description="Currency")
    description: str | None = Field(None, description="Description")
    category_key: str = Field(..., description="Category key")
    transaction_at: datetime = Field(..., description="Transaction timestamp")
    added_by_username: str = Field(..., description="Username of user who added transaction")
    added_at: datetime = Field(..., description="Added timestamp")

    model_config = ConfigDict(from_attributes=True)
