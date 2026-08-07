import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Category detail bottom sheet showing all categories
class CategoryDetailSheet extends ConsumerWidget {
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

  /// Parse a hex color string (e.g. `#ff0000` or `ff0000`) into a [Color].
  ///
  /// Returns a neutral fallback when the input is absent, malformed, or out of
  /// range instead of throwing, so a bad server-provided color can never crash
  /// the report sheet.
  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    // Accept 6-digit RRGGBB (prefixed with full opacity) or 8-digit AARRGGBB.
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return _fallbackColor;
    if (cleaned.length == 6) {
      return Color(0xFF000000 | value);
    }
    if (cleaned.length == 8) {
      return Color(value);
    }
    return _fallbackColor;
  }

  static const Color _fallbackColor = Color(0xFF9E9E9E);

  String _formatAmount(String amount, String currencyCode) {
    // Follow the report page's currency instead of a hardcoded CNY symbol.
    return AmountFormatter.formatWithCurrency(
      amount,
      currencyCode: currencyCode,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final currency = ref.watch(financialSettingsProvider).primaryCurrency;
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
                            formatAmount: (amount) =>
                                _formatAmount(amount, currency),
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
                  formatAmount(item.amount),
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
