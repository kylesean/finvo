// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExchangeRateResponse _$ExchangeRateResponseFromJson(
  Map<String, dynamic> json,
) => _ExchangeRateResponse(
  baseCode: json['base_code'] as String,
  lastUpdateUtc: json['last_update_utc'] as String?,
  conversionRates: _ratesFromJson(json['conversion_rates']),
);

Map<String, dynamic> _$ExchangeRateResponseToJson(
  _ExchangeRateResponse instance,
) => <String, dynamic>{
  'base_code': instance.baseCode,
  'last_update_utc': instance.lastUpdateUtc,
  'conversion_rates': _ratesToJson(instance.conversionRates),
};
