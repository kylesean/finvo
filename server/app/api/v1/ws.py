"""WebSocket endpoint for real-time notification push.

Clients connect via: ws://host/api/ws/notifications?token=<jwt_token>

Protocol:
- Server -> Client: {"type": "notification", "payload": {...}}
- Server -> Client: {"type": "pong"}  (heartbeat response)
- Client -> Server: {"type": "ping"}  (heartbeat)
"""

from __future__ import annotations

import asyncio
import json

import structlog
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from starlette.websockets import WebSocketState

from app.core.ws_manager import ws_manager
from app.utils.auth import verify_token

logger = structlog.get_logger(__name__)

router = APIRouter(tags=["websocket"])

_HEARTBEAT_TIMEOUT = 60  # seconds without message before disconnect


@router.websocket("/ws/notifications")
async def notification_websocket(websocket: WebSocket, token: str = "") -> None:
    """WebSocket endpoint for real-time notifications.

    Authenticates via JWT token in query parameter.
    """
    # 1. Validate JWT token (verify_token raises ValueError on malformed format)
    if not token:
        await websocket.close(code=4001, reason="Missing token")
        return

    try:
        user_uuid = verify_token(token)
    except ValueError:
        user_uuid = None

    if not user_uuid:
        await websocket.close(code=4001, reason="Invalid token")
        return

    # 2. Accept and register connection
    await ws_manager.connect(user_uuid, websocket)

    # 3. Listen for messages (heartbeat) and detect disconnection
    try:
        while True:
            try:
                raw = await asyncio.wait_for(
                    websocket.receive_text(),
                    timeout=_HEARTBEAT_TIMEOUT,
                )
            except TimeoutError:
                # No message received within timeout, close connection
                logger.info("ws_heartbeat_timeout", user_uuid=user_uuid)
                break

            try:
                data = json.loads(raw)
            except (json.JSONDecodeError, TypeError):
                # Non-JSON message — ignore and keep the connection alive
                logger.debug("ws_non_json_message_ignored", user_uuid=user_uuid)
                continue

            # Respond to ping with pong
            if data.get("type") == "ping":
                if websocket.client_state == WebSocketState.CONNECTED:
                    await websocket.send_json({"type": "pong"})
    except WebSocketDisconnect:
        logger.info("ws_client_disconnected", user_uuid=user_uuid)
    except Exception as exc:  # noqa: BLE001
        logger.exception("ws_connection_error", user_uuid=user_uuid, error=str(exc))
    finally:
        await ws_manager.disconnect(user_uuid, websocket)
