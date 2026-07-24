// SSE event handler registry
//
// Design patterns:
// - Strategy Pattern: each event type maps to a handler
// - Registry Pattern: unified management of all handlers
//
// Design intent:
// - Eliminate large switch statement in _handleSseEvent
// - Support extending event handling by registering new handlers
// - Improve code testability and maintainability

import 'package:logging/logging.dart';
import 'package:a2ui_core/a2ui_core.dart' as a2ui;
import '../models/sse_event_models.dart';

final _logger = Logger('SseEventHandlerRegistry');

/// SSE event handling context
class SseEventContext {
  final void Function(String?) setSessionId;
  final String? Function() getCurrentSessionId;
  final void Function(a2ui.A2uiMessage) addA2uiMessage;
  final void Function(String) addTextResponse;
  final SseEventCallbacks callbacks;
  final StringBuffer textBuffer;

  const SseEventContext({
    required this.setSessionId,
    required this.getCurrentSessionId,
    required this.addA2uiMessage,
    required this.addTextResponse,
    required this.callbacks,
    required this.textBuffer,
  });
}

/// SSE event handler abstract base class
abstract class SseEventHandler {
  Future<void> handle(Map<String, dynamic> data, SseEventContext context);
}

/// session_init event handler
class SessionInitHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    final metadata = data['metadata'] as Map<String, dynamic>?;
    if (metadata != null) {
      final sessionId = metadata['session_id'] as String?;
      final messageId = metadata['message_id'] as String?;

      _logger.info('Session initialized - id: $sessionId, message: $messageId');

      context.setSessionId(sessionId);
      if (sessionId != null) {
        context.callbacks.onSessionInit?.call(sessionId, messageId);
      }
    }
  }
}

/// text_delta event handler
class TextDeltaHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    final content = data['content'] as String?;
    if (content != null && content.isNotEmpty) {
      context.textBuffer.write(content);
      context.addTextResponse(content);
      context.callbacks.onTextChunk?.call(content);
    }
  }
}

/// title_update event handler
class TitleUpdateHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    final title = data['title'] as String?;
    if (title != null && title.isNotEmpty) {
      _logger.info('Title update: $title');
      context.callbacks.onTitleUpdate?.call(title);
    }
  }
}

/// a2ui_message event handler
class A2uiMessageHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    final a2uiMessageData = data['data'] as Map<String, dynamic>?;

    if (a2uiMessageData == null || a2uiMessageData.isEmpty) {
      _logger.warning('[A2UI] ERROR: No data field or empty');
      return;
    }

    try {
      final a2uiMessage = a2ui.A2uiMessage.fromJson(a2uiMessageData);
      context.addA2uiMessage(a2uiMessage);

      if (a2uiMessageData.containsKey('surfaceUpdate')) {
        final surfaceUpdate =
            a2uiMessageData['surfaceUpdate'] as Map<String, dynamic>?;
        if (surfaceUpdate != null) {
          final surfaceId = surfaceUpdate['surfaceId'] as String?;
          if (surfaceId != null) {
            context.callbacks.onSurfaceCreated?.call(surfaceId);
          }
        }
      }
    } catch (e) {
      _logger.severe('[A2UI] ERROR parsing message: $e');
    }
  }
}

/// tool_call_start event handler
class ToolCallStartHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    final eventData = data['data'] as Map<String, dynamic>?;
    if (eventData != null) {
      final event = ToolCallStartEvent.fromJson(eventData);
      _logger.info('Tool call start - ${event.name} (${event.id})');
      context.callbacks.onToolCallStart?.call(event);
    }
  }
}

/// tool_call_end event handler
class ToolCallEndHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    final eventData = data['data'] as Map<String, dynamic>?;
    if (eventData != null) {
      final event = ToolCallEndEvent.fromJson(eventData);
      _logger.info(
        'Tool call end - ${event.name} (${event.id}) '
        'status: ${event.status}, duration: ${event.durationMs}ms',
      );
      context.callbacks.onToolCallEnd?.call(event);
    }
  }
}

/// done event handler
class DoneHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    _logger.info('Stream completed (done event)');
    context.textBuffer.clear();
  }
}

/// Error event handler
class ErrorHandler implements SseEventHandler {
  @override
  Future<void> handle(
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    final content = data['content'] as String?;
    if (content != null) {
      _logger.warning('Error from backend: $content');
      context.callbacks.onError?.call(content);
    }
  }
}

/// SSE event handler registry
class SseEventHandlerRegistry {
  static final Map<String, SseEventHandler> _handlers = {};
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    register('session_init', SessionInitHandler());
    register('text_delta', TextDeltaHandler());
    register('title_update', TitleUpdateHandler());
    register('a2ui_message', A2uiMessageHandler());
    register('tool_call_start', ToolCallStartHandler());
    register('tool_call_end', ToolCallEndHandler());
    register('done', DoneHandler());
    register('error', ErrorHandler());

    _initialized = true;
    _logger.info(
      'SseEventHandlerRegistry initialized with ${_handlers.length} handlers',
    );
  }

  static void register(String eventType, SseEventHandler handler) {
    _handlers[eventType] = handler;
  }

  static Future<void> handle(
    String? eventType,
    Map<String, dynamic> data,
    SseEventContext context,
  ) async {
    if (eventType == null) return;

    initialize();

    final handler = _handlers[eventType];
    if (handler != null) {
      await handler.handle(data, context);
    } else {
      _logger.info('Unknown event type: $eventType');
    }
  }

  static List<String> get registeredEventTypes => _handlers.keys.toList();
}
