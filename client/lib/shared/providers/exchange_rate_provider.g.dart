// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExchangeRate)
final exchangeRateProvider = ExchangeRateProvider._();

final class ExchangeRateProvider
    extends $AsyncNotifierProvider<ExchangeRate, ExchangeRateResponse> {
  ExchangeRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exchangeRateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exchangeRateHash();

  @$internal
  @override
  ExchangeRate create() => ExchangeRate();
}

String _$exchangeRateHash() => r'0d48ade8887e62340000a58dfd3060a5e570f71b';

abstract class _$ExchangeRate extends $AsyncNotifier<ExchangeRateResponse> {
  FutureOr<ExchangeRateResponse> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ExchangeRateResponse>, ExchangeRateResponse>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ExchangeRateResponse>,
                ExchangeRateResponse
              >,
              AsyncValue<ExchangeRateResponse>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
