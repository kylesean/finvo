import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finvo/app/theme/app_theme_palette.dart';
import 'package:finvo/app/theme/forui_theme_config.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/finance/pages/financial_accounts_page.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/models/exchange_rate.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/shared/models/financial_settings.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';
import 'package:finvo/shared/providers/financial_account_provider.dart';
import 'package:finvo/shared/providers/financial_settings_provider.dart';
import 'package:finvo/shared/services/financial_account_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFinancialAccountService implements FinancialAccountService {
  FinancialAccountResponse accountsResponse = FinancialAccountResponse(
    totalBalance: Decimal.zero,
  );
  Completer<FinancialAccountResponse>? pendingCompleter;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<FinancialAccountResponse> getFinancialAccounts() async {
    callCount++;
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    if (shouldThrow) {
      throw Exception('Failed to fetch accounts');
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FinancialAccountsPage Widget Tests', () {
    late SharedPreferences prefs;
    late _FakeFinancialAccountService fakeService;

    setUp(() async {
      await LocaleSettings.setLocale(AppLocale.zh);
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      fakeService = _FakeFinancialAccountService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
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
        child: MaterialApp(
          home: FTheme(
            data: ForuiThemeConfig.resolve(
              palette: AppThemePalette.zinc,
              brightness: Brightness.light,
            ),
            child: const FinancialAccountsPage(),
          ),
        ),
      );
    }

    testWidgets(
      'shows loading spinner initially, then renders account list upon load',
      (tester) async {
        fakeService.pendingCompleter = Completer<FinancialAccountResponse>();

        await tester.pumpWidget(createTestWidget());
        // Let postFrameCallback execute
        await tester.pump();

        // While pending, CircularProgressIndicator is displayed
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(fakeService.callCount, 1);

        // Complete the network call
        fakeService.pendingCompleter!.complete(
          FinancialAccountResponse(
            accounts: [
              FinancialAccount(
                id: 'acc-1',
                name: '招商银行储蓄卡',
                nature: FinancialNature.asset,
                type: FinancialAccountType.deposit,
                initialBalance: Decimal.fromInt(12345),
                currencyCode: 'CNY',
                includeInNetWorth: true,
              ),
            ],
            totalBalance: Decimal.fromInt(12345),
            lastUpdatedAt: DateTime.now().toIso8601String(),
          ),
        );

        await tester.pumpAndSettle();

        // Loading spinner disappears and account item is shown
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('招商银行储蓄卡'), findsOneWidget);
      },
    );

    testWidgets(
      'shows error and retry button on load failure, retries successfully',
      (tester) async {
        fakeService.shouldThrow = true;

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Error message & retry button are displayed
        expect(find.text(t.common.retry), findsOneWidget);
        expect(fakeService.callCount, 1);

        // Now fix the service and click retry
        fakeService.shouldThrow = false;
        fakeService.accountsResponse = FinancialAccountResponse(
          accounts: [
            FinancialAccount(
              id: 'acc-2',
              name: '微信零钱',
              nature: FinancialNature.asset,
              type: FinancialAccountType.eMoney,
              initialBalance: Decimal.fromInt(888),
              currencyCode: 'CNY',
              includeInNetWorth: true,
            ),
          ],
          totalBalance: Decimal.fromInt(888),
          lastUpdatedAt: DateTime.now().toIso8601String(),
        );

        await tester.tap(find.text(t.common.retry));
        await tester.pumpAndSettle();

        expect(fakeService.callCount, 2);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('微信零钱'), findsOneWidget);
      },
    );

    testWidgets('recovers from invalidation without infinite loading loop', (
      tester,
    ) async {
      fakeService.accountsResponse = FinancialAccountResponse(
        accounts: [
          FinancialAccount(
            id: 'acc-3',
            name: '支付宝余额',
            nature: FinancialNature.asset,
            type: FinancialAccountType.eMoney,
            initialBalance: Decimal.fromInt(666),
            currencyCode: 'CNY',
            includeInNetWorth: true,
          ),
        ],
        totalBalance: Decimal.fromInt(666),
        lastUpdatedAt: DateTime.now().toIso8601String(),
      );

      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
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
          child: MaterialApp(
            home: FTheme(
              data: ForuiThemeConfig.resolve(
                palette: AppThemePalette.zinc,
                brightness: Brightness.light,
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  capturedRef = ref;
                  return const FinancialAccountsPage();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('支付宝余额'), findsOneWidget);
      expect(fakeService.callCount, 1);

      // Simulate provider invalidation (e.g. from transaction event or cache reset)
      capturedRef.invalidate(financialAccountProvider);
      await tester.pump(); // Triggers rebuild and postFrameCallback
      await tester.pumpAndSettle();

      // The page should have automatically re-fetched and displayed accounts
      expect(fakeService.callCount, 2);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('支付宝余额'), findsOneWidget);
    });
  });
}
