import 'package:dio/dio.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/core/utils/error_translator.dart';

/// Unified conversion of DioException to custom AppException.
///
/// Maps Dio-specific errors and HTTP status codes to our domain exceptions,
/// utilizing localized strings from the i18n system where possible.
class AppExceptionFactory {
  static AppException fromDio(DioException err) {
    final responseData = err.response?.data;
    final statusCode = err.response?.statusCode ?? 0;
    final backendMessage = _extractMessage(responseData);

    // Check for business error code != 0.
    // The server returns the {code, message, data} envelope for both 2xx
    // (legacy, now retired) and 4xx (proper REST status) business errors.
    // 5xx responses are system errors — they keep their HTTP-status mapping
    // (InternalServerErrorException) rather than being treated as business errors.
    if (statusCode >= 200 && statusCode < 500) {
      if (responseData is Map<String, dynamic>) {
        final business = tryFromEnvelope(responseData);
        if (business != null) return business;
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutException(t.server.error.connectionTimeout);
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return NetworkException(t.server.error.connectionRefused);
      case DioExceptionType.badResponse:
        return _fromHttpStatus(statusCode, backendMessage);
      case DioExceptionType.cancel:
        // A user-initiated CancelToken abort is NOT a system error. Map it to
        // the dedicated RequestCancelledException so callers can swallow it
        // silently (consistent with the backoff-abort path in NetworkClient),
        // instead of surfacing a misleading "System Error" toast.
        return RequestCancelledException(t.common.cancel);
      case DioExceptionType.badCertificate:
        return NetworkException(t.server.error.sslError);
    }
  }

  /// Extract a [BusinessException] from a `{code, message, data}` envelope.
  ///
  /// The server uses this envelope for both legacy 2xx business errors and
  /// 4xx business errors. Returns null when the code is absent or zero
  /// (success), so callers can fall through to HTTP-status mapping.
  static BusinessException? tryFromEnvelope(Map<String, dynamic> data) {
    final code = data['code'];
    if (code is int && code != 0) {
      // Safe read: the backend message is not guaranteed to be a String.
      final rawMessage = data['message'];
      final message = rawMessage is String
          ? rawMessage
          : rawMessage?.toString() ?? 'Unknown business error';
      final localizedMessage = ErrorTranslator.translate(code, message);
      return BusinessException(localizedMessage, code);
    }
    return null;
  }

  static AppException _fromHttpStatus(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return BadRequestException('${t.common.error}: $message');
      case 500:
      case 502:
      case 503:
        return InternalServerErrorException(t.server.error.serverError);
      default:
        return UnexpectedHttpException(message, statusCode);
    }
  }

  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return t.server.error.serverError;
  }
}
