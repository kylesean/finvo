// test/core/error_interceptor_test.dart
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/interceptors/error_interceptor.dart';

/// Adapter that always throws the given [DioException], rebuilt against the
/// incoming [options] so interceptor-set markers survive (matching real
/// network failures).
class _ThrowingAdapter implements HttpClientAdapter {
  final DioException error;

  _ThrowingAdapter(this.error);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      response: error.response,
      type: error.type,
      error: error.error,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ErrorInterceptor', () {
    test(
      'non-AppException server error is converted to AppException',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        dio.interceptors.add(ErrorInterceptor());
        dio.httpClientAdapter = _ThrowingAdapter(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: '/x'),
              statusCode: 500,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        await expectLater(
          dio.get<dynamic>('/x'),
          throwsA(
            isA<DioException>().having(
              (e) => e.error,
              'error',
              isA<InternalServerErrorException>(),
            ),
          ),
        );
      },
    );

    test('existing AppException is passed through unchanged', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.interceptors.add(ErrorInterceptor());
      final original = BusinessException('boom', 1001);
      dio.httpClientAdapter = _ThrowingAdapter(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          error: original,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 400,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having((e) => e.error, 'error', same(original)),
        ),
      );
    });
  });
}
