import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/finance/providers/account_view_currency_provider.dart';
import 'package:finvo/features/profile/models/financial_settings.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';

void main() {
  group('AccountViewCurrencyState', () {
    test('global state is default', () {
      const state = AccountViewCurrencyState.global();
      expect(state, isA<AccountViewCurrencyGlobal>());
    });

    test('temporary state holds currency', () {
      const state = AccountViewCurrencyState.temporary('USD');
      expect(state, isA<AccountViewCurrencyTemporary>());
      expect(
        state.map(global: (_) => null, temporary: (t) => t.currency),
        'USD',
      );
    });

    test('map resolves correct branch', () {
      const globalState = AccountViewCurrencyState.global();
      const tempState = AccountViewCurrencyState.temporary('EUR');

      final globalResult = globalState.map(
        global: (_) => 'is_global',
        temporary: (t) => 'is_temp:${t.currency}',
      );
      final tempResult = tempState.map(
        global: (_) => 'is_global',
        temporary: (t) => 'is_temp:${t.currency}',
      );

      expect(globalResult, 'is_global');
      expect(tempResult, 'is_temp:EUR');
    });
  });

  group('AccountViewCurrency notifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          financialSettingsProvider.overrideWith(
            () => _MockFinancialSettingsNotifier(
              const FinancialSettingsState(primaryCurrency: 'CNY'),
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is global', () {
      final state = container.read(accountViewCurrencyProvider);
      expect(state, isA<AccountViewCurrencyGlobal>());
    });

    test('setTemporary switches to temporary state', () {
      container.read(accountViewCurrencyProvider.notifier).setTemporary('USD');

      final state = container.read(accountViewCurrencyProvider);
      expect(state, isA<AccountViewCurrencyTemporary>());
      expect(
        state.map(global: (_) => null, temporary: (t) => t.currency),
        'USD',
      );
    });

    test('resetToGlobal returns to global state', () {
      final notifier = container.read(accountViewCurrencyProvider.notifier);
      notifier.setTemporary('GBP');
      notifier.resetToGlobal();

      final state = container.read(accountViewCurrencyProvider);
      expect(state, isA<AccountViewCurrencyGlobal>());
    });

    test('multiple setTemporary calls update currency', () {
      final notifier = container.read(accountViewCurrencyProvider.notifier);
      notifier.setTemporary('USD');
      notifier.setTemporary('EUR');
      notifier.setTemporary('JPY');

      final state = container.read(accountViewCurrencyProvider);
      expect(
        state.map(global: (_) => null, temporary: (t) => t.currency),
        'JPY',
      );
    });
  });

  group('effectiveViewCurrency provider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('returns global currency when in global state', () {
      container = ProviderContainer(
        overrides: [
          financialSettingsProvider.overrideWith(
            () => _MockFinancialSettingsNotifier(
              const FinancialSettingsState(primaryCurrency: 'CNY'),
            ),
          ),
        ],
      );

      final currency = container.read(effectiveViewCurrencyProvider);
      expect(currency, 'CNY');
    });

    test('returns temporary currency when overridden', () {
      container = ProviderContainer(
        overrides: [
          financialSettingsProvider.overrideWith(
            () => _MockFinancialSettingsNotifier(
              const FinancialSettingsState(primaryCurrency: 'CNY'),
            ),
          ),
        ],
      );

      container.read(accountViewCurrencyProvider.notifier).setTemporary('USD');

      final currency = container.read(effectiveViewCurrencyProvider);
      expect(currency, 'USD');
    });

    test('reverts to global after reset', () {
      container = ProviderContainer(
        overrides: [
          financialSettingsProvider.overrideWith(
            () => _MockFinancialSettingsNotifier(
              const FinancialSettingsState(primaryCurrency: 'EUR'),
            ),
          ),
        ],
      );

      final notifier = container.read(accountViewCurrencyProvider.notifier);
      notifier.setTemporary('JPY');
      expect(container.read(effectiveViewCurrencyProvider), 'JPY');

      notifier.resetToGlobal();
      expect(container.read(effectiveViewCurrencyProvider), 'EUR');
    });
  });
}

/// Mock notifier that returns a fixed FinancialSettingsState
class _MockFinancialSettingsNotifier extends FinancialSettingsNotifier {
  final FinancialSettingsState _state;

  _MockFinancialSettingsNotifier(this._state);

  @override
  FinancialSettingsState build() => _state;
}
