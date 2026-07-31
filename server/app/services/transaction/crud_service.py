"""Transaction CRUD service for basic transaction operations."""

from datetime import UTC, datetime
from decimal import Decimal
from typing import Any
from uuid import UUID, uuid4

import structlog
from sqlalchemy import Select, String, and_, cast as sa_cast, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.config.currency import PROJECT_DEFAULT_CURRENCY
from app.core.exceptions import BusinessError, NotFoundError
from app.models.attachment import Attachment
from app.models.base import utc_now
from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction, TransactionComment
from app.models.user import User
from app.schemas.transaction import TransactionDisplayValue
from app.utils.currency_utils import (
    BASE_CURRENCY,
    convert_to_user_base,
    get_user_base_currency,
    get_user_display_currency,
)
from app.utils.identicon import default_avatar_url

logger = structlog.get_logger(__name__)


class TransactionCRUDService:
    """Service for basic transaction CRUD operations."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_financial_account(self, account_id: UUID, user_uuid: UUID) -> FinancialAccount | None:
        """Get and validate financial account."""
        query = select(FinancialAccount).where(
            and_(FinancialAccount.id == account_id, FinancialAccount.user_uuid == user_uuid),
        )
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
            id=uuid4(),
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

        # Transfer scenario: immediately update account balance
        if tx_type == "transfer" and source_acc and target_acc:
            # Deduct from source account
            source_acc.current_balance -= transfer_amount
            source_acc.updated_at = datetime.now(UTC)
            # Add to target account
            target_acc.current_balance += transfer_amount
            target_acc.updated_at = datetime.now(UTC)

        await self.db.commit()
        await self.db.refresh(transaction)

        # Assemble return result (for GenUI rendering)
        result = {
            "success": True,
            "transaction_id": str(transaction.id),
            "amount": float(amount),
            "currency": currency,
            "type": tx_type.upper(),
            "category_key": transaction.category_key,
            "subject": transaction.subject,
            "intent": transaction.intent,
            "tags": transaction.tags,
            "transaction_at": transaction.transaction_at.isoformat(),
            "status": "success",
            "raw_input": transaction.raw_input,
            "account_linked": source_acc is not None or target_acc is not None,
        }

        if tx_type != "transfer":
            linked_acc = source_acc or target_acc
            if linked_acc:
                result["linked_account"] = {
                    "id": str(linked_acc.id),
                    "name": linked_acc.name,
                    "type": linked_acc.type,
                }
        else:
            if source_acc and target_acc:
                result["transfer_info"] = {
                    "source_account": {
                        "id": str(source_acc.id),
                        "name": source_acc.name,
                        "type": source_acc.type,
                    },
                    "target_account": {
                        "id": str(target_acc.id),
                        "name": target_acc.name,
                        "type": target_acc.type,
                    },
                }

        return result

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
        query = select(Transaction).options(selectinload(Transaction.comments)).where(Transaction.id == transaction_id)
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
        spaces_data = [{"id": str(s.id), "name": s.name} for s in associated_spaces]

        # Batch-load all comment authors in one query to avoid N+1.
        comments_data = []
        if transaction.comments:
            comment_user_uuids = {c.user_uuid for c in transaction.comments}
            users_result = await self.db.execute(select(User).where(User.uuid.in_(comment_user_uuids)))
            user_by_uuid = {u.uuid: u for u in users_result.scalars().all()}

            for comment in transaction.comments:
                user = user_by_uuid.get(comment.user_uuid)
                comments_data.append(
                    {
                        "id": comment.id,
                        "transactionId": str(comment.transaction_id),
                        "userUuid": str(comment.user_uuid),
                        "userName": user.username if user else "Unknown",
                        "userAvatarUrl": user.avatar_url if user else None,
                        "parentCommentId": comment.parent_comment_id,
                        "commentText": comment.comment_text,
                        "mentionedUserIds": comment.mentioned_user_ids or [],
                        "createdAt": comment.created_at.isoformat() if comment.created_at else None,
                        "updatedAt": comment.updated_at.isoformat() if comment.updated_at else None,
                    }
                )

        # Display: show original currency amount for individual transaction
        amount_val = float(transaction.amount_original)
        original_currency = (transaction.currency or display_currency).upper()

        # Query attachments linked via source_thread_id
        attachments_data: list[dict[str, Any]] = []
        if transaction.source_thread_id:
            # thread_id is text in DB but UUID in model; cast column to String for comparison
            att_query = select(Attachment).where(
                sa_cast(Attachment.thread_id, String) == str(transaction.source_thread_id),
            )
            att_result = await self.db.execute(att_query)
            attachments = att_result.scalars().all()
            attachments_data = [
                {
                    "id": str(a.id),
                    "filename": a.filename,
                    "mimeType": a.mime_type,
                    "size": a.size,
                    "url": f"/files/view/{a.id}",
                    "isImage": a.is_image,
                    "createdAt": a.created_at.isoformat() if a.created_at else None,
                }
                for a in attachments
            ]

        return {
            "id": str(transaction.id),
            "userUuid": str(transaction.user_uuid),
            "type": transaction.type,
            "amount": round(amount_val, 2),
            "amountOriginal": str(transaction.amount_original) if transaction.amount_original else None,
            "amountBase": float(transaction.amount),
            "currency": original_currency,
            "baseCurrency": display_currency,
            "exchangeRate": str(transaction.exchange_rate) if transaction.exchange_rate else None,
            "categoryKey": transaction.category_key,
            "rawInput": transaction.raw_input,
            "description": transaction.description,
            "transactionAt": transaction.transaction_at.isoformat() if transaction.transaction_at else None,
            "transactionTimezone": transaction.transaction_timezone,
            "sourceAccountId": transaction.source_account_id,
            "targetAccountId": transaction.target_account_id,
            "tags": transaction.tags or [],
            "location": transaction.location,
            "latitude": str(transaction.latitude) if transaction.latitude else None,
            "longitude": str(transaction.longitude) if transaction.longitude else None,
            "source": transaction.source,
            "status": transaction.status,
            "createdAt": transaction.created_at.isoformat() if transaction.created_at else None,
            "updatedAt": transaction.updated_at.isoformat() if transaction.updated_at else None,
            "comments": comments_data,
            "commentCount": len(comments_data),
            "spaces": spaces_data,
            "sourceThreadId": str(transaction.source_thread_id) if transaction.source_thread_id else None,
            "attachments": attachments_data,
            "display": TransactionDisplayValue.from_params(
                amount=transaction.amount_original, tx_type=transaction.type, currency=original_currency
            ).model_dump(),
        }

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
        query = select(Transaction).where(Transaction.id == transaction_id)
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
            new_original = amount

            # Get user's base currency and transaction currency
            user_base = await get_user_base_currency(self.db, user_uuid)
            tx_currency = (transaction.currency or user_base).upper()

            # Convert new original amount to user base currency for storage
            base_amount, new_rate = await convert_to_user_base(new_original, tx_currency, user_base)

            transaction.amount = base_amount.quantize(Decimal("0.00000001"))
            transaction.amount_original = new_original
            transaction.exchange_rate = new_rate.quantize(Decimal("0.00000001"))
            changed_fields.append("/amount")

            # Update linked account balance if exists
            linked_account_id = (
                transaction.source_account_id if transaction.type == "EXPENSE" else transaction.target_account_id
            )
            if linked_account_id:
                account_query = select(FinancialAccount).where(FinancialAccount.id == linked_account_id)
                account_result = await self.db.execute(account_query)
                account = account_result.scalar_one_or_none()
                if account:
                    # Rollback old amount, apply new amount
                    diff = base_amount - old_amount
                    if transaction.type == "EXPENSE":
                        account.current_balance -= diff
                    else:
                        account.current_balance += diff
                    account.updated_at = utc_now()

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

        return {
            "success": True,
            "transaction_id": str(transaction.id),
            "amount": round(display_amount, 2),
            "amount_original": float(transaction.amount_original) if transaction.amount_original else display_amount,
            "amount_base": float(transaction.amount),
            "currency": original_currency,
            "baseCurrency": display_currency,
            "type": transaction.type,
            "category_key": transaction.category_key,
            "raw_input": transaction.raw_input,
            "tags": transaction.tags or [],
            "transaction_at": transaction.transaction_at.isoformat() if transaction.transaction_at else None,
            "updated_at": transaction.updated_at.isoformat() if transaction.updated_at else None,
            # KEY: This flag tells frontend to use DataModelUpdate instead of creating new surface
            "_intent": "update",
            "_changed_fields": changed_fields,
            "message": "已更新交易记录",
        }

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
        query = select(Transaction).where(Transaction.id == transaction_id)
        result = await self.db.execute(query)
        transaction = result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("Transaction")

        # Verify ownership
        if transaction.user_uuid != user_uuid:
            raise BusinessError("Permission denied to delete this transaction", "PERMISSION_DENIED")

        # Delete transaction record (associated comments and shares will be automatically deleted through ORM cascade)
        await self.db.delete(transaction)
        await self.db.commit()

        logger.info(
            "transaction_deleted",
            transaction_id=str(transaction_id),
            user_uuid=str(user_uuid),
        )

        return True

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
        created_transactions = []

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

        for item in transactions_data:
            amount_original = Decimal(str(item["amount"]))
            # Use user's primaryCurrency as default value, instead of hardcoding CNY
            currency = (item.get("currency") or user_default_currency).upper()

            # Convert to user's base currency with rate snapshot
            base_amount, exchange_rate_val = await convert_to_user_base(
                abs(amount_original), currency, user_default_currency
            )
            amount = base_amount

            tx = Transaction(
                id=uuid4(),
                user_uuid=user_uuid,
                type=item.get("transaction_type", "EXPENSE").upper(),
                amount=amount.quantize(Decimal("0.00000001")),
                amount_original=abs(amount_original),
                currency=currency,
                exchange_rate=exchange_rate_val.quantize(Decimal("0.00000001")),
                category_key=item.get("category_key", "OTHERS"),
                tags=item.get("tags", []),
                raw_input=item.get("raw_input"),
                source_account_id=UUID(str(source_account_id)) if source_account_id else None,
                transaction_at=now,
                transaction_timezone=tx_timezone,
                source="AI",
                status="CLEARED",
                source_thread_id=source_thread_id,
            )
            self.db.add(tx)
            created_transactions.append(tx)

        await self.db.commit()

        # Refresh all records to get IDs
        for tx in created_transactions:
            await self.db.refresh(tx)

        return {
            "success": True,
            "count": len(created_transactions),
            "account_id": str(source_account_id) if source_account_id else None,
            "transactions": [
                {
                    "id": str(tx.id),
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
        """Update transaction account

        Support cross-currency account association:
        - If the transaction currency is different from the account currency, use real-time exchange rate to convert
        - Account balance is deducted/increased in the account's local currency"

        Args:
            transaction_id: Transaction ID
            user_uuid: User UUID
            account_id: New account ID, pass None to cancel association

        Returns:
            Updated transaction details

        Raises:
            NotFoundError: Transaction or account not found
            BusinessError: Permission denied
        """
        from app.services.exchange_rate_service import ExchangeRateService

        query = select(Transaction).where(Transaction.id == transaction_id)
        result = await self.db.execute(query)
        transaction = result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("Transaction")

        # Verify ownership
        if transaction.user_uuid != user_uuid:
            raise BusinessError("Permission denied to modify this transaction", "PERMISSION_DENIED")

        # Get transaction type
        is_expense = transaction.type == "EXPENSE"
        is_income = transaction.type == "INCOME"

        # Determine which account field to use based on transaction type
        # Expense → source_account_id (payment account)
        # Income → target_account_id (receipt account)
        if is_expense:
            old_account_id = transaction.source_account_id
        elif is_income:
            old_account_id = transaction.target_account_id
        else:
            # Transfer type does not support single account association
            old_account_id = transaction.source_account_id

        new_account_id = account_id

        # If the account has not changed, return directly
        if old_account_id == new_account_id:
            return await self.get_transaction_detail(transaction_id, user_uuid)

        # Get transaction original amount and currency (for cross-currency conversion)
        # Prioritize using original amount/currency, fallback to amount/currency
        tx_original_amount = transaction.amount_original or transaction.amount
        tx_currency = (transaction.currency or BASE_CURRENCY).upper()

        # Initialize exchange rate service
        exchange_rate_svc = ExchangeRateService()

        # Rollback old account balance
        if old_account_id:
            old_account_query = select(FinancialAccount).where(
                and_(
                    FinancialAccount.id == old_account_id,
                    FinancialAccount.user_uuid == user_uuid,
                )
            )
            old_account_result = await self.db.execute(old_account_query)
            old_account = old_account_result.scalar_one_or_none()

            if old_account:
                old_account_currency = (old_account.currency_code or BASE_CURRENCY).upper()

                # Calculate amount in old account currency
                if tx_currency == old_account_currency:
                    rollback_amount = abs(Decimal(str(tx_original_amount)))
                else:
                    # Need exchange rate conversion
                    converted = await exchange_rate_svc.convert(
                        amount=float(abs(Decimal(str(tx_original_amount)))),
                        from_currency=tx_currency,
                        to_currency=old_account_currency,
                    )
                    if converted is None:
                        logger.warning(
                            "exchange_rate_conversion_failed_rollback",
                            tx_currency=tx_currency,
                            account_currency=old_account_currency,
                        )
                        # Exchange rate conversion failed, use original amount as approximate value
                        rollback_amount = abs(Decimal(str(tx_original_amount)))
                    else:
                        rollback_amount = Decimal(str(converted))

                # Rollback: add back for expense, subtract for income
                if is_expense:
                    old_account.current_balance += rollback_amount
                elif is_income:
                    old_account.current_balance -= rollback_amount
                old_account.updated_at = utc_now()

                logger.info(
                    "account_balance_rollback",
                    account_id=str(old_account_id),
                    tx_currency=tx_currency,
                    account_currency=old_account_currency,
                    rollback_amount=str(rollback_amount),
                )

        # 2. Update new account balance
        if new_account_id:
            new_account_query = select(FinancialAccount).where(
                and_(
                    FinancialAccount.id == new_account_id,
                    FinancialAccount.user_uuid == user_uuid,
                )
            )
            new_account_result = await self.db.execute(new_account_query)
            new_account = new_account_result.scalar_one_or_none()

            if not new_account:
                raise NotFoundError("Account")

            new_account_currency = (new_account.currency_code or BASE_CURRENCY).upper()

            # Calculate amount in new account currency
            if tx_currency == new_account_currency:
                deduct_amount = abs(Decimal(str(tx_original_amount)))
            else:
                # Need exchange rate conversion: convert from transaction currency to account currency
                converted = await exchange_rate_svc.convert(
                    amount=float(abs(Decimal(str(tx_original_amount)))),
                    from_currency=tx_currency,
                    to_currency=new_account_currency,
                )
                if converted is None:
                    raise BusinessError(
                        f"Unable to get exchange rate from {tx_currency} to {new_account_currency}, please try again later",
                        "EXCHANGE_RATE_UNAVAILABLE",
                    )
                deduct_amount = Decimal(str(converted))

            # Update balance: deduct for expense, add for income
            if is_expense:
                new_account.current_balance -= deduct_amount
            elif is_income:
                new_account.current_balance += deduct_amount
            new_account.updated_at = utc_now()

            logger.info(
                "account_balance_updated",
                account_id=str(new_account_id),
                tx_currency=tx_currency,
                account_currency=new_account_currency,
                original_amount=str(tx_original_amount),
                deduct_amount=str(deduct_amount),
            )

        # 3. Update transaction account association (set correct field based on type)
        if is_expense:
            transaction.source_account_id = new_account_id
        elif is_income:
            transaction.target_account_id = new_account_id
        else:
            # Transfer default sets source_account_id
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

    # ===== Comment Operations =====

    async def _can_access_transaction_comments(self, transaction_id: UUID, user_uuid: UUID) -> Transaction:
        """Check if user can access transaction comments.

        Access is granted if:
        1. User is the transaction owner, OR
        2. Transaction is linked to a space the user is a member of.

        Returns the transaction if access is granted, raises NotFoundError otherwise.
        """
        from app.models.shared_space import SpaceMember, SpaceTransaction

        # Check ownership first (fast path)
        tx_query = select(Transaction).where(Transaction.id == transaction_id)
        tx_result = await self.db.execute(tx_query)
        transaction = tx_result.scalar_one_or_none()

        if not transaction:
            raise NotFoundError("Transaction")

        if transaction.user_uuid == user_uuid:
            return transaction

        # Check space membership: is the transaction linked to any space the user belongs to?
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
        if space_result.scalar_one_or_none() is not None:
            return transaction

        raise NotFoundError("Transaction")

    async def get_comments_for_transaction(self, transaction_id: UUID, user_uuid: UUID) -> list[dict[str, Any]]:
        """Get transaction comments list

        Args:
            transaction_id: Transaction ID
            user_uuid: Current user ID

        Returns:
            List of comments
        """
        # Verify access permission (owner or space member)
        await self._can_access_transaction_comments(transaction_id, user_uuid)

        # Query comments and related user information
        query = (
            select(
                TransactionComment,
                User.username.label("user_name"),
                User.avatar_url.label("user_avatar_url"),
            )
            .join(User, TransactionComment.user_uuid == User.uuid)
            .where(TransactionComment.transaction_id == transaction_id)
            .order_by(TransactionComment.created_at.asc())
        )

        result = await self.db.execute(query)
        comments_data = result.all()

        if not comments_data:
            return []

        # Batch-load parent comments in one query to avoid N+1.
        parent_ids = {c.parent_comment_id for c, _, _ in comments_data if c.parent_comment_id}
        parent_by_id: dict[Any, tuple[Any, str | None]] = {}
        if parent_ids:
            parent_query = (
                select(TransactionComment, User.username)
                .join(User, TransactionComment.user_uuid == User.uuid)
                .where(TransactionComment.id.in_(parent_ids))
            )
            parent_result = await self.db.execute(parent_query)
            for pc, pn in parent_result.all():
                parent_by_id[pc.id] = (pc, pn)

        # Format comment data
        formatted_comments = []
        for comment, user_name, user_avatar_url in comments_data:
            # If there is a parent comment, get the information of the user being replied to
            replied_to_user_uuid = None
            replied_to_user_name = None

            if comment.parent_comment_id and comment.parent_comment_id in parent_by_id:
                parent_comment, parent_user_name = parent_by_id[comment.parent_comment_id]
                replied_to_user_uuid = str(parent_comment.user_uuid)
                replied_to_user_name = parent_user_name

            formatted_comments.append(
                {
                    "id": str(comment.id),
                    "transactionId": str(comment.transaction_id),
                    "userId": str(comment.user_uuid),
                    "userName": user_name or "default_name",
                    "userAvatarUrl": user_avatar_url or default_avatar_url(comment.user_uuid),
                    "parentCommentId": str(comment.parent_comment_id) if comment.parent_comment_id else None,
                    "commentText": comment.comment_text,
                    "repliedToUserId": replied_to_user_uuid,
                    "repliedToUserName": replied_to_user_name,
                    "createdAt": comment.created_at.isoformat(),
                    "updatedAt": comment.updated_at.isoformat() if comment.updated_at else None,
                }
            )

        return formatted_comments

    async def add_comment(
        self,
        transaction_id: UUID,
        user_uuid: UUID,
        comment_text: str,
        parent_comment_id: int | None = None,
        mentioned_user_ids: list[str] | None = None,
        commenter_username: str = "Unknown",
    ) -> dict[str, Any]:
        """Add transaction comment

        Args:
            transaction_id: Transaction ID
            user_uuid: User ID
            comment_text: Comment content
            parent_comment_id: Optional parent comment ID
            mentioned_user_ids: Optional list of mentioned user UUIDs
            commenter_username: Username of the commenter for notification

        Returns:
            New comment dictionary
        """
        # Validate comment content
        if not comment_text or not comment_text.strip():
            logger.warning(
                "empty_comment_rejected",
                user_uuid=user_uuid,
                transaction_id=transaction_id,
            )
            raise BusinessError("Comment content cannot be empty", "TRANSACTION_COMMENT_NULL")

        # Validate transaction exists and user has access
        await self._can_access_transaction_comments(transaction_id, user_uuid)

        # If there is a parent comment, validate the parent comment
        if parent_comment_id is not None:
            parent_comment_query = select(TransactionComment).where(
                and_(
                    TransactionComment.id == parent_comment_id,
                    TransactionComment.transaction_id == transaction_id,
                )
            )
            parent_comment_result = await self.db.execute(parent_comment_query)
            parent_comment = parent_comment_result.scalar_one_or_none()

            if not parent_comment:
                raise BusinessError("Parent comment does not exist", "INVALID_PARENT_COMMENT_ID")

            # Ensure the parent comment is not a child comment (single-level reply structure)
            if parent_comment.parent_comment_id is not None:
                raise BusinessError("Cannot reply to a child comment", "INVALID_PARENT_COMMENT_ID")

        # Create new comment
        new_comment = TransactionComment(
            transaction_id=transaction_id,
            user_uuid=user_uuid,
            comment_text=comment_text,
            parent_comment_id=parent_comment_id,
        )

        self.db.add(new_comment)
        await self.db.commit()
        await self.db.refresh(new_comment)

        logger.info(
            "comment_created",
            user_uuid=user_uuid,
            transaction_id=transaction_id,
            comment_id=new_comment.id,
            is_reply=bool(parent_comment_id),
        )

        # Collect users to notify: mentioned + parent comment author (on reply)
        users_to_notify: set[str] = set(mentioned_user_ids or [])
        if parent_comment_id is not None:
            # Notify the parent comment's author that someone replied
            parent_author_query = select(TransactionComment.user_uuid).where(
                TransactionComment.id == parent_comment_id
            )
            parent_author_result = await self.db.execute(parent_author_query)
            parent_author_uuid = parent_author_result.scalar_one_or_none()
            if parent_author_uuid:
                users_to_notify.add(str(parent_author_uuid))

        # Don't notify the commenter themselves
        users_to_notify.discard(str(user_uuid))

        assert new_comment.id is not None
        comment_id_int = int(new_comment.id)

        if users_to_notify:
            await self._notify_mentioned_users(
                mentioned_user_ids=list(users_to_notify),
                transaction_id=transaction_id,
                comment_id=comment_id_int,
                commenter_username=commenter_username,
                comment_text=comment_text,
                parent_author_uuid=str(parent_author_uuid)
                if parent_comment_id is not None and parent_author_uuid
                else None,
            )

        # Broadcast real-time comment created event
        await self._broadcast_comment_event(
            transaction_id=transaction_id,
            comment_id=comment_id_int,
            action="created",
        )

        # Get complete comment information (including user information)
        query = (
            select(
                TransactionComment,
                User.username.label("user_name"),
                User.avatar_url.label("user_avatar_url"),
            )
            .join(User, TransactionComment.user_uuid == User.uuid)
            .where(TransactionComment.id == new_comment.id)
        )

        result = await self.db.execute(query)
        comment_data = result.first()

        if not comment_data:
            raise BusinessError("Failed to retrieve new comment data", "STORE_COMMENT_FAILED")

        comment, user_name, user_avatar_url = comment_data

        # If there is a parent comment, get the information of the user being replied to
        replied_to_user_uuid = None
        replied_to_user_name = None

        if parent_comment_id:
            reply_context_query: Select[Any] = (
                select(TransactionComment, User.username)
                .join(User, TransactionComment.user_uuid == User.uuid)
                .where(TransactionComment.id == parent_comment_id)
            )
            reply_context_result = await self.db.execute(reply_context_query)
            reply_context_data = reply_context_result.first()

            if reply_context_data:
                parent_comment_obj, parent_user_name = reply_context_data
                replied_to_user_uuid = str(parent_comment_obj.user_uuid)
                replied_to_user_name = parent_user_name

        return {
            "id": str(comment.id),
            "transactionId": str(comment.transaction_id),
            "userId": str(comment.user_uuid),
            "userName": user_name or "Anonymous",
            "userAvatarUrl": user_avatar_url or default_avatar_url(comment.user_uuid),
            "parentCommentId": str(comment.parent_comment_id) if comment.parent_comment_id else None,
            "commentText": comment.comment_text,
            "repliedToUserId": replied_to_user_uuid,
            "repliedToUserName": replied_to_user_name,
            "createdAt": comment.created_at.isoformat(),
            "updatedAt": comment.updated_at.isoformat() if comment.updated_at else None,
        }

    async def _notify_mentioned_users(
        self,
        mentioned_user_ids: list[str],
        transaction_id: UUID,
        comment_id: int,
        commenter_username: str,
        comment_text: str,
        parent_author_uuid: str | None = None,
    ) -> None:
        """Create notifications for mentioned users and push via WebSocket."""
        from app.core.ws_manager import ws_manager
        from app.models.notification import Notification

        target_path = f"/home/transaction/{transaction_id}?commentId={comment_id}"

        for mentioned_id in mentioned_user_ids:
            try:
                mentioned_uuid = UUID(mentioned_id)
            except ValueError:
                continue

            is_parent_author_reply = parent_author_uuid is not None and str(mentioned_uuid) == parent_author_uuid
            title = (
                f"{commenter_username} 回复了你的评论" if is_parent_author_reply else f"{commenter_username} 提及了你"
            )

            notification_data = {
                "transactionId": str(transaction_id),
                "transaction_id": str(transaction_id),
                "commentId": str(comment_id),
                "comment_id": str(comment_id),
                "target_path": target_path,
                "commenter": commenter_username,
            }

            # Create notification record
            notification = Notification(
                user_uuid=mentioned_uuid,
                type="bill_comment",
                title=title,
                content=comment_text[:100],
                data=notification_data,
            )
            self.db.add(notification)

        await self.db.commit()

        # Push via WebSocket (best effort, don't fail the comment)
        for mentioned_id in mentioned_user_ids:
            try:
                is_parent_author_reply = parent_author_uuid is not None and mentioned_id == parent_author_uuid
                title = (
                    f"{commenter_username} 回复了你的评论"
                    if is_parent_author_reply
                    else f"{commenter_username} 提及了你"
                )

                await ws_manager.send_notification(
                    mentioned_id,
                    {
                        "type": "bill_comment",
                        "title": title,
                        "message": comment_text[:100],
                        "data": {
                            "transactionId": str(transaction_id),
                            "commentId": str(comment_id),
                            "target_path": target_path,
                        },
                    },
                )
            except Exception:  # noqa: BLE001
                pass

    async def delete_comment(self, comment_id: int, user_uuid: UUID) -> bool:
        """Delete comment

        Args:
            comment_id: Comment ID
            user_uuid: User UUID

        Returns:
            Whether the comment was deleted successfully
        """
        # Query comment
        query = select(TransactionComment).where(TransactionComment.id == comment_id)
        result = await self.db.execute(query)
        comment = result.scalar_one_or_none()

        if not comment:
            return False

        # Verify permissions
        if comment.user_uuid != user_uuid:
            raise BusinessError("You do not have permission to delete this comment", "PERMISSION_DENIED")

        target_tx_id = comment.transaction_id

        # Delete comment (if foreign key cascade delete, child comments will be automatically deleted)
        await self.db.delete(comment)
        await self.db.commit()

        # Broadcast real-time comment deleted event
        await self._broadcast_comment_event(
            transaction_id=target_tx_id,
            comment_id=comment_id,
            action="deleted",
        )

        return True

    async def _broadcast_comment_event(
        self,
        transaction_id: UUID,
        comment_id: int,
        action: str,
    ) -> None:
        """Broadcast real-time comment created/deleted event to all space members / transaction participants."""
        from app.core.ws_manager import ws_manager
        from app.models.shared_space import SpaceMember, SpaceTransaction
        from app.models.transaction import Transaction

        user_uuids: set[str] = set()

        # 1. Add transaction owner
        tx_query = select(Transaction.user_uuid).where(Transaction.id == transaction_id)
        tx_res = await self.db.execute(tx_query)
        tx_user_uuid = tx_res.scalar_one_or_none()
        if tx_user_uuid:
            user_uuids.add(str(tx_user_uuid))

        # 2. Add all space members for spaces linked to this transaction
        space_members_query = (
            select(SpaceMember.user_uuid)
            .join(SpaceTransaction, SpaceMember.space_id == SpaceTransaction.space_id)
            .where(SpaceTransaction.transaction_id == transaction_id)
        )
        sm_res = await self.db.execute(space_members_query)
        for uid in sm_res.scalars():
            if uid:
                user_uuids.add(str(uid))

        if user_uuids:
            event_payload = {
                "type": "comment_updated",
                "data": {
                    "action": action,
                    "transactionId": str(transaction_id),
                    "transaction_id": str(transaction_id),
                    "commentId": str(comment_id),
                    "comment_id": str(comment_id),
                },
            }
            await ws_manager.broadcast(list(user_uuids), event_payload)
