import 'package:logging/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate.freezed.dart';
part 'exchange_rate.g.dart';

final _logger = Logger('ExchangeRateModel');

/// Tolerant rate coercion (CORE-H2): the provider's `convert()` is designed
/// to degrade a single bad rate to "missing" (tryParse), but the generated
/// `(e as num).toDouble()` parsing was strict — one string rate in the JSON
/// crashed the ENTIRE exchange-rate response, putting every currency screen
/// into the error state. Parse tolerantly here so a bad rate degrades to
/// missing (and is dropped) instead of breaking the whole load.
Map<String, double> _ratesFromJson(Object? json) {
  if (json is! Map) return const {};
  final rates = <String, double>{};
  json.forEach((key, value) {
    final name = key?.toString();
    if (name == null || name.isEmpty) return;
    // SHR-01: normalize keys to uppercase on ingress — the converters query
    // with upcased codes, so a lowercase key from the server would silently
    // be treated as a missing rate and drop that currency from totals.
    final normalizedName = name.toUpperCase();
    if (value is num) {
      rates[normalizedName] = value.toDouble();
      return;
    }
    final parsed = double.tryParse(value?.toString().trim() ?? '');
    if (parsed != null) {
      rates[normalizedName] = parsed;
    } else {
      _logger.warning('exchange_rate: dropping invalid rate for "$name"');
    }
  });
  return rates;
}

Map<String, double> _ratesToJson(Map<String, double> rates) => rates;

@freezed
abstract class ExchangeRateResponse with _$ExchangeRateResponse {
  const factory ExchangeRateResponse({
    @JsonKey(name: 'base_code') required String baseCode,
    @JsonKey(name: 'last_update_utc') String? lastUpdateUtc,
    @JsonKey(
      name: 'conversion_rates',
      fromJson: _ratesFromJson,
      toJson: _ratesToJson,
    )
    required Map<String, double> conversionRates,
  }) = _ExchangeRateResponse;

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateResponseFromJson(json);
}
