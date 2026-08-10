import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/features/version/models/update_info.dart';
import 'package:finvo/features/version/services/app_version_service.dart';
import 'package:finvo/shared/utils/error_message.dart';

part 'version_provider.freezed.dart';
part 'version_provider.g.dart';

/// State object for the version check flow.
@freezed
abstract class VersionCheckState with _$VersionCheckState {
  const factory VersionCheckState({
    @Default(false) bool isChecking,
    UpdateInfo? updateInfo,
    String? error,
  }) = _VersionCheckState;
}

@Riverpod(name: 'versionNotifierProvider')
class VersionNotifier extends _$VersionNotifier {
  @override
  VersionCheckState build() {
    return const VersionCheckState();
  }

  AppVersionService get _service => ref.read(appVersionServiceProvider);

  Future<UpdateInfo?> checkUpdate() async {
    state = state.copyWith(isChecking: true, error: null);
    try {
      final result = await _service.checkUpdate();
      if (!ref.mounted) return result;
      if (result != null) {
        state = state.copyWith(isChecking: false, updateInfo: result);
      } else {
        state = state.copyWith(
          isChecking: false,
          error: 'Failed to fetch update information',
        );
      }
      return result;
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isChecking: false, error: safeErrorMessage(e));
      }
      rethrow;
    }
  }
}
