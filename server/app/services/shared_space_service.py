"""Shared space service for managing collaborative spaces."""

from __future__ import annotations

import secrets
from datetime import UTC, datetime, timedelta
from decimal import Decimal
from typing import Any, cast
from uuid import UUID

import structlog
from sqlalchemy import and_, delete, desc, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.exceptions import (
    AppException,
    AuthorizationError,
    BusinessError,
    CommonErrorCode,
    ConflictError,
    NotFoundError,
    SpaceErrorCode,
    TransactionErrorCode,
)
from app.models.shared_space import (
    SharedSpace,
    SpaceMember,
    SpaceTransaction,
)
from app.models.transaction import Transaction
from app.models.user import User
from app.services.shared_space_access import verify_admin, verify_membership, verify_owner
from app.services.shared_space_settlement_service import SharedSpaceSettlementService
from app.services.shared_space_transaction_service import SharedSpaceTransactionService

logger = structlog.get_logger(__name__)

# Invite code alphabet: uppercase alphanumerics minus visually confusable
# characters (0/O, 1/I/L). 32 symbols x 8 positions ~= 1.1e12 combinations.
# Not a secret — flagged by detect-secrets as high-entropy; allowlisted.
_INVITE_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # pragma: allowlist secret
_INVITE_CODE_LENGTH = 8


class SharedSpaceService:
    """Service for managing shared spaces and their transactions."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.settlement = SharedSpaceSettlementService(db)
        self.space_transactions = SharedSpaceTransactionService(db)

    # =========================================================================
    # Space CRUD Operations
    # =========================================================================

    async def create_space(self, user_uuid: UUID, name: str, description: str | None = None) -> SharedSpace:
        """Create a new shared space.

        Args:
            user_uuid: Creator's UUID
            name: Space name
            description: Optional description

        Returns:
            Created SharedSpace instance
        """
        from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
        from app.models.financial_settings import FinancialSettings

        base_currency: str | None = None
        try:
            result = await self.db.execute(
                select(FinancialSettings.primary_currency).where(FinancialSettings.user_uuid == user_uuid)
            )
            base_currency = result.scalar_one_or_none() or PROJECT_DEFAULT_CURRENCY
        except Exception:  # noqa: BLE001 - settings lookup must not block space creation
            base_currency = PROJECT_DEFAULT_CURRENCY

        space = SharedSpace(
            name=name,
            description=description,
            creator_uuid=user_uuid,
            status="active",
            base_currency=(base_currency or PROJECT_DEFAULT_CURRENCY).upper(),
        )
        self.db.add(space)
        await self.db.flush()

        # Add creator as owner member
        member = SpaceMember(
            space_id=space.id,
            user_uuid=user_uuid,
            role="OWNER",
            status="ACCEPTED",
        )
        self.db.add(member)
        await self.db.flush()
        await self.db.refresh(space)

        logger.info("shared_space_created", space_id=space.id, creator=str(user_uuid))
        return space

    async def get_user_spaces(self, user_uuid: UUID, page: int = 1, limit: int = 20) -> dict[str, Any]:
        """Get all spaces the user is a member of with pagination.

        Args:
            user_uuid: User's UUID
            page: Page number
            limit: Items per page

        Returns:
            Dictionary with 'items' (list of spaces) and 'total' count
        """
        offset = (page - 1) * limit

        # Base query for filtering
        base_filter: Any = and_(
            SpaceMember.user_uuid == user_uuid,
            SpaceMember.status == "ACCEPTED",
            SharedSpace.status == "active",
        )

        # Count total
        count_query = select(func.count(SharedSpace.id)).join(SpaceMember).where(base_filter)
        count_result = await self.db.execute(count_query)
        total = count_result.scalar() or 0

        # Query spaces
        query = (
            select(SharedSpace, SpaceMember.role)
            .join(SpaceMember, SharedSpace.id == SpaceMember.space_id)
            .where(base_filter)
            .options(selectinload(SharedSpace.creator))
            .order_by(desc(SharedSpace.created_at))
            .offset(offset)
            .limit(limit)
        )

        result = await self.db.execute(query)
        rows = result.all()

        # Build response with transaction counts in batch
        space_ids = [space.id for space, _ in rows]
        stats_map = await self._batch_get_space_financial_stats(space_ids)

        items = []
        for space, role in rows:
            stats = stats_map.get(
                space.id,
                {
                    "transaction_count": 0,
                    "total_expense": Decimal("0"),
                    "member_contributions": {},
                    "base_currency": getattr(space, "base_currency", None) or "CNY",
                },
            )
            items.append(
                self._space_to_dict(
                    space,
                    tx_count=stats["transaction_count"],
                    total_expense=stats["total_expense"],
                    member_contributions=stats["member_contributions"],
                    role=role,
                    base_currency=stats.get("base_currency"),
                )
            )

        return {"spaces": items, "total": total, "page": page, "limit": limit}

    async def get_space_detail(self, space_id: UUID, user_uuid: UUID) -> dict[str, Any]:
        """Get detailed space info including members.

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID

        Returns:
            Space dictionary with full details

        Raises:
            NotFoundError: Space not found
            AuthorizationError: User not a member
        """
        # Verify membership
        member = await verify_membership(self.db, space_id, user_uuid)

        query = (
            select(SharedSpace)
            .join(SpaceMember, SharedSpace.id == SpaceMember.space_id)
            .where(
                and_(
                    SpaceMember.user_uuid == user_uuid,
                    SharedSpace.id == space_id,
                    SpaceMember.status == "ACCEPTED",
                )
            )
            .options(
                selectinload(SharedSpace.members).selectinload(SpaceMember.user),
            )
        )
        result = await self.db.execute(query)
        space = result.scalar_one_or_none()

        if not space:
            raise NotFoundError("shared space not found")

        # Load creator separately to ensure it's loaded
        creator_query = select(User).where(User.uuid == space.creator_uuid)
        creator_result = await self.db.execute(creator_query)
        creator = creator_result.scalar_one_or_none()

        # Aggregate financial statistics
        stats = await self._get_space_financial_stats(space_id)

        return self._space_to_dict_with_creator(
            space,
            creator,
            tx_count=stats["transaction_count"],
            total_expense=stats["total_expense"],
            member_contributions=stats["member_contributions"],
            include_members=True,
            role=member.role,
            base_currency=stats.get("base_currency"),
        )

    async def update_space(
        self,
        space_id: UUID,
        user_uuid: UUID,
        name: str | None = None,
        description: str | None = None,
        status: str | None = None,
        expected_version: int | None = None,
    ) -> dict[str, Any]:
        """Update space info (owner/admin only).

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID
            name: New name
            description: New description
            status: New status
            expected_version: Optional optimistic-lock check; when provided and
                the space's version differs, the update is rejected with 409
                instead of silently overwriting a concurrent change.

        Returns:
            Updated space dictionary

        Raises:
            NotFoundError: Space not found
            AuthorizationError: User not owner/admin
        """
        await verify_admin(self.db, space_id, user_uuid)

        query = select(SharedSpace).where(SharedSpace.id == space_id)
        result = await self.db.execute(query)
        space = result.scalar_one_or_none()

        if not space:
            raise NotFoundError("shared space not found")

        self._check_version(space, expected_version)

        if name is not None:
            space.name = name
        if description is not None:
            space.description = description
        if status is not None:
            space.status = status
        space.version += 1

        await self.db.flush()
        await self.db.refresh(space)

        # Load creator separately to avoid lazy-load in async context
        creator_query = select(User).where(User.uuid == space.creator_uuid)
        creator_result = await self.db.execute(creator_query)
        creator = creator_result.scalar_one_or_none()

        stats = await self._get_space_financial_stats(space_id)
        return self._space_to_dict_with_creator(
            space,
            creator,
            tx_count=stats["transaction_count"],
            total_expense=stats["total_expense"],
            base_currency=stats.get("base_currency"),
        )

    async def delete_space(self, space_id: UUID, user_uuid: UUID) -> bool:
        """Delete a space (owner only).

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID

        Returns:
            True if deleted

        Raises:
            NotFoundError: Space not found
            AuthorizationError: User not owner
        """
        await verify_owner(self.db, space_id, user_uuid)

        query = select(SharedSpace).where(SharedSpace.id == space_id)
        result = await self.db.execute(query)
        space = result.scalar_one_or_none()

        if not space:
            raise NotFoundError("shared space not found")

        await self.db.delete(space)
        await self.db.flush()

        logger.info("shared_space_deleted", space_id=space_id, by_user=str(user_uuid))
        return True

    # =========================================================================
    # Invitation Management
    # =========================================================================

    async def generate_invite_code(self, space_id: UUID, user_uuid: UUID, expires_days: int = 1) -> dict[str, Any]:
        """Generate a new invite code for the space.

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID
            expires_days: Days until expiration (default: 1 day)

        Returns:
            Invite code dictionary

        Raises:
            AuthorizationError: User not owner/admin
            NotFoundError: Space not found
        """
        await verify_admin(self.db, space_id, user_uuid)

        # Get space
        query = select(SharedSpace).where(SharedSpace.id == space_id)
        result = await self.db.execute(query)
        space = result.scalar_one_or_none()

        if not space:
            raise NotFoundError("shared space not found")

        # Generate an 8-char invite code from a confusion-free alphabet
        # (no 0/O, 1/I/L). 32^8 ~= 1.1e12 combinations — brute-forcing a code
        # within its expiration window is infeasible even without rate
        # limiting, unlike the old 6-digit numeric code (10^6).
        code = "".join(secrets.choice(_INVITE_CODE_ALPHABET) for _ in range(_INVITE_CODE_LENGTH))
        expires_at = datetime.now(UTC) + timedelta(days=expires_days)

        # Update space with new invite code
        space.invite_code = code
        space.invite_code_expires_at = expires_at
        await self.db.flush()
        await self.db.refresh(space)

        return {
            "code": code,
            "spaceId": str(space_id),
            "spaceName": space.name,
            "expiresAt": expires_at.isoformat(),
        }

    async def join_with_code(self, code: str, user_uuid: UUID) -> dict[str, Any]:
        """Join a space using invite code.

        Args:
            code: Invitation code
            user_uuid: Joining user's UUID

        Returns:
            Space dictionary

        Raises:
            NotFoundError: Invalid code
            BusinessError: Code expired or already a member
        """
        # Normalize user input: codes are generated uppercase from a
        # confusion-free alphabet; accept lowercase/whitespace from manual entry.
        code = code.strip().upper()

        # Find space by invite code
        query = select(SharedSpace).where(SharedSpace.invite_code == code)
        result = await self.db.execute(query)
        space = result.scalar_one_or_none()

        if (
            not space
            or space.status != "active"
            or (space.invite_code_expires_at and space.invite_code_expires_at < datetime.now(UTC))
        ):
            # Fold "not found", "space inactive", and "expired" into a single
            # error: distinguishable responses would let an attacker probe
            # which codes are valid and merely expired. Legitimate users get
            # the same actionable outcome (request a new code from an admin).
            raise NotFoundError("invalid or expired invitation code")

        # Check if already a member
        member_query = select(SpaceMember).where(
            and_(SpaceMember.space_id == space.id, SpaceMember.user_uuid == user_uuid)
        )
        member_result = await self.db.execute(member_query)
        existing_member = member_result.scalar_one_or_none()

        if existing_member:
            if existing_member.status == "ACCEPTED":
                raise BusinessError(
                    "you are already a member", error_code=SpaceErrorCode.ALREADY_MEMBER_OR_HAS_BEEN_INVITED
                )
            else:
                # Update existing pending membership
                existing_member.status = "ACCEPTED"
        else:
            # Add as new member
            member = SpaceMember(
                space_id=space.id,
                user_uuid=user_uuid,
                role="MEMBER",
                status="ACCEPTED",
            )
            self.db.add(member)

        await self.db.flush()

        # Get space detail FIRST (ensures response is ready before any side-effects)
        space_detail = await self.get_space_detail(space.id, user_uuid)

        # Emit domain event (async, fire-and-forget, never blocks response)
        from app.core.events import collect_event
        from app.services.notification_handlers import MemberJoinedEvent

        collect_event(
            self.db,
            MemberJoinedEvent(
                space_id=space.id,
                space_name=space.name,
                joined_user_uuid=user_uuid,
            ),
        )

        return space_detail

    # =========================================================================
    # Member Management
    # =========================================================================

    async def leave_space(self, space_id: UUID, user_uuid: UUID) -> bool:
        """Leave a space.

        Args:
            space_id: Space ID
            user_uuid: Leaving user's UUID

        Returns:
            True if left

        Raises:
            BusinessError: Owner cannot leave
        """
        # Check if user is owner
        query = select(SpaceMember).where(and_(SpaceMember.space_id == space_id, SpaceMember.user_uuid == user_uuid))
        result = await self.db.execute(query)
        member = result.scalar_one_or_none()

        if not member:
            raise NotFoundError("you are not a member of this space")

        if member.role == "OWNER":
            raise BusinessError(
                "space owner cannot leave space, please transfer or delete space first",
                error_code=CommonErrorCode.PERMISSION_DENIED,
            )

        await self.db.delete(member)
        await self._bump_space_version(space_id)
        await self.db.flush()

        logger.info("member_left_space", space_id=space_id, user=str(user_uuid))

        # Emit domain event so remaining members are notified in realtime
        from app.core.events import collect_event
        from app.services.notification_handlers import MemberLeftEvent

        space_name = (
            await self.db.execute(select(SharedSpace.name).where(SharedSpace.id == space_id))
        ).scalar_one_or_none()

        collect_event(
            self.db,
            MemberLeftEvent(
                space_id=space_id,
                space_name=space_name or "",
                left_user_uuid=user_uuid,
                reason="left",
            ),
        )

        return True

    async def remove_member(
        self,
        space_id: UUID,
        user_uuid: UUID,
        target_user_uuid: UUID,
        purge_transactions: bool = False,
    ) -> bool:
        """Remove a member from space (owner/admin only).

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID
            target_user_uuid: User to remove
            purge_transactions: When True, also delete the removed member's
                SpaceTransaction associations (their expense records vanish
                from the space for remaining members). Default False keeps
                them (settlement already excludes non-members; the detail
                rows stay visible as historical record).

        Returns:
            True if removed

        Raises:
            AuthorizationError: Not authorized
            BusinessError: Cannot remove owner
        """
        await verify_admin(self.db, space_id, user_uuid)

        # Cannot remove self via this method
        if user_uuid == target_user_uuid:
            raise BusinessError("please use leave space function", error_code=SpaceErrorCode.INVALID_ACTION)

        # Find target member
        query = select(SpaceMember).where(
            cast(
                Any,
                and_(SpaceMember.space_id == space_id, SpaceMember.user_uuid == target_user_uuid),
            )
        )
        result = await self.db.execute(query)
        member = result.scalar_one_or_none()

        if not member:
            raise NotFoundError("user is not a member of this space")

        if member.role == "OWNER":
            raise BusinessError("cannot remove space owner", error_code=CommonErrorCode.PERMISSION_DENIED)

        # C2: optional data-ownership purge. The removed member's expense
        # records in this space either stay (historical record; settlement
        # already excludes non-members) or are removed entirely so remaining
        # members no longer see their spending detail.
        if purge_transactions:
            purge_query = delete(SpaceTransaction).where(
                and_(
                    SpaceTransaction.space_id == space_id,
                    SpaceTransaction.added_by_user_uuid == target_user_uuid,
                )
            )
            await self.db.execute(purge_query)
            logger.info(
                "member_transactions_purged",
                space_id=space_id,
                removed=str(target_user_uuid),
                by=str(user_uuid),
            )

        await self.db.delete(member)
        await self._bump_space_version(space_id)
        await self.db.flush()

        logger.info("member_removed", space_id=space_id, removed=str(target_user_uuid), by=str(user_uuid))

        # Emit domain event so remaining members (and the removed user) are
        # notified in realtime
        from app.core.events import collect_event
        from app.services.notification_handlers import MemberLeftEvent

        space_name = (
            await self.db.execute(select(SharedSpace.name).where(SharedSpace.id == space_id))
        ).scalar_one_or_none()

        collect_event(
            self.db,
            MemberLeftEvent(
                space_id=space_id,
                space_name=space_name or "",
                left_user_uuid=target_user_uuid,
                reason="removed",
            ),
        )

        return True

    async def update_member_role(
        self, space_id: UUID, user_uuid: UUID, target_user_uuid: UUID, new_role: str
    ) -> dict[str, Any]:
        """Update a member's role (owner only).

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID (must be owner)
            target_user_uuid: Target member's UUID
            new_role: New role ('ADMIN' or 'MEMBER')

        Returns:
            Updated member info dict

        Raises:
            AuthorizationError: Not owner
            BusinessError: Invalid role change
        """
        await verify_owner(self.db, space_id, user_uuid)

        if new_role not in ("ADMIN", "MEMBER"):
            raise BusinessError("role must be ADMIN or MEMBER", error_code=SpaceErrorCode.INVALID_ACTION)

        # Cannot change own role
        if user_uuid == target_user_uuid:
            raise BusinessError("cannot change your own role", error_code=SpaceErrorCode.INVALID_ACTION)

        query = select(SpaceMember).where(
            cast(
                Any,
                and_(
                    SpaceMember.space_id == space_id,
                    SpaceMember.user_uuid == target_user_uuid,
                ),
            )
        )
        result = await self.db.execute(query)
        member = result.scalar_one_or_none()

        if not member:
            raise NotFoundError("user is not a member of this space")

        if member.role == "OWNER":
            raise BusinessError("cannot change owner role", error_code=CommonErrorCode.PERMISSION_DENIED)

        member.role = new_role
        await self._bump_space_version(space_id)
        await self.db.flush()
        await self.db.refresh(member)

        logger.info(
            "member_role_updated",
            space_id=space_id,
            target=str(target_user_uuid),
            new_role=new_role,
            by=str(user_uuid),
        )

        return {
            "userId": str(member.user_uuid),
            "role": member.role,
            "status": member.status,
        }

    async def transfer_ownership(
        self,
        space_id: UUID,
        user_uuid: UUID,
        target_user_uuid: UUID,
        expected_version: int | None = None,
    ) -> dict[str, Any]:
        """Transfer space ownership to another member.

        The current owner hands the space over: the target becomes OWNER and
        the former owner drops to MEMBER (they keep access, no longer the
        keys). This is the exit path leave_space hints at for owners —
        previously the only option was delete-and-recreate.

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID (must be owner)
            target_user_uuid: The new owner (an accepted member)
            expected_version: Optional optimistic-lock check

        Returns:
            Space dict (with members, new owner reflected)

        Raises:
            AuthorizationError: Not owner
            BusinessError: Target must be a non-owner accepted member
            ConflictError: expected_version mismatch
        """
        await verify_owner(self.db, space_id, user_uuid)

        if user_uuid == target_user_uuid:
            raise BusinessError("cannot transfer ownership to yourself", error_code=SpaceErrorCode.INVALID_ACTION)

        query = select(SpaceMember).where(
            cast(
                Any,
                and_(SpaceMember.space_id == space_id, SpaceMember.user_uuid == target_user_uuid),
            )
        )
        result = await self.db.execute(query)
        target = result.scalar_one_or_none()

        if not target:
            raise NotFoundError("user is not a member of this space")
        if target.role == "OWNER":
            raise BusinessError("target is already the owner", error_code=SpaceErrorCode.INVALID_ACTION)
        if target.status != "ACCEPTED":
            raise BusinessError("target has not accepted the invitation", error_code=SpaceErrorCode.INVALID_ACTION)

        space = await self._load_space(space_id, with_members=True)
        self._check_version(space, expected_version)

        # Former owner -> MEMBER (keeps access, loses admin powers), target
        # -> OWNER. creator_uuid stays untouched: it records who founded the
        # space, ownership is the current role.
        former_query = select(SpaceMember).where(
            cast(
                Any,
                and_(SpaceMember.space_id == space_id, SpaceMember.user_uuid == user_uuid),
            )
        )
        former_result = await self.db.execute(former_query)
        former = former_result.scalar_one()
        former.role = "MEMBER"
        target.role = "OWNER"
        space.version += 1

        await self.db.flush()
        # No refresh: version was incremented locally and refresh() would
        # expire the preloaded members relationship, breaking the
        # include_members rendering below.

        logger.info(
            "space_ownership_transferred",
            space_id=space_id,
            from_user=str(user_uuid),
            to_user=str(target_user_uuid),
        )

        from app.core.events import collect_event
        from app.services.notification_handlers import MemberLeftEvent

        space_name = space.name
        collect_event(
            self.db,
            MemberLeftEvent(
                space_id=space_id,
                space_name=space_name or "",
                left_user_uuid=user_uuid,
                reason="ownership_transferred",
            ),
        )

        stats = await self._get_space_financial_stats(space_id)
        creator = (await self.db.execute(select(User).where(User.uuid == space.creator_uuid))).scalar_one_or_none()
        return self._space_to_dict_with_creator(
            space,
            creator,
            tx_count=stats["transaction_count"],
            total_expense=stats["total_expense"],
            member_contributions=stats["member_contributions"],
            include_members=True,
            role="MEMBER",
            base_currency=stats.get("base_currency"),
        )

    def _check_version(self, space: SharedSpace, expected_version: int | None) -> None:
        """Reject a stale write when the caller pinned a version (C3).

        ``expected_version=None`` keeps the previous overwrite semantics for
        clients that do not participate in optimistic locking.
        """
        if expected_version is not None and space.version != expected_version:
            raise ConflictError(
                "shared space was modified by someone else, please refresh and retry",
                error_code=SpaceErrorCode.INVALID_ACTION,
            )

    async def _bump_space_version(self, space_id: UUID) -> SharedSpace:
        """Load a space and bump its version (metadata write)."""
        space = await self._load_space(space_id)
        space.version += 1
        return space

    async def _load_space(self, space_id: UUID, with_members: bool = False) -> SharedSpace:
        query = select(SharedSpace).where(SharedSpace.id == space_id)
        if with_members:
            query = query.options(
                selectinload(SharedSpace.members).selectinload(SpaceMember.user),
            )
        result = await self.db.execute(query)
        space = result.scalar_one_or_none()
        if not space:
            raise NotFoundError("shared space not found")
        return space

    # =========================================================================
    # Settlement Calculation
    # =========================================================================

    async def get_settlement(self, space_id: UUID, user_uuid: UUID) -> dict[str, Any]:
        """Calculate settlement for the space.

        This calculates who owes whom based on transactions in the space.

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID

        Returns:
            Settlement dictionary
        """
        return await self.settlement.get_settlement(space_id, user_uuid)

    # =========================================================================
    # Transaction Management (delegated to SharedSpaceTransactionService)
    # =========================================================================

    async def add_transaction_to_space(self, space_id: UUID, user_uuid: UUID, transaction_id: UUID) -> dict[str, Any]:
        """Add a transaction to the space (see :class:`SharedSpaceTransactionService`)."""
        return await self.space_transactions.add_transaction_to_space(space_id, user_uuid, transaction_id)

    async def create_transaction_for_space(self, *args: Any, **kwargs: Any) -> dict[str, Any]:
        """Create a transaction and add it to a space (see :class:`SharedSpaceTransactionService`)."""
        return await self.space_transactions.create_transaction_for_space(*args, **kwargs)

    async def record_shared_transactions(
        self, user_uuid: UUID, space_id: UUID, data: dict[str, Any]
    ) -> dict[str, Any]:
        """Record multiple transactions and link them to a space (see :class:`SharedSpaceTransactionService`)."""
        return await self.space_transactions.record_shared_transactions(user_uuid, space_id, data)

    async def get_space_transactions(
        self, space_id: UUID, user_uuid: UUID, page: int = 1, limit: int = 20
    ) -> dict[str, Any]:
        """Get transactions in a space (see :class:`SharedSpaceTransactionService`)."""
        return await self.space_transactions.get_space_transactions(space_id, user_uuid, page, limit)

    # =========================================================================
    # Helper Methods
    # =========================================================================

    async def _get_space_financial_stats(self, space_id: UUID) -> dict[str, Any]:
        """Retrieve aggregated financial statistics data across spatial dimensions.

        BF-P1-6: totals are converted into the space base currency (never mixed
        across member bases). BF-P1-8: expense scope is CLEARED + non-SYSTEM.
        Unconvertible rows are skipped with a warning (display path must not
        fail the whole list); settlement remains strict and raises instead.
        """
        from app.models.transaction import SYSTEM_TRANSACTION_SOURCE
        from app.services.shared_space_settlement_service import resolve_space_base_currency

        # 1. Total count (including all types)
        count_query = select(func.count()).where(SpaceTransaction.space_id == space_id)
        count_result = await self.db.execute(count_query)
        tx_count = count_result.scalar() or 0

        space_row = await self.db.execute(select(SharedSpace).where(SharedSpace.id == space_id))
        space = space_row.scalar_one_or_none()
        base_currency = await resolve_space_base_currency(self.db, space) if space else "CNY"

        # 2/3. Fetch in-scope expense rows and convert in Python so mixed bases
        # never reach the SUM.
        rows_query = (
            select(
                SpaceTransaction.added_by_user_uuid,
                Transaction.amount,
                Transaction.amount_original,
                Transaction.currency,
            )
            .join(Transaction, Transaction.uuid == SpaceTransaction.transaction_id)
            .where(
                cast(
                    Any,
                    and_(
                        SpaceTransaction.space_id == space_id,
                        Transaction.type == "EXPENSE",
                        Transaction.status == "CLEARED",
                        Transaction.source != SYSTEM_TRANSACTION_SOURCE,
                    ),
                )
            )
        )
        rows_result = await self.db.execute(rows_query)
        rows = rows_result.all()

        from app.services.exchange_rate_service import exchange_rate_service

        total_expense = Decimal("0")
        contributions: dict[UUID, Decimal] = {}
        for added_by, amount_base, amount_original, currency in rows:
            original = Decimal(str(amount_original if amount_original is not None else amount_base))
            tx_currency = (currency or base_currency).upper()
            if tx_currency == base_currency:
                converted = original
            else:
                try:
                    cv = await exchange_rate_service.convert(
                        amount=original, from_currency=tx_currency, to_currency=base_currency
                    )
                except Exception as e:  # noqa: BLE001 - skip, do not poison totals
                    logger.warning(
                        "space_stats_conversion_failed",
                        space_id=str(space_id),
                        currency=tx_currency,
                        error=str(e),
                    )
                    continue
                if cv is None:
                    logger.warning("space_stats_conversion_missing", space_id=str(space_id), currency=tx_currency)
                    continue
                converted = Decimal(str(cv))
            total_expense += converted
            contributions[added_by] = contributions.get(added_by, Decimal("0")) + converted

        return {
            "transaction_count": tx_count,
            "total_expense": total_expense,
            "member_contributions": contributions,
            "base_currency": base_currency,
        }

    async def _batch_get_space_financial_stats(self, space_ids: list[UUID]) -> dict[UUID, dict[str, Any]]:
        """Retrieve aggregated financial statistics across multiple spaces in batch queries.

        BF-P1-6: per-space totals are converted into that space's base currency.
        BF-P1-8: expense scope is CLEARED + non-SYSTEM.

        Args:
            space_ids: List of space IDs

        Returns:
            Dictionary mapping space_id to stats dict (transaction_count, total_expense, member_contributions)
        """
        from app.models.transaction import SYSTEM_TRANSACTION_SOURCE
        from app.services.shared_space_settlement_service import resolve_space_base_currency

        if not space_ids:
            return {}

        stats_by_space: dict[UUID, dict[str, Any]] = {
            sid: {
                "transaction_count": 0,
                "total_expense": Decimal("0"),
                "member_contributions": {},
                "base_currency": "CNY",
            }
            for sid in space_ids
        }

        # Resolve each space's base currency (batch load, fallback per space).
        spaces_result = await self.db.execute(select(SharedSpace).where(SharedSpace.id.in_(space_ids)))
        base_by_space: dict[UUID, str] = {}
        for space in spaces_result.scalars().all():
            base_by_space[space.id] = await resolve_space_base_currency(self.db, space)
        for sid in stats_by_space:
            stats_by_space[sid]["base_currency"] = base_by_space.get(sid, "CNY")

        # 1. Batch total transaction counts
        count_query = (
            select(SpaceTransaction.space_id, func.count(SpaceTransaction.id))
            .where(SpaceTransaction.space_id.in_(space_ids))
            .group_by(SpaceTransaction.space_id)
        )
        count_result = await self.db.execute(count_query)
        for space_id, count in count_result.all():
            if space_id in stats_by_space:
                stats_by_space[space_id]["transaction_count"] = count or 0

        # 2/3. Fetch in-scope rows once, convert per space in Python.
        rows_query = (
            select(
                SpaceTransaction.space_id,
                SpaceTransaction.added_by_user_uuid,
                Transaction.amount,
                Transaction.amount_original,
                Transaction.currency,
            )
            .join(Transaction, Transaction.uuid == SpaceTransaction.transaction_id)
            .where(
                cast(
                    Any,
                    and_(
                        SpaceTransaction.space_id.in_(space_ids),
                        Transaction.type == "EXPENSE",
                        Transaction.status == "CLEARED",
                        Transaction.source != SYSTEM_TRANSACTION_SOURCE,
                    ),
                )
            )
        )
        rows_result = await self.db.execute(rows_query)

        from app.services.exchange_rate_service import exchange_rate_service

        for space_id, added_by, amount_base, amount_original, currency in rows_result.all():
            if space_id not in stats_by_space:
                continue
            base_currency = stats_by_space[space_id]["base_currency"]
            original = Decimal(str(amount_original if amount_original is not None else amount_base))
            tx_currency = (currency or base_currency).upper()
            if tx_currency == base_currency:
                converted = original
            else:
                try:
                    cv = await exchange_rate_service.convert(
                        amount=original, from_currency=tx_currency, to_currency=base_currency
                    )
                except Exception as e:  # noqa: BLE001 - skip, do not poison totals
                    logger.warning(
                        "space_stats_conversion_failed",
                        space_id=str(space_id),
                        currency=tx_currency,
                        error=str(e),
                    )
                    continue
                if cv is None:
                    logger.warning("space_stats_conversion_missing", space_id=str(space_id), currency=tx_currency)
                    continue
                converted = Decimal(str(cv))
            stats_by_space[space_id]["total_expense"] += converted
            contribs = stats_by_space[space_id]["member_contributions"]
            contribs[added_by] = contribs.get(added_by, Decimal("0")) + converted

        return stats_by_space

    def _space_to_dict(
        self,
        space: SharedSpace,
        tx_count: int = 0,
        total_expense: Decimal = Decimal("0"),
        member_contributions: dict[UUID, Decimal] | None = None,
        include_members: bool = False,
        role: str | None = None,
        base_currency: str | None = None,
    ) -> dict[str, Any]:
        """Convert space to dictionary (creator resolved from the relationship)."""
        return self._space_to_dict_with_creator(
            space,
            creator=space.creator,
            tx_count=tx_count,
            total_expense=total_expense,
            member_contributions=member_contributions,
            include_members=include_members,
            role=role,
            base_currency=base_currency or getattr(space, "base_currency", None),
        )

    def _space_to_dict_with_creator(
        self,
        space: SharedSpace,
        creator: User | None,
        tx_count: int = 0,
        total_expense: Decimal = Decimal("0"),
        member_contributions: dict[UUID, Decimal] | None = None,
        include_members: bool = False,
        role: str | None = None,
        base_currency: str | None = None,
    ) -> dict[str, Any]:
        """Convert space to dictionary with externally loaded creator."""
        data: dict[str, Any] = {
            "id": str(space.id),
            "name": space.name,
            "role": role,
            "description": space.description,
            "baseCurrency": (base_currency or getattr(space, "base_currency", None) or "CNY"),
            "creator": {
                "id": str(creator.uuid) if creator else str(space.creator_uuid),
                "username": creator.username if creator else "Unknown",
                "avatarUrl": getattr(creator, "avatar_url", None) if creator else None,
            },
            "createdAt": space.created_at.isoformat() if space.created_at else None,
            "updatedAt": space.updated_at.isoformat() if space.updated_at else None,
            "transactionCount": tx_count,
            "totalExpense": f"{total_expense:.2f}",
        }

        if include_members and space.members:
            contributions = member_contributions or {}
            data["members"] = [
                {
                    "userId": str(m.user_uuid),
                    "username": m.user.username if m.user else "Unknown",
                    "avatarUrl": getattr(m.user, "avatar_url", None) if m.user else None,
                    "role": m.role,
                    "status": m.status,
                    "createdAt": m.created_at.isoformat() if m.created_at else None,
                    "contributionAmount": f"{contributions.get(m.user_uuid, Decimal('0')):.2f}",
                }
                for m in space.members
            ]

            # Get current valid invite code
            if space.invite_code:
                is_valid = not space.invite_code_expires_at or space.invite_code_expires_at > datetime.now(UTC)
                if is_valid:
                    data["currentInviteCode"] = space.invite_code
                    data["inviteCodeExpiresAt"] = (
                        space.invite_code_expires_at.isoformat() if space.invite_code_expires_at else None
                    )

        return data
