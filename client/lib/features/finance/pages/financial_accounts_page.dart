import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../profile/models/financial_account.dart';
import '../../profile/providers/financial_account_provider.dart';
import '../../profile/providers/financial_settings_provider.dart';
import '../models/account_type_definition.dart';
import '../../../shared/models/currency.dart';
import 'account_edit_page.dart';
import '../providers/financial_summary_provider.dart';
import '../providers/account_view_currency_provider.dart';
import '../../../shared/providers/exchange_rate_provider.dart';
import '../../../shared/widgets/app_card.dart';
import 'package:augo/i18n/strings.g.dart';
import 'package:augo/shared/widgets/amount_text.dart';
import 'package:augo/shared/widgets/themed_icon.dart';
import 'package:augo/features/home/models/transaction_model.dart';
import '../widgets/currency_selection_sheet.dart';

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
          style: theme.typography.body.xl.copyWith(fontWeight: FontWeight.w500),
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
              ),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
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
                              (account) =>
                                  _buildAccountCard(theme, colors, account),
                            ),
                          ],
                          if (liabilityAccounts.isNotEmpty) ...[
                            _buildSectionHeader(
                              theme,
                              colors,
                              t.financial.liabilityAccounts,
                            ),
                            ...liabilityAccounts.map(
                              (account) =>
                                  _buildAccountCard(theme, colors, account),
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
                style: theme.typography.body.xs.copyWith(
                  color: colors.primaryForeground.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
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
                            style: theme.typography.body.xs.copyWith(
                              color: colors.primaryForeground,
                              fontWeight: FontWeight.w500,
                            ),
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
                      amount: netWorth.toDouble().abs(),
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
                  const Color(0xFF4CAF50),
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
          style: theme.typography.body.xs.copyWith(
            color: colors.primaryForeground.withValues(alpha: 0.5),
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: hidden
              ? Text(
                  '****',
                  style: theme.typography.body.md.copyWith(
                    color: colors.primaryForeground.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                )
              : AmountText(
                  amount: amount.toDouble(),
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
      child: Text(
        title,
        style: theme.typography.body.sm.copyWith(
          color: colors.mutedForeground,
          fontWeight: FontWeight.w500,
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 8), // Reduced bottom padding
      child: AppCard(
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(10), // Match FCard radius
          child: InkWell(
            onTap: () => _editAccount(account, definition),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  // Icon - Using ThemedIcon for consistency
                  ThemedIcon(
                    icon: _getAccountTypeIcon(
                      definition?.id,
                      isLiabilityAccount,
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
                          style: theme.typography.body.md.copyWith(
                            // Revert to base
                            fontWeight: FontWeight.w500,
                            color: colors.foreground,
                          ),
                        ),
                        Text(
                          definition != null
                              ? _getTypeDisplayName(definition)
                              : (isLiabilityAccount
                                    ? t.financial.liabilityAccounts
                                    : t.financial.assetAccounts),
                          style: theme.typography.body.sm.copyWith(
                            // Revert to sm
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _hideAmounts
                          ? const Text('****')
                          : AmountText(
                              amount:
                                  (account.currentBalance ??
                                          account.initialBalance)
                                      .toDouble(),
                              type: isLiabilityAccount
                                  ? TransactionType.expense
                                  : TransactionType.income,
                              semantic: AmountSemantic.status,
                              currency: account.currencyCode,
                              style: theme.typography.body.md.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colors.foreground,
                              ),
                            ),
                      Text(
                        account.currencyCode,
                        style: theme.typography.body.sm.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                      if (!_hideAmounts) ...[
                        Builder(
                          builder: (context) {
                            final viewCurrency = ref.watch(
                              effectiveViewCurrencyProvider,
                            );
                            if (viewCurrency.toUpperCase() ==
                                account.currencyCode.toUpperCase()) {
                              return const SizedBox.shrink();
                            }
                            final rawBalance =
                                account.currentBalance ??
                                account.initialBalance;
                            final ratesNotifier = ref.watch(
                              exchangeRateProvider.notifier,
                            );
                            final converted = ratesNotifier.convert(
                              rawBalance,
                              account.currencyCode,
                              viewCurrency,
                            );
                            if (converted == null) {
                              return const SizedBox.shrink();
                            }
                            final symbol =
                                Currency.fromCode(viewCurrency)?.symbol ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '≈ $symbol${converted.toDouble().toStringAsFixed(2)} $viewCurrency',
                                style: theme.typography.body.xs.copyWith(
                                  color: colors.mutedForeground.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  // const SizedBox(width: 8),
                  // Icon(
                  //   FLucideIcons.chevronRight,
                  //   size: 16,
                  //   color: colors.mutedForeground.withValues(alpha: 0.5),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCurrencyPicker() async {
    final currentCurrency = ref.read(effectiveViewCurrencyProvider);

    final result = await CurrencySelectionSheet.show(context, currentCurrency);
    if (result != null && mounted) {
      ref.read(accountViewCurrencyProvider.notifier).setTemporary(result);
    }
  }

  String _getTypeDisplayName(AccountTypeDefinition definition) {
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

  /// Get Forui icon for account type ID
  IconData _getAccountTypeIcon(String? typeId, bool isLiability) {
    switch (typeId) {
      case 'cash':
        return FLucideIcons.wallet;
      case 'deposit':
        return FLucideIcons.landmark;
      case 'e_money':
        return FLucideIcons.smartphone;
      case 'investment':
        return FLucideIcons.trendingUp;
      case 'receivable':
        return FLucideIcons.arrowRight;
      case 'credit_card':
        return FLucideIcons.creditCard;
      case 'loan':
        return FLucideIcons.building;
      case 'payable':
        return FLucideIcons.arrowLeft;
      default:
        return isLiability ? FLucideIcons.creditCard : FLucideIcons.wallet;
    }
  }

  Future<void> _addAccount() async {
    final typeResult = await context.pushNamed('financialAccountTypePicker');
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

  Future<void> _editAccount(
    FinancialAccount account,
    AccountTypeDefinition? definition,
  ) async {
    // If no matching definition found, try to get default based on account.type
    final accountDefinition =
        definition ??
        AccountTypeRegistry.resolveByApiType(account.type) ??
        AccountTypeRegistry.getDefaultDefinition(account.nature);

    await context.pushNamed(
      'financialAccountEdit',
      extra: FinancialAccountEditArgs(
        definition: accountDefinition,
        account: account,
      ),
    );
    // Refresh is handled by the edit page's provider interaction
  }

  /// Build left drawer content
  Widget _buildDrawer(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;

    return Drawer(
      backgroundColor: colorScheme.background,
      shape: const RoundedRectangleBorder(), // Remove rounded corners
      child: SafeArea(
        child: Column(
          children: [
            // Top: title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.wallet,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.financial.management,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle: feature list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial settings group
                    Text(
                      t.financial.settings,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FItemGroup(
                      children: [
                        FItem(
                          prefix: const ThemedIcon(
                            icon: FLucideIcons.dollarSign,
                          ),
                          title: Text(t.financial.budgetManagement),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            // Delay navigation to wait for drawer close animation
                            unawaited(
                              Future<void>.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  if (context.mounted) {
                                    unawaited(
                                      context.pushNamed('budgetOverview'),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        FItem(
                          prefix: const ThemedIcon(icon: FLucideIcons.repeat),
                          title: Text(t.financial.recurringTransactions),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            // Delay navigation to wait for drawer close animation
                            unawaited(
                              Future<void>.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  if (context.mounted) {
                                    unawaited(
                                      context.pushNamed(
                                        'recurringTransactions',
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        FItem(
                          prefix: const ThemedIcon(icon: FLucideIcons.shield),
                          title: Text(t.financial.safetyThreshold),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            _showSafetyThresholdSettings(context);
                          },
                        ),
                        FItem(
                          prefix: const ThemedIcon(
                            icon: FLucideIcons.calculator,
                          ),
                          title: Text(t.financial.dailyBurnRate),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            _showDailySpendingSettings(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom: user info (optional)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colorScheme.border)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigate to profile page or other features
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            FLucideIcons.user,
                            size: 16,
                            color: colorScheme.primaryForeground,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.financial.financialAssistant,
                                style: theme.typography.body.sm.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                t.financial.manageFinancialSettings,
                                style: theme.typography.body.xs.copyWith(
                                  color: colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          FLucideIcons.chevronRight,
                          size: 16,
                          color: colorScheme.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show safety threshold settings
  void _showSafetyThresholdSettings(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext sheetContext) {
          return const _SafetyThresholdBottomSheet();
        },
      ),
    );
  }

  /// Show daily spending settings
  void _showDailySpendingSettings(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext sheetContext) {
          return const _DailySpendingBottomSheet();
        },
      ),
    );
  }
}

// Bottom sheet components below

class _SafetyThresholdBottomSheet extends ConsumerStatefulWidget {
  const _SafetyThresholdBottomSheet();

  @override
  ConsumerState<_SafetyThresholdBottomSheet> createState() =>
      _SafetyThresholdBottomSheetState();
}

class _SafetyThresholdBottomSheetState
    extends ConsumerState<_SafetyThresholdBottomSheet> {
  double _currentValue = 1000.0;
  bool _hasInitialized = false;
  bool _isUpdatingFromSlider = false;
  late final TextEditingController _controller;

  static const double _maxSliderLimit = 50000.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSliderChanged(double val) {
    _isUpdatingFromSlider = true;
    setState(() {
      _currentValue = val;
      _controller.text = val.toStringAsFixed(0);
    });
    _isUpdatingFromSlider = false;
  }

  void _onTextChanged(String text) {
    if (_isUpdatingFromSlider) return;
    final parsed = double.tryParse(text) ?? 0.0;
    setState(() {
      _currentValue = math.max(0.0, parsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;
    final settingsState = ref.watch(financialSettingsProvider);
    final primaryCurrency = settingsState.primaryCurrency;
    final symbol = Currency.fromCode(primaryCurrency)?.symbol ?? '¥';

    if (!_hasInitialized && settingsState.safetyThreshold != null) {
      _currentValue = settingsState.effectiveSafetyThreshold.toDouble();
      _controller.text = _currentValue.toStringAsFixed(0);
      _hasInitialized = true;
    }

    final double sliderValue = _currentValue.clamp(0.0, _maxSliderLimit);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                decoration: BoxDecoration(
                  color: colorScheme.border.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      t.financial.safetyThresholdSettings,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.financial.setSafetyThreshold,
                      style: theme.typography.body.sm.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Minimal Underline Amount Input Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      symbol,
                      style: theme.typography.body.lg.copyWith(
                        color: theme.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.typography.body.xl2.copyWith(
                          color: colorScheme.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.only(bottom: 4),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.border,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colors.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: _onTextChanged,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Slider Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Slider(
                      value: sliderValue,
                      min: 0.0,
                      max: _maxSliderLimit,
                      activeColor: theme.colors.primary,
                      onChanged: settingsState.isLoading
                          ? null
                          : _onSliderChanged,
                    ),

                    const SizedBox(height: 28),

                    // Button area
                    Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: .outline,
                            onPress: () => Navigator.of(context).pop(),
                            child: Text(t.common.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FButton(
                            onPress: settingsState.isLoading
                                ? null
                                : _handleSave,
                            child: settingsState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(t.common.save),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(financialSettingsProvider.notifier);
    notifier.updateSafetyThreshold(
      Decimal.parse(_currentValue.toStringAsFixed(0)),
    );

    final success = await notifier.saveFinancialSettings();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? t.financial.safetyThresholdSaved : t.financial.saveFailed,
          ),
        ),
      );
    }
  }
}

class _DailySpendingBottomSheet extends ConsumerStatefulWidget {
  const _DailySpendingBottomSheet();

  @override
  ConsumerState<_DailySpendingBottomSheet> createState() =>
      _DailySpendingBottomSheetState();
}

class _DailySpendingBottomSheetState
    extends ConsumerState<_DailySpendingBottomSheet> {
  double _currentValue = 100.0;
  bool _hasInitialized = false;
  bool _isUpdatingFromSlider = false;
  late final TextEditingController _controller;

  static const double _maxSliderLimit = 2000.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSliderChanged(double val) {
    _isUpdatingFromSlider = true;
    setState(() {
      _currentValue = val;
      _controller.text = val.toStringAsFixed(0);
    });
    _isUpdatingFromSlider = false;
  }

  void _onTextChanged(String text) {
    if (_isUpdatingFromSlider) return;
    final parsed = double.tryParse(text) ?? 0.0;
    setState(() {
      _currentValue = math.max(0.0, parsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final settingsState = ref.watch(financialSettingsProvider);
    final primaryCurrency = settingsState.primaryCurrency;
    final symbol = Currency.fromCode(primaryCurrency)?.symbol ?? '¥';

    if (!_hasInitialized && settingsState.dailyBurnRate != null) {
      _currentValue = settingsState.effectiveDailyBurnRate.toDouble();
      _controller.text = _currentValue.toStringAsFixed(0);
      _hasInitialized = true;
    }

    final double sliderValue = _currentValue.clamp(0.0, _maxSliderLimit);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      t.financial.dailyBurnRateSettings,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.financial.setDailyBurnRate,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Minimal Underline Amount Input Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      symbol,
                      style: theme.typography.body.lg.copyWith(
                        color: theme.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.typography.body.xl2.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.only(bottom: 4),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colors.border,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colors.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: _onTextChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.financial.dayUnit,
                      style: theme.typography.body.md.copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Slider Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Slider(
                      value: sliderValue,
                      min: 0.0,
                      max: _maxSliderLimit,
                      activeColor: theme.colors.primary,
                      onChanged: settingsState.isLoading
                          ? null
                          : _onSliderChanged,
                    ),

                    const SizedBox(height: 28),

                    // Button area
                    Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: .outline,
                            onPress: () => Navigator.of(context).pop(),
                            child: Text(t.common.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FButton(
                            onPress: settingsState.isLoading
                                ? null
                                : _handleSave,
                            child: settingsState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(t.common.save),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(financialSettingsProvider.notifier);
    notifier.updateDailyBurnRate(
      Decimal.parse(_currentValue.toStringAsFixed(0)),
    );

    final success = await notifier.saveFinancialSettings();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? t.financial.dailyBurnRateSaved : t.financial.saveFailed,
          ),
        ),
      );
    }
  }
}
