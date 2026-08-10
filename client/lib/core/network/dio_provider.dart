import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import 'package:finvo/core/network/interceptors/business_interceptor.dart';
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

/// Auth-related callbacks wired into the Dio interceptor pipeline.
///
/// Implemented at the composition root (main.dart) so that core/network stays
/// independent of feature modules: without an override, the Dio pipeline runs
/// without session-expiry handling (callbacks are null and the interceptor
/// skips them).
abstract interface class DioAuthCallbacks {
  /// Called when a 401 cannot be recovered by a token refresh.
  Future<void> onUnauthorized();

  /// Called after a silent token refresh to keep derived state in sync.
  Future<void> onTokenRefreshed(String accessToken, String refreshToken);
}

/// Composition-root override point for [DioAuthCallbacks].
final dioAuthCallbacksProvider = Provider<DioAuthCallbacks?>((ref) => null);

/// Interceptor that checks if server is configured before making requests
class ConfigurationCheckInterceptor extends Interceptor {
  final Ref _ref;

  ConfigurationCheckInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if server is configured
    if (!_ref.read(apiConfiguredProvider)) {
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
    final baseUrl = _ref.read(apiBaseUrlProvider);
    if (baseUrl.isNotEmpty && options.baseUrl != baseUrl) {
      options.baseUrl = baseUrl;
    }

    handler.next(options);
  }
}

/// Sign out locally when a 401 is received (token invalid/expired).
/// The router redirects to the login page after auth state clears.
///
/// Removed in favor of [dioAuthCallbacksProvider]: the implementation now
/// lives at the composition root so core/network does not import features.

/// Build a configured [Dio] instance with the shared interceptor pipeline.
///
/// [forSse] selects the SSE profile (relaxed streaming timeouts, no
/// Error/Business interceptors, `text/event-stream` accept header).
///
/// The instance is an application-lifetime singleton: it must never be
/// rebuilt (and its previous instance closed) when the server URL changes.
/// Replacing it mid-session strands every long-held reference (e.g.
/// [authServiceProvider] caches its [NetworkClient] via `ref.read`) with a
/// closed Dio, after which every request fails with "Dio can't establish a
/// new connection after it was closed". The [ConfigurationCheckInterceptor]
/// already injects the current base URL on each request, so a URL change
/// requires no rebuild at all.
Dio _buildDio(Ref ref, {required bool forSse}) {
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

  // Initial base URL; refreshed per-request by ConfigurationCheckInterceptor.
  final baseUrl = ref.read(apiBaseUrlProvider);
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
  final authCallbacks = ref.watch(dioAuthCallbacksProvider);
  dio.interceptors.add(
    ConfigurationCheckInterceptor(ref),
  ); // Check config first
  dio.interceptors.add(loggingInterceptor); // Logging interceptor
  dio.interceptors.add(LocaleInterceptor(ref)); // Locale interceptor
  dio.interceptors.add(
    AuthInterceptor(
      storageService,
      onUnauthorized: authCallbacks == null
          ? null
          : () => authCallbacks.onUnauthorized(),
      onTokenRefreshed: authCallbacks == null
          ? null
          : (accessToken, refreshToken) =>
                authCallbacks.onTokenRefreshed(accessToken, refreshToken),
      dio: dio,
    ),
  ); // Auth interceptor

  if (!forSse) {
    // SSE streams handle their own error/business parsing, so these two
    // interceptors are only wired for regular JSON requests.
    dio.interceptors.add(ErrorInterceptor()); // Error handling interceptor
    dio.interceptors.add(BusinessInterceptor()); // Business logic interceptor
  }

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
