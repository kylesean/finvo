import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/chat/genui/organisms/account_picker_card.dart';
import 'package:finvo/features/home/services/home_service.dart';
import 'package:finvo/features/home/providers/transaction_detail_provider.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Linked account & shared-space actions shown inside the transaction detail
/// card.
///
/// M-28: extracted from `TransactionDetailPage` so the page stays focused on
/// reading the transaction while this widget owns the account/space linking UI
/// and its mutation flows (picker sheets, update/link calls).
class TransactionLinkSection extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionLinkSection({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;

    // System-generated transactions (account close disposal entries) are the
    // ledger's audit trail: account/space linking would silently undo the
    // balance disposal, so no linking UI is offered for them.
    if (transaction.source == 'SYSTEM') {
      return _buildReadOnlyBadge(theme, colors);
    }

    // The account a transaction "is linked to" mirrors the server: INCOME
    // links the receiving (target) account, everything else (EXPENSE,
    // TRANSFER, ...) links the paying/from (source) account. TRANSFER must
    // NOT show the target here — the server updates the source side for
    // transfers, and showing the other end would mislead the user about
    // which account is being re-associated.
    final isIncome = transaction.type == TransactionType.income;
    final accountId = isIncome
        ? transaction.targetAccountId
        : transaction.sourceAccountId;
    final accountState = ref.watch(financialAccountProvider);
    final linkedAccount = accountId != null
        ? accountState.accounts.where((a) => a.id == accountId).firstOrNull
        : null;

    // Linked space info
    final spaces = transaction.spaces;
    final hasSpaces = spaces.isNotEmpty;

    return Row(
      children: [
        // Linked account button
        Expanded(
          child: _buildActionPill(
            context: context,
            theme: theme,
            colors: colors,
            icon: linkedAccount != null
                ? FLucideIcons.wallet
                : FLucideIcons.link,
            label: linkedAccount?.name ?? t.transaction.linkedAccount,
            isActive: linkedAccount != null,
            activeColor: colors.primary,
            onTap: () => _showAccountPicker(context, ref, transaction),
          ),
        ),
        const SizedBox(width: 8),
        // Linked space button
        Expanded(
          child: _buildActionPill(
            context: context,
            theme: theme,
            colors: colors,
            icon: hasSpaces ? FLucideIcons.users : FLucideIcons.plus,
            label: hasSpaces
                ? t.transaction.nSpaces(count: spaces.length.toString())
                : t.transaction.linkedSpace,
            isActive: hasSpaces,
            activeColor: theme.semantic.sharedSpaceAccent,
            onTap: () => _showSpacePicker(context, ref, transaction),
          ),
        ),
      ],
    );
  }

  /// Read-only badge shown for system-generated (lifecycle audit) entries.
  Widget _buildReadOnlyBadge(FThemeData theme, FColors colors) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: colors.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FLucideIcons.shieldCheck,
                  size: 14,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    t.transaction.systemGenerated,
                    style: AppTextStyles.sectionHeader(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Pill button style
  Widget _buildActionPill({
    required BuildContext context,
    required FThemeData theme,
    required FColors colors,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : colors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : colors.mutedForeground,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.sectionHeader(theme),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show account picker bottom sheet
  Future<void> _showAccountPicker(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) async {
    final theme = context.theme;
    final colors = theme.colors;

    // Load account list
    var accountState = ref.read(financialAccountProvider);
    if (accountState.accounts.isEmpty && !accountState.isLoading) {
      await ref.read(financialAccountProvider.notifier).loadFinancialAccounts();
      if (!context.mounted) return;
      accountState = ref.read(financialAccountProvider);
    }

    // Filter available accounts
    final accounts = accountState.accounts
        .where(
          (a) =>
              a.status == AccountStatus.active &&
              a.nature == FinancialNature.asset,
        )
        .map(
          (a) => <String, dynamic>{
            'id': a.id,
            'name': a.name,
            'type': a.type?.name ?? 'unknown',
            'balance': a.currentBalance,
            'currencyCode': a.currencyCode,
          },
        )
        .toList();

    if (accounts.isEmpty) {
      if (!context.mounted) return;
      ToastService.show(
        description: Text(t.chat.genui.transactionCard.noAccount),
      );
      return;
    }

    // Get the currently linked account ID (mirrors the server-side side
    // convention: INCOME -> target, everything else -> source).
    final isIncome = transaction.type == TransactionType.income;
    final currentAccountId = isIncome
        ? transaction.targetAccountId
        : transaction.sourceAccountId;

    if (!context.mounted) return;

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: AccountPickerCard(
          accounts: accounts,
          selectedId: currentAccountId,
          title: t.transaction.selectLinkedAccount,
          transactionCurrency: transaction.currency ?? 'CNY',
          onSelect: (id) => Navigator.pop(context, id),
          onConfirm: () {},
        ),
      ),
    );

    if (selectedId != null && context.mounted) {
      await _updateTransactionAccount(context, ref, transaction.id, selectedId);
    }
  }

  /// Update transaction linked account
  Future<void> _updateTransactionAccount(
    BuildContext context,
    WidgetRef ref,
    String transactionId,
    String accountId,
  ) async {
    try {
      final homeService = ref.read(homeServiceProvider);
      await homeService.updateTransactionAccount(transactionId, accountId);

      if (context.mounted) {
        // Reload transaction detail
        unawaited(
          ref.read(transactionDetailProvider(transactionId).notifier).reload(),
        );
        // Refresh account list to update balances
        unawaited(
          ref.read(financialAccountProvider.notifier).loadFinancialAccounts(),
        );
        ToastService.success(description: Text(t.transaction.linkSuccess));
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showDestructive(
          description: Text(t.transaction.linkFailed),
        );
      }
    }
  }

  /// Show space picker bottom sheet
  Future<void> _showSpacePicker(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) async {
    final theme = context.theme;
    final colors = theme.colors;

    try {
      // Load space list
      final homeService = ref.read(homeServiceProvider);
      final result = await homeService.listSharedSpaces();

      if (!context.mounted) return;

      final spaces = result;

      if (spaces.isEmpty) {
        ToastService.show(description: Text(t.transaction.noSpacesAvailable));
        return;
      }

      // Get currently linked space IDs
      final currentSpaceIds = transaction.spaces.map((s) => s.id).toSet();

      final selectedSpaceId = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.transaction.selectLinkedSpace,
                style: AppTextStyles.listTitle(theme),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: spaces.length,
                  itemBuilder: (context, index) {
                    final space = spaces[index];
                    final spaceId = space['id']?.toString();
                    final isSelected = currentSpaceIds.contains(spaceId);
                    return ListTile(
                      leading: Icon(
                        FLucideIcons.users,
                        color: isSelected
                            ? colors.primary
                            : colors.mutedForeground,
                      ),
                      title: Text((space['name'] as String?) ?? ''),
                      trailing: isSelected
                          ? Icon(FLucideIcons.check, color: colors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, spaceId),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

      if (selectedSpaceId != null && context.mounted) {
        await _linkTransactionToSpace(
          context,
          ref,
          transaction.id,
          selectedSpaceId,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showDestructive(
          description: Text(t.transaction.linkFailed),
        );
      }
    }
  }

  /// Link transaction to space
  Future<void> _linkTransactionToSpace(
    BuildContext context,
    WidgetRef ref,
    String transactionId,
    String spaceId,
  ) async {
    try {
      final homeService = ref.read(homeServiceProvider);
      await homeService.linkTransactionToSpace(transactionId, spaceId);

      if (context.mounted) {
        // Reload transaction detail
        unawaited(
          ref.read(transactionDetailProvider(transactionId).notifier).reload(),
        );
        ToastService.success(description: Text(t.transaction.linkSuccess));
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showDestructive(
          description: Text(t.transaction.linkFailed),
        );
      }
    }
  }
}
