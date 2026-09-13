import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';
import 'package:finvo/shared/providers/financial_settings_provider.dart';
import 'package:finvo/shared/providers/generation_guard.dart';
import 'package:finvo/shared/services/financial_account_service.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:logging/logging.dart';
import 'package:finvo/i18n/strings.g.dart';

part 'financial_account_provider.freezed.dart';
part 'financial_account_provider.g.dart';

final _logger = Logger('FinancialAccountProvider');

/// Calculate net worth as (assets - liabilities) over active, included accounts.
///
/// Converts foreign currency balances to [targetCurrency] via [exchangeRateNotifier]
/// when provided, preventing multi-currency accounts from being summed 1:1.
///
/// Balance source is kept consistent with [FinancialSummaryNotifier]: prefer the
/// server-provided [FinancialAccount.currentBalance] and only fall back to
/// [FinancialAccount.initialBalance] when the current balance is unknown, so the
/// two net-worth views never diverge.
Decimal _netWorthOf(
  List<FinancialAccount> accounts, {
  ExchangeRate? exchangeRateNotifier,
  String? targetCurrency,
}) {
  return accounts.fold(Decimal.zero, (sum, account) {
    // Only count active accounts included in net worth
    if (account.status == AccountStatus.active && account.includeInNetWorth) {
      final balance = account.currentBalance ?? account.initialBalance;
      final accountCurrency = account.currencyCode.toUpperCase();
      final normalizedTarget = targetCurrency?.toUpperCase();

      Decimal converted = balance;

      if (normalizedTarget != null && accountCurrency != normalizedTarget) {
        if (exchangeRateNotifier != null) {
          final rateConverted = exchangeRateNotifier.convert(
            balance,
            accountCurrency,
            normalizedTarget,
          );
          if (rateConverted != null) {
            converted = rateConverted;
          } else {
            _logger.warning(
              'Missing exchange rate to convert $accountCurrency to $normalizedTarget '
              'for account "${account.name}". Skipping account from net worth to prevent multi-currency pollution.',
            );
            return sum;
          }
        } else {
          _logger.warning(
            'Exchange rates unavailable to convert $accountCurrency to $normalizedTarget '
            'for account "${account.name}". Skipping account from net worth to prevent multi-currency pollution.',
          );
          return sum;
        }
      }

      if (account.nature == FinancialNature.asset) {
        return sum + converted;
      } else {
        return sum - converted.abs();
      }
    }
    return sum;
  });
}

// Account state
@freezed
abstract class FinancialAccountState with _$FinancialAccountState {
  const factory FinancialAccountState({
    @Default([]) List<FinancialAccount> accounts,
    Decimal? totalBalance,
    DateTime? lastUpdatedAt,
    @Default(false) bool isLoading,
    String? error,
  }) = _FinancialAccountState;

  const FinancialAccountState._();

  // Calculate account net worth (Assets - Liabilities)
  Decimal get calculatedNetWorth => _netWorthOf(accounts);

  /// Calculate account net worth in [targetCurrency] using [exchangeRateNotifier].
  Decimal calculateNetWorth({
    ExchangeRate? exchangeRateNotifier,
    String? targetCurrency,
  }) {
    return _netWorthOf(
      accounts,
      exchangeRateNotifier: exchangeRateNotifier,
      targetCurrency: targetCurrency,
    );
  }

  // Get actual total balance (priority to server-returned value)
  Decimal get effectiveTotalBalance {
    return totalBalance ?? calculatedNetWorth;
  }
}

// Account state notifier
@Riverpod(keepAlive: true)
class FinancialAccountNotifier extends _$FinancialAccountNotifier {
  /// Monotonic generation: a stale in-flight response is discarded when a
  /// newer load has superseded it (and writes after dispose are skipped).
  final GenerationGuard _loadGeneration = GenerationGuard();

  /// Compute net worth in user's primary currency using exchange rates.
  Decimal _computeNetWorth(List<FinancialAccount> accounts) {
    try {
      final targetCurrency = ref
          .read(financialSettingsProvider)
          .primaryCurrency;
      final ratesAsync = ref.read(exchangeRateProvider);
      final exchangeRateNotifier = ref.read(exchangeRateProvider.notifier);

      return _netWorthOf(
        accounts,
        exchangeRateNotifier: ratesAsync.hasValue ? exchangeRateNotifier : null,
        targetCurrency: targetCurrency,
      );
    } catch (e) {
      _logger.warning('Failed to compute multi-currency net worth: $e');
      return _netWorthOf(accounts);
    }
  }

  @override
  FinancialAccountState build() {
    // Recompute totalBalance when exchange rates are loaded or updated
    ref.listen(exchangeRateProvider, (prev, next) {
      if (next.hasValue && state.accounts.isNotEmpty) {
        final primaryCurrency = ref
            .read(financialSettingsProvider)
            .primaryCurrency;
        final hasForeignCurrency = state.accounts.any(
          (a) =>
              a.status == AccountStatus.active &&
              a.includeInNetWorth &&
              a.currencyCode.toUpperCase() != primaryCurrency.toUpperCase(),
        );
        if (hasForeignCurrency) {
          state = state.copyWith(
            totalBalance: _computeNetWorth(state.accounts),
          );
        }
      }
    });

    // Recompute totalBalance when user changes primary currency in settings
    ref.listen(financialSettingsProvider, (prev, next) {
      if (prev?.primaryCurrency != next.primaryCurrency &&
          state.accounts.isNotEmpty) {
        state = state.copyWith(totalBalance: _computeNetWorth(state.accounts));
      }
    });

    return const FinancialAccountState();
  }

  /// Load account data
  Future<void> loadFinancialAccounts() async {
    final generation = _loadGeneration.bump();
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(financialAccountServiceProvider);
      final response = await service.getFinancialAccounts();

      // Safely parse lastUpdatedAt, handle empty string
      DateTime? parsedDate;
      if (response.lastUpdatedAt.isNotEmpty) {
        try {
          parsedDate = tryParseDateTime(response.lastUpdatedAt);
        } catch (e) {
          // Malformed timestamp from the server: fall back to now but keep
          // the data issue diagnosable.
          _logger.warning(
            'Unparseable lastUpdatedAt "${response.lastUpdatedAt}"',
            e,
          );
          parsedDate = DateTime.now();
        }
      } else {
        parsedDate = DateTime.now();
      }
      parsedDate ??= DateTime.now();

      if (!ref.mounted || !_loadGeneration.isCurrent(generation)) return;

      final primaryCurrency = ref
          .read(financialSettingsProvider)
          .primaryCurrency;
      final hasForeignCurrency = response.accounts.any(
        (a) =>
            a.status == AccountStatus.active &&
            a.includeInNetWorth &&
            a.currencyCode.toUpperCase() != primaryCurrency.toUpperCase(),
      );

      final effectiveBalance =
          (hasForeignCurrency && ref.read(exchangeRateProvider).hasValue)
          ? _computeNetWorth(response.accounts)
          : response.totalBalance;

      state = state.copyWith(
        accounts: response.accounts,
        totalBalance: effectiveBalance,
        lastUpdatedAt: parsedDate,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      String errorMessage = t.common.loadFailed;
      if (e is AppException) {
        errorMessage = e.message;
      }

      if (!ref.mounted || !_loadGeneration.isCurrent(generation)) return;
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Save account data
  Future<bool> saveFinancialAccounts(List<FinancialAccount> accounts) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(financialAccountServiceProvider);
      final summary = await service.saveFinancialAccounts(accounts);

      // After successful save, use local source list + server returned balance/time
      if (!ref.mounted) return false;

      final primaryCurrency = ref
          .read(financialSettingsProvider)
          .primaryCurrency;
      final hasForeignCurrency = accounts.any(
        (a) =>
            a.status == AccountStatus.active &&
            a.includeInNetWorth &&
            a.currencyCode.toUpperCase() != primaryCurrency.toUpperCase(),
      );

      final effectiveBalance =
          (hasForeignCurrency && ref.read(exchangeRateProvider).hasValue)
          ? _computeNetWorth(accounts)
          : summary.totalBalance;

      state = state.copyWith(
        accounts: accounts,
        totalBalance: effectiveBalance,
        lastUpdatedAt: summary.lastUpdatedAt,
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Failed to save cash sources';
      if (e is AppException) {
        errorMessage = e.message;
      }

      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, error: errorMessage);

      return false;
    }
  }

  /// Create a single account server-side and append it to local state.
  ///
  /// Deliberately avoids routing through the bulk [saveFinancialAccounts]
  /// overwrite: submitting the whole local list from a minutes-old snapshot
  /// would clobber concurrent server-side changes.
  Future<bool> createFinancialAccount(FinancialAccount account) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(financialAccountServiceProvider);
      final created = await service.createFinancialAccount(account);

      if (!ref.mounted) return false;

      state = state.copyWith(
        accounts: [...state.accounts, created],
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Failed to save cash sources';
      if (e is AppException) {
        errorMessage = e.message;
      }

      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, error: errorMessage);

      return false;
    }
  }

  /// Add new account
  void addFinancialAccount(FinancialAccount account) {
    final updatedAccounts = [...state.accounts, account];
    state = state.copyWith(
      accounts: updatedAccounts,
      totalBalance: _computeNetWorth(updatedAccounts),
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update single account
  Future<bool> updateFinancialAccount(
    String accountId,
    FinancialAccount account,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(financialAccountServiceProvider);
      final updatedAccount = await service.updateFinancialAccount(
        accountId,
        account,
      );

      // Update local list
      if (!ref.mounted) return false;
      final updatedAccounts = state.accounts.map((a) {
        return a.id == accountId ? updatedAccount : a;
      }).toList();

      state = state.copyWith(
        accounts: updatedAccounts,
        totalBalance: _computeNetWorth(updatedAccounts),
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      // The success branch checks ref.mounted; the failure branch
      // must too, or a write-back after the autoDispose provider was
      // disposed triggers a Riverpod assertion.
      if (!ref.mounted) return false;
      String errorMessage = 'Failed to update account';
      if (e is AppException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  /// Delete single account
  Future<bool> deleteFinancialAccount(String accountId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(financialAccountServiceProvider);
      await service.deleteFinancialAccount(accountId);

      // Remove from local list
      if (!ref.mounted) return false;
      final updatedAccounts = state.accounts
          .where((a) => a.id != accountId)
          .toList();

      state = state.copyWith(
        accounts: updatedAccounts,
        totalBalance: _computeNetWorth(updatedAccounts),
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Failed to delete account';
      if (e is AppException) {
        errorMessage = e.message;
      }

      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  /// Merge [sourceId] into [targetId] (correction for wrong/duplicate
  /// accounts), then reload the authoritative list from the server.
  Future<bool> mergeFinancialAccounts(String sourceId, String targetId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(financialAccountServiceProvider);
      await service.mergeFinancialAccounts(sourceId, targetId);

      await loadFinancialAccounts();
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      String errorMessage = 'Failed to merge accounts';
      if (e is AppException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  /// Close (archive) an account, then reload the authoritative list.
  Future<bool> closeFinancialAccount(
    String accountId,
    String disposal, {
    String? targetAccountId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(financialAccountServiceProvider);
      await service.closeFinancialAccount(
        accountId,
        disposal: disposal,
        targetAccountId: targetAccountId,
      );

      await loadFinancialAccounts();
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      String errorMessage = 'Failed to close account';
      if (e is AppException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }
}
