import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
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
  late NetworkClient networkClient;
  late RequestOptions lastRequest;
  late _FakeSecureStorageService storage;
  late SharedPreferences prefs;
  late AuthService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = _FakeSecureStorageService();
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:9999'));
    networkClient = NetworkClient(dio);
    service = AuthService(
      networkClient,
      _FakeTimezoneService(),
      prefs,
      storage,
    );
  });

  /// Routes every request to a canned response map (also captures it).
  void mockResponses(Map<String, Map<String, dynamic>> responses) {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;
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

  group('login', () {
    test(
      'phone account is sent with type=mobile and saves credentials',
      () async {
        mockResponses({'/auth/login': _loginData});

        final result = await service.login('13812345678', 'secret123');

        expect(result.token, 'access-token');
        expect(result.user.id, 'u1');

        // Request payload carries account type detection + timezone.
        // The server schemas accept only 'email' | 'mobile' (see
        // server/app/schemas/auth.py), so 'mobile' is the contract value.
        final data = lastRequest.data as Map<String, dynamic>;
        expect(data['type'], 'mobile');
        expect(data['account'], '13812345678');
        expect(data['timezone'], 'Asia/Shanghai');

        // Credentials persisted through the single secure-storage entry point.
        expect(await storage.getToken(), 'access-token');
        expect(await storage.getRefreshToken(), 'refresh-token');

        // Non-sensitive user data in shared preferences.
        expect(prefs.getString('user_id'), 'u1');
        expect(prefs.getString('user_name'), 'alice');
        expect(prefs.getString('user_email'), 'a@example.com');
      },
    );

    test('email account is sent with type=email', () async {
      mockResponses({'/auth/login': _loginData});

      await service.login('bob@example.com', 'secret123');

      final data = lastRequest.data as Map<String, dynamic>;
      expect(data['type'], 'email');
    });

    test(
      'propagates DataParsingException when data field is missing',
      () async {
        mockResponses({
          '/auth/login': <String, dynamic>{'code': 1, 'message': 'bad'},
        });

        await expectLater(
          service.login('13812345678', 'secret123'),
          throwsA(isA<DataParsingException>()),
        );
      },
    );
  });

  group('register', () {
    test('sends type, code, timezone and locale', () async {
      mockResponses({'/auth/register': _loginData});

      final result = await service.register(
        account: '13812345678',
        password: 'secret123',
        verificationCode: '8888',
      );

      expect(result.token, 'access-token');
      final data = lastRequest.data as Map<String, dynamic>;
      expect(data['type'], 'mobile');
      expect(data['code'], '8888');
      expect(data['timezone'], 'Asia/Shanghai');
      // locale is resolved from the host platform; only assert presence.
      expect(data['locale'], isA<String>());
    });
  });

  group('sendVerificationCode', () {
    test('posts account with detected type', () async {
      mockResponses({
        '/auth/send-code': <String, dynamic>{'data': null},
      });

      await service.sendVerificationCode('13812345678');

      final data = lastRequest.data as Map<String, dynamic>;
      expect(data['type'], 'mobile');
      expect(data['account'], '13812345678');
    });
  });

  group('getStoredAuthData', () {
    test('returns null when no credentials are stored', () async {
      expect(await service.getStoredAuthData(), isNull);
    });

    test('returns token + user when both are present', () async {
      mockResponses({'/auth/login': _loginData});
      await service.login('13812345678', 'secret123');

      final stored = await service.getStoredAuthData();

      expect(stored, isNotNull);
      expect(stored!['token'], 'access-token');
      final user = stored['user'] as dynamic;
      expect(user.id, 'u1');
    });
  });

  group('logout', () {
    test('clears both secure storage and shared preferences', () async {
      mockResponses({'/auth/login': _loginData});
      await service.login('13812345678', 'secret123');
      expect(await storage.getToken(), isNotNull);

      await service.logout();

      expect(await storage.getToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(prefs.getString('user_id'), isNull);
      expect(prefs.getString('user_name'), isNull);
      expect(prefs.getString('user_email'), isNull);
      expect(await service.getStoredAuthData(), isNull);
    });
  });
}
