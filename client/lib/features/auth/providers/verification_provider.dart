import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:finvo/features/auth/services/auth_service.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/i18n/strings.g.dart';

part 'verification_provider.freezed.dart';
part 'verification_provider.g.dart';

enum VerificationStatus { initial, sendingCode, codeSent, error }

@freezed
abstract class VerificationState with _$VerificationState {
  const factory VerificationState({
    @Default(VerificationStatus.initial) VerificationStatus status,
    String? errorMessage,
  }) = _VerificationState;
}

@riverpod
class Verification extends _$Verification {
  final _logger = Logger('Verification');
  @override
  VerificationState build() {
    return const VerificationState();
  }

  Future<void> sendVerificationCode(String contact) async {
    try {
      state = state.copyWith(
        status: VerificationStatus.sendingCode,
        errorMessage: null,
      );
      final authService = ref.read(authServiceProvider);
      await authService.sendVerificationCode(contact);
      state = state.copyWith(status: VerificationStatus.codeSent);
    } catch (e) {
      // Surface a localized/typed AppException message when available, never
      // leak the raw exception text (which may contain internal details) to
      // the UI. Fall back to a generic message otherwise.
      final message = _safeErrorMessage(e);
      state = state.copyWith(
        status: VerificationStatus.error,
        errorMessage: message,
      );
      _logger.warning('sendVerificationCode failed', e);
    }
  }

  /// Extract a safe, user-displayable error message from [error].
  ///
  /// Recognises [AppException] (including one wrapped in a [DioException])
  /// and falls back to a generic unknown-error message — never [error.toString()].
  String _safeErrorMessage(Object error) {
    if (error is DioException && error.error is AppException) {
      return (error.error as AppException).message;
    }
    if (error is AppException) {
      return error.message;
    }
    return t.auth.verificationCode.sendFailed;
  }

  void reset() {
    state = const VerificationState();
  }
}
