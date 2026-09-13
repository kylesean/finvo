import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:finvo/core/events/domain_events.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:finvo/features/home/services/home_service.dart';
import 'package:finvo/shared/models/exchange_rate.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/shared/models/financial_settings.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';
import 'package:finvo/shared/providers/financial_account_provider.dart';
import 'package:finvo/shared/providers/financial_settings_provider.dart';
import 'package:finvo/shared/services/financial_account_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHomeService extends HomeService {
  _FakeHomeService() : super(NetworkClient(Dio()));

  @override
  Future<List<TransactionModel>> getTransactionFeed({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? date,
    CancelToken? cancelToken,
  }) async {
    return [];
  }
}

class _FakeFinancialAccountService implements FinancialAccountService {
  int loadCalls = 0;
  FinancialAccountResponse accountsResponse = FinancialAccountResponse(
    totalBalance: Decimal.fromInt(100),
    accounts: [
      FinancialAccount(
        id: '1',
        name: 'Bank',
        nature: FinancialNature.asset,
        type: FinancialAccountType.deposit,
        initialBalance: Decimal.fromInt(100),
        currencyCode: 'CNY',
        includeInNetWorth: true,
      ),
    ],
  );

  @override
  Future<FinancialAccountResponse> getFinancialAccounts() async {
    loadCalls++;
    return accountsResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestExchangeRate extends ExchangeRate {
  @override
  Future<ExchangeRateResponse> build() async => const ExchangeRateResponse(
    baseCode: 'CNY',
    conversionRates: {'CNY': 1.0},
  );
}

class _MockFinancialSettingsNotifier extends FinancialSettingsNotifier {
  @override
  FinancialSettingsState build() =>
      const FinancialSettingsState(primaryCurrency: 'CNY');
}

void main() {
  test(
    'transactionEventSubscriber reloads financialAccountProvider on transaction event',
    () async {
      final fakeHomeService = _FakeHomeService();
      final fakeAccountService = _FakeFinancialAccountService();

      final container = ProviderContainer(
        overrides: [
          authTokenProvider.overrideWith((ref) => 'fake-token'),
          homeServiceProvider.overrideWithValue(fakeHomeService),
          financialAccountServiceProvider.overrideWithValue(fakeAccountService),
          financialSettingsProvider.overrideWith(
            () => _MockFinancialSettingsNotifier(),
          ),
          exchangeRateProvider.overrideWith(() => _TestExchangeRate()),
        ],
      );
      addTearDown(container.dispose);

      // Start the subscriber
      container.read(transactionEventSubscriberProvider);

      // Initially accounts not loaded yet
      expect(fakeAccountService.loadCalls, 0);
      expect(container.read(financialAccountProvider).accounts, isEmpty);

      // Emit a transaction created event
      final eventBus = container.read(transactionCreatedEventsProvider);
      eventBus.add(
        TransactionCreatedEvent(
          amount: 50.0,
          transactionType: 'EXPENSE',
          currency: 'CNY',
          occurredAt: DateTime.now(),
        ),
      );

      // Allow async event loop to process stream event and notifier load
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // FinancialAccountService.getFinancialAccounts must have been called
      expect(fakeAccountService.loadCalls, 1);
      final state = container.read(financialAccountProvider);
      expect(state.isLoading, isFalse);
      expect(state.accounts.length, 1);
      expect(state.accounts.first.name, 'Bank');
    },
  );
}
