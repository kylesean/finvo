import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/chat/services/genui_error_translator.dart';

void main() {
  group('GenUiErrorTranslator', () {
    test('classifies busy / empty stream errors correctly', () {
      expect(
        GenUiErrorTranslator.classify('No generations in response'),
        equals(GenUiErrorType.busy),
      );
      expect(
        GenUiErrorTranslator.classify('empty stream received'),
        equals(GenUiErrorType.busy),
      );
    });

    test('classifies timeout errors correctly', () {
      expect(
        GenUiErrorTranslator.classify('Request timeout after 30s'),
        equals(GenUiErrorType.timeout),
      );
      expect(
        GenUiErrorTranslator.classify('Connection Timeout'),
        equals(GenUiErrorType.timeout),
      );
    });

    test('classifies network errors correctly', () {
      expect(
        GenUiErrorTranslator.classify('network connection lost'),
        equals(GenUiErrorType.network),
      );
      expect(
        GenUiErrorTranslator.classify('connection refused by server'),
        equals(GenUiErrorType.network),
      );
    });

    test('classifies session expired / auth errors correctly', () {
      expect(
        GenUiErrorTranslator.classify('Authentication failed'),
        equals(GenUiErrorType.sessionExpired),
      );
      expect(
        GenUiErrorTranslator.classify('Invalid JWT token provided'),
        equals(GenUiErrorType.sessionExpired),
      );
    });

    test('falls back to generic for unknown errors', () {
      expect(
        GenUiErrorTranslator.classify('Something weird happened'),
        equals(GenUiErrorType.generic),
      );
    });
  });
}
