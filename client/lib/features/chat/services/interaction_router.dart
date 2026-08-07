/// Interaction Router
///
/// Outbound message router — classifies and converts genui [genui.ChatMessage] into backend payload.
///
/// Design rationale (single responsibility, pure logic, independently unit-testable):
/// - In genui 0.10 / A2UI v0.9, Surface button interactions arrive uniformly as "empty-text user message +
///   UiInteractionPart" (see SurfaceController.handleUiEvent); the old
///   "stuff {"userAction":...} into text" convention is deprecated.
/// - This component handles: message classification -> interaction parsing (typed accessor with mimeType validation) ->
///   dispatch business events via [GenUiEventRegistry] -> produce [OutgoingMessage].
/// - Contains no network or side effects; [CustomContentGenerator] only sends the result.
///
/// Behavioral contract (fully equivalent to pre-refactoring):
/// - SurfaceController.reportError feedback (interaction containing "error") is never forwarded.
/// - Registered business events (e.g. transfer_path_confirmed) produce human-readable text +
///   client_state mutation (ui_mode=direct_execute), backend executes atomically.
/// - Unregistered events fall back to `Action: <name>` (preserving current behavior).
library;

import 'dart:convert';

import 'package:genui/genui.dart' as genui;
import 'package:logging/logging.dart';

import 'package:finvo/features/chat/genui/events/interaction_events.dart';
import 'package:finvo/features/chat/genui/genui_event_registry.dart';
import 'package:finvo/features/chat/models/client_state_mutation.dart';

final _logger = Logger('InteractionRouter');

/// Typed result of an outbound message.
///
/// Replaces the pre-refactoring loose Map + `_skip` sentinel key return convention.
class OutgoingMessage {
  /// Message payload list sent to backend.
  final List<Map<String, dynamic>> payload;

  /// GenUI atomic mode client_state mutation (nullable).
  /// When non-null, backend uses direct_execute, skipping LLM.
  final Map<String, dynamic>? clientState;

  /// Optimistic update content displayed to user (null means don't display).
  final String? displayContent;

  /// Whether to skip entirely (error feedback / empty content). When true, don't send or display.
  final bool skip;

  const OutgoingMessage({
    required this.payload,
    this.clientState,
    this.displayContent,
    this.skip = false,
  });

  /// Construct a "skipped" message.
  factory OutgoingMessage.skipped() =>
      const OutgoingMessage(payload: [], skip: true);
}

/// Outbound interaction router.
///
/// Pure logic component: routes a genui user message into [OutgoingMessage].
class InteractionRouter {
  /// Route a genui message to an outbound message.
  OutgoingMessage route(genui.ChatMessage message) {
    // sendRequest only receives user messages (controller.onSubmit); defensively skip non-user.
    if (message.role != genui.ChatMessageRole.user) {
      return OutgoingMessage.skipped();
    }

    // A2UI v0.9 interaction path: empty text + UiInteractionPart.
    final interaction = _extractInteraction(message);
    if (interaction != null) {
      return _routeInteraction(interaction);
    }

    // Plain text user message.
    final text = message.text;
    if (text.isEmpty) {
      return OutgoingMessage.skipped();
    }
    return OutgoingMessage(
      payload: [
        {'role': 'user', 'content': text},
      ],
      displayContent: text,
    );
  }

  /// Extract interaction JSON string using genui typed accessor.
  ///
  /// `uiInteractionParts` only matches DataPart with mimeType
  /// `application/vnd.genui.interaction+json`, avoiding mis-parsing attachments
  /// or other DataParts (pre-refactoring manual byte parsing ignored mimeType).
  String? _extractInteraction(genui.ChatMessage message) {
    final parts = message.parts.uiInteractionParts;
    return parts.isEmpty ? null : parts.first.interaction;
  }

  /// Parse interaction JSON and route.
  OutgoingMessage _routeInteraction(String interactionJson) {
    final Map<String, dynamic> inner;
    try {
      inner = jsonDecode(interactionJson) as Map<String, dynamic>;
    } catch (e) {
      // Malformed interaction payload from the AI layer: skip it, but keep
      // the failure diagnosable.
      _logger.warning('Skipping unparseable interaction JSON', e);
      return OutgoingMessage.skipped();
    }

    // SurfaceController.reportError feedback — never forward to backend
    // (would interrupt in-progress SSE stream and be rejected with 422).
    if (inner.containsKey('error')) {
      return OutgoingMessage.skipped();
    }

    // Action event: delegate to business registry for dispatch.
    final action = inner['action'];
    if (action is Map<String, dynamic>) {
      return _routeAction(action);
    }

    return OutgoingMessage.skipped();
  }

  /// Route action event through typed parsing and [GenUiEventRegistry] dispatch to construct outbound message.
  OutgoingMessage _routeAction(Map<String, dynamic> action) {
    final name = action['name'] as String?;
    final context = (action['context'] as Map<String, dynamic>?) ?? const {};

    // Typed decode: unknown event -> null, fall back to `Action: <name>` (preserving current behavior).
    final event = GenUiInteractionEvent.tryParse(name, context);
    if (event == null) {
      // Fall back to a readable label instead of rendering "Action: null"
      // when the payload carries no name.
      return _fallback('Action: ${name ?? 'unrecognized'}');
    }

    final result = GenUiEventRegistry.handle(event);
    if (result != null && !result.isEmpty) {
      final extensions = result.payloadExtensions;
      final content =
          (extensions?['content'] as String?) ?? 'Action: ${event.eventName}';
      return OutgoingMessage(
        payload: [
          extensions ?? {'role': 'user', 'content': content},
        ],
        clientState: result.mutation?.toJson(),
        displayContent: content,
      );
    }

    // Known event but no business handler (e.g. transaction confirmation) -> fallback, preserving pre-refactoring behavior.
    return _fallback('Action: ${event.eventName}');
  }

  /// Construct fallback outbound message (unregistered / no business handler events).
  OutgoingMessage _fallback(String content) {
    return OutgoingMessage(
      payload: [
        {'role': 'user', 'content': content},
      ],
      displayContent: content,
    );
  }
}
