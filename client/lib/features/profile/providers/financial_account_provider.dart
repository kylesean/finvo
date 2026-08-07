import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/profile/services/profile_service.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:logging/logging.dart';

part 'financial_account_provider.freezed.dart';
part 'financial_account_provider.g.dart';

final _logger = Logger('FinancialAccountProvider');

/// Calculate net worth as (assets - liabilities) over active, included accounts.
///
/// Balance source is kept consistent with [FinancialSummaryNotifier]: prefer the
/// server-provided [FinancialAccount.currentBalance] and only fall back to
/// [FinancialAccount.initialBalance] when the current balance is unknown, so the
/// two net-worth views never diverge.
Decimal _netWorthOf(List<FinancialAccount> accounts) {
  return accounts.fold(Decimal.zero, (sum, account) {
    // Only count active accounts included in net worth
    if (account.status == AccountStatus.active && account.includeInNetWorth) {
      final balance = account.currentBalance ?? account.initialBalance;
      if (account.nature == FinancialNature.asset) {
        return sum + balance;
      } else {
        return sum - balance.abs();
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

  // Get actual total balance (priority to server-returned value)
  Decimal get effectiveTotalBalance {
    return totalBalance ?? calculatedNetWorth;
  }
}

// Account state notifier
@riverpod
class FinancialAccountNotifier extends _$FinancialAccountNotifier {
  @override
  FinancialAccountState build() {
    // Pure build: consumers trigger [loadFinancialAccounts] explicitly rather
    // than firing a network side-effect from build().
    return const FinancialAccountState();
  }

  /// Load account data
  Future<void> loadFinancialAccounts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileService = ref.read(profileServiceProvider);
      final response = await profileService.getFinancialAccounts();

      // Safely parse lastUpdatedAt, handle empty string
      DateTime? parsedDate;
      if (response.lastUpdatedAt.isNotEmpty) {
        try {
          parsedDate = DateTime.parse(response.lastUpdatedAt);
        } catch (e) {
          // Malformed timestamp from the server: fall back to now but keep
          // the data issue diagnosable.
          _logger.warning(
            'Unparseable lastUpdatedAt "${response.lastUpdatedAt}"',
            e,
          );
          parsedDate = DateTime.now();
        }
      }

      state = state.copyWith(
        accounts: response.accounts,
        totalBalance: response.totalBalance,
        lastUpdatedAt: parsedDate,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      String errorMessage = 'Failed to load cash sources';
      if (e is AppException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Save account data
  Future<bool> saveFinancialAccounts(List<FinancialAccount> accounts) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileService = ref.read(profileServiceProvider);
      final summary = await profileService.saveFinancialAccounts(accounts);

      // After successful save, use local source list + server returned balance/time
      state = state.copyWith(
        accounts: accounts,
        totalBalance: summary.totalBalance,
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

      state = state.copyWith(isLoading: false, error: errorMessage);

      return false;
    }
  }

  /// Add new account
  void addFinancialAccount(FinancialAccount account) {
    final updatedAccounts = [...state.accounts, account];
    state = state.copyWith(
      accounts: updatedAccounts,
      totalBalance: _netWorthOf(updatedAccounts),
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
      final profileService = ref.read(profileServiceProvider);
      final updatedAccount = await profileService.updateFinancialAccount(
        accountId,
        account,
      );

      // Update local list
      final updatedAccounts = state.accounts.map((a) {
        return a.id == accountId ? updatedAccount : a;
      }).toList();

      state = state.copyWith(
        accounts: updatedAccounts,
        totalBalance: _netWorthOf(updatedAccounts),
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
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
      final profileService = ref.read(profileServiceProvider);
      await profileService.deleteFinancialAccount(accountId);

      // Remove from local list
      final updatedAccounts = state.accounts
          .where((a) => a.id != accountId)
          .toList();

      state = state.copyWith(
        accounts: updatedAccounts,
        totalBalance: _netWorthOf(updatedAccounts),
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Failed to delete account';
      if (e is AppException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }
}
