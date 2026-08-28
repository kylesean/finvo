import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/shared/providers/generation_guard.dart';

void main() {
  group('GenerationGuard', () {
    test('bump returns a strictly increasing sequence', () {
      final guard = GenerationGuard();
      final first = guard.bump();
      final second = guard.bump();
      final third = guard.bump();

      expect(second, greaterThan(first));
      expect(third, greaterThan(second));
    });

    test('isCurrent is true only for the latest generation', () {
      final guard = GenerationGuard();
      final first = guard.bump();

      expect(guard.isCurrent(first), isTrue);

      final second = guard.bump();
      expect(guard.isCurrent(first), isFalse);
      expect(guard.isCurrent(second), isTrue);
    });

    test('current exposes the generation without bumping', () {
      final guard = GenerationGuard();
      final captured = guard.current;

      expect(guard.isCurrent(captured), isTrue);
      // Capturing must not invalidate anything.
      expect(guard.current, captured);

      guard.bump();
      expect(guard.isCurrent(captured), isFalse);
    });
  });
}
