// BufferingBroadcastController: must never drop events emitted while no
// listener is attached — they are buffered and replayed in order (including
// errors) when the first listener subscribes.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/events/domain_events.dart';

void main() {
  group('BufferingBroadcastController<int>', () {
    test('emits directly while a listener is attached', () async {
      final controller = BufferingBroadcastController<int>();
      final seen = <int>[];
      final sub = controller.stream.listen(seen.add);

      controller.add(1);
      controller.add(2);
      await Future<void>.delayed(Duration.zero);

      expect(seen, [1, 2]);
      await sub.cancel();
      await controller.close();
    });

    test('buffers events emitted before the first listener and replays them '
        'in order', () async {
      final controller = BufferingBroadcastController<int>();
      controller.add(1);
      controller.add(2);
      controller.add(3);

      final seen = <int>[];
      final sub = controller.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      expect(seen, [1, 2, 3]);
      await sub.cancel();
      await controller.close();
    });

    test('replay does not duplicate events for a second listener', () async {
      final controller = BufferingBroadcastController<int>();
      controller.add(1);

      final first = <int>[];
      final sub1 = controller.stream.listen(first.add);
      await Future<void>.delayed(Duration.zero);
      expect(first, [1]);

      final second = <int>[];
      final sub2 = controller.stream.listen(second.add);
      await Future<void>.delayed(Duration.zero);
      expect(second, isEmpty);

      controller.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(first, [1, 2]);
      expect(second, [2]);

      await sub1.cancel();
      await sub2.cancel();
      await controller.close();
    });

    test('buffered errors are replayed as errors, preserving order', () async {
      final controller = BufferingBroadcastController<int>();
      controller.add(1);
      controller.addError(StateError('boom'));

      final seen = <int>[];
      final errors = <Object>[];
      final sub = controller.stream.listen(seen.add, onError: errors.add);
      await Future<void>.delayed(Duration.zero);

      expect(seen, [1]);
      expect(errors.single, isA<StateError>());
      await sub.cancel();
      await controller.close();
    });

    test('interleaved data/error replay stays ordered', () async {
      final controller = BufferingBroadcastController<int>();
      controller.add(1);
      controller.addError(Exception('a'));
      controller.add(2);
      controller.addError(Exception('b'));
      controller.add(3);

      final events = <Object>[];
      final sub = controller.stream.listen(
        events.add,
        onError: (Object e) => events.add(e),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(5));
      expect(events[0], 1);
      expect(events[1], isA<Exception>());
      expect(events[2], 2);
      expect(events[3], isA<Exception>());
      expect(events[4], 3);
      await sub.cancel();
      await controller.close();
    });

    test(
      'buffer is capped: the newest events survive, oldest are dropped',
      () async {
        final controller = BufferingBroadcastController<int>();
        // Push far more than the 200 cap.
        for (var i = 0; i < 250; i++) {
          controller.add(i);
        }

        final seen = <int>[];
        final sub = controller.stream.listen(seen.add);
        await Future<void>.delayed(Duration.zero);

        expect(seen, hasLength(200));
        // The newest 200 (indices 50..249) were kept.
        expect(seen.first, 50);
        expect(seen.last, 249);
        await sub.cancel();
        await controller.close();
      },
    );

    test('post-replay events flow through normally', () async {
      final controller = BufferingBroadcastController<int>();
      controller.add(0);
      final seen = <int>[];
      final sub = controller.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      controller.add(1);
      controller.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, [0, 1, 2]);
      await sub.cancel();
      await controller.close();
    });

    test('addStream respects the buffer invariant too', () async {
      final controller = BufferingBroadcastController<int>();
      final source = Stream<int>.fromIterable([1, 2, 3]);
      await controller.addStream(source);

      final seen = <int>[];
      final sub = controller.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, [1, 2, 3]);
      await sub.cancel();
      await controller.close();
    });
  });
}
