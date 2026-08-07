import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/interceptors/auth_interceptor.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  String? token;
  String? refreshToken;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == 'auth_token') token = value;
    if (key == 'auth_refresh_token') refreshToken = value;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == 'auth_token') return token;
    if (key == 'auth_refresh_token') return refreshToken;
    return null;
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == 'auth_token') token = null;
    if (key == 'auth_refresh_token') refreshToken = null;
  }
}

class _ThrowingSecureStorage extends FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw Exception('Keychain unavailable');
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw Exception('Keychain unavailable');
  }
}

void main() {
  group('AuthInterceptor', () {
    late Dio dio;
    late SecureStorageService storageService;
    late _FakeSecureStorage fakeStorage;
    final unauthorizedCalls = <String>[];

    setUp(() {
      fakeStorage = _FakeSecureStorage();
      storageService = SecureStorageService(fakeStorage);
      unauthorizedCalls.clear();
      dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          storageService,
          onUnauthorized: () async => unauthorizedCalls.add('triggered'),
        ),
      );
    });

    test('adds Bearer token from secure storage on request', () async {
      await fakeStorage.write(key: 'auth_token', value: 'tok123');
      RequestOptions? capturedOptions;
      dio.httpClientAdapter = _CaptureAdapter((options) {
        capturedOptions = options;
      });

      await dio.get<dynamic>('https://example.com/api');
      expect(capturedOptions?.headers['Authorization'], 'Bearer tok123');
    });

    test('401 triggers onUnauthorized callback', () async {
      var called = false;
      dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          storageService,
          onUnauthorized: () async => called = true,
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onError: (e, handler) async {
            handler.next(e);
          },
        ),
      );
      dio.httpClientAdapter = _MockAdapter(401);

      await expectLater(
        dio.get<dynamic>('https://example.com/api'),
        throwsA(isA<DioException>()),
      );
      expect(called, isTrue);
    });

    test('non-401 does not trigger onUnauthorized', () async {
      var called = false;
      dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          storageService,
          onUnauthorized: () async => called = true,
        ),
      );
      dio.httpClientAdapter = _MockAdapter(500);

      await expectLater(
        dio.get<dynamic>('https://example.com/api'),
        throwsA(isA<DioException>()),
      );
      expect(called, isFalse);
    });

    test('missing token attaches no Authorization header', () async {
      RequestOptions? seenOptions;
      dio.httpClientAdapter = _CaptureAdapter((options) {
        seenOptions = options;
      });

      await dio.get<dynamic>('https://example.com/api');
      expect(seenOptions?.headers['Authorization'], isNull);
    });
  });

  group('AuthInterceptor refresh-and-replay', () {
    late _FakeSecureStorage fakeStorage;
    late SecureStorageService storageService;
    final unauthorizedCalls = <String>[];
    late Dio refreshDio;

    setUp(() {
      fakeStorage = _FakeSecureStorage();
      storageService = SecureStorageService(fakeStorage);
      unauthorizedCalls.clear();
      // A dedicated refresh client whose /auth/refresh returns fresh tokens.
      // A non-empty baseUrl tells the interceptor to reuse this injected
      // client instead of spinning up a fresh Dio bound to the failing host.
      refreshDio = Dio(BaseOptions(baseUrl: 'https://placeholder.test/'));
      refreshDio.httpClientAdapter = _RefreshAdapter();
      // Seed a refresh token so the 401 path actually attempts a refresh.
      fakeStorage.refreshToken = 'seed-refresh-token';
    });

    Dio makeInterceptorDio(HttpClientAdapter adapter) {
      final d = Dio();
      d.interceptors.add(
        AuthInterceptor(
          storageService,
          onUnauthorized: () async => unauthorizedCalls.add('triggered'),
          dio: d,
          refreshDio: refreshDio,
        ),
      );
      d.httpClientAdapter = adapter;
      return d;
    }

    test(
      'replay network failure does NOT sign out and propagates error (M1)',
      () async {
        // 1st call -> 401 (triggers refresh), replay -> network error.
        final d = makeInterceptorDio(
          _SequencedAdapter([_mockResponse(401), _mockNetworkError]),
        );

        await expectLater(
          d.get<dynamic>('https://example.com/api'),
          throwsA(
            isA<DioException>().having(
              (e) => e.type,
              'type',
              DioExceptionType.connectionError,
            ),
          ),
        );
        // Must NOT sign out: the session is still valid, only the network hiccuped.
        expect(unauthorizedCalls, isEmpty);
      },
    );

    test('replay still-401 DOES sign out (genuinely invalid token)', () async {
      final d = makeInterceptorDio(
        _SequencedAdapter([_mockResponse(401), _mockResponse(401)]),
      );

      await expectLater(
        d.get<dynamic>('https://example.com/api'),
        throwsA(isA<DioException>()),
      );
      expect(unauthorizedCalls, ['triggered']);
    });
  });

  group('SecureStorageService fail-closed', () {
    test(
      'saveToken throws when Keychain fails (no plaintext fallback)',
      () async {
        final service = SecureStorageService(_ThrowingSecureStorage());
        await expectLater(
          service.saveToken('secret'),
          throwsA(isA<SecureStorageUnavailableException>()),
        );
      },
    );

    test('getToken throws when Keychain read fails', () async {
      final service = SecureStorageService(_ThrowingSecureStorage());
      await expectLater(
        service.getToken(),
        throwsA(isA<SecureStorageUnavailableException>()),
      );
    });

    test('save/get roundtrip works when Keychain is healthy', () async {
      final service = SecureStorageService(_FakeSecureStorage());
      await service.saveToken('secret');
      expect(await service.getToken(), 'secret');
      await service.deleteToken();
      expect(await service.getToken(), isNull);
    });

    test('deleteToken failure does not block logout', () async {
      final service = SecureStorageService(_ThrowingSecureStorage());
      // Should not throw: deletion is best-effort during logout
      await service.deleteToken();
    });
  });
}

class _MockAdapter implements HttpClientAdapter {
  final int statusCode;
  _MockAdapter(this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (statusCode == 200) {
      return ResponseBody.fromString(
        '{"code":0,"data":{}}',
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    throw DioException(
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: statusCode,
        statusMessage: 'error',
        data: '{"code":1}',
      ),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CaptureAdapter implements HttpClientAdapter {
  final void Function(RequestOptions options) onRequest;
  _CaptureAdapter(this.onRequest);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest(options);
    return ResponseBody.fromString(
      '{"code":0,"data":{}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Adapter for the dedicated refresh client: always returns fresh tokens.
class _RefreshAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"code":0,"data":{"token":"new-access-token",'
      '"refresh_token":"new-refresh-token"}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Returns a 401 DioException for the given options.
DioException _mockResponse(int statusCode) {
  return DioException(
    requestOptions: RequestOptions(path: '/api'),
    response: Response<dynamic>(
      requestOptions: RequestOptions(path: '/api'),
      statusCode: statusCode,
      statusMessage: 'error',
      data: '{"code":1}',
    ),
    type: DioExceptionType.badResponse,
  );
}

/// A connection-level error (no HTTP response).
final DioException _mockNetworkError = DioException(
  requestOptions: RequestOptions(path: '/api'),
  type: DioExceptionType.connectionError,
);

/// Serves pre-built outcomes in order.
///
/// Critically, the thrown [DioException] is rebuilt with the *incoming*
/// [options] as its `requestOptions` so any interceptor-set markers (e.g. the
/// `_refreshedKey` extra flag) survive into the error handling chain — exactly
/// as a real network failure would. Throwing a pre-built exception whose
/// requestOptions is a fresh object would silently drop those markers and
/// break interceptor logic.
class _SequencedAdapter implements HttpClientAdapter {
  final List<DioException> _outcomes;
  int _index = 0;

  _SequencedAdapter(List<DioException> outcomes) : _outcomes = outcomes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_index >= _outcomes.length) {
      return ResponseBody.fromString(
        '{"code":0,"data":{}}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    final e = _outcomes[_index++];
    // Rebuild the exception against the real request options so extra flags
    // set by interceptors survive.
    throw DioException(
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
        data: e.response?.data,
      ),
      type: e.type,
    );
  }

  @override
  void close({bool force = false}) {}
}
