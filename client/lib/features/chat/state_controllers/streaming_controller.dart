// features/chat/state_controllers/streaming_controller.dart
//
// Streaming Controller
// Extracted from ChatHistory to manage SSE streaming lifecycle
//
// Design Principles:
// - Encapsulates all streaming-related logic
// - Uses callbacks to communicate with host (ChatHistory)
// - Manages timers, cancellation, and stream state
//

import 'dart:async';
import 'package:logging/logging.dart';

import 'package:finvo/features/chat/models/chat_message.dart'
    show StreamingStatus;
import 'package:finvo/features/chat/services/genui_service.dart';
import 'package:finvo/features/chat/state_controllers/stream_state_controller.dart';

final _logger = Logger('StreamingController');

/// Callbacks for streaming events
typedef OnStreamingStartCallback = void Function();
typedef OnTextReceivedCallback = void Function(String text);
typedef OnStreamCompleteCallback = void Function(String? finalTextOverride);
typedef OnStreamErrorCallback = void Function(Object error);
typedef OnStreamCancelledCallback = void Function(bool hasContent);
typedef OnInitialDelayExceededCallback = void Function();
typedef UpdateMessageStateCallback =
    void Function({
      required String id,
      String? content,
      bool? isTyping,
      StreamingStatus? streamingStatus,
    });
typedef GetCurrentMessageContentCallback = String Function(String messageId);

/// Streaming Controller Configuration
class StreamingConfig {
  /// Initial delay before showing "AI is thinking..." (ms)
  final int initialDelayMs;

  /// Cancel wait timeout (seconds)
  final int cancelTimeoutSeconds;

  const StreamingConfig({
    this.initialDelayMs = 700,
    this.cancelTimeoutSeconds = 2,
  });

  static const defaultConfig = StreamingConfig();
}

/// Streaming Controller
///
/// Manages SSE streaming lifecycle, including:
/// - Stream startup and monitoring
/// - Timer management (initial delay)
/// - Cancellation handling
/// - Error and completion handling
class StreamingController {
  /// Configuration
  final StreamingConfig config;

  /// GenUI service reference (injected)
  GenUiService? _genUiService;

  /// Stream state controller reference (injected)
  final StreamStateController streamState;

  /// Current streaming message ID
  String _currentMessageId = '';

  /// Timer for initial response delay
  Timer? _initialResponseDelayTimer;

  /// Pending cancel completer (for tracking cancel operation)
  Completer<void>? _pendingCancelCompleter;

  bool _isDisposed = false;

  // ============================================================
  // Callbacks
  // ============================================================

  /// Called when streaming should update message state
  final UpdateMessageStateCallback onUpdateMessageState;

  /// Called to get current message content
  final GetCurrentMessageContentCallback getCurrentMessageContent;

  /// Called when initial delay is exceeded (show "thinking...")
  final OnInitialDelayExceededCallback onInitialDelayExceeded;

  /// Called when stream completes successfully
  final OnStreamCompleteCallback onStreamComplete;

  /// Called when stream encounters error
  final OnStreamErrorCallback onStreamError;

  /// Called when user cancels stream
  final OnStreamCancelledCallback onStreamCancelled;

  StreamingController({
    this.config = StreamingConfig.defaultConfig,
    required this.streamState,
    required this.onUpdateMessageState,
    required this.getCurrentMessageContent,
    required this.onInitialDelayExceeded,
    required this.onStreamComplete,
    required this.onStreamError,
    required this.onStreamCancelled,
  });

  // ============================================================
  // Public Getters
  // ============================================================

  /// Get current streaming message ID
  String get currentMessageId => _currentMessageId;

  /// Check if stream is done
  bool get isStreamDone => streamState.isStreamDone;

  /// Check if first chunk received
  bool get isFirstChunkReceived => streamState.isFirstChunkReceived;

  /// Check if message completed
  bool get isMessageCompleted => streamState.isMessageCompleted;

  /// Check if user cancelled
  bool get isUserCancelled => streamState.isUserCancelled;

  /// Check if there's a pending cancel operation
  bool get hasPendingCancel =>
      _pendingCancelCompleter != null && !_pendingCancelCompleter!.isCompleted;

  // ============================================================
  // Public Methods - Initialization
  // ============================================================

  /// Set GenUI service reference
  void setGenUiService(GenUiService? service) {
    _genUiService = service;
  }

  /// Update current streaming message ID without resetting stream state.
  ///
  /// Used when the server assigns a real message ID after `session_init`
  /// (replacing the optimistic temporary ID). Stream flags are preserved so
  /// subsequent text/tool-call events continue to target the same message.
  void updateCurrentMessageId(String messageId) {
    if (messageId.isEmpty) return;
    if (_currentMessageId == messageId) return;
    _logger.info(
      'StreamingController: Updating message ID $_currentMessageId -> $messageId',
    );
    _currentMessageId = messageId;
    streamState.updateMessageId(messageId);
  }

  // ============================================================
  // Public Methods - Stream Lifecycle
  // ============================================================

  /// Reset state for a new streaming session
  void resetForNewMessage(String messageId) {
    _currentMessageId = messageId;
    streamState.startStreaming(messageId);

    _logger.info('StreamingController: Reset for message $messageId');
  }

  /// Start initial response delay timer
  ///
  /// If first chunk is not received within the delay, triggers callback
  /// to show "AI is thinking..." indicator
  void startInitialDelayTimer() {
    _initialResponseDelayTimer?.cancel();
    _initialResponseDelayTimer = Timer(
      Duration(milliseconds: config.initialDelayMs),
      () {
        if (!streamState.isFirstChunkReceived) {
          _logger.info(
            'StreamingController: Initial delay exceeded, showing thinking indicator',
          );
          onInitialDelayExceeded();
        }
      },
    );
  }

  /// Handle incoming text chunk
  ///
  /// Returns true if this was the first chunk
  bool handleTextChunk(String text) {
    if (text.isEmpty) return false;

    _initialResponseDelayTimer?.cancel();

    final isFirst = !streamState.isFirstChunkReceived;
    if (isFirst) {
      streamState.markFirstChunkReceived();
      _logger.info('StreamingController: First chunk received');
    }

    return isFirst;
  }

  /// Mark first chunk as received (for UI components)
  void markFirstChunkReceived() {
    if (!streamState.isFirstChunkReceived) {
      streamState.markFirstChunkReceived();
    }
  }

  /// Manually mark message as completed
  void markMessageCompleted() {
    streamState.markCompleted();
  }

  /// Mark stream as ended (without triggering callbacks)
  void markStreamEnded({bool isError = false}) {
    _initialResponseDelayTimer?.cancel();
    if (isError) {
      streamState.markError();
    } else {
      streamState.markCompleted();
    }
  }

  /// Handle stream completion
  void handleStreamComplete(String? finalTextOverride) {
    _initialResponseDelayTimer?.cancel();
    streamState.markCompleted();

    onStreamComplete(finalTextOverride);
  }

  /// Handle stream error
  void handleStreamError(Object error) {
    _initialResponseDelayTimer?.cancel();
    streamState.markError();

    onStreamError(error);
  }

  /// Cancel pending stream (called from UI)
  ///
  /// Returns a Future that completes when cancel operation is done
  Future<void> cancelPendingOperation({
    required Future<bool> Function(String sessionId) cancelLastTurn,
    String? sessionId,
  }) async {
    _logger.info('StreamingController: cancelPendingOperation called');

    // Set cancel flags BEFORE calling cancel()
    // cancel() may synchronously trigger onStreamComplete callback
    streamState.markCancelled();

    // Cancel the GenUI conversation
    if (_genUiService != null && _genUiService!.isInitialized) {
      _genUiService!.conversation.cancel();
    }

    // Cancel timers and subscriptions
    await cancelStreamAndTimers();

    // StreamStateController phase already reflects the cancelled state

    // Determine if message has content
    final hasContent = getCurrentMessageContent(
      _currentMessageId,
    ).trim().isNotEmpty;

    // Notify about cancellation
    onStreamCancelled(hasContent);

    // Clean checkpoint if session exists
    if (sessionId != null) {
      _logger.info(
        'StreamingController: Calling cancelLastTurn to clean checkpoint',
      );

      _pendingCancelCompleter = Completer<void>();
      final completer = _pendingCancelCompleter!;

      // Fire-and-forget checkpoint cleanup. Extract the chain into a local
      // async closure so the completion bookkeeping lives in `finally` and
      // every error is funneled through a single try/catch (M13).
      Future<void> cleanCheckpoint() async {
        try {
          final success = await cancelLastTurn(sessionId);
          if (success) {
            _logger.info(
              'StreamingController: Checkpoint cleaned successfully',
            );
          } else {
            _logger.info('StreamingController: Checkpoint cleanup failed');
          }
        } catch (e) {
          _logger.warning('StreamingController: Cancel error: $e');
        } finally {
          if (!completer.isCompleted) {
            completer.complete();
          }
          _pendingCancelCompleter = null;
        }
      }

      unawaited(cleanCheckpoint());
    }

    _logger.info('StreamingController: Pending operation cancelled');
  }

  /// Wait for pending cancel operation to complete
  Future<void> waitForPendingCancel() async {
    if (_pendingCancelCompleter != null &&
        !_pendingCancelCompleter!.isCompleted) {
      _logger.info(
        'StreamingController: Waiting for pending cancel to complete...',
      );
      await _pendingCancelCompleter!.future.timeout(
        Duration(seconds: config.cancelTimeoutSeconds),
        onTimeout: () {
          _logger.info(
            'StreamingController: Cancel wait timeout, proceeding anyway',
          );
        },
      );
      _logger.info('StreamingController: Pending cancel completed');
    }
  }

  /// Cancel stream timers and any in-flight GenUI SSE request.
  ///
  /// Switching or creating a new conversation MUST tear down an in-flight
  /// stream, otherwise late SSE events (session_init, text_delta) would arrive
  /// after the switch and hijack the new conversation's state (stale sessionId
  /// written back, text appended to the wrong message). `cancel()` is
  /// idempotent: it no-ops when no request is in flight and drives the stream
  /// to its terminal state (onStreamComplete) instead of leaving it dangling.
  Future<void> cancelStreamAndTimers() async {
    _initialResponseDelayTimer?.cancel();

    if (_genUiService != null && _genUiService!.isInitialized) {
      _logger.info(
        'StreamingController: Cancelling in-flight GenUI stream on switch',
      );
      _genUiService!.conversation.cancel();
    }
  }

  /// Dispose controller.
  ///
  /// Awaits any in-flight cancel so a keepAlive rebuild fully tears down the
  /// old stream before a new controller is created, avoiding a short window in
  /// which two controllers coexist. Idempotent: a second call no-ops.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await cancelStreamAndTimers();
    _pendingCancelCompleter = null;
  }
}
