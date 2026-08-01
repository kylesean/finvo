"""Transaction management API endpoints."""

from datetime import datetime
from decimal import Decimal
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from fastapi.responses import JSONResponse
from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import apaginate
from sqlalchemy import and_, desc, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config.currency import PROJECT_DEFAULT_CURRENCY
from app.core.database import get_session
from app.core.dependencies import get_current_user
from app.core.exceptions import BusinessError, CommonErrorCode, NotFoundError
from app.core.responses import ResponseEnvelope, success_response
from app.core.service_deps import get_transaction_query_service, get_transaction_service
from app.models.notification import Notification
from app.models.transaction import Transaction
from app.models.user import User
from app.repositories.notification_repository import NotificationRepository
from app.repositories.transaction_repository import TransactionRepository
from app.schemas.transaction import (
    BatchCreateTransactionRequest,
    CashFlowForecastRequest,
    CommentCreateRequest,
    RecurringTransactionCreateRequest,
    RecurringTransactionUpdateRequest,
    TransactionDisplayValue,
    TransactionResponse,
    UpdateAccountRequest,
    UpdateBatchAccountRequest,
)
from app.services.transaction_query_service import TransactionQueryService
from app.services.transaction_service import TransactionService
from app.utils.currency_utils import get_user_display_currency

router = APIRouter(prefix="/transactions", tags=["transactions"])

# Type aliases for cleaner dependency injection
CurrentUser = Annotated[User, Depends(get_current_user)]
DbSession = Annotated[AsyncSession, Depends(get_session)]
TxService = Annotated[TransactionService, Depends(get_transaction_service)]


def _get_attr(obj: Any, snake_case: str, camel_case: str | None = None) -> Any:
    """Get attribute from object or dict, supporting both snake_case and camelCase keys.

    Args:
        obj: The object or dict to extract value from
        snake_case: The snake_case attribute name (for ORM models)
        camel_case: Optional camelCase key name (for dicts), defaults to snake_case

    Returns:
        The attribute value or None
    """
    if camel_case is None:
        camel_case = snake_case
    if isinstance(obj, dict):
        # Explicit key-existence checks: `or`-fallback would silently drop
        # falsy values (0, "", False, []) and fall through to the other key.
        if camel_case in obj:
            return obj[camel_case]
        if snake_case in obj:
            return obj[snake_case]
        return None
    return getattr(obj, snake_case, None)


def _format_datetime(value: Any) -> Any:
    """Format a datetime value to ISO format string.

    Args:
        value: A datetime object or string

    Returns:
        ISO format string or original value if not a datetime
    """
    if hasattr(value, "isoformat"):
        return value.isoformat()
    return value


def _to_decimal(val: Any) -> Decimal:
    """Helper to convert float, int, str, or Decimal to Decimal safely."""
    if val is None:
        return Decimal("0.0")
    if isinstance(val, Decimal):
        return val
    return Decimal(str(val))


def _extract_amounts(tx: Any) -> tuple[Decimal, Decimal, str, Any]:
    """Extract amount-related fields from transaction as Decimal.

    Args:
        tx: Transaction object or dict

    Returns:
        Tuple of (amount_val, amount_original, original_currency, stored_exchange_rate)
    """
    raw_original = _get_attr(tx, "amount_original", "amountOriginal") or _get_attr(tx, "amount") or "0.0"
    amount_original = _to_decimal(raw_original)
    original_currency = _get_attr(tx, "currency") or PROJECT_DEFAULT_CURRENCY
    stored_exchange_rate = _get_attr(tx, "exchange_rate", "exchangeRate")
    amount_val = _to_decimal(_get_attr(tx, "amount") or "0.0")

    return amount_val, amount_original, original_currency, stored_exchange_rate


def _transaction_to_dict(tx: Any, display_currency: str = PROJECT_DEFAULT_CURRENCY) -> dict[str, Any]:
    """Convert transaction model to dictionary for API response using Pydantic TransactionResponse schema.

    Args:
        tx: Transaction object, dict, or TransactionItem
        display_currency: User's base currency

    Returns:
        Dictionary representation of the transaction with camelCase aliases
    """
    from app.services.transaction_query_service import TransactionItem

    # Fast path: already formatted dict
    if isinstance(tx, dict) and ("userUuid" in tx or "display" in tx):
        return tx

    # Check if already converted by service layer
    is_already_converted = isinstance(tx, TransactionItem)

    # Extract core identifiers
    tx_id = str(_get_attr(tx, "id"))
    tx_type = str(_get_attr(tx, "type"))
    user_uuid = str(_get_attr(tx, "user_uuid", "userUuid"))

    # Extract amounts
    amount_val, amount_original, original_currency, stored_exchange_rate = _extract_amounts(tx)

    # Display original currency amount directly
    if not is_already_converted:
        amount_val = amount_original

    # Build typed Pydantic response model
    response_model = TransactionResponse(
        id=tx_id,
        user_uuid=user_uuid,
        type=tx_type,
        amount=amount_val,
        currency=original_currency,
        amount_base=_to_decimal(_get_attr(tx, "amount") or "0.0"),
        base_currency=display_currency,
        amount_original=amount_original,
        original_currency=original_currency,
        exchange_rate=str(stored_exchange_rate) if stored_exchange_rate else None,
        category_key=_get_attr(tx, "category_key", "categoryKey"),
        description=_get_attr(tx, "description") or "",
        raw_input=_get_attr(tx, "raw_input", "rawInput") or "",
        transaction_at=_format_datetime(_get_attr(tx, "transaction_at", "transactionAt")),
        transaction_timezone=_get_attr(tx, "transaction_timezone", "transactionTimezone") or "Asia/Shanghai",
        created_at=_format_datetime(_get_attr(tx, "created_at", "createdAt")),
        tags=_get_attr(tx, "tags") or [],
        status=_get_attr(tx, "status") or "CLEARED",
        location=_get_attr(tx, "location"),
        source_account_id=str(_get_attr(tx, "source_account_id")) if _get_attr(tx, "source_account_id") else None,
        target_account_id=str(_get_attr(tx, "target_account_id")) if _get_attr(tx, "target_account_id") else None,
        display=TransactionDisplayValue.from_params(amount=amount_val, tx_type=tx_type, currency=original_currency),
    )

    return response_model.model_dump(by_alias=True)


@router.get("", response_model=ResponseEnvelope[dict[str, Any]])
async def get_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
    query_service: Annotated[TransactionQueryService, Depends(get_transaction_query_service)],
    page: int = Query(default=1, ge=1),
    size: int = Query(default=20, ge=1, le=100),
    date: str | None = Query(default=None, pattern=r"^\d{4}-\d{2}-\d{2}$"),  # YYYY-MM-DD format
    transaction_type: str | None = Query(
        default=None, pattern="(?i)^(EXPENSE|INCOME|TRANSFER)$"
    ),  # EXPENSE, INCOME, TRANSFER
) -> JSONResponse:
    """Retrieve Transaction List (Feed Stream)
       Supports filtering by date and transaction type, returns a list of transactions with display calculated fields.

    Args:
        current_user: Current user
        db: Database session
        query_service: Transaction query service
        page: Page number, default is 1
        size: Number of items per page, default is 20
        date: Optional, date in YYYY-MM-DD format for filtering
        transaction_type: Optional, transaction type (EXPENSE, INCOME, TRANSFER)

    Returns:
        Unified format pagination response, containing display fields
    """
    from app.services.transaction_query_service import (
        TransactionQueryParams,
        TransactionType,
    )

    # Build query parameters
    params = TransactionQueryParams(
        date=date,
        transaction_types=[TransactionType(transaction_type.upper())] if transaction_type else None,
        page=page,
        per_page=size,
    )

    # Execute search via shared query service
    result = await query_service.search(str(current_user.uuid), params)

    # Obtain user's primary display currency
    display_currency = await get_user_display_currency(db, current_user.uuid)

    # Map response items (displaying original currency amounts)
    return success_response(
        data={
            "items": [_transaction_to_dict(item, display_currency) for item in result.items],
            "page": result.page,
            "size": result.per_page,
            "total": result.total,
            "pages": result.pages,
            "hasMore": result.has_more,
        },
        message="Transactions retrieved successfully",
    )


@router.get("/search", response_model=ResponseEnvelope[dict[str, Any]])
async def search_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
    params: Annotated[Params, Depends()],
    keyword: str | None = None,
    min_amount: Decimal | None = None,
    max_amount: Decimal | None = None,
    category_keys: str | None = None,
    tags: str | None = None,
    start_date: datetime | None = None,
    end_date: datetime | None = None,
    transaction_type: str | None = None,
) -> JSONResponse:
    """Search transaction records.

    Uses fastapi-pagination for standard pagination, supporting various filter criteria.

    Args:
        params: Pagination parameters
        keyword: Keyword search (description, location)
        min_amount: Minimum amount
        max_amount: Maximum amount
        category_keys: Category keys (comma separated)
        tags: Tags (comma separated)
        start_date: Start datetime
        end_date: End datetime
        transaction_type: Transaction type
        current_user: Currently authenticated user
        db: Database session

    Returns:
        Unified JSON pagination response
    """
    # Build the filtered query via the repository (keeps ORM construction out
    # of the route layer and escapes LIKE metacharacters consistently).
    query = TransactionRepository(db).search_query(
        current_user.uuid,
        keyword=keyword,
        min_amount=min_amount,
        max_amount=max_amount,
        category_keys=category_keys,
        tags=tags,
        start_date=start_date,
        end_date=end_date,
        transaction_type=transaction_type,
    )

    # Obtain user's primary display currency
    display_currency = await get_user_display_currency(db, current_user.uuid)

    # Paginate using fastapi-pagination
    page_result = await apaginate(
        db,
        query,
        params=params,
        transformer=lambda items: [_transaction_to_dict(t, display_currency) for t in items],
    )

    # Return unified format response
    return success_response(
        data={
            "items": page_result.items,
            "page": page_result.page,
            "size": page_result.size,
            "total": page_result.total,
            "pages": page_result.pages,
            "has_more": page_result.page < page_result.pages if page_result.pages else False,
        },
        message="Transactions searched successfully",
    )


@router.get("/recurring", response_model=ResponseEnvelope[list[dict[str, Any]]])
async def list_recurring_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
    type: str | None = None,  # EXPENSE, INCOME, TRANSFER
    is_active: bool | None = None,
) -> JSONResponse:
    """List recurring transactions.

    Args:
        type: Optional, transaction type filter (EXPENSE, INCOME, TRANSFER)
        is_active: Optional, active status filter
        current_user: Currently authenticated user
        service: Injected transaction service

    Returns:
        List of recurring transactions
    """
    recurring_txs = await service.list_recurring_transactions(
        current_user.uuid,
        type_filter=type,
        is_active=is_active,
    )
    return success_response(
        data=recurring_txs,
        message="Recurring transactions retrieved successfully",
    )


@router.post("/recurring", response_model=ResponseEnvelope[dict[str, Any]])
async def create_recurring_transaction(
    request: RecurringTransactionCreateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Create recurring transaction."""
    recurring_tx = await service.create_recurring_transaction(current_user.uuid, request.model_dump())
    return success_response(
        data=recurring_tx,
        message="Recurring transaction created successfully",
    )


# ============================================================================
# Pending Transaction Confirmation
# ============================================================================


@router.get("/pending", response_model=ResponseEnvelope[list[dict[str, Any]]])
async def get_pending_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """Get all PENDING transactions for the current user.

    These are auto-generated by recurring rules that require confirmation.
    """
    repo = TransactionRepository(db)
    transactions = await repo.list_pending(current_user.uuid)

    items = [
        {
            "id": str(tx.id),
            "type": tx.type,
            "amount": str(tx.amount_original),
            "currency": tx.currency,
            "category_key": tx.category_key,
            "description": tx.description,
            "transaction_at": tx.transaction_at.isoformat() if tx.transaction_at else None,
            "source": tx.source,
            "recurring_transaction_id": str(tx.recurring_transaction_id) if tx.recurring_transaction_id else None,
        }
        for tx in transactions
    ]

    return success_response(data=items)


@router.get("/{transaction_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
async def get_transaction_detail(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Get transaction details."""
    transaction_data = await service.get_transaction_detail(transaction_id, current_user.uuid)

    if not transaction_data:
        raise NotFoundError("Transaction")

    return success_response(
        data=transaction_data,
        message="Transaction retrieved successfully",
    )


@router.delete(
    "/{transaction_id:uuid}", status_code=status.HTTP_200_OK, response_model=ResponseEnvelope[dict[str, Any]]
)
async def delete_transaction(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Delete transaction."""
    await service.delete_transaction(transaction_id, current_user.uuid)
    return success_response(
        data=None,
        message="Transaction deleted successfully",
    )


@router.patch("/{transaction_id:uuid}/account", response_model=ResponseEnvelope[dict[str, Any]])
async def update_transaction_account(
    transaction_id: UUID,
    request: UpdateAccountRequest,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Update transaction associated account.

    Supports:
    - Associate account: pass account_id
    - Disassociate account: pass null
    - Switch account: pass new account_id (automatically rolls back old account balance and updates new account)
    """
    result = await service.update_transaction_account(
        transaction_id=transaction_id,
        user_uuid=current_user.uuid,
        account_id=UUID(request.account_id) if request.account_id else None,
    )
    return success_response(
        data=result,
        message="Transaction account updated successfully",
    )


@router.post("/batch", response_model=ResponseEnvelope[dict[str, Any]])
async def create_batch_transactions(
    request: BatchCreateTransactionRequest,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Batch create transactions."""
    result = await service.create_batch_transactions(
        user_uuid=current_user.uuid,
        data=request.model_dump(),
    )
    return success_response(
        data=result,
        message="Batch transactions created successfully",
    )


@router.patch("/batch/account", response_model=ResponseEnvelope[dict[str, Any]])
async def update_batch_transactions_account(
    request: UpdateBatchAccountRequest,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Batch update transactions account."""
    result = await service.update_batch_transactions_account(
        user_uuid=current_user.uuid,
        transaction_ids=[UUID(tid) for tid in request.transaction_ids],
        account_id=UUID(request.account_id) if request.account_id else None,
    )
    return success_response(
        data=result,
        message="Batch transactions account updated successfully",
    )


@router.get("/{transaction_id:uuid}/comments", response_model=ResponseEnvelope[list[dict[str, Any]]])
async def get_transaction_comments(
    transaction_id: UUID,  # UUID from path
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Get transaction comment list."""
    comments = await service.get_comments_for_transaction(transaction_id, current_user.uuid)
    return success_response(
        data=comments,
        message="Comments retrieved successfully",
    )


@router.post("/{transaction_id:uuid}/comments", response_model=ResponseEnvelope[dict[str, Any]])
async def add_transaction_comment(
    transaction_id: UUID,  # UUID from path
    request: CommentCreateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Add transaction comment."""
    comment = await service.add_comment(
        transaction_id=transaction_id,
        user_uuid=current_user.uuid,
        comment_text=request.comment_text,
        parent_comment_id=request.parent_comment_id,
        mentioned_user_ids=request.mentioned_user_ids,
        commenter_username=current_user.username or "Unknown",
    )
    return success_response(
        data=comment,
        message="Comment added successfully",
    )


@router.delete("/comments/{comment_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def delete_transaction_comment(
    comment_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Delete transaction comment."""
    success = await service.delete_comment(comment_id, current_user.uuid)

    if not success:
        raise NotFoundError("Comment")

    return success_response(
        data=None,
        message="Comment deleted successfully",
    )


@router.get("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
async def get_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Retrieve recurring transaction detail."""
    recurring_tx = await service.get_recurring_transaction(recurring_id, current_user.uuid)

    if not recurring_tx:
        raise NotFoundError("Recurring transaction")

    return success_response(
        data=recurring_tx,
        message="Recurring transaction retrieved successfully",
    )


@router.put("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
async def update_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    request: RecurringTransactionUpdateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Update recurring transaction."""
    recurring_tx = await service.update_recurring_transaction(
        recurring_id, current_user.uuid, request.model_dump(exclude_unset=True)
    )

    if not recurring_tx:
        raise NotFoundError("Recurring transaction")

    return success_response(
        data=recurring_tx,
        message="Recurring transaction updated successfully",
    )


@router.delete("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
async def delete_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Delete recurring transaction."""
    success = await service.delete_recurring_transaction(recurring_id, current_user.uuid)

    if not success:
        raise NotFoundError("Recurring transaction")

    return success_response(
        data=None,
        message="Recurring transaction deleted successfully",
    )


@router.post("/forecast", response_model=ResponseEnvelope[dict[str, Any]])
async def forecast_cash_flow(
    request: CashFlowForecastRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[TransactionService, Depends(get_transaction_service)],
) -> JSONResponse:
    """Generate cash flow forecast."""
    forecast = await service.forecast_cash_flow(
        user_uuid=current_user.uuid,
        forecast_days=request.forecast_days,
        granularity=request.granularity,
        scenarios=request.scenarios,
    )
    return success_response(
        data=forecast,
        message="Cash flow forecast generated successfully",
    )


@router.post("/{transaction_id:uuid}/confirm", response_model=ResponseEnvelope[dict[str, Any]])
async def confirm_pending_transaction(
    transaction_id: UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """Confirm a PENDING transaction, changing its status to CONFIRMED."""
    repo = TransactionRepository(db)
    tx = await repo.get_by_id_for_user(transaction_id, current_user.uuid)

    if not tx:
        raise NotFoundError("Transaction")
    if tx.status != "PENDING":
        raise BusinessError(
            "Transaction is not in PENDING status",
            error_code=CommonErrorCode.VALIDATION_ERROR,
        )

    tx.status = "CONFIRMED"
    # Auto-mark associated notification as read
    await NotificationRepository(db).mark_recurring_pending_read(current_user.uuid, transaction_id)
    await db.commit()

    return success_response(data={"id": str(tx.id), "status": "CONFIRMED"}, message="Transaction confirmed")


@router.post("/{transaction_id:uuid}/skip", response_model=ResponseEnvelope[dict[str, Any]])
async def skip_pending_transaction(
    transaction_id: UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """Skip (delete) a PENDING transaction."""
    repo = TransactionRepository(db)
    tx = await repo.get_by_id_for_user(transaction_id, current_user.uuid)

    if not tx:
        raise NotFoundError("Transaction")
    if tx.status != "PENDING":
        raise BusinessError(
            "Transaction is not in PENDING status",
            error_code=CommonErrorCode.VALIDATION_ERROR,
        )

    # Auto-mark associated notification as read before deleting the transaction
    await NotificationRepository(db).mark_recurring_pending_read(current_user.uuid, transaction_id)
    await db.delete(tx)
    await db.commit()

    return success_response(data=None, message="Transaction skipped")
