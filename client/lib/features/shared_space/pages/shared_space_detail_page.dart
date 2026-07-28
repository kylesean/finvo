// features/shared_space/pages/shared_space_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import '../providers/shared_space_provider.dart';
import '../widgets/space_dashboard_card.dart';
import '../models/shared_space_models.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/utils/amount_formatter.dart';
import '../../../shared/providers/amount_theme_provider.dart';
import '../../../features/home/models/transaction_model.dart';
import '../../../core/constants/category_constants.dart';
import '../../../shared/config/category_config.dart';
import '../../../i18n/strings.g.dart';
import '../widgets/detail/space_invite_code_sheet.dart';
import '../../../shared/widgets/dialogs/action_bottom_sheet.dart';
import '../../../shared/models/action_item_model.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/app/router/app_routes.dart';

class SharedSpaceDetailPage extends ConsumerStatefulWidget {
  final String spaceId;

  const SharedSpaceDetailPage({super.key, required this.spaceId});

  @override
  ConsumerState<SharedSpaceDetailPage> createState() =>
      _SharedSpaceDetailPageState();
}

class _SharedSpaceDetailPageState extends ConsumerState<SharedSpaceDetailPage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Layer 3: Auto-refresh when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  void _refreshAll() {
    ref.invalidate(spaceDetailProvider(widget.spaceId));
    ref.invalidate(spaceSettlementProvider(widget.spaceId));
    ref.invalidate(spaceTransactionsProvider(widget.spaceId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;

    final spaceAsync = ref.watch(spaceDetailProvider(widget.spaceId));
    final settlementAsync = ref.watch(spaceSettlementProvider(widget.spaceId));
    final transactionsAsync = ref.watch(
      spaceTransactionsProvider(widget.spaceId),
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: spaceAsync.when(
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error.toString()),
        data: (space) =>
            _buildContent(context, space, settlementAsync, transactionsAsync),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.sharedSpace.title, style: theme.typography.body.xl),
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = context.theme;
    final colors = theme.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.sharedSpace.title, style: theme.typography.body.xl),
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.circleAlert,
                size: 48,
                color: colors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                t.sharedSpace.detail.loadFailed,
                style: AppTextStyles.pageTitle(theme),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.listSubtitle(theme),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FButton(
                variant: .outline,
                onPress: () {
                  ref.invalidate(spaceDetailProvider(widget.spaceId));
                  ref.invalidate(spaceSettlementProvider(widget.spaceId));
                },
                child: Text(t.sharedSpace.detail.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SharedSpace space,
    AsyncValue<Settlement> settlementAsync,
    AsyncValue<SpaceTransactionListResponse> transactionsAsync,
  ) {
    final theme = context.theme;
    final colors = theme.colors;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          collapsedHeight: 64,
          pinned: true,
          stretch: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            title: Text(space.name, style: AppTextStyles.pageTitleLarge(theme)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.primary.withValues(alpha: 0.05),
                    colors.background,
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          elevation: 0,
          leading: FButton.icon(
            variant: .ghost,
            onPress: () => context.pop(),
            child: const Icon(FLucideIcons.chevronLeft, size: 20),
          ),
          actions: [
            // Invite member button - visible to all members
            FButton.icon(
              variant: .ghost,
              onPress: () => _showInviteSheet(space),
              child: const Icon(FLucideIcons.userPlus, size: 20),
            ),
            // Settings - only for OWNER/ADMIN
            if (space.canManage)
              FButton.icon(
                variant: .ghost,
                onPress: () => _navigateToSettings(space),
                child: const Icon(FLucideIcons.settings, size: 20),
              ),
            // More actions - visible to all (content varies by role)
            FButton.icon(
              variant: .ghost,
              onPress: () => _showSpaceActions(space),
              child: const Icon(FLucideIcons.moreVertical, size: 20),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Financial Dashboard Title
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.layoutDashboard,
                      size: 16,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.sharedSpace.dashboard.sectionTitle,
                      style: AppTextStyles.actionText(
                        theme,
                      ).copyWith(letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),

              // Financial Information Card
              settlementAsync.when(
                loading: () => _buildSettlementLoading(context),
                error: (error, stack) => _buildSettlementError(context),
                data: (settlement) =>
                    SpaceDashboardCard(space: space, settlement: settlement),
              ),

              const SizedBox(height: 32),

              // Transactions Title
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.receipt,
                      size: 16,
                      color: colors.foreground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.sharedSpace.detail.transactions,
                      style: AppTextStyles.listTrailing(
                        theme,
                      ).copyWith(letterSpacing: 1.2),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.muted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t.sharedSpace.detail.recordsCount(
                          count: space.transactionCount,
                        ),
                        style: AppTextStyles.statLabel(theme),
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction List
              transactionsAsync.when(
                loading: () => _buildTransactionListLoading(context),
                error: (error, stack) => _buildTransactionListError(context),
                data: (response) =>
                    _buildTransactionList(context, response.transactions),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementLoading(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color shimmerBaseColor = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.grey[200]!;
    final Color shimmerHighlightColor = isDark
        ? const Color(0xFF424242)
        : Colors.grey[50]!;
    final Color placeholderShapeColor = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.grey[200]!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        period: const Duration(milliseconds: 1200),
        child: Column(
          children: [
            // Top panel skeleton
            Container(
              height: 160,
              width: double.infinity,
              color: placeholderShapeColor,
            ),
            // Bottom content skeleton
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 100,
                    color: placeholderShapeColor,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: placeholderShapeColor,
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    2,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: placeholderShapeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14,
                                  width: 80,
                                  color: placeholderShapeColor,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 12,
                                  width: 40,
                                  color: placeholderShapeColor,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 24,
                            width: 60,
                            color: placeholderShapeColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementError(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.destructive.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            FLucideIcons.circleAlert,
            size: 24,
            color: colors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            t.sharedSpace.detail.loadFailed,
            style: AppTextStyles.listSubtitle(theme),
          ),
          const SizedBox(height: 16),
          FButton(
            variant: .outline,
            onPress: () =>
                ref.invalidate(spaceSettlementProvider(widget.spaceId)),
            child: Text(t.sharedSpace.detail.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListLoading(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => _buildTransactionCardSkeleton(context),
      ),
    );
  }

  Widget _buildTransactionCardSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color shimmerBaseColor = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.grey[200]!;
    final Color shimmerHighlightColor = isDark
        ? const Color(0xFF424242)
        : Colors.grey[50]!;
    final Color placeholderShapeColor = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.grey[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        period: const Duration(milliseconds: 1200),
        child: Row(
          children: [
            // Icon skeleton
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: placeholderShapeColor,
              ),
            ),
            const SizedBox(width: 12),
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    color: placeholderShapeColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    color: placeholderShapeColor,
                  ),
                ],
              ),
            ),
            // Amount skeleton
            Container(height: 20, width: 60, color: placeholderShapeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionListError(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.destructive.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            FLucideIcons.circleAlert,
            size: 24,
            color: colors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            t.sharedSpace.detail.loadFailed,
            style: AppTextStyles.listSubtitle(theme),
          ),
          const SizedBox(height: 16),
          FButton(
            variant: .outline,
            onPress: () =>
                ref.invalidate(spaceTransactionsProvider(widget.spaceId)),
            child: Text(t.sharedSpace.detail.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<SpaceTransaction> transactions,
  ) {
    final theme = context.theme;
    final colors = theme.colors;

    // Empty state
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: colors.muted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              FLucideIcons.receipt,
              size: 40,
              color: colors.mutedForeground.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              t.sharedSpace.detail.noTransactions,
              style: AppTextStyles.listTitle(theme),
            ),
            const SizedBox(height: 4),
            Text(
              t.sharedSpace.detail.noTransactionsHint,
              style: theme.typography.body.sm.copyWith(
                color: colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Transaction list
    return Column(
      children: transactions
          .map((tx) => _buildTransactionItem(context, tx))
          .toList(),
    );
  }

  Widget _buildTransactionItem(BuildContext context, SpaceTransaction tx) {
    final theme = context.theme;
    final colors = theme.colors;

    // Parse transaction type
    final isExpense = tx.type.toUpperCase() == 'EXPENSE';
    final isIncome = tx.type.toUpperCase() == 'INCOME';
    final transactionType = isExpense
        ? TransactionType.expense
        : (isIncome ? TransactionType.income : TransactionType.transfer);
    final amountTheme = ref.watch(currentAmountThemeValueProvider);
    final amountColor = AmountFormatter.getAmountColor(
      transactionType,
      amountTheme,
    );

    // Format time
    String timeDisplay = '';
    if (tx.transactionAt != null) {
      final now = DateTime.now();
      final diff = now.difference(tx.transactionAt!);
      if (diff.inMinutes < 1) {
        timeDisplay = t.notification.justNow;
      } else if (diff.inMinutes < 60) {
        timeDisplay = t.notification.minutesAgo(minutes: diff.inMinutes);
      } else if (diff.inHours < 24) {
        timeDisplay = t.notification.hoursAgo(hours: diff.inHours);
      } else if (diff.inDays < 7) {
        timeDisplay = t.notification.daysAgo(days: diff.inDays);
      } else {
        timeDisplay = '${tx.transactionAt!.month}/${tx.transactionAt!.day}';
      }
    }

    return GestureDetector(
      onTap: () {
        unawaited(
          context.pushNamed(
            AppRouteNames.transactionDetail,
            pathParameters: {'transactionId': tx.id},
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: amountColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                tx.categoryKey != null
                    ? CategoryConfig.getCategoryIcon(tx.categoryKey)
                    : (isExpense
                          ? FLucideIcons.trendingDown
                          : FLucideIcons.trendingUp),
                size: 18,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 12),
            // Description and added by
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description != null && tx.description!.isNotEmpty
                        ? tx.description!
                        : (tx.categoryKey != null
                              ? TransactionCategory.fromKey(
                                  tx.categoryKey,
                                ).displayText
                              : t.category.other),
                    style: AppTextStyles.listTitle(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.addedByUsername ?? "Unknown"} · $timeDisplay',
                    style: AppTextStyles.detailLabel(theme),
                  ),
                ],
              ),
            ),
            // Amount - using unified AmountText component
            tx.display != null
                ? AmountText.fromDisplay(
                    display: tx.display!,
                    type: transactionType,
                    style: AppTextStyles.listTitle(theme),
                  )
                : AmountText(
                    amount: double.tryParse(tx.amount) ?? 0.0,
                    type: transactionType,
                    currency: tx.currency,
                    style: AppTextStyles.listTitle(theme),
                  ),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(SharedSpace space) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SpaceInviteCodeSheet(space: space),
      ),
    );
  }

  void _navigateToSettings(SharedSpace space) {
    unawaited(
      context.push(
        '/profile/shared-space/${widget.spaceId}/settings',
        extra: space,
      ),
    );
  }

  void _showSpaceActions(SharedSpace space) {
    final isOwner = space.isOwner;

    final primaryActions = <ActionItem>[];
    final destructiveActions = <ActionItem>[];

    // Leave space - visible for non-owner members
    if (!isOwner) {
      primaryActions.add(
        ActionItem(
          title: t.sharedSpace.detail.leaveSpace,
          icon: FLucideIcons.logOut,
          onTap: () {
            final rootContext = GoRouter.of(
              context,
            ).routerDelegate.navigatorKey.currentContext;
            if (rootContext == null) return;
            unawaited(
              Future<void>.delayed(const Duration(milliseconds: 100), () {
                if (!rootContext.mounted) return;
                _showConfirmDialog(
                  context: rootContext,
                  title: t.sharedSpace.detail.leaveSpace,
                  message: t.sharedSpace.detail.leaveConfirm,
                  onConfirm: () async {
                    final success = await ref
                        .read(sharedSpaceProvider.notifier)
                        .leaveSpace(space.id);
                    if (success && mounted) {
                      context.pop();
                    }
                  },
                );
              }),
            );
          },
        ),
      );
    }

    // Delete space - visible for owner only
    if (isOwner) {
      destructiveActions.add(
        ActionItem(
          title: t.sharedSpace.detail.deleteSpace,
          icon: FLucideIcons.trash2,
          isDestructive: true,
          onTap: () {
            final rootContext = GoRouter.of(
              context,
            ).routerDelegate.navigatorKey.currentContext;
            if (rootContext == null) return;
            unawaited(
              Future<void>.delayed(const Duration(milliseconds: 100), () {
                if (!rootContext.mounted) return;
                _showConfirmDialog(
                  context: rootContext,
                  title: t.sharedSpace.detail.deleteSpace,
                  message: t.sharedSpace.detail.deleteConfirm,
                  onConfirm: () async {
                    final success = await ref
                        .read(sharedSpaceProvider.notifier)
                        .deleteSpace(space.id);
                    if (success && mounted) {
                      context.pop();
                    }
                  },
                );
              }),
            );
          },
        ),
      );
    }

    unawaited(
      showModalBottomSheet<void>(
        context: GoRouter.of(
          context,
        ).routerDelegate.navigatorKey.currentContext!,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) {
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

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    unawaited(
      showFDialog<void>(
        context: context,
        builder: (dialogContext, style, animation) => FDialog(
          animation: animation,
          builder: (context, dialogStyle) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: dialogStyle.titleTextStyle),
                const SizedBox(height: 8),
                Text(message, style: dialogStyle.bodyTextStyle),
                const SizedBox(height: 24),
                FButton(
                  variant: .outline,
                  onPress: () => Navigator.of(dialogContext).pop(),
                  child: Text(t.sharedSpace.create.cancel),
                ),
                const SizedBox(height: 8),
                FButton(
                  variant: .destructive,
                  onPress: () {
                    Navigator.of(dialogContext).pop();
                    onConfirm();
                  },
                  child: Text(title),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
