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
    r'63821676f2c91b7eafff77b70f2f592dd57090eb';

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
