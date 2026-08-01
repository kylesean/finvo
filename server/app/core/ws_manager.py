"""WebSocket connection manager for real-time notifications.

Manages active WebSocket connections per user, enabling server-side push
of notifications (e.g., @mentions, space activity) to connected clients.
"""

from __future__ import annotations

import asyncio
from typing import Any
from uuid import UUID

import structlog
from fastapi import WebSocket
from starlette.websockets import WebSocketState

logger = structlog.get_logger(__name__)


class ConnectionManager:
    """Manages active WebSocket connections (user_uuid -> WebSocket).

    Supports single connection per user (latest connection wins).
    """

    def __init__(self) -> None:
        self._connections: dict[str, WebSocket] = {}
        self._lock = asyncio.Lock()

    async def connect(self, user_uuid: str, websocket: WebSocket) -> None:
        """Accept and register a WebSocket connection."""
        await websocket.accept()
        async with self._lock:
            # Close existing connection if any (single device per user)
            existing = self._connections.get(user_uuid)
            if existing and existing.client_state == WebSocketState.CONNECTED:
                try:
                    await existing.close(code=4000, reason="New connection")
                except Exception:  # noqa: BLE001
                    pass
            self._connections[user_uuid] = websocket
        logger.info("ws_connected", user_uuid=user_uuid, total=len(self._connections))

    async def disconnect(self, user_uuid: str, websocket: WebSocket | None = None) -> None:
        """Remove a user's connection.

        When ``websocket`` is provided, only remove it if it is still the
        registered connection for this user. This prevents a stale connection's
        teardown (its ``finally`` block) from popping a *newer* live connection
        that was registered after a reconnect.
        """
        async with self._lock:
            if websocket is not None:
                if self._connections.get(user_uuid) is websocket:
                    self._connections.pop(user_uuid, None)
            else:
                self._connections.pop(user_uuid, None)
        logger.info("ws_disconnected", user_uuid=user_uuid, total=len(self._connections))

    async def send_notification(self, user_uuid: str, data: dict[str, Any]) -> bool:
        """Push a notification to a connected user.

        Returns True if message was sent, False if user is not connected.
        """
        websocket = self._connections.get(user_uuid)
        if not websocket:
            return False

        try:
            if websocket.client_state != WebSocketState.CONNECTED:
                await self.disconnect(user_uuid)
                return False
            await websocket.send_json({"type": "notification", "payload": data})
            return True
        except Exception:  # noqa: BLE001
            await self.disconnect(user_uuid)
            return False

    async def broadcast(self, user_uuids: list[str], data: dict[str, Any]) -> int:
        """Push a notification to multiple users. Returns count of successful sends."""
        sent = 0
        for uid in user_uuids:
            if await self.send_notification(uid, data):
                sent += 1
        return sent

    @property
    def active_count(self) -> int:
        return len(self._connections)


# Global singleton instance
ws_manager = ConnectionManager()
