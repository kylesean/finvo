import 'package:flutter/material.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:forui/forui.dart';
import '../../../i18n/strings.g.dart';
import '../models/statistics_models.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Category detail bottom sheet showing all categories
class CategoryDetailSheet extends StatelessWidget {
  final CategoryBreakdownResponse breakdown;

  const CategoryDetailSheet({super.key, required this.breakdown});

  static Future<void> show(
    BuildContext context, {
    required CategoryBreakdownResponse breakdown,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryDetailSheet(breakdown: breakdown),
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  String _formatAmount(String amount) {
    final numberFormat = AmountFormatter.getNumberFormat('CNY');
    return numberFormat.format(double.tryParse(amount) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final maxPercentage = breakdown.items.isEmpty
        ? 100.0
        : breakdown.items
              .map((e) => e.percentage)
              .reduce((a, b) => a > b ? a : b);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: colors.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.statistics.analysis.breakdown,
                      style: AppTextStyles.listTitle(theme),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        FLucideIcons.x,
                        size: 20,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: breakdown.items.isEmpty
                    ? Center(
                        child: Text(
                          t.statistics.noData,
                          style: AppTextStyles.listSubtitle(theme),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: breakdown.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = breakdown.items[index];
                          return _CategoryDetailItem(
                            item: item,
                            maxPercentage: maxPercentage,
                            parseColor: _parseColor,
                            formatAmount: _formatAmount,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryDetailItem extends StatelessWidget {
  final CategoryBreakdownItem item;
  final double maxPercentage;
  final Color Function(String) parseColor;
  final String Function(String) formatAmount;

  const _CategoryDetailItem({
    required this.item,
    required this.maxPercentage,
    required this.parseColor,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final color = parseColor(item.color);

    return Column(
      children: [
        Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                item.categoryName,
                style: AppTextStyles.listTrailing(theme),
              ),
            ),
            // Amount and percentage
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${formatAmount(item.amount)}',
                  style: AppTextStyles.listTrailing(theme),
                ),
                Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.detailLabel(theme),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        LinearProgressIndicator(
          value: item.percentage / maxPercentage,
          backgroundColor: colors.muted,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}
