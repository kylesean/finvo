import 'package:decimal/decimal.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'dart:async';

import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
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
  late Currency _selectedCurrency;
  bool _hidden = false;
  bool _includeInAssets = true;

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
    _selectedCurrency = Currency.fromCode(account.currencyCode) ?? Currency.cny;
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
            onPress: _handleDelete,
            child: Icon(
              FLucideIcons.trash2,
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

  /// Unified form card - all input items are combined into one card
  Widget _buildFormCard(
    FThemeData theme,
    FColors colors,
    AccountTypeDefinition definition,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Account name
          buildAccountInputRow(
            theme: theme,
            colors: colors,
            icon: SizedBox(
              width: 20,
              height: 20,
              child: FittedBox(
                fit: BoxFit.contain,
                child: definition.iconBuilder(colors.primary),
              ),
            ),
            label: t.account.nameLabel,
            child: TextField(
              controller: _nameController,
              style: AppTextStyles.formValue(theme),
              decoration: InputDecoration(
                hintText: t.account.nameHint,
                hintStyle: theme.typography.body.md.copyWith(
                  color: colors.mutedForeground,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              maxLength: 16,
              buildCounter:
                  (
                    _, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => null,
            ),
          ),

          buildAccountFormDivider(colors),

          // Current balance
          buildAccountInputRow(
            theme: theme,
            colors: colors,
            icon: SizedBox(
              width: 20,
              height: 20,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  _selectedCurrency.symbol,
                  style: AppTextStyles.actionText(theme).copyWith(height: 1.0),
                ),
              ),
            ),
            label: t.account.amountLabel,
            child: TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: AppTextStyles.formValueNumeric(theme),
              decoration: InputDecoration(
                hintText: t.account.amountHint,
                hintStyle: theme.typography.body.md.copyWith(
                  color: colors.mutedForeground,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          buildAccountFormDivider(colors),

          // Currency selection
          buildAccountTapRow(
            theme: theme,
            colors: colors,
            icon: Icon(FLucideIcons.globe, size: 20, color: colors.primary),
            label: t.account.currencyLabel,
            value:
                '${_selectedCurrency.code} - ${_selectedCurrency.localizedName}',
            showArrow: true,
            onTap: _openCurrencyPicker,
          ),

          buildAccountFormDivider(colors),

          // Hidden switch
          buildAccountSwitchRow(
            theme: theme,
            colors: colors,
            title: t.account.hiddenLabel,
            subtitle: t.account.hiddenDesc,
            value: _hidden,
            onChanged: (value) => setState(() => _hidden = value),
          ),

          buildAccountFormDivider(colors),

          // Include in net worth switch
          buildAccountSwitchRow(
            theme: theme,
            colors: colors,
            title: t.account.includeInNetWorthLabel,
            subtitle: t.account.includeInNetWorthDesc,
            value: _includeInAssets,
            onChanged: (value) => setState(() => _includeInAssets = value),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Future<void> _openCurrencyPicker() async {
    final result = await CurrencySelectionSheet.show(
      context,
      _selectedCurrency.code,
    );
    if (!mounted || result == null) return;
    setState(() {
      _selectedCurrency = Currency.fromCode(result) ?? Currency.cny;
    });
  }

  void _handleDelete() {
    unawaited(
      showConfirmDialog(
        context: context,
        title: t.account.deleteAccount,
        message: t.account.deleteConfirm,
        cancelLabel: t.common.cancel,
        confirmLabel: t.common.delete,
        onConfirm: () async {
          unawaited(_performDelete());
        },
      ),
    );
  }

  Future<void> _performDelete() async {
    final currentAccounts = ref.read(financialAccountProvider).accounts;
    final accountToDelete = widget.args.account;

    // Use ID or name+type combination to match accounts
    final updatedList = currentAccounts.where((a) {
      if (accountToDelete.id != null && a.id != null) {
        return a.id != accountToDelete.id;
      }
      // If ID is null, use name and type combination matching
      return !(a.name == accountToDelete.name &&
          a.type == accountToDelete.type &&
          a.currencyCode == accountToDelete.currencyCode);
    }).toList();

    final success = await ref
        .read(financialAccountProvider.notifier)
        .saveFinancialAccounts(updatedList);

    if (!mounted) return;

    // Never pop on failure: the account is still there and silently closing
    // the page would make the user believe the delete succeeded.
    if (!success) {
      TopToast.error(context, t.financial.deleteFailed);
      return;
    }

    await ref.read(financialAccountProvider.notifier).loadFinancialAccounts();

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();

    Decimal balance;
    try {
      balance = Decimal.parse(balanceText.isEmpty ? '0' : balanceText);
    } catch (_) {
      balance = Decimal.zero;
    }

    final updatedAccount = widget.args.account.copyWith(
      name: name.isNotEmpty ? name : widget.args.account.name,
      currencyCode: _selectedCurrency.code,
      currentBalance: balance,
      includeInNetWorth: _includeInAssets,
      status: _hidden ? AccountStatus.inactive : AccountStatus.active,
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
