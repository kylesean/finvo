import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'dart:async';

import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Account selection result
class AccountSelectionResult {
  final String accountId;
  final String accountName;

  const AccountSelectionResult({
    required this.accountId,
    required this.accountName,
  });
}

/// Account selection bottom sheet - based on financial accounts page list design
class AccountSelectionSheet extends ConsumerStatefulWidget {
  final String title;
  final String? selectedAccountId;

  /// Optional filter for the account list. Defaults to asset-only accounts
  /// (legacy behaviour for recurring-transaction selection); lifecycle flows
  /// (merge target, close transfer target) pass their own predicate.
  final bool Function(FinancialAccount account)? filter;

  /// Optional empty-state message. Only used when [filter] is provided; the
  /// legacy asset-only flow keeps its original two-line empty hint.
  final String? emptyMessage;

  const AccountSelectionSheet({
    super.key,
    required this.title,
    this.selectedAccountId,
    this.filter,
    this.emptyMessage,
  });

  /// Show sheet
  static Future<AccountSelectionResult?> show(
    BuildContext context, {
    required String title,
    String? selectedAccountId,
    bool Function(FinancialAccount account)? filter,
    String? emptyMessage,
  }) {
    return showModalBottomSheet<AccountSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountSelectionSheet(
        title: title,
        selectedAccountId: selectedAccountId,
        filter: filter,
        emptyMessage: emptyMessage,
      ),
    );
  }

  @override
  ConsumerState<AccountSelectionSheet> createState() =>
      _AccountSelectionSheetState();
}

class _AccountSelectionSheetState extends ConsumerState<AccountSelectionSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(financialAccountProvider.notifier).loadFinancialAccounts(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final accountState = ref.watch(financialAccountProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title bar
            _buildHeader(theme, colors),
            const SizedBox(height: 16),
            // Account list
            Expanded(
              child: accountState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : accountState.error != null
                  ? Center(
                      child: Text(
                        '${t.common.loadFailed}: ${accountState.error}',
                      ),
                    )
                  : _buildAccountList(theme, colors, accountState.accounts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FThemeData theme, FColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              t.common.cancel,
              style: theme.typography.body.md.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.listTitle(theme),
            ),
          ),
          const SizedBox(width: 48), // Balance cancel button
        ],
      ),
    );
  }

  Widget _buildAccountList(
    FThemeData theme,
    FColors colors,
    List<FinancialAccount> accounts,
  ) {
    // Default: only asset accounts that are still ACTIVE — a CLOSED account
    // must not be selectable for new transactions / recurring rules (its
    // history is preserved, but it no longer accepts new activity). Lifecycle
    // flows (merge/close targets) inject their own filter.
    final accountsToShow = accounts
        .where(
          widget.filter ??
              (account) =>
                  account.nature == FinancialNature.asset &&
                  account.status == AccountStatus.active,
        )
        .toList();

    if (accountsToShow.isEmpty) {
      // Custom-filtered empty state shows a single message; the legacy
      // asset-only flow keeps its original two-line hint.
      if (widget.emptyMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemedIcon.large(
                  icon: FLucideIcons.wallet,
                  backgroundColor: colors.secondary,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.emptyMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.listSubtitle(theme),
                ),
              ],
            ),
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemedIcon.large(
              icon: FLucideIcons.wallet,
              backgroundColor: colors.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              t.forecast.recurringTransaction.noAssetAccounts,
              style: AppTextStyles.listSubtitle(theme),
            ),
            const SizedBox(height: 8),
            Text(
              t.forecast.recurringTransaction.goToFinanceToAddAccounts,
              style: theme.typography.body.xs.copyWith(
                color: colors.mutedForeground.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSectionHeader(
          theme,
          colors,
          t.forecast.recurringTransaction.selectAccount,
        ),
        ...accountsToShow.map(
          (account) => _buildAccountCard(theme, colors, account),
        ),
        const SizedBox(height: 24), // Bottom spacing
      ],
    );
  }

  Widget _buildSectionHeader(FThemeData theme, FColors colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: AppTextStyles.sectionHeader(theme)),
    );
  }

  /// Account card - based on FinancialAccountsPage design
  Widget _buildAccountCard(
    FThemeData theme,
    FColors colors,
    FinancialAccount account,
  ) {
    final definition = AccountTypeRegistry.resolveByApiType(account.type);
    final isLiabilityAccount = account.nature == FinancialNature.liability;
    final isSelected = account.id == widget.selectedAccountId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(
                AccountSelectionResult(
                  accountId: account.id ?? '',
                  accountName: account.name,
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.primary, width: 2),
                    )
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  // Icon - using unified design token
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: definition != null
                          ? definition.iconBuilder(colors.foreground)
                          : Icon(
                              isLiabilityAccount
                                  ? FLucideIcons.creditCard
                                  : FLucideIcons.wallet,
                              color: colors.foreground,
                              size: 18,
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: AppTextStyles.listTitle(theme),
                        ),
                        Text(
                          definition != null
                              ? _getTypeDisplayName(definition)
                              : (isLiabilityAccount
                                    ? t
                                          .forecast
                                          .recurringTransaction
                                          .liabilityAccount
                                    : t
                                          .forecast
                                          .recurringTransaction
                                          .assetAccount),
                          style: AppTextStyles.listSubtitle(theme),
                        ),
                      ],
                    ),
                  ),

                  // Balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isLiabilityAccount ? '-' : ''}${_formatAmount(account.currentBalance ?? account.initialBalance)}',
                        style: AppTextStyles.listTitle(theme).copyWith(
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        account.currencyCode,
                        style: AppTextStyles.listSubtitle(theme),
                      ),
                    ],
                  ),

                  // Selection indicator
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Icon(FLucideIcons.check, color: colors.primary, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(Decimal amount) {
    final value = double.tryParse(amount.toString()) ?? 0.0;
    return AmountFormatter.getNumberFormat('CNY').format(value);
  }

  String _getTypeDisplayName(AccountTypeDefinition definition) {
    final rt = t.forecast.recurringTransaction;
    switch (definition.id) {
      case 'cash':
        return rt.accountTypeCash;
      case 'deposit':
        return rt.accountTypeDeposit;
      case 'e_money':
        return rt.accountTypeEMoney;
      case 'investment':
        return rt.accountTypeInvestment;
      case 'receivable':
        return rt.accountTypeReceivable;
      case 'credit_card':
        return rt.accountTypeCreditCard;
      case 'loan':
        return rt.accountTypeLoan;
      case 'payable':
        return rt.accountTypePayable;
      default:
        return definition.title;
    }
  }
}
