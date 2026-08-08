import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';

void main() {
  group('NetworkClient retry policy', () {
    late Dio dio;
    late NetworkClient client;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:9999'));
      client = NetworkClient(dio);
    });

    test('GET timeout is retried', () async {
      var calls = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );

      await expectLater(
        client.request<void>('/ping', method: HttpMethod.get, maxRetries: 2),
        throwsA(isA<NetworkException>()),
      );
      expect(calls, greaterThan(1), reason: 'GET should be retried');
    });

    test('POST timeout is NOT retried (non-idempotent)', () async {
      var calls = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );

      await expectLater(
        client.request<void>(
          '/transactions',
          method: HttpMethod.post,
          data: {'amount': 50},
          maxRetries: 2,
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(calls, 1, reason: 'POST must not be retried on timeout');
    });

    test('POST connectionError (stale socket) IS retried', () async {
      var calls = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message:
                    "Dio can't establish a new connection after it was closed",
              ),
            );
          },
        ),
      );

      await expectLater(
        client.request<void>(
          '/auth/login',
          method: HttpMethod.post,
          data: {'account': 'a@b.com'},
          maxRetries: 2,
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(
        calls,
        greaterThan(1),
        reason: 'POST connectionError should be retried on stale socket',
      );
    });

    test('DELETE timeout is NOT retried (non-idempotent)', () async {
      var calls = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.receiveTimeout,
              ),
            );
          },
        ),
      );

      await expectLater(
        client.request<void>(
          '/transactions/1',
          method: HttpMethod.delete,
          maxRetries: 3,
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(calls, 1, reason: 'DELETE must not be retried');
    });

    test('GET 500 is retried, GET 400 is not', () async {
      var calls500 = 0;
      final dio500 = Dio(BaseOptions(baseUrl: 'http://localhost:9999'));
      final client500 = NetworkClient(dio500);
      dio500.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls500++;
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 500),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        client500.request<void>('/x', method: HttpMethod.get, maxRetries: 2),
        throwsA(isA<NetworkException>()),
      );
      expect(calls500, greaterThan(1), reason: '5xx should be retried');

      var calls400 = 0;
      final dio400 = Dio(BaseOptions(baseUrl: 'http://localhost:9999'));
      final client400 = NetworkClient(dio400);
      dio400.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls400++;
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 400),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        client400.request<void>('/x', method: HttpMethod.get, maxRetries: 2),
        throwsA(isA<NetworkException>()),
      );
      expect(calls400, 1, reason: '4xx should not be retried');
    });

    test('cancelToken rejection is not retried', () async {
      var calls = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          },
        ),
      );

      await expectLater(
        client.request<void>('/x', method: HttpMethod.get, maxRetries: 2),
        throwsA(isA<NetworkException>()),
      );
      expect(calls, 1, reason: 'cancelled requests must not be retried');
    });
  });
}
