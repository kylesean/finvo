"""WebSocket endpoint for real-time notification push.

Clients connect via: ws://host/api/ws/notifications?token=<jwt_token>

Protocol:
- Server -> Client: {"type": "notification", "payload": {...}}
- Server -> Client: {"type": "pong"}  (heartbeat response)
- Client -> Server: {"type": "ping"}  (heartbeat)
"""

from __future__ import annotations

import asyncio

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
    # 1. Validate JWT token
    if not token:
        await websocket.close(code=4001, reason="Missing token")
        return

    user_uuid = verify_token(token)
    if not user_uuid:
        await websocket.close(code=4001, reason="Invalid token")
        return

    # 2. Accept and register connection
    await ws_manager.connect(user_uuid, websocket)

    # 3. Listen for messages (heartbeat) and detect disconnection
    try:
        while True:
            try:
                data = await asyncio.wait_for(
                    websocket.receive_json(),
                    timeout=_HEARTBEAT_TIMEOUT,
                )
                # Respond to ping with pong
                if data.get("type") == "ping":
                    if websocket.client_state == WebSocketState.CONNECTED:
                        await websocket.send_json({"type": "pong"})
            except TimeoutError:
                # No message received within timeout, close connection
                logger.info("ws_heartbeat_timeout", user_uuid=user_uuid)
                break
    except WebSocketDisconnect:
        pass
    except Exception:  # noqa: BLE001
        pass
    finally:
        await ws_manager.disconnect(user_uuid)
