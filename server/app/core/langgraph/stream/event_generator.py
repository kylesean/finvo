"""EventGenerator - Pure Event Generator

Responsibilities:
- Converts LangGraph stream events into GenUI protocol events
- Excludes strategy decision logic (encapsulated in RenderPolicy, TextFilterPolicy)
- Excludes component detection logic (encapsulated in ComponentDetector)

Design Principles:
- Single Responsibility: Event format transformation
- Stateless: Minimizes internal state tracking
"""

import json
import time
import uuid
from collections.abc import AsyncGenerator
from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from langchain_core.messages import AIMessage, ToolMessage
from langgraph.types import Command

from app.core.genui import SurfaceTracker
from app.core.langgraph.stream.component_detector import ComponentDetector
from app.core.logging import logger
from app.schemas.genui import GenUIEvent

# Tool-result fields that may carry sensitive financial/personal details and
# must be redacted before the result is written to logs.
_SENSITIVE_RESULT_KEYS: frozenset[str] = frozenset(
    {
        "account_number",
        "account_no",
        "address",
        "card",
        "card_number",
        "comment",
        "description",
        "email",
        "iban",
        "memo",
        "mobile",
        "name",
        "note",
        "notes",
        "pan",
        "phone",
        "raw_input",
        "remark",
    }
)


def _sanitize_tool_result_for_log(value: Any, depth: int = 0) -> Any:
    """Recursively redact sensitive fields of a tool result for log output.

    Financial amounts are preserved; identifying details (account numbers,
    notes, names, contact info) are replaced with a redaction marker. Deeply
    nested or oversized structures are truncated to bound log size.
    """
    if depth > 4:
        return "<truncated>"
    if isinstance(value, dict):
        return {
            k: ("<redacted>" if k.lower() in _SENSITIVE_RESULT_KEYS else _sanitize_tool_result_for_log(v, depth + 1))
            for k, v in value.items()
        }
    if isinstance(value, list):
        return [_sanitize_tool_result_for_log(item, depth + 1) for item in value[:20]]
    if isinstance(value, str) and len(value) > 200:
        return f"{value[:200]}..."
    return value


class EventGenerator:
    """GenUI Event Generator.

    Converts LangGraph stream output into GenUI protocol events.

    Responsibilities:
    - Event format transformation
    - Surface ID generation
    - Timestamp tracking
    - Render policy decisions (RenderPolicy)
    - Text filter decisions (TextFilterPolicy)
    """

    def __init__(self, surface_tracker: SurfaceTracker | None = None) -> None:
        # Tool call timing tracking (for duration_ms calculation)
        self._tool_start_times: dict[str, float] = {}
        # Tool ID to name mapping
        self._tool_id_to_name: dict[str, str] = {}
        # Processed tool call IDs (prevents duplicate tool_call_start events)
        self._processed_tool_calls: set[str] = set()
        # Accumulated streaming AI response parts (for history recording)
        self._ai_response_parts: list[str] = []
        # Surface tracker (for incremental updates and Surface reuse)
        self._surface_tracker = surface_tracker or SurfaceTracker()

    def reset(self) -> None:
        """Reset state (invoked prior to each new stream request)."""
        self._tool_start_times.clear()
        self._tool_id_to_name.clear()
        self._processed_tool_calls.clear()
        self._ai_response_parts.clear()

    def get_collected_response(self) -> str:
        """Obtain accumulated AI response text."""
        return "".join(self._ai_response_parts)

    # =========================================================================
    # Message Stream Event Generation
    # =========================================================================

    async def process_message_chunk(
        self,
        chunk: tuple[Any, ...],
        session_id: UUID,
    ) -> AsyncGenerator[GenUIEvent]:
        """Process stream chunk from messages mode.

        Args:
            chunk: (message_chunk, metadata) tuple
            session_id: Session ID

        Yields:
            GenUIEvent events
        """
        msg_chunk, _ = chunk

        # Skip ToolMessage (handled in updates mode)
        if isinstance(msg_chunk, ToolMessage):
            return

        # 1. Process text content
        if msg_chunk.content:
            async for event in self._process_text_content(msg_chunk.content):
                yield event

        # 2. Process tool call intents
        if isinstance(msg_chunk, AIMessage) and hasattr(msg_chunk, "tool_call_chunks"):
            tool_chunks = getattr(msg_chunk, "tool_call_chunks", None)
            if tool_chunks:
                async for event in self._process_tool_call_chunks(
                    tool_chunks,
                    session_id,
                ):
                    yield event

    async def _process_text_content(
        self,
        content: Any,
    ) -> AsyncGenerator[GenUIEvent]:
        """Process text content."""
        if isinstance(content, str):
            if content:
                self._ai_response_parts.append(content)
                yield GenUIEvent(type="text_delta", content=content)

        elif isinstance(content, list):
            for item in content:
                if isinstance(item, dict):
                    item_type = item.get("type")
                    item_text = item.get("text", "")

                    if item_type == "text" and item_text:
                        self._ai_response_parts.append(item_text)
                        yield GenUIEvent(type="text_delta", content=item_text)

                    elif item_type == "reasoning_content" and item_text:
                        yield GenUIEvent(
                            type="reasoning_delta",
                            content=item_text,
                            metadata={"status": "thinking"},
                        )

                elif isinstance(item, str):
                    self._ai_response_parts.append(item)
                    yield GenUIEvent(type="text_delta", content=item)

    async def _process_tool_call_chunks(
        self,
        tool_call_chunks: list[dict[str, Any]],
        session_id: UUID,
    ) -> AsyncGenerator[GenUIEvent]:
        """Process tool call chunks.

        Emits tool_call_start events notifying client of tool execution start.
        """
        active_calls: dict[int, dict[str, Any]] = {}

        for tc_chunk in tool_call_chunks:
            index = tc_chunk.get("index")
            if index is None:
                continue

            if index not in active_calls:
                active_calls[index] = {"id": None, "name": None}

            curr = active_calls[index]
            if tc_chunk.get("id"):
                curr["id"] = tc_chunk["id"]
            if tc_chunk.get("name"):
                curr["name"] = tc_chunk["name"]

            tool_id = curr["id"]
            tool_name = curr["name"]

            # First encounter of complete tool call
            if tool_id and tool_name and tool_id not in self._processed_tool_calls:
                self._processed_tool_calls.add(tool_id)
                self._tool_start_times[tool_id] = time.time()
                self._tool_id_to_name[tool_id] = tool_name

                # Emit tool_call_start event
                yield GenUIEvent(
                    type="tool_call_start",
                    data={
                        "id": tool_id,
                        "name": tool_name,
                        "timestamp": datetime.now(UTC).isoformat(),
                    },
                )

    # =========================================================================
    # Updates Stream Event Generation
    # =========================================================================

    async def process_updates_chunk(
        self,
        chunk: dict[str, Any],
        session_id: UUID,
    ) -> AsyncGenerator[GenUIEvent]:
        """Process stream chunk from updates mode.

        Args:
            chunk: {node_name: node_output} dictionary
            session_id: Session ID

        Yields:
            GenUIEvent events
        """
        for node_name, node_output in chunk.items():
            if node_name.startswith("__"):
                continue

            # Process direct_execute node
            if node_name == "direct_execute":
                result_data = node_output.get("direct_execute_result")
                if result_data and result_data.get("success"):
                    # Honor the surface_id the direct_execute node persisted (from
                    # the client's tool_params); without it, every turn would mint a
                    # brand-new random surface and in-place component updates break.
                    client_surface_id = result_data.get("surface_id")
                    async for event in self._emit_component_events(
                        tool_result=result_data.get("data", {}),
                        tool_name=result_data.get("tool_name", ""),
                        session_id=session_id,
                        tool_call_id=None,
                        surface_id=client_surface_id,
                    ):
                        yield event
                continue

            # Process tools node
            if node_name == "tools":
                async for event in self._process_tools_node(node_output, session_id):
                    yield event

    async def _process_tools_node(
        self,
        node_output: Any,
        session_id: UUID,
    ) -> AsyncGenerator[GenUIEvent]:
        """Process tools node output.

        LangGraph ToolNode._combine_tool_outputs may return:
        1. dict: {"messages": [ToolMessage, ...]}
        2. list[ToolMessage]: Direct message list
        3. list[Command | dict]: Mixed list when tools return Command objects
        """
        messages = self._extract_tool_messages_from_node_output(node_output)

        for msg in messages:
            tool_name, tool_call_id = self._extract_tool_info(msg)
            duration_ms = self._calculate_duration(tool_call_id)
            tool_result = self._extract_tool_result(msg)

            is_success = ComponentDetector.is_successful_result(tool_result)
            logger.info(
                "langgraph_tool_execution_trace",
                tool_name=tool_name,
                tool_call_id=tool_call_id,
                duration_ms=duration_ms,
                is_success=is_success,
            )
            logger.debug(
                "langgraph_tool_result_preview",
                tool_name=tool_name,
                tool_call_id=tool_call_id,
                tool_result_preview=json.dumps(
                    _sanitize_tool_result_for_log(tool_result), ensure_ascii=False, default=str
                )[:300],
            )
            yield GenUIEvent(
                type="tool_call_end",
                data={
                    "id": tool_call_id or f"call_{tool_name}",
                    "name": tool_name,
                    "status": "success" if is_success else "error",
                    "duration_ms": duration_ms,
                    "result": json.dumps(tool_result, indent=2, ensure_ascii=False, default=str)
                    if isinstance(tool_result, dict)
                    else str(tool_result),
                    "error": tool_result.get("error") if isinstance(tool_result, dict) else None,
                },
            )

            # Emit UI component events
            async for event in self._emit_component_events(
                tool_result=tool_result,
                tool_name=tool_name,
                session_id=session_id,
                tool_call_id=tool_call_id,
            ):
                yield event

    def _extract_tool_messages_from_node_output(self, node_output: Any) -> list[Any]:
        """Extract ToolMessage instances from tools node output."""
        messages: list[Any] = []

        if isinstance(node_output, dict):
            messages = node_output.get("messages", [])

        elif isinstance(node_output, list):
            for item in node_output:
                if self._is_tool_message(item):
                    messages.append(item)
                elif isinstance(item, dict):
                    messages.extend(item.get("messages", []))
                elif isinstance(item, Command):
                    update = item.update
                    if isinstance(update, dict):
                        cmd_messages = update.get("messages", [])
                        messages.extend(cmd_messages)

        return messages

    async def _emit_component_events(
        self,
        tool_result: Any,
        tool_name: str,
        session_id: UUID,
        tool_call_id: str | None,
        surface_id: str | None = None,
    ) -> AsyncGenerator[GenUIEvent]:
        """Generate UI component events (a2ui_message).

        GenUI Architecture (A2UI protocol v0.9):
        1. Check if reusable Surface exists for this component type
        2. If reusable: emit UpdateDataModel for changed fields only
        3. If new: emit CreateSurface + UpdateComponents (flat v0.9 format)

        Args:
            tool_result: Tool execution result (data payload)
            tool_name: Name of the executed tool
            session_id: Chat session ID
            tool_call_id: Tool call ID (used to derive a surface id)
            surface_id: Optional explicit surface id from the client (direct_execute);
                when given it is used verbatim instead of deriving a new one.
        """
        from app.core.genui_protocol import (
            CreateSurface,
            CreateSurfacePayload,
            UpdateComponents,
            UpdateComponentsPayload,
            UpdateDataModel,
            UpdateDataModelPayload,
            V09Component,
        )

        component_name = ComponentDetector.detect_with_overrides(tool_result, tool_name)

        logger.debug(
            "component_detection",
            tool_name=tool_name,
            detected_component=component_name,
            has_component_type="componentType" in tool_result if isinstance(tool_result, dict) else False,
            result_keys=list(tool_result.keys()) if isinstance(tool_result, dict) else None,
        )

        if not component_name:
            return

        if not ComponentDetector.is_successful_result(tool_result):
            return

        # Check for reusable Surface
        existing_surface_id = self._surface_tracker.find_reusable_surface(
            session_id=str(session_id),
            component_type=component_name,
        )

        if existing_surface_id and self._is_incremental_update(tool_result):
            logger.info(
                "reusing_surface_with_incremental_update",
                surface_id=existing_surface_id,
                component=component_name,
            )

            changes = self._extract_data_changes(existing_surface_id, tool_result)
            for path, value in changes:
                data_update_msg = UpdateDataModel(
                    updateDataModel=UpdateDataModelPayload(
                        surfaceId=existing_surface_id,
                        path=path,
                        value=value,
                    )
                )
                yield GenUIEvent(type="a2ui_message", data=data_update_msg.model_dump())
                self._surface_tracker.update_surface_data(existing_surface_id, path, value)
            return

        # Create new Surface
        if not tool_call_id and not surface_id:
            logger.warning(
                "missing_tool_call_id_for_component",
                tool_name=tool_name,
                component=component_name,
            )
            tool_call_id = uuid.uuid4().hex[:8]

        surface_id = surface_id or f"surface_{session_id}_{tool_call_id}"

        logger.info(
            "emitting_genui_component",
            tool_name=tool_name,
            component=component_name,
            tool_call_id=tool_call_id,
            surface_id=surface_id,
        )

        tracker_data = {**tool_result, "_surfaceId": surface_id} if isinstance(tool_result, dict) else tool_result

        self._surface_tracker.register_surface(
            session_id=str(session_id),
            surface_id=surface_id,
            component_type=component_name,
            data=tracker_data,
            tool_call_id=tool_call_id,
        )

        create_msg = CreateSurface(createSurface=CreateSurfacePayload(surfaceId=surface_id))
        yield GenUIEvent(type="a2ui_message", data=create_msg.model_dump())

        clean_props = (
            {k: v for k, v in tool_result.items() if not k.startswith("_")}
            if isinstance(tool_result, dict)
            else tool_result
        )

        flat_component = {**clean_props, "id": "root", "component": component_name}
        comp = V09Component.model_validate(flat_component)
        update_msg = UpdateComponents(
            updateComponents=UpdateComponentsPayload(surfaceId=surface_id, components=[comp])
        )
        yield GenUIEvent(type="a2ui_message", data=update_msg.model_dump())

    def _is_incremental_update(self, tool_result: Any) -> bool:
        """Check if tool result should trigger incremental update."""
        if not isinstance(tool_result, dict):
            return False

        if tool_result.get("_intent") == "update":
            return True
        if tool_result.get("_incremental_update"):
            return True

        return False

    def _extract_data_changes(
        self,
        surface_id: str,
        new_data: dict[str, Any],
    ) -> list[tuple[str, Any]]:
        """Extract changed fields between existing surface data and new data."""
        existing_data = self._surface_tracker.get_surface_data(surface_id) or {}
        changes: list[tuple[str, Any]] = []

        for key, new_value in new_data.items():
            if key.startswith("_"):
                continue
            if key not in existing_data or existing_data[key] != new_value:
                changes.append((f"/{key}", new_value))

        return changes

    # =========================================================================
    # Helper Methods
    # =========================================================================

    def _is_tool_message(self, msg: Any) -> bool:
        """Check if message is a ToolMessage."""
        return isinstance(msg, ToolMessage) or (isinstance(msg, dict) and msg.get("role") == "tool")

    def _extract_tool_info(self, msg: Any) -> tuple[str, str | None]:
        """Extract tool name and tool_call_id from message."""
        if isinstance(msg, dict):
            return msg.get("name", ""), msg.get("tool_call_id")
        return getattr(msg, "name", ""), getattr(msg, "tool_call_id", None)

    def _extract_tool_result(self, msg: Any) -> Any:
        """Extract tool execution result from message."""
        tool_result = getattr(msg, "artifact", None)
        if tool_result is None and isinstance(msg, dict):
            tool_result = msg.get("artifact")

        if tool_result is not None:
            return tool_result

        msg_content = getattr(msg, "content", None)
        if msg_content is None and isinstance(msg, dict):
            msg_content = msg.get("content", "")

        if isinstance(msg_content, dict):
            return msg_content
        elif isinstance(msg_content, str):
            try:
                return json.loads(msg_content)
            except (json.JSONDecodeError, TypeError):
                return {"result": msg_content}
        else:
            return {"result": str(msg_content)}

    def _calculate_duration(self, tool_call_id: str | None) -> int | None:
        """Calculate tool execution duration in milliseconds."""
        if not tool_call_id:
            return None
        start_time = self._tool_start_times.pop(tool_call_id, None)
        if start_time:
            return int((time.time() - start_time) * 1000)
        return None
