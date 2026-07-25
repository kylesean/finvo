"""Unit tests for the ephemeral-multimodal design (plan: lively-orbiting-anchor).

Verifies the model-view vs stored-state separation:
- The vision guard short-circuits a non-vision model before any LLM call.
- The model node enriches the *prompt* transiently without mutating state.
- AttachmentMiddleware no longer rewrites the stored user message; it only
  publishes ephemeral data via config.
"""

from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock, patch

from langchain_core.messages import AIMessage, HumanMessage, SystemMessage

from app.core.langgraph.agent.nodes import create_agent_node
from app.core.langgraph.middleware.attachment import AttachmentMiddleware


def _make_llm():
    llm = MagicMock()
    bound = MagicMock()
    bound.ainvoke = AsyncMock(return_value=AIMessage(content="ok"))
    llm.bind_tools.return_value = bound
    return llm, bound


async def test_vision_guard_short_circuits_without_llm_call():
    llm, bound = _make_llm()
    node = create_agent_node(llm, tools=[], system_prompt="sys")

    state = {"messages": [HumanMessage(content="", additional_kwargs={"attachment_ids": ["a1"]})]}
    config = {"configurable": {"_has_images": True}}

    with patch("app.services.llm.LLMRegistry.supports_vision", return_value=False):
        result = await node(state, config)

    # A single localized assistant error, no tool_calls → router sends us to END.
    assert len(result["messages"]) == 1
    assert isinstance(result["messages"][0], AIMessage)
    assert result["messages"][0].content  # non-empty localized message
    # The LLM must NOT have been invoked.
    llm.bind_tools.assert_not_called()
    bound.ainvoke.assert_not_called()


async def test_enrichment_is_transient_and_does_not_pollute_state():
    llm, bound = _make_llm()
    node = create_agent_node(llm, tools=[], system_prompt="sys")

    image_part = {"type": "image_url", "image_url": {"url": "data:image/png;base64,AAA"}}
    original = HumanMessage(content="hi", additional_kwargs={"attachment_ids": ["a1"]})
    state = {"messages": [original]}
    config = {
        "configurable": {
            "_has_images": True,
            "_image_multimodal_parts": [image_part],
            "user_uuid": "u",
        }
    }

    with (
        patch("app.services.llm.LLMRegistry.supports_vision", return_value=True),
        patch(
            "app.core.langgraph.agent.nodes.load_image_parts",
            new=AsyncMock(return_value=[]),
        ) as load_spy,
    ):
        result = await node(state, config)

    # Normal response path.
    assert isinstance(result["messages"][0], AIMessage)

    # The prompt the model saw must carry the multimodal content...
    prompt = bound.ainvoke.call_args.args[0]
    assert isinstance(prompt[0], SystemMessage)
    humans = [m for m in prompt if isinstance(m, HumanMessage)]
    assert len(humans) == 1
    assert isinstance(humans[0].content, list)
    assert humans[0].content[0] == {"type": "text", "text": "hi"}
    assert image_part in humans[0].content

    # ...but the *stored* state message is untouched (still a plain string),
    # and we used the middleware cache rather than hitting the DB.
    assert state["messages"][0].content == "hi"
    assert isinstance(state["messages"][0].content, str)
    load_spy.assert_not_called()


async def test_resume_path_self_loads_when_cache_absent():
    llm, bound = _make_llm()
    node = create_agent_node(llm, tools=[], system_prompt="sys")

    image_part = {"type": "image_url", "image_url": {"url": "data:image/png;base64,ZZZ"}}
    original = HumanMessage(content="receipt", additional_kwargs={"attachment_ids": ["a1"]})
    state = {"messages": [original]}
    # No `_image_multimodal_parts` (resume bypasses middleware) → node must self-load.
    config = {"configurable": {"_has_images": True, "user_uuid": "u"}}

    with (
        patch("app.services.llm.LLMRegistry.supports_vision", return_value=True),
        patch(
            "app.core.langgraph.agent.nodes.load_image_parts",
            new=AsyncMock(return_value=[image_part]),
        ) as load_spy,
    ):
        await node(state, config)

    load_spy.assert_awaited_once_with(["a1"], "u")
    prompt = bound.ainvoke.call_args.args[0]
    humans = [m for m in prompt if isinstance(m, HumanMessage)]
    assert isinstance(humans[0].content, list)
    assert image_part in humans[0].content
    # State still clean.
    assert state["messages"][0].content == "receipt"


def _middleware_with_image_loaded():
    mw = AttachmentMiddleware(db_session_factory=lambda: None)
    img = SimpleNamespace(
        id="img-1",
        mime_type="image/png",
        object_key="k.png",
        filename="k.png",
    )
    mw._load_attachments = AsyncMock(return_value=[img])
    return mw, img


async def test_middleware_does_not_rewrite_user_message_and_stashes_config():
    mw, _img = _middleware_with_image_loaded()
    user_msg = HumanMessage(content="receipt photo")
    config = {
        "configurable": {
            "attachment_ids": ["a1"],
            "user_uuid": "u",
            "thread_id": "t",
        }
    }

    with (
        patch("app.services.llm.LLMRegistry.supports_vision", return_value=True),
        patch(
            "app.core.langgraph.middleware.attachment.image_parts_from_attachments",
            new=AsyncMock(return_value=[{"type": "image_url"}]),
        ) as parts_spy,
    ):
        out_messages, out_config = await mw.before_invoke([user_msg], config)

    # The stored user message is NOT rewritten: content stays the original string.
    assert out_messages[0].content == "receipt photo"
    assert isinstance(out_messages[0].content, str)
    assert "attachment_ids" not in (out_messages[0].additional_kwargs or {})

    # Ephemeral data lives in config only.
    cfg = out_config["configurable"]
    assert cfg["_has_images"] is True
    assert cfg["_image_multimodal_parts"] == [{"type": "image_url"}]
    parts_spy.assert_awaited_once()


async def test_middleware_skips_base64_build_for_non_vision():
    mw, _img = _middleware_with_image_loaded()
    user_msg = HumanMessage(content="receipt photo")
    config = {
        "configurable": {
            "attachment_ids": ["a1"],
            "user_uuid": "u",
            "thread_id": "t",
        }
    }

    with (
        patch("app.services.llm.LLMRegistry.supports_vision", return_value=False),
        patch(
            "app.core.langgraph.middleware.attachment.image_parts_from_attachments",
            new=AsyncMock(return_value=[{"type": "image_url"}]),
        ) as parts_spy,
    ):
        _out_messages, out_config = await mw.before_invoke([user_msg], config)

    cfg = out_config["configurable"]
    assert cfg["_has_images"] is True  # guard flag still set
    assert "_image_multimodal_parts" not in cfg  # no wasted base64 work
    parts_spy.assert_not_called()
