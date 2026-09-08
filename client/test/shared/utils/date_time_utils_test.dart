import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';

void main() {
  group('tryParseDateTime', () {
    test('converts UTC timestamps (+00:00) to local', () {
      final local = tryParseDateTime('2026-01-01T12:00:00+00:00');
      expect(local, isNotNull);
      expect(local!.isUtc, isFalse);
      expect(local, DateTime.parse('2026-01-01T12:00:00+00:00').toLocal());
    });

    test('converts UTC timestamps (Z suffix) to local', () {
      final local = tryParseDateTime('2026-01-01T12:00:00Z');
      expect(local, isNotNull);
      expect(local!.isUtc, isFalse);
      expect(local, DateTime.parse('2026-01-01T12:00:00Z').toLocal());
    });

    test('strips a redundant trailing Z after an offset', () {
      // Non-standard form the server has emitted historically:
      // both offset and Z present, which DateTime.parse rejects.
      final local = tryParseDateTime('2025-12-27T07:07:20.586784+00:00Z');
      expect(local, isNotNull);
      expect(
        local,
        DateTime.parse('2025-12-27T07:07:20.586784+00:00').toLocal(),
      );
    });

    test('keeps naive (no offset) timestamps local', () {
      final local = tryParseDateTime('2026-01-01T12:00:00');
      expect(local, isNotNull);
      expect(local!.isUtc, isFalse);
      expect(local, DateTime.parse('2026-01-01T12:00:00'));
    });

    test('returns null for missing / malformed input', () {
      expect(tryParseDateTime(null), isNull);
      expect(tryParseDateTime(''), isNull);
      expect(tryParseDateTime('not a date'), isNull);
      expect(tryParseDateTime(42), isNull);
    });
  });

  group('LocalDateTimeConverter', () {
    const converter = LocalDateTimeConverter();

    test('fromJson parses UTC input into a local DateTime', () {
      final value = converter.fromJson('2026-09-08T23:30:00+00:00');
      expect(value.isUtc, isFalse);
      // Same instant, local wall clock.
      expect(
        value.millisecondsSinceEpoch,
        DateTime.parse('2026-09-08T23:30:00+00:00').millisecondsSinceEpoch,
      );
    });

    test('fromJson throws FormatException on garbage (as before)', () {
      expect(() => converter.fromJson('garbage'), throwsFormatException);
    });

    test('toJson keeps the local offset (no UTC day rollback)', () {
      // A local midnight (e.g. a picked budget start date) must not roll
      // back a day through a toUtc() conversion. Serialization is exactly
      // the pre-converter behavior: toIso8601String() of the stored value.
      final value = DateTime(2026, 9, 8);
      expect(converter.toJson(value), value.toIso8601String());
    });

    test('round-trips a UTC instant losslessly', () {
      final original = DateTime.parse('2026-09-08T23:30:00+00:00').toLocal();
      final restored = converter.fromJson(converter.toJson(original));
      expect(restored.millisecondsSinceEpoch, original.millisecondsSinceEpoch);
    });
  });
}
