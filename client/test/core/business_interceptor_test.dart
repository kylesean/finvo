// test/core/business_interceptor_test.dart
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/interceptors/business_interceptor.dart';

class _BodyAdapter implements HttpClientAdapter {
  final int statusCode;
  final String body;
  final String? contentType;

  _BodyAdapter(this.statusCode, this.body, {this.contentType});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        if (contentType != null) Headers.contentTypeHeader: [contentType!],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('BusinessInterceptor', () {
    Dio makeDio(String body, {String? contentType = Headers.jsonContentType}) {
      final d = Dio(BaseOptions(baseUrl: 'https://example.com'));
      d.interceptors.add(BusinessInterceptor());
      d.httpClientAdapter = _BodyAdapter(200, body, contentType: contentType);
      return d;
    }

    test('stream/SSE responses pass through untouched', () async {
      final d = makeDio('not json', contentType: 'text/event-stream');
      final res = await d.get<dynamic>('/sse');
      expect(res.data, 'not json');
    });

    test('non-JSON response is rejected as DataParsingException', () async {
      final d = makeDio('hello', contentType: 'text/plain');
      await expectLater(
        d.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<DataParsingException>(),
          ),
        ),
      );
    });

    test('missing code field is rejected as DataParsingException', () async {
      final d = makeDio('{"message":"no code"}');
      await expectLater(
        d.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<DataParsingException>(),
          ),
        ),
      );
    });

    test('business code != 0 is rejected as BusinessException', () async {
      final d = makeDio('{"code":1001,"message":"boom"}');
      await expectLater(
        d.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<BusinessException>(),
          ),
        ),
      );
    });

    test('code == 0 passes through unchanged', () async {
      final d = makeDio('{"code":0,"data":{"id":1}}');
      final res = await d.get<dynamic>('/x');
      expect((res.data as Map<String, dynamic>)['code'], 0);
      expect((res.data as Map<String, dynamic>)['data'], {'id': 1});
    });
  });
}
