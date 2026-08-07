"""Authentication endpoints.

This module provides endpoints for user authentication including:
- Send verification code (email/mobile)
- User registration
- User login
- Token verification and user/session dependencies
"""

from __future__ import annotations

import uuid
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Request
from fastapi.responses import JSONResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi_pagination import Params
from fastapi_pagination.ext.sqlalchemy import apaginate
from sqlalchemy import desc, select

from app.core.aliases import CurrentUser, DbSession
from app.core.config import settings
from app.core.database import get_session_context
from app.core.dependencies import (
    get_redis_client,
    is_token_revoked,
    revoke_token,
)
from app.core.exceptions import AuthorizationError, NotFoundError, ValidationError
from app.core.limiter import limiter
from app.core.logging import bind_context, logger
from app.core.responses import ResponseEnvelope, pagination_payload, success_response
from app.models.session import Session
from app.models.user import User
from app.repositories.session_repository import SessionRepository
from app.schemas.auth import (
    AuthResponse,
    LoginRequest,
    RegisterRequest,
    SendCodeRequest,
    UpdateSessionNameRequest,
    UserInfo,
)
from app.services.auth_service import AuthService
from app.utils.auth_utils import (
    create_access_token,
    create_refresh_token,
    is_refresh_token,
    verify_token_allow_expired,
)
from app.utils.sanitization import sanitize_string

router = APIRouter(prefix="/auth", tags=["auth"])
security = HTTPBearer()


async def get_authorized_session(
    session_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> Session:
    """Get session with ownership verification.

    This function verifies both:
    1. The session exists in the database
    2. The current user owns the session

    Args:
        session_id: The session ID from path/body parameter
        current_user: The authenticated user from access token
        db: Database session

    Returns:
        ChatSession: The verified session

    Raises:
        NotFoundError: 404 if session not found
        AuthorizationError: 403 if access denied
    """
    # Verify session exists using repository
    repo = SessionRepository(db)
    session = await repo.get(session_id)
    if session is None:
        logger.error("session_not_found", session_id=session_id)
        raise NotFoundError("Session")

    # Verify ownership
    if session.user_uuid != current_user.uuid:
        logger.warning(
            "session_access_denied",
            session_id=session_id,
            session_owner=session.user_uuid,
            requesting_user=current_user.uuid,
        )
        raise AuthorizationError("Access denied to this session")

    # Bind user_uuid to logging context
    bind_context(user_uuid=session.user_uuid)

    return session


def _build_user_info(user: User) -> UserInfo:
    """Build the auth response ``UserInfo`` from a user model (shared by register/login)."""
    return UserInfo(
        id=user.uuid,
        email=user.email,
        mobile=user.mobile,
        username=user.username or user.email or user.mobile or f"user_{str(user.uuid)[:8]}",
        avatarUrl=user.avatar_url,
        createdAt=user.created_at.isoformat(),
        updatedAt=user.updated_at.isoformat() if user.updated_at else None,
        clientLastLoginAt=user.last_login_at.isoformat() if user.last_login_at else None,
    )


@router.post("/send-code", response_model=ResponseEnvelope[dict[str, Any]])
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["send_code"][0])
async def send_code(
    request: Request,
    data: SendCodeRequest,
    db: DbSession,
) -> JSONResponse:
    """Send verification code to email or mobile.

    Args:
        request: FastAPI request object
        data: Send code request data
        db: Database session

    Returns:
        JSONResponse: Unified response format with code=0 on success

    Raises:
        BusinessError: If account already exists (handled by exception handler)
    """
    auth_service = AuthService(db)

    # Send verification code
    await auth_service.send_verification_code(
        account_type=data.type,
        account=data.account,
    )

    logger.info(
        "verification_code_request_accepted",
        account_type=data.type,
        account=data.account[:3] + "***",  # Mask account for privacy
    )

    return success_response(message="Verification code sent successfully")


@router.post("/register", response_model=ResponseEnvelope[dict[str, Any]])
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["register"][0])
async def register(
    request: Request,
    data: RegisterRequest,
    db: DbSession,
) -> JSONResponse:
    """Register a new user.

    Args:
        request: FastAPI request object
        data: Registration request data
        db: Database session

    Returns:
        JSONResponse: Unified response with token and user info (code=0 on success)

    Raises:
        AppException: propagated to the global app_exception_handler in main.py.
    """
    auth_service = AuthService(db)

    # Get client IP
    client_ip = request.client.host if request.client else None

    # Register user
    user = await auth_service.register(
        account_type=data.type,
        account=data.account,
        password=data.password,
        code=data.code,
        timezone=data.timezone,
        client_ip=client_ip,
        locale=data.locale,
    )

    # Generate token using user UUID
    token_obj = create_access_token(user.uuid)
    token = token_obj.access_token

    # Build user info response
    user_info = _build_user_info(user)

    logger.info(
        "user_registered",
        user_uuid=user.uuid,
        account_type=data.type,
        account=data.account[:3] + "***",
    )

    # Return unified format
    refresh = create_refresh_token(user.uuid)
    auth_response = AuthResponse(
        token=token,
        refresh_token=refresh.access_token,
        user=user_info,
    )
    return success_response(data=auth_response.model_dump(), message="Registration successful")


@router.post("/login", response_model=ResponseEnvelope[dict[str, Any]])
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["login"][0])
async def login(
    request: Request,
    data: LoginRequest,
    db: DbSession,
) -> JSONResponse:
    """User login.

    Args:
        request: FastAPI request object
        data: Login request data
        db: Database session

    Returns:
        JSONResponse: Unified response with token and user info (code=0 on success)

    Raises:
        AppException: propagated to the global app_exception_handler in main.py.
    """
    auth_service = AuthService(db)

    # Get client IP
    client_ip = request.client.host if request.client else None

    # Login user (returns tuple of user and token)
    user, token = await auth_service.login(
        account_type=data.type,
        account=data.account,
        password=data.password,
        timezone=data.timezone,
        client_ip=client_ip,
    )

    # Build user info response
    user_info = _build_user_info(user)

    logger.info(
        "user_logged_in",
        user_uuid=str(user.uuid),
        account_type=data.type,
        account=data.account[:3] + "***",
    )

    # Return unified format
    refresh = create_refresh_token(user.uuid)
    auth_response = AuthResponse(
        token=token,
        refresh_token=refresh.access_token,
        user=user_info,
    )
    return success_response(data=auth_response.model_dump(), message="Login successful")


@router.post("/session", response_model=ResponseEnvelope[dict[str, Any]])
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["session"][0])
async def create_session(
    request: Request,
    user: CurrentUser,
) -> JSONResponse:
    """Create a new chat session for the authenticated user.

    Args:
        request: FastAPI request object (used by the rate limiter)
        user: The authenticated user

    Returns:
        Unified response with session data
    """
    try:
        # Single-statement write; the context manager owns the commit
        # (transaction boundary lives in the data layer, not the route).
        async with get_session_context(auto_commit=True) as db:
            # Generate a unique session ID
            session_id = uuid.uuid4()

            # Create session in database with default name "New Chat"
            repo = SessionRepository(db)
            session = await repo.create(session_id, user.uuid, name="New Chat")

        logger.info(
            "session_created",
            session_id=session_id,
            user_uuid=user.uuid,
            name=session.name,
        )

        return success_response(
            data={
                "session_id": session_id,
                "name": session.name,
            },
            message="Session created successfully",
        )
    except ValueError as ve:
        logger.error("session_creation_validation_failed", error=str(ve), user_uuid=user.uuid, exc_info=True)
        raise ValidationError(str(ve))


@router.patch("/session/{session_id}/name", response_model=ResponseEnvelope[dict[str, Any]])
async def update_session_name(
    session_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
    payload: UpdateSessionNameRequest,
) -> JSONResponse:
    """Update a session's name.

    Args:
        session_id: The ID of the session to update
        payload: JSON body containing the new name
        current_user: The authenticated user
        db: Database session

    Returns:
        JSONResponse: Unified response with the updated session information
    """
    # Verify session ownership (this will use the same db session via Depends)
    session = await get_authorized_session(session_id, current_user, db)

    # Sanitize name
    sanitized_name = sanitize_string(payload.name)

    # Update the session name; the context manager owns the commit
    async with get_session_context(auto_commit=True) as db:
        repo = SessionRepository(db)
        updated_session = await repo.update_name(session.id, sanitized_name)
        if updated_session is None:
            raise NotFoundError("Session")

    logger.info(
        "session_name_updated",
        session_id=session.id,
        user_uuid=current_user.uuid,
        new_name=sanitized_name,
    )

    return success_response(
        data={
            "session_id": session.id,
            "name": updated_session.name,
        },
        message="Session name updated",
    )


@router.delete("/session/{session_id}", response_model=ResponseEnvelope[dict[str, Any]])
async def delete_session(
    session_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> JSONResponse:
    """Delete a session for the authenticated user.

    Deletion is best-effort across two stores that cannot share one transaction:
    1. Verify ownership and delete session metadata from sessions table
       (request-scoped SQLAlchemy session, committed last)
    2. Delete LangGraph checkpoints (checkpoint_blobs, checkpoint_writes,
       checkpoints) and searchable_messages via the agent's own connection

    Note: The checkpoint cleanup and the session-row delete are NOT atomic —
    if the process dies between steps, orphan checkpoints may remain.

    Note: Attachments are NOT deleted as they may be reused.

    Args:
        session_id: The ID of the session to delete
        current_user: The authenticated user
        db: Request-scoped database session

    Returns:
        Success response
    """
    from app.api.v1.chatbot import get_agent

    # Verify session ownership using the request-scoped db session
    repo = SessionRepository(db)
    session = await repo.get(session_id)
    if session is None:
        raise NotFoundError("Session")

    if session.user_uuid != current_user.uuid:
        logger.warning(
            "session_delete_unauthorized",
            session_id=session_id,
            user_uuid=current_user.uuid,
            owner_uuid=session.user_uuid,
        )
        raise AuthorizationError("Access denied to this session")

    # 1. Use the chatbot agent to cascade delete history
    # This handles LangGraph checkpoints (via official API) and searchable_messages
    chatbot_agent = get_agent()
    await chatbot_agent.delete_session_history(session.id)

    # 2. Delete the session metadata; the context manager owns the commit
    async with get_session_context(auto_commit=True) as db:
        repo = SessionRepository(db)
        await repo.delete(session.id)

    logger.info(
        "session_deleted_with_history",
        session_id=session.id,
        user_uuid=current_user.uuid,
    )

    return success_response(message="Session deleted")


@router.post("/logout", response_model=ResponseEnvelope[dict[str, Any]])
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["login"][0])
async def logout(
    request: Request,
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
    redis_client: Annotated[Any, Depends(get_redis_client)],
) -> JSONResponse:
    """Revoke the current access token (jti blacklist).

    The token stays blocked until it would have expired anyway, so no explicit
    cleanup job is needed. Requires a valid bearer token.
    """
    revoked = await revoke_token(redis_client, credentials.credentials)
    return success_response(
        message="Logged out successfully" if revoked else "Logged out",
        data={"revoked": revoked},
    )


@router.post("/refresh", response_model=ResponseEnvelope[dict[str, Any]])
@limiter.limit(settings.RATE_LIMIT_ENDPOINTS["login"][0])
async def refresh_access_token_endpoint(
    request: Request,
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
    redis_client: Annotated[Any, Depends(get_redis_client)],
) -> JSONResponse:
    """Refresh tokens using a dedicated refresh token.

    Only refresh-type tokens are accepted (access tokens are rejected), so a
    leaked access token cannot be used to mint new ones. Revoked refresh tokens
    are rejected. Returns a new access token and a rotated refresh token.
    """
    old_token = credentials.credentials

    # Reject access tokens — only refresh-type tokens may be refreshed.
    if not is_refresh_token(old_token):
        raise AuthorizationError("Invalid or expired refresh token")

    if await is_token_revoked(redis_client, old_token):
        raise AuthorizationError("Token has been revoked")

    subject = verify_token_allow_expired(old_token)
    if subject is None:
        raise AuthorizationError("Invalid or expired refresh token")

    # Rotate: issue a fresh access token and a new refresh token (the old one
    # is implicitly invalidated by rotation on the client side).
    new_access = create_access_token(subject)
    new_refresh = create_refresh_token(subject)

    logger.info(
        "token_refreshed",
        user_uuid=subject,
        endpoint="auth_refresh",
        rotated=True,
    )

    return success_response(
        data={
            "token": new_access.access_token,
            "refresh_token": new_refresh.access_token,
        },
        message="Token refreshed",
    )


@router.get("/sessions", response_model=ResponseEnvelope[dict[str, Any]])
async def get_user_sessions(
    user: CurrentUser,
    db: DbSession,
    params: Annotated[Params, Depends()],
) -> JSONResponse:
    """Get paginated session list for the authenticated user.

    This endpoint returns sessions with pagination support in unified response format.
    Use query parameters `page` (default: 1) and `size` (default: 50) to control pagination.

    Args:
        user: The authenticated user
        db: Database session
        params: Pagination parameters (injected by fastapi-pagination)

    Returns:
        JSONResponse: Unified response with paginated sessions
    """
    # Build query for user's sessions, ordered by most recent first
    query = SessionRepository(db).query_for_user(user.uuid)

    # Use fastapi-pagination to paginate the query
    page_result = await apaginate(
        db,
        query,
        params=params,
        transformer=lambda items: [
            {
                "session_id": session.id,
                "name": session.name or "",
                # Use standard ISO 8601 format: replace +00:00 with Z for UTC
                "created_at": (session.created_at.isoformat().replace("+00:00", "Z") if session.created_at else ""),
                "updated_at": (session.updated_at.isoformat().replace("+00:00", "Z") if session.updated_at else ""),
            }
            for session in items
        ],
    )

    # Wrap fastapi-pagination result in unified response format
    return success_response(
        data=pagination_payload(
            items=page_result.items,
            page=page_result.page,
            size=page_result.size,
            total=page_result.total,
            pages=page_result.pages,
        ),
        message="Sessions retrieved successfully",
    )
