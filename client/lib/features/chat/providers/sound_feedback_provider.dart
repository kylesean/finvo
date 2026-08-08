import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';

part 'sound_feedback_provider.g.dart';

/// Riverpod-managed [SoundFeedbackService] provider.
///
/// [keepAlive] so the audio players persist after first access (initialized lazily
/// when speech recognition or chat input is accessed, and reused across recording sessions).
/// Initialization is fire-and-forget: a failure falls back to haptic feedback internally.
@Riverpod(keepAlive: true)
SoundFeedbackService soundFeedback(Ref ref) {
  final service = SoundFeedbackService();
  unawaited(service.initialize());
  ref.onDispose(() => service.dispose());
  return service;
}
