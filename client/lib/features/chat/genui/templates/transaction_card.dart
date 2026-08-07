import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/chat/genui/organisms/account_select_sheet.dart';
import 'package:finvo/features/chat/genui/atoms/atoms.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class TransactionCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const TransactionCard({super.key, required this.data});

  @override
  ConsumerState<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends ConsumerState<TransactionCard> {
  String? _selectedAccountId;
  String? _selectedAccountName;
  bool _isUpdating = false;

  List<String> _linkedSpaceIds = [];
  bool _isUpdatingSpace = false;

  List<Map<String, dynamic>>? _cachedSpaces;

  @override
  void initState() {
    super.initState();

    final linkedAccount = widget.data['linked_account'];
    if (linkedAccount is Map) {
      _selectedAccountId = linkedAccount['id']?.toString();
      _selectedAccountName = linkedAccount['name']?.toString();
    } else {
      // Fallback for non-enriched or legacy data
      _selectedAccountId = widget.data['account_id']?.toString();
      _selectedAccountName = widget.data['account_name']?.toString();
    }

    final spaceId = widget.data['space_id']?.toString();
    if (spaceId != null) {
      _linkedSpaceIds = [spaceId];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final amount = (widget.data['amount'] is num
        ? (widget.data['amount'] as num).toDouble()
        : double.tryParse(widget.data['amount']?.toString() ?? '0') ?? 0.0);
    final currency = widget.data['currency']?.toString() ?? 'CNY';
    final categoryKey = widget.data['category_key']?.toString();
    final categoryEnum = TransactionCategory.fromKey(categoryKey);
    final category = categoryEnum.displayText;

    final time = widget.data['time']?.toString() ?? '';
    final transactionType =
        widget.data['type']?.toString() ??
        widget.data['transaction_type']?.toString() ??
        'EXPENSE';

    final tagsRaw = widget.data['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((e) => e.toString()).toList()
        : <String>[];

    final hasAccount =
        _selectedAccountId != null && _selectedAccountId!.isNotEmpty;

    final hasSpaces = _linkedSpaceIds.isNotEmpty;

    final isExpense = transactionType.toUpperCase() == 'EXPENSE';
    final transactionType_ = isExpense
        ? TransactionType.expense
        : TransactionType.income;

    final transactionId = widget.data['transaction_id']?.toString();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _navigateToDetail(transactionId),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusHeader(theme, colors, time),
            _buildMainContent(
              theme,
              colors,
              category,
              categoryEnum,
              currency,
              amount,
              transactionType_,
              tags,
            ),
            _buildActionsFooter(theme, colors, hasAccount, hasSpaces),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(String? transactionId) {
    if (transactionId == null || transactionId.isEmpty) {
      ToastService.showWarning(
        description: Text(t.chat.genui.transactionCard.missingId),
      );
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

  Widget _buildStatusHeader(FThemeData theme, FColors colors, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1)),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FLucideIcons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t.chat.genui.transactionCard.title,
            style: AppTextStyles.actionText(theme),
          ),
          const Spacer(),
          Text(
            _formatTimeOnly(time),
            style: theme.typography.body.sm.copyWith(
              color: colors.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    FThemeData theme,
    FColors colors,
    String category,
    TransactionCategory categoryEnum,
    String currency,
    double amount,
    TransactionType transactionType,
    List<String> tags,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          ThemedIcon.large(icon: categoryEnum.icon),
          const SizedBox(height: 16),
          AmountText.large(
            amount: amount,
            type: transactionType,
            currency: currency,
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: AppTextStyles.listSubtitle(theme),
            textAlign: TextAlign.center,
          ),

          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: tags.map((tag) {
                return Tag(label: tag);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsFooter(
    FThemeData theme,
    FColors colors,
    bool hasAccount,
    bool hasSpaces,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.muted.withValues(alpha: 0.3)),
      child: Row(
        children: [
          Expanded(
            child: _buildActionPill(
              theme: theme,
              colors: colors,
              icon: hasAccount ? FLucideIcons.wallet : FLucideIcons.link,
              label: hasAccount
                  ? _selectedAccountName ??
                        t.chat.genui.transactionCard.associatedAccount
                  : t.chat.genui.transactionCard.associate,
              isActive: hasAccount,
              activeColor: colors.primary,
              isLoading: _isUpdating,
              onTap: _isUpdating ? null : _showAccountSelector,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionPill(
              theme: theme,
              colors: colors,
              icon: hasSpaces ? FLucideIcons.users : FLucideIcons.plus,
              label: hasSpaces
                  ? '${_linkedSpaceIds.length} ${t.chat.genui.transactionCard.sharedSpace}'
                  : t.chat.genui.transactionCard.sharedSpace,
              isActive: hasSpaces,
              activeColor: theme.semantic.sharedSpaceAccent,
              isLoading: _isUpdatingSpace,
              onTap: _isUpdatingSpace ? null : _showSpaceSelector,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill({
    required FThemeData theme,
    required FColors colors,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required bool isLoading,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : colors.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isActive ? activeColor : colors.mutedForeground,
                  ),
                ),
              )
            else
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

  Future<void> _showAccountSelector() async {
    FocusScope.of(context).unfocus();

    var accountState = ref.read(financialAccountProvider);

    if (accountState.accounts.isEmpty && !accountState.isLoading) {
      await ref.read(financialAccountProvider.notifier).loadFinancialAccounts();
      if (!mounted) return;
      accountState = ref.read(financialAccountProvider);
    }

    final accountList = accountState.accounts;

    final accounts = accountList
        .where(
          (a) =>
              a.status == AccountStatus.active &&
              a.nature == FinancialNature.asset,
        )
        .map(
          (a) => {
            'id': a.id,
            'name': a.name,
            'type': a.type?.name ?? 'unknown',
          },
        )
        .toList();

    if (accounts.isEmpty) {
      if (!mounted) return;
      ToastService.show(
        description: Text(t.chat.genui.transactionCard.noAccount),
      );
      return;
    }

    if (!mounted) return;

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountSelectSheet(
        accounts: accounts,
        selectedId: _selectedAccountId,
        title: t.chat.genui.transactionCard.selectAccount,
      ),
    );

    if (selectedId != null && selectedId != _selectedAccountId) {
      await _updateAccount(selectedId, accounts);
    }
  }

  Future<void> _updateAccount(
    String accountId,
    List<Map<String, dynamic>> accounts,
  ) async {
    final transactionId = widget.data['transaction_id']?.toString();
    if (transactionId == null) {
      ToastService.showWarning(
        description: Text(t.chat.genui.transactionCard.missingId),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final result = await _updateTransactionAccountApi(
        transactionId: transactionId,
        accountId: accountId,
      );

      if (result['code'] == 0) {
        String? accountName;
        for (final acc in accounts) {
          if (acc['id'] == accountId) {
            accountName = acc['name']?.toString();
            break;
          }
        }

        // The card may have been disposed while the PATCH was in flight.
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedAccountId = accountId;
          _selectedAccountName = accountName;
          _isUpdating = false;
        });

        ToastService.success(
          description: Text(
            t.chat.genui.transactionCard.associatedTo(
              name: accountName ?? t.financial.title,
            ),
          ),
        );

        unawaited(
          ref.read(financialAccountProvider.notifier).loadFinancialAccounts(),
        );
      } else {
        throw Exception(result['message'] ?? t.financial.saveFailed);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ToastService.showDestructive(
        description: Text(
          t.chat.genui.transactionCard.updateFailed(error: e.toString()),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _updateTransactionAccountApi({
    required String transactionId,
    required String accountId,
  }) async {
    final networkClient = ref.read(networkClientProvider);
    final result = await networkClient.requestMap(
      '/transactions/$transactionId/account',
      method: HttpMethod.patch,
      data: {'account_id': accountId},
    );
    return result;
  }

  Future<void> _showSpaceSelector() async {
    FocusScope.of(context).unfocus();

    final theme = context.theme;
    final colors = theme.colors;

    if (_cachedSpaces == null) {
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
        } else {
          _cachedSpaces = [];
        }
      } catch (e) {
        _cachedSpaces = [];
      }
    }

    if (_cachedSpaces!.isEmpty) {
      if (!mounted) return;
      ToastService.show(
        description: Text(t.chat.genui.transactionCard.noSpace),
      );
      return;
    }

    if (!mounted) return;

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
              t.chat.genui.transactionCard.selectSpace,
              style: AppTextStyles.listTitle(theme),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _cachedSpaces!.length,
                itemBuilder: (context, index) {
                  final space = _cachedSpaces![index];
                  final spaceId = space['id']?.toString();
                  final isSelected = _linkedSpaceIds.contains(spaceId);
                  return ListTile(
                    leading: Icon(
                      FLucideIcons.users,
                      color: isSelected
                          ? colors.primary
                          : colors.mutedForeground,
                    ),
                    title: Text(space['name']?.toString() ?? ''),
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

    if (selectedSpaceId != null && mounted) {
      await _updateTransactionSpace(selectedSpaceId);
    }
  }

  Future<void> _updateTransactionSpace(String spaceId) async {
    final transactionId = widget.data['transaction_id']?.toString();
    if (transactionId == null) {
      ToastService.showWarning(
        description: Text(t.chat.genui.transactionCard.missingId),
      );
      return;
    }

    setState(() => _isUpdatingSpace = true);

    try {
      final networkClient = ref.read(networkClientProvider);
      await networkClient.requestMap(
        '/shared-spaces/$spaceId/transactions',
        method: HttpMethod.post,
        data: {'transaction_id': transactionId},
      );

      // The card may have been disposed while the POST was in flight.
      if (!mounted) return;
      setState(() {
        if (!_linkedSpaceIds.contains(spaceId)) {
          _linkedSpaceIds = [..._linkedSpaceIds, spaceId];
        }
        _isUpdatingSpace = false;
      });

      ToastService.success(
        description: Text(t.chat.genui.transactionCard.linkedToSpace),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdatingSpace = false);
      ToastService.showDestructive(
        description: Text(
          t.chat.genui.transactionCard.updateFailed(error: e.toString()),
        ),
      );
    }
  }

  String _formatTimeOnly(String isoTime) {
    if (isoTime.isEmpty) {
      final now = DateTime.now();
      return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
