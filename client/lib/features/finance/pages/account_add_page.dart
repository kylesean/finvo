import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/finance/widgets/account_form_widgets.dart';
import 'package:finvo/features/finance/widgets/currency_selection_sheet.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
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
      nameHint: _getDefaultName(definition),
      balanceController: _balanceController,
      currencySymbol: _selectedCurrency.symbol,
      currencyLabel:
          '${_selectedCurrency.code} - ${_selectedCurrency.localizedName}',
      onOpenCurrencyPicker: _openCurrencyPicker,
      hidden: _hidden,
      onHiddenChanged: (value) => setState(() => _hidden = value),
      includeInNetWorth: _includeInAssets,
      onIncludeInNetWorthChanged: (value) =>
          setState(() => _includeInAssets = value),
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
