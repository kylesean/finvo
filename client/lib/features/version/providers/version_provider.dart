import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/update_info.dart';
import '../services/app_version_service.dart';
part 'version_provider.g.dart';

class VersionCheckState {
  final bool isChecking;
  final UpdateInfo? updateInfo;
  final String? error;

  const VersionCheckState({
    this.isChecking = false,
    this.updateInfo,
    this.error,
  });

  VersionCheckState copyWith({
    bool? isChecking,
    UpdateInfo? updateInfo,
    String? error,
  }) {
    return VersionCheckState(
      isChecking: isChecking ?? this.isChecking,
      updateInfo: updateInfo ?? this.updateInfo,
      error: error,
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
  }
}
