import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/services/reconnect_policy.dart';

/// Shared reconnect-behavior cases, run against both production budgets
/// (notification 5×30s, speech 3×8s) so the two services stay identical.
void main() {
  group('ReconnectPolicy', () {
    test('delays follow 1s/2s/4s then cap at maxDelay', () {
      fakeAsync((async) {
        final fires = <int>[];
        final policy = ReconnectPolicy(
          maxAttempts: 5,
          maxDelay: const Duration(seconds: 30),
          jitterFraction: 0,
        );
        var now = 0;
        for (var i = 0; i < 5; i++) {
          expect(policy.schedule(() => fires.add(now)), isTrue);
          async.elapse(const Duration(seconds: 31));
          now += 31;
        }
        expect(fires, hasLength(5));
        expect(policy.exhausted, isTrue);
        expect(policy.schedule(() {}), isFalse);
      });
    });

    test('exact backoff sequence without jitter', () {
      fakeAsync((async) {
        final elapsedAtFire = <int>[];
        var elapsed = 0;
        final policy = ReconnectPolicy(
          maxAttempts: 5,
          maxDelay: const Duration(seconds: 30),
          jitterFraction: 0,
        );
        for (final expected in [1, 2, 4, 8, 16]) {
          policy.schedule(() => elapsedAtFire.add(elapsed));
          async.elapse(Duration(seconds: expected));
          elapsed += expected;
        }
        expect(elapsedAtFire, [0, 1, 3, 7, 15]);
      });
    });

    test('speech budget caps at 8s and stops after 3 attempts', () {
      fakeAsync((async) {
        var fires = 0;
        final policy = ReconnectPolicy(
          maxAttempts: 3,
          maxDelay: const Duration(seconds: 8),
          jitterFraction: 0,
        );
        for (var i = 0; i < 3; i++) {
          expect(policy.schedule(() => fires++), isTrue);
          async.elapse(const Duration(seconds: 9));
        }
        expect(fires, 3);
        expect(policy.schedule(() => fires++), isFalse);
        async.elapse(const Duration(seconds: 30));
        expect(fires, 3);
      });
    });

    test('success resets the budget', () {
      final policy = ReconnectPolicy(maxAttempts: 2, jitterFraction: 0);
      expect(policy.schedule(() {}), isTrue);
      expect(policy.schedule(() {}), isTrue);
      expect(policy.exhausted, isTrue);
      policy.markSucceeded();
      expect(policy.exhausted, isFalse);
      expect(policy.attempts, 0);
    });

    test('dispose cancels the pending retry', () {
      fakeAsync((async) {
        var fires = 0;
        final policy = ReconnectPolicy(maxAttempts: 5, jitterFraction: 0);
        expect(policy.schedule(() => fires++), isTrue);
        policy.dispose();
        async.elapse(const Duration(seconds: 60));
        expect(fires, 0);
        expect(policy.schedule(() => fires++), isFalse);
      });
    });

    test('jitter stays within fraction bounds', () {
      fakeAsync((async) {
        final policy = ReconnectPolicy(
          maxAttempts: 5,
          maxDelay: const Duration(seconds: 30),
          jitterFraction: 0.25,
          random: Random(42),
        );
        var fired = false;
        expect(policy.schedule(() => fired = true), isTrue);
        // First delay is 1s ± 250ms: must not fire before 750ms...
        async.elapse(const Duration(milliseconds: 749));
        expect(fired, isFalse);
        // ...and must fire by 1250ms.
        async.elapse(const Duration(milliseconds: 501));
        expect(fired, isTrue);
      });
    });
  });
}
