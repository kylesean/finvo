import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Provides a configured LogInterceptor instance.
/// Only enables logging in Debug mode.
Interceptor get loggingInterceptor {
  return LogInterceptor(
    request: kDebugMode, // Print request summary
    requestHeader: false, // Do not spam headers
    requestBody: false, // Print request body
    responseHeader: false, // Do not spam headers
    responseBody: false, // Print response body
    error: kDebugMode, // Print error information
    logPrint: (object) {
      // Custom log printing method
      if (kDebugMode) {
        debugPrint(object.toString());
      }
    },
  );
}
