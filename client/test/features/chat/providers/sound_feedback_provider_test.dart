import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/chat/providers/sound_feedback_provider.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('soundFeedbackProvider', () {
    test('provides a SoundFeedbackService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(soundFeedbackProvider);
      expect(service, isA<SoundFeedbackService>());
    });

    test('is keepAlive and returns the same instance across reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final firstRead = container.read(soundFeedbackProvider);
      final secondRead = container.read(soundFeedbackProvider);

      expect(identical(firstRead, secondRead), isTrue);
    });
  });
}
