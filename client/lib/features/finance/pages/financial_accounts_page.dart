import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/features/finance/pages/account_edit_navigation.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/finance/providers/financial_summary_provider.dart';
import 'package:finvo/features/finance/providers/account_view_currency_provider.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/finance/widgets/currency_selection_sheet.dart';
import 'package:finvo/features/finance/widgets/financial_account_card.dart';
import 'package:finvo/features/finance/widgets/financial_accounts_drawer.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';

class FinancialAccountsPage extends ConsumerStatefulWidget {
  const FinancialAccountsPage({super.key});

  @override
  ConsumerState<FinancialAccountsPage> createState() =>
      _FinancialAccountsPageState();
}

class _FinancialAccountsPageState extends ConsumerState<FinancialAccountsPage> {
  // Account management related state
  bool _hideAmounts = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final theme = context.theme;
    final colorScheme = theme.colors;
    final state = ref.watch(financialAccountProvider);
    final accounts = state.accounts;

    // Get view currency from reactive derived provider
    final viewCurrency = ref.watch(effectiveViewCurrencyProvider);

    // Use the reactive summary provider without manual calculation
    final summary = ref.watch(financialSummaryProvider(viewCurrency));
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

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => FButton.icon(
            variant: .ghost,
            onPress: () => Scaffold.of(context).openDrawer(),
            child: Icon(
              FLucideIcons.menu,
              color: theme.colors.foreground,
              size: 20,
            ),
          ),
        ),
        title: Text(
          t.financial.title,
          style: AppTextStyles.pageTitleLarge(theme),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildAccountManagementBody(
                theme,
                colorScheme,
                state,
                accounts,
                assetAccounts,
                liabilityAccounts,
                totalNetWorth,
                totalAssets,
                totalLiabilities,
                viewCurrency,
                summary.missingRateCurrencies,
              ),
            ),
          ],
        ),
      ),
      drawer: const FinancialAccountsDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.primaryForeground,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  /// build account management body
  Widget _buildAccountManagementBody(
    FThemeData theme,
    FColors colors,
    FinancialAccountState state,
    List<FinancialAccount> accounts,
    List<FinancialAccount> assetAccounts,
    List<FinancialAccount> liabilityAccounts,
    Decimal totalNetWorth,
    Decimal totalAssets,
    Decimal totalLiabilities,
    String viewCurrency,
    Set<String> missingRateCurrencies,
  ) {
    // loading state
    if (state.isLoading && accounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // error state
    if (state.error != null && accounts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.destructive),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: theme.typography.body.md.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              FButton(
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

    // Remove SafeArea here because it's already in the parent Scaffold body
    return LayoutBuilder(
      builder: (context, constraints) {
        // if available height is too small, only show list
        final showCard = constraints.maxHeight > 300;

        return Column(
          children: [
            // Black gold card at top (only show when there is enough space)
            if (showCard)
              _buildNetWorthCard(
                theme,
                colors,
                totalNetWorth,
                totalAssets,
                totalLiabilities,
                viewCurrency,
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
                              t.financial.assetAccounts,
                            ),
                            ...assetAccounts.map(
                              (account) => FinancialAccountCard(
                                account: account,
                                hideAmounts: _hideAmounts,
                                onEdit: (account, definition) =>
                                    pushAccountEditPage(
                                      context,
                                      account,
                                      definition,
                                    ),
                              ),
                            ),
                          ],
                          if (liabilityAccounts.isNotEmpty) ...[
                            _buildSectionHeader(
                              theme,
                              colors,
                              t.financial.liabilityAccounts,
                            ),
                            ...liabilityAccounts.map(
                              (account) => FinancialAccountCard(
                                account: account,
                                hideAmounts: _hideAmounts,
                                onEdit: (account, definition) =>
                                    pushAccountEditPage(
                                      context,
                                      account,
                                      definition,
                                    ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 80), // Space for FAB
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

  /// build empty state
  Widget _buildEmptyState(FThemeData theme, FColors colors) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: colors.mutedForeground.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                t.financial.noAccounts,
                style: theme.typography.body.lg.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.financial.addFirstAccount,
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
    String viewCurrency,
  ) {
    final currency = Currency.fromCode(viewCurrency) ?? Currency.cny;
    final currencySymbol = currency.symbol;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.financial.netWorth.toUpperCase(),
                style: AppTextStyles.statLabelOnDarkSecondary(theme).copyWith(
                  color: theme.colors.primaryForeground.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _hideAmounts = !_hideAmounts),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.primaryForeground.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _hideAmounts ? FLucideIcons.eyeOff : FLucideIcons.eye,
                        size: 16,
                        color: colors.primaryForeground.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showCurrencyPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryForeground.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.primaryForeground.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            viewCurrency,
                            style: AppTextStyles.statLabelOnDark(theme),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            FLucideIcons.repeat,
                            size: 11,
                            color: colors.primaryForeground.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Net worth amount
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: _hideAmounts
                  ? Text(
                      '$currencySymbol ****',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ).copyWith(color: colors.primaryForeground),
                    )
                  : AmountText(
                      amount: netWorth.abs(),
                      type: netWorth >= Decimal.zero
                          ? TransactionType.income
                          : TransactionType.expense,
                      semantic: AmountSemantic.status, // Changed to status
                      currency: viewCurrency,
                      shrinkCurrency: true,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // Explicitly force white
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),
          // Assets and liabilities row (2-column layout)
          Row(
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  theme,
                  colors,
                  t.financial.assets,
                  assets,
                  TransactionType.income,
                  viewCurrency,
                  _hideAmounts,
                  theme.semantic.successAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderMetric(
                  theme,
                  colors,
                  t.financial.liabilities,
                  liabilities,
                  TransactionType.expense,
                  viewCurrency,
                  _hideAmounts,
                  colors.destructive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(
    FThemeData theme,
    FColors colors,
    String label,
    Decimal amount,
    TransactionType type,
    String currency,
    bool hidden,
    Color fallbackColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.statLabelOnDarkSecondary(theme).copyWith(
            color: theme.colors.primaryForeground.withValues(alpha: 0.5),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: hidden
              ? Text(
                  '****',
                  style: AppTextStyles.statValueOnDarkSecondary(theme).copyWith(
                    color: theme.colors.primaryForeground.withValues(
                      alpha: 0.8,
                    ),
                  ),
                )
              : AmountText(
                  amount: amount,
                  type: type,
                  semantic: AmountSemantic.status, // Changed to status
                  currency: currency,
                  shrinkCurrency: true,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white, // Explicitly force white
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(FThemeData theme, FColors colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: AppTextStyles.sectionHeader(theme)),
    );
  }

  Future<void> _showCurrencyPicker() async {
    final currentCurrency = ref.read(effectiveViewCurrencyProvider);

    final result = await CurrencySelectionSheet.show(context, currentCurrency);
    if (result != null && mounted) {
      ref.read(accountViewCurrencyProvider.notifier).setTemporary(result);
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
