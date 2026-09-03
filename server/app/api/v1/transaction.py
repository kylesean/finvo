"""Transaction management API endpoints."""

from datetime import datetime
from decimal import Decimal
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from fastapi.responses import JSONResponse

from app.core.aliases import CurrentUser, DbSession
from app.core.exceptions import NotFoundError
from app.core.pagination import Paging, paginate, payload
from app.core.responses import ResponseEnvelope, success_response
from app.core.service_deps import get_transaction_query_service, get_transaction_service
from app.repositories.transaction_repository import TransactionRepository
from app.schemas.transaction import (
    BatchAccountUpdateResult,
    BatchCreateTransactionRequest,
    CashFlowForecastRequest,
    CashFlowForecastResponse,
    CommentCreateRequest,
    PendingTransactionResponse,
    RecurringTransactionCreateRequest,
    RecurringTransactionResponse,
    RecurringTransactionUpdateRequest,
    TransactionActionResponse,
    TransactionBatchResult,
    TransactionCommentResponse,
    TransactionDetailResponse,
    TransactionFeedResponse,
    UpdateAccountRequest,
    UpdateBatchAccountRequest,
)
from app.schemas.transaction_mapper import transaction_to_dict
from app.services.transaction_query_service import (
    TransactionQueryParams,
    TransactionQueryService,
    TransactionType,
)
from app.services.transaction_service import TransactionService
from app.utils.currency_utils import get_user_display_currency

router = APIRouter(prefix="/transactions", tags=["transactions"])

# Service-specific DI aliases. CurrentUser/DbSession come from app.core.aliases.
TxService = Annotated[TransactionService, Depends(get_transaction_service)]
TxQueryService = Annotated[TransactionQueryService, Depends(get_transaction_query_service)]


@router.get("", response_model=ResponseEnvelope[TransactionFeedResponse])
async def get_transactions(
    current_user: CurrentUser,
    db: DbSession,
    query_service: TxQueryService,
    paging: Paging,
    date: str | None = Query(default=None, pattern=r"^\d{4}-\d{2}-\d{2}$"),  # YYYY-MM-DD format
    transaction_type: str | None = Query(
        default=None, pattern="(?i)^(EXPENSE|INCOME|TRANSFER)$"
    ),  # EXPENSE, INCOME, TRANSFER
) -> JSONResponse:
    """Retrieve Transaction List (Feed Stream).

    Args:
        current_user: Current user
        db: Database session
        query_service: Transaction query service
        paging: Pagination params (page/page_size)
        date: Optional, date in YYYY-MM-DD format for filtering
        transaction_type: Optional, transaction type (EXPENSE, INCOME, TRANSFER)

    Returns:
        Unified format pagination response, containing display fields
    """
    params = TransactionQueryParams(
        date=date,
        transaction_types=[TransactionType(transaction_type.upper())] if transaction_type else None,
        page=paging.page,
        per_page=paging.page_size,
    )

    result = await query_service.search(str(current_user.uuid), params)
    display_currency = await get_user_display_currency(db, current_user.uuid)

    return success_response(
        data=payload(
            items=[transaction_to_dict(item, display_currency) for item in result.items],
            page=result.page,
            page_size=result.per_page,
            total=result.total,
        ),
        message="Transactions retrieved successfully",
    )


@router.get("/search", response_model=ResponseEnvelope[TransactionFeedResponse])
async def search_transactions(
    current_user: CurrentUser,
    db: DbSession,
    paging: Paging,
    keyword: str | None = None,
    min_amount: Decimal | None = None,
    max_amount: Decimal | None = None,
    category_keys: str | None = None,
    tags: str | None = None,
    start_date: datetime | None = None,
    end_date: datetime | None = None,
    transaction_type: str | None = Query(default=None, pattern="(?i)^(EXPENSE|INCOME|TRANSFER)$"),
) -> JSONResponse:
    """Search transaction records.

    Args:
        paging: Pagination params (page/page_size)
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
    # [P1-1] Filtered query built by the repository; the route owns no ORM.
    query = TransactionRepository(db).search_query(
        current_user.uuid,
        keyword=keyword,
        min_amount=min_amount,
        max_amount=max_amount,
        category_keys=[k.strip() for k in category_keys.split(",") if k.strip()] if category_keys else None,
        tags=[t.strip() for t in tags.split(",") if t.strip()] if tags else None,
        start_date=start_date,
        end_date=end_date,
        transaction_types=[transaction_type.upper()] if transaction_type else None,
    )

    display_currency = await get_user_display_currency(db, current_user.uuid)

    return success_response(
        data=await paginate(
            db,
            query,
            paging,
            transformer=lambda items: [transaction_to_dict(t, display_currency) for t in items],
        ),
        message="Transactions searched successfully",
    )


@router.get("/recurring", response_model=ResponseEnvelope[list[RecurringTransactionResponse]])
async def list_recurring_transactions(
    current_user: CurrentUser,
    service: TxService,
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


@router.post("/recurring", response_model=ResponseEnvelope[RecurringTransactionResponse])
async def create_recurring_transaction(
    request: RecurringTransactionCreateRequest,
    current_user: CurrentUser,
    service: TxService,
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


@router.get("/pending", response_model=ResponseEnvelope[list[PendingTransactionResponse]])
async def get_pending_transactions(
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Get all PENDING transactions for the current user.

    These are auto-generated by recurring rules that require confirmation.
    """
    items = await service.list_pending_transactions(current_user.uuid)
    return success_response(data=items)


@router.get("/{transaction_id:uuid}", response_model=ResponseEnvelope[TransactionDetailResponse])
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


@router.delete("/{transaction_id:uuid}", status_code=status.HTTP_200_OK, response_model=ResponseEnvelope[None])
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


@router.patch("/{transaction_id:uuid}/account", response_model=ResponseEnvelope[TransactionDetailResponse])
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
        account_id=request.account_id,
    )
    return success_response(
        data=result,
        message="Transaction account updated successfully",
    )


@router.post("/batch", response_model=ResponseEnvelope[TransactionBatchResult])
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


@router.patch("/batch/account", response_model=ResponseEnvelope[BatchAccountUpdateResult])
async def update_batch_transactions_account(
    request: UpdateBatchAccountRequest,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Batch update transactions account."""
    result = await service.update_batch_transactions_account(
        user_uuid=current_user.uuid,
        transaction_ids=request.transaction_ids,
        account_id=request.account_id,
    )
    return success_response(
        data=result,
        message="Batch transactions account updated successfully",
    )


@router.get("/{transaction_id:uuid}/comments", response_model=ResponseEnvelope[list[TransactionCommentResponse]])
async def get_transaction_comments(
    transaction_id: UUID,  # UUID from path
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Get transaction comment list."""
    comments = await service.get_comments_for_transaction(transaction_id, current_user.uuid)
    return success_response(
        data=comments,
        message="Comments retrieved successfully",
    )


@router.post("/{transaction_id:uuid}/comments", response_model=ResponseEnvelope[TransactionCommentResponse])
async def add_transaction_comment(
    transaction_id: UUID,  # UUID from path
    request: CommentCreateRequest,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Add transaction comment."""
    comment = await service.add_comment(
        transaction_id=transaction_id,
        user_uuid=current_user.uuid,
        comment_text=request.comment_text,
        parent_comment_id=request.parent_comment_id,
        mentioned_user_ids=request.mentioned_user_ids,
        commenter_username=current_user.username or "Unknown",
        replied_to_user_id=request.replied_to_user_id,
    )
    return success_response(
        data=comment,
        message="Comment added successfully",
    )


@router.delete("/comments/{comment_id}", response_model=ResponseEnvelope[None])
async def delete_transaction_comment(
    comment_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Delete transaction comment."""
    success = await service.delete_comment(comment_id, current_user.uuid)

    if not success:
        raise NotFoundError("Comment")

    return success_response(
        data=None,
        message="Comment deleted successfully",
    )


@router.get("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[RecurringTransactionResponse])
async def get_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Retrieve recurring transaction detail."""
    recurring_tx = await service.get_recurring_transaction(recurring_id, current_user.uuid)

    if not recurring_tx:
        raise NotFoundError("Recurring transaction")

    return success_response(
        data=recurring_tx,
        message="Recurring transaction retrieved successfully",
    )


@router.put("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[RecurringTransactionResponse])
async def update_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    request: RecurringTransactionUpdateRequest,
    current_user: CurrentUser,
    service: TxService,
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


@router.delete("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[None])
async def delete_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Delete recurring transaction."""
    success = await service.delete_recurring_transaction(recurring_id, current_user.uuid)

    if not success:
        raise NotFoundError("Recurring transaction")

    return success_response(
        data=None,
        message="Recurring transaction deleted successfully",
    )


@router.post("/forecast", response_model=ResponseEnvelope[CashFlowForecastResponse])
async def forecast_cash_flow(
    request: CashFlowForecastRequest,
    current_user: CurrentUser,
    service: TxService,
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


@router.post("/{transaction_id:uuid}/confirm", response_model=ResponseEnvelope[TransactionActionResponse])
async def confirm_pending_transaction(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Confirm a PENDING transaction, changing its status to CONFIRMED."""
    data = await service.confirm_pending_transaction(transaction_id, current_user.uuid)
    return success_response(data=data, message="Transaction confirmed")


@router.post("/{transaction_id:uuid}/skip", response_model=ResponseEnvelope[TransactionActionResponse])
async def skip_pending_transaction(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Skip (delete) a PENDING transaction."""
    await service.skip_pending_transaction(transaction_id, current_user.uuid)
    return success_response(data=None, message="Transaction skipped")
