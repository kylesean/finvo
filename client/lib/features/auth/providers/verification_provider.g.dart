// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Verification)
final verificationProvider = VerificationProvider._();

final class VerificationProvider
    extends $NotifierProvider<Verification, VerificationState> {
  VerificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationHash();

  @$internal
  @override
  Verification create() => Verification();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerificationState>(value),
    );
  }
}

String _$verificationHash() => r'4b56f7117897483ca0fd4412f80da4897013279a';

abstract class _$Verification extends $Notifier<VerificationState> {
  VerificationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VerificationState, VerificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerificationState, VerificationState>,
              VerificationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
