"""Shared-space transaction operations.

Extracted from :class:`SharedSpaceService` so space membership admin (CRUD,
invites, roles) and space transaction linking (add/create/batch/list) each live
in a focused service. Membership checks are shared via
:mod:`app.services.shared_space_access`.
"""

from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from typing import Any, cast
from uuid import UUID

import structlog
from sqlalchemy import and_, desc, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.exceptions import AppException, AuthorizationError, NotFoundError, TransactionErrorCode
from app.models.shared_space import SharedSpace, SpaceTransaction
from app.models.transaction import Transaction
from app.services.shared_space_access import verify_membership

logger = structlog.get_logger(__name__)


class SharedSpaceTransactionService:
    """Link and list transactions within a shared space."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_transaction_to_space(self, space_id: UUID, user_uuid: UUID, transaction_id: UUID) -> dict[str, Any]:
        """Add a transaction to the space.

        Args:
            space_id: Space ID
            user_uuid: Adding user's UUID
            transaction_id: Transaction to add

        Returns:
            Space transaction info

        Raises:
            AuthorizationError: Not a member
        """
        await verify_membership(self.db, space_id, user_uuid)

        # Verify transaction exists and belongs to user
        tx_query = select(Transaction).where(Transaction.uuid == transaction_id)
        tx_result = await self.db.execute(tx_query)
        transaction = tx_result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("transaction", error_code=TransactionErrorCode.TRANSACTION_NOT_EXISTS)

        if transaction.user_uuid != user_uuid:
            raise AuthorizationError("can only add your own transactions to shared space")

        # Check if already in space
        existing_query = select(SpaceTransaction).where(
            cast(
                Any,
                and_(
                    SpaceTransaction.space_id == space_id,
                    SpaceTransaction.transaction_id == transaction_id,
                ),
            )
        )
        existing_result = await self.db.execute(existing_query)
        if existing_result.scalar_one_or_none():
            return {"message": "Transaction already in this space", "already_exists": True}

        space_tx = SpaceTransaction(
            space_id=space_id,
            transaction_id=transaction_id,
            added_by_user_uuid=user_uuid,
        )
        self.db.add(space_tx)
        try:
            await self.db.commit()
        except IntegrityError:
            # Lost the race against a concurrent duplicate insert; the (space_id,
            # transaction_id) unique constraint fired. Treat as idempotent success.
            await self.db.rollback()
            return {"message": "Transaction already in this space", "already_exists": True}

        # Emit domain event (async, fire-and-forget)
        from app.core.events import event_bus
        from app.services.notification_handlers import TransactionAddedEvent

        # Get space name for notification content
        space_name_query = select(SharedSpace.name).where(SharedSpace.id == space_id)
        space_name_result = await self.db.execute(space_name_query)
        space_name = space_name_result.scalar_one_or_none() or "Shared Space"

        event_bus.emit(
            TransactionAddedEvent(
                space_id=space_id,
                space_name=space_name,
                transaction_id=transaction.uuid,
                added_by_user_uuid=user_uuid,
                amount=transaction.amount,
                currency=(transaction.currency or "CNY").upper(),
                tx_type=transaction.type.lower() if transaction.type else "expense",
                description=transaction.description or transaction.category_key or "",
            )
        )

        return {"message": "transaction added to space"}

    async def create_transaction_for_space(
        self,
        user_uuid: UUID,
        space_id: UUID,
        amount: Decimal,
        transaction_type: str = "expense",
        transaction_at: datetime | None = None,
        category_key: str = "OTHERS",
        currency: str = "CNY",
        raw_input: str | None = None,
        source_account_id: UUID | None = None,
        target_account_id: UUID | None = None,
        subject: str = "SELF",
        intent: str = "SURVIVAL",
        tags: list[str] | None = None,
    ) -> dict[str, Any]:
        """Create a transaction and immediately add it to a shared space."""
        from app.services.transaction_service import TransactionService

        tx_service = TransactionService(self.db)
        result = await tx_service.create_transaction(
            user_uuid=user_uuid,
            amount=amount,
            transaction_type=transaction_type,
            transaction_at=transaction_at,
            category_key=category_key,
            currency=currency,
            raw_input=raw_input,
            source_account_id=source_account_id,
            target_account_id=target_account_id,
            subject=subject,
            intent=intent,
            tags=tags,
        )

        tx_id = UUID(result["transaction_id"])
        try:
            await self.add_transaction_to_space(space_id=space_id, user_uuid=user_uuid, transaction_id=tx_id)
        except AppException as e:
            # The transaction is already persisted; surface the partial state
            # explicitly instead of failing the whole request while the
            # transaction silently stays out of the space. Only expected business
            # failures are tolerated here — programming errors must propagate.
            logger.error(
                "failed_to_link_transaction_to_space",
                transaction_id=str(tx_id),
                space_id=space_id,
                error=str(e),
                exc_info=True,
            )
            result["space_link_failed"] = True

        return result

    async def record_shared_transactions(
        self,
        user_uuid: UUID,
        space_id: UUID,
        data: dict[str, Any],
    ) -> dict[str, Any]:
        """Record multiple transactions and link them to a shared space."""
        from app.services.transaction_service import TransactionService

        tx_service = TransactionService(self.db)
        result = await tx_service.create_batch_transactions(user_uuid, data)

        if result.get("success"):
            # Link all created transactions to the space; report failures
            # explicitly instead of masking partial success.
            failed_links: list[str] = []
            for tx_item in result.get("transactions", []):
                tx_id = UUID(tx_item["id"])
                try:
                    await self.add_transaction_to_space(space_id=space_id, user_uuid=user_uuid, transaction_id=tx_id)
                except AppException as e:
                    logger.error(
                        "failed_to_link_batch_transaction_to_space",
                        transaction_id=str(tx_id),
                        space_id=space_id,
                        error=str(e),
                        exc_info=True,
                    )
                    failed_links.append(str(tx_id))

            if failed_links:
                result["link_failed"] = True
                result["link_failed_count"] = len(failed_links)
                result["link_failed_transaction_ids"] = failed_links

        return result

    async def get_space_transactions(
        self, space_id: UUID, user_uuid: UUID, page: int = 1, limit: int = 20
    ) -> dict[str, Any]:
        """Get transactions in a space with pagination metadata.

        Args:
            space_id: Space ID
            user_uuid: Requesting user's UUID
            page: Page number
            limit: Items per page

        Returns:
            Dictionary with 'transactions' (list), 'total' count, 'page' and 'limit'
        """
        await verify_membership(self.db, space_id, user_uuid)
        offset = (page - 1) * limit

        count_query = select(func.count(SpaceTransaction.id)).where(SpaceTransaction.space_id == space_id)
        count_result = await self.db.execute(count_query)
        total = count_result.scalar() or 0

        query = (
            select(SpaceTransaction)
            .where(SpaceTransaction.space_id == space_id)
            .options(
                selectinload(SpaceTransaction.transaction),
                selectinload(SpaceTransaction.added_by),
            )
            .order_by(desc(SpaceTransaction.created_at))
            .offset(offset)
            .limit(limit)
        )

        result = await self.db.execute(query)
        space_txs = result.scalars().all()

        return {
            "transactions": [self._space_transaction_to_dict(st) for st in space_txs],
            "total": total,
            "page": page,
            "limit": limit,
        }

    def _space_transaction_to_dict(self, st: SpaceTransaction) -> dict[str, Any]:
        """Convert space transaction to dictionary."""
        from app.schemas.transaction import TransactionDisplayValue

        tx = st.transaction
        amount = tx.amount if tx else Decimal("0")
        tx_type = tx.type if tx else "EXPENSE"
        currency = tx.currency if tx else "CNY"

        # Use unified transaction display value formatting
        display = TransactionDisplayValue.from_params(amount=amount, tx_type=tx_type, currency=currency)

        return {
            "id": str(tx.uuid) if tx else "",
            "type": tx_type,
            "amount": str(tx.amount) if tx else "0",
            "currency": currency,
            "description": tx.description if tx else None,
            "categoryKey": tx.category_key if tx else "",
            "transactionAt": tx.transaction_at.isoformat() if tx and tx.transaction_at else None,
            "addedByUsername": st.added_by.username if st.added_by else "Unknown",
            "addedAt": st.created_at.isoformat() if st.created_at else None,
            "display": display.model_dump(),  # Include unified transaction display format
        }
