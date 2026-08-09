// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_guide_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Welcome Guide Provider - returns greetings and contextual suggestions based on current time

@ProviderFor(welcomeGuide)
final welcomeGuideProvider = WelcomeGuideProvider._();

/// Welcome Guide Provider - returns greetings and contextual suggestions based on current time

final class WelcomeGuideProvider
    extends
        $FunctionalProvider<
          WelcomeGuideState,
          WelcomeGuideState,
          WelcomeGuideState
        >
    with $Provider<WelcomeGuideState> {
  /// Welcome Guide Provider - returns greetings and contextual suggestions based on current time
  WelcomeGuideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'welcomeGuideProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$welcomeGuideHash();

  @$internal
  @override
  $ProviderElement<WelcomeGuideState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WelcomeGuideState create(Ref ref) {
    return welcomeGuide(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WelcomeGuideState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WelcomeGuideState>(value),
    );
  }
}

String _$welcomeGuideHash() => r'69a662cbd4363ad9dad223fa6e9c24360b5f0bff';
