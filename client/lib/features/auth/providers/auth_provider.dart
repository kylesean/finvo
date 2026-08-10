import 'package:logging/logging.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/auth/models/user.dart';
import 'package:finvo/features/auth/services/auth_service.dart';
import 'package:finvo/features/auth/providers/auth_state.dart';
import 'dart:async';

// Re-export AuthState and AuthStatus for convenience
export 'package:finvo/features/auth/providers/auth_state.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthService _authService;
  late final SecureStorageService _storageService;
  final _logger = Logger('Auth');

  @override
  AuthState build() {
    // Use ref.read to get services (no need to subscribe to changes)
    _authService = ref.read(authServiceProvider);
    _storageService = ref.read(secureStorageServiceProvider);

    // Auth state restoration is intentionally NOT triggered here (no side
    // effect in build). It is kicked off explicitly from the app startup flow
    // (main.dart) via [checkAuthStatus], so the SecureStorage reads happen
    // after the first frame renders and are not coupled to the widget build
    // cycle. Keeping build() pure makes the provider deterministic and testable.
    return const AuthState();
  }

  /// Restore authentication state on app startup
  Future<void> _initializeAuthState() async {
    try {
      _logger.info('Starting authentication state initialization...');
      state = state.copyWith(status: AuthStatus.loading);

      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        _logger.info('Found local token, restoring login state');
        final userData = await _authService.getStoredAuthData();
        if (userData != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: userData['user'] as UserModel,
            token: token,
          );
        } else {
          // Token exists but no cached user data — the persisted auth cache is
          // inconsistent. Fail closed to unauthenticated instead of exposing an
          // authenticated state with a null user, which would break every UI
          // depending on currentUser (and leaves PII-vs-token out of sync). The
          // user simply re-logs-in; a 401 mid-session is handled by the auth
          // interceptor's session-expiry path.
          _logger.warning(
            'Token found but no cached user data; falling back to '
            'unauthenticated',
          );
          // The persisted auth cache is inconsistent (token without user
          // data). Wipe the orphaned token so a subsequent cold start does not
          // hit this fallback branch again and repeatedly log the warning.
          await _storageService.deleteToken();
          await _storageService.deleteRefreshToken();
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      _logger.severe('State initialization failed', e);
    }
  }

  Future<void> _handleAuthenticationSuccess({
    required UserModel user,
    required String token,
  }) async {
    await _storageService.saveToken(token);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      token: token,
    );
    _logger.info('Login successful, state updated - userId: ${user.id}');
  }

  /// If [error] is a [DioException] wrapping an [AppException], return that
  /// AppException so callers can rethrow it; otherwise return null.
  AppException? _appExceptionFrom(Object error) {
    if (error is DioException && error.error is AppException) {
      return error.error as AppException;
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await _authService.login(email, password);
      await _handleAuthenticationSuccess(
        user: result.user,
        token: result.token,
      );
    } catch (e) {
      if (state.status != AuthStatus.unauthenticated) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
      final appException = _appExceptionFrom(e);
      if (appException != null) {
        throw appException;
      }
      rethrow;
    }
  }

  Future<void> register({
    required String account,
    required String password,
    required String verificationCode,
  }) async {
    try {
      final result = await _authService.register(
        account: account,
        password: password,
        verificationCode: verificationCode,
      );
      await _handleAuthenticationSuccess(
        user: result.user,
        token: result.token,
      );
    } catch (e) {
      // Mirror login(): reset to unauthenticated on failure so the state never
      // stays pinned to loading/authenticated after a failed register attempt.
      if (state.status != AuthStatus.unauthenticated) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
      final appException = _appExceptionFrom(e);
      if (appException != null) {
        throw appException;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      _logger.warning('Error during logout, but local state cleared', e);
    }
    // logout() clears the secure-storage tokens and shared-preference user PII
    // internally (via _deleteAuthData). Whether the call succeeded or not, the
    // local credentials are already removed, so the user is never left in a
    // half-logged-in state.
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Called by the auth interceptor after a successful token refresh. Writes
  /// the rotated access token back into the in-memory [AuthState] so the
  /// memory copy and SecureStorage stay in sync, and so derived providers
  /// (e.g. authToken → notificationWs) see the *new* token value and rebuild
  /// their long-lived connections with it.
  ///
  /// The rotated refresh token lives only in SecureStorage (AuthState has no
  /// refresh field), so only the access token is synced here.
  Future<void> handleTokenRefreshed(String accessToken) async {
    if (state.status != AuthStatus.authenticated) {
      _logger.info(
        'handleTokenRefreshed: not authenticated, skipping token sync',
      );
      return;
    }
    state = state.copyWith(token: accessToken);
    _logger.info('Token refreshed, in-memory auth state synced');
  }

  /// Called by the auth interceptor when a 401 is received: the token is
  /// invalid or expired. Clears local auth state immediately so the router
  /// redirects to the login page, without the simulated logout delay.
  ///
  /// Unlike the old path (which only dropped the secure-storage tokens), this
  /// also wipes the user PII in SharedPreferences via [AuthService.logout]
  /// equivalent local cleanup, keeping cold-start behaviour identical to a
  /// full logout instead of leaving stale user data behind.
  Future<void> handleSessionExpired() async {
    try {
      await _authService.clearLocalAuthData();
    } catch (e) {
      _logger.warning('Failed to clear local auth data on session expiry', e);
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
    _logger.info('Session expired (401), auth state cleared');
  }

  Future<void> refreshUser() async {
    if (state.status != AuthStatus.authenticated) return;
    try {
      final userData = await _authService.getStoredAuthData();
      if (userData != null) {
        state = state.copyWith(user: userData['user'] as UserModel);
      }
    } catch (e) {
      _logger.warning('Failed to refresh user info', e);
    }
  }

  Future<void> updateUsername(String newUsername) async {
    await _authService.updateStoredUsername(newUsername);
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(username: newUsername));
    }
  }

  Future<void> checkAuthStatus() async {
    await _initializeAuthState();
  }
}

@Riverpod(keepAlive: true)
String? authToken(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.token;
}

@Riverpod(keepAlive: true)
UserModel? currentUser(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
}

@Riverpod(keepAlive: true)
AuthStatus authStatus(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.status;
}
