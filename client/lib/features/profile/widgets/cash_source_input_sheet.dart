import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/providers/financial_settings_provider.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/i18n/strings.g.dart';

class FinancialAccountInputSheet extends ConsumerStatefulWidget {
  final AccountTypeDefinition definition;
  final FinancialAccount? initialAccount;
  final ValueChanged<FinancialAccount> onSubmitted;

  const FinancialAccountInputSheet({
    super.key,
    required this.definition,
    this.initialAccount,
    required this.onSubmitted,
  });

  @override
  ConsumerState<FinancialAccountInputSheet> createState() =>
      _FinancialAccountInputSheetState();
}

class _FinancialAccountInputSheetState
    extends ConsumerState<FinancialAccountInputSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _isLoading = false;
  late bool _isPreset;

  @override
  void initState() {
    super.initState();
    // Determine whether to show name input based on requiresCustomName
    // CASH type doesn't need name, but DEPOSIT, etc., do
    _isPreset = !widget.definition.requiresCustomName;

    final initial = widget.initialAccount;
    if (initial != null) {
      // Use name field as account name
      _nameController.text = initial.name;
      _balanceController.text =
          (double.tryParse(initial.initialBalance.toString()) ?? 0)
              .toStringAsFixed(2);
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
    final definition = widget.definition;
    final showNameField = !_isPreset || definition.requiresCustomName;
    // Resolve the user's primary currency symbol instead of hard-coding ¥ so
    // the sheet respects the configured currency. For an unknown currency we
    // fall back to the code itself (visibly truthful) rather than silently
    // assuming CNY.
    final primaryCurrency = ref
        .watch(financialSettingsProvider)
        .primaryCurrency;
    final currencySymbol = AmountFormatter.getCurrencySymbol(primaryCurrency);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.symmetric(
            horizontal: BorderSide(color: colors.border),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedTitle(definition),
                      style: theme.typography.body.xl2.copyWith(
                        fontWeight: AppFontConfig.titleSemibold,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getLocalizedSubtitle(definition),
                      style: AppTextStyles.listSubtitle(theme),
                    ),
                    if (_hasHelper(definition)) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _getLocalizedHelper(definition),
                          style: AppTextStyles.badge(theme),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border),
                        ),
                        child: Center(
                          child: definition.iconBuilder(colors.foreground),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (showNameField) ...[
                      Text(
                        t.account.nameLabel,
                        style: AppTextStyles.formFieldLabel(theme),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: t.account.nameHint,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.account.nameRequired;
                          }
                          if (value.trim().length < 2) {
                            return t.account.nameTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      t.account.amountLabel,
                      style: AppTextStyles.formFieldLabel(theme),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _balanceController,
                      decoration: InputDecoration(
                        hintText: t.account.amountHint,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            currencySymbol,
                            style: AppTextStyles.listSubtitle(theme),
                          ),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t.account.amountRequired;
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null) {
                          return t.account.invalidAmount;
                        }
                        if (amount < 0) {
                          return t.account.negativeBalance;
                        }
                        if (amount > 999999999.99) {
                          return t.account.amountTooLarge;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    FButton(
                      onPress: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primaryForeground,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(t.common.saving),
                              ],
                            )
                          : Text(t.common.save),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final balance = Decimal.parse(_balanceController.text.trim());
      final definition = widget.definition;
      final shouldPersistName = definition.requiresCustomName;
      final trimmedName = _nameController.text.trim();

      // Infer FinancialNature from AccountTypeDefinition's nature
      final nature = _inferNature(definition.nature);

      // Use definition's apiType directly
      final accountType = definition.apiType;

      // Use account name: custom name priority, otherwise use definition title
      final accountName = (shouldPersistName && trimmedName.isNotEmpty)
          ? trimmedName
          : definition.title.split(' ').first; // Take part of the title

      final financialAccount = FinancialAccount(
        name: accountName,
        nature: nature,
        type: accountType,
        initialBalance: balance,
        includeInNetWorth: true,
      );

      widget.onSubmitted(financialAccount);
    } catch (e) {
      if (mounted) {
        // Show error dialog instead of SnackBar
        unawaited(
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(t.common.saveFailed),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.common.ok),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Infer API FinancialNature from UI AccountNature
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

  /// Gets localized title
  String _getLocalizedTitle(AccountTypeDefinition definition) {
    switch (definition.id) {
      case 'cash':
        return t.account.types.cashTitle;
      case 'deposit':
        return t.account.types.depositTitle;
      case 'e_money':
        return t.account.types.eMoneyTitle;
      case 'investment':
        return t.account.types.investmentTitle;
      case 'receivable':
        return t.account.types.receivableTitle;
      case 'credit_card':
        return t.account.types.creditCardTitle;
      case 'loan':
        return t.account.types.loanTitle;
      case 'payable':
        return t.account.types.payableTitle;
      default:
        return definition.title;
    }
  }

  /// Gets localized subtitle
  String _getLocalizedSubtitle(AccountTypeDefinition definition) {
    switch (definition.id) {
      case 'cash':
        return t.account.types.cashSubtitle;
      case 'deposit':
        return t.account.types.depositSubtitle;
      case 'e_money':
        return t.account.types.eMoneySubtitle;
      case 'investment':
        return t.account.types.investmentSubtitle;
      case 'receivable':
        return t.account.types.receivableSubtitle;
      case 'credit_card':
        return t.account.types.creditCardSubtitle;
      case 'loan':
        return t.account.types.loanSubtitle;
      case 'payable':
        return t.account.types.payableSubtitle;
      default:
        return definition.subtitle;
    }
  }

  /// Checks if there is helper text
  bool _hasHelper(AccountTypeDefinition definition) {
    return definition.id == 'receivable' || definition.id == 'payable';
  }

  /// Gets localized helper text
  String _getLocalizedHelper(AccountTypeDefinition definition) {
    switch (definition.id) {
      case 'receivable':
        return t.account.types.receivableHelper;
      case 'payable':
        return t.account.types.payableHelper;
      default:
        return '';
    }
  }
}
