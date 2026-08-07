// features/shared_space/pages/shared_space_detail_page.dart
import 'package:flutter/material.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/shared_space/providers/shared_space_provider.dart';
import 'package:finvo/features/shared_space/widgets/space_dashboard_card.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/shared_space/widgets/detail/space_invite_code_sheet.dart';
import 'package:finvo/shared/widgets/dialogs/action_bottom_sheet.dart';
import 'package:finvo/shared/models/action_item_model.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/shared_space/widgets/detail/shared_space_detail_sections.dart';
import 'package:finvo/shared/utils/route_utils.dart';
import 'dart:async';

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
    _scrollController.addListener(_onScroll);
    // Initial load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_refreshAll());
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
      unawaited(_refreshAll());
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      unawaited(
        ref.read(spaceTransactionProvider(widget.spaceId).notifier).loadMore(),
      );
    }
  }

  Future<void> _refreshAll() async {
    ref.invalidate(spaceDetailProvider(widget.spaceId));
    ref.invalidate(spaceSettlementProvider(widget.spaceId));
    await ref
        .read(spaceTransactionProvider(widget.spaceId).notifier)
        .loadTransactions(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;

    final spaceAsync = ref.watch(spaceDetailProvider(widget.spaceId));
    final settlementAsync = ref.watch(spaceSettlementProvider(widget.spaceId));
    final txState = ref.watch(spaceTransactionProvider(widget.spaceId));

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: spaceAsync.when(
        loading: () => const SpaceDetailLoadingState(),
        error: (error, stack) => SpaceDetailErrorState(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(spaceDetailProvider(widget.spaceId));
            ref.invalidate(spaceSettlementProvider(widget.spaceId));
          },
        ),
        data: (space) =>
            _buildContent(context, space, settlementAsync, txState),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SharedSpace space,
    AsyncValue<Settlement> settlementAsync,
    SpaceTransactionState txState,
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
            // 显式固定为左对齐，避免 iOS/macOS 默认居中导致标题位置与 Android 不一致
            centerTitle: false,
            titlePadding: const EdgeInsetsDirectional.only(
              start: 56,
              bottom: 18,
            ),
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
              child: const Icon(FLucideIcons.share2, size: 20),
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
                loading: () => const SpaceSettlementLoadingCard(),
                error: (error, stack) => SpaceSettlementErrorCard(
                  onRetry: () =>
                      ref.invalidate(spaceSettlementProvider(widget.spaceId)),
                ),
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
              if (txState.isLoading && txState.transactions.isEmpty)
                const SpaceTransactionsLoadingList()
              else if (txState.error != null && txState.transactions.isEmpty)
                SpaceTransactionsErrorCard(
                  onRetry: () => ref
                      .read(spaceTransactionProvider(widget.spaceId).notifier)
                      .loadTransactions(refresh: true),
                )
              else
                SpaceTransactionList(
                  transactions: txState.transactions,
                  hasMore: txState.hasMore,
                  isLoading: txState.isLoading,
                  onTransactionReturned: _refreshAll,
                ),
            ]),
          ),
        ),
      ],
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
      context.pushNamed(
        AppRouteNames.sharedSpaceSettings,
        pathParameters: {'spaceId': widget.spaceId},
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
              waitForRouteSettle().then((_) {
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
              waitForRouteSettle().then((_) {
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

    // Get root Navigator context safely (it may not be mounted yet on deep links)
    final rootContext = GoRouter.of(
      context,
    ).routerDelegate.navigatorKey.currentContext;
    if (rootContext == null) return;

    unawaited(
      showModalBottomSheet<void>(
        context: rootContext,
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
      showConfirmDialog(
        context: context,
        title: title,
        message: message,
        cancelLabel: t.sharedSpace.create.cancel,
        confirmVariant: FButtonVariant.destructive,
        confirmLabel: title,
        onConfirm: () async {
          onConfirm();
        },
      ),
    );
  }
}
