import 'package:dio/dio.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/exceptions/app_exception_factory.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppException) {
      // Known exception, return directly
      handler.next(err);
      return;
    }

    final converted = AppExceptionFactory.fromDio(err);
    final newErr = err.copyWith(error: converted);
    handler.next(newErr);
  }
}
