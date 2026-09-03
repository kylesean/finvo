"""Convert LangGraph chunks into GenUI events."""

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

_REDACTED_KEYS = frozenset(
    {
        "account_number", "account_no", "address", "card", "card_number",
        "comment", "description", "email", "iban", "memo", "mobile",
        "name", "note", "notes", "pan", "phone", "raw_input", "remark",
    }
)
_PREVIEW_LIMIT = 2000


def _redact(value: Any, depth: int = 0) -> Any:
    if depth > 4:
        return "<truncated>"
    if isinstance(value, dict):
        return {
            k: "<redacted>" if k.lower() in _REDACTED_KEYS else _redact(v, depth + 1)
            for k, v in value.items()
        }
    if isinstance(value, list):
        return [_redact(v, depth + 1) for v in value[:20]]
    if isinstance(value, str) and len(value) > 200:
        return f"{value[:200]}..."
    return value


class EventGenerator:
    def __init__(self, surfaces: SurfaceTracker | None = None) -> None:
        self._started: dict[str, float] = {}
        self._seen_calls: set[str] = set()
        self._created: set[str] = set()
        self._text_parts: list[str] = []
        self._surfaces = surfaces or SurfaceTracker()

    def reset(self) -> None:
        self._started.clear()
        self._seen_calls.clear()
        self._created.clear()
        self._text_parts.clear()

    @property
    def collected_response(self) -> str:
        return "".join(self._text_parts)

    async def process_message_chunk(self, chunk: tuple[Any, ...]) -> AsyncGenerator[GenUIEvent]:
        msg_chunk, _ = chunk
        if isinstance(msg_chunk, ToolMessage):
            return
        if msg_chunk.content:
            async for event in self._text_events(msg_chunk.content):
                yield event
        if isinstance(msg_chunk, AIMessage):
            chunks = getattr(msg_chunk, "tool_call_chunks", None)
            if chunks:
                async for event in self._tool_start_events(chunks):
                    yield event

    async def _text_events(self, content: Any) -> AsyncGenerator[GenUIEvent]:
        if isinstance(content, str):
            if content:
                self._text_parts.append(content)
                yield GenUIEvent(type="text_delta", content=content)
            return
        if not isinstance(content, list):
            return
        for item in content:
            if isinstance(item, str):
                self._text_parts.append(item)
                yield GenUIEvent(type="text_delta", content=item)
            elif isinstance(item, dict):
                text = item.get("text", "")
                if item.get("type") == "text" and text:
                    self._text_parts.append(text)
                    yield GenUIEvent(type="text_delta", content=text)
                elif item.get("type") == "reasoning_content" and text:
                    yield GenUIEvent(type="reasoning_delta", content=text, metadata={"status": "thinking"})

    async def _tool_start_events(self, chunks: list[dict[str, Any]]) -> AsyncGenerator[GenUIEvent]:
        by_index: dict[int, dict[str, Any]] = {}
        for part in chunks:
            index = part.get("index")
            if index is None:
                continue
            slot = by_index.setdefault(index, {"id": None, "name": None})
            slot["id"] = part.get("id") or slot["id"]
            slot["name"] = part.get("name") or slot["name"]
            tool_id, tool_name = slot["id"], slot["name"]
            if tool_id and tool_name and tool_id not in self._seen_calls:
                self._seen_calls.add(tool_id)
                self._started[tool_id] = time.time()
                yield GenUIEvent(
                    type="tool_call_start",
                    data={"id": tool_id, "name": tool_name, "timestamp": datetime.now(UTC).isoformat()},
                )

    async def process_updates_chunk(
        self, chunk: dict[str, Any], session_id: UUID
    ) -> AsyncGenerator[GenUIEvent]:
        for node_name, output in chunk.items():
            if node_name.startswith("__"):
                continue
            if node_name == "direct_execute":
                async for event in self._direct_execute_events(output, session_id):
                    yield event
            elif node_name == "tools":
                async for event in self._tools_events(output, session_id):
                    yield event

    async def _direct_execute_events(
        self, output: Any, session_id: UUID
    ) -> AsyncGenerator[GenUIEvent]:
        result = output.get("direct_execute_result") if isinstance(output, dict) else None
        if not result:
            return
        if not result.get("success"):
            yield GenUIEvent(type="error", content=str(result.get("error") or "Action failed"))
            return
        async for event in self._component_events(
            tool_result=result.get("data", {}),
            tool_name=result.get("tool_name", ""),
            session_id=session_id,
            tool_call_id=None,
            surface_id=result.get("surface_id"),
        ):
            yield event

    async def _tools_events(self, output: Any, session_id: UUID) -> AsyncGenerator[GenUIEvent]:
        for msg in _tool_messages(output):
            tool_name = getattr(msg, "name", "") if not isinstance(msg, dict) else msg.get("name", "")
            tool_call_id = getattr(msg, "tool_call_id", None) if not isinstance(msg, dict) else msg.get("tool_call_id")
            result = _tool_result(msg)
            ok = ComponentDetector.is_success(result)
            start = self._started.pop(tool_call_id, None) if tool_call_id else None
            duration = int((time.time() - start) * 1000) if start else None
            logger.debug(
                "tool_result_preview",
                tool=tool_name,
                ok=ok,
                preview=json.dumps(_redact(result), ensure_ascii=False, default=str)[:300],
            )
            payload = json.dumps(result, ensure_ascii=False, default=str) if isinstance(result, dict) else str(result)
            yield GenUIEvent(
                type="tool_call_end",
                data={
                    "id": tool_call_id or f"call_{tool_name}",
                    "name": tool_name,
                    "status": "success" if ok else "error",
                    "duration_ms": duration,
                    "result": payload[:_PREVIEW_LIMIT],
                    "result_truncated": len(payload) > _PREVIEW_LIMIT,
                    "error": result.get("error") if isinstance(result, dict) else None,
                },
            )
            async for event in self._component_events(
                tool_result=result,
                tool_name=tool_name,
                session_id=session_id,
                tool_call_id=tool_call_id,
            ):
                yield event

    async def _component_events(
        self,
        tool_result: Any,
        tool_name: str,
        session_id: UUID,
        tool_call_id: str | None,
        surface_id: str | None = None,
    ) -> AsyncGenerator[GenUIEvent]:
        from app.core.genui_protocol import (
            CreateSurface,
            CreateSurfacePayload,
            UpdateComponents,
            UpdateComponentsPayload,
            UpdateDataModel,
            UpdateDataModelPayload,
            V09Component,
        )

        component = ComponentDetector.detect(tool_result)
        if not component or not ComponentDetector.is_success(tool_result):
            return
        existing = self._surfaces.find_reusable(str(session_id), component)
        if existing and isinstance(tool_result, dict) and tool_result.get("_intent") == "update":
            old = self._surfaces.get_data(existing) or {}
            for key, value in tool_result.items():
                if key.startswith("_") or old.get(key) == value:
                    continue
                path = f"/{key}"
                yield GenUIEvent(
                    type="a2ui_message",
                    data=UpdateDataModel(
                        updateDataModel=UpdateDataModelPayload(surfaceId=existing, path=path, value=value)
                    ).model_dump(),
                )
                self._surfaces.update(existing, path, value)
            return

        surface_id = surface_id or f"surface_{session_id}_{tool_call_id or uuid.uuid4().hex[:8]}"
        self._surfaces.register(str(session_id), surface_id, component, tool_result, tool_call_id)
        if surface_id not in self._created:
            self._created.add(surface_id)
            yield GenUIEvent(
                type="a2ui_message",
                data=CreateSurface(createSurface=CreateSurfacePayload(surfaceId=surface_id)).model_dump(),
            )
        props = {k: v for k, v in tool_result.items() if not k.startswith("_")} if isinstance(tool_result, dict) else {}
        flat = {**props, "id": "root", "component": component}
        yield GenUIEvent(
            type="a2ui_message",
            data=UpdateComponents(
                updateComponents=UpdateComponentsPayload(
                    surfaceId=surface_id, components=[V09Component.model_validate(flat)]
                )
            ).model_dump(),
        )


def _tool_messages(output: Any) -> list[Any]:
    if isinstance(output, dict):
        return output.get("messages", [])
    items: list[Any] = []
    for item in output if isinstance(output, list) else []:
        if isinstance(item, ToolMessage) or (isinstance(item, dict) and item.get("role") == "tool"):
            items.append(item)
        elif isinstance(item, dict):
            items.extend(item.get("messages", []))
        elif isinstance(item, Command) and isinstance(item.update, dict):
            items.extend(item.update.get("messages", []))
    return items


def _tool_result(msg: Any) -> Any:
    artifact = msg.get("artifact") if isinstance(msg, dict) else getattr(msg, "artifact", None)
    if artifact is not None:
        return artifact
    content = msg.get("content", "") if isinstance(msg, dict) else getattr(msg, "content", "")
    if isinstance(content, dict):
        return content
    if isinstance(content, str):
        try:
            return json.loads(content)
        except (json.JSONDecodeError, TypeError):
            return {"result": content}
    return {"result": str(content)}
