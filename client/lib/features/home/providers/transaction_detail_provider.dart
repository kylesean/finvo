import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/home/services/home_service.dart';

part 'transaction_detail_provider.g.dart';

/// Loads a single transaction's detail as an [String] keyed, auto-disposed,
/// family [AsyncNotifier]. The loading / error / data lifecycle is fully
/// managed by [AsyncValue], removing the hand-rolled isLoading/errorMessage
/// state and the side-effect in `build()`.
@riverpod
class TransactionDetail extends _$TransactionDetail {
  @override
  FutureOr<TransactionModel> build(String transactionId) {
    final service = ref.watch(homeServiceProvider);
    return service.getTransactionDetail(transactionId);
  }

  /// Re-fetch the transaction detail by invalidating the provider.
  Future<void> reload() {
    ref.invalidateSelf();
    return future;
  }
}
