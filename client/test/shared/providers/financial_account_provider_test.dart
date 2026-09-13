import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/shared/models/exchange_rate.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/shared/models/financial_settings.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';
import 'package:finvo/shared/providers/financial_account_provider.dart';
import 'package:finvo/shared/providers/financial_settings_provider.dart';
import 'package:finvo/shared/services/financial_account_service.dart';

void main() {
  group('FinancialAccountState', () {
    test('single-currency net worth calculates assets - liabilities', () {
      final accounts = [
        FinancialAccount(
          id: '1',
          name: 'Checking',
          nature: FinancialNature.asset,
          type: FinancialAccountType.deposit,
          initialBalance: Decimal.fromInt(1000),
          currencyCode: 'CNY',
          includeInNetWorth: true,
        ),
        FinancialAccount(
          id: '2',
          name: 'Credit Card',
          nature: FinancialNature.liability,
          type: FinancialAccountType.creditCard,
          initialBalance: Decimal.fromInt(300),
          currencyCode: 'CNY',
          includeInNetWorth: true,
        ),
      ];

      final state = FinancialAccountState(accounts: accounts);
      expect(state.calculatedNetWorth, Decimal.fromInt(700));
      expect(state.effectiveTotalBalance, Decimal.fromInt(700));
    });

    test(
      'calculateNetWorth with targetCurrency converts foreign currency',
      () async {
        final accounts = [
          FinancialAccount(
            id: '1',
            name: 'CNY Cash',
            nature: FinancialNature.asset,
            type: FinancialAccountType.cash,
            initialBalance: Decimal.fromInt(1000),
            currencyCode: 'CNY',
            includeInNetWorth: true,
          ),
          FinancialAccount(
            id: '2',
            name: 'USD Wallet',
            nature: FinancialNature.asset,
            type: FinancialAccountType.cash,
            initialBalance: Decimal.fromInt(100),
            currencyCode: 'USD',
            includeInNetWorth: true,
          ),
        ];

        final state = FinancialAccountState(accounts: accounts);

        final testContainer = ProviderContainer(
          overrides: [
            exchangeRateProvider.overrideWith(
              () => _TestExchangeRate(
                const ExchangeRateResponse(
                  baseCode: 'USD',
                  conversionRates: {'USD': 1.0, 'CNY': 7.2},
                ),
              ),
            ),
          ],
        );
        addTearDown(testContainer.dispose);

        await testContainer.read(exchangeRateProvider.future);
        final exchangeRate = testContainer.read(exchangeRateProvider.notifier);

        final convertedNetWorth = state.calculateNetWorth(
          exchangeRateNotifier: exchangeRate,
          targetCurrency: 'CNY',
        );

        // 1000 CNY + 100 USD * 7.2 = 1720 CNY (NOT 1100)
        expect(convertedNetWorth, Decimal.fromInt(1720));
      },
    );

    test('skips foreign account when exchange rate is unavailable', () async {
      final accounts = [
        FinancialAccount(
          id: '1',
          name: 'CNY Cash',
          nature: FinancialNature.asset,
          type: FinancialAccountType.cash,
          initialBalance: Decimal.fromInt(1000),
          currencyCode: 'CNY',
          includeInNetWorth: true,
        ),
        FinancialAccount(
          id: '2',
          name: 'Unknown Currency',
          nature: FinancialNature.asset,
          type: FinancialAccountType.cash,
          initialBalance: Decimal.fromInt(500),
          currencyCode: 'XYZ',
          includeInNetWorth: true,
        ),
      ];

      final state = FinancialAccountState(accounts: accounts);

      final testContainer = ProviderContainer(
        overrides: [
          exchangeRateProvider.overrideWith(
            () => _TestExchangeRate(
              const ExchangeRateResponse(
                baseCode: 'CNY',
                conversionRates: {'CNY': 1.0},
              ),
            ),
          ),
        ],
      );
      addTearDown(testContainer.dispose);

      await testContainer.read(exchangeRateProvider.future);
      final exchangeRate = testContainer.read(exchangeRateProvider.notifier);

      final netWorth = state.calculateNetWorth(
        exchangeRateNotifier: exchangeRate,
        targetCurrency: 'CNY',
      );

      // XYZ skipped to prevent mixing 500 XYZ as 500 CNY
      expect(netWorth, Decimal.fromInt(1000));
    });
  });

  group('FinancialAccountNotifier multi-currency operations', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          financialSettingsProvider.overrideWith(
            () => _MockFinancialSettingsNotifier(
              const FinancialSettingsState(primaryCurrency: 'CNY'),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _TestExchangeRate(
              const ExchangeRateResponse(
                baseCode: 'USD',
                conversionRates: {'USD': 1.0, 'CNY': 7.2},
              ),
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'addFinancialAccount converts foreign currency to primary currency',
      () async {
        // Settle exchange rate future
        await container.read(exchangeRateProvider.future);

        final notifier = container.read(financialAccountProvider.notifier);

        // Add CNY account: 1000
        notifier.addFinancialAccount(
          FinancialAccount(
            id: '1',
            name: 'CNY Account',
            nature: FinancialNature.asset,
            type: FinancialAccountType.deposit,
            initialBalance: Decimal.fromInt(1000),
            currencyCode: 'CNY',
            includeInNetWorth: true,
          ),
        );

        expect(
          container.read(financialAccountProvider).totalBalance,
          Decimal.fromInt(1000),
        );

        // Add USD account: 100 USD (at 7.2 = 720 CNY)
        notifier.addFinancialAccount(
          FinancialAccount(
            id: '2',
            name: 'USD Account',
            nature: FinancialNature.asset,
            type: FinancialAccountType.deposit,
            initialBalance: Decimal.fromInt(100),
            currencyCode: 'USD',
            includeInNetWorth: true,
          ),
        );

        // Total balance must be 1000 + 720 = 1720 CNY, NOT 1100
        expect(
          container.read(financialAccountProvider).totalBalance,
          Decimal.fromInt(1720),
        );
      },
    );

    test(
      'addFinancialAccount liability in foreign currency subtracts correctly',
      () async {
        await container.read(exchangeRateProvider.future);

        final notifier = container.read(financialAccountProvider.notifier);

        notifier.addFinancialAccount(
          FinancialAccount(
            id: '1',
            name: 'CNY Savings',
            nature: FinancialNature.asset,
            type: FinancialAccountType.deposit,
            initialBalance: Decimal.fromInt(2000),
            currencyCode: 'CNY',
            includeInNetWorth: true,
          ),
        );

        // Add USD credit card: 50 USD liability (50 * 7.2 = 360 CNY)
        notifier.addFinancialAccount(
          FinancialAccount(
            id: '2',
            name: 'USD Card',
            nature: FinancialNature.liability,
            type: FinancialAccountType.creditCard,
            initialBalance: Decimal.fromInt(50),
            currencyCode: 'USD',
            includeInNetWorth: true,
          ),
        );

        // 2000 - 360 = 1640 CNY, NOT 1950
        expect(
          container.read(financialAccountProvider).totalBalance,
          Decimal.fromInt(1640),
        );
      },
    );
  });

  group('FinancialAccountNotifier lifecycle and loading state', () {
    late ProviderContainer container;
    late _FakeFinancialAccountService fakeService;

    setUp(() {
      fakeService = _FakeFinancialAccountService();
      container = ProviderContainer(
        overrides: [
          financialAccountServiceProvider.overrideWithValue(fakeService),
          financialSettingsProvider.overrideWith(
            () => _MockFinancialSettingsNotifier(
              const FinancialSettingsState(primaryCurrency: 'CNY'),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _TestExchangeRate(
              const ExchangeRateResponse(
                baseCode: 'CNY',
                conversionRates: {'CNY': 1.0},
              ),
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'initial state is idle (isLoading: false, accounts: empty, lastUpdatedAt: null)',
      () {
        final state = container.read(financialAccountProvider);
        expect(state.isLoading, isFalse);
        expect(state.accounts, isEmpty);
        expect(state.lastUpdatedAt, isNull);
        expect(state.error, isNull);
      },
    );

    test(
      'loadFinancialAccounts sets accounts and lastUpdatedAt on success',
      () async {
        fakeService.accountsResponse = FinancialAccountResponse(
          accounts: [
            FinancialAccount(
              id: '1',
              name: 'Checking',
              nature: FinancialNature.asset,
              type: FinancialAccountType.deposit,
              initialBalance: Decimal.fromInt(500),
              currencyCode: 'CNY',
              includeInNetWorth: true,
            ),
          ],
          totalBalance: Decimal.fromInt(500),
        );

        final notifier = container.read(financialAccountProvider.notifier);
        final future = notifier.loadFinancialAccounts();
        expect(container.read(financialAccountProvider).isLoading, isTrue);

        await future;

        final state = container.read(financialAccountProvider);
        expect(state.isLoading, isFalse);
        expect(state.accounts.length, 1);
        expect(state.lastUpdatedAt, isNotNull);
        expect(state.error, isNull);
      },
    );

    test(
      'loadFinancialAccounts sets error on failure and resets isLoading',
      () async {
        fakeService.shouldThrow = true;
        final notifier = container.read(financialAccountProvider.notifier);

        await notifier.loadFinancialAccounts();

        final state = container.read(financialAccountProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNotNull);
        expect(state.accounts, isEmpty);
      },
    );

    test('ref.invalidate resets state to idle (not isLoading)', () async {
      final notifier = container.read(financialAccountProvider.notifier);
      fakeService.accountsResponse = FinancialAccountResponse(
        accounts: [
          FinancialAccount(
            id: '1',
            name: 'Checking',
            nature: FinancialNature.asset,
            type: FinancialAccountType.deposit,
            initialBalance: Decimal.fromInt(500),
            currencyCode: 'CNY',
            includeInNetWorth: true,
          ),
        ],
        totalBalance: Decimal.fromInt(500),
      );
      await notifier.loadFinancialAccounts();
      expect(container.read(financialAccountProvider).accounts.length, 1);

      // Invalidate provider
      container.invalidate(financialAccountProvider);

      final state = container.read(financialAccountProvider);
      expect(state.isLoading, isFalse);
      expect(state.accounts, isEmpty);
      expect(state.lastUpdatedAt, isNull);
      expect(state.error, isNull);
    });
  });
}

class _FakeFinancialAccountService implements FinancialAccountService {
  FinancialAccountResponse accountsResponse = FinancialAccountResponse(
    totalBalance: Decimal.zero,
  );
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<FinancialAccountResponse> getFinancialAccounts() async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return accountsResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestExchangeRate extends ExchangeRate {
  final ExchangeRateResponse _response;

  _TestExchangeRate(this._response);

  @override
  Future<ExchangeRateResponse> build() async => _response;
}

class _MockFinancialSettingsNotifier extends FinancialSettingsNotifier {
  final FinancialSettingsState _state;

  _MockFinancialSettingsNotifier(this._state);

  @override
  FinancialSettingsState build() => _state;
}
