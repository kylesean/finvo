import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/budget/models/budget_models.dart';
import 'package:finvo/features/budget/services/budget_service.dart';
import 'package:finvo/i18n/strings.g.dart';

part 'budget_provider.g.dart';

@riverpod
class BudgetFilterState extends _$BudgetFilterState {
  @override
  BudgetFilter build() => BudgetFilter.active;

  void setFilter(BudgetFilter filter) => state = filter;
}

enum BudgetFilter { active, all }

extension BudgetFilterExtension on BudgetFilter {
  String get label => switch (this) {
    BudgetFilter.active => t.budget.active,
    BudgetFilter.all => t.budget.all,
  };

  bool get includePaused => this == BudgetFilter.all;
}

class BudgetSummaryState {
  final BudgetSummary? summary;
  final bool isLoading;

  /// Typed error (e.g. [AppException]) so UI can branch on the concrete type.
  /// Previously flattened to `String`, which destroyed that information.
  final Object? error;

  const BudgetSummaryState({this.summary, this.isLoading = false, this.error});

  BudgetSummaryState copyWith({
    BudgetSummary? summary,
    bool? isLoading,
    Object? error,
  }) {
    return BudgetSummaryState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasBudgets => summary?.hasBudgets ?? false;
}

@riverpod
class BudgetSummaryNotifier extends _$BudgetSummaryNotifier {
  /// Generation token guarding against stale responses. Incremented on every
  /// load/refresh; a response is discarded if its captured generation no
  /// longer matches, so a fast filter switch can't have an old request
  /// overwrite the newer selection's data.
  int _loadGeneration = 0;

  @override
  BudgetSummaryState build() {
    return const BudgetSummaryState();
  }

  Future<void> load() async {
    // No early-return on isLoading: a pending request for the previous filter
    // must not cause the new filter's request to be silently dropped (which
    // previously left the label showing "All" while the list still showed
    // "Active" data).
    final generation = ++_loadGeneration;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(budgetServiceProvider);
      final filter = ref.read(budgetFilterStateProvider);
      final summary = await service.getSummary(
        includePaused: filter.includePaused,
      );
      // Discard a stale response if the user switched filters while this
      // request was in flight, or if the provider was disposed meanwhile.
      if (!ref.mounted || generation != _loadGeneration) return;
      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      // Preserve the typed exception (AppException) instead of flattening it.
      if (!ref.mounted || generation != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(error: null);
    await load();
  }

  /// Deletes a budget and refreshes the summary.
  ///
  /// On failure the exception is rethrown (instead of being swallowed into a
  /// `bool` return) so callers like `_handleDelete` can react to the failure
  /// and avoid showing a false "deleted successfully" toast.
  Future<void> deleteBudget(String id) async {
    final service = ref.read(budgetServiceProvider);
    try {
      await service.delete(id);
    } catch (e) {
      state = state.copyWith(error: e);
      rethrow;
    }
    await refresh();
  }
}
