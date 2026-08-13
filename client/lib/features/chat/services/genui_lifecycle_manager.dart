// features/chat/services/genui_lifecycle_manager.dart

import 'dart:async';
import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/chat/genui/app_catalog.dart';
import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/models/genui_config.dart';
import 'package:finvo/features/chat/models/genui_surface_info.dart';
import 'package:finvo/features/chat/models/tool_call_info.dart';
import 'package:finvo/features/chat/repositories/message_repository.dart';
import 'package:finvo/features/chat/services/genui_logger.dart';
import 'package:finvo/features/chat/services/genui_service.dart';
import 'package:finvo/features/chat/services/custom_content_generator.dart';
import 'package:finvo/features/chat/services/genui_error_translator.dart';
// ignore_for_file: prefer_initializing_formals - private fields with public named ctor params

final _logger = Logger('GenUiLifecycleManager');

/// Groups callbacks used by [GenUiLifecycleManager] to communicate state updates.
class GenUiLifecycleCallbacks {
  final String Function() getCurrentStreamingMessageId;
  final void Function(double amount, String type, String currency)
  onTransactionCreated;
  final void Function(String sessionId, String? messageId) onSessionInit;
  final void Function(String text) onTextResponse;
  final void Function() onStreamComplete;
  final void Function() markFirstChunkReceived;
  final void Function(String title) onTitleUpdate;
  final void Function(ToolCallInfo)? onToolCallStart;
  final void Function(ToolCallInfo)? onToolCallEnd;

  const GenUiLifecycleCallbacks({
    required this.getCurrentStreamingMessageId,
    required this.onTransactionCreated,
    required this.onSessionInit,
    required this.onTextResponse,
    required this.onStreamComplete,
    required this.markFirstChunkReceived,
    required this.onTitleUpdate,
    this.onToolCallStart,
    this.onToolCallEnd,
  });
}

/// Manages the lifecycle of the GenUI service and handles surface events.
///
/// Enhanced features:
/// - Surface state tracking (loading/rendered/updated/error/removed)
/// - DeleteSurface event handling
/// - Session cleanup on close
/// - Reactive update metrics
class GenUiLifecycleManager {
  final SecureStorageService _secureStorageService;
  final MessageRepository _messageRepository;
  final GenUiLifecycleCallbacks _callbacks;

  GenUiService? _genUiService;
  bool _isDisposed = false;

  // Surface lifecycle tracking (surfaceId -> SurfaceInfo)
  final Map<String, GenUiSurfaceInfo> _surfaceRegistry = {};

  // Message to surfaces mapping
  final Map<String, List<String>> _messageSurfaceIds = {};

  // Metrics tracking
  int _totalSurfacesCreated = 0;
  int _totalReactiveUpdates = 0;
  int _totalSurfacesDeleted = 0;

  GenUiLifecycleManager({
    required SecureStorageService secureStorageService,
    required MessageRepository messageRepository,
    required GenUiLifecycleCallbacks callbacks,
  }) : _secureStorageService = secureStorageService,
       _messageRepository = messageRepository,
       _callbacks = callbacks;

  // Callbacks getters for internal use
  //
  // Every forwarding callback guards on [_isDisposed]: dispose() (which is
  // invoked unawaited during a keepAlive provider rebuild) is asynchronous
  // inside, so the old GenUI service may still deliver late events while the
  // teardown is in flight. Without these guards those late events would be
  // applied through the *old* repository/state closures onto the *new* chat
  // session — message cross-talk, duplicate completions, or surface leaks.
  String Function() get _getCurrentStreamingMessageId =>
      _callbacks.getCurrentStreamingMessageId;
  void Function(double amount, String type, String currency)
  get _onTransactionCreated {
    final cb = _callbacks.onTransactionCreated;
    return (amount, type, currency) {
      if (_isDisposed) return;
      cb(amount, type, currency);
    };
  }

  void Function(String sessionId, String? messageId) get _onSessionInit {
    final cb = _callbacks.onSessionInit;
    return (sessionId, messageId) {
      if (_isDisposed) return;
      cb(sessionId, messageId);
    };
  }

  void Function(String text) get _onTextResponse {
    final cb = _callbacks.onTextResponse;
    return (text) {
      if (_isDisposed) return;
      cb(text);
    };
  }

  void Function() get _onStreamComplete {
    final cb = _callbacks.onStreamComplete;
    return () {
      if (_isDisposed) return;
      cb();
    };
  }

  void Function() get _markFirstChunkReceived {
    final cb = _callbacks.markFirstChunkReceived;
    return () {
      if (_isDisposed) return;
      cb();
    };
  }

  void Function(String title) get _onTitleUpdate {
    final cb = _callbacks.onTitleUpdate;
    return (title) {
      if (_isDisposed) return;
      cb(title);
    };
  }

  void Function(ToolCallInfo)? get _onToolCallStart {
    final cb = _callbacks.onToolCallStart;
    if (cb == null) return null;
    return (toolCall) {
      if (_isDisposed) return;
      cb(toolCall);
    };
  }

  void Function(ToolCallInfo)? get _onToolCallEnd {
    final cb = _callbacks.onToolCallEnd;
    if (cb == null) return null;
    return (toolCall) {
      if (_isDisposed) return;
      cb(toolCall);
    };
  }

  bool get isInitialized => _genUiService?.isInitialized ?? false;
  GenUiService? get service => _genUiService;

  // Metrics getters
  int get totalSurfacesCreated => _totalSurfacesCreated;
  int get totalReactiveUpdates => _totalReactiveUpdates;
  int get totalSurfacesDeleted => _totalSurfacesDeleted;
  int get activeSurfaceCount => _surfaceRegistry.length;

  /// Initialize GenUI service
  ///
  /// [sseBaseUrlResolver] is resolved per request (not at init time) so a
  /// server switch mid-session takes effect without rebuilding the keepAlive
  /// chat service.
  Future<void> initialize({
    Dio? dio,
    required String Function() sseBaseUrlResolver,
  }) async {
    try {
      _genUiService = GenUiService();
      await _genUiService!.initialize(
        config: GenUiConfig(
          catalog: AppCatalog.build(),
          storageService: _secureStorageService,
          sseBaseUrlResolver: sseBaseUrlResolver,
          dio: dio,
        ),
        callbacks: GenUiCallbacks(
          onSurfaceAdded: _handleSurfaceAdded,
          onSurfaceRemoved: _handleSurfaceRemoved,
          onTextResponse: _onTextResponse,
          onSessionInit: _onSessionInit,
          onStreamComplete: _onStreamComplete,
          onTitleUpdate: _onTitleUpdate,
          onError: (msg, err) => _handleGenUiError(msg),
          onSurfaceIdAdded: _handleSurfaceIdAdded,
          onTransactionCreated: (data) => _onTransactionCreated(
            (data['amount'] as num?)?.toDouble() ?? 0.0,
            data['transactionType'] as String? ?? 'expense',
            data['currency'] as String? ?? 'CNY',
          ),
        ),
      );

      // Wire up tool call event callbacks
      final CustomContentGenerator contentGenerator =
          _genUiService!.conversation.contentGenerator;
      contentGenerator.onToolCallStart = (event) {
        _logger.info('GenUiLifecycleManager: Tool call start - ${event.name}');
        final toolCallInfo = ToolCallInfo(
          id: event.id,
          name: event.name,
          args: event.args,
          status: ToolExecutionStatus.running,
          timestamp: event.timestamp,
        );
        _onToolCallStart?.call(toolCallInfo);
      };

      contentGenerator.onToolCallEnd = (event) {
        _logger.info(
          'GenUiLifecycleManager: Tool call end - ${event.name}, ${event.status}',
        );
        final status = event.status == 'error'
            ? ToolExecutionStatus.error
            : ToolExecutionStatus.success;
        final toolCallInfo = ToolCallInfo(
          id: event.id,
          name: event.name,
          status: status,
          durationMs: event.durationMs,
          resultPreview: event.resultPreview,
          error: event.error,
        );
        _onToolCallEnd?.call(toolCallInfo);
      };

      _logger.info('GenUiLifecycleManager: Service initialized successfully');
      GenUiLogger.logInitialization(success: true);
    } catch (e, stackTrace) {
      _logger.severe(
        'GenUiLifecycleManager: Initialization failed',
        e,
        stackTrace,
      );
      GenUiLogger.logInitialization(success: false, errorMessage: e.toString());
    }
  }

  void setOnUserMessageSent(void Function(String) callback) {
    if (_genUiService != null) {
      _genUiService!.conversation.onUserMessageSent = callback;
    }
  }

  /// Release the GenUI service.
  ///
  /// Awaiting the underlying async cleanup guarantees the SSE controller and
  /// conversation are fully torn down before a keepAlive rebuild re-creates a
  /// new manager, so two live services can never coexist in the rebuild window.
  /// Idempotent: a second call no-ops.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await _genUiService?.dispose();
    } finally {
      _genUiService = null;
    }
    _clearAllSurfaces();
  }

  /// Clear all surfaces when session ends
  void clearSession() {
    _logger.info(
      'GenUiLifecycleManager: Clearing session - '
      '${_surfaceRegistry.length} surfaces, '
      'created=$_totalSurfacesCreated, '
      'updates=$_totalReactiveUpdates, '
      'deleted=$_totalSurfacesDeleted',
    );
    _clearAllSurfaces();
  }

  void _clearAllSurfaces() {
    _surfaceRegistry.clear();
    _messageSurfaceIds.clear();
  }

  // ============================================================
  // Surface State Management
  // ============================================================

  /// Get surface info by ID
  GenUiSurfaceInfo? getSurfaceInfo(String surfaceId) {
    return _surfaceRegistry[surfaceId];
  }

  /// Get all surfaces for a message
  List<GenUiSurfaceInfo> getSurfacesForMessage(String messageId) {
    final surfaceIds = _messageSurfaceIds[messageId] ?? [];
    return surfaceIds
        .map((id) => _surfaceRegistry[id])
        .whereType<GenUiSurfaceInfo>()
        .toList();
  }

  /// Update surface status
  void updateSurfaceStatus(String surfaceId, SurfaceStatus status) {
    if (_isDisposed) return;
    final existing = _surfaceRegistry[surfaceId];
    if (existing != null) {
      _surfaceRegistry[surfaceId] = existing.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _logger.fine(
        'GenUiLifecycleManager: Surface $surfaceId status -> $status',
      );

      // Track reactive updates
      if (status == SurfaceStatus.updated) {
        _totalReactiveUpdates++;
      }
    }
  }

  /// Handle DeleteSurface event
  void handleDeleteSurface(String surfaceId) {
    if (_isDisposed) return;
    final existing = _surfaceRegistry[surfaceId];
    if (existing != null) {
      updateSurfaceStatus(surfaceId, SurfaceStatus.removed);
      _surfaceRegistry.remove(surfaceId);
      _totalSurfacesDeleted++;

      // Remove from message mapping
      _messageSurfaceIds.forEach((messageId, surfaceIds) {
        surfaceIds.remove(surfaceId);
      });

      // Remove from message repository
      _messageRepository.removeSurfaceIdFromMessage(surfaceId);

      _logger.info('GenUiLifecycleManager: Deleted surface $surfaceId');
      GenUiLogger.logSurfaceLifecycle(
        event: 'deleted',
        surfaceId: surfaceId,
        messageId: existing.messageId,
      );
    }
  }

  // ============================================================
  // Event Handlers
  // ============================================================

  void _handleSurfaceAdded(String surfaceId) {
    if (_isDisposed) return;
    _logger.info('GenUiLifecycleManager: Surface added - $surfaceId');

    if (surfaceId.startsWith('history_')) {
      return;
    }

    final messageId = _findTargetMessageIdForSurface(surfaceId);
    if (messageId.isEmpty) return;

    _registerSurface(surfaceId, messageId);
  }

  void _handleSurfaceIdAdded(String surfaceId) {
    if (_isDisposed) return;
    _logger.info('GenUiLifecycleManager: Surface ID added - $surfaceId');

    final messageId = _findTargetMessageIdForSurface(surfaceId);
    if (messageId.isEmpty) return;

    // Mark content received (silent mode support)
    _markFirstChunkReceived();
    _logger.info(
      'GenUiLifecycleManager: Silent mode - UI component received, marking as first chunk',
    );

    _registerSurface(surfaceId, messageId);
  }

  void _registerSurface(String surfaceId, String messageId) {
    // Create surface info
    final surfaceInfo = GenUiSurfaceInfo(
      surfaceId: surfaceId,
      messageId: messageId,
      createdAt: DateTime.now(),
      status: SurfaceStatus.loading,
    );

    // Register in tracking
    _surfaceRegistry[surfaceId] = surfaceInfo;
    _messageSurfaceIds.putIfAbsent(messageId, () => []).add(surfaceId);
    _totalSurfacesCreated++;

    // Store in message repository
    _messageRepository.addSurfaceIdToMessage(messageId, surfaceId);

    GenUiLogger.logSurfaceLifecycle(
      event: 'added',
      surfaceId: surfaceId,
      messageId: messageId,
    );
  }

  void _handleSurfaceRemoved(String surfaceId) {
    if (_isDisposed) return;
    _logger.info('GenUiLifecycleManager: Surface removed - $surfaceId');
    handleDeleteSurface(surfaceId);
  }

  void _handleGenUiError(String error) {
    if (_isDisposed) return;
    // Log and update message state
    _logger.warning('GenUiLifecycleManager: GenUI error: $error');

    // Converter logic (localized via i18n using GenUiErrorTranslator)
    final userFriendlyMessage = GenUiErrorTranslator.translate(error);

    final currentId = _getCurrentStreamingMessageId();
    if (currentId.isNotEmpty) {
      // M-7: a late error (e.g. an A2UI payload parsed after the `done` event)
      // must not rewrite a message already in a terminal state — appending an
      // error footnote and flipping a completed message back to `error` would
      // misrepresent a finished turn as failed.
      final messages = _messageRepository.getCurrentMessages();
      StreamingStatus? currentStatus;
      for (final m in messages) {
        if (m.id == currentId) {
          currentStatus = m.streamingStatus;
          break;
        }
      }
      if (currentStatus == StreamingStatus.completed ||
          currentStatus == StreamingStatus.error) {
        _logger.info(
          'GenUiLifecycleManager: ignoring late GenUI error for terminal '
          'message $currentId',
        );
        return;
      }
      _messageRepository.updateAiMessageState(
        id: currentId,
        // Append the error note instead of replacing the already-streamed
        // content: the AI may have produced real paragraphs or a GenUI
        // surface before failing, and wiping them on error would discard
        // work the user already saw.
        contentDelta: '\n\n$userFriendlyMessage',
        isTyping: false,
        streamingStatus: StreamingStatus.error,
      );
    }

    // H-1: Guarantee the streaming state is reset on every error path.
    //
    // CustomContentGenerator pairs onError with onStreamComplete, but the
    // genui.ConversationError event (routed through ExtendedGenUiConversation)
    // fires onError alone. Without this fallback, isStreamingResponse stays
    // true forever and the chat UI locks up (stop button stuck, new messages
    // rejected). onStreamComplete is idempotent: when the message is already
    // marked completed it only clears isStreamingResponse, so double-firing is
    // safe.
    _onStreamComplete();
  }

  String _findTargetMessageIdForSurface(String surfaceId) {
    final messageId = _getCurrentStreamingMessageId();
    if (messageId.isNotEmpty) {
      return messageId;
    }

    // Fallback: find the last AI message (a surface arriving outside an
    // active stream belongs to the most recent AI turn).
    final messages = _messageRepository.getCurrentMessages();
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].sender == MessageSender.ai) {
        return messages[i].id;
      }
    }
    return '';
  }

  // Public method for UI Render Event (from SSE)
  void handleUiRenderEvent(
    String componentName,
    Map<String, dynamic> componentData,
    String uuidV4,
  ) {
    if (_isDisposed) return;
    if (_genUiService == null || !_genUiService!.isInitialized) {
      _logger.info('GenUiLifecycleManager: Service not initialized');
      return;
    }

    final surfaceId = 'surface_$uuidV4';

    // Use replayHistoricalSurface which handles CreateSurface + UpdateComponents
    final success = _genUiService!.replayHistoricalSurface(
      surfaceId: surfaceId,
      componentType: componentName,
      data: componentData,
    );

    if (success) {
      final messageId = _getCurrentStreamingMessageId();
      if (messageId.isNotEmpty) {
        _registerSurface(surfaceId, messageId);
      }
    }
  }
}
