import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/chat/services/sse_event_parsing.dart';

void main() {
  group('SseEventAccumulator', () {
    test('dispatches a single-line event on blank-line boundary', () {
      final acc = SseEventAccumulator();
      expect(acc.addLine('data: {"type":"text"}'), isNull);
      expect(acc.addLine(''), '{"type":"text"}');
      expect(acc.flush(), isNull);
    });

    test('joins multi-line data fields with newline', () {
      final acc = SseEventAccumulator();
      acc.addLine('data: {"type":"text",');
      acc.addLine('data: "chunk":"hi"}');
      expect(acc.addLine(''), '{"type":"text",\n"chunk":"hi"}');
    });

    test('accepts the space-less `data:value` variant', () {
      final acc = SseEventAccumulator();
      expect(acc.addLine('data:{"type":"text","v":1}'), isNull);
      expect(acc.addLine(''), '{"type":"text","v":1}');
    });

    test('preserves payload whitespace verbatim (no trim)', () {
      final acc = SseEventAccumulator();
      expect(acc.addLine('data:  {"type":"text","v":1}  '), isNull);
      expect(acc.addLine(''), ' {"type":"text","v":1}  ');
    });

    test('bare `data:` line contributes an empty segment', () {
      final acc = SseEventAccumulator();
      acc.addLine('data: first');
      acc.addLine('data:');
      expect(acc.addLine(''), 'first\n');
    });

    test('ignores non-data SSE fields and comments', () {
      final acc = SseEventAccumulator();
      expect(acc.addLine('event: message'), isNull);
      expect(acc.addLine('id: 42'), isNull);
      expect(acc.addLine('retry: 1000'), isNull);
      expect(acc.addLine(': comment'), isNull);
      acc.addLine('data: payload');
      expect(acc.addLine(''), 'payload');
    });

    test('blank lines without pending data dispatch nothing', () {
      final acc = SseEventAccumulator();
      expect(acc.addLine(''), isNull);
      expect(acc.addLine(''), isNull);
    });

    test('flush returns trailing event without final blank line', () {
      final acc = SseEventAccumulator();
      acc.addLine('data: trailing');
      expect(acc.flush(), 'trailing');
      // Flush is consuming: a second flush yields nothing.
      expect(acc.flush(), isNull);
    });

    test('dispatches consecutive events independently', () {
      final acc = SseEventAccumulator();
      acc.addLine('data: first');
      expect(acc.addLine(''), 'first');
      acc.addLine('data: second');
      expect(acc.addLine(''), 'second');
    });
  });

  group('receiptBucketEvents', () {
    test('emits one event per non-zero bucket with its own currency', () {
      final events = receiptBucketEvents({
        'by_currency': {
          'USD': {'expense': '100.00', 'income': '0.00'},
          'CNY': {'expense': '0.00', 'income': '720.00'},
        },
        'mixed_currencies': true,
      });

      expect(events, [
        (amount: 100.0, type: 'expense', currency: 'USD'),
        (amount: 720.0, type: 'income', currency: 'CNY'),
      ]);
    });

    test('zero buckets emit nothing', () {
      expect(
        receiptBucketEvents({
          'by_currency': {
            'CNY': {'expense': '0.00', 'income': '0.00'},
          },
        }),
        isEmpty,
      );
    });

    test('missing or malformed summaries emit nothing', () {
      expect(receiptBucketEvents(null), isEmpty);
      expect(receiptBucketEvents({}), isEmpty);
      expect(receiptBucketEvents({'by_currency': 'garbage'}), isEmpty);
      expect(
        receiptBucketEvents({
          'by_currency': {
            'CNY': 'garbage',
            'USD': {'expense': 'n/a', 'income': null},
          },
        }),
        isEmpty,
      );
    });

    test('currency codes are uppercased', () {
      final events = receiptBucketEvents({
        'by_currency': {
          'usd': {'expense': '10.00', 'income': '0.00'},
        },
      });

      expect(events.single.currency, 'USD');
    });
  });
}
