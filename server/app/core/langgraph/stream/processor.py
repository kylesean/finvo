"""Turn LangGraph stream chunks into GenUI events."""

from collections.abc import AsyncGenerator
from typing import Any
from uuid import UUID

from langchain_core.messages import AIMessage
from langgraph.errors import GraphRecursionError

from app.core.exceptions import to_client_error
from app.core.langgraph.stream.event_generator import EventGenerator
from app.core.langgraph.stream.policies import suppress_text
from app.core.logging import logger
from app.schemas.genui import GenUIEvent
from app.services.message_index_service import message_index_service


class StreamProcessor:
    def __init__(self) -> None:
        self._events = EventGenerator()
        self._message_id_sent = False

    def last_response(self) -> str:
        return self._events.collected_response

    async def process_stream(
        self,
        agent: Any,
        input_data: dict[str, Any] | None,
        config: dict[str, Any],
        session_id: UUID,
        user_uuid: UUID | None = None,
    ) -> AsyncGenerator[GenUIEvent]:
        self._events.reset()
        self._message_id_sent = False
        user_message = _user_text(input_data)
        try:
            async for mode, chunk in agent.astream(
                input_data,
                config=config,
                stream_mode=["messages", "custom", "updates"],
            ):
                if mode == "messages":
                    async for event in self._process_messages(chunk):
                        yield event
                elif mode == "custom":
                    if isinstance(chunk, dict) and chunk.get("type") == "progress":
                        yield GenUIEvent(type="ui_progress", content=chunk.get("message", ""))
                elif mode == "updates":
                    async for event in self._events.process_updates_chunk(chunk, session_id):
                        yield event
        except GraphRecursionError:
            raise
        except Exception as e:
            logger.error("stream_processor_error", error=str(e), exc_info=True)
            yield GenUIEvent(type="error", content=f"Stream processing error: {to_client_error(e)}")
            return
        finally:
            if user_uuid:
                from app.core.background_tasks import spawn_background_task

                spawn_background_task(
                    _index_messages(session_id, user_uuid, user_message, self._events.collected_response)
                )

        yield GenUIEvent(type="done")

    async def _process_messages(self, chunk: tuple[Any, dict[str, Any]]) -> AsyncGenerator[GenUIEvent]:
        msg_chunk, metadata = chunk
        node_name = metadata.get("langgraph_node", "")
        if not self._message_id_sent and isinstance(msg_chunk, AIMessage):
            msg_id = getattr(msg_chunk, "id", None)
            if msg_id:
                self._message_id_sent = True
                yield GenUIEvent(type="message_id", content=msg_id)
        tool_name = metadata.get("current_tool_name")
        silent = suppress_text(node_name, tool_name)
        async for event in self._events.process_message_chunk(chunk):
            if event.type == "text_delta" and silent:
                continue
            yield event


def _user_text(input_data: dict[str, Any] | None) -> str:
    if not input_data:
        return ""
    messages = input_data.get("messages", [])
    if not messages:
        return ""
    last = messages[-1]
    content = getattr(last, "content", last.get("content", "") if isinstance(last, dict) else str(last))
    if isinstance(content, list):
        parts = [p.get("text", "") if isinstance(p, dict) else p for p in content if isinstance(p, (dict, str))]
        return " ".join(p for p in parts if p)
    return str(content) if content else ""


async def _index_messages(session_id: UUID, user_uuid: UUID, user_message: str, ai_response: str) -> None:
    try:
        if user_message.strip():
            await message_index_service.index_user_message(
                thread_id=session_id, user_uuid=user_uuid, content=user_message
            )
        if ai_response.strip():
            await message_index_service.index_assistant_message(
                thread_id=session_id, user_uuid=user_uuid, content=ai_response
            )
    except Exception as e:
        logger.warning("message_indexing_failed", error=str(e))
