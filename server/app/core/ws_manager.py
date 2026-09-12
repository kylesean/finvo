"""WebSocket connection manager for real-time notifications.

Manages active WebSocket connections per user, enabling server-side push
of notifications (e.g., @mentions, space activity) to connected clients.

Supports multiple concurrent connections per user (multi-device): a user
on phone + tablet + desktop receives the same push on every live socket.
The public surface is user-oriented (``connect`` / ``disconnect`` /
``send_notification`` / ``broadcast``); the in-process fan-out below is an
implementation detail that can be replaced by a Redis pub/sub relay if the
server ever moves to multiple workers — callers stay untouched.
"""

from __future__ import annotations

import asyncio
from contextlib import suppress
from typing import Any

from fastapi import WebSocket
from starlette.websockets import WebSocketState

from app.core.logging import logger


class ConnectionManager:
    """Manages active WebSocket connections (user_uuid -> set of sockets).

    Supports multiple connections per user (one per device); every live
    connection of a user receives each notification.
    """

    def __init__(self) -> None:
        self._connections: dict[str, set[WebSocket]] = {}
        self._lock = asyncio.Lock()

    async def connect(self, user_uuid: str, websocket: WebSocket) -> None:
        """Accept and register a WebSocket connection."""
        await websocket.accept()
        async with self._lock:
            self._connections.setdefault(user_uuid, set()).add(websocket)
        logger.info("ws_connected", user_uuid=user_uuid, total=sum(len(v) for v in self._connections.values()))

    async def disconnect(self, user_uuid: str, websocket: WebSocket | None = None) -> None:
        """Remove a user's connection.

        When ``websocket`` is provided, only that socket is removed; a stale
        connection's teardown (its ``finally`` block) never affects other
        live devices of the same user. When omitted, the user's entry is
        cleared entirely.
        """
        async with self._lock:
            sockets = self._connections.get(user_uuid)
            if sockets is None:
                return
            if websocket is not None:
                sockets.discard(websocket)
                if not sockets:
                    self._connections.pop(user_uuid, None)
            else:
                self._connections.pop(user_uuid, None)
        logger.info("ws_disconnected", user_uuid=user_uuid, total=sum(len(v) for v in self._connections.values()))

    async def send_notification(self, user_uuid: str, data: dict[str, Any]) -> bool:
        """Push a notification to all of a user's live connections.

        Returns True if at least one socket received it, False if the user
        is not connected. Dead sockets are removed individually without
        affecting the user's other devices.
        """
        async with self._lock:
            sockets = list(self._connections.get(user_uuid) or ())
        if not sockets:
            return False

        delivered = False
        for websocket in sockets:
            try:
                if websocket.client_state != WebSocketState.CONNECTED:
                    await self.disconnect(user_uuid, websocket)
                    continue
                await asyncio.wait_for(
                    websocket.send_json({"type": "notification", "payload": data}),
                    timeout=3.0,
                )
                delivered = True
            except Exception:  # noqa: BLE001
                await self.disconnect(user_uuid, websocket)
                with suppress(Exception):
                    await websocket.close(code=1001)
        return delivered

    async def broadcast(self, user_uuids: list[str], data: dict[str, Any]) -> int:
        """Push a notification to multiple users. Returns count of successful sends."""
        # send_notification never raises (it catches internally), so gather is safe.
        results = await asyncio.gather(*(self.send_notification(uid, data) for uid in user_uuids))
        return sum(1 for ok in results if ok)

    @property
    def active_count(self) -> int:
        return sum(len(v) for v in self._connections.values())


# Global singleton instance
ws_manager = ConnectionManager()
