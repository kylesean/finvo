import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/shared/theme/amount_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AmountThemeNotifier Tests', () {
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Initial theme state should default to chinaMarket when no preference is saved',
      () {
        final state = container.read(amountThemeProvider);
        expect(state.themeId, equals('chinaMarket'));
        expect(state.theme, equals(AmountTheme.chinaMarket));
      },
    );

    test(
      'setTheme should update theme state and persist to SharedPreferences',
      () async {
        final notifier = container.read(amountThemeProvider.notifier);
        await notifier.setTheme('international');

        final updatedState = container.read(amountThemeProvider);
        expect(updatedState.themeId, equals('international'));
        expect(updatedState.theme, equals(AmountTheme.international));
        expect(prefs.getString('amount_theme_id'), equals('international'));
      },
    );

    test('setTheme to minimalist should set minimalist theme', () async {
      final notifier = container.read(amountThemeProvider.notifier);
      await notifier.setTheme('minimalist');

      final state = container.read(amountThemeProvider);
      expect(state.themeId, equals('minimalist'));
      expect(state.theme, equals(AmountTheme.minimalist));
    });

    test(
      'resetToDefault should restore chinaMarket theme and clear storage',
      () async {
        final notifier = container.read(amountThemeProvider.notifier);
        await notifier.setTheme('colorBlindFriendly');
        expect(
          container.read(amountThemeProvider).themeId,
          equals('colorBlindFriendly'),
        );

        await notifier.resetToDefault();
        final resetState = container.read(amountThemeProvider);
        expect(resetState.themeId, equals('chinaMarket'));
        expect(prefs.containsKey('amount_theme_id'), isFalse);
      },
    );
  });
}
