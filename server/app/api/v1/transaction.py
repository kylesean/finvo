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

from app.core.aliases import CurrentUser, DbSession
from app.core.constants.currency import PROJECT_DEFAULT_CURRENCY
from app.core.exceptions import NotFoundError
from app.core.responses import ResponseEnvelope, pagination_payload, success_response
from app.core.service_deps import get_transaction_query_service, get_transaction_service
from app.models.notification import Notification
from app.models.transaction import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.schemas.transaction import (
    BatchCreateTransactionRequest,
    CashFlowForecastRequest,
    CommentCreateRequest,
    RecurringTransactionCreateRequest,
    RecurringTransactionUpdateRequest,
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
        data=pagination_payload(
            items=[transaction_to_dict(item, display_currency) for item in result.items],
            page=result.page,
            size=result.per_page,
            total=result.total,
            pages=result.pages,
            has_more=result.has_more,
        ),
        message="Transactions retrieved successfully",
    )


@router.get("/search", response_model=ResponseEnvelope[dict[str, Any]])
async def search_transactions(
    current_user: CurrentUser,
    db: DbSession,
    params: Annotated[Params, Depends()],
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
        category_keys=[k.strip() for k in category_keys.split(",") if k.strip()] if category_keys else None,
        tags=[t.strip() for t in tags.split(",") if t.strip()] if tags else None,
        start_date=start_date,
        end_date=end_date,
        transaction_types=[transaction_type.upper()] if transaction_type else None,
    )

    # Obtain user's primary display currency
    display_currency = await get_user_display_currency(db, current_user.uuid)

    # Paginate using fastapi-pagination
    page_result = await apaginate(
        db,
        query,
        params=params,
        transformer=lambda items: [transaction_to_dict(t, display_currency) for t in items],
    )

    # Return unified format response
    return success_response(
        data=pagination_payload(
            items=page_result.items,
            page=page_result.page,
            size=page_result.size,
            total=page_result.total,
            pages=page_result.pages,
        ),
        message="Transactions searched successfully",
    )


@router.get("/recurring", response_model=ResponseEnvelope[list[dict[str, Any]]])
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


@router.post("/recurring", response_model=ResponseEnvelope[dict[str, Any]])
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


@router.get("/pending", response_model=ResponseEnvelope[list[dict[str, Any]]])
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
        account_id=request.account_id,
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
        transaction_ids=request.transaction_ids,
        account_id=request.account_id,
    )
    return success_response(
        data=result,
        message="Batch transactions account updated successfully",
    )


@router.get("/{transaction_id:uuid}/comments", response_model=ResponseEnvelope[list[dict[str, Any]]])
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


@router.post("/{transaction_id:uuid}/comments", response_model=ResponseEnvelope[dict[str, Any]])
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
    )
    return success_response(
        data=comment,
        message="Comment added successfully",
    )


@router.delete("/comments/{comment_id}", response_model=ResponseEnvelope[dict[str, Any]])
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


@router.get("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
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


@router.put("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
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


@router.delete("/recurring/{recurring_id:uuid}", response_model=ResponseEnvelope[dict[str, Any]])
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


@router.post("/forecast", response_model=ResponseEnvelope[dict[str, Any]])
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


@router.post("/{transaction_id:uuid}/confirm", response_model=ResponseEnvelope[dict[str, Any]])
async def confirm_pending_transaction(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Confirm a PENDING transaction, changing its status to CONFIRMED."""
    data = await service.confirm_pending_transaction(transaction_id, current_user.uuid)
    return success_response(data=data, message="Transaction confirmed")


@router.post("/{transaction_id:uuid}/skip", response_model=ResponseEnvelope[dict[str, Any]])
async def skip_pending_transaction(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Skip (delete) a PENDING transaction."""
    await service.skip_pending_transaction(transaction_id, current_user.uuid)
    return success_response(data=None, message="Transaction skipped")
