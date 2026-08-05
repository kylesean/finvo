import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:genui/genui.dart' as genui;
import 'package:a2ui_core/a2ui_core.dart' as a2ui;
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/sse_event_models.dart';
import 'interaction_router.dart';

export '../models/sse_event_models.dart'
    show ToolCallStartEvent, ToolCallEndEvent;

final _logger = Logger('CustomContentGenerator');

// ============================================================
// Callback type definitions - GenUI architecture unified
// ============================================================

/// Session initialization callback - called when new session is created
typedef OnSessionInit = void Function(String sessionId, String? messageId);

/// Text chunk callback - called each time a text segment is received
typedef OnTextChunk = void Function(String text);

/// Stream completion callback - called when SSE stream normally ends
typedef OnStreamComplete = void Function();

/// Title update callback - called when session title is received
typedef OnTitleUpdate = void Function(String title);

/// Error callback - called when an error occurs
typedef OnErrorCallback = void Function(String error);

/// Message ID update callback - called when backend message ID is received
typedef OnMessageIdUpdate = void Function(String localId, String serverId);

/// Surface creation callback - called when SurfaceUpdate creates a new surface
/// Used for unified surface lifecycle management, triggering GenUI's onSurfaceAdded
typedef OnSurfaceCreated = void Function(String surfaceId);

typedef OnTransactionCreated =
    void Function(double amount, String transactionType, String currency);

/// Tool call start callback - called when tool execution starts (Claude Code style)
typedef OnToolCallStart = void Function(ToolCallStartEvent event);

/// Tool call end callback - called when tool execution completes (Claude Code style)
typedef OnToolCallEnd = void Function(ToolCallEndEvent event);

/// Custom Transport implementation, connecting to our SSE backend API
///
/// Implements Transport interface for GenUI 0.8+:
/// - incomingMessages: AI operation instruction stream (for creating/updating/deleting UI)
/// - incomingText: Text response stream
/// - sendRequest: Send user message to backend
class CustomContentGenerator implements genui.Transport {
  final SecureStorageService _storageService;

  /// Routes outgoing genui messages to backend payloads (pure logic, no I/O).
  final InteractionRouter _router = InteractionRouter();

  // Core stream controllers (Transport interface)
  final _a2uiMessageController = StreamController<a2ui.A2uiMessage>.broadcast();
  final _textResponseController = StreamController<String>.broadcast();

  // Note: uiRenderStream removed, unified through onSurfaceCreated callback

  // ============================================================
  // Callback fields - GenUI architecture unified
  // ============================================================
  OnSessionInit? onSessionInit;
  OnTextChunk? onTextChunk;
  OnStreamComplete? onStreamComplete;
  OnTitleUpdate? onTitleUpdate;
  OnErrorCallback? onError;
  OnMessageIdUpdate? onMessageIdUpdate;
  OnSurfaceCreated? onSurfaceCreated;
  OnToolCallStart? onToolCallStart;
  OnToolCallEnd? onToolCallEnd;
  OnTransactionCreated? onTransactionCreated;

  /// User message send callback - notifies upper layer to update UI when GenUI internally sends request
  void Function(String content)? onUserMessageSent;

  // Store current session ID (user authentication uses SecureStorageService's token)
  String? _currentSessionId;

  // =========================================================================
  // SSE stream cancellation mechanism
  // =========================================================================
  // Used to manage HTTP requests, calling close() can immediately interrupt all ongoing requests
  Dio? _dio;
  CancelToken? _cancelToken;
  // Cancellation flag - set to true when user clicks stop button
  bool _isCancelled = false;

  // URL configuration
  final String _sseBaseUrl;

  CustomContentGenerator(
    this._storageService, {
    this._dio,
    required this._sseBaseUrl,
  });

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Set current session ID
  void setSessionId(String sessionId) {
    _currentSessionId = sessionId;
  }

  /// Clear session token/ID
  void clearSessionToken() {
    _currentSessionId = null;
  }

  /// Cancel currently ongoing SSE request
  ///
  /// Immediately interrupts network connection and resets state
  void cancel() {
    _logger.info(
      'CustomContentGenerator: Public cancel() called - notifying complete',
    );
    _internalCancel(notifyComplete: true);
  }

  /// Internal cancellation logic
  ///
  /// [notifyComplete] - Whether to trigger onStreamComplete callback.
  /// When called by _sendRequestInternal to clean up old requests, should be set to false
  /// to prevent incorrectly ending the lifecycle of new requests.
  void _internalCancel({required bool notifyComplete}) {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _logger.info('CustomContentGenerator: Internal aborting active request');
      _isCancelled = true;
      _cancelToken?.cancel('User cancelled');
      _cancelToken = null;
    }

    // Only notify stream end when explicitly requested
    if (notifyComplete) {
      _logger.info('CustomContentGenerator: Notifying stream complete');
      onStreamComplete?.call();
    }
  }

  // Transport interface implementation
  @override
  Stream<a2ui.A2uiMessage> get incomingMessages =>
      _a2uiMessageController.stream;

  @override
  Stream<String> get incomingText => _textResponseController.stream;

  @override
  Future<void> sendRequest(genui.ChatMessage message) async {
    // Route the outgoing message: classify it, parse any UI interaction and
    // dispatch business events via GenUiEventRegistry (see InteractionRouter).
    // Error-feedback messages and empty content are skipped here, protecting
    // the in-flight SSE stream from interruption.
    final outgoing = _router.route(message);
    if (outgoing.skip) {
      _logger.info('CustomContentGenerator: Outgoing message skipped');
      return;
    }

    // Optimistic UI update. The [GENUI_INTERNAL] prefix tells the upper layer
    // to display the message without sending a duplicate request (the request
    // is already being sent below together with the atomic client_state).
    final content = outgoing.displayContent;
    if (content != null && content.isNotEmpty) {
      onUserMessageSent?.call(
        outgoing.clientState != null ? '[GENUI_INTERNAL]$content' : content,
      );
    }

    // Execute unified request logic.
    await _sendRequestInternal(
      messages: outgoing.payload,
      sessionId: _currentSessionId,
      clientState: outgoing.clientState,
    );
  }

  /// Unified entry: Send message to backend, supports attachments and session ID
  Future<void> sendRequestWithAttachments(
    String message, {
    String? sessionId,
    List<Map<String, dynamic>>? attachments,
    Map<String, dynamic>? stateUpdates,
  }) async {
    // Build simple message body
    final messagePayload = <String, dynamic>{
      'role': 'user',
      'content': message,
    };

    if (attachments != null && attachments.isNotEmpty) {
      messagePayload['attachments'] = attachments;
    }

    // Update current Session ID (if provided)
    if (sessionId != null) {
      _currentSessionId = sessionId;
    }

    // Execute unified request logic
    await _sendRequestInternal(
      messages: [messagePayload],
      sessionId: _currentSessionId,
      clientState: stateUpdates,
    );
  }

  /// Core internal request method: Unified handling of Session, ClientState and SSE stream
  Future<void> _sendRequestInternal({
    required List<Map<String, dynamic>> messages,
    String? sessionId,
    Map<String, dynamic>? clientState,
  }) async {
    // Defense in depth: never send empty/skipped messages to the backend.
    // A message is valid if it has non-empty content OR has attachments
    // (image-only messages are legitimate for multimodal LLMs).
    final hasValidContent = messages.any(
      (m) =>
          m['_skip'] != true &&
          (((m['content'] as String?) ?? '').isNotEmpty ||
              (m['attachments'] as List?)?.isNotEmpty == true),
    );
    if (!hasValidContent) {
      _logger.warning(
        'CustomContentGenerator: Skipping request with no valid content '
        '(protecting active stream from interruption)',
      );
      return;
    }

    // 0. Ensure any ongoing request is cancelled
    _internalCancel(notifyComplete: false);

    // Reset cancellation flag
    _isCancelled = false;

    try {
      // 1. Get user authentication token
      final token = await _storageService.getToken();
      _logger.info('CustomContentGenerator: Using session_id: $sessionId');

      if (token == null || token.isEmpty) {
        const error = 'Authentication token is missing';
        _logger.info('CustomContentGenerator: $error');
        onError?.call(error);
        return;
      }

      // 2. Build request
      final uri = Uri.parse('$_sseBaseUrl${ApiConstants.aiChatSseEndpoint}');

      _dio ??= Dio(
        BaseOptions(
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: const Duration(hours: 1),
          sendTimeout: const Duration(hours: 1),
        ),
      );
      _cancelToken = CancelToken();

      // Build request Body
      final body = <String, dynamic>{'messages': messages};

      if (sessionId != null) {
        body['session_id'] = sessionId;
        _logger.info(
          'CustomContentGenerator: Attaching session_id: $sessionId',
        );
      }

      if (clientState != null && clientState.isNotEmpty) {
        body['client_state'] = clientState;
        _logger.info(
          'CustomContentGenerator: Injected client_state for atomic mode',
        );
      }

      _logger.fine('CustomContentGenerator: Sending SSE request');

      // 3. Send request
      final response = await _dio!.post<ResponseBody>(
        uri.toString(),
        data: body,
        options: Options(
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.stream,
          validateStatus: (status) => true,
          // Force extremely long timeout: SSE stream may last a long time (e.g. AI executing scripts)
          receiveTimeout: const Duration(hours: 1),
          sendTimeout: const Duration(hours: 1),
        ),
        cancelToken: _cancelToken,
      );

      if (response.statusCode != 200) {
        final error = 'HTTP error: ${response.statusCode}';
        _logger.info('CustomContentGenerator: $error');
        onError?.call(error);
        return;
      }

      // 4. Process SSE stream response
      await for (final line
          in response.data!.stream
              .cast<List<int>>()
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (_isCancelled) {
          _logger.info(
            'CustomContentGenerator: Stream processing cancelled by user',
          );
          break;
        }

        if (line.isEmpty || !line.startsWith('data: ')) continue;

        try {
          final jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty) continue;

          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          final eventType = data['type'] as String?;

          await _handleSseEvent(eventType, data);
        } catch (e) {
          _logger.warning(
            'CustomContentGenerator: Error parsing SSE event: $e',
          );
        }
      }

      // Stream processing ended normally
      if (!_isCancelled) {
        _logger.info('CustomContentGenerator: Stream succeeded');
        onStreamComplete?.call();
      }
    } catch (e, stackTrace) {
      if (_isCancelled || (e is DioException && CancelToken.isCancel(e))) {
        _logger.info('CustomContentGenerator: Request cancelled by user');
        return;
      }

      _logger.severe(
        'CustomContentGenerator: Error in _sendRequestInternal',
        e,
        stackTrace,
      );
      onError?.call(e.toString());
    }
  }

  /// Handle SSE events
  Future<void> _handleSseEvent(
    String? eventType,
    Map<String, dynamic> data,
  ) async {
    switch (eventType) {
      case 'session_init':
        final metadata = data['metadata'] as Map<String, dynamic>?;
        if (metadata != null) {
          _currentSessionId = metadata['session_id'] as String?;
          final messageId = metadata['message_id'] as String?;
          _logger.info(
            'CustomContentGenerator: Session initialized - id: $_currentSessionId, message: $messageId',
          );

          if (_currentSessionId != null) {
            onSessionInit?.call(_currentSessionId!, messageId);
          }
        }
        break;

      case 'text_delta':
        final content = data['content'] as String?;
        if (content != null && content.isNotEmpty) {
          _textResponseController.add(content);
          onTextChunk?.call(content);
          // IMPORTANT: Yield to event loop to allow UI to update during streaming.
          // Without this, rapid SSE events are processed synchronously in a single frame,
          // causing Flutter to batch all state updates and only render at stream end.
          await Future<void>.delayed(Duration.zero);
        }
        break;

      case 'title_update':
        final title = data['title'] as String?;
        if (title != null && title.isNotEmpty) {
          _logger.info('CustomContentGenerator: Title update: $title');
          onTitleUpdate?.call(title);
        }
        break;

      case 'a2ui_message':
        await _handleA2uiMessage(data);
        break;

      case 'tool_call_start':
        final eventData = data['data'] as Map<String, dynamic>?;
        if (eventData != null) {
          final event = ToolCallStartEvent.fromJson(eventData);
          _logger.info(
            'CustomContentGenerator: Tool call start - ${event.name} (${event.id})',
          );
          onToolCallStart?.call(event);
          await Future<void>.delayed(Duration.zero);
        }
        break;

      case 'tool_call_end':
        final eventData = data['data'] as Map<String, dynamic>?;
        if (eventData != null) {
          final event = ToolCallEndEvent.fromJson(eventData);
          _logger.info(
            'CustomContentGenerator: Tool call end - ${event.name} (${event.id}) '
            'status: ${event.status}, duration: ${event.durationMs}ms',
          );
          onToolCallEnd?.call(event);
          await Future<void>.delayed(Duration.zero);
        }
        break;

      case 'done':
        _logger.info('CustomContentGenerator: Stream completed (done event)');
        break;

      default:
        _logger.info('CustomContentGenerator: Unknown event type: $eventType');
    }
  }

  Future<void> _handleA2uiMessage(Map<String, dynamic> data) async {
    try {
      final a2uiMessageData = data['data'] as Map<String, dynamic>?;

      if (a2uiMessageData == null || a2uiMessageData.isEmpty) {
        _logger.warning('[A2UI] ERROR: No data field or empty');
        return;
      }

      // =====================================================================
      // Protocol normalization: Backend emits A2UI v0.9 natively. This only
      // forces version='v0.9' and rewrites createSurface.catalogId to the
      // app's basic catalog (see _translateProtocol).
      // =====================================================================
      final translatedMessages = _translateProtocol(a2uiMessageData);
      if (translatedMessages == null || translatedMessages.isEmpty) return;

      for (final translated in translatedMessages) {
        final a2uiMessage = a2ui.A2uiMessage.fromJson(translated);

        // Send immediately - GenUI components render without waiting for stream end
        _a2uiMessageController.add(a2uiMessage);
        _logger.info('[A2UI] Message sent: ${a2uiMessage.runtimeType}');

        // Handle surface lifecycle callbacks
        if (a2uiMessage is a2ui.CreateSurfaceMessage) {
          onSurfaceCreated?.call(a2uiMessage.surfaceId);
        } else if (a2uiMessage is a2ui.UpdateComponentsMessage) {
          // Also notify surface creation for UpdateComponents (backward compat)
          onSurfaceCreated?.call(a2uiMessage.surfaceId);
          _checkAndNotifyTransaction(a2uiMessage);
        }
      }

      // Yield to event loop for UI update
      await Future<void>.delayed(Duration.zero);
    } catch (e, stackTrace) {
      _logger.severe('[A2UI] ERROR parsing message', e, stackTrace);
      onError?.call(e.toString());
    }
  }

  /// Normalize a backend A2UI message to GenUI 0.10 v0.9 format.
  ///
  /// The backend emits A2UI v0.9 natively (createSurface / updateComponents /
  /// updateDataModel / deleteSurface), so this is a thin pass-through that:
  ///   - forces `version` to 'v0.9' (required by a2ui_core's A2uiMessage.fromJson)
  ///   - sets a default catalogId for createSurface if missing or empty, preserving
  ///     backend-specified custom catalog IDs.
  List<Map<String, dynamic>>? _translateProtocol(Map<String, dynamic> raw) {
    if (raw.containsKey('createSurface')) {
      final cs = Map<String, dynamic>.from(
        raw['createSurface'] as Map<String, dynamic>,
      );
      final catalogIdStr = (cs['catalogId'] as String?)?.trim() ?? '';
      if (catalogIdStr.isEmpty) {
        cs['catalogId'] = genui.basicCatalogId;
      }
      return [
        {...raw, 'version': 'v0.9', 'createSurface': cs},
      ];
    }

    if (raw.containsKey('updateComponents') ||
        raw.containsKey('updateDataModel') ||
        raw.containsKey('deleteSurface')) {
      return [
        {...raw, 'version': 'v0.9'},
      ];
    }

    _logger.warning('[A2UI] Unknown message format: ${raw.keys}');
    return null;
  }

  /// Detect transaction success within UpdateComponents and notify
  void _checkAndNotifyTransaction(a2ui.UpdateComponentsMessage msg) {
    try {
      for (final component in msg.components) {
        // 0.10.x: components are raw JSON maps
        // Format: {'id': '...', 'component': 'TypeName', ...props}
        final componentType = component['component'] as String?;
        final props = Map<String, dynamic>.from(component)
          ..remove('id')
          ..remove('component');

        if (componentType == 'transaction_success' ||
            componentType == 'TransactionSuccess') {
          final amount = (props['amount'] as num?)?.toDouble() ?? 0.0;
          final type = props['transaction_type'] as String? ?? 'expense';
          final currency = props['currency'] as String? ?? 'CNY';

          _logger.info(
            'CustomContentGenerator: Detected transaction success: $amount $currency ($type)',
          );

          onTransactionCreated?.call(amount, type, currency);
        } else if (componentType == 'TransactionGroupReceipt') {
          final summary = props['summary'] as Map<String, dynamic>?;
          if (summary != null) {
            final expenseTotal =
                (summary['expense_total'] as num?)?.toDouble() ?? 0.0;
            final incomeTotal =
                (summary['income_total'] as num?)?.toDouble() ?? 0.0;

            if (expenseTotal > 0) {
              onTransactionCreated?.call(expenseTotal, 'expense', 'CNY');
            }
            if (incomeTotal > 0) {
              onTransactionCreated?.call(incomeTotal, 'income', 'CNY');
            }

            _logger.info(
              'CustomContentGenerator: Detected TransactionGroupReceipt: expense=$expenseTotal, income=$incomeTotal',
            );
          }
        }
      }
    } catch (e) {
      _logger.warning(
        'CustomContentGenerator: Error checking transaction auto-update: $e',
      );
    }
  }

  @override
  void dispose() {
    unawaited(_a2uiMessageController.close());
    unawaited(_textResponseController.close());
    _cancelToken?.cancel('Disposed');
  }
}
