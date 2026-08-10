import 'package:logging/logging.dart';
import 'package:dio/dio.dart';
import 'package:finvo/core/network/dio_provider.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/network/interceptors/business_interceptor.dart';

// Define HTTP method enum for type safety
enum HttpMethod { get, post, put, delete, patch }

class NetworkClient {
  final Dio _dio;
  final _logger = Logger('NetworkClient');

  NetworkClient(this._dio);

  Dio get dio => _dio;

  /// Unwrap the common `{ "data": ... }` response envelope used by the backend.
  ///
  /// Shared by every service's `fromJsonT` to avoid near-identical unwrap
  /// boilerplate (previously duplicated in profile/budget/home/comment/
  /// shared_space/notification services):
  /// - Non-object envelopes and non-object/`null` payloads raise
  ///   [DataParsingException] with a consistent message (unless [onNull]
  ///   supplies a fallback for a null payload).
  /// - Decode failures are re-wrapped so the raw parser error never leaks.
  T unwrapData<T>(
    Object? json,
    T Function(Map<String, dynamic> data) fromJson, {
    required String endpoint,
    T Function()? onNull,
  }) {
    if (json is! Map<String, dynamic>) {
      throw DataParsingException(
        'API $endpoint expects an object, but received ${json.runtimeType}',
      );
    }
    final data = json['data'];
    if (data == null) {
      if (onNull != null) return onNull();
      throw DataParsingException('data field is null');
    }
    if (data is! Map<String, dynamic>) {
      throw DataParsingException(
        'data field is not an object, but ${data.runtimeType}',
      );
    }
    try {
      return fromJson(data);
    } catch (e) {
      throw DataParsingException(
        'Failed to parse $endpoint response: ${e.toString()}',
      );
    }
  }

  /// Generic network request method
  /// - [path]: API relative path
  /// - [method]: HTTP method (GET, POST, etc.)
  /// - [queryParameters]: URL query parameters
  /// - [data]: Request body (for POST, PUT, PATCH)
  /// - [fromJsonT]: Callback to convert response data to generic type T
  /// - [options]: Optional Dio Options to override defaults or pass extra info
  /// - [enableRetry]: Enable retry mechanism. **Only idempotent (GET) requests
  ///   are ever retried** — non-idempotent methods (POST/PUT/DELETE/PATCH)
  ///   ignore this flag and never retry, because a timed-out write may already
  ///   have succeeded server-side and retrying could create/duplicate a
  ///   resource. Default true.
  /// - [maxRetries]: Maximum retry attempts for idempotent requests, default 3.
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    FromJsonT<T>? fromJsonT, // T Function(Object? json)
    Options? options,
    CancelToken? cancelToken,
    bool enableRetry = true,
    int maxRetries = 3,
  }) async {
    final isIdempotentMethod = method == HttpMethod.get;
    return await _executeWithRetry<T>(
      () async {
        // Prepare Options
        final requestOptions = (options ?? Options()).copyWith(
          method: method.name, // Convert enum to "GET", "POST" strings
        );

        // Execute request
        final Response<dynamic> response = await _dio.request(
          path,
          data: data,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          options: requestOptions,
        );

        return response;
      },
      fromJsonT: fromJsonT,
      enableRetry: enableRetry,
      maxRetries: maxRetries,
      path: path,
      isIdempotentMethod: isIdempotentMethod,
      cancelToken: cancelToken,
    );
  }

  /// Request executor with retry mechanism
  Future<T> _executeWithRetry<T>(
    Future<Response<dynamic>> Function() requestFunction, {
    FromJsonT<T>? fromJsonT,
    required bool enableRetry,
    required int maxRetries,
    required String path,
    required bool isIdempotentMethod,
    CancelToken? cancelToken,
  }) async {
    int attempts = 0;
    int retriesPerformed = 0;
    DioException? lastException;

    while (attempts <= maxRetries) {
      try {
        final response = await requestFunction();

        // Perform final type conversion here
        // BusinessInterceptor maintains complete response format {code, message, data}
        // response.data is complete object containing code, message, data
        if (fromJsonT != null) {
          try {
            return fromJsonT(response.data);
          } catch (e, stackTrace) {
            _logger.severe('fromJsonT parsing failed', e, stackTrace);
            // Throw specific data parsing exception
            throw DataParsingException(
              'Client data parsing failed: ${e.toString()}',
            );
          }
        } else {
          // If no parser provided, assume caller expects raw data
          // and perform safe type check
          if (response.data is T) {
            return response.data as T;
          } else {
            // Type mismatch is also a parsing error
            throw DataParsingException(
              'Response data type mismatch. Received: ${response.data.runtimeType}, Expected: $T',
            );
          }
        }
      } on DioException catch (e) {
        lastException = e;
        attempts++;

        // Check if should retry
        if (!enableRetry ||
            attempts > maxRetries ||
            !_shouldRetry(e, isIdempotentMethod: isIdempotentMethod)) {
          break;
        }

        _logger.warning(
          'Request failed, preparing retry ($attempts/$maxRetries): ${e.message}',
        );

        // Wait before retry (exponential backoff: 500ms, 1s, 2s, 4s, ... capped)
        final delay = _exponentialBackoff(attempts);
        if (cancelToken != null) {
          // Abort the backoff wait the moment the caller cancels the request,
          // instead of sleeping through the full delay and retrying a request
          // nobody cares about anymore.
          await Future.any<void>([
            Future<void>.delayed(delay),
            cancelToken.whenCancel,
          ]);
          if (cancelToken.isCancelled) {
            // Throw a typed AppException (not a raw DioException) so the caller
            // can distinguish "user cancelled" from "network failure" and
            // swallow it silently. A raw DioException here would bypass the
            // interceptor normalization chain and break the error contract.
            throw RequestCancelledException('Request cancelled by user');
          }
        } else {
          await Future<void>.delayed(delay);
        }
        retriesPerformed++;
        continue;
      } catch (e, stackTrace) {
        if (e is AppException) rethrow;
        _logger.severe('Caught unknown error', e, stackTrace);
        // Wrap in a typed AppException so callers can handle it uniformly,
        // while preserving the original stack for debugging.
        Error.throwWithStackTrace(
          GeneralException('Unexpected client error: $e'),
          stackTrace,
        );
      }
    }

    // lastException is guaranteed non-null here: the loop either returns on
    // success or records a DioException before breaking/rethrowing, so the
    // former `if (lastException != null)` guard and its unreachable fallback
    // throw were dead code and are removed.
    final failure = lastException!;
    // Run network diagnostics before final failure
    _handleFinalFailure(failure, path);

    // ErrorInterceptor should have filled e.error with AppException subclass
    if (failure.error is AppException) {
      throw failure.error as AppException;
    }
    _logger.severe(
      'All retries failed, final error: ${failure.type}, ${failure.message}',
    );
    throw NetworkException(
      // Report the number of retries actually performed (0 for
      // non-idempotent/disabled retry), not the configured max.
      "Network request failed, retried $retriesPerformed times: ${failure.message ?? 'Unknown network error'}",
    );
  }

  /// Determine if request should be retried
  ///
  /// Socket connection error ([DioExceptionType.connectionError]) occurs when the
  /// underlying TCP socket is closed/reset by the server (e.g. Keep-Alive idle timeout
  /// race condition). Because the request failed at the socket connection layer before an
  /// HTTP exchange was established, it is safe to retry once with a fresh socket connection
  /// for all HTTP methods (including POST/PUT/DELETE).
  ///
  /// Non-idempotent methods (POST/PUT/DELETE/PATCH) are otherwise not retried for
  /// timeouts or bad responses: a timed-out write may already have succeeded server-side,
  /// so retrying could create/modify resources twice.
  bool _shouldRetry(DioException e, {required bool isIdempotentMethod}) {
    // Stale TCP socket connection error (Keep-Alive closed connection) is always
    // safe to retry on a fresh connection.
    if (e.type == DioExceptionType.connectionError) {
      return true;
    }

    // Non-idempotent methods are never retried for timeouts or bad responses
    if (!isIdempotentMethod) {
      return false;
    }

    // Only retry for specific error types on idempotent (GET) requests
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return true;
      case DioExceptionType.badResponse:
        // Can retry for 5xx server errors
        final statusCode = e.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      default:
        return false;
    }
  }

  /// Exponential backoff delay in milliseconds:
  /// attempts 1, 2, 3, 4 -> 500, 1000, 2000, 4000 (capped at 8s for 5+)
  Duration _exponentialBackoff(int attempts) {
    final cappedAttempts = attempts > 5 ? 5 : attempts;
    return Duration(milliseconds: 500 << (cappedAttempts - 1));
  }

  /// Handle final failure, log error details
  void _handleFinalFailure(DioException e, String path) {
    _logger.info('Final failure for path: $path');
    _logger.info('Error type: ${e.type}, Message: ${e.message}');
  }

  Future<Map<String, dynamic>> requestMap(
    String path, {
    required HttpMethod method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool enableRetry = true,
    int maxRetries = 3,
  }) {
    return request<Map<String, dynamic>>(
      path,
      method: method,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      enableRetry: enableRetry,
      maxRetries: maxRetries,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}

// Riverpod Provider for NetworkClient
final networkClientProvider = Provider<NetworkClient>((ref) {
  final dio = ref.watch(dioProvider);
  return NetworkClient(dio);
});
