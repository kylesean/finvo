"""TextFilterPolicy - Text Filtering Strategy Pattern Implementation

Responsibilities:
- Determines whether to suppress AI text output
- Controls text suppression based on node type and tool metadata

Design Patterns:
- Strategy Pattern
- Composite Pattern
"""

from abc import ABC, abstractmethod
from typing import Any


class TextFilterPolicy(ABC):
    """Abstract base class for text filtering policies.

    Subclasses implement should_suppress() to define specific suppression policies.
    """

    @abstractmethod
    def should_suppress(self, node_name: str, metadata: dict[str, Any]) -> bool:
        """Determines whether text output should be suppressed.

        Args:
            node_name: LangGraph node name
            metadata: Message metadata

        Returns:
            True if output should be suppressed (no text output emitted)
        """
        ...


class NeverSuppressPolicy(TextFilterPolicy):
    """Never suppress policy (default behavior)."""

    def should_suppress(self, node_name: str, metadata: dict[str, Any]) -> bool:
        """Determines that text output should never be suppressed."""
        return False


class DirectExecuteSilentPolicy(TextFilterPolicy):
    """Direct execute node suppression policy.

    Design rationale:
    - direct_execute is a direct tool execution node in GenUI atomic mode
    - User has completed interaction on UI, AI does not need text explanation
    - Let UI components present the outcome directly
    """

    def should_suppress(self, node_name: str, metadata: dict[str, Any]) -> bool:
        """Suppresses output if the originating node is 'direct_execute'."""
        return node_name == "direct_execute"


class SilentToolPolicy(TextFilterPolicy):
    """Silent tool policy.

    Design rationale:
    - Executions for certain tools (e.g. bash, read_file) do not require AI text output
    - Tool execution results sufficiently convey intent

    Note: Used in conjunction with ToolMetadata.silent_mode
    """

    # Silent tools set
    _SILENT_TOOLS = {"bash", "ls", "read_file", "write_file", "write_todos", "execute"}

    def __init__(self, additional_tools: set[str] | None = None):
        self._silent_tools = self._SILENT_TOOLS.copy()
        if additional_tools:
            self._silent_tools.update(additional_tools)

    def should_suppress(self, node_name: str, metadata: dict[str, Any]) -> bool:
        """Suppresses output if the tool executed is marked as silent."""
        current_tool = metadata.get("current_tool_name")
        return current_tool in self._silent_tools if current_tool else False


class CompositeTextFilterPolicy(TextFilterPolicy):
    """Composite text filtering policy.

    Executes multiple policies in order; returns True if any policy matches.
    """

    def __init__(self, policies: list[TextFilterPolicy] | None = None):
        self._policies = policies or []

    def add_policy(self, policy: TextFilterPolicy) -> "CompositeTextFilterPolicy":
        """Add policy (fluent interface)."""
        self._policies.append(policy)
        return self

    def should_suppress(self, node_name: str, metadata: dict[str, Any]) -> bool:
        """Suppresses output if any sub-policy determines it should be suppressed."""
        return any(p.should_suppress(node_name, metadata) for p in self._policies)


class DefaultTextFilterPolicy(CompositeTextFilterPolicy):
    """Default text filtering policy.

    Composes:
    1. DirectExecuteSilentPolicy - Suppresses direct_execute node text
    """

    def __init__(self) -> None:
        super().__init__(
            [
                DirectExecuteSilentPolicy(),
            ]
        )
