// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Financial settings state notifier
///
/// [keepAlive] so the primary currency is loaded once on login and reused
/// across every currency-dependent screen (home/budget/report/shared widgets)
/// without being torn down when those screens leave the tree.

@ProviderFor(FinancialSettingsNotifier)
final financialSettingsProvider = FinancialSettingsNotifierProvider._();

/// Financial settings state notifier
///
/// [keepAlive] so the primary currency is loaded once on login and reused
/// across every currency-dependent screen (home/budget/report/shared widgets)
/// without being torn down when those screens leave the tree.
final class FinancialSettingsNotifierProvider
    extends
        $NotifierProvider<FinancialSettingsNotifier, FinancialSettingsState> {
  /// Financial settings state notifier
  ///
  /// [keepAlive] so the primary currency is loaded once on login and reused
  /// across every currency-dependent screen (home/budget/report/shared widgets)
  /// without being torn down when those screens leave the tree.
  FinancialSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialSettingsNotifierHash();

  @$internal
  @override
  FinancialSettingsNotifier create() => FinancialSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinancialSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinancialSettingsState>(value),
    );
  }
}

String _$financialSettingsNotifierHash() =>
    r'4e6ac4e0069e02c0297530f4eadc1c4050b92853';

/// Financial settings state notifier
///
/// [keepAlive] so the primary currency is loaded once on login and reused
/// across every currency-dependent screen (home/budget/report/shared widgets)
/// without being torn down when those screens leave the tree.

abstract class _$FinancialSettingsNotifier
    extends $Notifier<FinancialSettingsState> {
  FinancialSettingsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<FinancialSettingsState, FinancialSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FinancialSettingsState, FinancialSettingsState>,
              FinancialSettingsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
