import 'dart:async';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
// features/home/pages/transaction_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finvo/shared/models/action_item_model.dart';
import 'package:finvo/shared/widgets/dialogs/action_bottom_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../widgets/feed/comment_section_widget.dart';
import '../widgets/feed/comment_input_bar.dart';
import '../widgets/feed/attachment_section_widget.dart';
import '../providers/transaction_detail_provider.dart';
import '../widgets/transaction_detail_skeleton.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/features/chat/genui/organisms/account_picker_card.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/home/services/home_service.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class TransactionDetailPage extends ConsumerWidget {
  final String transactionId;
  final String? targetCommentId;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
    this.targetCommentId,
  });

  /// Get category display name
  String _getCategoryDisplayName(TransactionModel transaction) {
    // Prefer server-returned localized name
    if (transaction.categoryText != null &&
        transaction.categoryText!.isNotEmpty) {
      return transaction.categoryText!;
    }
    // Use TransactionCategory to get localized name
    if (transaction.categoryKey != null &&
        transaction.categoryKey!.isNotEmpty) {
      return TransactionCategory.fromKey(transaction.categoryKey!).displayText;
    }
    return transaction.category;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure real-time WebSocket connection is active for live comment sync
    ref.watch(notificationWsProvider);

    final detailState = ref.watch(transactionDetailProvider(transactionId));
    final theme = context.theme;
    final colors = theme.colors;

    // Show skeleton screen
    if (detailState.isLoading && detailState.transaction == null) {
      return const TransactionDetailSkeleton();
    }

    // Show error state
    if (detailState.errorMessage != null && detailState.transaction == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildPageHeader(context, theme, colors, null),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FLucideIcons.ellipsis,
                        size: 48,
                        color: colors.destructive,
                      ),
                      const SizedBox(height: 16),
                      Text(t.home.loadFailed, style: theme.typography.body.xl2),
                      const SizedBox(height: 8),
                      Text(
                        detailState.errorMessage!,
                        style: AppTextStyles.listSubtitle(theme),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FButton(
                        onPress: () {
                          unawaited(
                            ref
                                .read(
                                  transactionDetailProvider(
                                    transactionId,
                                  ).notifier,
                                )
                                .reload(),
                          );
                        },
                        child: Text(t.common.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final transaction = detailState.transaction;
    if (transaction == null) {
      return const TransactionDetailSkeleton();
    }

    // Page header
    final pageHeader = _buildPageHeader(context, theme, colors, transaction);

    return Scaffold(
      // Still use Scaffold as root so CommentInputBar can be properly pinned to bottom
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.background, // Page background color from theme
      body: SafeArea(
        // Use SafeArea
        child: Column(
          children: [
            pageHeader,
            Expanded(
              child: CustomScrollView(
                // Keep CustomScrollView for scrolling when content overflows
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      // Wrap main detail area with FCard
                      child: AppCard(
                        style: const .delta(padding: .value(EdgeInsets.zero)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Top: category icon, category name, time, more actions button ---
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: ThemedIcon.large(
                                      icon: TransactionCategory.fromKey(
                                        transaction.categoryKey,
                                      ).icon,
                                      backgroundColor: colors.primary
                                          .withValues(alpha: 0.1),
                                      iconColor: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getCategoryDisplayName(transaction),
                                          style: AppTextStyles.detailValueLarge(
                                            theme,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          timeago.format(
                                            transaction.timestamp,
                                            locale: 'zh_CN',
                                          ),
                                          style: theme.typography.body.sm
                                              .copyWith(
                                                color: colors.mutedForeground,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FButton.icon(
                                    // More actions button
                                    variant: .ghost,
                                    onPress: () => _showTransactionActions(
                                      context,
                                      ref,
                                      transaction,
                                    ),
                                    child: Icon(
                                      FLucideIcons.ellipsis,
                                      color: colors.mutedForeground,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Amount with subtle primary-tinted background
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AmountText.large(
                                    amount: transaction.amount,
                                    type: transaction.type,
                                    currency:
                                        transaction.paymentMethod ?? 'CNY',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Status indicator chip
                              if (transaction.status == 'PENDING')
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.semantic.warningBackground,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t.transaction.statusPending,
                                      style: theme.typography.body.xs.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: theme.semantic.warningAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              if (transaction.status == 'PENDING')
                                const SizedBox(height: 12),

                              // Linked account and space actions
                              _buildAccountSpaceActions(
                                context,
                                ref,
                                theme,
                                colors,
                                transaction,
                              ),

                              const SizedBox(height: 16),
                              const FDivider(axis: Axis.horizontal),
                              const SizedBox(height: 12),
                              // Detail row - original entry text (user's raw input)
                              _buildDetailRow(
                                context,
                                icon: FLucideIcons.messageSquareText,
                                label: t.transaction.rawInput,
                                valueWidget: GestureDetector(
                                  onTap: transaction.sourceThreadId != null
                                      ? () {
                                          unawaited(
                                            HapticFeedback.lightImpact(),
                                          );
                                          context.go(
                                            '/ai/${transaction.sourceThreadId}',
                                          );
                                        }
                                      : null,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          transaction.rawInput ??
                                              t.transaction.noRawInput,
                                          style: theme.typography.body.sm
                                              .copyWith(
                                                color: colors.foreground,
                                                fontWeight: FontWeight.normal,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (transaction.sourceThreadId !=
                                          null) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          FLucideIcons.externalLink,
                                          size: 14,
                                          color: colors.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              _buildDetailRow(
                                context,
                                icon: FLucideIcons.calendarClock,
                                label: t.transaction.time,
                                valueWidget: Text(
                                  DateFormat(
                                    'yyyy年M月d日 HH:mm:ss',
                                    'zh_CN',
                                  ).format(transaction.timestamp),
                                  style: theme.typography.body.sm.copyWith(
                                    color: colors.foreground,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (transaction.location != null &&
                                  transaction.location!.isNotEmpty)
                                _buildDetailRow(
                                  context,
                                  icon: FLucideIcons.mapPin,
                                  label: t.transaction.location,
                                  valueWidget: Text(
                                    transaction.location!,
                                    style: theme.typography.body.sm.copyWith(
                                      color: colors.foreground,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                              if (transaction.tags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                _buildDetailRow(
                                  context,
                                  icon: FLucideIcons.tags,
                                  label: t.transaction.tags,
                                  valueWidget: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 6.0,
                                    children: transaction.tags
                                        .map(
                                          (tag) => FBadge(
                                            // Use FBadge
                                            variant: .secondary,
                                            child: Text(
                                              tag,
                                              style: theme.typography.body.sm
                                                  .copyWith(fontSize: 11),
                                            ),
                                            // FBadge has appropriate padding and border radius by default
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- Attachment section ---
                  if (transaction.attachments.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: AttachmentSectionWidget(
                          attachments: transaction.attachments,
                        ),
                      ),
                    ),
                  // --- Comment section ---
                  SliverToBoxAdapter(
                    child: CommentSectionWidget(
                      transactionId: transaction.id,
                      targetCommentId: targetCommentId,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                    ), // Bottom spacing to prevent overlap with input bar
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Comment input bar
      bottomNavigationBar: CommentInputBar(
        transactionId: transaction.id,
        spaces: transaction.spaces,
        recorderUserId: transaction.sharedWith.isNotEmpty
            ? transaction.sharedWith.first.userId
            : null,
      ),
    );
  }

  // Build page header
  Widget _buildPageHeader(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    TransactionModel? transaction,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          FButton.icon(
            variant: .ghost,
            onPress: () => GoRouter.of(context).pop(),
            child: Icon(
              FLucideIcons.arrowLeft,
              size: 20,
              color: colors.foreground,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.transaction.transactionDetail,
              style: AppTextStyles.pageTitle(theme),
              textAlign: TextAlign.center, // Center the title
            ),
          ),
          // Right spacer to keep title centered, or can hold other action buttons
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // Detail row - optimized for i18n with flexible width
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget valueWidget,
  }) {
    final theme = context.theme;
    final colors = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and label use fixed-width Row for alignment
          SizedBox(
            width: 90, // Wider to accommodate English labels
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: colors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
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
          const SizedBox(width: 12),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  /// Build linked account and space actions section
  Widget _buildAccountSpaceActions(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    FColors colors,
    TransactionModel transaction,
  ) {
    // Get linked account info
    final isExpense = transaction.type == TransactionType.expense;
    final accountId = isExpense
        ? transaction.sourceAccountId
        : transaction.targetAccountId;

    // Get account info from Provider
    final accountState = ref.watch(financialAccountProvider);
    final linkedAccount = accountId != null
        ? accountState.accounts.where((a) => a.id == accountId).firstOrNull
        : null;

    // Get linked space info
    final spaces = transaction.spaces;
    final hasSpaces = spaces.isNotEmpty;

    return Row(
      children: [
        // Linked account button
        Expanded(
          child: _buildActionPill(
            context: context,
            theme: theme,
            colors: colors,
            icon: linkedAccount != null
                ? FLucideIcons.wallet
                : FLucideIcons.link,
            label: linkedAccount?.name ?? t.transaction.linkedAccount,
            isActive: linkedAccount != null,
            activeColor: colors.primary,
            onTap: () => _showAccountPicker(context, ref, transaction),
          ),
        ),
        const SizedBox(width: 8),
        // Linked space button
        Expanded(
          child: _buildActionPill(
            context: context,
            theme: theme,
            colors: colors,
            icon: hasSpaces ? FLucideIcons.users : FLucideIcons.plus,
            label: hasSpaces
                ? t.transaction.nSpaces(count: spaces.length.toString())
                : t.transaction.linkedSpace,
            isActive: hasSpaces,
            activeColor: theme.semantic.sharedSpaceAccent,
            onTap: () => _showSpacePicker(context, ref, transaction),
          ),
        ),
      ],
    );
  }

  /// Pill button style
  Widget _buildActionPill({
    required BuildContext context,
    required FThemeData theme,
    required FColors colors,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : colors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  /// Show account picker bottom sheet
  Future<void> _showAccountPicker(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) async {
    final theme = context.theme;
    final colors = theme.colors;

    // Load account list
    var accountState = ref.read(financialAccountProvider);
    if (accountState.accounts.isEmpty && !accountState.isLoading) {
      await ref.read(financialAccountProvider.notifier).loadFinancialAccounts();
      if (!context.mounted) return;
      accountState = ref.read(financialAccountProvider);
    }

    // Filter available accounts
    final accounts = accountState.accounts
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
            'currencyCode': a.currencyCode,
          },
        )
        .toList();

    if (accounts.isEmpty) {
      if (!context.mounted) return;
      ToastService.show(
        description: Text(t.chat.genui.transactionCard.noAccount),
      );
      return;
    }

    // Get current account ID
    final isExpense = transaction.type == TransactionType.expense;
    final currentAccountId = isExpense
        ? transaction.sourceAccountId
        : transaction.targetAccountId;

    if (!context.mounted) return;

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
          accounts: accounts,
          selectedId: currentAccountId,
          title: t.transaction.selectLinkedAccount,
          transactionCurrency: transaction.paymentMethod ?? 'CNY',
          onSelect: (id) => Navigator.pop(context, id),
          onConfirm: () {},
        ),
      ),
    );

    if (selectedId != null && context.mounted) {
      await _updateTransactionAccount(context, ref, transaction.id, selectedId);
    }
  }

  /// Update transaction linked account
  Future<void> _updateTransactionAccount(
    BuildContext context,
    WidgetRef ref,
    String transactionId,
    String accountId,
  ) async {
    try {
      final homeService = ref.read(homeServiceProvider);
      await homeService.updateTransactionAccount(transactionId, accountId);

      if (context.mounted) {
        // Reload transaction detail
        unawaited(
          ref.read(transactionDetailProvider(transactionId).notifier).reload(),
        );
        // Refresh account list to update balances
        unawaited(
          ref.read(financialAccountProvider.notifier).loadFinancialAccounts(),
        );
        ToastService.success(description: Text(t.transaction.linkSuccess));
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showDestructive(
          description: Text(t.transaction.linkFailed),
        );
      }
    }
  }

  /// Show space picker bottom sheet
  Future<void> _showSpacePicker(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) async {
    final theme = context.theme;
    final colors = theme.colors;

    try {
      // Load space list
      final homeService = ref.read(homeServiceProvider);
      final result = await homeService.listSharedSpaces();

      if (!context.mounted) return;

      final spaces = result;

      if (spaces.isEmpty) {
        ToastService.show(description: Text(t.transaction.noSpacesAvailable));
        return;
      }

      // Get currently linked space IDs
      final currentSpaceIds = transaction.spaces.map((s) => s.id).toSet();

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
                t.transaction.selectLinkedSpace,
                style: AppTextStyles.listTitle(theme),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: spaces.length,
                  itemBuilder: (context, index) {
                    final space = spaces[index];
                    final spaceId = space['id']?.toString();
                    final isSelected = currentSpaceIds.contains(spaceId);
                    return ListTile(
                      leading: Icon(
                        FLucideIcons.users,
                        color: isSelected
                            ? colors.primary
                            : colors.mutedForeground,
                      ),
                      title: Text((space['name'] as String?) ?? ''),
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

      if (selectedSpaceId != null && context.mounted) {
        await _linkTransactionToSpace(
          context,
          ref,
          transaction.id,
          selectedSpaceId,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showDestructive(
          description: Text(t.transaction.linkFailed),
        );
      }
    }
  }

  /// Link transaction to space
  Future<void> _linkTransactionToSpace(
    BuildContext context,
    WidgetRef ref,
    String transactionId,
    String spaceId,
  ) async {
    try {
      final homeService = ref.read(homeServiceProvider);
      await homeService.linkTransactionToSpace(transactionId, spaceId);

      if (context.mounted) {
        // Reload transaction detail
        unawaited(
          ref.read(transactionDetailProvider(transactionId).notifier).reload(),
        );
        ToastService.success(description: Text(t.transaction.linkSuccess));
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showDestructive(
          description: Text(t.transaction.linkFailed),
        );
      }
    }
  }

  void _showTransactionActions(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) {
    final List<ActionItem> primaryActions = [];
    final List<ActionItem> destructiveActions = [];

    primaryActions.add(
      ActionItem(
        title: t.transaction.favorite,
        icon: FLucideIcons.bookmark,
        onTap: () {
          // TODO: Implement favorite/bookmark functionality
        },
      ),
    );

    destructiveActions.add(
      ActionItem(
        title: t.common.delete,
        icon: FLucideIcons.trash2,
        onTap: () {
          // Get rootContext for subsequent dialogs (BottomSheet is auto-dismissed by ActionBottomSheet)
          final rootContext = GoRouter.of(
            context,
          ).routerDelegate.navigatorKey.currentContext;
          if (rootContext == null) return;

          // Delay showing dialog to wait for BottomSheet animation to complete
          unawaited(
            Future<void>.delayed(const Duration(milliseconds: 100), () {
              if (!rootContext.mounted) return;
              unawaited(
                showConfirmDialog(
                  context: rootContext,
                  title: t.transaction.confirmDelete,
                  message: t.transaction.deleteTransactionConfirm,
                  cancelLabel: t.common.cancel,
                  confirmLabel: t.common.delete,
                  onConfirm: () async {
                    // Execute delete operation
                    try {
                      final homeService = ref.read(homeServiceProvider);
                      await homeService.deleteTransaction(transaction.id);

                      ToastService.success(
                        description: Text(t.transaction.deleted),
                      );
                      // Navigate back
                      if (rootContext.mounted) {
                        GoRouter.of(rootContext).pop();
                      }
                    } catch (e) {
                      ToastService.showDestructive(
                        description: Text(t.transaction.deleteFailed),
                      );
                    }
                  },
                ),
              );
            }),
          );
        },
      ),
    );
    if (primaryActions.isEmpty && destructiveActions.isEmpty) {
      ToastService.show(description: Text(t.transaction.noActions));
      return;
    }

    // Get root Navigator context safely (it may not be mounted yet on deep links)
    final rootContext = GoRouter.of(
      context,
    ).routerDelegate.navigatorKey.currentContext;
    if (rootContext == null) return;

    unawaited(
      showModalBottomSheet<void>(
        context: rootContext,
        // Alternatively, if MaterialApp has a global navigatorKey:
        // context: rootNavigatorKey.currentContext!,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext sheetContext) {
          // sheetContext is now the context under root Navigator
          return ActionBottomSheet(
            actions: primaryActions,
            destructiveActions: destructiveActions.isNotEmpty
                ? destructiveActions
                : null,
          );
        },
      ),
    );
  }
}
