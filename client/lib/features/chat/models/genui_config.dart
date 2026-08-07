// features/chat/models/genui_config.dart
import 'package:dio/dio.dart';
import 'package:genui/genui.dart' as genui;
import 'package:finvo/core/storage/secure_storage_service.dart';

typedef OnSessionInit = void Function(String sessionId, String? messageId);
typedef OnStreamComplete = void Function();
typedef OnTitleUpdate = void Function(String title);
typedef OnErrorCallback = void Function(String message, dynamic error);

/// Configuration DTO for GenUiService initialization.
class GenUiConfig {
  final genui.Catalog catalog;
  final SecureStorageService storageService;
  final String sseBaseUrl;
  final Dio? dio;
  final dynamic configuration;

  const GenUiConfig({
    required this.catalog,
    required this.storageService,
    required this.sseBaseUrl,
    this.dio,
    this.configuration,
  });
}

/// Callback bindings DTO for GenUiService event listening.
class GenUiCallbacks {
  final void Function(String surfaceId) onSurfaceAdded;
  final void Function(String surfaceId) onSurfaceRemoved;
  final void Function(String text) onTextResponse;
  final OnSessionInit? onSessionInit;
  final OnStreamComplete? onStreamComplete;
  final OnTitleUpdate? onTitleUpdate;
  final OnErrorCallback? onError;
  final void Function(String surfaceId)? onSurfaceIdAdded;
  final void Function(Map<String, dynamic>)? onTransactionCreated;

  const GenUiCallbacks({
    required this.onSurfaceAdded,
    required this.onSurfaceRemoved,
    required this.onTextResponse,
    this.onSessionInit,
    this.onStreamComplete,
    this.onTitleUpdate,
    this.onError,
    this.onSurfaceIdAdded,
    this.onTransactionCreated,
  });
}
