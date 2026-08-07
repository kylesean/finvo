import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/shared/utils/tolerant_json.dart';

void main() {
  group('TolerantJson Utilities', () {
    test('tryDouble converts num, string, and null safely', () {
      expect(tryDouble(12.5), 12.5);
      expect(tryDouble(10), 10.0);
      expect(tryDouble(' 99.9 '), 99.9);
      expect(tryDouble('invalid', -1.0), -1.0);
      expect(tryDouble(null, 0.0), 0.0);

      expect(tryNullableDouble('3.14'), 3.14);
      expect(tryNullableDouble('bad'), isNull);
      expect(tryNullableDouble(null), isNull);
    });

    test('tryInt converts num, string, and null safely', () {
      expect(tryInt(42), 42);
      expect(tryInt(10.8), 10);
      expect(tryInt('100'), 100);
      expect(tryInt('bad', 7), 7);
      expect(tryInt(null, 0), 0);

      expect(tryNullableInt('50'), 50);
      expect(tryNullableInt('bad'), isNull);
    });

    test('tryDecimal converts num and string preserving precision', () {
      expect(tryDecimal(100), Decimal.parse('100'));
      expect(tryDecimal('123.45'), Decimal.parse('123.45'));
      expect(tryDecimal(null), Decimal.zero);
      expect(tryDecimal('invalid'), Decimal.zero);
    });

    test('tryDate parses String and timestamp safely', () {
      final now = DateTime.now();
      expect(tryDate(now), now);

      const dateStr = '2026-08-08T07:00:00.000Z';
      final parsed = tryDate(dateStr);
      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);

      expect(tryDate('invalid-date'), isNull);
      expect(tryDate(null), isNull);
    });

    test('tryString converts any object to string safely', () {
      expect(tryString('hello'), 'hello');
      expect(tryString(123), '123');
      expect(tryString(null, 'default'), 'default');
    });
  });
}
