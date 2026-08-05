import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/shared/models/exchange_rate.dart';
import 'package:finvo/shared/services/response_parser.dart';

class ExchangeRateService {
  final NetworkClient _networkClient;

  ExchangeRateService(this._networkClient);

  Future<ExchangeRateResponse> getExchangeRates() async {
    return await _networkClient.request<ExchangeRateResponse>(
      '/exchange-rates',
      method: HttpMethod.get,
      fromJsonT: (json) =>
          ResponseParser.parseItem(json, ExchangeRateResponse.fromJson),
    );
  }
}

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ExchangeRateService(networkClient);
});
