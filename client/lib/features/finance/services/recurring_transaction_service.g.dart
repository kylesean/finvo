// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recurring transaction service provider

@ProviderFor(recurringTransactionService)
final recurringTransactionServiceProvider =
    RecurringTransactionServiceProvider._();

/// Recurring transaction service provider

final class RecurringTransactionServiceProvider
    extends
        $FunctionalProvider<
          RecurringTransactionService,
          RecurringTransactionService,
          RecurringTransactionService
        >
    with $Provider<RecurringTransactionService> {
  /// Recurring transaction service provider
  RecurringTransactionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionServiceHash();

  @$internal
  @override
  $ProviderElement<RecurringTransactionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringTransactionService create(Ref ref) {
    return recurringTransactionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringTransactionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringTransactionService>(value),
    );
  }
}

String _$recurringTransactionServiceHash() =>
    r'90a34738357ad6c7b18c0e348f05a85c97a5ccdd';
