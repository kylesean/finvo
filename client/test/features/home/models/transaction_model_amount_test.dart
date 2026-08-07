import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/home/models/transaction_model.dart';

/// Amount parsing is exercised through the public [TransactionModel.fromApiJson]
/// boundary (the parser helpers are private by design).
TransactionModel _parse(Map<String, dynamic> overrides) {
  return TransactionModel.fromApiJson({
    'id': 'tx-1',
    'type': 'EXPENSE',
    // Provide a category name so the fallback never touches i18n globals.
    'categoryName': 'Food',
    ...overrides,
  });
}

void main() {
  group('TransactionModel.fromApiJson amount parsing', () {
    test('numeric amounts pass through', () {
      expect(_parse({'amount': 12.34}).amount, closeTo(12.34, 1e-9));
      expect(_parse({'amount': 0}).amount, 0.0);
      expect(_parse({'amount': -3}).amount, -3.0);
    });

    test('plain string amounts parse', () {
      expect(_parse({'amount': '12.34'}).amount, closeTo(12.34, 1e-9));
      expect(_parse({'amount': '-7.5'}).amount, closeTo(-7.5, 1e-9));
    });

    test('US grouping: commas are thousands separators', () {
      expect(_parse({'amount': '1,234.56'}).amount, closeTo(1234.56, 1e-9));
      expect(_parse({'amount': '1,234'}).amount, closeTo(1234, 1e-9));
      expect(
        _parse({'amount': '1,234,567.89'}).amount,
        closeTo(1234567.89, 1e-6),
      );
    });

    test('EU grouping: dots are thousands separators, comma is decimal', () {
      expect(_parse({'amount': '1.234,56'}).amount, closeTo(1234.56, 1e-9));
      expect(_parse({'amount': '1.234.567'}).amount, closeTo(1234567, 1e-6));
    });

    test('comma-only decimals', () {
      expect(_parse({'amount': '12,5'}).amount, closeTo(12.5, 1e-9));
      expect(_parse({'amount': '-5,50'}).amount, closeTo(-5.5, 1e-9));
    });

    test('currency symbols and whitespace are stripped', () {
      expect(_parse({'amount': '¥1,234.56'}).amount, closeTo(1234.56, 1e-9));
      expect(_parse({'amount': ' 12.5 € '}).amount, closeTo(12.5, 1e-9));
    });

    test('single dot stays a decimal point (backward compatibility)', () {
      expect(_parse({'amount': '1.234'}).amount, closeTo(1.234, 1e-9));
    });

    test('missing or empty amounts degrade to zero', () {
      expect(_parse(<String, dynamic>{}).amount, 0.0);
      expect(_parse({'amount': null}).amount, 0.0);
      expect(_parse({'amount': ''}).amount, 0.0);
    });

    test('unparseable amounts degrade to zero instead of throwing', () {
      expect(_parse({'amount': 'abc'}).amount, 0.0);
      expect(_parse({'amount': '12.34.56,78.9'}).amount, 0.0);
    });

    test('unexpected amount types degrade to zero', () {
      expect(
        _parse({
          'amount': ['12'],
        }).amount,
        0.0,
      );
    });
  });
}
