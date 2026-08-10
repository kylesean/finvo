import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/auth/utils/auth_validators.dart';
import 'package:finvo/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await LocaleSettings.setLocale(AppLocale.zh);
  });

  group('AuthValidators Tests', () {
    test('isPhone validates 11-digit mobile numbers', () {
      expect(AuthValidators.isPhone('13800138000'), isTrue);
      expect(AuthValidators.isPhone('19912345678'), isTrue);
      expect(AuthValidators.isPhone('12800138000'), isFalse); // Invalid segment
      expect(AuthValidators.isPhone('1380013800'), isFalse); // 10 digits
    });

    test('isEmail validates email pattern', () {
      expect(AuthValidators.isEmail('user@example.com'), isTrue);
      expect(AuthValidators.isEmail('user.name@domain.co.uk'), isTrue);
      expect(
        AuthValidators.isEmail('user@domain'),
        isFalse,
      ); // Missing top-level domain
      expect(AuthValidators.isEmail('user'), isFalse);
    });

    test('validateContact validates both phone and email', () {
      expect(AuthValidators.validateContact('13800138000'), isNull);
      expect(AuthValidators.validateContact('user@example.com'), isNull);
      expect(AuthValidators.validateContact(''), equals(t.auth.email.required));
      expect(
        AuthValidators.validateContact('invalid_contact'),
        equals(t.auth.email.invalid),
      );
    });
  });
}
