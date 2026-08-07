// core/network/interceptors/auth_interceptor.dart
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import 'package:finvo/core/constants/api_constants.dart';
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
  final Future<void> Function(String accessToken, String refreshToken)?
  onTokenRefreshed;
  final Dio _dio;
  final Dio _refreshDio;
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

  /// Extra key used to mark a request that has already been retried after a
  /// token refresh. Without this guard, a retried request that gets a *second*
  /// 401 would re-enter the refresh flow, causing a 401→refresh→retry→401
  /// cascade that hammers the backend until the refresh token is exhausted.
  static const _refreshedKey = '__refreshed';

  AuthInterceptor(
    this.storageService, {
    this.onUnauthorized,
    this.onTokenRefreshed,
    Dio? dio,
    Dio? refreshDio,
  }) : _dio = dio ?? Dio(),
       _refreshDio = refreshDio ?? Dio();

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
    // Public endpoints (login/register/send-code) must NOT trigger the
    // refresh-and-replay flow: a 401 there means "bad credentials", not "token
    // expired". Without this guard, a wrong-password login could attempt a
    // token refresh and, on failure, call onUnauthorized to wipe the local
    // login state.
    final bool isPublicPath = _publicPaths.contains(err.requestOptions.path);
    // A retried request that already went through token refresh must not
    // re-enter the refresh flow — that would cause a 401→refresh→retry→401
    // cascade until the refresh token is exhausted.
    final bool alreadyRefreshed =
        err.requestOptions.extra[_refreshedKey] == true;

    if (isStatus401 && !isRefreshPath && !isPublicPath) {
      if (alreadyRefreshed) {
        // This is the *replayed* request (a second 401 right after a token
        // refresh). Do NOT sign out here: the caller that initiated the replay
        // (the outer onError) already owns the sign-out decision and will run
        // it exactly once when it catches this error. Signing out here too
        // would double-fire [onUnauthorized]. Just propagate the error.
        _logger.warning(
          '401 after token-refresh retry for ${err.requestOptions.path}',
        );
        super.onError(err, handler);
        return;
      } else {
        _logger.warning(
          'Received 401 Unauthorized error for ${err.requestOptions.path}',
        );

        final String? refreshToken = await storageService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          // _singleFlightRefresh holds the lock across the whole
          // refresh + persist + notify span, so a 401 arriving during the
          // narrow window between refresh completion and persistence can't
          // kick off a second refresh with the already-rotated refresh token.
          final _RefreshResult? result;
          try {
            result = await _singleFlightRefresh(
              refreshToken,
              err.requestOptions.baseUrl,
            );
          } catch (e, stackTrace) {
            // Guard the refresh pipeline: a storage write failure must not
            // replace the original DioException (which would bypass the error
            // normalization chain). Degrade to the plain-401 path instead.
            _logger.warning('Token refresh pipeline failed', e, stackTrace);
            handler.next(err);
            return;
          }

          if (result != null) {
            _logger.info('Token refreshed, replaying original request');

            final opts = err.requestOptions;
            // Mark this request as already refreshed so a second 401 on the
            // retry skips the refresh flow and goes straight to sign-out.
            opts.extra[_refreshedKey] = true;
            opts.headers[ApiConstants.authorizationHeader] =
                'Bearer ${result.accessToken}';
            try {
              final Response<dynamic> response = await _dio.fetch<dynamic>(
                opts,
              );
              handler.resolve(response);
              return;
            } on DioException catch (retryErr) {
              // Only sign out when the replay is still a 401 (token genuinely
              // invalid). Network/timeout errors must NOT log out an otherwise
              // valid session — propagate them through the normalization chain.
              if (retryErr.response?.statusCode == 401) {
                _logger.warning(
                  'Replay still 401 after refresh for '
                  '${err.requestOptions.path}, signing out',
                );
                await _signOutLocally();
              } else {
                _logger.warning('Retry after refresh failed: $retryErr');
              }
              handler.next(retryErr);
              return;
            } catch (retryErr, stackTrace) {
              _logger.warning(
                'Retry after refresh failed',
                retryErr,
                stackTrace,
              );
              // A non-DioException here is unexpected; propagate the ORIGINAL
              // DioException so the normalization chain still sees a valid type.
              handler.next(err);
              return;
            }
          } else {
            _logger.warning('Token refresh rejected, signing out');
          }
        }
      }

      // Refresh not possible (or already tried) — sign out locally; the
      // router redirects to login.
      await _signOutLocally();
    }
    super.onError(err, handler);
  }

  /// Sign out locally, swallowing any callback failure so a broken
  /// [onUnauthorized] never escapes into the interceptor chain.
  Future<void> _signOutLocally() async {
    try {
      await onUnauthorized?.call();
    } catch (e, stackTrace) {
      _logger.warning('onUnauthorized callback failed', e, stackTrace);
    }
  }

  /// Exchange a refresh token for a fresh access token + rotated refresh token
  /// via the backend refresh endpoint. Returns null if refresh fails.
  Future<_RefreshResult?> _refreshTokens(
    String refreshToken,
    String baseUrl,
  ) async {
    try {
      Dio refreshDio = _refreshDio;
      if (_refreshDio.options.baseUrl.isEmpty) {
        // The shared refresh client is used without a fixed baseUrl, so create
        // a per-call instance bound to the failing request's server.
        refreshDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
          ),
        );
      }
      final Response<dynamic> response = await refreshDio.post(
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
    } catch (e, stackTrace) {
      _logger.warning('Token refresh failed', e, stackTrace);
      return null;
    }
  }

  /// Single-flight wrapper around [_refreshAndPersist].
  ///
  /// Concurrent 401 responses share one refresh round-trip; the shared future
  /// is cleared once the *whole* refresh + persist + notify pipeline completes
  /// so a later 401 can start a fresh one. Holding the lock until persistence
  /// finishes closes the rotation race: a 401 that arrives after the HTTP
  /// round-trip but before the rotated token is stored would otherwise read
  /// the stale refresh token and trigger a second refresh against an already-
  /// rotated token, which can cascade into an unnecessary sign-out.
  Future<_RefreshResult?> _singleFlightRefresh(
    String refreshToken,
    String baseUrl,
  ) {
    final inFlight = _refreshing;
    if (inFlight != null) {
      return inFlight;
    }
    final future = _refreshAndPersist(refreshToken, baseUrl);
    _refreshing = future;
    unawaited(future.whenComplete(() => _refreshing = null));
    return future;
  }

  /// Refresh then persist the rotated tokens and sync the in-memory AuthState
  /// as one unit, so the memory/storage copies never diverge and derived
  /// long-lived connections (WS/SSE) rebuild with the new token.
  Future<_RefreshResult?> _refreshAndPersist(
    String refreshToken,
    String baseUrl,
  ) async {
    final result = await _refreshTokens(refreshToken, baseUrl);
    if (result == null) {
      return null;
    }
    await storageService.saveToken(result.accessToken);
    await storageService.saveRefreshToken(result.refreshToken);
    // Best-effort sync of the in-memory AuthState: a failure here must not
    // abort an otherwise successful refresh.
    try {
      await onTokenRefreshed?.call(result.accessToken, result.refreshToken);
    } catch (e, stackTrace) {
      _logger.warning('onTokenRefreshed callback failed', e, stackTrace);
    }
    return result;
  }
}

/// Result of a successful token refresh.
class _RefreshResult {
  final String accessToken;
  final String refreshToken;

  const _RefreshResult({required this.accessToken, required this.refreshToken});
}
