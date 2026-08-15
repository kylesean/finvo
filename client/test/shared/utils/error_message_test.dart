import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/utils/error_message.dart';

void main() {
  group('safeErrorMessage', () {
    test('returns the AppException message verbatim', () {
      final exception = BusinessException('业务错误', 1001);
      expect(safeErrorMessage(exception), '业务错误');
    });

    test('unwraps an AppException embedded in a DioException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/x'),
        error: NetworkException('网络不可用'),
      );
      expect(safeErrorMessage(dioException), '网络不可用');
    });

    test('never leaks raw exception text for unknown errors', () {
      expect(
        safeErrorMessage(
          Exception('internal url: https://secret.internal/path'),
          fallback: 'oops',
        ),
        'oops',
      );
      expect(safeErrorMessage(null, fallback: 'oops'), 'oops');
    });

    test('defaults to the generic error label when no fallback is given', () {
      expect(safeErrorMessage(Exception('x')), t.common.error);
    });
  });
}
