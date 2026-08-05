import 'dart:async';
import 'package:logging/logging.dart';
import 'package:genui/genui.dart' as genui;
import 'package:finvo/features/chat/services/custom_content_generator.dart';

final _logger = Logger('ExtendedGenUiConversation');

/// Extended GenUI conversation manager
///
/// Encapsulates GenUI 0.8.0's Conversation facade with additional
/// session management and callback wiring.
class ExtendedGenUiConversation {
  final CustomContentGenerator _customGenerator;
  final genui.Conversation _conversation;
  final genui.SurfaceController _controller;
  StreamSubscription<dynamic>? _eventsSubscription;
  String? _currentSessionId;

  // Callbacks
  final void Function(String) _onTextResponse;
  final void Function(String, dynamic) _onError;

  ExtendedGenUiConversation({
    required genui.SurfaceController controller,
    required CustomContentGenerator contentGenerator,
    required void Function(String) onSurfaceAdded,
    required void Function(String) onSurfaceDeleted,
    required this._onTextResponse,
    required this._onError,
    void Function(String, String?)? onSessionInit,
  }) : _controller = controller,
       _customGenerator = contentGenerator,
       _conversation = genui.Conversation(
         controller: controller,
         transport: contentGenerator,
       ) {
    // Listen to Conversation events for surface lifecycle
    _eventsSubscription = _conversation.events.listen((event) {
      switch (event) {
        case genui.ConversationSurfaceAdded(:final surfaceId):
          _logger.info('ExtendedGenUiConversation: Surface added: $surfaceId');
          onSurfaceAdded(surfaceId);
        case genui.ConversationSurfaceRemoved(:final surfaceId):
          _logger.info(
            'ExtendedGenUiConversation: Surface deleted: $surfaceId',
          );
          onSurfaceDeleted(surfaceId);
        case genui.ConversationError(:final error):
          _onError(error.toString(), error);
        default:
          break;
      }
    });

    // Listen to Session initialization events
    _customGenerator.onSessionInit = (String sessionId, String? messageId) {
      _logger.info(
        'ExtendedGenUiConversation: Session initialized: $sessionId',
      );
      _currentSessionId = sessionId;
      onSessionInit?.call(sessionId, messageId);
    };

    // Listen to text stream
    _customGenerator.onTextChunk = _onTextResponse;

    // Listen to errors (Requirement 2.1)
    _customGenerator.onError = (String error) {
      _onError(error, error);
    };
  }

  /// Get current Session ID
  String? get currentSessionId => _currentSessionId;

  /// Expose the content generator for callback registration
  CustomContentGenerator get contentGenerator => _customGenerator;

  /// Set current Session ID
  void setSessionId(String sessionId) {
    _currentSessionId = sessionId;
    _customGenerator.setSessionId(sessionId);
  }

  /// Send text message (Requirement 1.1)
  Future<void> sendRequest(genui.ChatMessage message) async {
    return _customGenerator.sendRequest(message);
  }

  /// Unified send entry: send message with attachments (Requirement 1.4)
  Future<void> sendRequestWithAttachments(
    String content, {
    List<Map<String, dynamic>>? attachments,
  }) async {
    _logger.info(
      'ExtendedGenUiConversation: Sending request with ${attachments?.length ?? 0} attachments',
    );

    // Call CustomContentGenerator's extended method
    await _customGenerator.sendRequestWithAttachments(
      content,
      sessionId: _currentSessionId,
      attachments: attachments,
    );
  }

  /// Cancel current request
  void cancel() {
    _customGenerator.cancel();
  }

  /// Clear current session
  void clearSession() {
    _currentSessionId = null;
    _customGenerator.clearSessionToken();
  }

  /// Resource release
  void dispose() {
    unawaited(_eventsSubscription?.cancel());
    _eventsSubscription = null;
    _customGenerator.dispose();
  }

  /// Compatibility setter for old code
  set onUserMessageSent(void Function(String)? callback) {
    _customGenerator.onUserMessageSent = callback;
  }

  /// Expose internal Host (SurfaceController) for UI rendering
  genui.SurfaceHost get host => _controller;
}
