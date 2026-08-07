import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/version/models/update_info.dart';
import 'package:finvo/features/version/services/app_version_service.dart';
part 'version_provider.g.dart';

class VersionCheckState {
  final bool isChecking;
  final UpdateInfo? updateInfo;
  final String? error;

  // Sentinel distinguishing "argument not passed" from "explicitly cleared"
  // (null), giving [updateInfo] and [error] symmetric copy semantics: both
  // keep their current value when omitted, and both can be cleared to null.
  static const Object _unset = Object();

  const VersionCheckState({
    this.isChecking = false,
    this.updateInfo,
    this.error,
  });

  VersionCheckState copyWith({
    bool? isChecking,
    Object? updateInfo = _unset,
    Object? error = _unset,
  }) {
    return VersionCheckState(
      isChecking: isChecking ?? this.isChecking,
      updateInfo: identical(updateInfo, _unset)
          ? this.updateInfo
          : updateInfo as UpdateInfo?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
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
      // Reset the in-flight flag even on failure so the caller is never stuck
      // in a perpetual checking state, then surface the original error.
      state = state.copyWith(isChecking: false, error: e.toString());
      rethrow;
    }
  }
}
