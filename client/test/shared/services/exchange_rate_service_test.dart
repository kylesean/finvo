import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/shared/models/exchange_rate.dart';
import 'package:finvo/shared/services/exchange_rate_service.dart';

import 'exchange_rate_service_test.mocks.dart';

@GenerateMocks([NetworkClient])
void main() {
  late ExchangeRateService service;
  late MockNetworkClient mockNetworkClient;

  setUp(() {
    mockNetworkClient = MockNetworkClient();
    service = ExchangeRateService(mockNetworkClient);
  });

  group('ExchangeRateResponse model', () {
    test('fromJson parses valid response', () {
      final json = {
        'base_code': 'CNY',
        'last_update_utc': '2026-07-29 00:00:00',
        'conversion_rates': {'USD': 0.14, 'EUR': 0.13, 'JPY': 21.5},
      };

      final response = ExchangeRateResponse.fromJson(json);

      expect(response.baseCode, 'CNY');
      expect(response.lastUpdateUtc, '2026-07-29 00:00:00');
      expect(response.conversionRates['USD'], 0.14);
      expect(response.conversionRates['EUR'], 0.13);
      expect(response.conversionRates['JPY'], 21.5);
    });

    test('fromJson handles null last_update_utc', () {
      final json = {
        'base_code': 'USD',
        'conversion_rates': {'CNY': 7.2},
      };

      final response = ExchangeRateResponse.fromJson(json);

      expect(response.baseCode, 'USD');
      expect(response.lastUpdateUtc, isNull);
      expect(response.conversionRates['CNY'], 7.2);
    });

    test('fromJson with empty conversion_rates', () {
      final json = {'base_code': 'EUR', 'conversion_rates': <String, double>{}};

      final response = ExchangeRateResponse.fromJson(json);

      expect(response.conversionRates, isEmpty);
    });

    test('toJson round-trip preserves data', () {
      const original = ExchangeRateResponse(
        baseCode: 'CNY',
        lastUpdateUtc: '2026-07-29 12:00:00',
        conversionRates: {'USD': 0.14, 'GBP': 0.11},
      );

      final json = original.toJson();
      final restored = ExchangeRateResponse.fromJson(json);

      expect(restored.baseCode, original.baseCode);
      expect(restored.lastUpdateUtc, original.lastUpdateUtc);
      expect(restored.conversionRates, original.conversionRates);
    });
  });

  group('ExchangeRateService.getExchangeRates', () {
    test('returns parsed response on success', () async {
      const expectedResponse = ExchangeRateResponse(
        baseCode: 'CNY',
        lastUpdateUtc: '2026-07-29 00:00:00',
        conversionRates: {'USD': 0.14, 'EUR': 0.13},
      );

      when(
        mockNetworkClient.request<ExchangeRateResponse>(
          '/exchange-rates',
          method: HttpMethod.get,
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenAnswer((_) async => expectedResponse);

      final result = await service.getExchangeRates();

      expect(result.baseCode, 'CNY');
      expect(result.conversionRates['USD'], 0.14);
      verify(
        mockNetworkClient.request<ExchangeRateResponse>(
          '/exchange-rates',
          method: HttpMethod.get,
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).called(1);
    });

    test('propagates network exception on failure', () async {
      when(
        mockNetworkClient.request<ExchangeRateResponse>(
          '/exchange-rates',
          method: HttpMethod.get,
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenThrow(NetworkException('Connection failed'));

      await expectLater(
        service.getExchangeRates(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
