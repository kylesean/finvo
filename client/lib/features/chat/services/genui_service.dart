import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart' as genui;
import 'package:a2ui_core/a2ui_core.dart' as a2ui;
import 'package:finvo/features/chat/models/genui_config.dart';
import 'package:finvo/features/chat/services/custom_content_generator.dart';
import 'package:finvo/features/chat/services/extended_genui_conversation.dart';

final _logger = Logger('GenUiService');

/// GenUI initialization and configuration service (Requirement 1.1, 1.4)
///
/// Manages the lifecycle of GenUI components using [GenUiConfig] and [GenUiCallbacks].
class GenUiService {
  genui.SurfaceController? _controller;
  ExtendedGenUiConversation? _genUiConversation;
  CustomContentGenerator? _contentGenerator;
  bool _isInitialized = false;

  /// Callbacks for surface lifecycle events
  void Function(String surfaceId)? _onSurfaceAdded;
  void Function(String surfaceId)? _onSurfaceRemoved;
  void Function(String)? _onTextResponse;
  void Function(String surfaceId)? _onSurfaceIdAdded;

  /// Initialize GenUI with [GenUiConfig] and [GenUiCallbacks] DTOs.
  Future<void> initialize({
    required GenUiConfig config,
    required GenUiCallbacks callbacks,
  }) async {
    try {
      _logger.info('GenUiService: Starting initialization');

      _onSurfaceAdded = callbacks.onSurfaceAdded;
      _onSurfaceRemoved = callbacks.onSurfaceRemoved;
      _onTextResponse = callbacks.onTextResponse;
      _onSurfaceIdAdded = callbacks.onSurfaceIdAdded;

      // GenUI SurfaceController manages surfaces and implements SurfaceHost
      _controller = genui.SurfaceController(catalogs: [config.catalog]);
      _logger.info('GenUiService: SurfaceController created');

      // Create custom Transport (ContentGenerator)
      _contentGenerator = CustomContentGenerator(
        config.storageService,
        dio: config.dio,
        sseBaseUrl: config.sseBaseUrl,
      );

      // Wire up callbacks
      _contentGenerator!.onTextChunk = callbacks.onTextResponse;
      _contentGenerator!.onStreamComplete = callbacks.onStreamComplete;
      _contentGenerator!.onTitleUpdate = callbacks.onTitleUpdate;
      _contentGenerator!.onError = (err) {
        _logger.warning('GenUiService: ContentGenerator error - $err');
        callbacks.onError?.call(err.toString(), err);
      };
      _contentGenerator!.onTransactionCreated = (amount, type, currency) {
        callbacks.onTransactionCreated?.call({
          'amount': amount,
          'transactionType': type,
          'currency': currency,
        });
      };

      _contentGenerator!.onSurfaceCreated = (String surfaceId) {
        _logger.info(
          'GenUiService: Surface created via SurfaceUpdate - $surfaceId',
        );
        _onSurfaceIdAdded?.call(surfaceId);
      };

      // Create ExtendedGenUiConversation to orchestrate everything
      _genUiConversation = ExtendedGenUiConversation(
        controller: _controller!,
        contentGenerator: _contentGenerator!,
        onSurfaceAdded: (surfaceId) {
          _onSurfaceAdded?.call(surfaceId);
        },
        onSurfaceDeleted: (surfaceId) {
          _onSurfaceRemoved?.call(surfaceId);
        },
        onTextResponse: (text) => _onTextResponse?.call(text),
        onError: (message, rawError) =>
            callbacks.onError?.call(message, rawError),
        onSessionInit: callbacks.onSessionInit,
      );

      _isInitialized = true;
      _logger.info('GenUiService: Initialization complete');
    } catch (e, stackTrace) {
      _logger.severe('GenUiService: Initialization failed', e, stackTrace);
      _isInitialized = false;
      await _cleanup();
      rethrow;
    }
  }

  /// Send a message to the AI
  Future<void> sendMessage(String message) async {
    if (!_isInitialized || _genUiConversation == null) {
      throw StateError('GenUiService not initialized.');
    }

    final userMessage = genui.ChatMessage.user(message);
    await _genUiConversation!.sendRequest(userMessage);
  }

  /// Get the ExtendedGenUiConversation instance
  ExtendedGenUiConversation get conversation {
    if (!_isInitialized || _genUiConversation == null) {
      throw StateError('GenUiService not initialized.');
    }
    return _genUiConversation!;
  }

  /// Get the SurfaceHost instance (for direct surface manipulation)
  genui.SurfaceHost get manager {
    if (!_isInitialized || _controller == null) {
      throw StateError('GenUiService not initialized.');
    }
    return _controller!;
  }

  /// Alias for manager (for backward compatibility)
  genui.SurfaceHost get host => manager;

  bool get isInitialized => _isInitialized;

  /// Get a ValueListenable for a specific surface's definition
  ValueListenable<genui.SurfaceDefinition?> getSurfaceNotifier(
    String surfaceId,
  ) {
    if (!_isInitialized || _controller == null) {
      throw StateError('GenUiService not initialized.');
    }
    return _controller!.contextFor(surfaceId).definition;
  }

  /// Clear the current session state
  void clearSessionToken() {
    _genUiConversation?.clearSession();
    _logger.info('GenUiService: Session cleared');
  }

  /// Replay historical UI components (Requirement 7.1)
  /// Returns `true` if replayed successfully, `false` otherwise.
  bool replayHistoricalSurface({
    required String surfaceId,
    required String componentType,
    required Map<String, dynamic> data,
  }) {
    if (!_isInitialized || _controller == null) return false;

    try {
      // Clean private/internal keys starting with '_' before replaying
      final cleanData = Map<String, dynamic>.from(data)
        ..removeWhere((key, _) => key.startsWith('_'));

      final createMsg = a2ui.CreateSurfaceMessage(
        surfaceId: surfaceId,
        catalogId: genui.basicCatalogId,
      );
      _controller!.handleMessage(createMsg);

      final updateMsg = a2ui.UpdateComponentsMessage(
        surfaceId: surfaceId,
        components: [
          {'id': 'root', 'component': componentType, ...cleanData},
        ],
      );

      _controller!.handleMessage(updateMsg);
      _logger.info(
        'GenUiService: Surface $surfaceId replayed via handleMessage',
      );
      return true;
    } catch (e) {
      _logger.warning('GenUiService: Replay failed: $e');
      return false;
    }
  }

  Future<void> _cleanup() async {
    _genUiConversation?.dispose();
    _genUiConversation = null;
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  Future<void> dispose() async {
    await _cleanup();
  }
}
