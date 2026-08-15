"""User service for managing user information, settings, and financial accounts."""

from __future__ import annotations

from datetime import UTC, datetime
from decimal import Decimal
from typing import Any, cast as type_cast
from uuid import UUID

from sqlmodel import select, update
from sqlmodel.ext.asyncio.session import AsyncSession

from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.core.exceptions import AccountErrorCode, BusinessError, NotFoundError, ValidationError
from app.core.logging import logger
from app.models.base import utc_now
from app.models.financial_account import FinancialAccount
from app.models.financial_settings import BurnRateMode, FinancialSettings
from app.models.transaction import RecurringTransaction, Transaction
from app.models.user import User
from app.models.user_settings import UserSettings
from app.services.account_balance import count_account_references, recompute_account_balance
from app.utils.currency_utils import (
    convert_to_display_currency,
    convert_to_user_base,
    get_user_display_currency,
)


def _close_system_message(locale: str | None, kind: str) -> str:
    """Localized raw_input for system-generated close entries.

    The client sends its UI language in ``Accept-Language`` (always with the
    user's own language first, e.g. ``zh-CN,zh;q=0.9,en;q=0.8``); we take the
    first tag and store a snapshot message in that language so the entry reads
    naturally in the user's own language forever after (like any user-typed
    memo, it is a snapshot at creation time).
    """
    tag = (locale or "").split(",")[0].split(";")[0].strip().lower()
    if tag.startswith("zh-hant") or tag.startswith("zh-tw"):
        return "停用時餘額轉出" if kind == "transfer" else "停用時餘額核銷"
    if tag.startswith("zh"):
        return "停用时余额转出" if kind == "transfer" else "停用时余额核销"
    if tag.startswith("ja"):
        return "口座停止時の残高振替" if kind == "transfer" else "口座停止時の残高処理"
    if tag.startswith("ko"):
        return "계좌 정지 시 잔액 이체" if kind == "transfer" else "계좌 정지 시 잔액 정리"
    return "Balance transferred out on account close" if kind == "transfer" else "Balance written off on account close"


def _exec_rowcount(result: Any) -> int:
    """Row count of an UPDATE/DELETE result (mypy-safe rowcount access)."""
    return int(getattr(result, "rowcount", 0) or 0)


def _format_decimal(value: Decimal, precision: int = 8) -> str:
    """Format a Decimal to a fixed-point string, avoiding scientific notation.

    Args:
        value: The Decimal value to format
        precision: Number of decimal places (default: 8 for DB precision)

    Returns:
        str: Formatted decimal string (e.g., "0.00000000" instead of "0E-8")
    """
    # Use quantize to ensure fixed-point representation
    format_str = Decimal(f"1.{'0' * precision}")
    return str(value.quantize(format_str))


def _format_iso_datetime(dt: datetime | None) -> str | None:
    """Format a datetime to ISO 8601 UTC string with Z suffix.

    Normalizes any timezone offset to UTC first so a non-UTC aware datetime
    (e.g. ``+08:00``) is never silently relabeled as UTC.

    Args:
        dt: The datetime to format (may be None or timezone-aware)

    Returns:
        str: ISO 8601 formatted string ending with Z, or None if input is None
    """
    if dt is None:
        return None
    if dt.tzinfo is not None:
        dt = dt.astimezone(UTC)
    return dt.isoformat().replace("+00:00", "Z")


class UserService:
    """Service for managing user-related operations.

    Handles user information retrieval, settings management,
    financial account CRUD operations, and onboarding status checks.
    """

    def __init__(self, db: AsyncSession):
        """Initialize the user service.

        Args:
            db: Database session for executing queries
        """
        self.db = db

    async def get_user_by_uuid(self, user_uuid: UUID) -> User:
        """Get user information by UUID.

        Args:
            user_uuid: The user's UUID

        Returns:
            User: The user object

        Raises:
            NotFoundError: If user is not found
        """
        result = await self.db.execute(select(User).where(User.uuid == user_uuid))
        user = result.scalar_one_or_none()

        if not user:
            raise NotFoundError("User")

        return type_cast(User, user)

    async def update_user_profile(
        self, user_uuid: UUID, username: str | None = None, avatar_url: str | None = None
    ) -> dict[str, Any]:
        """Update user profile (username and/or avatar).

        Args:
            user_uuid: The user's UUID
            username: Optional new username
            avatar_url: Optional new avatar URL

        Returns:
            Dict containing updated user info

        Raises:
            NotFoundError: If user is not found
        """
        result = await self.db.execute(select(User).where(User.uuid == user_uuid))
        user = result.scalar_one_or_none()

        if not user:
            raise NotFoundError("User")

        now = utc_now()

        if username is not None:
            user.username = username
        if avatar_url is not None:
            user.avatar_url = avatar_url

        user.updated_at = now

        await self.db.commit()
        await self.db.refresh(user)

        logger.info(
            "user_profile_updated",
            user_uuid=str(user_uuid),
            username=user.username,
            has_avatar=user.avatar_url is not None,
        )

        return {
            "id": str(user.uuid),
            "email": user.email,
            "mobile": user.mobile,
            "username": user.username,
            "avatarUrl": user.avatar_url,
            "createdAt": _format_iso_datetime(type_cast(datetime | None, user.created_at)),
            "updatedAt": _format_iso_datetime(type_cast(datetime | None, user.updated_at)),
            "clientLastLoginAt": _format_iso_datetime(type_cast(datetime | None, user.last_login_at)),
        }

    async def save_financial_accounts(self, user_uuid: UUID, accounts: list[dict[str, Any]]) -> dict[str, Any]:
        """Save or update user's financial accounts (UPSERT semantics).

        Existing accounts (matched by ``id``) are updated in place — names,
        attributes and balances are synced, but the account identity and any
        transaction links are preserved. Accounts absent from the payload are
        left untouched: removal is a dedicated, intentional delete / merge /
        close operation, never a side effect of "saving" the list.

        Balance semantics:
        - ``initialBalance`` + ``currentBalance`` are authoritative when supplied
          (the client round-trips the server values, so editing the name or
          attributes alone can never reset balances or orphan transactions).
        - Brand-new accounts default ``current_balance`` to ``initial_balance``
          when no explicit current balance is supplied.

        Args:
            user_uuid: The user's UUID
            accounts: List of financial account dictionaries (see
                ``schemas.user.FinancialAccountItem`` for the shape; ``id`` is
                present for existing accounts)

        Returns:
            Dict containing:
                - totalBalance: str (net worth in display currency)
                - lastUpdatedAt: str (ISO 8601 timestamp)
        """
        now = utc_now()

        result = await self.db.execute(select(FinancialAccount).where(FinancialAccount.user_uuid == user_uuid))
        existing = result.scalars().all()
        existing_by_id: dict[Any, FinancialAccount] = {acc.id: acc for acc in existing}

        for account_data in accounts:
            account_id = account_data.get("id")
            if account_id is not None and account_id in existing_by_id:
                acc = existing_by_id[account_id]
                self._apply_financial_account_fields(acc, account_data)
                acc.updated_at = now
            else:
                balance = Decimal(str(account_data.get("initialBalance") or "0"))
                current = Decimal(str(account_data.get("currentBalance") or balance))
                self.db.add(
                    FinancialAccount(
                        user_uuid=user_uuid,
                        name=account_data["name"],
                        nature=account_data.get("nature", "ASSET"),
                        type=account_data.get("type"),
                        currency_code=account_data.get("currencyCode", "CNY"),
                        initial_balance=balance,
                        current_balance=current,
                        include_in_net_worth=account_data.get("includeInNetWorth", True),
                        include_in_cash_flow=account_data.get("includeInCashFlow", False),
                        status=account_data.get("status", "ACTIVE"),
                        created_at=now,
                        updated_at=now,
                    )
                )

        await self.db.commit()

        # Net worth in display currency (ACTIVE accounts included in net worth)
        display_currency = await get_user_display_currency(self.db, user_uuid)
        result = await self.db.execute(
            select(FinancialAccount)
            .where(FinancialAccount.user_uuid == user_uuid)
            .where(FinancialAccount.status == "ACTIVE")
            .where(FinancialAccount.include_in_net_worth.is_(True))
        )
        active_accounts = result.scalars().all()

        total_display_balance = Decimal("0.00")
        for acc in active_accounts:
            val = acc.current_balance if acc.current_balance is not None else acc.initial_balance
            conv_val = await convert_to_display_currency(val, acc.currency_code or "CNY", display_currency)
            if acc.nature == "ASSET":
                total_display_balance += conv_val
            else:
                total_display_balance -= abs(conv_val)

        logger.info(
            "financial_accounts_saved",
            user_uuid=str(user_uuid),
            account_count=len(accounts),
            total_balance=str(total_display_balance),
        )

        return {"totalBalance": f"{total_display_balance:.2f}", "lastUpdatedAt": _format_iso_datetime(now)}

    async def get_user_financial_accounts(self, user_uuid: UUID) -> dict[str, Any]:
        """Get user's financial accounts.

        Args:
            user_uuid: The user's UUID

        Returns:
            Dict containing:
                - accounts: List of financial account dictionaries
                - totalBalance: str (net worth: assets - liabilities)
                - lastUpdatedAt: str (ISO 8601 timestamp of most recent update)
        """
        result = await self.db.execute(
            select(FinancialAccount)
            .where(FinancialAccount.user_uuid == user_uuid)
            .order_by(FinancialAccount.created_at)
        )
        accounts = result.scalars().all()

        # 1. Base aggregation logic
        total_balance = Decimal("0.00")
        max_updated_at = None

        # Accumulate raw account balances for total balance overview
        account_list = []
        for account in accounts:
            # 1. Calculate raw balance for output
            orig_balance = account.current_balance if account.current_balance is not None else account.initial_balance

            # 2. Net worth calculation using raw balance values
            if account.include_in_net_worth and account.status == "ACTIVE":
                if account.nature == "ASSET":
                    total_balance += orig_balance
                else:
                    total_balance -= abs(orig_balance)

            # Track most recent update
            if max_updated_at is None or account.updated_at > max_updated_at:
                max_updated_at = account.updated_at

            account_list.append(
                {
                    "id": str(account.id),
                    "name": account.name,
                    "nature": account.nature,
                    "type": account.type,
                    "currencyCode": account.currency_code or "CNY",
                    "initialBalance": f"{account.initial_balance:.2f}",
                    "currentBalance": f"{orig_balance:.2f}",
                    "includeInNetWorth": account.include_in_net_worth,
                    "includeInCashFlow": getattr(account, "include_in_cash_flow", False),
                    "status": account.status,
                    "createdAt": _format_iso_datetime(type_cast(datetime | None, account.created_at)),
                    "updatedAt": _format_iso_datetime(type_cast(datetime | None, account.updated_at)),
                }
            )

        # Use current time if no accounts exist
        if max_updated_at is None:
            max_updated_at = utc_now()

        return {
            "accounts": account_list,
            "totalBalance": f"{total_balance:.2f}",
            "lastUpdatedAt": _format_iso_datetime(max_updated_at),
        }

    async def create_financial_account(self, user_uuid: UUID, account_data: dict[str, Any]) -> dict[str, Any]:
        """Create a single financial account.

        Args:
            user_uuid: The user's UUID
            account_data: Financial account data

        Returns:
            Dict: The created account data
        """
        now = utc_now()
        balance = Decimal(str(account_data.get("initialBalance", "0")))
        # Explicit currentBalance is authoritative; otherwise a brand-new account
        # starts from its initial balance (never a silent "0").
        current = Decimal(str(account_data.get("currentBalance", balance)))

        financial_account = FinancialAccount(
            user_uuid=user_uuid,
            name=account_data["name"],
            nature=account_data.get("nature", "ASSET"),
            type=account_data.get("type"),
            currency_code=account_data.get("currencyCode", "CNY"),
            initial_balance=balance,
            current_balance=current,
            include_in_net_worth=account_data.get("includeInNetWorth", True),
            status=account_data.get("status", "ACTIVE"),
            created_at=now,
            updated_at=now,
        )
        self.db.add(financial_account)
        await self.db.commit()
        await self.db.refresh(financial_account)

        logger.info(
            "financial_account_created",
            user_uuid=str(user_uuid),
            account_id=financial_account.uuid,
            account_name=financial_account.name,
        )

        return {
            "id": str(financial_account.uuid),  # UUID as string
            "name": financial_account.name,
            "nature": financial_account.nature,
            "type": financial_account.type,
            "currencyCode": financial_account.currency_code,
            "initialBalance": _format_decimal(financial_account.initial_balance),
            "includeInNetWorth": financial_account.include_in_net_worth,
            "status": financial_account.status,
            "createdAt": _format_iso_datetime(financial_account.created_at),
            "updatedAt": _format_iso_datetime(financial_account.updated_at),
        }

    async def update_financial_account(
        self, user_uuid: UUID, account_id: UUID, account_data: dict[str, Any]
    ) -> dict[str, Any] | None:
        """Update a financial account.

        Args:
            user_uuid: The user's UUID
            account_id: The account ID
            account_data: Updated account data

        Returns:
            Dict: The updated account data, or None if not found
        """
        result = await self.db.execute(
            select(FinancialAccount).where(
                FinancialAccount.uuid == account_id,
                FinancialAccount.user_uuid == user_uuid,
            )
        )
        account = result.scalar_one_or_none()

        if not account:
            return None

        # CLOSED is a terminal lifecycle state managed by the dedicated close
        # endpoint (it also implies balance disposal decisions). Refuse to flip
        # it through the generic update path so the semantics stay unambiguous.
        if account_data.get("status") == "CLOSED":
            raise ValidationError(
                "Use the close-account operation to close an account",
                field_errors={"status": "POST /financial-accounts/{id}/close"},
            )

        # Update fields
        if "name" in account_data:
            account.name = account_data["name"]
        if "nature" in account_data:
            account.nature = account_data["nature"]
        if "type" in account_data:
            account.type = account_data["type"]
        if "currencyCode" in account_data:
            account.currency_code = account_data["currencyCode"]
        # Balance semantics (ledger-preserving):
        # - currentBalance supplied -> authoritative (client round-trip or an
        #   explicit balance correction).
        # - only initialBalance supplied -> shift current by the same delta so
        #   the accumulated transaction effect is preserved instead of wiped.
        if "initialBalance" in account_data:
            old_initial = Decimal(str(account.initial_balance or "0"))
            new_initial = Decimal(str(account_data["initialBalance"]))
            if "currentBalance" in account_data:
                account.current_balance = Decimal(str(account_data["currentBalance"]))
            else:
                delta = new_initial - old_initial
                account.current_balance = (account.current_balance or Decimal("0")) + delta
            account.initial_balance = new_initial
        elif "currentBalance" in account_data:
            account.current_balance = Decimal(str(account_data["currentBalance"]))
        if "includeInNetWorth" in account_data:
            account.include_in_net_worth = account_data["includeInNetWorth"]
        if "status" in account_data:
            account.status = account_data["status"]

        account.updated_at = utc_now()

        await self.db.commit()
        await self.db.refresh(account)

        logger.info("financial_account_updated", user_uuid=str(user_uuid), account_id=account.id)

        return {
            "id": str(account.id),  # UUID as string
            "name": account.name,
            "nature": account.nature,
            "type": account.type,
            "currencyCode": account.currency_code,
            "initialBalance": _format_decimal(account.initial_balance),
            "includeInNetWorth": account.include_in_net_worth,
            "status": account.status,
            "createdAt": _format_iso_datetime(type_cast(datetime | None, account.created_at)),
            "updatedAt": _format_iso_datetime(type_cast(datetime | None, account.updated_at)),
        }

    async def delete_financial_account(self, user_uuid: UUID, account_id: UUID) -> bool:
        """Delete a financial account (guarded).

        Physical deletion is only allowed for accounts with no ledger history:
        - No transactions / recurring rules may reference the account (a delete
          would silently orphan history via ``ondelete=SET NULL``).
        - The account balance must be zero (a non-zero balance has to go
          somewhere — merge it elsewhere or dispose of it on close).

        Referenced or non-empty accounts are rejected with a 409 Conflict that
        tells the caller to use the merge / close lifecycle instead.

        Args:
            user_uuid: The user's UUID
            account_id: The account ID

        Returns:
            bool: True if deleted, False if not found

        Raises:
            BusinessError: 409 when the account still has references or balance
        """
        result = await self.db.execute(
            select(FinancialAccount).where(
                FinancialAccount.uuid == account_id,
                FinancialAccount.user_uuid == user_uuid,
            )
        )
        account = result.scalar_one_or_none()
        if not account:
            return False

        refs = await count_account_references(self.db, account_id)
        if refs["transactions"] or refs["recurring"]:
            # A CLOSED account keeps its full history BY DESIGN — telling the
            # user "still referenced" is confusing when closing is exactly what
            # preserved it. Give the real guidance: merge to move data away.
            is_closed = (account.status or "ACTIVE").upper() == "CLOSED"
            if is_closed:
                raise BusinessError(
                    "This closed account keeps its full history. To remove it "
                    "entirely, merge it into another account first.",
                    error_code=AccountErrorCode.ACCOUNT_DELETE_CLOSED_HAS_HISTORY,
                    status_code=409,
                    details={
                        "transactions": refs["transactions"],
                        "recurring": refs["recurring"],
                        "suggested_actions": ["merge"],
                    },
                )
            raise BusinessError(
                f"This account is referenced by {refs['transactions']} transaction(s) and "
                f"{refs['recurring']} recurring rule(s) and cannot be deleted directly. "
                "Merge it into another account, or close it to keep the history.",
                error_code=AccountErrorCode.ACCOUNT_DELETE_REFERENCED,
                status_code=409,
                details={
                    "transactions": refs["transactions"],
                    "recurring": refs["recurring"],
                    "suggested_actions": ["merge", "close"],
                },
            )

        balance = Decimal(account.current_balance if account.current_balance is not None else account.initial_balance or 0)
        if balance != 0:
            raise BusinessError(
                f"This account still has a balance of {balance:g} and cannot be deleted directly. "
                "Merge it into another account, or dispose of the balance when closing it.",
                error_code=AccountErrorCode.ACCOUNT_DELETE_BALANCE_NOT_ZERO,
                status_code=409,
                details={
                    "balance": str(balance),
                    "suggested_actions": ["merge", "close"],
                },
            )

        await self.db.delete(account)
        await self.db.commit()

        logger.info("financial_account_deleted", user_uuid=str(user_uuid), account_id=account_id)
        return True

    async def merge_financial_accounts(
        self,
        user_uuid: UUID,
        source_id: UUID,
        target_id: UUID,
    ) -> dict[str, Any]:
        """Merge ``source_id`` into ``target_id`` (the "created the wrong /
        duplicate account" correction path).

        Semantics — no real money moves, so no TRANSFER is generated:
        1. Transaction / recurring rules referencing the source are re-pointed
           to the target (same transaction, same amounts, same history).
        2. The target's balance is recomputed from its (now extended) ledger.
        3. The source account is physically deleted.

        Both accounts must belong to the user, share the same nature
        (asset/liability) and currency; the target must not be closed.

        Args:
            user_uuid: The user's UUID
            source_id: Account to merge away (deleted)
            target_id: Account to merge into (survives)

        Returns:
            Dict matching ``MergeFinancialAccountsResponse``

        Raises:
            NotFoundError / BusinessError (409 for incompatible accounts)
        """
        if source_id == target_id:
            raise BusinessError(
                "Cannot merge an account into itself",
                error_code=AccountErrorCode.ACCOUNT_MERGE_SELF,
            )

        result = await self.db.execute(
            select(FinancialAccount).where(
                FinancialAccount.uuid.in_([source_id, target_id]),
                FinancialAccount.user_uuid == user_uuid,
            )
        )
        accounts = {acc.id: acc for acc in result.scalars().all()}
        source = accounts.get(source_id)
        target = accounts.get(target_id)
        if source is None or target is None:
            raise NotFoundError("Financial account")

        if (source.currency_code or "CNY").upper() != (target.currency_code or "CNY").upper():
            raise BusinessError(
                "Cannot merge accounts with different currencies",
                error_code=AccountErrorCode.ACCOUNT_MERGE_CURRENCY_MISMATCH,
                details={"source_currency": source.currency_code, "target_currency": target.currency_code},
            )
        if (source.nature or "ASSET").upper() != (target.nature or "ASSET").upper():
            raise BusinessError(
                "Cannot merge an asset into a liability (or vice versa)",
                error_code=AccountErrorCode.ACCOUNT_MERGE_NATURE_MISMATCH,
                details={"source_nature": source.nature, "target_nature": target.nature},
            )
        if (target.status or "ACTIVE").upper() == "CLOSED":
            raise BusinessError(
                "Cannot merge into a closed account; reopen it or pick another target",
                error_code=AccountErrorCode.ACCOUNT_MERGE_CLOSED_TARGET,
            )

        now = utc_now()

        # Re-point transaction references (source -> target), same history.
        moved_result = await self.db.execute(
            update(Transaction)
            .where(Transaction.user_uuid == user_uuid, Transaction.source_account_id == source_id)
            .values(source_account_id=target_id, updated_at=now)
        )
        moved_tx_source = _exec_rowcount(moved_result)
        moved_result = await self.db.execute(
            update(Transaction)
            .where(Transaction.user_uuid == user_uuid, Transaction.target_account_id == source_id)
            .values(target_account_id=target_id, updated_at=now)
        )
        moved_tx_target = _exec_rowcount(moved_result)

        # Re-point recurring rules referencing the source.
        moved_result = await self.db.execute(
            update(RecurringTransaction)
            .where(RecurringTransaction.user_uuid == user_uuid, RecurringTransaction.source_account_id == source_id)
            .values(source_account_id=target_id, updated_at=now)
        )
        moved_rec_source = _exec_rowcount(moved_result)
        moved_result = await self.db.execute(
            update(RecurringTransaction)
            .where(RecurringTransaction.user_uuid == user_uuid, RecurringTransaction.target_account_id == source_id)
            .values(target_account_id=target_id, updated_at=now)
        )
        moved_rec_target = _exec_rowcount(moved_result)

        # Balance: ledger-derived, so merged history is reflected exactly and
        # any pre-existing drift is corrected (same convention as reconcile).
        await recompute_account_balance(self.db, target)
        target.updated_at = now

        await self.db.delete(source)
        await self.db.commit()

        logger.info(
            "financial_account_merged",
            user_uuid=str(user_uuid),
            source_id=str(source_id),
            target_id=str(target_id),
            moved_transactions=moved_tx_source + moved_tx_target,
            moved_recurring=moved_rec_source + moved_rec_target,
        )

        return {
            "source_id": str(source_id),
            "target_id": str(target_id),
            "moved_transactions": moved_tx_source + moved_tx_target,
            "moved_recurring": moved_rec_source + moved_rec_target,
            "target_currency": target.currency_code or "CNY",
            "target_balance": f"{target.current_balance:.2f}",
        }

    async def close_financial_account(
        self,
        user_uuid: UUID,
        account_id: UUID,
        disposal: str = "keep",
        target_account_id: UUID | None = None,
        locale: str | None = None,
    ) -> dict[str, Any]:
        """Close (archive) an account while keeping its full transaction history.

        Closing freezes the account's balance snapshot and marks it ``CLOSED``
        so it no longer appears in new-transaction pickers or net worth, but
        historical reports stay intact.

        A non-zero balance must be disposed of first:
        - ``keep``     — freeze the balance as-is (user accepts the snapshot)
        - ``transfer`` — generate a real TRANSFER to ``target_account_id``
        - ``writeoff`` — generate an EXPENSE (assets) / INCOME (liabilities)
          write-off entry, zeroing the balance through the normal ledger

        Args:
            user_uuid: The user's UUID
            account_id: Account to close
            disposal: Balance disposal strategy
            target_account_id: Required when ``disposal == "transfer"``
            locale: Client ``Accept-Language`` (first tag) used to localize the
                generated transfer/write-off transaction message

        Returns:
            Dict matching ``CloseFinancialAccountResponse``

        Raises:
            NotFoundError / ValidationError / BusinessError
        """
        result = await self.db.execute(
            select(FinancialAccount).where(
                FinancialAccount.uuid == account_id,
                FinancialAccount.user_uuid == user_uuid,
            )
        )
        account = result.scalar_one_or_none()
        if not account:
            raise NotFoundError("Financial account")
        if (account.status or "ACTIVE").upper() == "CLOSED":
            raise BusinessError(
                "This account is already closed",
                error_code=AccountErrorCode.ACCOUNT_ALREADY_CLOSED,
                status_code=409,
            )

        # Recurring rules would keep generating future transactions on a closed
        # account. Closing is a "real account terminated" decision — the user
        # must first move/disable those rules (merge is the correction path and
        # re-points them automatically). Transaction history itself is NOT a
        # blocker: closing is exactly what preserves it.
        refs = await count_account_references(self.db, account_id)
        if refs["recurring"]:
            raise BusinessError(
                f"This account is referenced by {refs['recurring']} recurring rule(s). "
                "Disable them or merge those rules into another account before closing.",
                error_code=AccountErrorCode.ACCOUNT_CLOSE_RECURRING_ACTIVE,
                status_code=409,
                details={
                    "recurring": refs["recurring"],
                    "suggested_actions": ["merge", "close"],
                },
            )

        balance = Decimal(account.current_balance if account.current_balance is not None else account.initial_balance or 0)
        effective_disposal = disposal
        transaction_id: str | None = None

        if balance != 0 and disposal != "keep":
            if disposal == "transfer":
                if target_account_id is None or target_account_id == account_id:
                    raise BusinessError(
                        "Transfer disposal requires a different target account",
                        error_code=AccountErrorCode.ACCOUNT_CLOSE_TARGET_REQUIRED,
                    )
                result = await self.db.execute(
                    select(FinancialAccount).where(
                        FinancialAccount.uuid == target_account_id,
                        FinancialAccount.user_uuid == user_uuid,
                    )
                )
                target = result.scalar_one_or_none()
                if target is None:
                    raise BusinessError(
                        "Target financial account not found",
                        error_code=AccountErrorCode.ACCOUNT_NOT_FOUND,
                        status_code=404,
                    )
                if (target.status or "ACTIVE").upper() == "CLOSED":
                    raise BusinessError(
                        "Target account is closed",
                        error_code=AccountErrorCode.ACCOUNT_CLOSE_TARGET_CLOSED,
                        status_code=409,
                    )
                if (target.currency_code or "CNY").upper() != (account.currency_code or "CNY").upper():
                    raise BusinessError(
                        "Transfer target must use the same currency",
                        error_code=AccountErrorCode.ACCOUNT_CLOSE_TARGET_CURRENCY_MISMATCH,
                    )

                # Transfer direction depends on the SIGN of the balance:
                # - positive balance (assets): move the money OUT of the closing
                #   account (closing account = source, target = chosen account)
                # - negative balance (liabilities, i.e. owed money): move the
                #   DEBT over to the target (target = chosen account becomes the
                #   source of the transfer, closing account is the target), which
                #   pays the closing account's balance back up to zero.
                from app.services.transaction.crud_service import TransactionCRUDService

                crud = TransactionCRUDService(self.db)
                created = await crud.create_transaction(
                    user_uuid=user_uuid,
                    amount=abs(balance),
                    transaction_type="transfer",
                    source_account_id=(
                        account_id if balance > 0 else target_account_id
                    ),
                    target_account_id=(
                        target_account_id if balance > 0 else account_id
                    ),
                    category_key="OTHERS",
                    raw_input=_close_system_message(locale, "transfer"),
                )
                transaction_id = created["transaction_id"]
                # create_transaction hard-codes source="AI" and offers no source
                # parameter; balance disposal is a system operation, so pin the
                # column explicitly (committed together with CLOSED below).
                await self.db.execute(
                    update(Transaction)
                    .where(Transaction.uuid == created["transaction_id"])
                    .values(source="SYSTEM")
                )
            elif disposal == "writeoff":
                # Ledger invariant: EXPENSE deducts the SOURCE account, INCOME
                # credits the TARGET account. So:
                # - positive balance (assets): a plain expense out of the
                #   closing account — the money is treated as spent/lost.
                # - negative balance (liabilities): an income recorded TO the
                #   closing account (target) — the debt is treated as forgiven.
                # Either way the closing account's balance is zeroed through the
                # normal ledger and a traceable SYSTEM entry is left behind.
                if balance > 0:
                    tx_type = "expense"
                    source_acc_id = account_id
                    target_acc_id = None
                else:
                    tx_type = "income"
                    source_acc_id = None
                    target_acc_id = account_id

                from app.services.transaction.crud_service import TransactionCRUDService

                crud = TransactionCRUDService(self.db)
                created = await crud.create_transaction(
                    user_uuid=user_uuid,
                    amount=abs(balance),
                    transaction_type=tx_type,
                    source_account_id=source_acc_id,
                    target_account_id=target_acc_id,
                    category_key="OTHERS",
                    raw_input=_close_system_message(locale, "writeoff"),
                )
                transaction_id = created["transaction_id"]
                # Same source-column correction for the write-off entry.
                await self.db.execute(
                    update(Transaction)
                    .where(Transaction.uuid == created["transaction_id"])
                    .values(source="SYSTEM")
                )
            else:
                raise ValidationError(f"Unknown disposal strategy: {disposal}")

            # Recompute the closing account's snapshot from the ledger (the
            # disposal entry is in), so the frozen balance always equals the
            # derived balance regardless of create_transaction side effects.
            await recompute_account_balance(self.db, account)
        elif balance == 0 and disposal != "keep":
            effective_disposal = "keep"

        account.status = "CLOSED"
        account.updated_at = utc_now()
        await self.db.commit()

        final_balance = Decimal(
            account.current_balance if account.current_balance is not None else account.initial_balance or 0
        )

        logger.info(
            "financial_account_closed",
            user_uuid=str(user_uuid),
            account_id=str(account_id),
            disposal=effective_disposal,
            transaction_id=transaction_id,
            final_balance=str(final_balance),
        )

        return {
            "account_id": str(account_id),
            "status": account.status,
            "disposal": effective_disposal,
            "transaction_id": transaction_id,
            "final_balance": f"{final_balance:.2f}",
        }

    def _apply_financial_account_fields(self, account: FinancialAccount, data: dict[str, Any]) -> None:
        """Apply identity-preserving field updates to an existing account.

        Balance rules:
        - ``initialBalance`` + ``currentBalance`` both supplied -> authoritative.
        - Only ``initialBalance`` supplied -> shift current by the delta so the
          accumulated transaction effect is preserved.
        - Only ``currentBalance`` supplied -> authoritative correction.
        """
        if "name" in data:
            account.name = data["name"]
        if "nature" in data:
            account.nature = data["nature"]
        if "type" in data:
            account.type = data["type"]
        if "currencyCode" in data:
            account.currency_code = data["currencyCode"]
        if "includeInNetWorth" in data:
            account.include_in_net_worth = data["includeInNetWorth"]
        if "includeInCashFlow" in data:
            account.include_in_cash_flow = data["includeInCashFlow"]
        if "status" in data:
            account.status = data["status"]

        if "initialBalance" in data:
            old_initial = Decimal(str(account.initial_balance or "0"))
            new_initial = Decimal(str(data["initialBalance"]))
            if "currentBalance" in data:
                account.current_balance = Decimal(str(data["currentBalance"]))
            else:
                delta = new_initial - old_initial
                account.current_balance = (account.current_balance or Decimal("0")) + delta
            account.initial_balance = new_initial
        elif "currentBalance" in data:
            account.current_balance = Decimal(str(data["currentBalance"]))

    async def update_financial_safety_line(self, user_uuid: UUID, safety_balance_threshold: str) -> dict[str, Any]:
        """Update user's financial safety line threshold.

        Args:
            user_uuid: The user's UUID
            safety_balance_threshold: The new threshold value (decimal as string)

        Returns:
            Dict containing:
                - safetyBalanceThreshold: str (the updated threshold)
                - updatedAt: str (ISO 8601 timestamp)

        Raises:
            NotFoundError: If user is not found
        """
        # Get or create user settings
        result = await self.db.execute(select(UserSettings).where(UserSettings.user_uuid == user_uuid))
        settings = result.scalar_one_or_none()

        now = utc_now()

        if settings is None:
            # Create new settings
            settings = UserSettings(
                user_uuid=user_uuid, safety_balance_threshold=safety_balance_threshold, created_at=now, updated_at=now
            )
            self.db.add(settings)
        else:
            # Update existing settings
            settings.safety_balance_threshold = safety_balance_threshold
            settings.updated_at = now

        await self.db.commit()
        await self.db.refresh(settings)

        logger.info("financial_safety_line_updated", user_uuid=str(user_uuid), threshold=safety_balance_threshold)

        return {"safetyBalanceThreshold": settings.safety_balance_threshold, "updatedAt": _format_iso_datetime(now)}

    async def check_onboarding_status(self, user_uuid: UUID) -> dict[str, bool]:
        """Check if user has completed onboarding.

        Onboarding is considered complete when:
        1. User has at least one financial account
        2. User has at least one recurring income transaction
        3. User has at least one recurring expense transaction

        Args:
            user_uuid: The user's UUID

        Returns:
            Dict containing:
                - isCompleted: bool (True if all onboarding steps are complete)
        """
        # Check if user has at least one financial account
        account_result = await self.db.execute(
            select(FinancialAccount).where(FinancialAccount.user_uuid == user_uuid).limit(1)
        )
        has_financial_account = account_result.scalar_one_or_none() is not None

        # Check if user has at least one recurring income (amount > 0)
        income_result = await self.db.execute(
            select(RecurringTransaction)
            .where(RecurringTransaction.user_uuid == user_uuid)
            .where(RecurringTransaction.amount > 0)
            .limit(1)
        )
        has_recurring_income = income_result.scalar_one_or_none() is not None

        # Check if user has at least one recurring expense (amount < 0)
        expense_result = await self.db.execute(
            select(RecurringTransaction)
            .where(RecurringTransaction.user_uuid == user_uuid)
            .where(RecurringTransaction.amount < 0)
            .limit(1)
        )
        has_recurring_expense = expense_result.scalar_one_or_none() is not None

        is_completed = has_financial_account and has_recurring_income and has_recurring_expense

        logger.info(
            "onboarding_status_checked",
            user_uuid=str(user_uuid),
            is_completed=is_completed,
            has_financial_account=has_financial_account,
            has_recurring_income=has_recurring_income,
            has_recurring_expense=has_recurring_expense,
        )

        return {"isCompleted": is_completed}

    async def update_user_settings(
        self,
        user_uuid: UUID,
        safety_balance_threshold: str | None = None,
        estimated_avg_daily_spending: str | None = None,
    ) -> UserSettings:
        """Update user settings.

        Args:
            user_uuid: The user's UUID
            safety_balance_threshold: Optional new safety threshold
            estimated_avg_daily_spending: Optional new estimated daily spending

        Returns:
            UserSettings: The updated settings object

        Raises:
            NotFoundError: If user is not found
        """
        # Get or create user settings
        result = await self.db.execute(select(UserSettings).where(UserSettings.user_uuid == user_uuid))
        settings = result.scalar_one_or_none()

        now = utc_now()

        if settings is None:
            # Create new settings with provided values or defaults
            settings = UserSettings(
                user_uuid=user_uuid,
                safety_balance_threshold=safety_balance_threshold or "0.00",
                avg_daily_spending=estimated_avg_daily_spending or "0.00",
                created_at=now,
                updated_at=now,
            )
            self.db.add(settings)
        else:
            # Update existing settings
            if safety_balance_threshold is not None:
                settings.safety_balance_threshold = safety_balance_threshold
            if estimated_avg_daily_spending is not None:
                settings.avg_daily_spending = estimated_avg_daily_spending
            settings.updated_at = now

        await self.db.commit()
        await self.db.refresh(settings)

        logger.info(
            "user_settings_updated",
            user_uuid=str(user_uuid),
            safety_threshold=settings.safety_balance_threshold,
            avg_spending=settings.avg_daily_spending,
        )

        return settings

    # =========================================================================
    # Financial Settings Methods (NEW financial_settings table)
    # =========================================================================

    async def get_financial_settings(self, user_uuid: UUID) -> FinancialSettings:
        """Get or create user's financial settings.

        If settings don't exist, creates default settings.

        Args:
            user_uuid: The user's UUID

        Returns:
            FinancialSettings: The settings object
        """
        result = await self.db.execute(select(FinancialSettings).where(FinancialSettings.user_uuid == user_uuid))
        settings = result.scalar_one_or_none()

        if settings is None:
            # Create default settings
            settings = await self.create_default_financial_settings(user_uuid)

        return settings

    async def create_default_financial_settings(
        self,
        user_uuid: UUID,
        locale: str | None = None,
        timezone: str | None = None,
        *,
        commit: bool = True,
    ) -> FinancialSettings:
        """Create default financial settings for a user.

        Called during user registration or when settings don't exist.
        Currency is inferred from locale/timezone; falls back to USD.

        Args:
            user_uuid: The user's UUID
            locale: User's locale (e.g. "zh_CN") for currency inference
            timezone: User's IANA timezone (e.g. "Asia/Shanghai") for currency inference
            commit: When True (default), commit and refresh within this method.
                When False, only flush within the caller's transaction so the
                caller can roll back user + settings atomically if a later step
                fails. Used by :meth:`AuthService.register`.

        Returns:
            FinancialSettings: The created settings object
        """
        from app.utils.currency_inference import infer_currency

        inferred_currency = infer_currency(locale=locale, timezone=timezone)

        settings = FinancialSettings(
            user_uuid=user_uuid,
            safety_threshold=Decimal("1000.00"),
            daily_burn_rate=Decimal("100.00"),
            burn_rate_mode="AI_AUTO",
            primary_currency=inferred_currency,
            month_start_day=1,
            updated_at=utc_now(),
        )
        self.db.add(settings)
        if commit:
            await self.db.commit()
            await self.db.refresh(settings)
        else:
            # Send INSERT within the caller's transaction without committing,
            # so the caller can roll back atomically if a later step fails.
            await self.db.flush()
            await self.db.refresh(settings)

        logger.info(
            "financial_settings_created",
            user_uuid=str(user_uuid),
            primary_currency=inferred_currency,
            locale=locale,
            timezone=timezone,
        )

        return settings

    async def update_financial_settings(
        self,
        user_uuid: UUID,
        safety_threshold: str | None = None,
        daily_burn_rate: str | None = None,
        burn_rate_mode: BurnRateMode | str | None = None,
        primary_currency: str | None = None,
        month_start_day: int | None = None,
    ) -> FinancialSettings:
        """Update user's financial settings using UPSERT.

        If settings don't exist, creates them with provided values.
        When primary_currency changes, triggers a one-time recalculation of
        all transaction ``amount`` fields (derived values) to maintain
        aggregation correctness.

        Args:
            user_uuid: The user's UUID
            safety_threshold: Optional new safety threshold
            daily_burn_rate: Optional new daily burn rate
            burn_rate_mode: Optional new burn rate mode
            primary_currency: Optional new primary currency
            month_start_day: Optional new month start day

        Returns:
            FinancialSettings: The updated settings object
        """
        result = await self.db.execute(select(FinancialSettings).where(FinancialSettings.user_uuid == user_uuid))
        settings = result.scalar_one_or_none()

        now = utc_now()
        old_currency: str | None = None

        if settings is None:
            # Create new settings with provided values or defaults (UPSERT behavior)
            settings = FinancialSettings(
                user_uuid=user_uuid,
                safety_threshold=Decimal(safety_threshold) if safety_threshold else Decimal("1000.00"),
                daily_burn_rate=Decimal(daily_burn_rate) if daily_burn_rate else Decimal("100.00"),
                burn_rate_mode=BurnRateMode(burn_rate_mode) if burn_rate_mode else BurnRateMode.AI_AUTO,
                primary_currency=primary_currency or PROJECT_DEFAULT_CURRENCY,
                month_start_day=month_start_day or 1,
                updated_at=now,
            )
            self.db.add(settings)
        else:
            # Update existing settings
            old_currency = settings.primary_currency
            if safety_threshold is not None:
                settings.safety_threshold = Decimal(safety_threshold)
            if daily_burn_rate is not None:
                settings.daily_burn_rate = Decimal(daily_burn_rate)
            if burn_rate_mode is not None:
                settings.burn_rate_mode = BurnRateMode(burn_rate_mode)
            if primary_currency is not None:
                settings.primary_currency = primary_currency
            if month_start_day is not None:
                settings.month_start_day = month_start_day
            settings.updated_at = now

        await self.db.commit()
        await self.db.refresh(settings)

        # Trigger recalculation if base currency actually changed
        new_currency = settings.primary_currency
        if old_currency is not None and primary_currency is not None:
            if old_currency.upper() != new_currency.upper():
                await self._recalculate_transaction_amounts(user_uuid, new_currency)

        logger.info(
            "financial_settings_updated",
            user_uuid=str(user_uuid),
            safety_threshold=str(settings.safety_threshold),
            daily_burn_rate=str(settings.daily_burn_rate),
            primary_currency=new_currency,
        )

        return settings

    async def _recalculate_transaction_amounts(self, user_uuid: UUID, new_base_currency: str) -> None:
        """Recalculate all transaction ``amount`` fields after a base currency change.

        This re-derives ``amount`` from the immutable facts (``amount_original`` + ``currency``)
        using current exchange rates. The original data is never modified.

        Args:
            user_uuid: The user's UUID
            new_base_currency: The new base currency code
        """
        from app.models.transaction import Transaction

        # Fetch all transactions for this user
        result = await self.db.execute(select(Transaction).where(Transaction.user_uuid == user_uuid))
        transactions = result.scalars().all()

        if not transactions:
            logger.info(
                "base_currency_change_no_transactions",
                user_uuid=str(user_uuid),
                new_base_currency=new_base_currency,
            )
            return

        recalculated = 0
        # Two-phase: first convert ALL amounts (network-bound), then apply. If any
        # conversion fails (e.g. the exchange-rate provider is unreachable), raise
        # BEFORE mutating any row so no partially-recalculated state is left behind.
        conversions: list[tuple[Transaction, Decimal, Decimal]] = []
        for tx in transactions:
            original_currency = (tx.currency or new_base_currency).upper()
            base_amount, new_rate = await convert_to_user_base(
                tx.amount_original, original_currency, new_base_currency
            )
            conversions.append((tx, base_amount, new_rate))

        for tx, base_amount, new_rate in conversions:
            tx.amount = base_amount.quantize(Decimal("0.00000001"))
            tx.exchange_rate = new_rate.quantize(Decimal("0.00000001"))
            recalculated += 1

        await self.db.commit()

        logger.info(
            "base_currency_change_recalculation_complete",
            user_uuid=str(user_uuid),
            new_base_currency=new_base_currency,
            transactions_recalculated=recalculated,
        )
