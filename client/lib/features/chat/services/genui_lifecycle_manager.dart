// features/chat/services/genui_lifecycle_manager.dart

import 'dart:async';
import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/chat/genui/app_catalog.dart';
import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/models/genui_surface_info.dart';
import 'package:finvo/features/chat/models/tool_call_info.dart';
import 'package:finvo/features/chat/repositories/message_repository.dart';
import 'package:finvo/features/chat/services/genui_logger.dart';
import 'package:finvo/features/chat/services/genui_service.dart';
import 'package:finvo/features/chat/services/custom_content_generator.dart';

final _logger = Logger('GenUiLifecycleManager');

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

  // Callbacks to interact with standard ChatNotifier state
  final String Function() _getCurrentStreamingMessageId;
  final void Function(double amount, String type, String currency)
  _onTransactionCreated;
  final void Function(String sessionId, String? messageId) _onSessionInit;
  final void Function(String text) _onTextResponse;
  final void Function() _onStreamComplete;
  final void Function() _markFirstChunkReceived;
  final void Function(String title) _onTitleUpdate;
  final void Function(ToolCallInfo)? _onToolCallStart;
  final void Function(ToolCallInfo)? _onToolCallEnd;

  GenUiService? _genUiService;

  // Surface lifecycle tracking (surfaceId -> SurfaceInfo)
  final Map<String, GenUiSurfaceInfo> _surfaceRegistry = {};

  // Message to surfaces mapping
  final Map<String, List<String>> _messageSurfaceIds = {};

  // Metrics tracking
  int _totalSurfacesCreated = 0;
  int _totalReactiveUpdates = 0;
  int _totalSurfacesDeleted = 0;

  GenUiLifecycleManager({
    required this._secureStorageService,
    required this._messageRepository,
    required this._getCurrentStreamingMessageId,
    required this._onTransactionCreated,
    required this._onSessionInit,
    required this._onTextResponse,
    required this._onStreamComplete,
    required this._markFirstChunkReceived,
    required this._onTitleUpdate,
    this._onToolCallStart,
    this._onToolCallEnd,
  });

  bool get isInitialized => _genUiService?.isInitialized ?? false;
  GenUiService? get service => _genUiService;

  // Metrics getters
  int get totalSurfacesCreated => _totalSurfacesCreated;
  int get totalReactiveUpdates => _totalReactiveUpdates;
  int get totalSurfacesDeleted => _totalSurfacesDeleted;
  int get activeSurfaceCount => _surfaceRegistry.length;

  /// Initialize GenUI service
  Future<void> initialize({Dio? dio, required String sseBaseUrl}) async {
    try {
      _genUiService = GenUiService();
      await _genUiService!.initialize(
        catalog: AppCatalog.build(),
        storageService: _secureStorageService,
        sseBaseUrl: sseBaseUrl,
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
        dio: dio,
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

  void dispose() {
    unawaited(_genUiService?.dispose());
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

  /// Handle DataModelUpdate - mark surface as updated
  void handleDataModelUpdate(String surfaceId, String path) {
    updateSurfaceStatus(surfaceId, SurfaceStatus.updated);
    _logger.info(
      'GenUiLifecycleManager: DataModelUpdate for $surfaceId at path $path',
    );
  }

  /// Handle DeleteSurface event
  void handleDeleteSurface(String surfaceId) {
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
    _logger.info('GenUiLifecycleManager: Surface added - $surfaceId');

    if (surfaceId.startsWith('history_')) {
      return;
    }

    final messageId = _findTargetMessageIdForSurface(surfaceId);
    if (messageId.isEmpty) return;

    _registerSurface(surfaceId, messageId);
  }

  void _handleSurfaceIdAdded(String surfaceId) {
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
    _logger.info('GenUiLifecycleManager: Surface removed - $surfaceId');
    handleDeleteSurface(surfaceId);
  }

  void _handleGenUiError(String error) {
    // Log and update message state
    _logger.warning('GenUiLifecycleManager: GenUI error: $error');

    // Converter logic (localized via i18n)
    String userFriendlyMessage;
    if (error.contains('No generations') || error.contains('empty stream')) {
      userFriendlyMessage = t.genui.errorBusy;
    } else if (error.contains('timeout') || error.contains('Timeout')) {
      userFriendlyMessage = t.genui.errorTimeout;
    } else if (error.contains('network') || error.contains('connection')) {
      userFriendlyMessage = t.genui.errorNetwork;
    } else if (error.contains('Authentication') || error.contains('token')) {
      userFriendlyMessage = t.genui.errorSessionExpired;
    } else {
      userFriendlyMessage = t.genui.errorGeneric;
    }

    final currentId = _getCurrentStreamingMessageId();
    if (currentId.isNotEmpty) {
      _messageRepository.updateAiMessageState(
        id: currentId,
        content: userFriendlyMessage,
        isTyping: false,
        streamingStatus: StreamingStatus.error,
      );
    }
  }

  String _findTargetMessageIdForSurface(String surfaceId) {
    final messageId = _getCurrentStreamingMessageId();
    if (messageId.isNotEmpty) {
      return messageId;
    }

    // Fallback: find last AI message
    final messages = _messageRepository.getCurrentMessages();
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].sender != MessageSender.ai) {
        continue;
      }
      if (messages[i].sender != MessageSender.user) {
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
    if (_genUiService == null || !_genUiService!.isInitialized) {
      _logger.info('GenUiLifecycleManager: Service not initialized');
      return;
    }

    final surfaceId = 'surface_$uuidV4';

    // Use replayHistoricalSurface which handles CreateSurface + UpdateComponents
    _genUiService!.replayHistoricalSurface(
      surfaceId: surfaceId,
      componentType: componentName,
      data: componentData,
    );

    final messageId = _getCurrentStreamingMessageId();
    if (messageId.isNotEmpty) {
      _registerSurface(surfaceId, messageId);
    }
  }
}
