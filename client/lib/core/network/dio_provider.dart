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
import 'package:finvo/core/services/server_config_service.dart';
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

/// Build a configured [Dio] instance with the shared interceptor pipeline.
///
/// [forSse] selects the SSE profile (relaxed streaming timeouts, no
/// Error/Business interceptors, `text/event-stream` accept header).
///
/// The provider watches [serverConfigServiceProvider] (not just
/// [apiConstantsProvider], which never changes) so that saving a new server
/// URL — which invalidates `serverConfigServiceProvider` — rebuilds the Dio
/// instance. That rebuild triggers `ref.onDispose(dio.close)` and releases the
/// stale idle connection pool.
Dio _buildDio(Ref ref, {required bool forSse}) {
  final apiConstants = ref.watch(apiConstantsProvider);
  ref.watch(serverConfigServiceProvider);

  final dio = Dio();

  // Timeouts: SSE relaxes receive/send to 1h because streams may legitimately
  // idle while waiting for the AI to execute long-running tasks.
  final (connectTimeout, receiveTimeout, sendTimeout) = forSse
      ? (
          ApiConstants.connectTimeout,
          const Duration(hours: 1),
          const Duration(hours: 1),
        )
      : (
          ApiConstants.connectTimeout,
          ApiConstants.receiveTimeout,
          ApiConstants.sendTimeout,
        );

  // Use baseUrl or empty placeholder (will be set dynamically by
  // ConfigurationCheckInterceptor on each request).
  final baseUrl = apiConstants.baseUrl;
  dio.options.baseUrl = baseUrl.isNotEmpty ? baseUrl : 'http://placeholder';
  dio.options.connectTimeout = connectTimeout;
  dio.options.receiveTimeout = receiveTimeout;
  dio.options.sendTimeout = sendTimeout;
  dio.options.headers = {
    ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
    ApiConstants.acceptHeader: forSse
        ? 'text/event-stream'
        : ApiConstants.applicationJson,
  };

  // --- Shared interceptor pipeline (in execution order) ---
  final storageService = ref.watch(secureStorageServiceProvider);
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
        // Keep the in-memory AuthState in sync after a silent token refresh so
        // derived providers (authToken → notificationWs) rebuild their long-
        // lived connections with the new token instead of the stale one.
        return ref
            .read(authProvider.notifier)
            .handleTokenRefreshed(accessToken);
      },
      dio: dio,
    ),
  ); // Auth interceptor

  if (!forSse) {
    // SSE streams handle their own error/business parsing, so these two
    // interceptors are only wired for regular JSON requests.
    dio.interceptors.add(ErrorInterceptor()); // Error handling interceptor
    dio.interceptors.add(BusinessInterceptor()); // Business logic interceptor
  }

  // Release the idle HTTP connection pool when the provider rebuilds
  // (e.g. server URL change) or the container is disposed.
  ref.onDispose(dio.close);
  return dio;
}

/// SSE Dio Provider
///
/// Used for SSE streaming connections (AI chat, script execution, etc.), disabling timeout limits.
/// Streaming connections may last for a long time (e.g., waiting for AI to execute scripts), should not be subject to timeout limits.
final sseDioProvider = Provider<Dio>((ref) {
  final dio = _buildDio(ref, forSse: true);
  _logger.info('SSE Dio instance created (baseUrl will be set dynamically)');
  return dio;
});

final dioProvider = Provider<Dio>((ref) {
  final dio = _buildDio(ref, forSse: false);
  _logger.info('Dio instance created (baseUrl will be set dynamically)');
  return dio;
});
