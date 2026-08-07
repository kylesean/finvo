// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_events.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Buffering broadcast bus for [TransactionCreatedEvent].
///
/// Kept alive for the whole app lifetime: events must not be dropped just
/// because no listener happens to be attached at emit time.

@ProviderFor(transactionCreatedEvents)
final transactionCreatedEventsProvider = TransactionCreatedEventsProvider._();

/// Buffering broadcast bus for [TransactionCreatedEvent].
///
/// Kept alive for the whole app lifetime: events must not be dropped just
/// because no listener happens to be attached at emit time.

final class TransactionCreatedEventsProvider
    extends
        $FunctionalProvider<
          StreamController<TransactionCreatedEvent>,
          StreamController<TransactionCreatedEvent>,
          StreamController<TransactionCreatedEvent>
        >
    with $Provider<StreamController<TransactionCreatedEvent>> {
  /// Buffering broadcast bus for [TransactionCreatedEvent].
  ///
  /// Kept alive for the whole app lifetime: events must not be dropped just
  /// because no listener happens to be attached at emit time.
  TransactionCreatedEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionCreatedEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionCreatedEventsHash();

  @$internal
  @override
  $ProviderElement<StreamController<TransactionCreatedEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StreamController<TransactionCreatedEvent> create(Ref ref) {
    return transactionCreatedEvents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamController<TransactionCreatedEvent> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<StreamController<TransactionCreatedEvent>>(value),
    );
  }
}

String _$transactionCreatedEventsHash() =>
    r'acaebc38d2fe719f3346d3496ab048ccae229f9a';
