import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'dart:async';

import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/features/finance/pages/account_edit_navigation.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/finance/providers/financial_summary_provider.dart';
import 'package:finvo/features/finance/widgets/currency_selection_sheet.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Account management page - strictly following design spec
class AccountSourcesPage extends ConsumerStatefulWidget {
  const AccountSourcesPage({super.key});

  @override
  ConsumerState<AccountSourcesPage> createState() => _AccountSourcesPageState();
}

class _AccountSourcesPageState extends ConsumerState<AccountSourcesPage> {
  bool _hideAmounts = false;
  String _viewCurrency = 'CNY';

  @override
  void initState() {
    super.initState();
    // Load account list via API on page init
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
    final state = ref.watch(financialAccountProvider);
    final accounts = state.accounts;

    // Calculate totals based on nature field from API
    // Use the reactive summary provider
    final summary = ref.watch(financialSummaryProvider(_viewCurrency));
    final totalNetWorth = summary.totalNetWorth;
    final totalAssets = summary.totalAssets;
    final totalLiabilities = summary.totalLiabilities;

    // Group accounts by nature field
    final assetAccounts = accounts
        .where((a) => a.nature == FinancialNature.asset)
        .toList();

    final liabilityAccounts = accounts
        .where((a) => a.nature == FinancialNature.liability)
        .toList();

    return FScaffold(
      header: FHeader(
        title: Text(
          'Account Management',
          style: AppTextStyles.pageTitleLarge(theme),
        ),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: _addAccount,
          ),
        ],
      ),
      child: _buildBody(
        theme,
        colors,
        state,
        accounts,
        assetAccounts,
        liabilityAccounts,
        totalNetWorth,
        totalAssets,
        totalLiabilities,
        summary.missingRateCurrencies,
      ),
    );
  }

  /// Build page body content
  Widget _buildBody(
    FThemeData theme,
    FColors colors,
    FinancialAccountState state,
    List<FinancialAccount> accounts,
    List<FinancialAccount> assetAccounts,
    List<FinancialAccount> liabilityAccounts,
    Decimal totalNetWorth,
    Decimal totalAssets,
    Decimal totalLiabilities,
    Set<String> missingRateCurrencies,
  ) {
    // Loading state
    if (state.isLoading && accounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.error != null && accounts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FLucideIcons.circleAlert,
                size: 48,
                color: colors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.listSubtitle(theme),
              ),
              const SizedBox(height: 24),
              FButton(
                variant: .outline,
                onPress: () {
                  unawaited(
                    ref
                        .read(financialAccountProvider.notifier)
                        .loadFinancialAccounts(),
                  );
                },
                child: Text(t.common.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Normal content
    return LayoutBuilder(
      builder: (context, constraints) {
        // If available height is too small, only show list
        final showCard = constraints.maxHeight > 300;

        return Column(
          children: [
            // Black gold card at top (only shown when enough space)
            if (showCard)
              _buildNetWorthCard(
                theme,
                colors,
                totalNetWorth,
                totalAssets,
                totalLiabilities,
              ),

            // Warn when some accounts were excluded from the totals because
            // their currency has no usable exchange rate.
            if (missingRateCurrencies.isNotEmpty)
              _buildMissingRateHint(theme, colors, missingRateCurrencies),

            // Account list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(financialAccountProvider.notifier)
                      .loadFinancialAccounts();
                },
                child: accounts.isEmpty
                    ? _buildEmptyState(theme, colors)
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          if (assetAccounts.isNotEmpty) ...[
                            _buildSectionHeader(
                              theme,
                              colors,
                              'Asset Accounts',
                            ),
                            ...assetAccounts.map(
                              (account) =>
                                  _buildAccountCard(theme, colors, account),
                            ),
                          ],
                          if (liabilityAccounts.isNotEmpty) ...[
                            _buildSectionHeader(
                              theme,
                              colors,
                              'Liability Accounts',
                            ),
                            ...liabilityAccounts.map(
                              (account) =>
                                  _buildAccountCard(theme, colors, account),
                            ),
                          ],
                          const SizedBox(height: 40), // Bottom spacing
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissingRateHint(
    FThemeData theme,
    FColors colors,
    Set<String> missingRateCurrencies,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(FLucideIcons.circleAlert, size: 14, color: colors.destructive),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.financial.missingExchangeRates(
                currencies: missingRateCurrencies.join(', '),
              ),
              style: theme.typography.body.xs.copyWith(
                color: colors.destructive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state UI
  Widget _buildEmptyState(FThemeData theme, FColors colors) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.wallet,
                size: 64,
                color: colors.mutedForeground.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No accounts yet',
                style: theme.typography.body.lg.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add your first account',
                style: theme.typography.body.sm.copyWith(
                  color: colors.mutedForeground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetWorthCard(
    FThemeData theme,
    FColors colors,
    Decimal netWorth,
    Decimal assets,
    Decimal liabilities,
  ) {
    final currency = Currency.fromCode(_viewCurrency) ?? Currency.cny;
    final currencySymbol = currency.symbol;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary, // Use theme primary color
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.financial.netWorth.toUpperCase(),
                style: theme.typography.body.xs.copyWith(
                  color: colors.primaryForeground.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Net worth amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _hideAmounts
                    ? '$currencySymbol ****'
                    : '$currencySymbol ${_formatAmount(netWorth)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  fontFeatures: [FontFeature.tabularFigures()],
                ).copyWith(color: colors.primaryForeground),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _hideAmounts = !_hideAmounts),
                child: Icon(
                  _hideAmounts ? FLucideIcons.eyeOff : FLucideIcons.eye,
                  size: 20,
                  color: colors.primaryForeground.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Assets and liabilities row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSETS',
                      style: theme.typography.body.xs.copyWith(
                        color: colors.primaryForeground.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hideAmounts ? '****' : '+${_formatAmount(assets)}',
                      style: AppTextStyles.listTitle(
                        theme,
                      ).copyWith(color: theme.semantic.successAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIABILITIES',
                      style: theme.typography.body.xs.copyWith(
                        color: colors.primaryForeground.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hideAmounts ? '****' : '-${_formatAmount(liabilities)}',
                      style: AppTextStyles.listTitle(
                        theme,
                      ).copyWith(color: colors.destructive),
                    ),
                  ],
                ),
              ),
              // Currency switcher
              GestureDetector(
                onTap: _showCurrencyPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryForeground.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.primaryForeground.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${Currency.fromCode(_viewCurrency)?.localizedName ?? _viewCurrency} $currencySymbol',
                        style: AppTextStyles.statLabelOnDark(theme),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        FLucideIcons.repeat,
                        size: 14,
                        color: colors.primaryForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(FThemeData theme, FColors colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: AppTextStyles.sectionHeader(theme)),
    );
  }

  Widget _buildAccountCard(
    FThemeData theme,
    FColors colors,
    FinancialAccount account,
  ) {
    final definition = AccountTypeRegistry.resolveByApiType(account.type);

    // Use nature field to determine if liability
    final isLiabilityAccount = account.nature == FinancialNature.liability;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(10), // Match FCard radius
          child: InkWell(
            onTap: () => pushAccountEditPage(context, account, definition),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ThemedIcon.large(
                    icon: isLiabilityAccount
                        ? FLucideIcons.creditCard
                        : FLucideIcons.wallet,
                  ),
                  const SizedBox(width: 16),
                  // Name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: AppTextStyles.listTitle(theme),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          definition != null
                              ? _getTypeDisplayName(definition)
                              : (isLiabilityAccount
                                    ? 'Liability Account'
                                    : 'Asset Account'),
                          style: AppTextStyles.listSubtitle(theme),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _hideAmounts
                            ? '****'
                            : '${isLiabilityAccount ? '-' : ''}${_formatAmount(account.initialBalance)}',
                        style: AppTextStyles.listTitle(theme).copyWith(
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.currencyCode,
                        style: AppTextStyles.detailLabel(theme),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    FLucideIcons.chevronRight,
                    size: 16,
                    color: colors.mutedForeground.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCurrencyPicker() async {
    final result = await CurrencySelectionSheet.show(context, _viewCurrency);
    if (result != null && mounted) {
      setState(() {
        _viewCurrency = result;
      });
    }
  }

  String _formatAmount(Decimal amount) {
    final value = double.tryParse(amount.toString()) ?? 0.0;
    // Format with the currency the user is currently viewing, not a fixed
    // CNY: the summary above is already converted into _viewCurrency.
    return AmountFormatter.getNumberFormat(_viewCurrency).format(value);
  }

  String _getTypeDisplayName(AccountTypeDefinition definition) {
    final account = t.account;
    switch (definition.id) {
      case 'cash':
        return account.cash;
      case 'deposit':
        return account.deposit;
      case 'e_money':
        return account.eWallet;
      case 'investment':
        return account.investment;
      case 'receivable':
        return account.receivable;
      case 'credit_card':
        return account.creditCard;
      case 'loan':
        return account.loan;
      case 'payable':
        return account.payable;
      default:
        return definition.title;
    }
  }

  Future<void> _addAccount() async {
    final typeResult = await context.pushNamed(
      AppRouteNames.financialAccountTypePicker,
    );
    if (!mounted || typeResult == null) return;

    if (typeResult is FinancialAccount) {
      // Add the new account to the provider
      final currentAccounts = ref.read(financialAccountProvider).accounts;
      final updatedList = [...currentAccounts, typeResult];
      final success = await ref
          .read(financialAccountProvider.notifier)
          .saveFinancialAccounts(updatedList);

      // Refresh account list after successful save
      if (success && mounted) {
        await ref
            .read(financialAccountProvider.notifier)
            .loadFinancialAccounts();
      }
    }
  }
}
