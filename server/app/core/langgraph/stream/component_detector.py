"""ComponentDetector - Unified GenUI Component Type Detector

Responsibilities:
- Detects GenUI component types from tool execution results
- Applies business-level component override rules
- Consolidates component detection logic across streaming and history

Design Patterns:
- Utility class with static strategy methods
"""

from typing import Any, cast


class ComponentDetector:
    """Data-driven GenUI Component Detector.

    Unified component detection logic:
    1. EventGenerator.process_updates_chunk (direct_execute)
    2. EventGenerator.process_updates_chunk (tools)
    3. SimpleLangChainAgent.get_detailed_history

    Detection Priority:
    1. componentType - Explicit component key (recommended)
    2. _genui_component - Compatibility fallback key
    3. type - Heuristic detection (when satisfying naming conventions)
    """

    # Business-level component override rules
    _BUSINESS_OVERRIDES = {
        # (tool_name, condition_key) -> target_component
        ("create_transaction", "transfer_info"): "TransferReceipt",
        ("execute_transfer", "transfer_info"): "TransferReceipt",
    }

    @staticmethod
    def detect(tool_result: Any) -> str | None:
        """Detect component type from tool result dictionary.

        Args:
            tool_result: Execution result dictionary from tool

        Returns:
            Component type string (e.g. "TransactionReceipt") or None if undetected
        """
        if not isinstance(tool_result, dict):
            return None

        # Priority 1: Explicit field
        component_type = tool_result.get("componentType")
        if component_type:
            return cast(str, component_type)

        # Priority 2: Compatibility field
        component_type = tool_result.get("_genui_component")
        if component_type:
            return cast(str, component_type)

        # Priority 3: Heuristic detection on type field
        type_value = tool_result.get("type")
        if ComponentDetector._is_valid_component_name(type_value):
            return type_value

        return None

    @staticmethod
    def detect_with_overrides(
        tool_result: Any,
        tool_name: str | None,
    ) -> str | None:
        """Detect component type and apply business override rules.

        Args:
            tool_result: Tool execution result
            tool_name: Tool name

        Returns:
            Final component type string or None
        """
        base_component = ComponentDetector.detect(tool_result)

        if not base_component:
            return None

        # Apply business override rules
        if isinstance(tool_result, dict):
            for (target_tool, condition_key), override_component in ComponentDetector._BUSINESS_OVERRIDES.items():
                if tool_name == target_tool and tool_result.get(condition_key):
                    return override_component

        return base_component

    @staticmethod
    def is_successful_result(tool_result: Any) -> bool:
        """Check whether tool result represents successful execution.

        Failed tool calls should not render UI components.

        Args:
            tool_result: Tool execution result

        Returns:
            True if execution succeeded or status unspecified
        """
        if not isinstance(tool_result, dict):
            return True
        return bool(tool_result.get("success", True))

    @staticmethod
    def _is_valid_component_name(value: Any) -> bool:
        """Heuristic validation of potential component name.

        Rules:
        - Must be string
        - Length > 3 (excluding "id", "ok", etc.)
        - Not ALL CAPS (excluding "SUCCESS", "TRANSFER", etc.)
        - Starts with uppercase letter (CamelCase convention)

        Args:
            value: Candidate value to validate

        Returns:
            True if value conforms to component naming rules
        """
        if not isinstance(value, str):
            return False
        if len(value) <= 3:
            return False
        if value.isupper():
            return False
        if not value[0].isupper():
            return False
        return True
