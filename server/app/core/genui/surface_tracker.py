"""Per-thread UI surface state for incremental updates."""

from __future__ import annotations

import time
from dataclasses import dataclass, field
from typing import Any
from uuid import UUID


@dataclass
class SurfaceInfo:
    surface_id: str
    session_id: str
    component_type: str
    tool_call_id: str | None
    data: dict[str, Any]
    updated_at: float = field(default_factory=time.time)

    def set_path(self, path: str, value: Any) -> None:
        if path == "/" or not path:
            self.data = value if isinstance(value, dict) else {"value": value}
        else:
            keys = [k for k in path.split("/") if k]
            node = self.data
            for key in keys[:-1]:
                child = node.get(key)
                if not isinstance(child, dict):
                    child = {}
                    node[key] = child
                node = child
            node[keys[-1]] = value
        self.updated_at = time.time()


class SurfaceTracker:
    """Last surface per (session, component). Single-thread use only."""

    def __init__(self) -> None:
        self._by_id: dict[str, SurfaceInfo] = {}
        self._latest: dict[tuple[str, str], str] = {}

    def register(
        self,
        session_id: str | UUID,
        surface_id: str,
        component_type: str,
        data: dict[str, Any],
        tool_call_id: str | None = None,
    ) -> SurfaceInfo:
        info = SurfaceInfo(
            surface_id=surface_id,
            session_id=str(session_id),
            component_type=component_type,
            tool_call_id=tool_call_id,
            data=data,
        )
        self._by_id[surface_id] = info
        self._latest[(str(session_id), component_type)] = surface_id
        return info

    def find_reusable(self, session_id: str | UUID, component_type: str) -> str | None:
        surface_id = self._latest.get((str(session_id), component_type))
        return surface_id if surface_id in self._by_id else None

    def update(self, surface_id: str, path: str, value: Any) -> bool:
        info = self._by_id.get(surface_id)
        if info is None:
            return False
        info.set_path(path, value)
        return True

    def get_data(self, surface_id: str) -> dict[str, Any] | None:
        info = self._by_id.get(surface_id)
        return info.data if info else None
