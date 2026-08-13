import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/shared/models/exchange_rate.dart';
import 'package:finvo/shared/services/exchange_rate_service.dart';

part 'exchange_rate_provider.g.dart';

// Note: Exchange rates are cached on the backend for 24 hours (free API limitation).
// No client-side periodic refresh is needed as the backend handles caching.

@Riverpod(keepAlive: true)
class ExchangeRate extends _$ExchangeRate {
  @override
  Future<ExchangeRateResponse> build() async {
    final service = ref.watch(exchangeRateServiceProvider);
    return service.getExchangeRates();
  }

  /// Convert amount from one currency to another
  /// Returns null if conversion is not possible (e.g. rate missing)
  Decimal? convert(Decimal amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    final rates = state.value?.conversionRates;
    final base = state.value?.baseCode;

    if (rates == null || base == null) return null;

    // Normalize currencies
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();
    final baseCurrency = base.toUpperCase();

    // Get rate: Base -> Currency
    // If rate map contains "CNY": 7.2 (where Base is USD), then 1 USD = 7.2 CNY.
    // So Value(CNY) = Value(USD) * 7.2
    // Rates are parsed into Decimal so the whole conversion stays in Decimal,
    // avoiding floating-point rounding on monetary amounts.
    final Decimal? fromRate;
    final Decimal? toRate;

    if (from == baseCurrency) {
      fromRate = Decimal.one;
    } else {
      // Parse tolerantly: the backend may deliver a rate in a form whose
      // toString() is not a valid Decimal literal (e.g. scientific notation
      // or an unexpected type). A single bad rate must degrade to "no rate"
      // (null -> caller shows the missing-rate state) instead of throwing.
      final r = rates[from];
      fromRate = r != null ? Decimal.tryParse(r.toString()) : null;
    }

    if (to == baseCurrency) {
      toRate = Decimal.one;
    } else {
      final r = rates[to];
      toRate = r != null ? Decimal.tryParse(r.toString()) : null;
    }

    if (fromRate == null || toRate == null) return null;

    // Convert From -> Base
    // Amount(Base) = Amount(From) / Rate(Base->From)
    // Note: `Decimal / Decimal` yields a Rational, so convert back to Decimal.
    // `toDecimal()` without `scaleOnInfinite` throws `StateError` on
    // non-terminating decimals (e.g. 100 / 7.2 = 13.888…), which is common
    // for real-world exchange rates. Scale to 20 digits — far beyond any
    // monetary precision — so the division never throws; the final result is
    // rounded to 2 decimal places below anyway.
    final Decimal amountInBase = (amount / fromRate).toDecimal(
      scaleOnInfinitePrecision: 20,
    );

    // Convert Base -> To
    // Amount(To) = Amount(Base) * Rate(Base->To)
    final Decimal amountInTarget = amountInBase * toRate;

    return amountInTarget.round(scale: 2);
  }
}
