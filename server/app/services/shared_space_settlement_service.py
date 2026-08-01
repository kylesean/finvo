"""Shared space settlement service for calculating who owes whom."""

from __future__ import annotations

from collections import defaultdict
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any, cast
from uuid import UUID

from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.exceptions import AuthorizationError
from app.models.shared_space import (
    SpaceMember,
    SpaceTransaction,
)


class SharedSpaceSettlementService:
    """Service for calculating settlements within shared spaces."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def _verify_membership(self, space_id: UUID, user_uuid: UUID) -> SpaceMember:
        """Verify user is a member of the space."""
        # Query members
        query = select(SpaceMember).where(
            and_(
                SpaceMember.space_id == space_id,
                SpaceMember.user_uuid == user_uuid,
                SpaceMember.status == "ACCEPTED",
            )
        )
        result = await self.db.execute(query)
        member = result.scalar_one_or_none()

        if not member:
            raise AuthorizationError("you are not a member of this space")
        return member

    async def get_settlement(self, space_id: UUID, user_uuid: UUID) -> dict[str, Any]:
        """Calculate settlement for the space.

        This calculates who owes whom based on transactions in the space.

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID

        Returns:
            Settlement dictionary
        """
        await self._verify_membership(space_id, user_uuid)

        # Get all transactions in space
        query = (
            select(SpaceTransaction)
            .where(SpaceTransaction.space_id == space_id)
            .options(
                selectinload(SpaceTransaction.transaction),
                selectinload(SpaceTransaction.added_by),
            )
        )
        result = await self.db.execute(query)
        space_txs = result.scalars().all()

        # Get all members
        members_query = (
            select(SpaceMember)
            .where(
                cast(
                    Any,
                    and_(SpaceMember.space_id == space_id, SpaceMember.status == "ACCEPTED"),
                )
            )
            .options(selectinload(SpaceMember.user))
        )
        members_result = await self.db.execute(members_query)
        members = members_result.scalars().all()

        member_count = len(members)
        if member_count == 0:
            return {
                "spaceId": str(space_id),
                "items": [],
                "totalAmount": "0.00",
                "calculatedAt": datetime.now(UTC).isoformat(),
                "isSettled": True,
            }

        # Calculate balances: positive = others owe this person, negative = owes others
        balances: dict[UUID, Decimal] = defaultdict(Decimal)
        total_amount = Decimal("0")

        for st in space_txs:
            tx = st.transaction
            if tx and tx.type == "EXPENSE":
                # Person who paid gets credit
                payer_uuid = st.added_by_user_uuid
                amount = Decimal(str(tx.amount))
                share = amount / member_count

                # Payer's balance increases (others owe them)
                balances[payer_uuid] += amount - share

                # Everyone else's balance decreases (they owe)
                for member in members:
                    if member.user_uuid != payer_uuid:
                        balances[member.user_uuid] -= share

                total_amount += amount

        # Create settlement items (who pays whom)
        items = []
        debtors = [(u, b) for u, b in balances.items() if b < 0]
        creditors = [(u, b) for u, b in balances.items() if b > 0]

        # Build user lookup
        user_map = {m.user_uuid: m.user for m in members}

        # Track remaining credit per creditor so that a creditor shared by
        # multiple debtors is never assigned more than they are owed.
        creditor_remaining = {creditor_uuid: credit for creditor_uuid, credit in creditors}

        for debtor_uuid, debt in debtors:
            remaining = abs(debt)
            for creditor_uuid, credit in creditor_remaining.items():
                if remaining <= 0 or credit <= 0:
                    continue

                settle_amount = min(remaining, credit)
                if settle_amount > Decimal("0.01"):
                    debtor_user = user_map.get(debtor_uuid)
                    creditor_user = user_map.get(creditor_uuid)

                    items.append(
                        {
                            "fromUserId": str(debtor_uuid),
                            "fromUsername": debtor_user.username if debtor_user else "Unknown",
                            "toUserId": str(creditor_uuid),
                            "toUsername": creditor_user.username if creditor_user else "Unknown",
                            "amount": f"{settle_amount:.2f}",
                        }
                    )

                remaining -= settle_amount
                creditor_remaining[creditor_uuid] -= settle_amount

        return {
            "spaceId": str(space_id),
            "items": items,
            "totalAmount": f"{total_amount:.2f}",
            "calculatedAt": datetime.now(UTC).isoformat(),
            "isSettled": len(items) == 0,
        }
