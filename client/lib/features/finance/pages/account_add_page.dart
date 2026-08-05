import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/finance/widgets/account_form_widgets.dart';
import 'package:finvo/features/finance/widgets/currency_selection_sheet.dart';
import 'package:finvo/i18n/strings.g.dart';

class FinancialAccountAddArgs {
  const FinancialAccountAddArgs({
    required this.definition,
    this.initialAccount,
  });

  final AccountTypeDefinition definition;
  final FinancialAccount? initialAccount;
}

/// Add account page - compact layout design
class FinancialAccountAddPage extends ConsumerStatefulWidget {
  const FinancialAccountAddPage({super.key, required this.args});

  final FinancialAccountAddArgs args;

  @override
  ConsumerState<FinancialAccountAddPage> createState() =>
      _FinancialAccountAddPageState();
}

class _FinancialAccountAddPageState
    extends ConsumerState<FinancialAccountAddPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late Currency _selectedCurrency;
  bool _hidden = false;
  bool _includeInAssets = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.args.initialAccount;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _balanceController = TextEditingController(
      text: initial != null ? formatAccountAmount(initial.initialBalance) : '',
    );
    _selectedCurrency = initial != null
        ? Currency.fromCode(initial.currencyCode) ?? Currency.cny
        : Currency.cny;
    if (initial != null) {
      _includeInAssets = initial.includeInNetWorth;
      _hidden = initial.status == AccountStatus.inactive;
    }
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
          false, // Prevent keyboard from pushing layout up
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
        title: Text(t.account.addTitle, style: AppTextStyles.pageTitle(theme)),
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

  /// Unified form card - all inputs combined in a single card
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
                hintText: _getDefaultName(definition),
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

          // Initial balance
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
                hintText: '0.00',
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

          // Hidden toggle
          buildAccountSwitchRow(
            theme: theme,
            colors: colors,
            title: t.account.hiddenLabel,
            subtitle: t.account.hiddenDesc,
            value: _hidden,
            onChanged: (value) => setState(() => _hidden = value),
          ),

          buildAccountFormDivider(colors),

          // Include in assets toggle
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

  void _handleSave() {
    final definition = widget.args.definition;
    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();

    Decimal balance;
    try {
      balance = Decimal.parse(balanceText.isEmpty ? '0' : balanceText);
    } catch (_) {
      balance = Decimal.zero;
    }

    final accountType = definition.apiType;
    final nature = _inferNature(definition.nature);

    final accountName = name.isNotEmpty ? name : _getDefaultName(definition);

    final newAccount = FinancialAccount(
      name: accountName,
      nature: nature,
      type: accountType,
      currencyCode: _selectedCurrency.code,
      initialBalance: balance,
      currentBalance: balance,
      includeInNetWorth: _includeInAssets,
      status: _hidden ? AccountStatus.inactive : AccountStatus.active,
    );

    context.pop(newAccount);
  }

  String _getDefaultName(AccountTypeDefinition definition) {
    switch (definition.id) {
      case 'cash':
        return t.account.cash;
      case 'deposit':
        return t.account.deposit;
      case 'e_money':
        return t.account.eWallet;
      case 'investment':
        return t.account.investment;
      case 'receivable':
        return t.account.receivable;
      case 'credit_card':
        return t.account.creditCard;
      case 'loan':
        return t.account.loan;
      case 'payable':
        return t.account.payable;
      default:
        return definition.title;
    }
  }

  FinancialNature _inferNature(AccountNature uiNature) {
    switch (uiNature) {
      case AccountNature.liquidAssets:
      case AccountNature.investmentAssets:
      case AccountNature.receivables:
      case AccountNature.otherAssets:
        return FinancialNature.asset;
      case AccountNature.creditAccounts:
      case AccountNature.longTermLiabilities:
      case AccountNature.payables:
        return FinancialNature.liability;
    }
  }
}
