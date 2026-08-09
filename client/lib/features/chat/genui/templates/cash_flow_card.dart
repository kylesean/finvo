import 'package:flutter/material.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:forui/forui.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Cash Flow Analysis Card - GenUI Template
///
/// Used to display the user's cash flow analysis results in AI chat.
/// Uses a simplified and expandable design for progressive disclosure of detailed information.
///
/// Supports an optional `ai_insight` field to display an AI-generated analysis summary.
class CashFlowAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const CashFlowAnalysisCard({super.key, required this.data});

  @override
  State<CashFlowAnalysisCard> createState() => _CashFlowAnalysisCardState();
}

class _CashFlowAnalysisCardState extends State<CashFlowAnalysisCard> {
  bool _isExpanded = false;

  String _formatAmount(dynamic amount) {
    final numberFormat = AmountFormatter.getNumberFormat('CNY');
    if (amount is String) {
      return numberFormat.format(double.tryParse(amount) ?? 0);
    }
    return numberFormat.format(amount ?? 0);
  }

  String _formatPercent(dynamic value) {
    final v = _asDouble(value) ?? 0;
    return '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}%';
  }

  /// AI-provided numbers may arrive as `num` or as numeric strings; coerce
  /// both instead of crashing the build with a `TypeError` on bad payloads.
  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = context.theme;
        final colors = theme.colors;
        final amountTheme = ref.watch(currentAmountThemeProvider);

        final netCashFlow = widget.data['netCashFlow'];
        final savingsRate = _asDouble(widget.data['savingsRate']) ?? 0;
        final isPositive = savingsRate >= 0;
        final aiInsight = widget.data['aiInsight'] as String?;

        return GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - always visible
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            FLucideIcons.trendingUp,
                            size: 20,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.chat.genui.cashFlowCard.title,
                                style: AppTextStyles.listTitle(theme),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '¥${_formatAmount(netCashFlow)}',
                                    style: theme.typography.body.lg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isPositive
                                          ? amountTheme.incomeColor
                                          : amountTheme.expenseColor,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (isPositive
                                                  ? amountTheme.incomeColor
                                                  : amountTheme.expenseColor)
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      t.chat.genui.cashFlowCard.savingsRate(
                                        rate: savingsRate.toStringAsFixed(0),
                                      ),
                                      style: AppTextStyles.statLabel(theme)
                                          .copyWith(
                                            color: isPositive
                                                ? amountTheme.incomeColor
                                                : amountTheme.expenseColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? FLucideIcons.chevronUp
                              : FLucideIcons.chevronDown,
                          size: 16,
                          color: colors.mutedForeground,
                        ),
                      ],
                    ),

                    // Expanded details
                    if (_isExpanded) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1, color: colors.border),
                      const SizedBox(height: 16),

                      // Income & Expense
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              amountTheme,
                              label: t.chat.genui.cashFlowCard.totalIncome,
                              value:
                                  '¥${_formatAmount(widget.data['totalIncome'])}',
                              change: _asDouble(
                                widget.data['incomeChangePercent'],
                              ),
                              valueColor: amountTheme.incomeColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              amountTheme,
                              label: t.chat.genui.cashFlowCard.totalExpense,
                              value:
                                  '¥${_formatAmount(widget.data['totalExpense'])}',
                              change: _asDouble(
                                widget.data['expenseChangePercent'],
                              ),
                              inverseColor: true,
                              valueColor: amountTheme.expenseColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Expense breakdown
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              amountTheme,
                              label: t.chat.genui.cashFlowCard.essentialExpense,
                              value:
                                  '${(_asDouble(widget.data['essentialExpenseRatio']) ?? 0).toStringAsFixed(0)}%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              amountTheme,
                              label: t
                                  .chat
                                  .genui
                                  .cashFlowCard
                                  .discretionaryExpense,
                              value:
                                  '${(_asDouble(widget.data['discretionaryExpenseRatio']) ?? 0).toStringAsFixed(0)}%',
                            ),
                          ),
                        ],
                      ),
                      // AI Insight section (if available)
                      if (aiInsight != null && aiInsight.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.muted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    FLucideIcons.sparkles,
                                    size: 14,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.chat.genui.cashFlowCard.aiInsight,
                                    style: AppTextStyles.badge(theme),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GptMarkdown(
                                aiInsight,
                                style: theme.typography.body.sm.copyWith(
                                  color: colors.foreground.withValues(
                                    alpha: 0.9,
                                  ),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    AmountTheme amountTheme, {
    required String label,
    required String value,
    double? change,
    bool inverseColor = false,
    Color? valueColor,
  }) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.detailLabel(theme)),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.listTrailing(theme),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 4),
                Text(
                  _formatPercent(change),
                  style: theme.typography.body.xs.copyWith(
                    color: (inverseColor ? change <= 0 : change >= 0)
                        ? amountTheme.incomeColor
                        : amountTheme.expenseColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
