"""Map tool results to GenUI component types."""

from typing import Any


class ComponentDetector:
    @staticmethod
    def detect(tool_result: Any) -> str | None:
        if not isinstance(tool_result, dict):
            return None
        component = tool_result.get("componentType")
        return component if isinstance(component, str) and component else None

    @staticmethod
    def is_success(tool_result: Any) -> bool:
        if not isinstance(tool_result, dict):
            return True
        return bool(tool_result.get("success", True))
