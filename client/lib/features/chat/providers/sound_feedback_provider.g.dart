// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod-managed [SoundFeedbackService] provider.
///
/// [keepAlive] so the audio players persist after first access (initialized lazily
/// when speech recognition or chat input is accessed, and reused across recording sessions).
/// Initialization is fire-and-forget: a failure falls back to haptic feedback internally.

@ProviderFor(soundFeedback)
final soundFeedbackProvider = SoundFeedbackProvider._();

/// Riverpod-managed [SoundFeedbackService] provider.
///
/// [keepAlive] so the audio players persist after first access (initialized lazily
/// when speech recognition or chat input is accessed, and reused across recording sessions).
/// Initialization is fire-and-forget: a failure falls back to haptic feedback internally.

final class SoundFeedbackProvider
    extends
        $FunctionalProvider<
          SoundFeedbackService,
          SoundFeedbackService,
          SoundFeedbackService
        >
    with $Provider<SoundFeedbackService> {
  /// Riverpod-managed [SoundFeedbackService] provider.
  ///
  /// [keepAlive] so the audio players persist after first access (initialized lazily
  /// when speech recognition or chat input is accessed, and reused across recording sessions).
  /// Initialization is fire-and-forget: a failure falls back to haptic feedback internally.
  SoundFeedbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundFeedbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundFeedbackHash();

  @$internal
  @override
  $ProviderElement<SoundFeedbackService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SoundFeedbackService create(Ref ref) {
    return soundFeedback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundFeedbackService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundFeedbackService>(value),
    );
  }
}

String _$soundFeedbackHash() => r'40cb17ecfb81f7af88c1ea62cb77c29106438b9d';
