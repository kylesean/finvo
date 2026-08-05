// core/network/interceptors/auth_interceptor.dart
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';

/// Authentication Interceptor
///
/// Automatically adds Bearer Token to requests that require authentication.
///
/// On a 401 it attempts a single token refresh (via the backend `/auth/refresh`
/// endpoint) and replays the original request with the new token. If refresh
/// fails or is unavailable, it signs out locally so the router redirects to
/// login.
class AuthInterceptor extends Interceptor {
  final SecureStorageService storageService;
  final Future<void> Function()? onUnauthorized;
  final Dio _dio;
  final _logger = Logger('AuthInterceptor');

  /// Public paths that do not require authentication.
  ///
  /// `/auth/refresh` is included so the refresh flow never re-enters this
  /// interceptor's 401 handling.
  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/send-code',
    '/auth/refresh',
  ];

  AuthInterceptor(this.storageService, {this.onUnauthorized, Dio? dio})
    : _dio = dio ?? Dio();

  /// Shared in-flight refresh so that concurrent 401 responses await a single
  /// token refresh instead of each triggering their own (which could race
  /// refresh-token rotation on the server).
  Future<_RefreshResult?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public paths do not require authentication
    if (_publicPaths.contains(options.path)) {
      return handler.next(options);
    }

    // Get token from secure storage
    final String? authToken = await storageService.getToken();

    if (authToken != null && authToken.isNotEmpty) {
      options.headers[ApiConstants.authorizationHeader] = 'Bearer $authToken';
      _logger.fine('Token added to headers for path: ${options.path}');
    } else {
      _logger.fine('No auth token found for path: ${options.path}');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool isStatus401 = err.response?.statusCode == 401;
    final bool isRefreshPath = err.requestOptions.path == '/auth/refresh';

    if (isStatus401 && !isRefreshPath) {
      _logger.warning(
        'Received 401 Unauthorized error for ${err.requestOptions.path}',
      );

      final String? refreshToken = await storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final _RefreshResult? result = await _singleFlightRefresh(
          refreshToken,
          err.requestOptions.baseUrl,
        );

        if (result != null) {
          await storageService.saveToken(result.accessToken);
          await storageService.saveRefreshToken(result.refreshToken);
          _logger.info('Token refreshed, replaying original request');

          try {
            final opts = err.requestOptions;
            opts.headers[ApiConstants.authorizationHeader] =
                'Bearer ${result.accessToken}';
            final Response<dynamic> response = await _dio.fetch<dynamic>(opts);
            handler.resolve(response);
            return;
          } catch (retryErr) {
            _logger.warning('Retry after refresh failed: $retryErr');
          }
        } else {
          _logger.warning('Token refresh rejected, signing out');
        }
      }

      // Refresh not possible — sign out locally; the router redirects to login.
      try {
        await onUnauthorized?.call();
      } catch (e) {
        _logger.warning('onUnauthorized callback failed: $e');
      }
    }
    super.onError(err, handler);
  }

  /// Exchange a refresh token for a fresh access token + rotated refresh token
  /// via the backend refresh endpoint. Returns null if refresh fails.
  Future<_RefreshResult?> _refreshTokens(
    String refreshToken,
    String baseUrl,
  ) async {
    try {
      final Dio dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ),
      );
      final Response<dynamic> response = await dio.post(
        '/auth/refresh',
        options: Options(
          headers: {ApiConstants.authorizationHeader: 'Bearer $refreshToken'},
        ),
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic> &&
          data['code'] == 0 &&
          data['data'] is Map<String, dynamic>) {
        final access = (data['data'] as Map<String, dynamic>)['token'];
        final refresh = (data['data'] as Map<String, dynamic>)['refresh_token'];
        if (access is String &&
            access.isNotEmpty &&
            refresh is String &&
            refresh.isNotEmpty) {
          return _RefreshResult(accessToken: access, refreshToken: refresh);
        }
      }
      return null;
    } catch (e) {
      _logger.warning('Token refresh failed: $e');
      return null;
    }
  }

  /// Single-flight wrapper around [_refreshTokens].
  ///
  /// Concurrent 401 responses share one refresh round-trip; the shared future
  /// is cleared once the refresh completes so a later 401 can start a fresh one.
  Future<_RefreshResult?> _singleFlightRefresh(
    String refreshToken,
    String baseUrl,
  ) {
    final inFlight = _refreshing;
    if (inFlight != null) {
      return inFlight;
    }
    final future = _refreshTokens(refreshToken, baseUrl);
    _refreshing = future;
    unawaited(future.whenComplete(() => _refreshing = null));
    return future;
  }
}

/// Result of a successful token refresh.
class _RefreshResult {
  final String accessToken;
  final String refreshToken;

  const _RefreshResult({required this.accessToken, required this.refreshToken});
}
