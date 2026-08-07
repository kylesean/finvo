import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:finvo/features/home/models/daily_expense_summary_model.dart';
import 'package:finvo/features/home/models/total_expense_model.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/home/providers/transaction_feed_state.dart';
export 'package:finvo/features/home/providers/transaction_feed_state.dart';
import 'package:finvo/features/home/services/home_service.dart';
import 'package:finvo/core/events/domain_events.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/features/profile/models/financial_settings.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/i18n/strings.g.dart';

part 'home_providers.g.dart';

enum TransactionFeedType { all, expense, income }

/// Derived provider exposing only the primary currency, so dependents can
/// subscribe narrowly instead of watching the whole settings state.
final primaryCurrencyProvider = Provider<String>((ref) {
  return ref.watch(financialSettingsProvider).primaryCurrency;
});

@riverpod
class CurrentTransactionFeedType extends _$CurrentTransactionFeedType {
  @override
  TransactionFeedType build() => TransactionFeedType.all;

  void set(TransactionFeedType value) => state = value;
}

@riverpod
class CurrentDisplayMonth extends _$CurrentDisplayMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void update(DateTime Function(DateTime state) cb) => state = cb(state);
}

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime? build() => null;

  void set(DateTime? date) => state = date;
}

/// Subscribes the home feature to cross-feature transaction events and
/// invalidates the affected home providers.
///
/// This keeps the dependency direction feature -> core: producers (e.g. the
/// chat feature) only publish [TransactionCreatedEvent]s on the shared bus
/// and never touch home providers directly.
@Riverpod(keepAlive: true)
Future<void> transactionEventSubscriber(Ref ref) async {
  await for (final _ in ref.watch(transactionCreatedEventsProvider).stream) {
    unawaited(ref.read(transactionFeedProvider.notifier).refreshFeed());
    ref.invalidate(totalExpenseProvider);
    final currentMonth = ref.read(currentDisplayMonthProvider);
    ref.invalidate(calendarMonthDataProvider(currentMonth));
  }
}

@riverpod
Future<TotalExpenseData> totalExpense(Ref ref) async {
  final token = ref.watch(authTokenProvider);
  if (token == null) {
    throw UnauthorizedException(t.home.userNotLoggedIn);
  }
  // Subscribe to currency changes (scoped via the derived provider).
  ref.watch(primaryCurrencyProvider);

  final homeService = ref.read(homeServiceProvider);
  return homeService.getTotalExpense();
}

@riverpod
Future<CalendarMonthData> calendarMonthData(Ref ref, DateTime monthYear) async {
  final token = ref.watch(authTokenProvider);
  if (token == null) {
    throw UnauthorizedException(t.home.userNotLoggedIn);
  }
  ref.watch(primaryCurrencyProvider);

  final homeService = ref.read(homeServiceProvider);
  return homeService.getCalendarMonthDetails(monthYear.year, monthYear.month);
}

@riverpod
class TransactionFeed extends _$TransactionFeed {
  final _logger = Logger('TransactionFeed');
  static const int _pageSize = 20;

  /// Monotonic request generation. Incremented on every refresh so that a
  /// slower in-flight [fetchMoreTransactions] response is discarded if a newer
  /// refresh has already replaced the feed (prevents stale page-merge).
  int _generation = 0;

  @override
  TransactionFeedState build() {
    // Listen to feed type changes
    ref.listen<TransactionFeedType>(currentTransactionFeedTypeProvider, (
      previous,
      next,
    ) {
      if (previous != next) {
        ref.read(selectedDateProvider.notifier).set(null);
        unawaited(refreshFeed());
      }
    });

    // Listen to selected date changes
    ref.listen<DateTime?>(selectedDateProvider, (previous, next) {
      if (previous != next) {
        unawaited(refreshFeed());
      }
    });

    // Listen to currency/financial setting changes
    ref.listen<FinancialSettingsState>(financialSettingsProvider, (
      previous,
      next,
    ) {
      if (previous != null &&
          previous.primaryCurrency != next.primaryCurrency) {
        _logger.info(
          'Currency changed from ${previous.primaryCurrency} to ${next.primaryCurrency}, refreshing feed',
        );
        unawaited(refreshFeed());
      }
    });

    // Listen to auth token (NOT watch!) to trigger initial load.
    // Using listen instead of watch prevents build() from re-executing
    // when token changes, which would reset state and cause render conflicts.
    ref.listen<String?>(authTokenProvider, (previous, next) {
      if (next != null && previous == null) {
        unawaited(refreshFeed());
      }
    });

    // If token already exists at creation time (user already logged in),
    // trigger initial load via microtask (safe: build() only runs once now).
    final hasToken = ref.read(authTokenProvider) != null;
    if (hasToken) {
      unawaited(Future.microtask(() => refreshFeed()));
    }

    // build() only runs ONCE (no ref.watch dependencies).
    // Return loading state if token exists so UI shows skeleton immediately.
    return TransactionFeedState(isLoading: hasToken);
  }

  String? _mapFeedTypeToApiString(TransactionFeedType feedType) {
    switch (feedType) {
      case TransactionFeedType.expense:
        return 'expense';
      case TransactionFeedType.income:
        return 'income';
      case TransactionFeedType.all:
        return null;
    }
  }

  Future<void> _fetchInitialTransactions({bool isRefresh = false}) async {
    // Check if provider is still valid
    if (!ref.mounted) {
      _logger.warning('Provider disposed before fetch, aborting');
      return;
    }

    // Bump the generation: any in-flight fetchMore starts a new epoch.
    final generation = ++_generation;

    final currentFeedType = ref.read(currentTransactionFeedTypeProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final apiTypeString = _mapFeedTypeToApiString(currentFeedType);
    final apiDateString = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate)
        : null;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: true,
      currentPage: 1,
      transactions: isRefresh ? [] : state.transactions,
      hasReachedMax: false,
      hasLoadMoreError: false,
      errorMessage: null,
    );

    try {
      final homeService = ref.read(homeServiceProvider);
      final newTransactions = await homeService.getTransactionFeed(
        page: 1,
        type: apiTypeString,
        date: apiDateString,
      );

      // Riverpod 3.0: use ref.mounted to check if provider is still valid
      if (!ref.mounted || generation != _generation) {
        _logger.info(
          'Provider disposed or superseded during fetch, discarding',
        );
        return;
      }

      state = state.copyWith(
        transactions: newTransactions,
        isLoading: false,
        isLoadingMore: false,
        hasReachedMax: newTransactions.length < _pageSize,
        currentPage: 1,
      );
    } catch (e) {
      _logger.severe('Error fetching initial transaction feed', e);

      // Check if provider is still valid
      if (!ref.mounted || generation != _generation) return;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasReachedMax: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> fetchMoreTransactions() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    // Riverpod 3.0: use ref.mounted to check if provider is still valid
    if (!ref.mounted) return;

    // Capture the current generation; discard the response if a refresh bumps it.
    final generation = _generation;

    final currentFeedType = ref.read(currentTransactionFeedTypeProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final apiTypeString = _mapFeedTypeToApiString(currentFeedType);
    final apiDateString = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate)
        : null;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    final nextPage = state.currentPage + 1;
    try {
      final homeService = ref.read(homeServiceProvider);
      final newTransactions = await homeService.getTransactionFeed(
        page: nextPage,
        type: apiTypeString,
        date: apiDateString,
      );

      // Check again after async operation
      if (!ref.mounted || generation != _generation) return;

      if (newTransactions.isEmpty) {
        state = state.copyWith(
          hasReachedMax: true,
          isLoadingMore: false,
          hasLoadMoreError: false,
        );
      } else {
        state = state.copyWith(
          transactions: [...state.transactions, ...newTransactions],
          isLoadingMore: false,
          currentPage: nextPage,
          hasReachedMax: newTransactions.length < _pageSize,
          hasLoadMoreError: false,
        );
      }
    } catch (e) {
      _logger.severe('Error fetching more transactions', e);

      if (!ref.mounted) return;

      // Never mark hasReachedMax on an error: a transient network failure is
      // not "end of data". Surface the failure via hasLoadMoreError so the
      // feed footer can offer a retry instead of a dead "no more data" state.
      state = state.copyWith(
        isLoadingMore: false,
        hasLoadMoreError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshFeed() async {
    await _fetchInitialTransactions(isRefresh: true);
  }

  Future<bool> deleteTransaction(String transactionId) async {
    final transactionIndex = state.transactions.indexWhere(
      (t) => t.id == transactionId,
    );
    if (transactionIndex == -1) return false;

    final deletedTransaction = state.transactions[transactionIndex];
    final updatedList = List<TransactionModel>.from(state.transactions);
    updatedList.removeAt(transactionIndex);
    state = state.copyWith(transactions: updatedList);

    try {
      final homeService = ref.read(homeServiceProvider);
      await homeService.deleteTransaction(transactionId);
      // Invalidate derived data so the total-expense and calendar views no
      // longer reflect the just-deleted transaction (previously only the feed
      // list was updated, leaving stale totals/calendar entries behind).
      ref.invalidate(totalExpenseProvider);
      final currentMonth = ref.read(currentDisplayMonthProvider);
      ref.invalidate(calendarMonthDataProvider(currentMonth));
      return true;
    } catch (e) {
      // Race-safe rollback: while the delete request was in flight, a
      // concurrent refresh (WS-driven refreshFeed, fetchMore) may have
      // rewritten state.transactions, so blindly inserting at the captured
      // pre-delete index could land out of bounds or in the wrong slot.
      // Recompute the insertion point from list order (timestamp desc,
      // matching the server feed ordering) and clamp it as a final guard.
      if (!ref.mounted) return false;
      final current = List<TransactionModel>.from(state.transactions);
      if (!current.any((t) => t.id == deletedTransaction.id)) {
        int insertAt = current.indexWhere(
          (t) =>
              t.timestamp.isBefore(deletedTransaction.timestamp) ||
              t.timestamp.isAtSameMomentAs(deletedTransaction.timestamp),
        );
        if (insertAt == -1) insertAt = current.length;
        insertAt = insertAt.clamp(0, current.length);
        current.insert(insertAt, deletedTransaction);
        state = state.copyWith(transactions: current);
      }
      return false;
    }
  }
}
