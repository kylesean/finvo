import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/chat/genui/organisms/account_picker_card.dart';
import 'package:finvo/features/chat/genui/templates/transaction_group_receipt_parts.dart';
import 'package:finvo/features/chat/genui/templates/transaction_group_receipt_sheets.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/utils/error_display.dart';

/// Batch transaction receipt component
///
/// Supports carousel and list view mode switching
/// Each transaction has independent account association (per-transaction operation)
class TransactionGroupReceipt extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final void Function(UiEvent)? dispatchEvent;

  const TransactionGroupReceipt({
    super.key,
    required this.data,
    this.dispatchEvent,
  });

  @override
  ConsumerState<TransactionGroupReceipt> createState() =>
      _TransactionGroupReceiptState();
}

class _TransactionGroupReceiptState
    extends ConsumerState<TransactionGroupReceipt> {
  static final _log = Logger('TransactionGroupReceipt');

  bool _isListView = false;
  int _currentIndex = 0;
  late final PageController _pageController;

  /// Account association state per transaction
  final Map<String, String?> _accountAssociations = {};

  /// Shared space association state per transaction
  final Map<String, List<String>> _spaceAssociations = {};

  /// Set of transaction IDs currently updating account
  final Set<String> _updatingTransactions = {};

  /// Set of transaction IDs currently updating shared space
  final Set<String> _updatingSpaceTransactions = {};

  /// Cached shared space list
  List<Map<String, dynamic>>? _cachedSpaces;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAccountAssociations();
    // Async refresh latest account association state
    unawaited(_refreshAccountAssociations());
  }

  void _initializeAccountAssociations() {
    final transactions = (widget.data['transactions'] as List? ?? []);
    for (final tx in transactions) {
      // AI-provided payloads are untrusted: skip malformed entries instead of
      // throwing a TypeError during initState (same policy as build()).
      final txMap = _toTxMap(tx);
      if (txMap == null) continue;
      final id = txMap['id']?.toString();
      if (id != null) {
        // Prefer source_account_id (expense), otherwise use target_account_id (income)
        final accountId =
            txMap['source_account_id']?.toString() ??
            txMap['target_account_id']?.toString();
        _accountAssociations[id] = accountId;

        // Initialize shared space association
        final spaceId = txMap['space_id']?.toString();
        if (spaceId != null) {
          _spaceAssociations[id] = [spaceId];
        } else {
          _spaceAssociations[id] = [];
        }
      }
    }
  }

  /// Refresh latest account association state from server (parallel request optimization)
  Future<void> _refreshAccountAssociations() async {
    final transactions = (widget.data['transactions'] as List? ?? []);
    if (transactions.isEmpty) return;

    final transactionIds = transactions
        .map((tx) => _toTxMap(tx)?['id']?.toString())
        .where((id) => id != null)
        .cast<String>()
        .toList();

    if (transactionIds.isEmpty) return;

    try {
      final networkClient = ref.read(networkClientProvider);

      // Parallel fetch all transaction details
      final results = await Future.wait(
        transactionIds.map((txId) async {
          try {
            return await networkClient.requestMap(
              '/transactions/$txId',
              method: HttpMethod.get,
            );
          } catch (e) {
            _log.warning('Failed to fetch transaction $txId', e);
            return <String, dynamic>{};
          }
        }),
      );

      // Process all results
      if (mounted) {
        setState(() {
          for (int i = 0; i < transactionIds.length; i++) {
            final txId = transactionIds[i];
            final result = results[i];

            if (result['code'] == 0 && result['data'] != null) {
              final data = result['data'] as Map<String, dynamic>;
              // Get correct account ID based on transaction type
              final type = data['type']?.toString().toUpperCase() ?? 'EXPENSE';
              String? accountId;
              if (type == 'INCOME') {
                accountId = data['targetAccountId']?.toString();
              } else {
                accountId = data['sourceAccountId']?.toString();
              }

              _accountAssociations[txId] = accountId;

              // Sync shared space association
              final spaces = data['spaces'] as List<dynamic>?;
              if (spaces != null) {
                _spaceAssociations[txId] = spaces
                    .whereType<Map<String, dynamic>>()
                    .map((s) => s['id']?.toString())
                    .whereType<String>()
                    .toList();
              }
            }
          }
        });
      }
    } catch (e) {
      _log.warning('Failed to refresh account associations', e);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==================== Molecules ====================

  /// Molecule 1: Transaction info (icon + info + amount)
  /// Following home page flow card layout
  Widget _moleculeTransactionInfo(
    FThemeData theme,
    FColors colors,
    TransactionCategory category,
    List<String> tags,
    Decimal amount,
    bool isExpense, {
    double iconSize = 44,
    String? currency,
  }) {
    return buildGroupTransactionInfo(
      theme,
      colors,
      category,
      tags,
      amount,
      isExpense,
      iconSize: iconSize,
      currency: currency,
    );
  }

  /// Molecule 3: Actions (account + space button group)
  Widget _moleculeActions(
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> tx,
  ) {
    final txId = tx['id']?.toString();
    final currentAccountId = _accountAssociations[txId];
    final account = ref
        .watch(financialAccountProvider)
        .accounts
        .where((a) => a.id == currentAccountId)
        .firstOrNull;
    final associatedIds = _spaceAssociations[txId] ?? [];

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showAccountPicker(tx),
            child: _atomActionPill(
              theme,
              colors,
              icon: account != null ? FLucideIcons.wallet : FLucideIcons.link,
              label:
                  account?.name ??
                  t.chat.genui.transactionGroupReceipt.accountAssociation,
              activeColor: colors.primary,
              isActive: account != null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _showSpacePicker(tx),
            child: _atomActionPill(
              theme,
              colors,
              icon: associatedIds.isNotEmpty
                  ? FLucideIcons.users
                  : FLucideIcons.plus,
              label: associatedIds.isNotEmpty
                  ? t.chat.genui.transactionGroupReceipt.spaceCount(
                      count: associatedIds.length,
                    )
                  : t.chat.genui.transactionGroupReceipt.sharedSpace,
              activeColor: context.theme.semantic.sharedSpaceAccent,
              isActive: associatedIds.isNotEmpty,
            ),
          ),
        ),
      ],
    );
  }

  /// Atom: Action pill style
  Widget _atomActionPill(
    FThemeData theme,
    FColors colors, {
    required IconData icon,
    required String label,
    required Color activeColor,
    required bool isActive,
  }) {
    return buildGroupActionPill(
      theme,
      colors,
      icon: icon,
      label: label,
      activeColor: activeColor,
      isActive: isActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final transactions = (widget.data['transactions'] as List? ?? []);

    Decimal totalAmount = Decimal.zero;
    // Bucket totals by transaction type: mixing income and expense in a single
    // sum (the previous behaviour) produces a misleading financial figure, and
    // the header used to hard-code expense styling regardless of content.
    // The per-item type check mirrors the one used when rendering each row.
    Decimal expenseTotal = Decimal.zero;
    Decimal incomeTotal = Decimal.zero;
    for (final tx in transactions) {
      // AI-provided payloads are untrusted: an element that is not a Map
      // must not crash the whole card during build.
      if (tx is! Map) continue;
      final amount = AmountFormatter.parseDecimal(tx['amount']?.toString());
      if (tx['type']?.toString().toUpperCase() == 'INCOME') {
        incomeTotal += amount;
      } else {
        expenseTotal += amount;
      }
    }
    // Single-type groups show their own total; mixed groups show the dominant
    // bucket with its correct type styling.
    final bool totalIsExpense = expenseTotal >= incomeTotal;
    totalAmount = totalIsExpense ? expenseTotal : incomeTotal;

    if (transactions.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(
            theme,
            colors,
            transactions.length,
            totalAmount,
            isExpenseTotal: totalIsExpense,
          ),

          // Content
          AnimatedCrossFade(
            firstChild: _buildCarouselView(theme, colors, transactions),
            secondChild: _buildListView(theme, colors, transactions),
            crossFadeState: _isListView
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    FThemeData theme,
    FColors colors,
    int count,
    Decimal totalAmount, {
    required bool isExpenseTotal,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ), // Restore compact layout
      decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.05)),
      child: Row(
        children: [
          Icon(FLucideIcons.layers, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t.chat.genui.transactionGroupReceipt.title} ${t.chat.genui.transactionGroupReceipt.count(count: count)}',
                  style: AppTextStyles.actionText(theme),
                ),
                Row(
                  children: [
                    Text(
                      '${t.chat.genui.transactionGroupReceipt.total} ',
                      style: AppTextStyles.detailLabel(theme),
                    ),
                    AmountText(
                      amount: totalAmount,
                      type: isExpenseTotal
                          ? TransactionType.expense
                          : TransactionType.income,
                      semantic: AmountSemantic.status,
                      showSign: false,
                      style: AppTextStyles.statLabel(theme),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Toggle button
          _buildToggle(theme, colors),
        ],
      ),
    );
  }

  Widget _buildToggle(FThemeData theme, FColors colors) {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: FLucideIcons.layoutPanelLeft,
            isSelected: !_isListView,
            onTap: () => setState(() => _isListView = false),
            colors: colors,
          ),
          _buildToggleButton(
            icon: FLucideIcons.list,
            isSelected: _isListView,
            onTap: () => setState(() => _isListView = true),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required FColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? colors.primary : colors.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildCarouselView(
    FThemeData theme,
    FColors colors,
    List<dynamic> transactions,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 196, // Increased height to prevent content overflow
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = _toTxMap(transactions[index]);
              if (tx == null) return const SizedBox.shrink();
              return _buildCarouselItem(theme, colors, tx);
            },
          ),
        ),
        if (transactions.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                transactions.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? colors.primary
                        : colors.muted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCarouselItem(
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> tx,
  ) {
    final category = TransactionCategory.fromKey(
      tx['category_key']?.toString(),
    );
    final tags = (tx['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];

    // Prefer original currency and amount (for exchange rate conversion scenarios)
    // Backend returns camelCase: originalAmount, originalCurrency
    final originalAmount = tx['originalAmount'] != null
        ? AmountFormatter.parseDecimal(tx['originalAmount'].toString())
        : null;
    final originalCurrency = tx['originalCurrency']?.toString();

    final amount =
        originalAmount ??
        AmountFormatter.parseDecimal(tx['amount']?.toString());
    final isExpense = tx['type']?.toString().toUpperCase() != 'INCOME';
    // Parenthesize: `as` binds tighter than `??`, so the un-parenthesized
    // form (`a ?? b as T`) would leave `a` untyped dynamic on the left.
    final currency = originalCurrency ?? tx['currency']?.toString();

    final transactionId = tx['id']?.toString();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _navigateToTransactionDetail(transactionId),
      child: Container(
        // Height auto-adapts, no longer forcing a large fixed size to avoid gaps
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _moleculeTransactionInfo(
              theme,
              colors,
              category,
              tags,
              amount,
              isExpense,
              currency: currency,
            ),
            const SizedBox(height: 20),
            _moleculeActions(theme, colors, tx),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
    FThemeData theme,
    FColors colors,
    List<dynamic> transactions,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: transactions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: colors.border.withValues(alpha: 0.1)),
        itemBuilder: (context, index) {
          final tx = _toTxMap(transactions[index]);
          if (tx == null) return const SizedBox.shrink();
          return _buildListItem(theme, colors, tx);
        },
      ),
    );
  }

  /// Safely coerce an AI-provided transaction entry into a map, skipping
  /// malformed elements instead of throwing a TypeError during build.
  Map<String, dynamic>? _toTxMap(dynamic item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return Map<String, dynamic>.from(item);
    return null;
  }

  Widget _buildListItem(
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> tx,
  ) {
    final category = TransactionCategory.fromKey(
      tx['category_key']?.toString(),
    );
    final tags = (tx['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];

    // Prefer original currency and amount (for exchange rate conversion scenarios)
    // Backend returns camelCase: originalAmount, originalCurrency
    final originalAmount = tx['originalAmount'] != null
        ? AmountFormatter.parseDecimal(tx['originalAmount'].toString())
        : null;
    final originalCurrency = tx['originalCurrency']?.toString();

    final amount =
        originalAmount ??
        AmountFormatter.parseDecimal(tx['amount']?.toString());
    final isExpense = tx['type']?.toString().toUpperCase() != 'INCOME';
    final currency = originalCurrency ?? tx['currency']?.toString();

    final transactionId = tx['id']?.toString();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _navigateToTransactionDetail(transactionId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _moleculeTransactionInfo(
              theme,
              colors,
              category,
              tags,
              amount,
              isExpense,
              iconSize: 40,
              currency: currency,
            ),
            const SizedBox(height: 12),
            _moleculeActions(theme, colors, tx),
          ],
        ),
      ),
    );
  }

  /// Navigate to transaction detail page
  void _navigateToTransactionDetail(String? transactionId) {
    if (transactionId == null || transactionId.isEmpty) {
      _log.warning('Transaction ID is null or empty, cannot navigate');
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    unawaited(
      context.pushNamed(
        AppRouteNames.transactionDetail,
        pathParameters: {'transactionId': transactionId},
      ),
    );
  }

  Future<void> _showAccountPicker(Map<String, dynamic> tx) async {
    final txId = tx['id']?.toString();
    if (txId == null) return;

    final theme = context.theme;
    final colors = theme.colors;

    // Get transaction currency. Fallback must match the app-wide default
    // ('CNY', used by every other fallback site): 'USD' here made the
    // currency-mismatch confirmation dialog fire incorrectly.
    final txCurrency =
        (tx['originalCurrency']?.toString()) ??
        (tx['currency']?.toString()) ??
        'CNY';

    // Get transaction amount
    final txAmount = tx['originalAmount'] != null
        ? AmountFormatter.parseDecimal(tx['originalAmount'].toString())
        : AmountFormatter.parseDecimal(tx['amount']?.toString());

    var accountState = ref.read(financialAccountProvider);
    if (accountState.accounts.isEmpty && !accountState.isLoading) {
      await ref.read(financialAccountProvider.notifier).loadFinancialAccounts();
      accountState = ref.read(financialAccountProvider);
    }

    final printableAccounts = accountState.accounts
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
            'currencyCode': a.currencyCode, // Include currency info
          },
        )
        .toList();

    // If no available accounts, show a hint
    if (printableAccounts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.chat.genui.transactionCard.noAccount),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentAccountId = _accountAssociations[txId];

    if (!mounted) return;

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
          accounts: printableAccounts,
          selectedId: currentAccountId,
          title: t.chat.genui.transactionCard.selectAccount,
          transactionCurrency: txCurrency, // Pass transaction currency
          onSelect: (id) {
            Navigator.pop(context, id);
          },
          onConfirm: () {},
        ),
      ),
    );
    if (selectedId == null) return;
    if (!mounted) return;
    // Get selected account
    final selectedAccount = accountState.accounts
        .where((a) => a.id == selectedId)
        .firstOrNull;

    if (selectedAccount != null) {
      final accountCurrency = selectedAccount.currencyCode.toUpperCase();
      final transactionCurrency = txCurrency.toUpperCase();

      // Currency mismatch, show confirmation dialog
      if (accountCurrency != transactionCurrency) {
        final confirmed = await showCurrencyMismatchConfirmDialog(
          context,
          amount: txAmount,
          fromCurrency: transactionCurrency,
          toCurrency: accountCurrency,
          accountName: selectedAccount.name,
        );

        if (confirmed != true) return;
      }
    }

    await _updateTransactionAccount(txId, selectedId);
  }

  Future<void> _updateTransactionAccount(
    String transactionId,
    String accountId,
  ) async {
    if (!mounted) return;
    setState(() => _updatingTransactions.add(transactionId));

    try {
      final networkClient = ref.read(networkClientProvider);
      final result = await networkClient.requestMap(
        '/transactions/$transactionId/account',
        method: HttpMethod.patch,
        data: {'account_id': accountId},
      );

      if (result['code'] == 0) {
        // The page may have been popped while the PATCH was in flight.
        if (!mounted) return;
        setState(() {
          _accountAssociations[transactionId] = accountId;
          _updatingTransactions.remove(transactionId);
        });

        final accountState = ref.read(financialAccountProvider);
        final acc = accountState.accounts
            .where((a) => a.id == accountId)
            .firstOrNull;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.chat.genui.transactionCard.associatedTo(name: acc?.name ?? ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: context.theme.colors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        unawaited(
          ref.read(financialAccountProvider.notifier).loadFinancialAccounts(),
        );
      } else {
        throw Exception(result['message'] ?? 'Update failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _updatingTransactions.remove(transactionId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.chat.genui.transactionCard.updateFailed(
              error: friendlyErrorMessage(e),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: context.theme.colors.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSpacePicker(Map<String, dynamic> tx) async {
    final txId = tx['id']?.toString();
    if (txId == null) return;

    // Always try to fetch fresh: a lifetime cache hides spaces created after
    // the first open. On failure fall back to the last good cache.
    try {
      final networkClient = ref.read(networkClientProvider);
      final result = await networkClient.requestMap(
        '/shared-spaces',
        method: HttpMethod.get,
      );

      if (result['code'] == 0 && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        _cachedSpaces = (data['spaces'] as List? ?? [])
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      _log.warning('Failed to load spaces, using cached list if any', e);
    }

    if (_cachedSpaces == null || _cachedSpaces!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.chat.genui.transactionCard.noSpace),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final associatedIds = _spaceAssociations[txId] ?? [];

    if (!mounted) return;

    final selectedId = await showSpacePickerSheet(
      context,
      spaces: _cachedSpaces!,
      associatedIds: associatedIds,
    );
    if (selectedId != null) {
      await _updateTransactionSpace(txId, selectedId);
    }
  }

  Future<void> _updateTransactionSpace(
    String transactionId,
    dynamic spaceId,
  ) async {
    if (!mounted) return;
    setState(() => _updatingSpaceTransactions.add(transactionId));

    try {
      final networkClient = ref.read(networkClientProvider);
      final result = await networkClient.requestMap(
        '/shared-spaces/$spaceId/transactions',
        method: HttpMethod.post,
        data: {'transaction_id': transactionId},
      );

      if (result['code'] == 0) {
        final newSpaceId = spaceId.toString();
        // The page may have been popped while the POST was in flight.
        if (!mounted) return;
        setState(() {
          final list = _spaceAssociations[transactionId] ?? [];
          if (!list.contains(newSpaceId)) {
            list.add(newSpaceId);
          }
          _spaceAssociations[transactionId] = list;
          _updatingSpaceTransactions.remove(transactionId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.chat.genui.transactionGroupReceipt.spaceAssociateSuccess,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: context.theme.colors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Association failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _updatingSpaceTransactions.remove(transactionId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.chat.genui.transactionGroupReceipt.spaceAssociateFailed(
              error: e.toString(),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: context.theme.colors.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
