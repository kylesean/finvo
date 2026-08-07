import 'package:dio/dio.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';

/// Extracts a safe, user-displayable error message from [error], preferring a
/// typed/localized [AppException] message and never leaking raw exception text
/// (which may contain internal details) to the UI.
///
/// Recognises [AppException], including one wrapped in a [DioException]. When
/// [error] is null or not a recognised exception type, returns [fallback]
/// (defaults to [t.common.error]).
String safeErrorMessage(Object? error, {String? fallback}) {
  if (error is DioException && error.error is AppException) {
    return (error.error as AppException).message;
  }
  if (error is AppException) {
    return error.message;
  }
  return fallback ?? t.common.error;
}
