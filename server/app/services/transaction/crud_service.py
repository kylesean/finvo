"""Transaction CRUD service for basic transaction operations."""

from __future__ import annotations

from datetime import UTC, datetime
from decimal import Decimal, InvalidOperation
from typing import Any
from uuid import UUID, uuid4

import structlog
from sqlalchemy import String, and_, cast as sa_cast, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.core.exceptions import BusinessError, CommonErrorCode, NotFoundError
from app.models.attachment import Attachment
from app.models.base import utc_now
from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction
from app.models.user import User
from app.repositories.notification_repository import NotificationRepository
from app.schemas.transaction import (
    LinkedAccountInfo,
    TransactionAttachmentItem,
    TransactionCommentItem,
    TransactionCreateResult,
    TransactionDetailResponse,
    TransactionDisplayValue,
    TransactionSpaceItem,
    TransactionUpdateResult,
    TransferInfo,
)
from app.services.transaction.comment_service import TransactionCommentService
from app.utils.currency_utils import (
    convert_to_user_base,
    get_user_base_currency,
    get_user_display_currency,
)

logger = structlog.get_logger(__name__)


class TransactionCRUDService:
    """Service for basic transaction CRUD operations."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.comments = TransactionCommentService(db)

    async def get_financial_account(
        self,
        account_id: UUID,
        user_uuid: UUID,
        *,
        for_update: bool = False,
    ) -> FinancialAccount | None:
        """Get and validate financial account.

        Args:
            account_id: Financial account UUID.
            user_uuid: Owner UUID.
            for_update: If True, acquire a row lock (``SELECT ... FOR UPDATE``)
                so concurrent balance adjustments on the same account are
                serialized instead of silently overwriting each other.

        Returns:
            The financial account or None if not found/not owned.
        """
        query = select(FinancialAccount).where(
            and_(FinancialAccount.uuid == account_id, FinancialAccount.user_uuid == user_uuid),
        )
        if for_update:
            # populate_existing: even if the row is already in the session's
            # identity map (e.g. an earlier unlocked validation read in this
            # transaction), the FOR UPDATE re-select MUST refresh its columns.
            # Without it the locked read returns the stale pre-lock snapshot and
            # a concurrent commit between the two reads is silently overwritten
            # (lost update on account balance).
            query = query.with_for_update().execution_options(populate_existing=True)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def create_transaction(
        self,
        user_uuid: UUID,
        amount: Decimal,
        transaction_type: str = "expense",
        transaction_at: datetime | None = None,
        category_key: str = "OTHERS",
        currency: str = PROJECT_DEFAULT_CURRENCY,
        raw_input: str | None = None,
        source_account_id: UUID | None = None,
        target_account_id: UUID | None = None,
        subject: str = "SELF",
        intent: str = "SURVIVAL",
        tags: list[str] | None = None,
    ) -> dict[str, Any]:
        """Create a single transaction record

        Follow the principle of "record first, then link" and defaults to not linking balance.
        """
        tx_type = transaction_type.lower()
        transfer_amount = amount
        tx_time = transaction_at or datetime.now(UTC)

        # Reject non-positive amounts instead of silently abs()-ing them
        # (update_transaction already rejected them; the create path must too,
        # otherwise the two paths disagree on what a negative amount means).
        if amount <= 0:
            raise BusinessError("Amount must be positive", "VALIDATION_ERROR")

        # Validation logic has been handled by the utility layer, Service layer mainly responsible for persistence
        source_acc = None
        target_acc = None

        if source_account_id:
            source_acc = await self.get_financial_account(source_account_id, user_uuid)
            if not source_acc:
                raise NotFoundError(
                    "Source account",
                    details={"account_id": str(source_account_id)},
                )

        if target_account_id:
            target_acc = await self.get_financial_account(target_account_id, user_uuid)
            if not target_acc:
                raise NotFoundError(
                    "Target account",
                    details={"account_id": str(target_account_id)},
                )

        tx_currency = currency.upper()
        amount_original = transfer_amount

        # Convert to user's base currency (primary_currency) with rate snapshot
        user_base = await get_user_base_currency(self.db, user_uuid)
        base_amount, exchange_rate_val = await convert_to_user_base(abs(amount_original), tx_currency, user_base)

        # Create record
        transaction = Transaction(
            uuid=uuid4(),
            user_uuid=user_uuid,
            type=tx_type.upper(),
            raw_input=raw_input or "",
            amount_original=abs(amount_original),
            amount=base_amount.quantize(Decimal("0.00000001")),
            currency=tx_currency,
            exchange_rate=exchange_rate_val.quantize(Decimal("0.00000001")),
            transaction_at=tx_time,
            transaction_timezone=str(tx_time.tzinfo or "UTC"),
            category_key=category_key.upper() if category_key else "OTHERS",
            subject=subject.upper() if subject else "SELF",
            intent=intent.upper() if intent else "SURVIVAL",
            tags=tags or [],
            source="AI",
            status="CLEARED",
            source_account_id=source_account_id,
            target_account_id=target_account_id,
        )

        self.db.add(transaction)

        # Apply the transaction's balance effect on linked accounts, converted
        # to each account's own currency (snapshot conversion + row locks).
        # EXPENSE/INCOME/TRANSFER all follow the same rule so create/update/
        # delete share one ledger convention.
        await self._apply_transaction_balance_effect(
            transaction,
            user_uuid,
            sign=1,
            source_account_id=source_account_id,
            target_account_id=target_account_id,
            for_update=True,
        )

        await self.db.commit()
        await self.db.refresh(transaction)

        # Assemble typed result (for GenUI rendering / LangGraph tools)
        linked_account: LinkedAccountInfo | None = None
        transfer_info: TransferInfo | None = None
        if tx_type != "transfer":
            linked_acc = source_acc or target_acc
            if linked_acc:
                linked_account = LinkedAccountInfo(id=str(linked_acc.uuid), name=linked_acc.name, type=linked_acc.type)
        elif source_acc and target_acc:
            transfer_info = TransferInfo(
                source_account=LinkedAccountInfo(id=str(source_acc.uuid), name=source_acc.name, type=source_acc.type),
                target_account=LinkedAccountInfo(id=str(target_acc.uuid), name=target_acc.name, type=target_acc.type),
            )

        return TransactionCreateResult(
            success=True,
            transaction_id=str(transaction.uuid),
            amount=float(amount),
            currency=currency,
            type=tx_type.upper(),
            category_key=transaction.category_key,
            subject=transaction.subject,
            intent=transaction.intent,
            tags=transaction.tags,
            transaction_at=transaction.transaction_at.isoformat(),
            status="success",
            raw_input=transaction.raw_input,
            account_linked=source_acc is not None or target_acc is not None,
            linked_account=linked_account,
            transfer_info=transfer_info,
        ).model_dump()

    async def get_transaction_detail(self, transaction_id: UUID, user_uuid: UUID) -> dict[str, Any] | None:
        """Get transaction details (including comments)

        Access is granted if:
        1. User is the transaction owner, OR
        2. Transaction is linked to a space the user is a member of.

        Args:
            transaction_id: Transaction ID
            user_uuid: User UUID

        Returns:
            Transaction details dictionary (including comments), returns None if not found
        """
        from app.models.shared_space import SharedSpace, SpaceMember, SpaceTransaction

        # First, load the transaction by ID (no owner filter)
        query = (
            select(Transaction).options(selectinload(Transaction.comments)).where(Transaction.uuid == transaction_id)
        )
        result = await self.db.execute(query)
        transaction = result.scalar_one_or_none()

        if not transaction:
            return None

        # Check access: owner or space member
        if transaction.user_uuid != user_uuid:
            space_access_query = (
                select(SpaceTransaction.id)
                .join(SpaceMember, SpaceMember.space_id == SpaceTransaction.space_id)
                .where(
                    SpaceTransaction.transaction_id == transaction_id,
                    SpaceMember.user_uuid == user_uuid,
                    SpaceMember.status == "ACCEPTED",
                )
                .limit(1)
            )
            space_result = await self.db.execute(space_access_query)
            if space_result.scalar_one_or_none() is None:
                return None

        # Get user preferred currency (base currency)
        display_currency = await get_user_display_currency(self.db, user_uuid)

        # Get associated shared spaces
        spaces_query = (
            select(SharedSpace)
            .join(SpaceTransaction, SpaceTransaction.space_id == SharedSpace.id)
            .where(SpaceTransaction.transaction_id == transaction_id)
        )
        spaces_result = await self.db.execute(spaces_query)
        associated_spaces = spaces_result.scalars().all()
        spaces_data = [TransactionSpaceItem(id=str(s.id), name=s.name) for s in associated_spaces]

        # Batch-load all comment authors in one query to avoid N+1.
        comments_data = []
        if transaction.comments:
            comment_user_uuids = {c.user_uuid for c in transaction.comments}
            users_result = await self.db.execute(select(User).where(User.uuid.in_(comment_user_uuids)))
            user_by_uuid = {u.uuid: u for u in users_result.scalars().all()}

            for comment in transaction.comments:
                user = user_by_uuid.get(comment.user_uuid)
                comments_data.append(
                    TransactionCommentItem(
                        id=str(comment.uuid),
                        transaction_id=str(comment.transaction_id),
                        user_uuid=str(comment.user_uuid),
                        user_name=user.username if user else "Unknown",
                        user_avatar_url=user.avatar_url if user else None,
                        parent_comment_id=str(comment.parent_comment_id) if comment.parent_comment_id else None,
                        comment_text=comment.comment_text,
                        mentioned_user_ids=comment.mentioned_user_ids or [],
                        created_at=comment.created_at.isoformat() if comment.created_at else None,
                        updated_at=comment.updated_at.isoformat() if comment.updated_at else None,
                    )
                )

        # Display: show original currency amount for individual transaction
        amount_val = float(transaction.amount_original)
        original_currency = (transaction.currency or display_currency).upper()

        # Query attachments linked via source_thread_id
        attachments_data: list[TransactionAttachmentItem] = []
        if transaction.source_thread_id:
            # thread_id is text in DB but UUID in model; cast column to String for comparison
            att_query = select(Attachment).where(
                sa_cast(Attachment.thread_id, String) == str(transaction.source_thread_id),
            )
            att_result = await self.db.execute(att_query)
            attachments = att_result.scalars().all()
            attachments_data = [
                TransactionAttachmentItem(
                    id=str(a.id),
                    filename=a.filename,
                    mime_type=a.mime_type,
                    size=a.size,
                    url=f"/files/view/{a.id}",
                    is_image=a.is_image,
                    created_at=a.created_at.isoformat() if a.created_at else None,
                )
                for a in attachments
            ]

        return TransactionDetailResponse(
            id=str(transaction.uuid),
            user_uuid=str(transaction.user_uuid),
            type=transaction.type,
            amount=round(amount_val, 2),
            # Numeric (float) — must stay consistent with TransactionUpdateResult
            # and TransactionResponse (list endpoints); a string here breaks the
            # shared client contract for amountOriginal.
            amount_original=float(transaction.amount_original) if transaction.amount_original else None,
            amount_base=float(transaction.amount),
            currency=original_currency,
            base_currency=display_currency,
            exchange_rate=str(transaction.exchange_rate) if transaction.exchange_rate else None,
            category_key=transaction.category_key,
            raw_input=transaction.raw_input,
            description=transaction.description,
            transaction_at=transaction.transaction_at.isoformat() if transaction.transaction_at else None,
            transaction_timezone=transaction.transaction_timezone,
            source_account_id=str(transaction.source_account_id) if transaction.source_account_id else None,
            target_account_id=str(transaction.target_account_id) if transaction.target_account_id else None,
            tags=transaction.tags or [],
            location=transaction.location,
            latitude=str(transaction.latitude) if transaction.latitude else None,
            longitude=str(transaction.longitude) if transaction.longitude else None,
            source=transaction.source,
            status=transaction.status,
            created_at=transaction.created_at.isoformat() if transaction.created_at else None,
            updated_at=transaction.updated_at.isoformat() if transaction.updated_at else None,
            comments=comments_data,
            comment_count=len(comments_data),
            spaces=spaces_data,
            source_thread_id=str(transaction.source_thread_id) if transaction.source_thread_id else None,
            attachments=attachments_data,
            display=TransactionDisplayValue.from_params(
                amount=transaction.amount_original, tx_type=transaction.type, currency=original_currency
            ),
        ).model_dump(by_alias=True)

    async def update_transaction(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
        *,
        amount: Decimal | None = None,
        category_key: str | None = None,
        raw_input: str | None = None,
        transaction_at: datetime | None = None,
        tags: list[str] | None = None,
    ) -> dict[str, Any]:
        """Update transaction properties.

        Supports updating: amount, category, raw_input, transaction_at, tags.
        Returns _intent='update' for reactive UI updates via DataModelUpdate.

        Args:
            transaction_id: Transaction ID
            user_uuid: User UUID
            amount: New amount (optional)
            category_key: New category key (optional)
            raw_input: New description (optional)
            transaction_at: New transaction time (optional)
            tags: New tags list (optional)

        Returns:
            Updated transaction data with _intent flag

        Raises:
            NotFoundError: Transaction not found
            BusinessError: Permission denied
        """
        # Query transaction
        query = select(Transaction).where(Transaction.uuid == transaction_id)
        result = await self.db.execute(query)
        transaction = result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("Transaction")

        # Verify ownership
        if transaction.user_uuid != user_uuid:
            raise BusinessError("Permission denied to modify this transaction", "PERMISSION_DENIED")

        # Track what changed for DataModelUpdate paths
        changed_fields: list[str] = []

        # Update amount if provided
        if amount is not None:
            if amount <= 0:
                raise BusinessError("Amount must be positive", "VALIDATION_ERROR")
            old_amount = transaction.amount
            old_amount_original = transaction.amount_original
            user_base = await get_user_base_currency(self.db, user_uuid)
            old_currency = (transaction.currency or user_base).upper()
            new_original = amount

            # Get user's base currency and transaction currency
            tx_currency = (transaction.currency or user_base).upper()

            # Convert new original amount to user base currency for storage
            base_amount, new_rate = await convert_to_user_base(new_original, tx_currency, user_base)

            transaction.amount = base_amount.quantize(Decimal("0.00000001"))
            transaction.amount_original = new_original
            transaction.exchange_rate = new_rate.quantize(Decimal("0.00000001"))
            changed_fields.append("/amount")

            # Roll back the old balance effect and apply the new one, each
            # converted to the linked account's own currency (snapshot-based,
            # with row locks). EXPENSE adjusts the source, INCOME the target,
            # TRANSFER both ends. PENDING rows have no booked effect, so an
            # amount change there must not touch balances either.
            if transaction.status != "PENDING":
                await self._apply_balance_diff(
                    transaction,
                    user_uuid,
                    old_amount_original=old_amount_original,
                    old_amount_base=old_amount,
                    old_currency=old_currency,
                )

        # Update category if provided
        if category_key is not None:
            transaction.category_key = category_key.upper()
            changed_fields.append("/category_key")

        # Update raw_input (description) if provided
        if raw_input is not None:
            transaction.raw_input = raw_input
            changed_fields.append("/raw_input")

        # Update transaction time if provided
        if transaction_at is not None:
            transaction.transaction_at = transaction_at
            changed_fields.append("/transaction_at")

        # Update tags if provided
        if tags is not None:
            transaction.tags = tags
            changed_fields.append("/tags")

        # Update timestamp
        transaction.updated_at = utc_now()

        await self.db.commit()
        await self.db.refresh(transaction)

        logger.info(
            "transaction_updated",
            transaction_id=str(transaction_id),
            changed_fields=changed_fields,
        )

        # Get display values - show original currency amount
        display_currency = await get_user_display_currency(self.db, user_uuid)
        original_currency = (transaction.currency or display_currency).upper()
        display_amount = float(transaction.amount_original)
        tx_at = transaction.transaction_at
        updated_at = transaction.updated_at

        return TransactionUpdateResult(
            success=True,
            transaction_id=str(transaction.uuid),
            amount=round(display_amount, 2),
            amount_original=float(transaction.amount_original) if transaction.amount_original else display_amount,
            amount_base=float(transaction.amount),
            currency=original_currency,
            base_currency=display_currency,
            type=transaction.type,
            category_key=transaction.category_key,
            raw_input=transaction.raw_input,
            tags=transaction.tags or [],
            transaction_at=tx_at.isoformat() if tx_at else None,
            updated_at=updated_at.isoformat() if updated_at else None,
            intent="update",
            changed_fields=changed_fields,
            message="Transaction updated",
        ).model_dump(by_alias=True)

    async def delete_transaction(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
    ) -> bool:
        """Delete transaction record

        Args:
            transaction_id: Transaction ID (UUID object)
            user_uuid: User UUID (UUID object, used for ownership verification)

        Returns:
            Whether the deletion was successful

        Raises:
            NotFoundError: Transaction not found
            BusinessError: Permission denied
        """
        # Query transaction record
        query = select(Transaction).where(Transaction.uuid == transaction_id)
        result = await self.db.execute(query)
        transaction = result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("Transaction")

        # Verify ownership
        if transaction.user_uuid != user_uuid:
            raise BusinessError("Permission denied to delete this transaction", "PERMISSION_DENIED")

        # PENDING rows carry no booked balance effect (see confirm/skip docs),
        # so deleting one must not reverse an effect that was never applied.
        if transaction.status != "PENDING":
            # Reverse the transaction's balance effect before deletion (EXPENSE
            # adds back, INCOME subtracts, TRANSFER reverses both ends), using the
            # same snapshot conversion applied at creation.
            await self._apply_transaction_balance_effect(
                transaction,
                user_uuid,
                sign=-1,
                source_account_id=transaction.source_account_id,
                target_account_id=transaction.target_account_id,
                for_update=True,
            )

        # Delete transaction record (associated comments and shares will be automatically deleted through ORM cascade)
        await self.db.delete(transaction)
        await self.db.commit()

        logger.info(
            "transaction_deleted",
            transaction_id=str(transaction_id),
            user_uuid=str(user_uuid),
        )

        return True

    async def _get_owned_transaction(self, transaction_id: UUID, user_uuid: UUID) -> Transaction:
        """Fetch a transaction scoped to its owner; raise NotFoundError if missing.

        Scoping by ``user_uuid`` means a non-owner gets a 404 (not a 403),
        avoiding leaking the existence of rows the user doesn't own.
        """
        result = await self.db.execute(
            select(Transaction).where(
                and_(Transaction.uuid == transaction_id, Transaction.user_uuid == user_uuid),
            )
        )
        transaction = result.scalar_one_or_none()
        if transaction is None:
            raise NotFoundError("Transaction")
        return transaction

    async def confirm_pending_transaction(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
    ) -> dict[str, Any]:
        """Confirm a PENDING transaction, changing its status to CONFIRMED.

        PENDING rows are generated by recurring rules that require user
        confirmation; they carry no booked balance effect, so confirming only
        flips the status (no account adjustment). The associated
        ``recurring_pending`` notification is marked read in the same transaction.

        Raises:
            NotFoundError: Transaction not found (or not owned by ``user_uuid``).
            BusinessError: Transaction is not in the PENDING status.
        """
        transaction = await self._get_owned_transaction(transaction_id, user_uuid)

        if transaction.status != "PENDING":
            raise BusinessError(
                "Transaction is not in PENDING status",
                error_code=CommonErrorCode.VALIDATION_ERROR,
            )

        transaction.status = "CONFIRMED"

        # Book the deferred balance effect now: recurring jobs book balances
        # immediately for auto-confirmed transactions, so the invariant
        # "CONFIRMED ⇒ balance booked" must hold for user-confirmed rows too.
        await self._apply_transaction_balance_effect(
            transaction,
            user_uuid,
            sign=1,
            source_account_id=transaction.source_account_id,
            target_account_id=transaction.target_account_id,
            for_update=True,
        )

        await NotificationRepository(self.db).mark_recurring_pending_read(user_uuid, transaction_id)
        await self.db.commit()

        logger.info(
            "transaction_confirmed",
            transaction_id=str(transaction_id),
            user_uuid=str(user_uuid),
        )
        return {"id": str(transaction.uuid), "status": "CONFIRMED"}

    async def skip_pending_transaction(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
    ) -> None:
        """Skip (delete) a PENDING transaction.

        The PENDING row has no booked balance effect, so it is deleted directly
        without reversing any account adjustment (unlike :meth:`delete_transaction`,
        which reverses the balance of a CLEARED transaction). The associated
        ``recurring_pending`` notification is marked read first, while the row
        still exists for correlation.

        Raises:
            NotFoundError: Transaction not found (or not owned by ``user_uuid``).
            BusinessError: Transaction is not in the PENDING status.
        """
        transaction = await self._get_owned_transaction(transaction_id, user_uuid)

        if transaction.status != "PENDING":
            raise BusinessError(
                "Transaction is not in PENDING status",
                error_code=CommonErrorCode.VALIDATION_ERROR,
            )

        await NotificationRepository(self.db).mark_recurring_pending_read(user_uuid, transaction_id)
        await self.db.delete(transaction)
        await self.db.commit()

        logger.info(
            "transaction_skipped",
            transaction_id=str(transaction_id),
            user_uuid=str(user_uuid),
        )

    async def list_pending_transactions(self, user_uuid: UUID) -> list[dict[str, Any]]:
        """List a user's PENDING transactions (newest first), serialized for the API.

        These are auto-generated by recurring rules that require confirmation.
        """
        result = await self.db.execute(
            select(Transaction)
            .where(
                and_(
                    Transaction.user_uuid == user_uuid,
                    Transaction.status == "PENDING",
                )
            )
            .order_by(Transaction.transaction_at.desc())
        )
        return [
            {
                "id": str(tx.uuid),
                "type": tx.type,
                "amount": str(tx.amount_original),
                "currency": tx.currency,
                "category_key": tx.category_key,
                "description": tx.description,
                "transaction_at": tx.transaction_at.isoformat() if tx.transaction_at else None,
                "source": tx.source,
                "recurring_transaction_id": str(tx.recurring_transaction_id) if tx.recurring_transaction_id else None,
            }
            for tx in result.scalars().all()
        ]

    async def create_batch_transactions(
        self,
        user_uuid: UUID,
        data: dict[str, Any],
        source_thread_id: UUID | None = None,
    ) -> dict[str, Any]:
        """Batch create transactions

        Base currency scheme:
        - amount_original: Original input amount
        - amount: Base amount converted to CNY
        - currency: Original currency (if not specified, use the user's primaryCurrency)
        - exchange_rate: Exchange rate snapshot at the time of storage
        """
        transactions_data = data.get("transactions", [])
        source_account_id = data.get("source_account_id")

        # Validate/normalize the shared source account once, before the loop, instead of
        # parsing an unvalidated raw value per item where a bad UUID would surface as a 500.
        source_account_uuid: UUID | None = None
        if source_account_id:
            try:
                source_account_uuid = UUID(str(source_account_id))
            except (ValueError, AttributeError):
                raise BusinessError(message="Invalid source_account_id", error_code="INVALID_ACCOUNT_ID") from None

        # Get user's default currency (primaryCurrency) as the default value when currency is not specified
        user_default_currency = await get_user_display_currency(self.db, user_uuid)
        logger.debug(
            "batch_create_using_default_currency", user_uuid=str(user_uuid), default_currency=user_default_currency
        )

        # Capture once for consistency across all items in the batch.
        # Use the tzinfo of `now` for transaction_timezone, matching create_transaction()
        # — never hardcode a region-specific zone for a globally usable product.
        now = utc_now()
        tx_timezone = str(now.tzinfo or "UTC")

        # Per-item validation with partial-failure semantics: this service is
        # also fed raw LLM-generated dicts (LangGraph tools), where a missing
        # key or malformed amount previously surfaced as an uncaught
        # KeyError/InvalidOperation → 500 that aborted the ENTIRE batch.
        # Bad items are now rejected individually and reported in `failed`.
        created_transactions: list[Transaction] = []
        failed: list[dict[str, str]] = []

        for index, item in enumerate(transactions_data):
            try:
                raw_amount = item.get("amount")
                if raw_amount is None or raw_amount == "":
                    raise BusinessError("Amount is required", "VALIDATION_ERROR")
                amount_original = Decimal(str(raw_amount))
                if amount_original <= 0:
                    raise BusinessError("Amount must be greater than 0", "VALIDATION_ERROR")

                # Use user's primaryCurrency as default value, instead of hardcoding CNY
                currency = (item.get("currency") or user_default_currency).upper()

                # Convert to user's base currency with rate snapshot
                base_amount, exchange_rate_val = await convert_to_user_base(
                    amount_original, currency, user_default_currency
                )
                amount = base_amount

                tx = Transaction(
                    uuid=uuid4(),
                    user_uuid=user_uuid,
                    type=item.get("transaction_type", "EXPENSE").upper(),
                    amount=amount.quantize(Decimal("0.00000001")),
                    amount_original=amount_original,
                    currency=currency,
                    exchange_rate=exchange_rate_val.quantize(Decimal("0.00000001")),
                    category_key=item.get("category_key", "OTHERS"),
                    tags=item.get("tags", []),
                    raw_input=item.get("raw_input"),
                    source_account_id=source_account_uuid,
                    transaction_at=now,
                    transaction_timezone=tx_timezone,
                    source="AI",
                    status="CLEARED",
                    source_thread_id=source_thread_id,
                )
                self.db.add(tx)
                created_transactions.append(tx)
            except BusinessError as e:
                logger.warning("batch_create_item_rejected", index=index, error=e.message)
                failed.append({"index": str(index), "error": e.message})
            except (ValueError, InvalidOperation) as e:
                logger.warning("batch_create_item_invalid", index=index, error=str(e))
                failed.append({"index": str(index), "error": "Invalid amount or currency"})

        await self.db.commit()

        # Refresh all records to get IDs
        for tx in created_transactions:
            await self.db.refresh(tx)

        return {
            "success": len(failed) == 0,
            "count": len(created_transactions),
            "failed_count": len(failed),
            "failed": failed,
            "account_id": str(source_account_id) if source_account_id else None,
            "transactions": [
                {
                    "id": str(tx.uuid),
                    "amount": str(tx.amount),
                    "type": tx.type,
                    "tags": tx.tags,
                    "category_key": tx.category_key,
                    "originalAmount": str(tx.amount_original),
                    "originalCurrency": tx.currency,
                    "display": TransactionDisplayValue.from_params(
                        amount=tx.amount_original, tx_type=tx.type, currency=tx.currency
                    ).model_dump(),
                }
                for tx in created_transactions
            ],
        }

    async def update_batch_transactions_account(
        self,
        user_uuid: UUID,
        transaction_ids: list[UUID],
        account_id: UUID | None,
    ) -> dict[str, Any]:
        """Batch update transaction account.

        Returns a partial-failure result: ``success`` is True only if every
        item was updated; ``failed`` lists the transaction_ids that raised.
        Previously this always reported success=True and ``count`` conflated
        attempted with successful updates, masking total failures.
        """
        results: list[dict[str, Any]] = []
        failed: list[dict[str, str]] = []
        for tx_id in transaction_ids:
            try:
                res = await self.update_transaction_account(
                    transaction_id=tx_id, user_uuid=user_uuid, account_id=account_id
                )
                results.append(res)  # type: ignore[arg-type]
            except Exception as e:
                logger.error("batch_update_tx_failed", tx_id=str(tx_id), error=str(e))
                failed.append({"transaction_id": str(tx_id), "error": str(e)})

        return {
            "success": len(failed) == 0,
            "count": len(results),
            "failed_count": len(failed),
            "failed": failed,
            "account_id": str(account_id) if account_id else None,
        }

    async def update_transaction_account(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
        account_id: UUID | None,
    ) -> dict[str, Any] | None:
        """Update transaction account association.

        Supports cross-currency account association: if the transaction
        currency differs from the account currency, a real-time exchange
        rate is used to convert the amount. Account balance is adjusted
        in the account's local currency.

        Args:
            transaction_id: Transaction ID
            user_uuid: User UUID
            account_id: New account ID, or None to cancel association

        Returns:
            Updated transaction details

        Raises:
            NotFoundError: Transaction or account not found
            BusinessError: Permission denied or exchange rate unavailable
        """
        query = select(Transaction).where(Transaction.uuid == transaction_id)
        result = await self.db.execute(query)
        transaction = result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("Transaction")

        if transaction.user_uuid != user_uuid:
            raise BusinessError("Permission denied to modify this transaction", "PERMISSION_DENIED")

        is_income = transaction.type == "INCOME"

        # Expense → source_account_id; Income → target_account_id (Transfer uses
        # source_account_id too).
        if is_income:
            old_account_id = transaction.target_account_id
        else:
            old_account_id = transaction.source_account_id

        new_account_id = account_id

        if old_account_id == new_account_id:
            return await self.get_transaction_detail(transaction_id, user_uuid)

        # PENDING rows carry no booked balance effect, so re-association must
        # not adjust any balance (the association itself is still updated).
        if transaction.status != "PENDING":
            user_base_currency = await get_user_base_currency(self.db, user_uuid)

            # Reverse the old account's effect and apply the new account's
            # effect. Both go through the SAME row-locked, snapshot-converted
            # ledger helper as create/delete, so a TRANSFER re-association
            # credits the old source back and debits the new one (previously
            # this path skipped TRANSFER entirely and silently drifted).
            if old_account_id:
                await self._apply_account_balance_effect(
                    transaction,
                    account_id=old_account_id,
                    user_uuid=user_uuid,
                    user_base_currency=user_base_currency,
                    sign=-1,
                    for_update=True,
                )
            if new_account_id:
                await self._apply_account_balance_effect(
                    transaction,
                    account_id=new_account_id,
                    user_uuid=user_uuid,
                    user_base_currency=user_base_currency,
                    sign=1,
                    for_update=True,
                )

        if is_income:
            transaction.target_account_id = new_account_id
        else:
            transaction.source_account_id = new_account_id
        transaction.updated_at = utc_now()

        await self.db.commit()

        logger.info(
            "transaction_account_updated",
            transaction_id=str(transaction_id),
            old_account_id=str(old_account_id) if old_account_id else None,
            new_account_id=str(new_account_id) if new_account_id else None,
        )

        return await self.get_transaction_detail(transaction_id, user_uuid)

    async def _convert_snapshot_amount(
        self,
        *,
        amount_original: Decimal,
        amount_base: Decimal,
        tx_currency: str | None,
        target_currency: str,
        user_base_currency: str,
    ) -> Decimal:
        """Convert a transaction snapshot amount to an account's currency.

        Balance apply/rollback must use the transaction's recorded snapshot so
        it matches what was originally booked, instead of re-converting at the
        *live* rate:
        - same currency as the transaction -> ``amount_original`` (exact)
        - the user's real base currency     -> ``amount`` (snapshot-based, stable)
        - any other currency               -> live conversion; raises if the rate
          is unavailable (never silently mislabels a currency)

        ``amount_base`` is denominated in the user's base currency, so comparing
        against the hardcoded USD hub constant would mislabel currencies for
        non-USD users — the user's real base currency is always used here.

        Raises:
            BusinessError: If a required cross-currency conversion is unavailable.
        """
        tx_currency = (tx_currency or target_currency).upper()
        target = target_currency.upper()
        if target == tx_currency:
            return abs(amount_original)
        if target == user_base_currency.upper():
            return abs(amount_base)

        from app.services.exchange_rate_service import exchange_rate_service

        converted = await exchange_rate_service.convert(
            amount=abs(amount_original),
            from_currency=tx_currency,
            to_currency=target,
        )
        if converted is None:
            raise BusinessError(
                f"Unable to get exchange rate from {tx_currency} to {target}, please try again later",
                "EXCHANGE_RATE_UNAVAILABLE",
            )
        return abs(converted)

    async def _apply_account_balance_effect(
        self,
        transaction: Transaction,
        *,
        account_id: UUID | None,
        user_uuid: UUID,
        user_base_currency: str,
        sign: int,
        for_update: bool = False,
    ) -> None:
        """Apply (sign=+1) or reverse (sign=-1) a transaction's balance effect on one account.

        EXPENSE and TRANSFER debit their linked account; INCOME credits it. The
        effect is converted to the account's own currency from the transaction
        snapshot (see :meth:`_convert_snapshot_amount`). Accounts that no longer
        exist (or are no longer owned) are skipped so stale links never crash
        the ledger. Row locks serialize concurrent adjustments on the same
        account — always keep ``for_update=True`` when mutating balances.
        """
        if account_id is None:
            return
        account = await self.get_financial_account(account_id, user_uuid, for_update=for_update)
        if not account:
            return

        acc_currency = account.currency_code or user_base_currency
        effect = await self._convert_snapshot_amount(
            amount_original=transaction.amount_original,
            amount_base=transaction.amount,
            tx_currency=transaction.currency,
            target_currency=acc_currency,
            user_base_currency=user_base_currency,
        )
        # Expense/Transfer debit the linked account, Income credits it.
        direction = 1 if transaction.type == "INCOME" else -1
        account.current_balance = (account.current_balance or Decimal("0")) + sign * direction * effect
        account.updated_at = utc_now()

        logger.info(
            "account_balance_effect",
            transaction_id=str(transaction.uuid),
            account_id=str(account_id),
            account_currency=acc_currency,
            effect=str(sign * direction * effect),
            sign=sign,
        )

    async def _apply_transaction_balance_effect(
        self,
        transaction: Transaction,
        user_uuid: UUID,
        *,
        sign: int,
        source_account_id: UUID | None,
        target_account_id: UUID | None,
        for_update: bool = False,
    ) -> None:
        """Apply (sign=1) or reverse (sign=-1) a transaction's balance effect.

        EXPENSE deducts the source account, INCOME credits the target account,
        TRANSFER deducts the source and credits the target. The amount is
        converted from the transaction's stored snapshot to each account's own
        currency (see ``_convert_snapshot_amount``) so apply and rollback are
        symmetric and never silently mislabel a currency. Accounts that no
        longer exist are skipped.
        """
        user_base_currency = await get_user_base_currency(self.db, user_uuid)
        tx_type = transaction.type

        if tx_type == "EXPENSE":
            await self._apply_account_balance_effect(
                transaction,
                account_id=source_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                for_update=for_update,
            )
        elif tx_type == "INCOME":
            await self._apply_account_balance_effect(
                transaction,
                account_id=target_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                for_update=for_update,
            )
        elif tx_type == "TRANSFER":
            await self._apply_account_balance_effect(
                transaction,
                account_id=source_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                for_update=for_update,
            )
            await self._apply_account_balance_effect(
                transaction,
                account_id=target_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                for_update=for_update,
            )

    async def _apply_balance_diff(
        self,
        transaction: Transaction,
        user_uuid: UUID,
        *,
        old_amount_original: Decimal,
        old_amount_base: Decimal,
        old_currency: str,
    ) -> None:
        """Adjust linked account balances by the (new - old) effect after an amount update.

        The old effect is derived from the pre-update snapshot (original amount
        and currency) and the new effect from the transaction's fresh snapshot,
        both converted to each account's own currency. Row locks serialize
        concurrent updates to the same account.
        """
        user_base_currency = await get_user_base_currency(self.db, user_uuid)
        tx_type = transaction.type

        async def adjust(account_id: UUID | None, direction: int) -> None:
            if account_id is None:
                return
            account = await self.get_financial_account(account_id, user_uuid, for_update=True)
            if not account:
                return
            acc_currency = account.currency_code or user_base_currency
            old_effect = await self._convert_snapshot_amount(
                amount_original=old_amount_original,
                amount_base=old_amount_base,
                tx_currency=old_currency,
                target_currency=acc_currency,
                user_base_currency=user_base_currency,
            )
            new_effect = await self._convert_snapshot_amount(
                amount_original=transaction.amount_original,
                amount_base=transaction.amount,
                tx_currency=transaction.currency,
                target_currency=acc_currency,
                user_base_currency=user_base_currency,
            )
            delta = new_effect - old_effect
            account.current_balance = (account.current_balance or Decimal("0")) + direction * delta
            account.updated_at = utc_now()

        if tx_type == "EXPENSE":
            await adjust(transaction.source_account_id, -1)
        elif tx_type == "INCOME":
            await adjust(transaction.target_account_id, +1)
        elif tx_type == "TRANSFER":
            await adjust(transaction.source_account_id, -1)
            await adjust(transaction.target_account_id, +1)

    # ===== Comment Operations =====

    async def _can_access_transaction_comments(self, transaction_id: UUID, user_uuid: UUID) -> Transaction:
        """Check if user can access transaction comments."""
        return await self.comments._can_access_transaction_comments(transaction_id, user_uuid)

    async def get_comments_for_transaction(self, transaction_id: UUID, user_uuid: UUID) -> list[dict[str, Any]]:
        """Get transaction comments list."""
        return await self.comments.get_comments_for_transaction(transaction_id, user_uuid)

    async def add_comment(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
        comment_text: str,
        parent_comment_id: UUID | None = None,
        mentioned_user_ids: list[str] | None = None,
        commenter_username: str = "Unknown",
    ) -> dict[str, Any]:
        """Add transaction comment."""
        return await self.comments.add_comment(
            transaction_id,
            user_uuid,
            comment_text,
            parent_comment_id,
            mentioned_user_ids=mentioned_user_ids,
            commenter_username=commenter_username,
        )

    async def _notify_mentioned_users(
        self,
        mentioned_user_ids: list[str],
        transaction_id: UUID,
        comment_id: UUID,
        commenter_username: str,
        comment_text: str,
        parent_author_uuid: str | None = None,
    ) -> None:
        """Create notifications for mentioned users and push via WebSocket."""
        return await self.comments._notify_mentioned_users(
            mentioned_user_ids,
            transaction_id,
            comment_id,
            commenter_username,
            comment_text,
            parent_author_uuid=parent_author_uuid,
        )

    async def delete_comment(self, comment_id: UUID, user_uuid: UUID) -> bool:
        """Delete comment."""
        return await self.comments.delete_comment(comment_id, user_uuid)

    async def _broadcast_comment_event(
        self,
        transaction_id: UUID,
        comment_id: UUID,
        action: str,
    ) -> None:
        """Broadcast real-time comment created/deleted event to all space members / transaction participants."""
        return await self.comments._broadcast_comment_event(transaction_id, comment_id, action)
