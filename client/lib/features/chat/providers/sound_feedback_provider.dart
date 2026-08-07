import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';

part 'sound_feedback_provider.g.dart';

/// Riverpod-managed [SoundFeedbackService] provider.
///
/// [keepAlive] so the audio players persist for the app's lifetime (they are
/// pre-warmed at startup and reused across recording sessions). Initialization
/// is fire-and-forget: a failure falls back to haptic feedback internally, so
/// callers never need to guard against a failed init.
@Riverpod(keepAlive: true)
SoundFeedbackService soundFeedback(Ref ref) {
  final service = SoundFeedbackService();
  unawaited(service.initialize());
  ref.onDispose(() => service.dispose());
  return service;
}
