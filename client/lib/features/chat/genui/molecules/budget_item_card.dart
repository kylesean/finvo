import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:augo/app/theme/app_semantic_colors.dart';
import 'package:augo/features/profile/providers/financial_settings_provider.dart';
import 'package:augo/shared/models/currency.dart';
import 'package:augo/i18n/strings.g.dart';

import '../atoms/budget_progress_bar.dart';
import '../../../../shared/widgets/app_card.dart';

class BudgetItemCard extends ConsumerWidget {
  final String? budgetId;

  final String name;

  final double percentage;

  final String status;

  final double spent;

  final double amount;

  final double remaining;

  final VoidCallback? onTap;

  final bool compact;

  const BudgetItemCard({
    super.key,
    this.budgetId,
    required this.name,
    required this.percentage,
    this.status = 'ON_TRACK',
    this.spent = 0,
    this.amount = 0,
    this.remaining = 0,
    this.onTap,
    this.compact = false,
  });

  factory BudgetItemCard.fromJson(
    Map<String, dynamic> json, {
    VoidCallback? onTap,
  }) {
    return BudgetItemCard(
      budgetId: json['id'] as String?,
      name: json['name'] as String? ?? t.budget.budget,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ON_TRACK',
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final financialSettings = ref.watch(financialSettingsProvider);
    final currencySymbol =
        Currency.fromCode(financialSettings.primaryCurrency)?.symbol ?? '¥';

    if (compact) {
      return _buildCompactView(theme, colors);
    }

    return _buildFullView(theme, colors, currencySymbol);
  }

  /// Compact view - for list display
  Widget _buildCompactView(FThemeData theme, FColors colors) {
    return InkWell(
      onTap: onTap,
      borderRadius: theme.style.borderRadius.md,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Budget name
            SizedBox(
              width: 72,
              child: Text(
                name,
                style: theme.typography.body.sm.copyWith(
                  color: colors.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // Progress bar
            Expanded(
              child: BudgetProgressBar(
                percentage: percentage,
                status: status,
                height: 4,
                showLabel: true,
              ),
            ),
            // Tap indicator
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                FLucideIcons.chevronRight,
                size: 14,
                color: colors.mutedForeground,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Full view - for detailed display
  Widget _buildFullView(
    FThemeData theme,
    FColors colors,
    String currencySymbol,
  ) {
    final semantic = theme.semantic;
    final statusColor = _getStatusColor(status, colors, semantic);

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: theme.style.borderRadius.md,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: theme.typography.body.xs.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              BudgetProgressBar(
                percentage: percentage,
                status: status,
                height: 8,
              ),
              const SizedBox(height: 8),

              // Percentage and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    '$currencySymbol${_formatAmount(spent)} / $currencySymbol${_formatAmount(amount)}',
                    style: theme.typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        return t.budget.periodStatusExceeded;
      case 'WARNING':
        return t.budget.periodStatusWarning;
      case 'ACHIEVED':
        return t.budget.periodStatusAchieved;
      default:
        return t.budget.periodStatusOnTrack;
    }
  }

  String _formatAmount(double amount) {
    final absAmount = amount.abs();
    if (absAmount >= 10000) {
      return '${(absAmount / 10000).toStringAsFixed(1)}${t.budget.tenThousandSuffix}';
    }
    return absAmount.toStringAsFixed(0);
  }
}
