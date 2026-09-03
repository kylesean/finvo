"""SurfaceTracker: last surface per session and component."""

from uuid import uuid4

import pytest

from app.core.genui import SurfaceTracker


def _tracker_with_one(session_id: str, component: str = "TransactionCard") -> tuple[SurfaceTracker, str]:
    tracker = SurfaceTracker()
    surface_id = f"surface_{session_id}_call1"
    tracker.register(session_id, surface_id, component, {"amount": 100.0}, "call1")
    return tracker, surface_id


class TestSurfaceTracker:
    def test_register_stores_surface(self):
        # Arrange
        tracker = SurfaceTracker()
        session_id = str(uuid4())

        # Act
        info = tracker.register(session_id, f"surface_{session_id}_c1", "TransactionCard", {"amount": 100.0}, "c1")

        # Assert
        assert info.component_type == "TransactionCard"
        assert info.data["amount"] == 100.0

    def test_find_reusable_matches_component_only(self):
        # Arrange
        session_id = str(uuid4())
        tracker, surface_id = _tracker_with_one(session_id)

        # Act + Assert
        assert tracker.find_reusable(session_id, "TransactionCard") == surface_id
        assert tracker.find_reusable(session_id, "TransferReceipt") is None
        assert tracker.find_reusable(str(uuid4()), "TransactionCard") is None

    def test_latest_write_wins(self):
        # Arrange
        tracker = SurfaceTracker()
        session_id = str(uuid4())
        tracker.register(session_id, "s1", "TransactionCard", {"amount": 1.0})
        tracker.register(session_id, "s2", "TransactionCard", {"amount": 2.0})

        # Act + Assert
        assert tracker.find_reusable(session_id, "TransactionCard") == "s2"

    def test_update_missing_surface_returns_false(self):
        assert SurfaceTracker().update("missing", "/amount", 1.0) is False

    @pytest.mark.parametrize(
        ("path", "expected"),
        [("/amount", {"amount": 200.0}), ("/user/name", {"user": {"name": "Bob"}})],
    )
    def test_set_path(self, path: str, expected: dict):
        # Arrange
        info_tracker = SurfaceTracker()
        base = {"amount": 100.0} if path == "/amount" else {"user": {"name": "Alice"}}
        info_tracker.register("s", "surf", "C", base)

        # Act
        assert info_tracker.update("surf", path, expected[path.split("/")[-1]] if path == "/amount" else "Bob") is True

        # Assert
        data = info_tracker.get_data("surf")
        assert data is not None
        for key, value in expected.items():
            assert data[key] == value
