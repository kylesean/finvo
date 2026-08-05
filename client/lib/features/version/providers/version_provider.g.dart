// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VersionNotifier)
final versionNotifierProvider = VersionNotifierProvider._();

final class VersionNotifierProvider
    extends $NotifierProvider<VersionNotifier, VersionCheckState> {
  VersionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionNotifierHash();

  @$internal
  @override
  VersionNotifier create() => VersionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VersionCheckState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VersionCheckState>(value),
    );
  }
}

String _$versionNotifierHash() => r'fadaa076030c7e8db0b29600001e3bc4f2673242';

abstract class _$VersionNotifier extends $Notifier<VersionCheckState> {
  VersionCheckState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VersionCheckState, VersionCheckState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VersionCheckState, VersionCheckState>,
              VersionCheckState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
