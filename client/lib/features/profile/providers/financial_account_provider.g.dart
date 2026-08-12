// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FinancialAccountNotifier)
final financialAccountProvider = FinancialAccountNotifierProvider._();

final class FinancialAccountNotifierProvider
    extends $NotifierProvider<FinancialAccountNotifier, FinancialAccountState> {
  FinancialAccountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialAccountNotifierHash();

  @$internal
  @override
  FinancialAccountNotifier create() => FinancialAccountNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinancialAccountState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinancialAccountState>(value),
    );
  }
}

String _$financialAccountNotifierHash() =>
    r'24660ba43238b8a47ec948f9c82f28ddbfd343fe';

abstract class _$FinancialAccountNotifier
    extends $Notifier<FinancialAccountState> {
  FinancialAccountState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FinancialAccountState, FinancialAccountState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FinancialAccountState, FinancialAccountState>,
              FinancialAccountState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
