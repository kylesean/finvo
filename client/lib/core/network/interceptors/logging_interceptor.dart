import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Provides a clean, concise HTTP LoggingInterceptor.
///
/// In Debug mode, it prints clean single-line summaries for requests, responses, and errors.
/// In Release/Profile mode, it is completely silent.
Interceptor get loggingInterceptor {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      if (kDebugMode) {
        debugPrint('[HTTP] 🚀 ${options.method} -> ${options.uri}');
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      if (kDebugMode) {
        final statusCode = response.statusCode ?? 0;
        debugPrint(
          '[HTTP] ✅ $statusCode <- ${response.requestOptions.method} ${response.requestOptions.uri}',
        );
      }
      return handler.next(response);
    },
    onError: (DioException err, handler) {
      if (kDebugMode) {
        final statusCode = err.response?.statusCode ?? 'ERR';
        debugPrint(
          '[HTTP] ❌ $statusCode <- ${err.requestOptions.method} ${err.requestOptions.uri} (${err.message})',
        );
      }
      return handler.next(err);
    },
  );
}
