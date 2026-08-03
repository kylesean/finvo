"""SimpleLangChainAgent - LangGraph Low-level API Implementation

Agent built using LangGraph StateGraph low-level API.
Responsibilities are modularized into:
- agent/: State definitions, node functions, routing logic, graph construction
- stream/: Stream processing and GenUI adaptation
- middleware/: Dynamic context, long-term memory, attachment processing

Acts as a facade class coordinating submodules.
"""

from __future__ import annotations

import asyncio
import json
import uuid
from collections.abc import AsyncGenerator, Sequence
from contextvars import ContextVar
from typing import Any
from uuid import UUID

from langchain_core.messages import AIMessage, HumanMessage
from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver
from langgraph.errors import GraphRecursionError

from app.core.config import settings
from app.core.langgraph.agent import build_agent_graph
from app.core.langgraph.middleware import (
    AttachmentMiddleware,
    DynamicContextMiddleware,
    LongTermMemoryMiddleware,
    MiddlewareAgent,
)
from app.core.langgraph.middleware.state_validator import state_validator
from app.core.langgraph.stream import StreamProcessor
from app.core.langgraph.tools import tools
from app.core.logging import logger
from app.core.prompts import get_stable_system_prompt
from app.schemas import Message
from app.schemas.client_state import ClientStateMutation
from app.schemas.genui import GenUIEvent
from app.services.llm import llm_service
from app.services.memory import MemoryService, get_memory_service

# Holds the StreamProcessor for the *current request*. ``SimpleLangChainAgent``
# is a module-level singleton, but each asyncio task receives its own
# ContextVar context, so concurrent requests using this context get their own
# processor and never share mutable stream state (M17).
#
# There is deliberately NO shared fallback instance: reading the collected
# response without an active stream in this context returns "" instead of
# leaking another request's data.
_current_stream_processor: ContextVar[StreamProcessor | None] = ContextVar("current_stream_processor", default=None)


class SimpleLangChainAgent:
    """LangGraph Agent Facade.

    Coordinates graph building, stream processing, and middleware pipeline.

    Architecture:
    - Uses LangGraph StateGraph low-level API to construct graph
    - Uses MiddlewareAgent wrapper for dynamic context and memory
    - Uses StreamProcessor for streaming output
    """

    def __init__(self, checkpointer: AsyncPostgresSaver | None = None) -> None:
        """Initialize the agent.

        Args:
            checkpointer: Optional LangGraph checkpointer. When not provided,
                it is lazily obtained from app.core.checkpointer.checkpointer_manager
                on first use (the pool is eagerly warmed up in the app lifespan).

        Note:
            Construction is side-effect free. The LLM tool binding happens inside
            create_agent_node at graph-build time (see get_agent), and the
            "simple_agent_initialized" log is emitted on the first get_agent()
            call — so importing this module never triggers I/O or log noise.
        """
        self.llm_service = llm_service
        self._agent: MiddlewareAgent | None = None
        self._checkpointer: AsyncPostgresSaver | None = checkpointer
        self._memory_service: MemoryService | None = None
        self._middlewares: list[Any] | None = None

    # =========================================================================
    # Internal Component Initialization
    # =========================================================================

    async def _get_memory_service(self) -> MemoryService:
        """Obtain MemoryService instance (centralized long-term memory management)."""
        if self._memory_service is None:
            self._memory_service = await get_memory_service()
        return self._memory_service

    async def _get_checkpointer(self) -> AsyncPostgresSaver:
        """Obtain LangGraph checkpointer managed by checkpointer_manager."""
        if self._checkpointer is None:
            from app.core.checkpointer import checkpointer_manager

            await checkpointer_manager.ensure_initialized()
            self._checkpointer = checkpointer_manager.saver()
        return self._checkpointer

    async def _initialize_middlewares(self) -> list[Any]:
        """Initialize middleware stack."""
        if self._middlewares is None:
            from app.core.database import get_session_context
            from app.core.langgraph.middleware import SkillMiddleware

            # LongTermMemoryMiddleware now uses MemoryService internally
            # No need to pass memory instance directly
            self._middlewares = [
                DynamicContextMiddleware(),
                LongTermMemoryMiddleware(
                    max_memories=5,
                    min_relevance_score=0.3,  # Only include relevant memories
                ),
                AttachmentMiddleware(get_session_context),
                # SkillMiddleware: Official LangChain Skills pattern
                # Injects skill catalog into system prompt (progressive disclosure)
                SkillMiddleware(),
            ]

            logger.info(
                "middlewares_initialized",
                count=len(self._middlewares),
            )

        return self._middlewares

    def get_last_response(self) -> str:
        """Get the AI response text from the last stream in the current request.

        Resolves the per-request ``StreamProcessor`` bound to this task's
        context, so concurrent requests never read each other's collected
        response. Returns ``""`` when no stream has run in this context
        (e.g. a non-streaming call or an early failure) instead of falling
        back to shared state.

        Returns:
            str: The collected AI response text from the most recent stream
        """
        processor = _current_stream_processor.get()
        if processor is None:
            return ""
        return processor.get_last_response()

    def reset_stream_context(self) -> None:
        """Release the request-scoped stream processor bound to this context.

        Call after reading ``get_last_response()`` (or when the stream ends
        without a reader) so the ContextVar does not leak into a reused task
        context (e.g. pytest worker tasks or pooled executors).
        """
        _current_stream_processor.set(None)

    def _new_stream_processor(self) -> StreamProcessor:
        """Create a request-scoped StreamProcessor bound to this task's context.

        Each streaming call gets a fresh processor so mutable stream state
        (tool timing, deduplication sets, collected response) never leaks
        across concurrent requests. The per-request ContextVar is what
        ``get_last_response`` reads after the stream finishes.
        """
        processor = StreamProcessor()
        _current_stream_processor.set(processor)
        return processor

    # =========================================================================
    # Agent Lifecycle
    # =========================================================================

    async def get_agent(self) -> MiddlewareAgent:
        """Obtain or build the MiddlewareAgent instance.

        Returns:
            MiddlewareAgent: Agent graph wrapped with middleware stack
        """
        if self._agent is not None:
            return self._agent

        logger.info(
            "simple_agent_initialized",
            model=settings.DEFAULT_LLM_MODEL,
        )

        # Build custom graph (supporting direct_execute node)
        checkpointer = await self._get_checkpointer()
        llm = self.llm_service.get_llm()
        if llm is None:
            raise RuntimeError("LLM not initialized")

        graph = build_agent_graph(
            llm=llm,
            tools=tools,
            system_prompt=get_stable_system_prompt(),
            checkpointer=checkpointer,
        )

        # Wrap with application layer middleware (dynamic context, long-term memory, attachments)
        middlewares = await self._initialize_middlewares()
        self._agent = MiddlewareAgent(graph, middlewares)

        logger.info("agent_created")
        return self._agent

    # =========================================================================
    # Core API
    # =========================================================================

    async def get_genui_stream(
        self,
        messages: Sequence[Message],
        session_id: UUID,
        user_uuid: UUID | None = None,
        attachment_ids: list[UUID] | None = None,
        client_state: ClientStateMutation | None = None,
    ) -> AsyncGenerator[GenUIEvent]:
        """GenUI core stream processor.

        Core entry point for GenUI atomic mode:
        - client_state is merged as initial graph input
        - Performs state validation prior to graph execution
        - Fallbacks automatically to agent node when validation fails

        Args:
            messages: List of messages
            session_id: Session ID
            user_uuid: User UUID
            attachment_ids: List of attachment IDs
            client_state: Client state mutation (GenUI atomic mode)

        Yields:
            GenUIEvent events
        """
        agent = await self.get_agent()

        config: dict[str, Any] = {
            "configurable": {
                "thread_id": str(session_id),
                "user_uuid": str(user_uuid) if user_uuid else None,
                "attachment_ids": [str(aid) for aid in attachment_ids] if attachment_ids else [],
            },
        }

        # Add Langfuse callback for tracing
        langfuse_handler = self._get_langfuse_callback(session_id, user_uuid)
        if langfuse_handler:
            config["callbacks"] = [langfuse_handler]

        # Convert message formats
        # History is persisted in checkpoint; process incremental input only.
        lc_messages = []
        if messages:
            last_msg = messages[-1]
            # Keep `content` a plain string — never multimodal / base64. Carry the
            # attachment id references in additional_kwargs so the history API
            # (get_detailed_history) can emit signed URLs, and so the model node
            # can rebuild the multimodal payload transiently (including on resume,
            # where the middleware is bypassed). A single list literal keeps the
            # element type as `HumanMessage | AIMessage` (mypy list invariance).
            lc_messages = [
                HumanMessage(
                    content=last_msg.content,
                    additional_kwargs=(
                        {"attachment_ids": [str(aid) for aid in attachment_ids]} if attachment_ids else {}
                    ),
                )
                if last_msg.role == "user"
                else AIMessage(content=last_msg.content)
            ]

        # Build input_data
        input_data: dict[str, Any] = {"messages": lc_messages}

        # GenUI atomic mode: process client_state
        if client_state:
            # Defensive validation
            validation_result = state_validator.validate(client_state)

            if validation_result:
                # Validation passed: merge into graph input
                state_dict = client_state.to_state_dict()
                input_data.update(state_dict)
                logger.info(
                    "genui_atomic_mode",
                    session_id=session_id,
                    ui_mode=client_state.ui_mode,
                    tool_name=client_state.tool_name,
                )
            else:
                # Validation failed: fallback to agent node
                logger.warning(
                    "genui_atomic_mode_validation_failed",
                    session_id=session_id,
                    errors=validation_result.errors,
                )
                # Do not set ui_mode; let route_entry route to agent

        # Delegate to StreamProcessor
        from app.core.langgraph.tools import current_user_id

        token = None
        if user_uuid:
            token = current_user_id.set(str(user_uuid))

        try:
            async for event in self._new_stream_processor().process_stream(
                agent=agent,
                input_data=input_data,
                config=config,
                session_id=session_id,
                user_uuid=user_uuid,
            ):
                yield event
        except GraphRecursionError:
            logger.warning(
                "agent_recursion_limit_exceeded",
                session_id=session_id,
            )
            yield GenUIEvent(
                type="text_delta",
                content="\n\nSorry, I attempted this task too many times without success. Please try simplifying your request or rephrasing it.",
            )
            yield GenUIEvent(type="done")
        finally:
            if token:
                try:
                    current_user_id.reset(token)
                except ValueError:
                    pass

            # Flush Langfuse telemetry off the event loop.
            # langfuse_handler is always bound above; the old `in locals()` guard was dead code.
            if langfuse_handler and hasattr(langfuse_handler, "flush"):
                await asyncio.to_thread(langfuse_handler.flush)

    async def get_session_state(self, session_id: UUID) -> Any:
        """Retrieve current LangGraph state snapshot for session.

        Used to inspect pending executions (state.next != None).

        Args:
            session_id: Session ID

        Returns:
            StateSnapshot containing values and next properties
        """
        agent = await self.get_agent()
        config = {"configurable": {"thread_id": str(session_id)}}
        return await agent.aget_state(config)

    async def update_state(self, session_id: UUID, values: dict[str, Any], as_node: str | None = None) -> Any:
        """Update current LangGraph state snapshot for session.

        Args:
            session_id: Session ID
            values: Dictionary of values to update in state
            as_node: Optional node name under which state is updated

        Returns:
            Updated configuration dictionary
        """
        agent = await self.get_agent()
        config = {"configurable": {"thread_id": str(session_id)}}
        return await agent.aupdate_state(config, values, as_node=as_node)

    async def resume_stream(
        self,
        session_id: UUID,
        user_uuid: UUID | None = None,
    ) -> AsyncGenerator[GenUIEvent]:
        """Resume streaming execution from checkpoint.

        When get_session_state() returns non-None state.next, invoke this
        method to resume execution from the latest checkpoint.

        Args:
            session_id: Session ID
            user_uuid: User UUID

        Yields:
            GenUIEvent events
        """
        agent = await self.get_agent()

        config: dict[str, Any] = {
            "configurable": {
                "thread_id": str(session_id),
                "user_uuid": str(user_uuid) if user_uuid else None,
            },
        }

        # Add Langfuse callback for tracing
        langfuse_handler = self._get_langfuse_callback(session_id, user_uuid)
        if langfuse_handler:
            config["callbacks"] = [langfuse_handler]

        logger.info(
            "resume_stream_started",
            session_id=session_id,
            user_uuid=user_uuid,
        )

        # Pass None as input to resume execution from checkpoint
        from app.core.langgraph.tools import current_user_id

        token = None
        if user_uuid:
            token = current_user_id.set(str(user_uuid))

        try:
            async for event in self._new_stream_processor().process_stream(
                agent=agent,
                input_data=None,  # None signifies resume from checkpoint
                config=config,
                session_id=session_id,
                user_uuid=user_uuid,
            ):
                yield event
        except GraphRecursionError:
            logger.warning(
                "resume_stream_recursion_limit_exceeded",
                session_id=session_id,
            )
            yield GenUIEvent(
                type="text_delta",
                content="\n\nTask execution exceeded maximum attempt limits. Please restart the conversation.",
            )
            yield GenUIEvent(type="done")
        finally:
            if token:
                try:
                    current_user_id.reset(token)
                except ValueError:
                    pass

            # Flush Langfuse telemetry off the event loop.
            if langfuse_handler and hasattr(langfuse_handler, "flush"):
                await asyncio.to_thread(langfuse_handler.flush)

        logger.info(
            "resume_stream_completed",
            session_id=session_id,
        )

    async def get_chat_history(self, session_id: UUID) -> list[Message]:
        """Retrieve chat history for session.

        Args:
            session_id: Session ID

        Returns:
            List of Message instances
        """
        agent = await self.get_agent()
        config = {"configurable": {"thread_id": str(session_id)}}
        state = await agent.aget_state(config)

        if state.values and "messages" in state.values:
            result = []
            for msg in state.values["messages"]:
                if not isinstance(msg, AIMessage | HumanMessage):
                    continue
                if not msg.content:
                    continue

                text_content = self._extract_text_content(msg.content)
                if text_content:
                    result.append(
                        Message(
                            role="assistant" if isinstance(msg, AIMessage) else "user",
                            content=text_content,
                        )
                    )
            return result
        return []

    async def get_detailed_history(self, session_id: UUID, user_uuid: UUID | None = None) -> list[dict[str, Any]]:
        """Retrieve detailed chat history including UI components and attachment details.

        Reads messages from LangGraph checkpoint and parses:
        - AI message tool_calls
        - UI component data from ToolMessages
        - Attachment details referenced via additional_kwargs

        Args:
            session_id: Session ID
            user_uuid: User UUID (for data enrichment backfill)

        Returns:
            List of message dictionaries formatted for client response (using camelCase keys)
        """
        from langchain_core.messages import ToolMessage

        agent = await self.get_agent()
        config = {"configurable": {"thread_id": str(session_id)}}
        state = await agent.aget_state(config)

        if not state.values or "messages" not in state.values:
            return []

        messages = state.values["messages"]
        result = []

        # Step 1: Preprocess - Collect UI component mappings from ToolMessages
        tool_call_ui_map: dict[str, dict[str, Any]] = {}

        from app.core.genui.enricher import EnricherRegistry
        from app.core.langgraph.stream import ComponentDetector
        from app.services.enrichers.transaction_enricher import transaction_enricher

        # Register enricher (idempotent)
        EnricherRegistry.register(transaction_enricher)

        for msg in messages:
            if isinstance(msg, ToolMessage):
                tool_name = getattr(msg, "name", None)
                tool_call_id = getattr(msg, "tool_call_id", None)
                if not tool_call_id:
                    continue

                # Extract tool execution result (from artifact first, or parse content string)
                tool_result = getattr(msg, "artifact", None)
                if tool_result is None:
                    try:
                        content = msg.content
                        if isinstance(content, str):
                            tool_result = json.loads(content)
                        elif isinstance(content, dict):
                            tool_result = content
                    except Exception:  # nosec B112
                        continue

                if not isinstance(tool_result, dict):
                    continue

                # Detect component type using ComponentDetector
                component_type = ComponentDetector.detect_with_overrides(tool_result, tool_name)

                if not component_type:
                    continue

                # Filter out unsuccessful execution results
                if not ComponentDetector.is_successful_result(tool_result):
                    continue

                msg_id = getattr(msg, "id", None) or str(uuid.uuid4())
                tool_call_ui_map[tool_call_id] = {
                    "surfaceId": f"history_{msg_id}",
                    "componentType": component_type,
                    "data": tool_result,
                    "mode": "historical",
                    "toolCallId": tool_call_id,
                    "toolName": tool_name,
                }

        # Process direct_execute_result (bypassing LLM execution results)
        direct_execute_result = state.values.get("direct_execute_result")
        if direct_execute_result and direct_execute_result.get("success"):
            tool_name = direct_execute_result.get("tool_name", "")
            tool_result = direct_execute_result.get("data", {})

            if isinstance(tool_result, dict):
                component_type = ComponentDetector.detect_with_overrides(tool_result, tool_name)

                if component_type and ComponentDetector.is_successful_result(tool_result):
                    de_id = "direct_execute_result"
                    tool_call_ui_map[de_id] = {
                        "surfaceId": f"history_de_{session_id}",
                        "componentType": component_type,
                        "data": tool_result,
                        "mode": "historical",
                        "toolCallId": de_id,
                        "toolName": tool_name,
                    }

        # Enrichment Layer: Real-time data backfill
        if user_uuid:
            for tc_id, ui_comp in tool_call_ui_map.items():
                component_type = ui_comp.get("componentType")
                if component_type and ui_comp.get("mode") == "historical":
                    original_data = ui_comp.get("data", {})

                    enriched_data = await EnricherRegistry.enrich_component(
                        component_name=component_type,
                        tool_call_id=tc_id,
                        data=original_data,
                        context={"user_uuid": user_uuid, "session_id": session_id},
                    )

                    if enriched_data != original_data:
                        ui_comp["data"] = enriched_data
                        logger.debug(
                            "component_enriched_success",
                            tool_call_id=tc_id,
                            component_type=component_type,
                        )

        # Link TransferWizard to execution result for historical state completeness
        confirmed_params = None
        if direct_execute_result and direct_execute_result.get("success"):
            de_data = direct_execute_result.get("data", {})
            if de_data.get("componentType") == "TransferReceipt" or de_data.get("transfer_info"):
                transfer_info = de_data.get("transfer_info") or {}
                source_acc = transfer_info.get("source_account") or {}
                target_acc = transfer_info.get("target_account") or {}

                confirmed_params = {
                    "amount": float(de_data.get("amount") or 0.0),
                    "source_id": str(source_acc.get("id") or de_data.get("source_account_id") or ""),
                    "target_id": str(target_acc.get("id") or de_data.get("target_account_id") or ""),
                }

        if confirmed_params:
            for ui_comp in tool_call_ui_map.values():
                if ui_comp.get("componentType") == "TransferWizard":
                    wizard_data = ui_comp.get("data", {})
                    if confirmed_params["source_id"]:
                        wizard_data["preselectedSourceId"] = confirmed_params["source_id"]
                    if confirmed_params["target_id"]:
                        wizard_data["preselectedTargetId"] = confirmed_params["target_id"]
                    if float(str(confirmed_params.get("amount") or 0.0)) > 0:
                        wizard_data["amount"] = confirmed_params["amount"]

                    wizard_data["isConfirmed"] = True
                    logger.debug("history_wizard_data_auto_filled", surface_id=ui_comp.get("surfaceId"))

        logger.debug("tool_call_ui_map_built", count=len(tool_call_ui_map))

        # Step 2: Build and optimize message structure
        raw_result: list[dict[str, Any]] = []
        for msg in messages:
            msg_id = getattr(msg, "id", None) or str(uuid.uuid4())

            # Skip ToolMessages (handled above)
            if isinstance(msg, ToolMessage):
                continue

            # HumanMessage
            if isinstance(msg, HumanMessage):
                text_content = self._extract_text_content(msg.content)
                additional_kwargs = getattr(msg, "additional_kwargs", {}) or {}
                attachment_ids = additional_kwargs.get("attachment_ids", [])

                content_type = type(msg.content).__name__
                content_length = len(msg.content) if isinstance(msg.content, str | list) else 0
                logger.debug(
                    "human_message_content_debug",
                    msg_id=msg_id,
                    content_type=content_type,
                    content_length=content_length,
                    has_additional_kwargs=bool(additional_kwargs),
                    attachment_ids_from_kwargs=attachment_ids,
                )

                if attachment_ids:
                    attachments_data = [
                        {
                            "id": att_id,
                            "filename": f"image_{i}.jpg",
                            "signedUrl": f"/api/v1/files/view/{att_id}",
                        }
                        for i, att_id in enumerate(attachment_ids)
                    ]
                else:
                    attachments_data = self._extract_attachment_ids(msg.content)

                logger.debug(
                    "human_message_attachments_extracted",
                    msg_id=msg_id,
                    attachment_count=len(attachments_data),
                    text_content_length=len(text_content),
                )

                raw_result.append(
                    {
                        "id": msg_id,
                        "role": "user",
                        "content": text_content,
                        "timestamp": None,
                        "toolCalls": [],
                        "uiComponents": [],
                        "attachments": attachments_data,
                    }
                )

            # AIMessage
            elif isinstance(msg, AIMessage):
                text_content = self._extract_text_content(msg.content)
                tool_calls_data = []
                ui_components = []

                if hasattr(msg, "tool_calls") and msg.tool_calls:
                    for tc in msg.tool_calls:
                        tc_id = str(tc.get("id") or "")
                        tc_name = tc.get("name", "")
                        tool_calls_data.append(
                            {
                                "id": tc_id,
                                "name": tc_name,
                                "args": tc.get("args", {}),
                                "status": "success",
                            }
                        )
                        if tc_id in tool_call_ui_map:
                            ui_components.append(tool_call_ui_map[tc_id])
                            logger.debug("ui_component_matched", tc_id=tc_id, tool_name=tc_name)
                        else:
                            logger.debug(
                                "ui_component_not_found",
                                tc_id=tc_id,
                                tool_name=tc_name,
                                available_keys=list(tool_call_ui_map.keys())[:5],
                            )

                raw_result.append(
                    {
                        "id": msg_id,
                        "role": "assistant",
                        "content": text_content,
                        "timestamp": None,
                        "toolCalls": tool_calls_data,
                        "uiComponents": ui_components,
                        "attachments": [],
                    }
                )

        result = raw_result

        # Append direct_execute_result UI component to last AI message
        de_ui_component = tool_call_ui_map.get("direct_execute_result")
        if de_ui_component:
            for i in range(len(result) - 1, -1, -1):
                if isinstance(result[i], dict) and result[i].get("role") == "assistant":
                    assistant_msg_ui_components: Any = result[i]["uiComponents"]
                    if isinstance(assistant_msg_ui_components, list):
                        assistant_msg_ui_components.append(de_ui_component)
                    logger.info(
                        "direct_execute_ui_appended_to_message",
                        message_id=result[i].get("id"),
                        component_type=de_ui_component.get("componentType"),
                    )
                    break

        logger.info(
            "detailed_history_retrieved",
            session_id=session_id,
            message_count=len(result),
            ui_component_count=len(tool_call_ui_map),
        )

        return result

    async def delete_session_history(self, session_id: UUID) -> None:
        """Purge all session history and checkpoints.

        1. Invoke LangGraph official adelete_thread API.
        2. Delete records from searchable_messages database table.

        Args:
            session_id: Session ID
        """
        from app.services.message_index_service import message_index_service

        checkpointer = await self._get_checkpointer()

        # 1. Delete thread checkpoints and writes
        await checkpointer.adelete_thread(str(session_id))

        # 2. Delete searchable message index records
        deleted_count = await message_index_service.delete_thread_messages(session_id)

        logger.info(
            "session_history_deleted_cascade",
            session_id=session_id,
            cleared_tables=["langgraph_checkpoints", "searchable_messages"],
            deleted_message_count=deleted_count,
        )

    async def clear_chat_history(self, session_id: UUID) -> None:
        """Clear chat message content while keeping session metadata.

        Args:
            session_id: Session ID
        """
        await self.delete_session_history(session_id)
        logger.info("chat_history_cleared", session_id=session_id)

    async def cancel_last_turn(self, session_id: UUID) -> dict[str, Any]:
        """Cancel the last conversation turn.

        Uses RemoveMessage to clear checkpoint state.

        Args:
            session_id: Session ID

        Returns:
            Dictionary containing removed_count and removed_message_ids
        """
        from langchain_core.messages import RemoveMessage

        agent = await self.get_agent()
        config = {"configurable": {"thread_id": str(session_id)}}

        state = await agent.aget_state(config)

        if not state.values or "messages" not in state.values:
            return {"removed_count": 0, "removed_message_ids": []}

        messages = state.values["messages"]

        if not messages:
            return {"removed_count": 0, "removed_message_ids": []}

        last_human_idx = -1
        for i in range(len(messages) - 1, -1, -1):
            if isinstance(messages[i], HumanMessage):
                last_human_idx = i
                break

        if last_human_idx == -1:
            return {"removed_count": 0, "removed_message_ids": []}

        messages_to_remove = []
        for msg in messages[last_human_idx:]:
            msg_id = getattr(msg, "id", None)
            if msg_id:
                messages_to_remove.append(RemoveMessage(id=msg_id))

        if not messages_to_remove:
            return {"removed_count": 0, "removed_message_ids": []}

        await agent.aupdate_state(config, {"messages": messages_to_remove})

        removed_ids = [rm.id for rm in messages_to_remove]
        logger.info(
            "cancel_last_turn_success",
            session_id=session_id,
            removed_count=len(removed_ids),
        )

        return {
            "removed_count": len(removed_ids),
            "removed_message_ids": removed_ids,
        }

    # =========================================================================
    # Helper Methods
    # =========================================================================

    def _extract_text_content(self, content: Any) -> str:
        """Extract text string from message content."""
        if isinstance(content, str):
            return content
        elif isinstance(content, list):
            text_parts = []
            for item in content:
                if isinstance(item, dict):
                    if item.get("type") == "text" and item.get("text"):
                        text_parts.append(item["text"])
                elif isinstance(item, str):
                    text_parts.append(item)
            return " ".join(text_parts)
        else:
            return str(content)

    def _extract_attachment_ids(self, content: Any) -> list[dict[str, Any]]:
        """Extract attachment data from message content.

        Supports formats:
        1. Base64 data URI: {type: "image_url", image_url: {url: "data:..."}}
        2. External URL: {type: "image_url", image_url: {url: "http://..."}}
        3. attachment_id format: {type: "image_url", attachment_id: "xxx", image_url: {...}}

        Returns list of attachment dicts matching client ChatMessageAttachment model.
        """
        attachments = []
        if isinstance(content, list):
            for idx, item in enumerate(content):
                if isinstance(item, dict):
                    if item.get("type") == "image_url":
                        image_url = item.get("image_url", {})
                        url = image_url.get("url", "")

                        attachment_id = item.get("attachment_id")

                        if attachment_id:
                            attachments.append(
                                {
                                    "id": attachment_id,
                                    "filename": f"image_{idx}.jpg",
                                    "signedUrl": f"/api/v1/files/view/{attachment_id}",
                                }
                            )
                        elif url.startswith("data:"):
                            mime_match = url.split(";")[0].replace("data:", "")
                            ext = mime_match.split("/")[1] if "/" in mime_match else "jpg"

                            attachments.append(
                                {
                                    "id": f"inline_{idx}_{str(uuid.uuid4())[:8]}",
                                    "filename": f"image_{idx}.{ext}",
                                    "signedUrl": url,
                                }
                            )
                        elif url.startswith(("http://", "https://", "/")):
                            ext = "jpg"
                            if "." in url.split("/")[-1]:
                                ext = url.split(".")[-1].split("?")[0][:4]

                            attachments.append(
                                {
                                    "id": f"url_{idx}_{str(uuid.uuid4())[:8]}",
                                    "filename": f"image_{idx}.{ext}",
                                    "signedUrl": url,
                                }
                            )
        return attachments

    async def update_long_term_memory(
        self,
        user_uuid: UUID | None,
        messages: list[dict[str, Any]],
        session_id: UUID | None = None,
        category: str = "conversation",
        additional_metadata: dict[str, Any] | None = None,
    ) -> None:
        """Update long-term memory (safe to run as a background task).

        Uses MemoryService to extract and store relevant information
        from the conversation.

        Args:
            user_uuid: User identifier
            messages: Conversation messages in OpenAI format
            session_id: Optional session ID for context
            category: Memory category (conversation, preference, financial, etc.)
            additional_metadata: Extra metadata to store
        """
        if not user_uuid:
            return

        if not messages:
            return

        try:
            service = await self._get_memory_service()
            result = await service.add_conversation_memory(
                user_uuid=user_uuid,
                messages=messages,
                session_id=session_id,
                category=category,
                additional_metadata=additional_metadata,
            )

            if result.get("success"):
                logger.debug(
                    "long_term_memory_updated",
                    user_uuid=user_uuid,
                    session_id=session_id,
                    category=category,
                )
            else:
                logger.warning(
                    "long_term_memory_update_failed",
                    user_uuid=user_uuid,
                    error=result.get("error", "Unknown error"),
                )
        except Exception as e:
            logger.warning(
                "long_term_memory_update_failed",
                user_uuid=user_uuid,
                error=str(e),
            )

    def _get_langfuse_callback(self, thread_id: UUID, user_id: UUID | None = None) -> Any:
        """Obtain Langfuse Callback Handler for execution tracing."""
        logger.debug(
            "langfuse_check",
            has_pub=bool(settings.LANGFUSE_PUBLIC_KEY),
            has_sec=bool(settings.LANGFUSE_SECRET_KEY),
            host=settings.LANGFUSE_HOST,
        )

        if not settings.LANGFUSE_PUBLIC_KEY or not settings.LANGFUSE_SECRET_KEY:
            logger.debug("langfuse_config_missing_skipping_callback")
            return None

        try:
            from langfuse.langchain import CallbackHandler

            logger.info(
                "initializing_langfuse_callback", host=settings.LANGFUSE_HOST, thread_id=thread_id, user_id=user_id
            )
            handler = CallbackHandler()
            handler.metadata = {"thread_id": str(thread_id), "user_id": str(user_id) if user_id else None}  # type: ignore[attr-defined]
            return handler
        except Exception as e:
            logger.warning("failed_to_initialize_langfuse_callback", error=str(e))
            return None

    async def get_response(
        self,
        messages: list[Message],
        session_id: UUID,
        user_uuid: UUID | None = None,
    ) -> list[Message]:
        """Get non-streaming AI response with Langfuse tracing support."""
        agent = await self.get_agent()

        config: dict[str, Any] = {
            "configurable": {
                "thread_id": str(session_id),
                "user_uuid": str(user_uuid) if user_uuid else None,
            },
        }

        langfuse_handler = self._get_langfuse_callback(session_id, user_uuid)
        if langfuse_handler:
            config["callbacks"] = [langfuse_handler]

        lc_messages = []
        if messages:
            last_msg = messages[-1]
            lc_messages = [
                HumanMessage(content=last_msg.content)
                if last_msg.role == "user"
                else AIMessage(content=last_msg.content)
            ]

        input_data = {"messages": lc_messages}

        result = await agent.ainvoke(input_data, config=config)

        if result and "messages" in result:
            new_msgs = result["messages"]
            for msg in reversed(new_msgs):
                if isinstance(msg, AIMessage) and msg.content:
                    text = self._extract_text_content(msg.content)
                    return [Message(role="assistant", content=text)]

        return []
