// ErrorTranslator 单元测试。
//
// 覆盖 H6 回归：翻译必须在"翻译时"按当前 locale 惰性解析——运行时切换语言后
// 不得继续返回启动语言的文案。

import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/constants/error_codes.dart';
import 'package:finvo/core/utils/error_translator.dart';
import 'package:finvo/i18n/strings.g.dart';

void main() {
  setUp(() async {
    await LocaleSettings.setLocale(AppLocale.zh);
  });

  test('known code resolves to the localized message', () {
    final message = ErrorTranslator.translate(
      ErrorCodes.authFailed,
      'fallback',
    );

    expect(message, t.errorMapping.generic.authFailed);
    expect(message, isNot('fallback'));
  });

  test('unknown code falls back to the default message', () {
    final message = ErrorTranslator.translate(999999, 'fallback-message');

    expect(message, 'fallback-message');
  });

  test('translations follow a runtime locale switch (H6 regression)', () async {
    final zhMessage = ErrorTranslator.translate(
      ErrorCodes.userNotMatchPassword,
      '',
    );

    await LocaleSettings.setLocale(AppLocale.en);
    final enMessage = ErrorTranslator.translate(
      ErrorCodes.userNotMatchPassword,
      '',
    );

    expect(zhMessage, isNotEmpty);
    expect(enMessage, isNotEmpty);
    expect(zhMessage, isNot(equals(enMessage)));
  });
}
