import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import 'package:finvo/core/network/interceptors/business_interceptor.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/core/network/interceptors/auth_interceptor.dart';
import 'package:finvo/core/network/interceptors/logging_interceptor.dart';
import 'package:finvo/core/network/interceptors/error_interceptor.dart';
import 'package:finvo/core/network/interceptors/locale_interceptor.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';

/// Riverpod Provider for Dio instance
final _logger = Logger('DioProvider');

/// Interceptor that checks if server is configured before making requests
class ConfigurationCheckInterceptor extends Interceptor {
  final Ref _ref;

  ConfigurationCheckInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final apiConstants = _ref.read(apiConstantsProvider);

    // Check if server is configured
    if (!apiConstants.isConfigured) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: ServerNotConfiguredException(
            'Server not configured. Please configure server URL first.',
          ),
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }

    // Update baseUrl dynamically in case it changed
    final baseUrl = apiConstants.baseUrl;
    if (baseUrl.isNotEmpty && options.baseUrl != baseUrl) {
      options.baseUrl = baseUrl;
    }

    handler.next(options);
  }
}

/// Sign out locally when a 401 is received (token invalid/expired).
/// The router redirects to the login page after auth state clears.
Future<void> handleUnauthorized(Ref ref) async {
  await ref.read(authProvider.notifier).handleSessionExpired();
}

/// SSE Dio Provider
///
/// Used for SSE streaming connections (AI chat, script execution, etc.), disabling timeout limits.
/// Streaming connections may last for a long time (e.g., waiting for AI to execute scripts), should not be subject to timeout limits.
final sseDioProvider = Provider<Dio>((ref) {
  final apiConstants = ref.watch(apiConstantsProvider);
  final dio = Dio();

  // SSE connection configuration: only set connectTimeout; the receive/send
  // timeouts are relaxed (1h) because SSE streams may legitimately idle for a
  // long time while waiting for the AI to execute long-running tasks.
  dio.options.baseUrl = apiConstants.baseUrl;
  dio.options.connectTimeout = ApiConstants.connectTimeout;
  dio.options.receiveTimeout = const Duration(hours: 1);
  dio.options.sendTimeout = const Duration(hours: 1);
  dio.options.headers = {
    ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
    ApiConstants.acceptHeader: 'text/event-stream',
  };

  // SSE connection only needs basic interceptors
  final storageService = ref.watch(secureStorageServiceProvider);
  dio.interceptors.add(
    ConfigurationCheckInterceptor(ref),
  ); // Check config first
  dio.interceptors.add(loggingInterceptor);
  dio.interceptors.add(LocaleInterceptor(ref));
  dio.interceptors.add(
    AuthInterceptor(
      storageService,
      onUnauthorized: () => handleUnauthorized(ref),
      onTokenRefreshed: (accessToken, _) {
        // Keep the in-memory AuthState in sync after a silent token refresh so
        // derived providers (authToken → notificationWs) rebuild their long-
        // lived connections with the new token instead of the stale one.
        return ref
            .read(authProvider.notifier)
            .handleTokenRefreshed(accessToken);
      },
      dio: dio,
    ),
  );
  // Note: SSE does not need ErrorInterceptor and BusinessInterceptor, because the streaming response handling is different

  // Release the idle HTTP connection pool when the provider rebuilds
  // (e.g. server URL change) or the container is disposed.
  ref.onDispose(dio.close);

  _logger.info('SSE Dio instance created (baseUrl will be set dynamically)');
  return dio;
});

final dioProvider = Provider<Dio>((ref) {
  final apiConstants = ref.watch(apiConstantsProvider);
  final dio = Dio();

  // Basic configuration
  // Use baseUrl or empty placeholder (will be set by ConfigurationCheckInterceptor)
  final baseUrl = apiConstants.baseUrl;
  dio.options.baseUrl = baseUrl.isNotEmpty ? baseUrl : 'http://placeholder';
  dio.options.connectTimeout = ApiConstants.connectTimeout;
  dio.options.receiveTimeout = ApiConstants.receiveTimeout;
  dio.options.sendTimeout = ApiConstants.sendTimeout;
  dio.options.headers = {
    ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
    ApiConstants.acceptHeader: ApiConstants.applicationJson,
  };
  // --- Inject dependencies and add interceptors ---
  // 1. Get SecureStorageService instance
  final storageService = ref.watch(secureStorageServiceProvider);
  // 2. Add interceptors in execution order
  dio.interceptors.add(
    ConfigurationCheckInterceptor(ref),
  ); // Check config first
  dio.interceptors.add(loggingInterceptor); // Logging interceptor
  dio.interceptors.add(LocaleInterceptor(ref)); // Locale interceptor
  dio.interceptors.add(
    AuthInterceptor(
      storageService,
      onUnauthorized: () => handleUnauthorized(ref),
      onTokenRefreshed: (accessToken, _) {
        return ref
            .read(authProvider.notifier)
            .handleTokenRefreshed(accessToken);
      },
      dio: dio,
    ),
  ); // Auth interceptor
  dio.interceptors.add(ErrorInterceptor()); // Error handling interceptor
  dio.interceptors.add(BusinessInterceptor()); // Business logic interceptor
  // Release the idle HTTP connection pool when the provider rebuilds
  // (e.g. server URL change) or the container is disposed.
  ref.onDispose(dio.close);
  _logger.info('Dio instance created (baseUrl will be set dynamically)');
  return dio;
});
