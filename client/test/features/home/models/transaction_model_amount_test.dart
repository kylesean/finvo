import 'package:decimal/decimal.dart';
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

/// Assert the parsed Decimal amount equals an expected decimal string.
void _expectAmount(Map<String, dynamic> overrides, String expected) {
  expect(_parse(overrides).amount, Decimal.parse(expected));
}

void main() {
  group('TransactionModel.fromApiJson amount parsing', () {
    test('numeric amounts pass through', () {
      _expectAmount({'amount': 12.34}, '12.34');
      _expectAmount({'amount': 0}, '0');
      _expectAmount({'amount': -3}, '-3');
    });

    test('plain string amounts parse', () {
      _expectAmount({'amount': '12.34'}, '12.34');
      _expectAmount({'amount': '-7.5'}, '-7.5');
    });

    test('US grouping: commas are thousands separators', () {
      _expectAmount({'amount': '1,234.56'}, '1234.56');
      _expectAmount({'amount': '1,234'}, '1234');
      _expectAmount({'amount': '1,234,567.89'}, '1234567.89');
    });

    test('EU grouping: dots are thousands separators, comma is decimal', () {
      _expectAmount({'amount': '1.234,56'}, '1234.56');
      _expectAmount({'amount': '1.234.567'}, '1234567');
    });

    test('comma-only decimals', () {
      _expectAmount({'amount': '12,5'}, '12.5');
      _expectAmount({'amount': '-5,50'}, '-5.5');
    });

    test('currency symbols and whitespace are stripped', () {
      _expectAmount({'amount': '¥1,234.56'}, '1234.56');
      _expectAmount({'amount': ' 12.5 € '}, '12.5');
    });

    test('single dot stays a decimal point (backward compatibility)', () {
      _expectAmount({'amount': '1.234'}, '1.234');
    });

    test('missing or empty amounts degrade to zero', () {
      _expectAmount(<String, dynamic>{}, '0');
      _expectAmount({'amount': null}, '0');
      _expectAmount({'amount': ''}, '0');
    });

    test('unparseable amounts degrade to zero instead of throwing', () {
      _expectAmount({'amount': 'abc'}, '0');
      _expectAmount({'amount': '12.34.56,78.9'}, '0');
    });

    test('unexpected amount types degrade to zero', () {
      _expectAmount({
        'amount': ['12'],
      }, '0');
    });
  });

  group('TransactionModel.fromApiJson source parsing', () {
    test('defaults to MANUAL when source is absent', () {
      expect(_parse({}).source, 'MANUAL');
    });

    test('parses the server source marker', () {
      expect(_parse({'source': 'AI'}).source, 'AI');
      expect(_parse({'source': 'SYSTEM'}).source, 'SYSTEM');
    });
  });
}
