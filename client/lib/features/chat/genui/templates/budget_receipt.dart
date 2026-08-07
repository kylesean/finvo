import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Budget creation success receipt card
///
/// Displays newly created budget information.
/// Reference design:
/// ┌─────────────────────────────────────────────────┐
/// │ ✓ Budget Created                       14:30   │  ← Top: success status bar
/// ├─────────────────────────────────────────────────┤
/// │                    📊                           │
/// │               ¥10,000                           │  ← Middle: budget amount
/// │            Dec 2024 Total Budget                │
/// ├─────────────────────────────────────────────────┤
/// │ Period: Dec 1 - Dec 31             Rollover    │  ← Bottom: details
/// └─────────────────────────────────────────────────┘
class BudgetReceipt extends StatelessWidget {
  final Map<String, dynamic> data;

  const BudgetReceipt({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final success = data['success'] == true;

    if (!success) {
      return _buildErrorCard(theme, colors);
    }

    return _buildSuccessCard(theme, colors);
  }

  /// Build success card
  Widget _buildSuccessCard(FThemeData theme, FColors colors) {
    final name =
        data['name']?.toString() ?? t.chat.genui.budgetReceipt.newBudget;
    final amountRaw = data['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw?.toString() ?? '') ?? 0.0;
    final scope = data['scope']?.toString() ?? 'TOTAL';
    final categoryKey = data['category_key']?.toString();
    final periodStart = data['period_start']?.toString();
    final periodEnd = data['period_end']?.toString();
    final rolloverEnabled = data['rollover_enabled'] == true;

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
          // Top status bar
          _buildStatusHeader(theme, colors),

          // Middle content
          _buildMainContent(theme, colors, name, amount, scope, categoryKey),

          // Bottom details
          _buildDetailsFooter(
            theme,
            colors,
            periodStart,
            periodEnd,
            rolloverEnabled,
          ),
        ],
      ),
    );
  }

  /// Build top status bar
  Widget _buildStatusHeader(FThemeData theme, FColors colors) {
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
            t.chat.genui.budgetReceipt.budgetCreated,
            style: AppTextStyles.actionText(theme),
          ),
          const Spacer(),
          Text(
            _formatCurrentTime(),
            style: theme.typography.body.sm.copyWith(
              color: colors.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build middle content
  Widget _buildMainContent(
    FThemeData theme,
    FColors colors,
    String name,
    double amount,
    String scope,
    String? categoryKey,
  ) {
    final isTotal = scope.toUpperCase() == 'TOTAL';
    final iconData = isTotal ? FLucideIcons.wallet : FLucideIcons.layoutGrid;
    final iconColor = colors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),

          // Amount
          Text(
            '¥${_formatAmount(amount)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: colors.foreground,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Budget name
          Text(
            name,
            style: AppTextStyles.listSubtitle(theme),
            textAlign: TextAlign.center,
          ),

          // Category tag (if category budget)
          if (categoryKey != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(categoryKey, style: AppTextStyles.badge(theme)),
            ),
          ],
        ],
      ),
    );
  }

  /// Build bottom details
  Widget _buildDetailsFooter(
    FThemeData theme,
    FColors colors,
    String? periodStart,
    String? periodEnd,
    bool rolloverEnabled,
  ) {
    final periodText = _formatPeriod(periodStart, periodEnd);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: colors.muted.withValues(alpha: 0.3)),
      child: Row(
        children: [
          Icon(FLucideIcons.calendar, size: 14, color: colors.mutedForeground),
          const SizedBox(width: 6),
          Expanded(
            child: Text(periodText, style: AppTextStyles.listSubtitle(theme)),
          ),
          if (rolloverEnabled) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FLucideIcons.refreshCcw,
                    size: 12,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.chat.genui.budgetReceipt.rolloverBudget,
                    style: AppTextStyles.badge(theme),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build error card
  Widget _buildErrorCard(FThemeData theme, FColors colors) {
    final message =
        data['message']?.toString() ?? t.chat.genui.budgetReceipt.createFailed;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.destructive.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(FLucideIcons.circleAlert, color: colors.destructive, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.typography.body.sm.copyWith(
                color: colors.destructive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format current time
  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Format amount
  String _formatAmount(double amount) {
    if (amount >= 10000) {
      final wan = amount / 10000;
      if (wan == wan.truncate()) {
        return '${wan.truncate()}${t.budget.tenThousandSuffix}';
      }
      return '${wan.toStringAsFixed(1)}${t.budget.tenThousandSuffix}';
    }
    if (amount == amount.truncate()) {
      return amount.truncate().toString();
    }
    return amount.toStringAsFixed(2);
  }

  /// Format period
  String _formatPeriod(String? start, String? end) {
    if (start == null || end == null) {
      return t.chat.genui.budgetReceipt.thisMonth;
    }
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      return t.chat.genui.budgetReceipt.dateRange(
        start: startDate.month,
        startDay: startDate.day,
        end: endDate.month,
        endDay: endDate.day,
      );
    } catch (e) {
      return t.chat.genui.budgetReceipt.thisMonth;
    }
  }
}
