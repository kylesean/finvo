import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Provides a configured LogInterceptor instance.
/// Only enables logging in Debug mode.
Interceptor get loggingInterceptor {
  return LogInterceptor(
    request: kDebugMode, // Print request summary
    requestHeader: false, // Do not print request headers in debug output
    requestBody: false, // Do not print request body
    responseHeader: false, // Do not print response headers in debug output
    responseBody: false, // Do not print response body
    error: kDebugMode, // Print error information
    logPrint: (object) {
      // Custom log printing restricted to debug builds
      if (kDebugMode) {
        debugPrint(object.toString());
      }
    },
  );
}
