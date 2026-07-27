import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/i18n/strings.g.dart';

import '../../../../core/constants/category_constants.dart';
import '../atoms/budget_progress_bar.dart';
import '../atoms/empty_state_alert.dart';
import '../molecules/budget_item_card.dart';

/// Budget status card template
///
/// Layer 4 (Template) - Complete budget overview card
/// Composed of atoms and molecules, following the GenUI four-layer architecture
///
/// Design layout:
/// ┌─────────────────────────────────────────────────┐
/// │ 📊 Budget Overview                     This Month │  ← Top header bar
/// ├─────────────────────────────────────────────────┤
/// │ Total   ████████░░░░░░  75%                     │  ← Total budget progress
/// │ Spent ¥7,500 / Remaining ¥2,500                 │
/// ├─────────────────────────────────────────────────┤
/// │ Dining  ██████████░░  90%  >                    │  ← Category budget list
/// │ Shopping ████████░░░░  50%  >                    │
/// └─────────────────────────────────────────────────┘
class BudgetStatusCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BudgetStatusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final hasBudget = data['has_budget'] == true;

    if (!hasBudget) {
      return _buildNoBudgetCard();
    }

    // Check if it's a single budget or summary
    if (data.containsKey('budget')) {
      return _buildSingleBudgetCard(
        context,
        theme,
        colors,
        data['budget'] as Map<String, dynamic>,
      );
    } else {
      return _buildBudgetSummaryCard(context, theme, colors);
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
      percentage: (budget['percentage'] as num?)?.toDouble() ?? 0.0,
      status: budget['status'] as String? ?? 'ON_TRACK',
      spent: (budget['spent'] as num?)?.toDouble() ?? 0.0,
      amount: (budget['amount'] as num?)?.toDouble() ?? 0.0,
      remaining: (budget['remaining'] as num?)?.toDouble() ?? 0.0,
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
    final overallSpent = (data['overall_spent'] as num?)?.toDouble() ?? 0.0;
    final overallRemaining =
        (data['overall_remaining'] as num?)?.toDouble() ?? 0.0;
    final overallPercentage =
        (data['overall_percentage'] as num?)?.toDouble() ?? 0.0;
    final budgets = data['budgets'] as List<dynamic>? ?? [];
    final alerts = data['alerts'] as List<dynamic>? ?? [];
    final totalBudget = data['total_budget'] as Map<String, dynamic>?;

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
                      style: theme.typography.body.sm.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
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
                  style: theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                Text(
                  t.chat.genui.budgetStatusCard.remaining(
                    amount: _formatAmount(remaining),
                  ),
                  style: theme.typography.body.xs.copyWith(
                    color: remaining >= 0 ? colors.primary : colors.destructive,
                    fontWeight: FontWeight.w500,
                  ),
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
    final percentage = (budget['percentage'] as num?)?.toDouble() ?? 0.0;
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
              style: theme.typography.body.md.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _getStatusText(status),
            style: theme.typography.body.xs.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
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
