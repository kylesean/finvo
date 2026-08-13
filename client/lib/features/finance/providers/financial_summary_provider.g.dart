// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FinancialSummaryNotifier)
final financialSummaryProvider = FinancialSummaryNotifierFamily._();

final class FinancialSummaryNotifierProvider
    extends $NotifierProvider<FinancialSummaryNotifier, FinancialSummary> {
  FinancialSummaryNotifierProvider._({
    required FinancialSummaryNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'financialSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$financialSummaryNotifierHash();

  @override
  String toString() {
    return r'financialSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FinancialSummaryNotifier create() => FinancialSummaryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinancialSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinancialSummary>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FinancialSummaryNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$financialSummaryNotifierHash() =>
    r'c00e49a39be14aa5f8bd57781b045103aaab8dc1';

final class FinancialSummaryNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          FinancialSummaryNotifier,
          FinancialSummary,
          FinancialSummary,
          FinancialSummary,
          String
        > {
  FinancialSummaryNotifierFamily._()
    : super(
        retry: null,
        name: r'financialSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FinancialSummaryNotifierProvider call(String targetCurrency) =>
      FinancialSummaryNotifierProvider._(argument: targetCurrency, from: this);

  @override
  String toString() => r'financialSummaryProvider';
}

abstract class _$FinancialSummaryNotifier extends $Notifier<FinancialSummary> {
  late final _$args = ref.$arg as String;
  String get targetCurrency => _$args;

  FinancialSummary build(String targetCurrency);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FinancialSummary, FinancialSummary>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FinancialSummary, FinancialSummary>,
              FinancialSummary,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
