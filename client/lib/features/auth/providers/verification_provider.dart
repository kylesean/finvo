import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/features/auth/services/auth_service.dart';

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
      state = state.copyWith(
        status: VerificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const VerificationState();
  }
}
