import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/finance/providers/financial_summary_provider.dart';
import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/shared/models/exchange_rate.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';

void main() {
  group('FinancialSummary model', () {
    test('empty has zero values and CNY currency', () {
      final summary = FinancialSummary.empty;

      expect(summary.totalNetWorth, Decimal.zero);
      expect(summary.totalAssets, Decimal.zero);
      expect(summary.totalLiabilities, Decimal.zero);
      expect(summary.currencyCode, 'CNY');
      expect(summary.isLoading, isFalse);
    });

    test('copyWith updates specified fields only', () {
      final original = FinancialSummary.empty;
      final updated = original.copyWith(
        totalAssets: Decimal.fromInt(1000),
        isLoading: true,
      );

      expect(updated.totalAssets, Decimal.fromInt(1000));
      expect(updated.isLoading, isTrue);
      // Unchanged fields
      expect(updated.totalNetWorth, Decimal.zero);
      expect(updated.totalLiabilities, Decimal.zero);
      expect(updated.currencyCode, 'CNY');
    });

    test('copyWith updates currency code', () {
      final updated = FinancialSummary.empty.copyWith(currencyCode: 'USD');
      expect(updated.currencyCode, 'USD');
    });

    test('net worth = assets - liabilities', () {
      final summary = FinancialSummary(
        totalAssets: Decimal.fromInt(10000),
        totalLiabilities: Decimal.fromInt(3000),
        totalNetWorth: Decimal.fromInt(7000),
        currencyCode: 'CNY',
      );

      expect(
        summary.totalAssets - summary.totalLiabilities,
        summary.totalNetWorth,
      );
    });
  });

  group('FinancialSummaryNotifier provider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('returns loading state when exchange rates are loading', () {
      container = ProviderContainer(
        overrides: [
          financialAccountProvider.overrideWith(
            () => _MockFinancialAccountNotifier(
              const FinancialAccountState(accounts: [], isLoading: false),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _LoadingExchangeRateNotifier(),
          ),
        ],
      );

      final summary = container.read(financialSummaryProvider('CNY'));
      expect(summary.isLoading, isTrue);
    });

    test('returns loading state when accounts are loading', () {
      container = ProviderContainer(
        overrides: [
          financialAccountProvider.overrideWith(
            () => _MockFinancialAccountNotifier(
              const FinancialAccountState(accounts: [], isLoading: true),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _MockExchangeRateNotifier(
              const ExchangeRateResponse(
                baseCode: 'CNY',
                conversionRates: {'USD': 0.14},
              ),
            ),
          ),
        ],
      );

      final summary = container.read(financialSummaryProvider('CNY'));
      expect(summary.isLoading, isTrue);
    });

    test('calculates totals with asset and liability accounts', () async {
      final accounts = [
        FinancialAccount(
          id: '1',
          name: 'Savings',
          nature: FinancialNature.asset,
          type: FinancialAccountType.deposit,
          initialBalance: Decimal.fromInt(5000),
          currencyCode: 'CNY',
          includeInNetWorth: true,
        ),
        FinancialAccount(
          id: '2',
          name: 'Credit Card',
          nature: FinancialNature.liability,
          type: FinancialAccountType.creditCard,
          initialBalance: Decimal.fromInt(2000),
          currencyCode: 'CNY',
          includeInNetWorth: true,
        ),
      ];

      container = ProviderContainer(
        overrides: [
          financialAccountProvider.overrideWith(
            () => _MockFinancialAccountNotifier(
              FinancialAccountState(accounts: accounts, isLoading: false),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _MockExchangeRateNotifier(
              const ExchangeRateResponse(
                baseCode: 'CNY',
                conversionRates: {'USD': 0.14},
              ),
            ),
          ),
        ],
      );

      // Wait for async provider to settle
      await container.read(exchangeRateProvider.future);
      await Future<void>.delayed(Duration.zero);

      final summary = container.read(financialSummaryProvider('CNY'));

      expect(summary.isLoading, isFalse);
      expect(summary.totalAssets, Decimal.fromInt(5000));
      expect(summary.totalLiabilities, Decimal.fromInt(2000));
      expect(summary.totalNetWorth, Decimal.fromInt(3000));
    });

    test('excludes accounts with includeInNetWorth=false', () async {
      final accounts = [
        FinancialAccount(
          id: '1',
          name: 'Savings',
          nature: FinancialNature.asset,
          type: FinancialAccountType.deposit,
          initialBalance: Decimal.fromInt(5000),
          currencyCode: 'CNY',
          includeInNetWorth: true,
        ),
        FinancialAccount(
          id: '2',
          name: 'Hidden',
          nature: FinancialNature.asset,
          type: FinancialAccountType.deposit,
          initialBalance: Decimal.fromInt(9999),
          currencyCode: 'CNY',
          includeInNetWorth: false,
        ),
      ];

      container = ProviderContainer(
        overrides: [
          financialAccountProvider.overrideWith(
            () => _MockFinancialAccountNotifier(
              FinancialAccountState(accounts: accounts, isLoading: false),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _MockExchangeRateNotifier(
              const ExchangeRateResponse(baseCode: 'CNY', conversionRates: {}),
            ),
          ),
        ],
      );

      await container.read(exchangeRateProvider.future);
      await Future<void>.delayed(Duration.zero);

      final summary = container.read(financialSummaryProvider('CNY'));

      expect(summary.totalAssets, Decimal.fromInt(5000));
      expect(summary.totalNetWorth, Decimal.fromInt(5000));
    });

    test('empty accounts list returns zero summary', () async {
      container = ProviderContainer(
        overrides: [
          financialAccountProvider.overrideWith(
            () => _MockFinancialAccountNotifier(
              const FinancialAccountState(accounts: [], isLoading: false),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _MockExchangeRateNotifier(
              const ExchangeRateResponse(baseCode: 'CNY', conversionRates: {}),
            ),
          ),
        ],
      );

      await container.read(exchangeRateProvider.future);
      await Future<void>.delayed(Duration.zero);

      final summary = container.read(financialSummaryProvider('CNY'));

      expect(summary.totalAssets, Decimal.zero);
      expect(summary.totalLiabilities, Decimal.zero);
      expect(summary.totalNetWorth, Decimal.zero);
      expect(summary.isLoading, isFalse);
    });

    test('excludes accounts whose currency has no exchange rate', () async {
      final accounts = [
        FinancialAccount(
          id: '1',
          name: 'Savings',
          nature: FinancialNature.asset,
          type: FinancialAccountType.deposit,
          initialBalance: Decimal.fromInt(5000),
          currencyCode: 'CNY',
          includeInNetWorth: true,
        ),
        FinancialAccount(
          id: '2',
          name: 'USD Wallet',
          nature: FinancialNature.asset,
          type: FinancialAccountType.deposit,
          initialBalance: Decimal.fromInt(100),
          currencyCode: 'USD',
          includeInNetWorth: true,
        ),
      ];

      container = ProviderContainer(
        overrides: [
          financialAccountProvider.overrideWith(
            () => _MockFinancialAccountNotifier(
              FinancialAccountState(accounts: accounts, isLoading: false),
            ),
          ),
          exchangeRateProvider.overrideWith(
            () => _MockExchangeRateNotifier(
              // No USD rate available.
              const ExchangeRateResponse(baseCode: 'CNY', conversionRates: {}),
            ),
          ),
        ],
      );

      await container.read(exchangeRateProvider.future);
      await Future<void>.delayed(Duration.zero);

      final summary = container.read(financialSummaryProvider('CNY'));

      // The USD account must be excluded entirely (not counted as zero
      // silently) and recorded so the UI can warn the user.
      expect(summary.totalAssets, Decimal.fromInt(5000));
      expect(summary.totalNetWorth, Decimal.fromInt(5000));
      expect(summary.missingRateCurrencies, {'USD'});
    });
  });
}

/// Mock notifier that returns a fixed state
class _MockFinancialAccountNotifier extends FinancialAccountNotifier {
  final FinancialAccountState _state;

  _MockFinancialAccountNotifier(this._state);

  @override
  FinancialAccountState build() => _state;
}

/// Mock exchange rate notifier that returns a fixed response
class _MockExchangeRateNotifier extends ExchangeRate {
  final ExchangeRateResponse _response;

  _MockExchangeRateNotifier(this._response);

  @override
  Future<ExchangeRateResponse> build() async => _response;
}

/// Mock exchange rate notifier that stays in loading state
class _LoadingExchangeRateNotifier extends ExchangeRate {
  @override
  Future<ExchangeRateResponse> build() async {
    // Never completes - simulates loading state
    await Future<ExchangeRateResponse>.delayed(const Duration(hours: 1));
    throw UnimplementedError();
  }
}
