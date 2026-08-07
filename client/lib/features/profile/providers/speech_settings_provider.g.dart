// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Speech settings Notifier
///
/// [keepAlive] so the locally-stored settings are kept in memory after the
/// startup pre-warm instead of being re-read on every screen mount.

@ProviderFor(SpeechSettingsNotifier)
final speechSettingsProvider = SpeechSettingsNotifierProvider._();

/// Speech settings Notifier
///
/// [keepAlive] so the locally-stored settings are kept in memory after the
/// startup pre-warm instead of being re-read on every screen mount.
final class SpeechSettingsNotifierProvider
    extends $NotifierProvider<SpeechSettingsNotifier, SpeechSettingsState> {
  /// Speech settings Notifier
  ///
  /// [keepAlive] so the locally-stored settings are kept in memory after the
  /// startup pre-warm instead of being re-read on every screen mount.
  SpeechSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechSettingsNotifierHash();

  @$internal
  @override
  SpeechSettingsNotifier create() => SpeechSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechSettingsState>(value),
    );
  }
}

String _$speechSettingsNotifierHash() =>
    r'957052e4505156226e0bda9792e5e18dab285657';

/// Speech settings Notifier
///
/// [keepAlive] so the locally-stored settings are kept in memory after the
/// startup pre-warm instead of being re-read on every screen mount.

abstract class _$SpeechSettingsNotifier extends $Notifier<SpeechSettingsState> {
  SpeechSettingsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SpeechSettingsState, SpeechSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SpeechSettingsState, SpeechSettingsState>,
              SpeechSettingsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Convenience provider for the current speech service type

@ProviderFor(currentSpeechServiceType)
final currentSpeechServiceTypeProvider = CurrentSpeechServiceTypeProvider._();

/// Convenience provider for the current speech service type

final class CurrentSpeechServiceTypeProvider
    extends
        $FunctionalProvider<
          SpeechServiceType,
          SpeechServiceType,
          SpeechServiceType
        >
    with $Provider<SpeechServiceType> {
  /// Convenience provider for the current speech service type
  CurrentSpeechServiceTypeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSpeechServiceTypeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSpeechServiceTypeHash();

  @$internal
  @override
  $ProviderElement<SpeechServiceType> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SpeechServiceType create(Ref ref) {
    return currentSpeechServiceType(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechServiceType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechServiceType>(value),
    );
  }
}

String _$currentSpeechServiceTypeHash() =>
    r'6cf3bd4865a875973a38d9b487233fb4f108f4c9';
