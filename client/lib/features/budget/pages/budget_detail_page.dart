import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:augo/core/widgets/top_toast.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/constants/category_constants.dart';
import '../../../shared/models/currency.dart';
import '../../profile/providers/financial_settings_provider.dart';
import '../models/budget_models.dart';
import '../providers/budget_provider.dart';
import '../services/budget_service.dart';
import 'package:augo/i18n/strings.g.dart';
import 'package:augo/app/theme/app_semantic_colors.dart';
import '../../../shared/widgets/app_card.dart';

class BudgetDetailPage extends ConsumerStatefulWidget {
  final String budgetId;

  const BudgetDetailPage({super.key, required this.budgetId});

  @override
  ConsumerState<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends ConsumerState<BudgetDetailPage> {
  BudgetWithUsage? _budgetWithUsage;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;

  /// Get currency symbol from global settings
  String get _currencySymbol =>
      Currency.fromCode(
        ref.watch(financialSettingsProvider).primaryCurrency,
      )?.symbol ??
      '¥';

  @override
  void initState() {
    super.initState();
    unawaited(_loadBudgetDetail());
  }

  Future<void> _loadBudgetDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(budgetServiceProvider);
      final summary = await service.getSummary(includePaused: true);
      BudgetWithUsage? found;

      if (summary.totalBudgetDetail != null &&
          summary.totalBudgetDetail!.budget.id == widget.budgetId) {
        found = summary.totalBudgetDetail!;
      }

      if (found == null) {
        for (final b in summary.categoryBudgets) {
          if (b.budget.id == widget.budgetId) {
            found = b;
            break;
          }
        }
      }

      if (found == null) {
        for (final b in summary.budgets) {
          if (b.budget.id == widget.budgetId) {
            found = b;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _budgetWithUsage = found;
          _isLoading = false;
          if (found == null) {
            _error = t.budget.notFound;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '${t.budget.loadFailed}: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(theme, colors),
      body: _buildBody(theme, colors),
    );
  }

  PreferredSizeWidget _buildAppBar(FThemeData theme, FColors colors) {
    final isPaused = _budgetWithUsage?.budget.status == BudgetStatus.paused;

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(FLucideIcons.arrowLeft, color: colors.foreground),
        onPressed: () => context.pop(),
      ),
      title: Text(
        t.budget.detail,
        style: theme.typography.body.lg.copyWith(
          fontWeight: FontWeight.w500,
          color: colors.foreground,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_budgetWithUsage != null) ...[
          IconButton(
            icon: Icon(
              isPaused ? FLucideIcons.play : FLucideIcons.pause,
              color: colors.foreground,
              size: 20,
            ),
            tooltip: isPaused ? t.budget.resume : t.budget.pause,
            onPressed: _handlePauseToggle,
          ),

          IconButton(
            icon: Icon(
              FLucideIcons.squarePen,
              color: colors.foreground,
              size: 20,
            ),
            tooltip: t.common.edit,
            onPressed: () => context.pushNamed(
              'budgetEdit',
              pathParameters: {'id': widget.budgetId},
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody(FThemeData theme, FColors colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.triangleAlert,
                size: 48,
                color: colors.destructive,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.typography.body.md.copyWith(
                  color: colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                child: FButton(
                  onPress: _loadBudgetDetail,
                  child: Text(t.common.retry),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final budgetWithUsage = _budgetWithUsage!;
    final budget = budgetWithUsage.budget;

    return RefreshIndicator(
      onRefresh: _loadBudgetDetail,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProgressCard(theme, colors, budgetWithUsage),
          const SizedBox(height: 24),

          _buildDetailSection(theme, colors, budget),
          const SizedBox(height: 24),

          _buildStatusSection(theme, colors, budgetWithUsage),
          const SizedBox(height: 32),

          _buildDeleteButton(theme, colors),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    FThemeData theme,
    FColors colors,
    BudgetWithUsage budgetWithUsage,
  ) {
    final usagePercent = budgetWithUsage.usagePercentage;
    final isExceeded = usagePercent > 100;
    final isWarning = usagePercent > 70 && !isExceeded;

    Color statusColor;
    if (isExceeded) {
      statusColor = colors.destructive;
    } else if (isWarning) {
      statusColor = theme.semantic.warningAccent;
    } else {
      statusColor = colors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor, statusColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Budget name
          Text(
            budgetWithUsage.budget.displayName,
            style: theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.primaryForeground,
            ),
          ),
          const SizedBox(height: 24),

          // Circular progress
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: (usagePercent / 100).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: colors.primaryForeground.withValues(
                      alpha: 0.3,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.primaryForeground,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${usagePercent.toStringAsFixed(0)}%',
                      style: theme.typography.body.xl2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primaryForeground,
                      ),
                    ),
                    Text(
                      t.budget.used,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.primaryForeground.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAmountItem(
                theme,
                colors,
                t.budget.used,
                budgetWithUsage.spentAmount,
              ),
              Container(
                width: 1,
                height: 40,
                color: colors.primaryForeground.withValues(alpha: 0.3),
              ),
              _buildAmountItem(
                theme,
                colors,
                t.budget.remaining,
                budgetWithUsage.remainingAmount,
              ),
              Container(
                width: 1,
                height: 40,
                color: colors.primaryForeground.withValues(alpha: 0.3),
              ),
              _buildAmountItem(
                theme,
                colors,
                t.budget.budget,
                budgetWithUsage.budget.amount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(
    FThemeData theme,
    FColors colors,
    String label,
    Decimal amount,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: colors.primaryForeground.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_currencySymbol${_formatAmount(amount)}',
          style: theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.primaryForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(FThemeData theme, FColors colors, Budget budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.budget.info,
          style: theme.typography.body.sm.copyWith(
            color: colors.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            children: [
              _buildInfoRow(
                theme,
                colors,
                t.budget.type,
                budget.isTotalBudget
                    ? t.budget.totalBudget
                    : t.budget.categoryBudget,
                icon: budget.isTotalBudget
                    ? FLucideIcons.wallet
                    : FLucideIcons.layers,
              ),
              Divider(height: 1, color: colors.border),
              if (budget.categoryKey != null) ...[
                _buildInfoRow(
                  theme,
                  colors,
                  t.budget.category,
                  TransactionCategory.fromKey(budget.categoryKey!).displayText,
                  icon: TransactionCategory.fromKey(budget.categoryKey!).icon,
                  iconColor: TransactionCategory.fromKey(
                    budget.categoryKey!,
                  ).themedColor(theme),
                ),
                Divider(height: 1, color: colors.border),
              ],
              _buildInfoRow(
                theme,
                colors,
                t.budget.period,
                budget.periodType.label,
                icon: FLucideIcons.calendarClock,
              ),
              Divider(height: 1, color: colors.border),
              _buildInfoRow(
                theme,
                colors,
                t.budget.rollover,
                budget.rolloverEnabled ? t.budget.enabled : t.budget.disabled,
                icon: FLucideIcons.repeat,
              ),
              if (budget.rolloverBalance != Decimal.zero) ...[
                Divider(height: 1, color: colors.border),
                _buildInfoRow(
                  theme,
                  colors,
                  t.budget.rolloverBalance,
                  '$_currencySymbol${_formatAmount(budget.rolloverBalance)}',
                  icon: FLucideIcons.arrowRightLeft,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    FThemeData theme,
    FColors colors,
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor ?? colors.mutedForeground),
            const SizedBox(width: 12),
          ],
          Text(
            label,
            style: theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.typography.body.sm.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(
    FThemeData theme,
    FColors colors,
    BudgetWithUsage budgetWithUsage,
  ) {
    final periodStatus = budgetWithUsage.periodStatus;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (periodStatus) {
      case BudgetPeriodStatus.onTrack:
        statusColor = colors.primary;
        statusText = t.budget.statusNormal;
        statusIcon = FLucideIcons.circleCheck;
        break;
      case BudgetPeriodStatus.warning:
        statusColor = theme.semantic.warningAccent;
        statusText = t.budget.statusWarning;
        statusIcon = FLucideIcons.circleAlert;
        break;
      case BudgetPeriodStatus.exceeded:
        statusColor = colors.destructive;
        statusText = t.budget.statusOverspent;
        statusIcon = FLucideIcons.circleX;
        break;
      case BudgetPeriodStatus.achieved:
        statusColor = theme.semantic.successAccent;
        statusText = t.budget.statusAchieved;
        statusIcon = FLucideIcons.trophy;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
                Text(
                  _getStatusDescription(periodStatus, budgetWithUsage),
                  style: theme.typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(
    BudgetPeriodStatus status,
    BudgetWithUsage budgetWithUsage,
  ) {
    final remaining = budgetWithUsage.remainingAmount;
    switch (status) {
      case BudgetPeriodStatus.onTrack:
        return t.budget.tipNormal(
          amount: '$_currencySymbol${_formatAmount(remaining)}',
        );
      case BudgetPeriodStatus.warning:
        return t.budget.tipWarning(
          amount: '$_currencySymbol${_formatAmount(remaining)}',
        );
      case BudgetPeriodStatus.exceeded:
        return t.budget.tipOverspent(
          amount: '$_currencySymbol${_formatAmount(remaining.abs())}',
        );
      case BudgetPeriodStatus.achieved:
        return t.budget.tipAchieved;
    }
  }

  Future<void> _handlePauseToggle() async {
    final newStatus = _budgetWithUsage!.budget.status == BudgetStatus.paused
        ? BudgetStatus.active
        : BudgetStatus.paused;

    try {
      final service = ref.read(budgetServiceProvider);
      await service.update(
        widget.budgetId,
        BudgetUpdateRequest(status: newStatus),
      );
      await ref.read(budgetSummaryProvider.notifier).refresh();
      await _loadBudgetDetail();
      if (mounted) {
        TopToast.success(
          context,
          newStatus == BudgetStatus.paused
              ? t.budget.budgetPaused
              : t.budget.budgetResumed,
        );
      }
    } catch (e) {
      if (mounted) {
        TopToast.error(context, '${t.budget.operationFailed}: $e');
      }
    }
  }

  Widget _buildDeleteButton(FThemeData theme, FColors colors) {
    return FButton(
      variant: .destructive,
      onPress: _isDeleting ? null : _showDeleteConfirmation,
      child: _isDeleting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(t.budget.deleteBudget),
    );
  }

  void _showDeleteConfirmation() {
    unawaited(
      showFDialog(
        context: context,
        builder: (context, style, animation) => FDialog(
          animation: animation,
          builder: (context, dialogStyle) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.budget.deleteBudget, style: dialogStyle.titleTextStyle),
                const SizedBox(height: 8),
                Text(t.budget.deleteConfirm, style: dialogStyle.bodyTextStyle),
                const SizedBox(height: 24),
                FButton(
                  variant: .outline,
                  onPress: () => Navigator.pop(context),
                  child: Text(t.common.cancel),
                ),
                const SizedBox(height: 8),
                FButton(
                  variant: .destructive,
                  onPress: () async {
                    await Navigator.maybePop(context);
                    unawaited(_handleDelete());
                  },
                  child: Text(t.common.delete),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await ref
          .read(budgetSummaryProvider.notifier)
          .deleteBudget(widget.budgetId);
      if (mounted) {
        TopToast.success(context, t.budget.deleteSuccess);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        TopToast.error(context, '${t.budget.deleteFailed}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _formatAmount(Decimal amount) {
    final value = double.tryParse(amount.toString()) ?? 0.0;
    final absValue = value.abs();

    if (absValue >= 10000) {
      return '${(absValue / 10000).toStringAsFixed(1)}${t.budget.tenThousandSuffix}';
    }

    return absValue.toStringAsFixed(2);
  }
}
