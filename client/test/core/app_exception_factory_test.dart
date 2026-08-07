// test/core/app_exception_factory_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/exceptions/app_exception_factory.dart';

void main() {
  DioException dioException({
    required DioExceptionType type,
    int? statusCode,
    Object? data,
  }) {
    return DioException(
      requestOptions: RequestOptions(path: '/api'),
      type: type,
      response: statusCode != null
          ? Response<dynamic>(
              requestOptions: RequestOptions(path: '/api'),
              statusCode: statusCode,
              data: data,
            )
          : null,
    );
  }

  group('AppExceptionFactory.fromDio', () {
    test('timeout types map to TimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        expect(
          AppExceptionFactory.fromDio(dioException(type: type)),
          isA<TimeoutException>(),
        );
      }
    });

    test('connectionError and unknown map to NetworkException', () {
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.connectionError),
        ),
        isA<NetworkException>(),
      );
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.unknown),
        ),
        isA<NetworkException>(),
      );
    });

    test('user-initiated cancel maps to RequestCancelledException', () {
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.cancel),
        ),
        isA<RequestCancelledException>(),
      );
    });

    test('badCertificate maps to NetworkException', () {
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.badCertificate),
        ),
        isA<NetworkException>(),
      );
    });

    test('HTTP 400 maps to BadRequestException', () {
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.badResponse, statusCode: 400),
        ),
        isA<BadRequestException>(),
      );
    });

    test('HTTP 401 maps to UnauthorizedException', () {
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.badResponse, statusCode: 401),
        ),
        isA<UnauthorizedException>(),
      );
    });

    test('HTTP 403 maps to ForbiddenException', () {
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.badResponse, statusCode: 403),
        ),
        isA<ForbiddenException>(),
      );
    });

    test('HTTP 404 maps to NotFoundException', () {
      expect(
        AppExceptionFactory.fromDio(
          dioException(type: DioExceptionType.badResponse, statusCode: 404),
        ),
        isA<NotFoundException>(),
      );
    });

    test('HTTP 5xx maps to InternalServerErrorException', () {
      for (final code in [500, 502, 503]) {
        expect(
          AppExceptionFactory.fromDio(
            dioException(type: DioExceptionType.badResponse, statusCode: code),
          ),
          isA<InternalServerErrorException>(),
        );
      }
    });

    test('unmapped status maps to UnexpectedHttpException with code', () {
      final e = AppExceptionFactory.fromDio(
        dioException(type: DioExceptionType.badResponse, statusCode: 418),
      );
      expect(e, isA<UnexpectedHttpException>());
      expect((e as UnexpectedHttpException).statusCode, 418);
    });

    test('business envelope wins over HTTP status for 2xx/4xx', () {
      final e = AppExceptionFactory.fromDio(
        dioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'code': 1001, 'message': 'boom'},
        ),
      );
      expect(e, isA<BusinessException>());
    });

    test('business envelope is ignored for 5xx (keeps HTTP mapping)', () {
      final e = AppExceptionFactory.fromDio(
        dioException(
          type: DioExceptionType.badResponse,
          statusCode: 500,
          data: {'code': 1001, 'message': 'boom'},
        ),
      );
      expect(e, isA<InternalServerErrorException>());
    });
  });

  group('AppExceptionFactory.tryFromEnvelope', () {
    test('missing code returns null', () {
      expect(AppExceptionFactory.tryFromEnvelope({'message': 'x'}), isNull);
    });

    test('code == 0 returns null (success)', () {
      expect(AppExceptionFactory.tryFromEnvelope({'code': 0}), isNull);
    });

    test('non-int code returns null', () {
      expect(AppExceptionFactory.tryFromEnvelope({'code': 'oops'}), isNull);
    });

    test('code != 0 returns BusinessException with code and message', () {
      final e = AppExceptionFactory.tryFromEnvelope({
        'code': 99999,
        'message': 'boom',
      });
      expect(e, isA<BusinessException>());
      expect(e!.code, 99999);
      expect(e.message, 'boom');
    });

    test('non-string message falls back to its string form', () {
      final e = AppExceptionFactory.tryFromEnvelope({'code': 1, 'message': 42});
      expect(e!.message, '42');
    });
  });
}
