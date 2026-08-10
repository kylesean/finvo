"""Transaction ledger service: applies and reverses balance effects on linked accounts.

Extracted from :class:`TransactionCRUDService` so the money-moving math lives in
one cohesive unit. Every balance mutation in the transaction domain (create,
update, delete, confirm, account re-association) goes through the methods here,
so apply and rollback are always symmetric: same snapshot conversion, same row
locking, same EXPENSE/INCOME/TRANSFER convention.
"""

from __future__ import annotations

from decimal import Decimal
from uuid import UUID

import structlog
from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError, TransactionErrorCode
from app.models.base import utc_now
from app.models.financial_account import FinancialAccount
from app.models.transaction import Transaction
from app.utils.currency_utils import get_user_base_currency

logger = structlog.get_logger(__name__)


class TransactionLedgerService:
    """Apply/reverse a transaction's balance effect on linked accounts.

    Instances are request-scoped and share the caller's session; they never
    commit — transaction boundaries stay with the caller (Unit of Work).
    """

    def __init__(self, db: AsyncSession):
        self.db = db

    async def _get_account(self, account_id: UUID, user_uuid: UUID, *, for_update: bool) -> FinancialAccount | None:
        """Fetch an owned account, optionally with a row lock for balance writes."""
        query = select(FinancialAccount).where(
            and_(FinancialAccount.uuid == account_id, FinancialAccount.user_uuid == user_uuid),
        )
        if for_update:
            # populate_existing: re-select MUST refresh the row even when it is
            # already in the session's identity map, so the locked read is never
            # a stale pre-lock snapshot (lost update protection).
            query = query.with_for_update().execution_options(populate_existing=True)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def convert_snapshot_amount(
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
                TransactionErrorCode.EXCHANGE_RATE_UNAVAILABLE,
            )
        return abs(converted)

    async def apply_account_balance_effect(
        self,
        transaction: Transaction,
        account_id: UUID | None,
        *,
        user_uuid: UUID,
        user_base_currency: str,
        sign: int,
        direction: int = -1,
        for_update: bool = False,
    ) -> None:
        """Apply (sign=1) or rollback (sign=-1) a balance delta on a single account.

        ``direction`` controls whether the transaction increases (+1, e.g. INCOME,
        target account in TRANSFER) or decreases (-1, e.g. EXPENSE, source account
        in TRANSFER) the balance.
        """
        if account_id is None:
            return
        account = await self._get_account(account_id, user_uuid, for_update=for_update)
        if not account:
            return

        acc_currency = account.currency_code or user_base_currency
        effect = await self.convert_snapshot_amount(
            amount_original=transaction.amount_original,
            amount_base=transaction.amount,
            tx_currency=transaction.currency,
            target_currency=acc_currency,
            user_base_currency=user_base_currency,
        )
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

    async def apply_transaction_balance_effect(
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
        currency (see ``convert_snapshot_amount``) so apply and rollback are
        symmetric and never silently mislabel a currency. Accounts that no
        longer exist are skipped.
        """
        user_base_currency = await get_user_base_currency(self.db, user_uuid)
        tx_type = transaction.type

        if tx_type == "EXPENSE":
            await self.apply_account_balance_effect(
                transaction,
                account_id=source_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                direction=-1,
                for_update=for_update,
            )
        elif tx_type == "INCOME":
            await self.apply_account_balance_effect(
                transaction,
                account_id=target_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                direction=1,
                for_update=for_update,
            )
        elif tx_type == "TRANSFER":
            # Source account is debited (-1)
            await self.apply_account_balance_effect(
                transaction,
                account_id=source_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                direction=-1,
                for_update=for_update,
            )
            # Target account is credited (+1)
            await self.apply_account_balance_effect(
                transaction,
                account_id=target_account_id,
                user_uuid=user_uuid,
                user_base_currency=user_base_currency,
                sign=sign,
                direction=1,
                for_update=for_update,
            )

    async def apply_balance_diff(
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
            account = await self._get_account(account_id, user_uuid, for_update=True)
            if not account:
                return
            acc_currency = account.currency_code or user_base_currency
            old_effect = await self.convert_snapshot_amount(
                amount_original=old_amount_original,
                amount_base=old_amount_base,
                tx_currency=old_currency,
                target_currency=acc_currency,
                user_base_currency=user_base_currency,
            )
            new_effect = await self.convert_snapshot_amount(
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
