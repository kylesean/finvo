"""Transaction management API endpoints."""

from datetime import datetime
from decimal import Decimal
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import apaginate
from sqlalchemy import and_, desc, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config.currency import PROJECT_DEFAULT_CURRENCY
from app.core.database import get_session
from app.core.dependencies import get_current_user
from app.core.responses import error_response, get_error_code_int, success_response
from app.core.service_deps import get_transaction_service
from app.models.notification import Notification
from app.models.transaction import Transaction
from app.models.user import User
from app.schemas.transaction import (
    BatchCreateTransactionRequest,
    CashFlowForecastRequest,
    CommentCreateRequest,
    RecurringTransactionCreateRequest,
    RecurringTransactionUpdateRequest,
    TransactionDisplayValue,
    UpdateAccountRequest,
    UpdateBatchAccountRequest,
)
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
        return obj.get(camel_case) or obj.get(snake_case)
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


def _extract_amounts(tx: Any) -> tuple[float, float, str, Any]:
    """Extract amount-related fields from transaction.

    Args:
        tx: Transaction object or dict

    Returns:
        Tuple of (amount_val, amount_original, original_currency, stored_exchange_rate)
    """
    amount_original = float(_get_attr(tx, "amount_original", "amountOriginal") or _get_attr(tx, "amount") or 0)
    original_currency = _get_attr(tx, "currency") or PROJECT_DEFAULT_CURRENCY
    stored_exchange_rate = _get_attr(tx, "exchange_rate", "exchangeRate")
    amount_val = float(_get_attr(tx, "amount") or 0)

    return amount_val, amount_original, original_currency, stored_exchange_rate


def _transaction_to_dict(
    tx: Any, display_currency: str = PROJECT_DEFAULT_CURRENCY, exchange_rate: float = 1.0
) -> dict[str, Any]:
    """Convert transaction model to dictionary for API response.

    This function handles multiple input types:
    - SQLModel Transaction objects
    - Pydantic TransactionItem objects
    - Pre-formatted dictionaries

    Returns format (user-base-currency model):
    - amount: Original currency amount (amount_original)
    - currency: Original currency code
    - amountBase: Base currency equivalent (Transaction.amount)
    - baseCurrency: User's base currency code
    - exchangeRate: Exchange rate snapshot at recording time

    Args:
        tx: Transaction object, dict, or TransactionItem
        display_currency: User's base currency
        exchange_rate: Deprecated, kept for compatibility

    Returns:
        Dictionary representation of the transaction
    """
    from app.services.transaction_query_service import TransactionItem

    # Fast path: already formatted dict
    if isinstance(tx, dict) and ("userUuid" in tx or "display" in tx):
        return tx

    # Check if already converted by service layer
    is_already_converted = isinstance(tx, TransactionItem)

    # Extract core identifiers
    tx_id = str(_get_attr(tx, "id"))
    tx_type = _get_attr(tx, "type")
    user_uuid = _get_attr(tx, "user_uuid", "userUuid")

    # Extract amounts
    amount_val, amount_original, original_currency, stored_exchange_rate = _extract_amounts(tx)

    # Display original currency amount directly
    if not is_already_converted:
        amount_val = amount_original

    # Build response dictionary
    return {
        # Core fields
        "id": tx_id,
        "userUuid": str(user_uuid),
        "type": tx_type,
        # Amount fields - show original currency
        "amount": round(amount_val, 2),
        "currency": original_currency,
        "amountBase": round(float(_get_attr(tx, "amount") or 0), 2),
        "baseCurrency": display_currency,
        "amountOriginal": round(amount_original, 2),
        "originalCurrency": original_currency,
        "exchangeRate": str(stored_exchange_rate) if stored_exchange_rate else None,
        # Descriptive fields
        "categoryKey": _get_attr(tx, "category_key", "categoryKey"),
        "description": _get_attr(tx, "description") or "",
        "rawInput": _get_attr(tx, "raw_input", "rawInput") or "",
        # Temporal fields
        "transactionAt": _format_datetime(_get_attr(tx, "transaction_at", "transactionAt")),
        "transactionTimezone": _get_attr(tx, "transaction_timezone", "transactionTimezone") or "Asia/Shanghai",
        "createdAt": _format_datetime(_get_attr(tx, "created_at", "createdAt")),
        # Metadata
        "tags": _get_attr(tx, "tags") or [],
        "status": _get_attr(tx, "status") or "CLEARED",
        "location": _get_attr(tx, "location"),
        # Account references
        "sourceAccountId": str(_get_attr(tx, "source_account_id")) if _get_attr(tx, "source_account_id") else None,
        "targetAccountId": str(_get_attr(tx, "target_account_id")) if _get_attr(tx, "target_account_id") else None,
        # Display value for UI (uses original currency)
        "display": TransactionDisplayValue.from_params(
            amount=Decimal(str(amount_val)), tx_type=tx_type, currency=original_currency
        ).model_dump(by_alias=False),
    }


@router.get("")
async def get_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
    page: int = 1,
    size: int = 20,
    date: str | None = None,  # YYYY-MM-DD format
    transaction_type: str | None = None,  # EXPENSE, INCOME, TRANSFER
) -> JSONResponse:
    """Retrieve Transaction List (Feed Stream)
       Supports filtering by date and transaction type, returns a list of transactions with display calculated fields.

    Args:
        page: Page number, default is 1
        size: Number of items per page, default is 20
        date: Optional, date in YYYY-MM-DD format for filtering
        transaction_type: Optional, transaction type (EXPENSE, INCOME, TRANSFER)
        current_user: Current user
        db: Database session

    Returns:
        Unified format pagination response, containing display fields
    """
    from app.services.transaction_query_service import (
        TransactionQueryParams,
        TransactionQueryService,
        TransactionType,
    )

    # 构建查询参数
    params = TransactionQueryParams(
        date=date,
        transaction_types=[TransactionType(transaction_type.upper())] if transaction_type else None,
        page=page,
        per_page=size,
    )

    # 使用共享服务执行查询
    service = TransactionQueryService(db)
    result = await service.search(str(current_user.uuid), params)

    # 获取用户本位币
    display_currency = await get_user_display_currency(db, current_user.uuid)

    # 映射响应（展示原币金额）
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


@router.get("/search")
async def search_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
    params: Annotated[Params, Depends()],
    keyword: str | None = None,
    min_amount: str | None = None,
    max_amount: str | None = None,
    category_keys: str | None = None,
    tags: str | None = None,
    start_date: str | None = None,
    end_date: str | None = None,
    transaction_type: str | None = None,
) -> JSONResponse:
    """搜索交易记录

    使用 fastapi-pagination 进行标准分页，支持多种过滤条件。

    Args:
        params: 分页参数
        keyword: 关键词搜索（描述、位置）
        min_amount: 最小金额（字符串格式）
        max_amount: 最大金额（字符串格式）
        category_keys: 分类键（逗号分隔）
        tags: 标签（逗号分隔）
        start_date: 开始日期（ISO 8601）
        end_date: 结束日期（ISO 8601）
        transaction_type: 交易类型
        current_user: 当前用户
        db: 数据库会话

    Returns:
        统一格式的分页响应
    """
    # 构建基础查询
    conditions: list[Any] = []
    conditions.append(Transaction.user_uuid == current_user.uuid)

    # 添加过滤条件
    if keyword:
        # SQLModel field types are interpreted as actual types (str) rather than column elements
        # when accessing them directly. We use type: ignore for ilike/in_ etc.
        conditions.append(
            or_(
                Transaction.description.ilike(f"%{keyword}%"),
                Transaction.location.ilike(f"%{keyword}%"),
            )
        )

    if min_amount is not None:
        try:
            min_val = Decimal(min_amount)
            conditions.append(Transaction.amount >= min_val)
        except (ValueError, TypeError):
            pass

    if max_amount is not None:
        try:
            max_val = Decimal(max_amount)
            conditions.append(Transaction.amount <= max_val)
        except (ValueError, TypeError):
            pass

    if category_keys:
        keys = [k.strip() for k in category_keys.split(",")]
        conditions.append(Transaction.category_key.in_(keys))

    if tags:
        tag_list = [t.strip() for t in tags.split(",")]
        # PostgreSQL JSONB contains check
        for tag in tag_list:
            conditions.append(Transaction.tags.contains([tag]))

    if start_date:
        try:
            start_dt = datetime.fromisoformat(start_date.replace("Z", "+00:00"))
            conditions.append(Transaction.transaction_at >= start_dt)
        except ValueError:
            pass

    if end_date:
        try:
            end_dt = datetime.fromisoformat(end_date.replace("Z", "+00:00"))
            conditions.append(Transaction.transaction_at <= end_dt)
        except ValueError:
            pass

    if transaction_type:
        conditions.append(Transaction.type == transaction_type.upper())

    # 构建查询
    query = select(Transaction).where(and_(True, *conditions)).order_by(desc(Transaction.transaction_at))

    # 获取用户本位币
    display_currency = await get_user_display_currency(db, current_user.uuid)

    # 使用 fastapi-pagination 分页
    page_result = await apaginate(
        db,
        query,
        params=params,
        transformer=lambda items: [_transaction_to_dict(t, display_currency) for t in items],
    )

    # 返回统一格式
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


@router.get("/{transaction_id:uuid}")
async def get_transaction_detail(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Get transaction details."""
    transaction_data = await service.get_transaction_detail(transaction_id, current_user.uuid)

    if not transaction_data:
        return error_response(
            code=get_error_code_int("NOT_FOUND"),
            message="Transaction not found",
            http_status=status.HTTP_404_NOT_FOUND,
        )

    return success_response(
        data=transaction_data,
        message="Transaction retrieved successfully",
    )


@router.delete("/{transaction_id:uuid}", status_code=status.HTTP_200_OK)
async def delete_transaction(
    transaction_id: UUID,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Delete transaction."""
    from app.core.exceptions import BusinessError, NotFoundError

    try:
        await service.delete_transaction(transaction_id, current_user.uuid)
        return success_response(
            data=None,
            message="Transaction deleted successfully",
        )
    except NotFoundError:
        return error_response(
            code=get_error_code_int("NOT_FOUND"),
            message="Transaction not found",
            http_status=status.HTTP_404_NOT_FOUND,
        )
    except BusinessError as e:
        return error_response(
            code=get_error_code_int("FORBIDDEN"),
            message=str(e),
            http_status=status.HTTP_403_FORBIDDEN,
        )


@router.patch("/{transaction_id:uuid}/account")
async def update_transaction_account(
    transaction_id: UUID,
    request: UpdateAccountRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """更新交易的关联账户

    支持：
    - 关联账户：传入 account_id
    - 取消关联：传入 null
    - 更换账户：传入新的 account_id（会自动回滚旧账户余额并更新新账户）
    """
    from app.core.exceptions import BusinessError, NotFoundError

    service = TransactionService(db)
    try:
        result = await service.update_transaction_account(
            transaction_id=transaction_id,
            user_uuid=current_user.uuid,
            account_id=UUID(request.account_id) if request.account_id else None,
        )
        return success_response(
            data=result,
            message="Transaction account updated successfully",
        )
    except NotFoundError:
        return error_response(
            code=get_error_code_int("NOT_FOUND"),
            message="Transaction or account not found",
            http_status=status.HTTP_404_NOT_FOUND,
        )
    except BusinessError as e:
        return error_response(
            code=get_error_code_int("FORBIDDEN"),
            message=str(e),
            http_status=status.HTTP_403_FORBIDDEN,
        )


@router.post("/batch")
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


@router.patch("/batch/account")
async def update_batch_transactions_account(
    request: UpdateBatchAccountRequest,
    current_user: CurrentUser,
    service: TxService,
) -> JSONResponse:
    """Batch update transactions account."""
    from app.core.exceptions import BusinessError, NotFoundError

    try:
        result = await service.update_batch_transactions_account(
            user_uuid=current_user.uuid,
            transaction_ids=[UUID(tid) for tid in request.transaction_ids],
            account_id=UUID(request.account_id) if request.account_id else None,
        )
        return success_response(
            data=result,
            message="Batch transactions account updated successfully",
        )
    except (NotFoundError, BusinessError) as e:
        return error_response(
            code=get_error_code_int("INTERNAL_ERROR"),
            message=str(e),
            http_status=status.HTTP_400_BAD_REQUEST,
        )


@router.get("/{transaction_id:uuid}/comments")
async def get_transaction_comments(
    transaction_id: UUID,  # UUID from path
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """获取交易评论列表"""
    service = TransactionService(db)
    comments = await service.get_comments_for_transaction(transaction_id, current_user.uuid)
    return success_response(
        data=comments,
        message="Comments retrieved successfully",
    )


@router.post("/{transaction_id:uuid}/comments")
async def add_transaction_comment(
    transaction_id: UUID,  # UUID from path
    request: CommentCreateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """添加交易评论"""
    service = TransactionService(db)
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


@router.delete("/comments/{comment_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_transaction_comment(
    comment_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """删除交易评论"""
    service = TransactionService(db)
    success = await service.delete_comment(comment_id, current_user.uuid)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comment not found",
        )

    return success_response(
        data=None,
        message="Comment deleted successfully",
    )


@router.get("/recurring")
async def list_recurring_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
    type: str | None = None,  # EXPENSE, INCOME, TRANSFER
    is_active: bool | None = None,
) -> JSONResponse:
    """获取周期性交易列表

    Args:
        type: 可选，交易类型过滤 (EXPENSE, INCOME, TRANSFER)
        is_active: 可选，激活状态过滤
        current_user: 当前用户
        db: 数据库会话

    Returns:
        周期性交易列表
    """
    service = TransactionService(db)
    recurring_txs = await service.list_recurring_transactions(
        current_user.uuid,
        type_filter=type,
        is_active=is_active,
    )
    return success_response(
        data=recurring_txs,
        message="Recurring transactions retrieved successfully",
    )


@router.post("/recurring")
async def create_recurring_transaction(
    request: RecurringTransactionCreateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """创建周期性交易"""
    service = TransactionService(db)
    recurring_tx = await service.create_recurring_transaction(current_user.uuid, request.model_dump())
    return success_response(
        data=recurring_tx,
        message="Recurring transaction created successfully",
    )


@router.get("/recurring/{recurring_id:uuid}")
async def get_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """获取周期性交易详情"""
    service = TransactionService(db)
    recurring_tx = await service.get_recurring_transaction(recurring_id, current_user.uuid)

    if not recurring_tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recurring transaction not found",
        )

    return success_response(
        data=recurring_tx,
        message="Recurring transaction retrieved successfully",
    )


@router.put("/recurring/{recurring_id:uuid}")
async def update_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    request: RecurringTransactionUpdateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """更新周期性交易"""
    service = TransactionService(db)
    recurring_tx = await service.update_recurring_transaction(
        recurring_id, current_user.uuid, request.model_dump(exclude_unset=True)
    )

    if not recurring_tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recurring transaction not found",
        )

    return success_response(
        data=recurring_tx,
        message="Recurring transaction updated successfully",
    )


@router.delete("/recurring/{recurring_id:uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_recurring_transaction(
    recurring_id: UUID,  # UUID from path
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """删除周期性交易"""
    service = TransactionService(db)
    success = await service.delete_recurring_transaction(recurring_id, current_user.uuid)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recurring transaction not found",
        )

    return success_response(
        data=None,
        message="Recurring transaction deleted successfully",
    )


@router.post("/forecast")
async def forecast_cash_flow(
    request: CashFlowForecastRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """现金流预测"""
    service = TransactionService(db)
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


# ============================================================================
# Pending Transaction Confirmation
# ============================================================================


@router.get("/pending")
async def get_pending_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """Get all PENDING transactions for the current user.

    These are auto-generated by recurring rules that require confirmation.
    """
    query = (
        select(Transaction)
        .where(
            Transaction.user_uuid == current_user.uuid,
            Transaction.status == "PENDING",
        )
        .order_by(Transaction.transaction_at.desc())
    )
    result = await db.execute(query)
    transactions = result.scalars().all()

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


@router.post("/{transaction_id:uuid}/confirm")
async def confirm_pending_transaction(
    transaction_id: UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """Confirm a PENDING transaction, changing its status to CONFIRMED."""
    query = select(Transaction).where(
        and_(Transaction.id == transaction_id, Transaction.user_uuid == current_user.uuid)
    )
    result = await db.execute(query)
    tx = result.scalar_one_or_none()

    if not tx:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    if tx.status != "PENDING":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Transaction is not in PENDING status")

    tx.status = "CONFIRMED"
    # Auto-mark associated notification as read
    await _mark_recurring_notification_read(db, current_user.uuid, transaction_id)
    await db.commit()

    return success_response(data={"id": str(tx.id), "status": "CONFIRMED"}, message="Transaction confirmed")


@router.post("/{transaction_id:uuid}/skip")
async def skip_pending_transaction(
    transaction_id: UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_session)],
) -> JSONResponse:
    """Skip (delete) a PENDING transaction."""
    query = select(Transaction).where(
        and_(Transaction.id == transaction_id, Transaction.user_uuid == current_user.uuid)
    )
    result = await db.execute(query)
    tx = result.scalar_one_or_none()

    if not tx:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    if tx.status != "PENDING":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Transaction is not in PENDING status")

    # Auto-mark associated notification as read before deleting the transaction
    await _mark_recurring_notification_read(db, current_user.uuid, transaction_id)
    await db.delete(tx)
    await db.commit()

    return success_response(data=None, message="Transaction skipped")


async def _mark_recurring_notification_read(db: AsyncSession, user_uuid: UUID, transaction_id: UUID) -> None:
    """Mark the recurring_pending notification associated with this transaction as read."""
    from sqlalchemy import update as sa_update

    stmt = (
        sa_update(Notification)
        .where(
            Notification.user_uuid == user_uuid,
            Notification.type == "recurring_pending",
            Notification.is_read == False,  # noqa: E712
            Notification.data["transaction_id"].as_string() == str(transaction_id),
        )
        .values(is_read=True, read_at=func.now())
    )
    await db.execute(stmt)
