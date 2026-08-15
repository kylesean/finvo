import 'dart:async';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finvo/shared/models/action_item_model.dart';
import 'package:finvo/shared/widgets/dialogs/action_bottom_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:finvo/shared/utils/route_utils.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/home/widgets/feed/comment_section_widget.dart';
import 'package:finvo/features/home/widgets/feed/comment_input_bar.dart';
import 'package:finvo/features/home/widgets/feed/attachment_section_widget.dart';
import 'package:finvo/features/home/providers/transaction_detail_provider.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:finvo/features/home/widgets/transaction_detail_skeleton.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/features/home/services/home_service.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/features/home/widgets/transaction_link_section.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';

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
    final detailState = ref.watch(transactionDetailProvider(transactionId));
    final theme = context.theme;
    final colors = theme.colors;

    // Show error state first if an error occurred and there is no cached value
    if (detailState.hasError && detailState.value == null) {
      return _buildErrorState(context, theme, colors, ref, detailState);
    }

    // Show skeleton screen when initially loading
    if (detailState.isLoading && detailState.value == null) {
      return const TransactionDetailSkeleton();
    }

    final transaction = detailState.value;
    if (transaction == null) {
      return const TransactionDetailSkeleton();
    }

    return _buildDetailContent(context, theme, colors, ref, transaction);
  }

  /// Main content for a loaded transaction detail.
  Widget _buildDetailContent(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    WidgetRef ref,
    TransactionModel transaction,
  ) {
    // Whether the current user recorded this transaction themselves. When the
    // record comes from a shared space and belongs to another member, edit,
    // delete, link (account/space) and AI-thread entrypoint rights do not
    // apply and the corresponding UI is hidden.
    final currentUser = ref.watch(currentUserProvider);
    // HOME-6/M-13: `sharedWith` carries the RECORDER's identity (the backend
    // overloads it with the transaction's userUuid/userId). When the backend
    // omits that field (e.g. older endpoints), assume the current user is the
    // owner instead of hiding every edit/delete entry point for their own
    // transactions.
    final isMine =
        currentUser != null &&
        (transaction.sharedWith.isEmpty ||
            transaction.sharedWith.first.userId == currentUser.id);

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
                                          relativeTime(transaction.timestamp),
                                          style: theme.typography.body.sm
                                              .copyWith(
                                                color: colors.mutedForeground,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isMine)
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
                                    currency: transaction.currency ?? 'CNY',
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

                              // Linked account and space actions (only the
                              // recorder may link/move their own record)
                              if (isMine)
                                TransactionLinkSection(
                                  transaction: transaction,
                                ),

                              const SizedBox(height: 16),
                              const FDivider(axis: Axis.horizontal),
                              const SizedBox(height: 12),
                              // Detail row - original entry text (user's raw input).
                              // The AI-chat jump icon only applies when the current
                              // user recorded the transaction themselves.
                              _buildDetailRow(
                                context,
                                icon: FLucideIcons.messageSquareText,
                                label: t.transaction.rawInput,
                                valueWidget: GestureDetector(
                                  onTap:
                                      isMine &&
                                          transaction.sourceThreadId != null
                                      ? () {
                                          unawaited(
                                            HapticFeedback.lightImpact(),
                                          );
                                          context.goNamed(
                                            AppRouteNames.conversation,
                                            pathParameters: {
                                              'conversationId':
                                                  transaction.sourceThreadId!,
                                            },
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
                                      if (isMine &&
                                          transaction.sourceThreadId !=
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
                                  appDateTimeFormat().format(
                                    transaction.timestamp,
                                  ),
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
                      recorderUserId: transaction.sharedWith.isNotEmpty
                          ? transaction.sharedWith.first.userId
                          : null,
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

  bool _isNotFoundError(Object? error) {
    if (error is NotFoundException) return true;
    if (error is UnexpectedHttpException && error.statusCode == 404) {
      return true;
    }
    if (error is AppException &&
        (error.message.contains('404') ||
            error.message.contains('Not Found'))) {
      return true;
    }
    final errStr = error?.toString() ?? '';
    return errStr.contains('404') || errStr.contains('Not Found');
  }

  /// Full-screen error state with a retry button or deleted-resource empty state.
  Widget _buildErrorState(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    WidgetRef ref,
    AsyncValue<TransactionModel> detailState,
  ) {
    final isNotFound = _isNotFoundError(detailState.error);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildPageHeader(context, theme, colors, null),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isNotFound
                            ? FLucideIcons.trash2
                            : FLucideIcons.alertTriangle,
                        size: 56,
                        color: isNotFound
                            ? colors.mutedForeground
                            : colors.destructive,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isNotFound
                            ? t.transaction.notFoundTitle
                            : t.home.loadFailed,
                        style: theme.typography.body.xl2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isNotFound
                            ? t.transaction.notFoundBody
                            : (detailState.error is AppException
                                  ? (detailState.error as AppException).message
                                  : detailState.error.toString()),
                        style: AppTextStyles.listSubtitle(theme),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (isNotFound)
                        FButton(
                          onPress: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutePaths.home);
                            }
                          },
                          child: Text(t.transaction.backToPrevious),
                        )
                      else
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
            ),
          ],
        ),
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
  ///
  /// M-28: the account/space linking UI (pills, pickers, update/link calls)
  /// moved to `TransactionLinkSection`; only the inline call site remains.

  void _showTransactionActions(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) {
    final List<ActionItem> primaryActions = [];
    final List<ActionItem> destructiveActions = [];

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
            waitForRouteSettle().then((_) {
              if (!rootContext.mounted) return;
              unawaited(
                showConfirmDialog(
                  context: rootContext,
                  title: t.transaction.confirmDelete,
                  message: t.transaction.deleteTransactionConfirm,
                  cancelLabel: t.common.cancel,
                  confirmLabel: t.common.delete,
                  onConfirm: () async {
                    // Execute delete operation.
                    // Route the deletion through the feed notifier so the
                    // optimistic removal + total-expense/calendar
                    // invalidation stay in sync with the home page (the
                    // previous direct service call left the feed, monthly
                    // total and calendar cells stale after returning).
                    try {
                      final removedFromFeed = await ref
                          .read(transactionFeedProvider.notifier)
                          .deleteTransaction(transaction.id);
                      if (!removedFromFeed) {
                        // The transaction is not in the current feed (e.g.
                        // filtered out or beyond the loaded pages): delete
                        // via the service and invalidate the derived home
                        // providers so no stale totals/calendar remain.
                        await ref
                            .read(homeServiceProvider)
                            .deleteTransaction(transaction.id);
                        ref.invalidate(transactionFeedProvider);
                        ref.invalidate(totalExpenseProvider);
                        final currentMonth = ref.read(
                          currentDisplayMonthProvider,
                        );
                        ref.invalidate(calendarMonthDataProvider(currentMonth));
                      }

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
