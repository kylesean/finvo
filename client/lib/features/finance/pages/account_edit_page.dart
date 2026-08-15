import 'package:decimal/decimal.dart';
import 'package:finvo/shared/models/action_item_model.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:finvo/shared/widgets/dialogs/action_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'dart:async';

import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/features/finance/widgets/account_selection_sheet.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/finance/widgets/account_form_widgets.dart';
import 'package:finvo/features/finance/widgets/currency_selection_sheet.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:finvo/i18n/strings.g.dart';

class FinancialAccountEditArgs {
  const FinancialAccountEditArgs({
    required this.definition,
    required this.account,
  });

  final AccountTypeDefinition definition;
  final FinancialAccount account;
}

/// Edit account page - compact layout design
class FinancialAccountEditPage extends ConsumerStatefulWidget {
  const FinancialAccountEditPage({super.key, required this.args});

  final FinancialAccountEditArgs args;

  @override
  ConsumerState<FinancialAccountEditPage> createState() =>
      _FinancialAccountEditPageState();
}

class _FinancialAccountEditPageState
    extends ConsumerState<FinancialAccountEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  // Store the raw code so an unknown currency is preserved (and re-saved)
  // instead of being silently coerced to CNY, which would destroy the
  // account's original currency on edit.
  late String _currencyCode;
  bool _hidden = false;
  bool _includeInAssets = true;

  Currency? get _currency => Currency.fromCode(_currencyCode);
  String get _currencySymbol => _currency?.symbol ?? _currencyCode;
  String get _currencyLabel =>
      '$_currencyCode - ${_currency?.localizedName ?? _currencyCode}';

  @override
  void initState() {
    super.initState();
    final account = widget.args.account;
    _nameController = TextEditingController(text: account.name);
    _balanceController = TextEditingController(
      text: formatAccountAmount(
        account.currentBalance ?? account.initialBalance,
      ),
    );
    _currencyCode = account.currencyCode;
    _hidden = account.status == AccountStatus.inactive;
    _includeInAssets = account.includeInNetWorth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final definition = widget.args.definition;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset:
          false, // Preventing the keyboard from lifting the layout
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: FButton.icon(
          variant: .ghost,
          onPress: () => context.pop(),
          child: Icon(
            FLucideIcons.chevronLeft,
            color: colors.foreground,
            size: 20,
          ),
        ),
        titleSpacing: 0,
        centerTitle: true,
        title: Text(t.account.editTitle, style: AppTextStyles.pageTitle(theme)),
        actions: [
          FButton.icon(
            variant: .ghost,
            onPress: _showManageActions,
            child: Icon(
              FLucideIcons.moreHorizontal,
              size: 20,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: _buildFormCard(theme, colors, definition),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildAccountSaveButton(
        theme,
        colors,
        onSave: _handleSave,
      ),
    );
  }

  /// Unified form card
  Widget _buildFormCard(
    FThemeData theme,
    FColors colors,
    AccountTypeDefinition definition,
  ) {
    return buildAccountFormCard(
      theme: theme,
      colors: colors,
      definition: definition,
      nameController: _nameController,
      nameHint: t.account.nameHint,
      balanceController: _balanceController,
      currencySymbol: _currencySymbol,
      currencyLabel: _currencyLabel,
      onOpenCurrencyPicker: _openCurrencyPicker,
      hidden: _hidden,
      onHiddenChanged: (value) => setState(() => _hidden = value),
      includeInNetWorth: _includeInAssets,
      onIncludeInNetWorthChanged: (value) =>
          setState(() => _includeInAssets = value),
    );
  }

  Future<void> _openCurrencyPicker() async {
    final result = await CurrencySelectionSheet.show(context, _currencyCode);
    if (!mounted || result == null) return;
    setState(() {
      _currencyCode = result;
    });
  }

  /// Account lifecycle menu — intent decides the operation:
  /// merge (wrong/duplicate account), close (real-life account termination),
  /// or delete (only empty accounts; the server enforces this).
  void _showManageActions() {
    final account = widget.args.account;
    final isClosed = account.status == AccountStatus.closed;
    final primaryActions = <ActionItem>[
      // A closed (archived) account can be explicitly reopened — reopening is
      // the user's decision, never a side effect of editing its fields.
      if (isClosed)
        ActionItem(
          title: t.account.reopenAccount,
          icon: FLucideIcons.rotateCcw,
          onTap: _handleReopen,
        ),
      ActionItem(
        title: t.account.mergeToOther,
        icon: FLucideIcons.gitMerge,
        onTap: _handleMerge,
      ),
      if (!isClosed)
        ActionItem(
          title: t.account.closeAccount,
          icon: FLucideIcons.archive,
          onTap: _handleClose,
        ),
    ];
    final destructiveActions = <ActionItem>[
      ActionItem(
        title: t.account.deleteAccount,
        icon: FLucideIcons.trash2,
        isDestructive: true,
        onTap: _handleDelete,
      ),
    ];

    final rootContext = GoRouter.of(
      context,
    ).routerDelegate.navigatorKey.currentContext;
    if (rootContext == null) return;

    unawaited(
      showModalBottomSheet<void>(
        context: rootContext,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) {
          return ActionBottomSheet(
            actions: primaryActions,
            destructiveActions: destructiveActions,
          );
        },
      ),
    );
  }

  /// Explicitly reopen a closed (archived) account. The status change goes
  /// through the PATCH endpoint (setting CLOSED is rejected there, but going
  /// back to ACTIVE is a legitimate, deliberate user action).
  Future<void> _handleReopen() async {
    final account = widget.args.account;
    final accountId = account.id;
    if (accountId == null) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: t.account.reopenAccount,
      message: t.account.reopenConfirm,
      cancelLabel: t.common.cancel,
      confirmLabel: t.account.reopenAccount,
    );
    if (!confirmed || !mounted) return;

    final reopened = account.copyWith(status: AccountStatus.active);
    final success = await ref
        .read(financialAccountProvider.notifier)
        .updateFinancialAccount(accountId, reopened);

    if (!mounted) return;
    if (!success) {
      final err = ref.read(financialAccountProvider).error;
      TopToast.error(context, err ?? t.financial.saveFailed);
      return;
    }

    TopToast.success(context, t.account.reopenSuccess);
    context.pop();
  }

  /// Merge this account into another one (correction path for wrong/duplicate
  /// accounts). The server re-points transactions/rules, recomputes the target
  /// balance and deletes the source; no new record is created.
  Future<void> _handleMerge() async {
    final account = widget.args.account;
    final accountId = account.id;
    if (accountId == null) return;

    final targetId = await _pickAccountTarget(
      title: t.account.mergeTargetTitle,
      sameNature: true,
    );
    if (targetId == null || !mounted) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: t.account.mergeTitle,
      message: t.account.mergeMessage(name: account.name),
      cancelLabel: t.common.cancel,
      confirmLabel: t.account.mergeTitle,
    );
    if (!confirmed || !mounted) return;

    final success = await ref
        .read(financialAccountProvider.notifier)
        .mergeFinancialAccounts(accountId, targetId);

    if (!mounted) return;
    if (!success) {
      final err = ref.read(financialAccountProvider).error;
      TopToast.error(context, err ?? t.financial.saveFailed);
      return;
    }

    TopToast.success(context, t.account.mergedSuccess);
    context.pop();
  }

  /// Close (archive) this account, keeping its full transaction history. A
  /// non-zero balance must be disposed of first (keep snapshot / transfer /
  /// write off).
  Future<void> _handleClose() async {
    final account = widget.args.account;
    final accountId = account.id;
    if (accountId == null) return;

    var disposal = 'keep';
    String? targetAccountId;

    final balance = account.currentBalance ?? account.initialBalance;
    if (balance != Decimal.zero) {
      final choice = await _pickCloseDisposal(balance);
      if (choice == null || !mounted) return;
      disposal = choice;

      if (disposal == 'transfer') {
        final targetId = await _pickAccountTarget(
          title: t.account.transferTargetTitle,
          sameNature: false,
        );
        if (targetId == null || !mounted) return;
        targetAccountId = targetId;
      }
    }

    if (!mounted) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: t.account.closeTitle,
      message: t.account.closeMessage,
      cancelLabel: t.common.cancel,
      confirmLabel: t.account.closeAccount,
    );
    if (!confirmed || !mounted) return;

    final success = await ref
        .read(financialAccountProvider.notifier)
        .closeFinancialAccount(
          accountId,
          disposal,
          targetAccountId: targetAccountId,
        );

    if (!mounted) return;
    if (!success) {
      final err = ref.read(financialAccountProvider).error;
      TopToast.error(context, err ?? t.financial.saveFailed);
      return;
    }

    TopToast.success(context, t.account.closedSuccess);
    context.pop();
  }

  /// Physical delete — only valid for accounts without transactions and
  /// without a balance. The server rejects everything else with guidance.
  Future<void> _handleDelete() async {
    final account = widget.args.account;
    final accountId = account.id;
    if (accountId == null) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: t.account.deleteAccount,
      message: t.account.deleteConfirm,
      cancelLabel: t.common.cancel,
      confirmLabel: t.common.delete,
    );
    if (!confirmed || !mounted) return;

    final success = await ref
        .read(financialAccountProvider.notifier)
        .deleteFinancialAccount(accountId);

    if (!mounted) return;
    if (!success) {
      final err = ref.read(financialAccountProvider).error;
      TopToast.error(context, err ?? t.financial.deleteFailed);
      return;
    }

    TopToast.success(context, t.account.deleteSuccess);
    context.pop();
  }

  /// Bottom-sheet picker for choosing another account as merge/transfer target.
  ///
  /// Candidates are limited to active accounts with the same currency (the
  /// server enforces same-nature for merges and same-currency for transfers,
  /// so we pre-filter the obvious mismatches for a better UX).
  Future<String?> _pickAccountTarget({
    required String title,
    required bool sameNature,
  }) async {
    final current = widget.args.account;
    final currentId = current.id;

    // Reuse the system AccountSelectionSheet (same modal design as every other
    // account picker in the app) and just narrow the list to what the backend
    // will accept: same currency + active + (for merges) same nature.
    final rootContext = GoRouter.of(
      context,
    ).routerDelegate.navigatorKey.currentContext;
    if (rootContext == null) return null;

    final result = await AccountSelectionSheet.show(
      rootContext,
      title: title,
      filter: (account) {
        if (account.id == null || account.id == currentId) return false;
        if (account.status != AccountStatus.active) return false;
        if (account.currencyCode != current.currencyCode) return false;
        if (sameNature && account.nature != current.nature) return false;
        return true;
      },
      emptyMessage: t.account.mergeNoTarget,
    );
    return result?.accountId;
  }

  /// Bottom-sheet to choose how to dispose of a non-zero balance on close.
  Future<String?> _pickCloseDisposal(Decimal balance) async {
    final rootContext = GoRouter.of(
      context,
    ).routerDelegate.navigatorKey.currentContext;
    if (rootContext == null) return null;

    // Uses the same ActionBottomSheet as every other account-management modal,
    // with each option carrying a short explanation of what it actually does.
    // ActionBottomSheet pops itself with the selected item's `result`, so we
    // must NOT pop again here (a manual second pop would eject the page too).
    final options = <(String, ActionItem)>[
      (
        'keep',
        ActionItem(
          title: t.account.disposalKeep,
          subtitle: t.account.disposalKeepDesc,
          icon: FLucideIcons.archive,
          result: 'keep',
          onTap: () {},
        ),
      ),
      (
        'transfer',
        ActionItem(
          title: t.account.disposalTransfer,
          subtitle: t.account.disposalTransferDesc,
          icon: FLucideIcons.wallet,
          result: 'transfer',
          onTap: () {},
        ),
      ),
      (
        'writeoff',
        ActionItem(
          title: t.account.disposalWriteoff,
          subtitle: t.account.disposalWriteoffDesc,
          icon: FLucideIcons.receipt,
          result: 'writeoff',
          onTap: () {},
        ),
      ),
    ];

    return showModalBottomSheet<String>(
      context: rootContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ActionBottomSheet(
          title: t.account.closeDisposalTitle,
          description: t.account.closeBalanceDisposal(
            balance: formatAccountAmount(balance),
          ),
          actions: [
            for (final (value, item) in options)
              ActionItem(
                title: item.title,
                subtitle: item.subtitle,
                icon: item.icon,
                result: value,
                onTap: () {},
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();

    // Parse the balance explicitly instead of silently coercing a bad input to
    // zero: an invalid amount would otherwise be saved as 0 without any
    // feedback, silently discarding the user's intended value.
    final Decimal? balance = balanceText.isEmpty
        ? Decimal.zero
        : Decimal.tryParse(balanceText);
    if (balance == null) {
      TopToast.error(context, t.transaction.pleaseEnterAmount);
      return;
    }

    final updatedAccount = widget.args.account.copyWith(
      name: name.isNotEmpty ? name : widget.args.account.name,
      currencyCode: _currencyCode,
      currentBalance: balance,
      includeInNetWorth: _includeInAssets,
      // A closed (archived) account stays closed through ordinary edits;
      // reopening is an explicit account-management decision, not a side
      // effect of editing its name or balance.
      status: widget.args.account.status == AccountStatus.closed
          ? AccountStatus.closed
          : (_hidden ? AccountStatus.inactive : AccountStatus.active),
    );

    final currentAccounts = ref.read(financialAccountProvider).accounts;
    final updatedList = currentAccounts.map((a) {
      if (a.id == updatedAccount.id) return updatedAccount;
      return a;
    }).toList();

    final success = await ref
        .read(financialAccountProvider.notifier)
        .saveFinancialAccounts(updatedList);

    if (!mounted) return;

    // Keep the page open on failure so the user's edits are not lost.
    if (!success) {
      TopToast.error(context, t.financial.saveFailed);
      return;
    }

    await ref.read(financialAccountProvider.notifier).loadFinancialAccounts();

    if (mounted) {
      context.pop(updatedAccount);
    }
  }
}
