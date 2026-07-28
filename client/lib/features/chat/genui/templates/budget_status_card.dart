import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/i18n/strings.g.dart';

import '../../../../core/constants/category_constants.dart';
import '../atoms/budget_progress_bar.dart';
import '../atoms/empty_state_alert.dart';
import '../molecules/budget_item_card.dart';
import '../utils/genui_num_utils.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Budget status card template
///
/// Layer 4 (Template) - Complete budget overview card
/// Composed of atoms and molecules, following the GenUI four-layer architecture
class BudgetStatusCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BudgetStatusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    try {
      final theme = context.theme;
      final colors = theme.colors;

      final hasBudget = data['has_budget'] == true;

      if (!hasBudget) {
        return _buildNoBudgetCard();
      }

      // Check if it's a single budget or summary
      final budgetData = data['budget'];
      if (budgetData is Map) {
        return _buildSingleBudgetCard(
          context,
          theme,
          colors,
          Map<String, dynamic>.from(budgetData),
        );
      } else {
        return _buildBudgetSummaryCard(context, theme, colors);
      }
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: context.theme.colors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Budget status format error: $e',
                style: TextStyle(
                  color: context.theme.colors.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// No budget hint - uses concise FAlert style
  Widget _buildNoBudgetCard() {
    return EmptyStateAlert.budget();
  }

  /// Single budget card
  Widget _buildSingleBudgetCard(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> budget,
  ) {
    final budgetId = budget['id'] as String?;

    return BudgetItemCard(
      budgetId: budgetId,
      name: budget['name'] as String? ?? t.chat.genui.budgetStatusCard.budget,
      percentage: GenUiNumUtils.toDouble(budget['percentage']),
      status: budget['status'] as String? ?? 'ON_TRACK',
      spent: GenUiNumUtils.toDouble(budget['spent']),
      amount: GenUiNumUtils.toDouble(budget['amount']),
      remaining: GenUiNumUtils.toDouble(budget['remaining']),
      compact: false,
      onTap: budgetId != null
          ? () => context.pushNamed(
              'budgetDetail',
              pathParameters: {'id': budgetId},
            )
          : null,
    );
  }

  /// Budget summary card
  Widget _buildBudgetSummaryCard(
    BuildContext context,
    FThemeData theme,
    FColors colors,
  ) {
    final overallSpent = GenUiNumUtils.toDouble(data['overall_spent']);
    final overallRemaining = GenUiNumUtils.toDouble(data['overall_remaining']);
    final overallPercentage = GenUiNumUtils.toDouble(
      data['overall_percentage'],
    );
    final budgetsRaw = data['budgets'];
    final budgets = budgetsRaw is List ? budgetsRaw : <dynamic>[];
    final alertsRaw = data['alerts'];
    final alerts = alertsRaw is List ? alertsRaw : <dynamic>[];
    final totalBudgetRaw = data['total_budget'];
    final totalBudget = totalBudgetRaw is Map
        ? Map<String, dynamic>.from(totalBudgetRaw)
        : null;

    return Container(
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
          // Top header bar
          _buildHeader(
            theme,
            colors,
            t.chat.genui.budgetStatusCard.overview,
            _getOverallStatus(alerts),
          ),

          // Main content area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Total budget section (tappable)
                _buildTotalBudgetSection(
                  context,
                  theme,
                  colors,
                  totalBudget,
                  overallPercentage,
                  overallSpent,
                  overallRemaining,
                ),

                // Category budget list
                if (budgets.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(height: 1, color: colors.border),
                  const SizedBox(height: 12),
                  ...budgets.take(5).map((b) {
                    final budget = b as Map<String, dynamic>;
                    return _buildCategoryBudgetItem(
                      context,
                      theme,
                      colors,
                      budget,
                    );
                  }),
                ],

                // Alert messages
                if (alerts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...alerts.take(2).map((a) {
                    final alert = a as Map<String, dynamic>;
                    return _buildAlertItem(theme, colors, alert);
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Total budget section
  Widget _buildTotalBudgetSection(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    Map<String, dynamic>? totalBudget,
    double percentage,
    double spent,
    double remaining,
  ) {
    final semantic = theme.semantic;
    final status = _getPercentageStatus(percentage);
    final statusColor = _getStatusColor(status, colors, semantic);
    final budgetId = totalBudget?['id'] as String?;

    return InkWell(
      onTap: budgetId != null
          ? () => context.pushNamed(
              'budgetDetail',
              pathParameters: {'id': budgetId},
            )
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      t.chat.genui.budgetStatusCard.totalBudget,
                      style: AppTextStyles.listTrailing(theme),
                    ),
                    if (budgetId != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: 14,
                        color: colors.mutedForeground,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            BudgetProgressBar(
              percentage: percentage,
              status: status,
              height: 8,
            ),
            const SizedBox(height: 8),

            // Amount info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.chat.genui.budgetStatusCard.spent(
                    amount: _formatAmount(spent),
                  ),
                  style: AppTextStyles.detailLabel(theme),
                ),
                Text(
                  t.chat.genui.budgetStatusCard.remaining(
                    amount: _formatAmount(remaining),
                  ),
                  style: AppTextStyles.badge(theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Category budget item (using category name)
  Widget _buildCategoryBudgetItem(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> budget,
  ) {
    // Prefer category_key for category display name
    final categoryKey = budget['category_key'] as String?;
    final name = categoryKey != null
        ? _getCategoryDisplayName(categoryKey)
        : (budget['name'] as String? ?? '');
    final percentage = GenUiNumUtils.toDouble(budget['percentage']);
    final status = budget['status'] as String? ?? 'ON_TRACK';
    final budgetId = budget['id'] as String?;

    return BudgetItemCard(
      budgetId: budgetId,
      name: name,
      percentage: percentage,
      status: status,
      compact: true,
      onTap: budgetId != null
          ? () => context.pushNamed(
              'budgetDetail',
              pathParameters: {'id': budgetId},
            )
          : null,
    );
  }

  /// Get category display name
  String _getCategoryDisplayName(String categoryKey) {
    try {
      return TransactionCategory.fromKey(categoryKey).displayText;
    } catch (e) {
      return categoryKey;
    }
  }

  /// Top header bar
  Widget _buildHeader(
    FThemeData theme,
    FColors colors,
    String title,
    String status,
  ) {
    final semantic = theme.semantic;
    final statusColor = _getStatusColor(status, colors, semantic);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1)),
      child: Row(
        children: [
          Icon(FLucideIcons.chartPie, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.listTitle(
                theme,
              ).copyWith(color: statusColor),
            ),
          ),
          Text(
            _getStatusText(status),
            style: AppTextStyles.statLabel(theme).copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }

  /// Alert item
  Widget _buildAlertItem(
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> alert,
  ) {
    final semantic = theme.semantic;
    final alertType = alert['alert_type'] as String? ?? 'warning';
    final message = alert['message'] as String? ?? '';
    final iconColor = alertType == 'exceeded'
        ? colors.destructive
        : semantic.warningAccent;
    final icon = alertType == 'exceeded'
        ? FLucideIcons.circleAlert
        : FLucideIcons.triangleAlert;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.typography.body.xs.copyWith(color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  // ============ Utility methods ============

  Color _getStatusColor(
    String status,
    FColors colors,
    AppSemanticColors semantic,
  ) {
    switch (status.toUpperCase()) {
      case 'EXCEEDED':
        return colors.destructive;
      case 'WARNING':
        return semantic.warningAccent;
      case 'ACHIEVED':
        return semantic.successAccent;
      default:
        return colors.primary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'EXCEEDED':
        return t.chat.genui.budgetStatusCard.exceeded;
      case 'WARNING':
        return t.chat.genui.budgetStatusCard.warning;
      case 'ACHIEVED':
        return t.chat.genui.budgetStatusCard.plentiful;
      default:
        return t.chat.genui.budgetStatusCard.normal;
    }
  }

  String _getOverallStatus(List<dynamic> alerts) {
    if (alerts.isEmpty) return 'ON_TRACK';
    for (final alert in alerts) {
      final alertType =
          (alert as Map<String, dynamic>)['alert_type'] as String?;
      if (alertType == 'exceeded') return 'EXCEEDED';
    }
    return 'WARNING';
  }

  String _getPercentageStatus(double percentage) {
    if (percentage >= 100) return 'EXCEEDED';
    if (percentage >= 80) return 'WARNING';
    return 'ON_TRACK';
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}${t.budget.tenThousandSuffix}';
    }
    return amount.toStringAsFixed(0);
  }
}
