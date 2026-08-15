import 'dart:async';

import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';

/// Shared single-flight token-refresh state.
///
/// Both the regular REST Dio and the SSE Dio install their own
/// [AuthInterceptor], but the in-flight refresh lock MUST be shared across
/// them. A 401 storm can hit both pipelines at the same time (a long-lived
/// SSE stream plus parallel REST calls); with per-instance locks both would
/// read the same refresh token and both would fire `/auth/refresh`, racing
/// the server-side refresh-token rotation. The loser gets rejected, and the
/// failure is misattributed to an expired session — logging the user out for
/// no reason. A single coordinator serializes the whole
/// refresh + persist + notify pipeline for every interceptor instance.
///
/// It also owns two derived side effects so concurrent waiters do not repeat
/// them:
/// - [handleRefreshRejected] runs the local sign-out exactly once per failed
///   refresh round instead of N times (once per concurrent 401 waiter).
/// - [isSessionValid] (set at the composition root) is consulted before the
///   rotated tokens are persisted: an in-flight refresh that settles after a
///   logout must not resurrect credentials in secure storage.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator({
    required this.storageService,
    this.onUnauthorized,
    this.onTokenRefreshed,
    this.isSessionValid,
    Dio? refreshDio,
  }) : refreshDio = refreshDio ?? Dio();

  final SecureStorageService storageService;
  final Future<void> Function()? onUnauthorized;
  final Future<void> Function(String accessToken, String refreshToken)?
  onTokenRefreshed;
  final bool Function()? isSessionValid;
  final Dio refreshDio;
  final _logger = Logger('TokenRefreshCoordinator');

  /// Shared in-flight refresh so that concurrent 401 responses await a single
  /// token refresh instead of each triggering their own (which could race
  /// refresh-token rotation on the server).
  Future<TokenRefreshResult?>? _refreshing;

  /// Latch so that a failed refresh round runs the local sign-out exactly
  /// once: the first waiter that observes the rejection performs it, the rest
  /// just propagate the error. Reset at the start of every new refresh round.
  bool _signOutPending = false;

  /// Single-flight wrapper around [_refreshAndPersist].
  ///
  /// Concurrent 401 responses share one refresh round-trip; the shared future
  /// is cleared once the *whole* refresh + persist + notify pipeline completes
  /// so a later 401 can start a fresh one. Holding the lock until persistence
  /// finishes closes the rotation race: a 401 that arrives after the HTTP
  /// round-trip but before the rotated token is stored would otherwise read
  /// the stale refresh token and trigger a second refresh against an already-
  /// rotated token, which can cascade into an unnecessary sign-out.
  Future<TokenRefreshResult?> refresh(String refreshToken, String baseUrl) {
    final inFlight = _refreshing;
    if (inFlight != null) {
      return inFlight;
    }
    // A new refresh round: allow one sign-out side effect for this round.
    _signOutPending = false;
    final future = _refreshAndPersist(refreshToken, baseUrl);
    _refreshing = future;
    // Clear the shared future when the pipeline settles, on success AND on
    // failure. Handle the error explicitly: an unhandled completion here would
    // surface as an uncaught async error in the zone handler. The derived
    // future can only error if the refresh pipeline itself throws (it does
    // not), so discarding it is safe.
    unawaited(
      future.then<void>(
        (_) {
          if (identical(_refreshing, future)) _refreshing = null;
        },
        onError: (Object error, StackTrace stackTrace) {
          if (identical(_refreshing, future)) _refreshing = null;
          _logger.warning('Token refresh pipeline failed', error, stackTrace);
        },
      ),
    );
    return future;
  }

  /// Called by a waiter when [refresh] completed with `null` (the server
  /// rejected the refresh token). Only the first waiter performs the local
  /// sign-out; the remaining N-1 waiters no-op so the cleanup (storage
  /// deletes, prefs removes, state resets) does not fan out N times.
  Future<void> handleRefreshRejected() async {
    if (_signOutPending) return;
    _signOutPending = true;
    try {
      await onUnauthorized?.call();
    } catch (e, stackTrace) {
      _logger.warning('onUnauthorized callback failed', e, stackTrace);
    }
  }

  /// Refresh then persist the rotated tokens and sync the in-memory AuthState
  /// as one unit, so the memory/storage copies never diverge and derived
  /// long-lived connections (WS/SSE) rebuild with the new token.
  Future<TokenRefreshResult?> _refreshAndPersist(
    String refreshToken,
    String baseUrl,
  ) async {
    final result = await _refreshTokens(refreshToken, baseUrl);
    if (result == null) {
      return null;
    }
    // H-3: the refresh round-trip is slow; the user may have logged out (or
    // the session may have expired) while it was in flight. Persisting the
    // rotated tokens after a logout would resurrect credentials the logout
    // explicitly removed. Consult the composition-root session check and drop
    // the result instead. Returning null routes the waiters through the
    // rejected path (handleRefreshRejected), which is a no-op when the
    // session is already gone.
    final sessionActive = isSessionValid?.call() ?? true;
    if (!sessionActive) {
      _logger.info(
        'Session is no longer active; discarding in-flight refresh result',
      );
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

  /// Exchange a refresh token for a fresh access token + rotated refresh token
  /// via the backend refresh endpoint. Returns null if refresh fails.
  Future<TokenRefreshResult?> _refreshTokens(
    String refreshToken,
    String baseUrl,
  ) async {
    try {
      // Reuse the shared refresh client for every call. A per-call Dio was
      // previously created here when the shared client had no fixed baseUrl and
      // was never closed, leaking its underlying HTTP connections. Instead of
      // creating a new client, bind the failing request's server by building
      // the full URL: dio's Options exposes no baseUrl field, so we can't
      // repoint the shared instance per-request.
      final Response<dynamic> response = await refreshDio.post(
        '$baseUrl${ApiConstants.authRefreshPath}',
        options: Options(
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
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
          return TokenRefreshResult(accessToken: access, refreshToken: refresh);
        }
      }
      return null;
    } catch (e, stackTrace) {
      _logger.warning('Token refresh failed', e, stackTrace);
      return null;
    }
  }
}

/// Authentication Interceptor
///
/// Automatically adds Bearer Token to requests that require authentication.
///
/// On a 401 it attempts a single token refresh (via the backend `/auth/refresh`
/// endpoint) and replays the original request with the new token. If refresh
/// fails or is unavailable, it signs out locally so the router redirects to
/// login.
///
/// Each Dio instance gets its OWN [AuthInterceptor] (so replays run through
/// the same pipeline the request originated from, preserving SSE-specific
/// headers/timeouts), but all instances share one [TokenRefreshCoordinator]
/// so the refresh round-trip is single-flight across the whole app.
class AuthInterceptor extends Interceptor {
  final SecureStorageService storageService;

  /// Shared across every AuthInterceptor instance (see [TokenRefreshCoordinator]).
  final TokenRefreshCoordinator _refreshCoordinator;
  final Dio _dio;
  final _logger = Logger('AuthInterceptor');

  /// Extra key used to mark a request that has already been retried after a
  /// token refresh. Without this guard, a retried request that gets a *second*
  /// 401 would re-enter the refresh flow, causing a 401→refresh→retry→401
  /// cascade that hammers the backend until the refresh token is exhausted.
  static const _refreshedKey = '__refreshed';

  AuthInterceptor(
    this.storageService, {
    Future<void> Function()? onUnauthorized,
    Future<void> Function(String accessToken, String refreshToken)?
    onTokenRefreshed,
    bool Function()? isSessionValid,
    Dio? dio,
    Dio? refreshDio,
    TokenRefreshCoordinator? refreshCoordinator,
  }) : _dio = dio ?? Dio(),
       _refreshCoordinator =
           refreshCoordinator ??
           TokenRefreshCoordinator(
             storageService: storageService,
             onUnauthorized: onUnauthorized,
             onTokenRefreshed: onTokenRefreshed,
             isSessionValid: isSessionValid,
             refreshDio: refreshDio,
           );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public paths do not require authentication
    if (ApiConstants.publicAuthPaths.contains(options.path)) {
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
    final bool isRefreshPath =
        err.requestOptions.path == ApiConstants.authRefreshPath;
    // Public endpoints (login/register/send-code) must NOT trigger the
    // refresh-and-replay flow: a 401 there means "bad credentials", not "token
    // expired". Without this guard, a wrong-password login could attempt a
    // token refresh and, on failure, call onUnauthorized to wipe the local
    // login state.
    final bool isPublicPath = ApiConstants.publicAuthPaths.contains(
      err.requestOptions.path,
    );
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

        final String? refreshToken;
        try {
          refreshToken = await storageService.getRefreshToken();
        } catch (e, stackTrace) {
          // Secure storage is unavailable: the refresh token cannot be read,
          // so a silent refresh is impossible. Fail closed (sign out locally)
          // and propagate the ORIGINAL DioException through the normalization
          // chain instead of letting this storage error replace it (which
          // would bypass error normalization and skip the sign-out flow).
          _logger.warning(
            'Failed to read refresh token from secure storage, signing out',
            e,
            stackTrace,
          );
          await _refreshCoordinator.handleRefreshRejected();
          super.onError(err, handler);
          return;
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          // The coordinator holds the lock across the whole
          // refresh + persist + notify span, so a 401 arriving during the
          // narrow window between refresh completion and persistence can't
          // kick off a second refresh with the already-rotated refresh token.
          final TokenRefreshResult? result;
          try {
            result = await _refreshCoordinator.refresh(
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
                await _refreshCoordinator.handleRefreshRejected();
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
      // router redirects to login. The latch inside the coordinator ensures
      // concurrent 401 waiters perform this exactly once per refresh round.
      await _refreshCoordinator.handleRefreshRejected();
    }
    super.onError(err, handler);
  }
}

/// Result of a successful token refresh.
class TokenRefreshResult {
  final String accessToken;
  final String refreshToken;

  const TokenRefreshResult({
    required this.accessToken,
    required this.refreshToken,
  });
}
