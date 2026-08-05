// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetFilterState)
final budgetFilterStateProvider = BudgetFilterStateProvider._();

final class BudgetFilterStateProvider
    extends $NotifierProvider<BudgetFilterState, BudgetFilter> {
  BudgetFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetFilterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetFilterStateHash();

  @$internal
  @override
  BudgetFilterState create() => BudgetFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetFilter>(value),
    );
  }
}

String _$budgetFilterStateHash() => r'7b2ed20675cbed3ee3d166fd17ea0a2e1f2aee3c';

abstract class _$BudgetFilterState extends $Notifier<BudgetFilter> {
  BudgetFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BudgetFilter, BudgetFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BudgetFilter, BudgetFilter>,
              BudgetFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BudgetSummaryNotifier)
final budgetSummaryProvider = BudgetSummaryNotifierProvider._();

final class BudgetSummaryNotifierProvider
    extends $NotifierProvider<BudgetSummaryNotifier, BudgetSummaryState> {
  BudgetSummaryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetSummaryNotifierHash();

  @$internal
  @override
  BudgetSummaryNotifier create() => BudgetSummaryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetSummaryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetSummaryState>(value),
    );
  }
}

String _$budgetSummaryNotifierHash() =>
    r'd1096ad0babd354632734a166f01a298ef59a3f4';

abstract class _$BudgetSummaryNotifier extends $Notifier<BudgetSummaryState> {
  BudgetSummaryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BudgetSummaryState, BudgetSummaryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BudgetSummaryState, BudgetSummaryState>,
              BudgetSummaryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
