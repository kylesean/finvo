"""Multi-device WebSocket connection manager tests.

Locks the multi-device fan-out: a user with several live connections
(phone + tablet + desktop) receives every notification on all sockets,
and one dead socket never kicks the others. The manager's public surface
is user-oriented, so a future Redis pub/sub relay can replace the
in-process fan-out without touching callers.
"""

from __future__ import annotations

from typing import Any

import pytest
from starlette.websockets import WebSocketState

from app.core.ws_manager import ConnectionManager


class FakeWebSocket:
    """Minimal WebSocket stand-in for ConnectionManager behavior tests."""

    def __init__(self, *, dead: bool = False) -> None:
        self.client_state: Any = WebSocketState.DISCONNECTED if dead else WebSocketState.CONNECTED
        self.sent: list[dict[str, Any]] = []
        self.closed = False

    async def accept(self) -> None:
        self.client_state = WebSocketState.CONNECTED

    async def send_json(self, data: dict[str, Any]) -> None:
        self.sent.append(data)

    async def close(self, code: int = 1000, reason: str = "") -> None:
        self.closed = True
        self.client_state = WebSocketState.DISCONNECTED


@pytest.mark.asyncio
async def test_multi_device_all_receive_notification() -> None:
    mgr = ConnectionManager()
    phone = FakeWebSocket()
    tablet = FakeWebSocket()
    desktop = FakeWebSocket()

    await mgr.connect("u1", phone)
    await mgr.connect("u1", tablet)
    await mgr.connect("u1", desktop)

    assert mgr.active_count == 3

    ok = await mgr.send_notification("u1", {"msg": "hello"})

    assert ok is True
    assert len(phone.sent) == 1
    assert len(tablet.sent) == 1
    assert len(desktop.sent) == 1
    assert phone.sent[0]["payload"]["msg"] == "hello"


@pytest.mark.asyncio
async def test_second_connection_does_not_kick_first() -> None:
    """Regression: connecting a new device must NOT close existing ones."""
    mgr = ConnectionManager()
    first = FakeWebSocket()
    second = FakeWebSocket()

    await mgr.connect("u1", first)
    await mgr.connect("u1", second)

    assert first.closed is False
    assert mgr.active_count == 2


@pytest.mark.asyncio
async def test_dead_socket_removed_others_still_deliver() -> None:
    mgr = ConnectionManager()
    live = FakeWebSocket()
    dead = FakeWebSocket()

    await mgr.connect("u1", live)
    await mgr.connect("u1", dead)
    # Simulate the connection dropping after registration.
    dead.client_state = WebSocketState.DISCONNECTED

    ok = await mgr.send_notification("u1", {"msg": "hello"})

    assert ok is True
    assert len(live.sent) == 1
    # Dead socket is removed, user entry still holds the live one.
    assert mgr.active_count == 1

    await mgr.disconnect("u1", live)
    assert mgr.active_count == 0


@pytest.mark.asyncio
async def test_disconnect_one_device_keeps_others() -> None:
    mgr = ConnectionManager()
    a = FakeWebSocket()
    b = FakeWebSocket()

    await mgr.connect("u1", a)
    await mgr.connect("u1", b)

    await mgr.disconnect("u1", a)

    assert mgr.active_count == 1
    ok = await mgr.send_notification("u1", {"msg": "still here"})
    assert ok is True
    assert len(b.sent) == 1


@pytest.mark.asyncio
async def test_notification_to_disconnected_user_returns_false() -> None:
    mgr = ConnectionManager()

    assert await mgr.send_notification("nobody", {"msg": "x"}) is False
    assert mgr.active_count == 0


@pytest.mark.asyncio
async def test_broadcast_counts_per_user_not_per_socket() -> None:
    mgr = ConnectionManager()
    await mgr.connect("u1", FakeWebSocket())
    await mgr.connect("u1", FakeWebSocket())
    await mgr.connect("u2", FakeWebSocket())

    assert await mgr.broadcast(["u1", "u2"], {"msg": "all"}) == 2
