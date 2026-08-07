// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads a single transaction's detail as an [String] keyed, auto-disposed,
/// family [AsyncNotifier]. The loading / error / data lifecycle is fully
/// managed by [AsyncValue], removing the hand-rolled isLoading/errorMessage
/// state and the side-effect in `build()`.

@ProviderFor(TransactionDetail)
final transactionDetailProvider = TransactionDetailFamily._();

/// Loads a single transaction's detail as an [String] keyed, auto-disposed,
/// family [AsyncNotifier]. The loading / error / data lifecycle is fully
/// managed by [AsyncValue], removing the hand-rolled isLoading/errorMessage
/// state and the side-effect in `build()`.
final class TransactionDetailProvider
    extends $AsyncNotifierProvider<TransactionDetail, TransactionModel> {
  /// Loads a single transaction's detail as an [String] keyed, auto-disposed,
  /// family [AsyncNotifier]. The loading / error / data lifecycle is fully
  /// managed by [AsyncValue], removing the hand-rolled isLoading/errorMessage
  /// state and the side-effect in `build()`.
  TransactionDetailProvider._({
    required TransactionDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionDetailHash();

  @override
  String toString() {
    return r'transactionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionDetail create() => TransactionDetail();

  @override
  bool operator ==(Object other) {
    return other is TransactionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionDetailHash() => r'f08c69a67ab081e81a660ec594640f64cbe889c1';

/// Loads a single transaction's detail as an [String] keyed, auto-disposed,
/// family [AsyncNotifier]. The loading / error / data lifecycle is fully
/// managed by [AsyncValue], removing the hand-rolled isLoading/errorMessage
/// state and the side-effect in `build()`.

final class TransactionDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionDetail,
          AsyncValue<TransactionModel>,
          TransactionModel,
          FutureOr<TransactionModel>,
          String
        > {
  TransactionDetailFamily._()
    : super(
        retry: null,
        name: r'transactionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads a single transaction's detail as an [String] keyed, auto-disposed,
  /// family [AsyncNotifier]. The loading / error / data lifecycle is fully
  /// managed by [AsyncValue], removing the hand-rolled isLoading/errorMessage
  /// state and the side-effect in `build()`.

  TransactionDetailProvider call(String transactionId) =>
      TransactionDetailProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'transactionDetailProvider';
}

/// Loads a single transaction's detail as an [String] keyed, auto-disposed,
/// family [AsyncNotifier]. The loading / error / data lifecycle is fully
/// managed by [AsyncValue], removing the hand-rolled isLoading/errorMessage
/// state and the side-effect in `build()`.

abstract class _$TransactionDetail extends $AsyncNotifier<TransactionModel> {
  late final _$args = ref.$arg as String;
  String get transactionId => _$args;

  FutureOr<TransactionModel> build(String transactionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransactionModel>, TransactionModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransactionModel>, TransactionModel>,
              AsyncValue<TransactionModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
