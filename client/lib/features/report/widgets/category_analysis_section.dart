import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/widgets/app_filter_chip.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';

/// Unified Category Analysis Section with multi-view switching
/// Replaces both CategoryDonutChart and CategoryDetailedReport
class CategoryAnalysisSection extends ConsumerStatefulWidget {
  final CategoryBreakdownResponse breakdown;
  final ChartType chartType;

  const CategoryAnalysisSection({
    super.key,
    required this.breakdown,
    this.chartType = ChartType.expense,
  });

  @override
  ConsumerState<CategoryAnalysisSection> createState() =>
      _CategoryAnalysisSectionState();
}

enum CategoryViewMode { bar, pie, radar, list }

class _CategoryAnalysisSectionState
    extends ConsumerState<CategoryAnalysisSection> {
  CategoryViewMode _viewMode = CategoryViewMode.bar;

  // Format an amount using the user's configured currency instead of the
  // hard-coded CNY so the tooltip matches the app-wide currency setting.
  String _formatAmount(String amount, String currencyCode) {
    final numberFormat = AmountFormatter.getNumberFormat(
      currencyCode,
      decimalDigits: 0,
    );
    return numberFormat.format(AmountFormatter.parseDecimal(amount).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    if (widget.breakdown.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with custom view switcher
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.chartType == ChartType.expense
                  ? t.statistics.analysis.expenseTitle
                  : t.statistics.analysis.incomeTitle,
              style: AppTextStyles.listTitle(theme),
            ),
            // Custom icon toggle (FTabs needs bounded width)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFilterChip(
                  icon: FLucideIcons.chartColumn,
                  isSelected: _viewMode == CategoryViewMode.bar,
                  onTap: () => setState(() => _viewMode = CategoryViewMode.bar),
                ),
                const SizedBox(width: 4),
                AppFilterChip(
                  icon: FLucideIcons.chartPie,
                  isSelected: _viewMode == CategoryViewMode.pie,
                  onTap: () => setState(() => _viewMode = CategoryViewMode.pie),
                ),
                const SizedBox(width: 4),
                AppFilterChip(
                  icon: FLucideIcons.hexagon,
                  isSelected: _viewMode == CategoryViewMode.radar,
                  onTap: () =>
                      setState(() => _viewMode = CategoryViewMode.radar),
                ),
                const SizedBox(width: 4),
                AppFilterChip(
                  icon: FLucideIcons.list,
                  isSelected: _viewMode == CategoryViewMode.list,
                  onTap: () =>
                      setState(() => _viewMode = CategoryViewMode.list),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart content based on view mode
        AppCard(
          clipBehavior: Clip.antiAlias,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildChartContent(theme, colors),
          ),
        ),
      ],
    );
  }

  Widget _buildChartContent(FThemeData theme, FColors colors) {
    switch (_viewMode) {
      case CategoryViewMode.bar:
        return _buildBarChart(theme, colors);
      case CategoryViewMode.pie:
        return _buildPieChart(theme, colors);
      case CategoryViewMode.radar:
        return _buildRadarChart(theme, colors);
      case CategoryViewMode.list:
        return _buildListView(theme, colors);
    }
  }

  Widget _buildBarChart(FThemeData theme, FColors colors) {
    final maxPercentage = widget.breakdown.items.isEmpty
        ? 100.0
        : widget.breakdown.items
              .map((e) => e.percentage)
              .reduce((a, b) => a > b ? a : b);
    final maxY = maxPercentage > 0 ? maxPercentage * 1.35 : 100.0;

    return SizedBox(
      key: const ValueKey('bar'),
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                tooltipMargin: 4,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                getTooltipColor: (group) => colors.primary,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final item = widget.breakdown.items[group.x];
                  final category = TransactionCategory.fromKey(
                    item.categoryKey,
                  );
                  final currencyCode = ref
                      .read(financialSettingsProvider)
                      .primaryCurrency;
                  final currencySymbol = AmountFormatter.getCurrencySymbol(
                    currencyCode,
                  );
                  return BarTooltipItem(
                    '${category.displayText}\n$currencySymbol${_formatAmount(item.amount, currencyCode)}',
                    theme.typography.body.xs.copyWith(
                      color: colors.primaryForeground,
                      fontWeight: AppFontConfig.headingBold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= widget.breakdown.items.length) {
                      return const SizedBox();
                    }
                    final item = widget.breakdown.items[index];
                    final category = TransactionCategory.fromKey(
                      item.categoryKey,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Icon(
                        category.icon,
                        size: 16,
                        color: colors.foreground,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: widget.breakdown.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final chartColor = context.theme.chartColorAt(index);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item.percentage,
                    color: chartColor,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(FThemeData theme, FColors colors) {
    // Calculate total for center display
    final total = widget.breakdown.items
        .fold<Decimal>(
          Decimal.zero,
          (sum, item) => sum + AmountFormatter.parseDecimal(item.amount),
        )
        .toDouble();
    final topItems = widget.breakdown.items.take(4).toList();

    return Column(
      key: const ValueKey('pie'),
      children: [
        SizedBox(
          height: 180,
          child: Row(
            children: [
              // Pie chart
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 42,
                        sections: widget.breakdown.items.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final item = entry.value;
                          final chartColor = context.theme.chartColorAt(index);
                          return PieChartSectionData(
                            color: chartColor,
                            value: item.percentage,
                            title: '',
                            radius: 28,
                          );
                        }).toList(),
                      ),
                    ),
                    // Center total
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.statistics.analysis.total,
                          style: theme.typography.body.xs.copyWith(
                            color: colors.mutedForeground,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AmountFormatter.getCurrencySymbol(ref.read(financialSettingsProvider).primaryCurrency)}${_formatAmount(total.toStringAsFixed(0), ref.read(financialSettingsProvider).primaryCurrency)}',
                          style: AppTextStyles.listTitle(
                            theme,
                          ).copyWith(letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Legend
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topItems.asMap().entries.map((entry) {
                    final item = entry.value;
                    final category = TransactionCategory.fromKey(
                      item.categoryKey,
                    );
                    // Legend colors must correspond to pie chart segments, use index from original items
                    final originalIndex = widget.breakdown.items.indexOf(item);
                    final chartColor = context.theme.chartColorAt(
                      originalIndex,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: chartColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.displayText,
                              style: theme.typography.body.xs.copyWith(
                                color: colors.foreground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(0)}%',
                            style: AppTextStyles.statLabel(theme),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadarChart(FThemeData theme, FColors colors) {
    // Take top 6 categories for radar chart
    final items = widget.breakdown.items.take(6).toList();
    if (items.length < 3) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            t.statistics.analysis.radarNeedMoreData,
            style: AppTextStyles.listSubtitle(theme),
          ),
        ),
      );
    }

    return SizedBox(
      key: const ValueKey('radar'),
      height: 200,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: theme.typography.body.xs.copyWith(
            color: colors.mutedForeground,
            fontSize: 8,
          ),
          tickBorderData: BorderSide(
            color: colors.border.withValues(alpha: 0.2),
          ),
          gridBorderData: BorderSide(
            color: colors.border.withValues(alpha: 0.3),
          ),
          radarBorderData: BorderSide(
            color: colors.primary.withValues(alpha: 0.5),
          ),
          titleTextStyle: theme.typography.body.xs.copyWith(
            color: colors.mutedForeground,
            fontSize: 9,
          ),
          getTitle: (index, angle) {
            if (index >= items.length) return const RadarChartTitle(text: '');
            final category = TransactionCategory.fromKey(
              items[index].categoryKey,
            );
            final text = category.displayText;
            return RadarChartTitle(
              text: text.length > 2 ? text.substring(0, 2) : text,
            );
          },
          dataSets: [
            RadarDataSet(
              fillColor: colors.primary.withValues(alpha: 0.2),
              borderColor: colors.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: items
                  .map((item) => RadarEntry(value: item.percentage))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(FThemeData theme, FColors colors) {
    return Column(
      key: const ValueKey('list'),
      children: widget.breakdown.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final category = TransactionCategory.fromKey(item.categoryKey);
        final chartColor = context.theme.chartColorAt(index);
        final isLast = index == widget.breakdown.items.length - 1;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  ThemedIcon.compact(icon: category.icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.displayText,
                          style: AppTextStyles.listTrailing(theme),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (item.percentage / 100).clamp(0.0, 1.0),
                            backgroundColor: colors.muted,
                            valueColor: AlwaysStoppedAnimation(chartColor),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AmountText(
                        amount: AmountFormatter.parseDecimal(item.amount),
                        type: TransactionType.expense,
                        semantic: AmountSemantic.status,
                        currency: ref
                            .read(financialSettingsProvider)
                            .primaryCurrency,
                        showSign: false,
                        style: AppTextStyles.listTrailing(theme),
                      ),
                      Text(
                        '${item.percentage.toStringAsFixed(1)}%',
                        style: theme.typography.body.xs.copyWith(
                          color: colors.mutedForeground,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isLast)
              Divider(height: 1, color: colors.border.withValues(alpha: 0.2)),
          ],
        );
      }).toList(),
    );
  }
}
