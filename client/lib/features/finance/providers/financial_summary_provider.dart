import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';

part 'financial_summary_provider.freezed.dart';
part 'financial_summary_provider.g.dart';

@freezed
abstract class FinancialSummary with _$FinancialSummary {
  const factory FinancialSummary({
    required Decimal totalNetWorth,
    required Decimal totalAssets,
    required Decimal totalLiabilities,
    required String currencyCode,
    @Default(false) bool isLoading,
    // True when the exchange-rate fetch itself FAILED (vs. individual
    // currencies merely missing a rate). The UI must distinguish these:
    // showing "rates missing for your currencies" while the whole fetch
    // failed would silently zero the net worth and mislead the user into
    // thinking the data is merely incomplete.
    @Default(false) bool ratesFailed,
    // Currency codes of accounts excluded from the totals because no exchange
    // rate was available for them. Empty when every account converted cleanly.
    // UI layers can surface a hint instead of silently treating them as zero.
    @Default(<String>{}) Set<String> missingRateCurrencies,
  }) = _FinancialSummary;

  static final empty = FinancialSummary(
    totalNetWorth: Decimal.zero,
    totalAssets: Decimal.zero,
    totalLiabilities: Decimal.zero,
    currencyCode: 'CNY',
  );
}

@riverpod
class FinancialSummaryNotifier extends _$FinancialSummaryNotifier {
  @override
  FinancialSummary build(String targetCurrency) {
    // Watch required providers
    final accountsState = ref.watch(financialAccountProvider);
    // ratesNotifier needs the state to be ready to access .value inside convert
    // So we watch the provider to rebuild when it changes.
    final ratesAsync = ref.watch(exchangeRateProvider);

    // If exchange rates are still loading, return state with loading flag
    if (ratesAsync.isLoading) {
      return FinancialSummary.empty.copyWith(
        isLoading: true,
        currencyCode: targetCurrency,
      );
    }

    // M-10: the rate fetch failed. Do NOT fall through to the conversion loop:
    // every convert() would return null and every currency would land in
    // missingRateCurrencies, silently zeroing the net worth under the guise
    // of "no rates available". Surface the failure instead so the UI can
    // offer a retry.
    if (ratesAsync.hasError) {
      return FinancialSummary.empty.copyWith(
        isLoading: false,
        ratesFailed: true,
        currencyCode: targetCurrency,
      );
    }

    // Same if accounts are loading
    if (accountsState.isLoading) {
      return FinancialSummary.empty.copyWith(
        isLoading: true,
        currencyCode: targetCurrency,
      );
    }

    final ratesNotifier = ref.read(exchangeRateProvider.notifier);

    var totalAssets = Decimal.zero;
    var totalLiabilities = Decimal.zero;
    var totalNetWorth = Decimal.zero;
    final missingRateCurrencies = <String>{};

    for (final account in accountsState.accounts) {
      // Keep the eligibility rules aligned with _netWorthOf in
      // financial_account_provider: only active accounts opted into net
      // worth contribute to the totals.
      if (account.status != AccountStatus.active) continue;
      if (!account.includeInNetWorth) continue;

      final currency = account.currencyCode;

      final convertedAmount = ratesNotifier.convert(
        account.currentBalance ?? account.initialBalance,
        currency,
        targetCurrency,
      );

      if (convertedAmount == null) {
        // No usable exchange rate for this currency: exclude the account
        // from the totals entirely rather than silently counting it as 0,
        // and record it so the UI can warn the user.
        missingRateCurrencies.add(currency);
        continue;
      }

      if (account.nature == FinancialNature.liability) {
        // Liability balances may arrive as negative values depending on the
        // backend convention. Take the absolute value so that a negative
        // liability never inflates net worth (subtracting a negative would
        // add to it). Both the liability total and the net-worth deduction
        // use the same magnitude.
        final absAmount = convertedAmount.abs();
        totalLiabilities += absAmount;
        totalNetWorth -= absAmount;
      } else {
        totalAssets += convertedAmount;
        totalNetWorth += convertedAmount;
      }
    }

    return FinancialSummary(
      totalNetWorth: totalNetWorth,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      currencyCode: targetCurrency,
      isLoading: false,
      missingRateCurrencies: missingRateCurrencies,
    );
  }
}
