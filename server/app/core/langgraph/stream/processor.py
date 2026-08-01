"""StreamProcessor - Stream Processing Orchestrator

Responsibilities:
- Coordinates LangGraph streaming with GenUI event generation
- Orchestrates policy execution (RenderPolicy, TextFilterPolicy)
- Manages event buffering and flushing
- Asynchronously dual-writes messages to searchable_messages table (full-text search)

Design Principles:
- Orchestrator pattern: Coordinates execution without defining concrete logic
- Dependency injection: Policies injected via constructor
- Open/Closed Principle: Extensible behavior via custom policies
"""

import asyncio
from collections.abc import AsyncGenerator
from typing import Any
from uuid import UUID

from app.core.exceptions import to_client_error
from app.core.langgraph.stream.event_generator import EventGenerator
from app.core.langgraph.stream.render_policy import (
    DefaultRenderPolicy,
    RenderDecision,
    RenderPolicy,
)
from app.core.langgraph.stream.text_filter_policy import (
    DefaultTextFilterPolicy,
    TextFilterPolicy,
)
from app.core.logging import logger
from app.schemas.genui import GenUIEvent
from app.services.message_index_service import message_index_service


class StreamProcessor:
    """LangGraph Stream Processing Orchestrator.

    Coordinates LangGraph multi-mode streaming output into GenUI events.

    Architecture:
    - EventGenerator: Event format transformation
    - RenderPolicy: Rendering decision (EMIT/BUFFER/SUPPRESS)
    - TextFilterPolicy: Text filter decision

    Usage Example:
        processor = StreamProcessor()
        async for event in processor.process_stream(agent, input_data, config, session_id):
            yield event

        # Custom policy
        processor = StreamProcessor(
            render_policy=CustomRenderPolicy(),
            text_filter_policy=CustomTextFilterPolicy(),
        )
    """

    def __init__(
        self,
        render_policy: RenderPolicy | None = None,
        text_filter_policy: TextFilterPolicy | None = None,
    ):
        """Initialize StreamProcessor.

        Args:
            render_policy: Render policy instance (defaults to DefaultRenderPolicy)
            text_filter_policy: Text filter policy instance (defaults to DefaultTextFilterPolicy)
        """
        self._render_policy = render_policy or DefaultRenderPolicy()
        self._text_filter_policy = text_filter_policy or DefaultTextFilterPolicy()
        self._event_generator = EventGenerator()

    def get_last_response(self) -> str:
        """Get the AI response text from the last stream processing.

        Returns:
            str: The collected AI response text
        """
        return self._event_generator.get_collected_response()

    async def process_stream(
        self,
        agent: Any,
        input_data: dict[str, Any] | None,
        config: dict[str, Any],
        session_id: UUID,
        user_uuid: UUID | None = None,
    ) -> AsyncGenerator[GenUIEvent]:
        """Process LangGraph stream and generate GenUI events.

        Args:
            agent: LangGraph Agent instance
            input_data: Graph input dictionary (None when resuming from checkpoint)
            config: Runtime configuration
            session_id: Session ID
            user_uuid: User UUID

        Yields:
            GenUIEvent events
        """
        self._event_generator.reset()
        event_buffer: list[GenUIEvent] = []

        # Extract user message for indexing
        user_message_content = self._extract_user_message(input_data)

        logger.info("stream_processor_start", session_id=session_id)

        try:
            async for mode, chunk in agent.astream(
                input_data,
                config=config,
                stream_mode=["messages", "custom", "updates"],
            ):
                async for event in self._process_chunk(
                    mode=mode,
                    chunk=chunk,
                    session_id=session_id,
                    event_buffer=event_buffer,
                ):
                    yield event

        except Exception as e:
            logger.error(
                "stream_processor_error",
                session_id=session_id,
                error=str(e),
                exc_info=True,
            )
            # Send error event to client (internal details stay in the log)
            yield GenUIEvent(
                type="error",
                content=f"Stream processing error: {to_client_error(e)}",
            )

        finally:
            # 1. Flush buffered events
            for event in event_buffer:
                yield event

            # 2. Emit completion event
            yield GenUIEvent(type="done")

            # 3. Dual-write messages to searchable_messages table (async, non-blocking)
            if user_uuid and session_id:
                from app.core.background_tasks import spawn_background_task

                spawn_background_task(
                    self._index_messages(
                        session_id=session_id,
                        user_uuid=user_uuid,
                        user_message=user_message_content,
                        ai_response=self._event_generator.get_collected_response(),
                    )
                )

            logger.info(
                "stream_processor_complete",
                session_id=session_id,
                buffered_events=len(event_buffer),
            )

    def _extract_user_message(self, input_data: dict[str, Any] | None) -> str:
        """Extract user message text from graph input data.

        Args:
            input_data: Graph input dictionary

        Returns:
            User message text string
        """
        if not input_data:
            return ""

        messages = input_data.get("messages", [])
        if not messages:
            return ""

        last_msg = messages[-1]

        if hasattr(last_msg, "content"):
            content = last_msg.content
        elif isinstance(last_msg, dict):
            content = last_msg.get("content", "")
        else:
            content = str(last_msg)

        if isinstance(content, list):
            text_parts = []
            for item in content:
                if isinstance(item, dict) and item.get("type") == "text":
                    text_parts.append(item.get("text", ""))
                elif isinstance(item, str):
                    text_parts.append(item)
            return " ".join(text_parts)

        return str(content) if content else ""

    async def _index_messages(
        self,
        session_id: UUID,
        user_uuid: UUID,
        user_message: str,
        ai_response: str,
    ) -> None:
        """Asynchronously index user message and AI response into searchable_messages table.

        Dual-write pattern core: writes messages simultaneously to LangGraph checkpoints
        and searchable_messages table for full-text search.

        Args:
            session_id: Session ID
            user_uuid: User UUID
            user_message: User message text
            ai_response: AI response text
        """
        try:
            # Index user message
            if user_message and user_message.strip():
                await message_index_service.index_user_message(
                    thread_id=session_id,
                    user_uuid=user_uuid,
                    content=user_message,
                )

            # Index AI response
            if ai_response and ai_response.strip():
                await message_index_service.index_assistant_message(
                    thread_id=session_id,
                    user_uuid=user_uuid,
                    content=ai_response,
                )

        except Exception as e:
            # Indexing failure should not disrupt main execution pipeline
            logger.warning(
                "message_indexing_failed",
                session_id=session_id,
                error=str(e),
            )

    async def _process_chunk(
        self,
        mode: str,
        chunk: Any,
        session_id: UUID,
        event_buffer: list[GenUIEvent],
    ) -> AsyncGenerator[GenUIEvent]:
        """Process an individual stream chunk.

        Args:
            mode: Stream mode ("messages", "custom", "updates")
            chunk: Chunk data payload
            session_id: Session ID
            event_buffer: Event buffer for BUFFER decision events

        Yields:
            GenUIEvent instances to emit immediately
        """
        if mode == "messages":
            async for event in self._process_messages_mode(chunk, session_id, event_buffer):
                yield event

        elif mode == "custom":
            async for event in self._process_custom_mode(chunk):
                yield event

        elif mode == "updates":
            async for event in self._process_updates_mode(
                chunk,
                session_id,
                event_buffer,
            ):
                yield event

    async def _process_messages_mode(
        self,
        chunk: tuple[Any, dict[str, Any]],
        session_id: UUID,
        event_buffer: list[GenUIEvent],
    ) -> AsyncGenerator[GenUIEvent]:
        """Process messages stream mode."""
        msg_chunk, metadata = chunk
        node_name = metadata.get("langgraph_node", "")

        # Apply text filter policy
        should_suppress_text = self._text_filter_policy.should_suppress(node_name, metadata)

        async for event in self._event_generator.process_message_chunk(chunk, session_id):
            # 1. Text filtering
            if event.type == "text_delta" and should_suppress_text:
                logger.debug(
                    "text_suppressed",
                    node_name=node_name,
                    content_length=len(event.content or ""),
                )
                continue

            # 2. Render policy
            decision = self._render_policy.decide(event, node_name)

            if decision == RenderDecision.EMIT:
                yield event
            elif decision == RenderDecision.BUFFER:
                event_buffer.append(event)
                logger.debug(
                    "event_buffered_messages_mode",
                    event_type=event.type,
                    node_name=node_name,
                )
            elif decision == RenderDecision.SUPPRESS:
                logger.debug(
                    "event_suppressed_messages_mode",
                    event_type=event.type,
                    node_name=node_name,
                )

    async def _process_custom_mode(
        self,
        chunk: dict[str, Any],
    ) -> AsyncGenerator[GenUIEvent]:
        """Process custom stream mode."""
        if isinstance(chunk, dict) and chunk.get("type") == "progress":
            yield GenUIEvent(
                type="ui_progress",
                content=chunk.get("message", ""),
            )

    async def _process_updates_mode(
        self,
        chunk: dict[str, Any],
        session_id: UUID,
        event_buffer: list[GenUIEvent],
    ) -> AsyncGenerator[GenUIEvent]:
        """Process updates stream mode."""
        node_name = next(iter(chunk.keys())) if isinstance(chunk, dict) else ""

        async for event in self._event_generator.process_updates_chunk(chunk, session_id):
            decision = self._render_policy.decide(event, node_name)

            if decision == RenderDecision.EMIT:
                yield event

            elif decision == RenderDecision.BUFFER:
                event_buffer.append(event)
                logger.debug(
                    "event_buffered",
                    event_type=event.type,
                    node_name=node_name,
                )

            elif decision == RenderDecision.SUPPRESS:
                logger.debug(
                    "event_suppressed",
                    event_type=event.type,
                    node_name=node_name,
                )
