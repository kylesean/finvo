import 'package:dio/dio.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/exceptions/app_exception_factory.dart';

typedef FromJsonT<T> = T Function(Object? json);

class BusinessInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // Dio only invokes onResponse for 2xx responses (default validateStatus),
    // so no status-code guard is needed here.

    // Skip validation for stream responses (e.g., SSE)
    if (response.requestOptions.responseType == ResponseType.stream ||
        (response.headers
                .value('content-type')
                ?.contains('text/event-stream') ??
            false)) {
      return handler.next(response);
    }

    // Skip validation for binary responses (e.g. authenticated image/file
    // downloads via ResponseType.bytes): the payload is List<int>, not a JSON
    // envelope, and would otherwise be rejected as a malformed business
    // response, breaking every binary endpoint that shares this Dio pipeline.
    if (response.requestOptions.responseType == ResponseType.bytes) {
      return handler.next(response);
    }

    // Response must be a JSON object
    if (response.data is! Map<String, dynamic>) {
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: DataParsingException(
            'Response format error: expected JSON object, but received ${response.data.runtimeType}',
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    final data = response.data as Map<String, dynamic>;

    // 'code' field is mandatory
    if (!data.containsKey('code')) {
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: DataParsingException(
            "API response format error: missing 'code' field.",
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    // If code != 0, it's a business error. Reuse the shared envelope parsing
    // from AppExceptionFactory instead of duplicating the extraction here.
    final businessError = AppExceptionFactory.tryFromEnvelope(data);
    if (businessError != null) {
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: businessError,
          type: DioExceptionType.badResponse,
        ),
      );
    }

    // Keep complete response format {code, message, data}
    // Don't auto-extract data field to ensure consistency across all APIs (including pagination)
    // response.data remains unchanged, let the caller handle it uniformly
    handler.next(response);
  }
}
