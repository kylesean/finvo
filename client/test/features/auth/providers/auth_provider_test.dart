import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/auth/services/auth_service.dart';
import 'package:finvo/shared/services/timezone_service.dart';

/// In-memory fake for [SecureStorageService]; no platform channel involved.
class _FakeSecureStorageService extends SecureStorageService {
  _FakeSecureStorageService() : super(const FlutterSecureStorage());

  final Map<String, String> _store = {};

  @override
  Future<void> saveToken(String token) async => _store['token'] = token;

  @override
  Future<String?> getToken() async => _store['token'];

  @override
  Future<void> deleteToken() async => _store.remove('token');

  @override
  Future<void> saveRefreshToken(String token) async {
    _store['refresh'] = token;
  }

  @override
  Future<String?> getRefreshToken() async => _store['refresh'];

  @override
  Future<void> deleteRefreshToken() async => _store.remove('refresh');
}

class _FakeTimezoneService extends TimezoneService {
  @override
  Future<String> getCurrentTimezone() async => 'Asia/Shanghai';
}

const _loginData = {
  'data': {
    'user': {'id': 'u1', 'username': 'alice', 'email': 'a@example.com'},
    'token': 'access-token',
    'refresh_token': 'refresh-token',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late _FakeSecureStorageService storage;
  late SharedPreferences prefs;
  late AuthService service;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = _FakeSecureStorageService();
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:9999'));
    final networkClient = NetworkClient(dio);
    service = AuthService(
      networkClient,
      _FakeTimezoneService(),
      prefs,
      storage,
    );
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(service),
        secureStorageServiceProvider.overrideWithValue(storage),
      ],
    );
  });

  tearDown(() => container.dispose());

  /// Routes every request to a canned response map keyed by path.
  void mockResponses(Map<String, Map<String, dynamic>> responses) {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final response =
              responses[options.path] ?? <String, dynamic>{'data': null};
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: response,
              statusCode: 200,
            ),
          );
        },
      ),
    );
  }

  /// Seeds SharedPreferences with the non-sensitive user cache that
  /// [AuthService.getStoredAuthData] reads alongside the secure token.
  void seedCachedUser() {
    unawaited(prefs.setString('user_id', 'u1'));
    unawaited(prefs.setString('user_name', 'alice'));
    unawaited(prefs.setString('user_email', 'a@example.com'));
  }

  group('checkAuthStatus (state restoration)', () {
    test('no stored token ends unauthenticated', () async {
      await container.read(authProvider.notifier).checkAuthStatus();

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });

    test('stored token + cached user restores authenticated state', () async {
      await storage.saveToken('access-token');
      seedCachedUser();

      await container.read(authProvider.notifier).checkAuthStatus();

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.token, 'access-token');
      expect(state.user?.id, 'u1');
    });

    test(
      'token without cached user fails closed and wipes the orphan token',
      () async {
        await storage.saveToken('access-token');
        // No user_* keys in prefs: the persisted cache is inconsistent.

        await container.read(authProvider.notifier).checkAuthStatus();

        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
        // The orphaned token must be removed so the next cold start does not
        // loop through this fallback branch again.
        expect(await storage.getToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
      },
    );
  });

  group('login', () {
    test(
      'success transitions to authenticated and persists the token',
      () async {
        mockResponses({'/auth/login': _loginData});

        await container
            .read(authProvider.notifier)
            .login('a@example.com', 'pw');

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.token, 'access-token');
        expect(state.user?.email, 'a@example.com');
        expect(await storage.getToken(), 'access-token');
      },
    );

    test(
      'failure resets to unauthenticated and rethrows the typed error',
      () async {
        mockResponses({
          '/auth/login': <String, dynamic>{'code': 1, 'message': 'bad creds'},
        });

        await expectLater(
          container.read(authProvider.notifier).login('a@example.com', 'pw'),
          throwsA(isA<DataParsingException>()),
        );
        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      },
    );
  });

  group('logout', () {
    test('clears state and local credentials', () async {
      mockResponses({'/auth/login': _loginData});
      await container.read(authProvider.notifier).login('a@example.com', 'pw');
      expect(container.read(authProvider).status, AuthStatus.authenticated);

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      expect(container.read(authProvider).token, isNull);
      expect(await storage.getToken(), isNull);
      expect(prefs.getString('user_id'), isNull);
    });
  });

  group('handleSessionExpired (401 path)', () {
    test('clears state and wipes local auth data', () async {
      mockResponses({'/auth/login': _loginData});
      await container.read(authProvider.notifier).login('a@example.com', 'pw');
      seedCachedUser();

      await container.read(authProvider.notifier).handleSessionExpired();

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      expect(await storage.getToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      // PII in SharedPreferences is wiped too, matching a full logout.
      expect(prefs.getString('user_id'), isNull);
      expect(prefs.getString('user_name'), isNull);
    });
  });

  group('handleTokenRefreshed', () {
    test('syncs the rotated access token while authenticated', () async {
      mockResponses({'/auth/login': _loginData});
      await container.read(authProvider.notifier).login('a@example.com', 'pw');

      await container
          .read(authProvider.notifier)
          .handleTokenRefreshed('rotated-token');

      expect(container.read(authProvider).token, 'rotated-token');
      expect(container.read(authProvider).status, AuthStatus.authenticated);
    });

    test('is a no-op when not authenticated', () async {
      await container.read(authProvider.notifier).checkAuthStatus();

      await container
          .read(authProvider.notifier)
          .handleTokenRefreshed('rotated-token');

      expect(container.read(authProvider).token, isNull);
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });
  });

  group('derived providers', () {
    test('authStatus/currentUser/authToken track the auth state', () async {
      mockResponses({'/auth/login': _loginData});

      expect(container.read(authStatusProvider), AuthStatus.initial);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(authTokenProvider), isNull);

      await container.read(authProvider.notifier).login('a@example.com', 'pw');

      expect(container.read(authStatusProvider), AuthStatus.authenticated);
      expect(container.read(currentUserProvider)?.id, 'u1');
      expect(container.read(authTokenProvider), 'access-token');
    });
  });
}
