import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_theme_palette.dart';
import 'package:finvo/app/theme/forui_theme_config.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/profile/pages/amount_settings_page.dart';
import 'package:finvo/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AmountSettingsPage Widget Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      await LocaleSettings.setLocale(AppLocale.zh);
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: FTheme(
            data: ForuiThemeConfig.resolve(
              palette: AppThemePalette.zinc,
              brightness: Brightness.light,
            ),
            child: const AmountSettingsPage(),
          ),
        ),
      );
    }

    testWidgets(
      'AmountSettingsPage renders preview card and options correctly',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify title & preview card header are present
        expect(find.text('实时效果预览'), findsOneWidget);
        expect(find.text('收入示例'), findsOneWidget);
        expect(find.text('支出示例'), findsOneWidget);
        expect(find.text('转账示例'), findsOneWidget);

        // Verify options are rendered
        expect(find.text('国际标准'), findsOneWidget);
        expect(find.text('中国市场'), findsOneWidget);
      },
    );

    testWidgets('Tapping on a theme option changes the active theme state', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on international theme tile
      final internationalOption = find.text('国际标准');
      expect(internationalOption, findsOneWidget);

      await tester.tap(internationalOption);
      await tester.pumpAndSettle();

      // Check persisted preference
      expect(prefs.getString('amount_theme_id'), equals('international'));
    });
  });
}
