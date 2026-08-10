import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/chat/genui/utils/genui_num_utils.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Financial health score card - GenUI Template
///
/// Displays user's financial health score in AI chat.
/// Uses compact + expandable design for progressive disclosure.
class HealthScoreAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const HealthScoreAnalysisCard({super.key, required this.data});

  @override
  State<HealthScoreAnalysisCard> createState() =>
      _HealthScoreAnalysisCardState();
}

class _HealthScoreAnalysisCardState extends State<HealthScoreAnalysisCard> {
  bool _isExpanded = false;

  /// Get grade color - based on theme semantic colors
  /// A=success(successAccent), B=primary, C=warning(warningAccent), D/F=destructive
  Color _getGradeColor(
    String grade,
    FColors colors,
    AppSemanticColors semantic,
  ) {
    switch (grade) {
      case 'A':
        return semantic.successAccent;
      case 'B':
        return colors.primary;
      case 'C':
        return semantic.warningAccent;
      case 'D':
        return colors.destructive;
      default:
        return colors.destructive;
    }
  }

  String _getGradeSummary(String grade) {
    switch (grade) {
      case 'A':
        return t.chat.genui.healthScore.status.excellent;
      case 'B':
        return t.chat.genui.healthScore.status.good;
      case 'C':
        return t.chat.genui.healthScore.status.fair;
      case 'D':
        return t.chat.genui.healthScore.status.needsImprovement;
      default:
        return t.chat.genui.healthScore.status.poor;
    }
  }

  Color _getStatusColor(
    String status,
    FColors colors,
    AppSemanticColors semantic,
  ) {
    switch (status) {
      case 'excellent':
        return semantic.successAccent;
      case 'good':
        return colors.primary;
      case 'fair':
        return semantic.warningAccent;
      default:
        return colors.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final grade = widget.data['grade'] as String? ?? 'C';
    // Untrusted AI data: score may arrive as a string, keep the cast safe.
    final totalScore = GenUiNumUtils.toInt(widget.data['totalScore']);
    final dimensions = widget.data['dimensions'] as List? ?? [];
    final suggestions = widget.data['suggestions'] as List? ?? [];
    final semantic = theme.semantic;
    final gradeColor = _getGradeColor(grade, colors, semantic);

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.foreground.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact header - always visible
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(FLucideIcons.heart, size: 18, color: gradeColor),
                      const SizedBox(width: 8),
                      Text(
                        t.chat.genui.healthScore.title,
                        style: AppTextStyles.listTrailing(theme),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getGradeSummary(grade),
                        style: AppTextStyles.detailLabel(theme),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Grade badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gradeColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              grade,
                              style: theme.typography.body.sm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$totalScore',
                              style: theme.typography.body.xs.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? FLucideIcons.chevronUp
                            : FLucideIcons.chevronDown,
                        size: 16,
                        color: colors.mutedForeground,
                      ),
                    ],
                  ),
                ],
              ),

              // Expanded details
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                // Dimensions
                ...dimensions.map((dim) {
                  // Untrusted AI data: skip malformed dimension entries.
                  if (dim is! Map<String, dynamic>) {
                    return const SizedBox.shrink();
                  }
                  final dimMap = dim;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDimensionBar(context, dimMap),
                  );
                }),
                // Suggestions
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    t.chat.genui.healthScore.suggestions,
                    style: AppTextStyles.listTrailing(theme),
                  ),
                  const SizedBox(height: 8),
                  ...suggestions.map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FLucideIcons.info,
                            size: 14,
                            color: theme.semantic.warningAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion.toString(),
                              style: AppTextStyles.detailLabel(theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionBar(
    BuildContext context,
    Map<String, dynamic> dimension,
  ) {
    final theme = context.theme;
    final colors = theme.colors;

    final name = dimension['name'] as String? ?? '';
    final score = GenUiNumUtils.toInt(dimension['score']);
    final description = dimension['description'] as String? ?? '';
    final status = dimension['status'] as String? ?? 'fair';
    final semantic = theme.semantic;
    final statusColor = _getStatusColor(status, colors, semantic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: theme.typography.body.sm),
            Text(
              t.chat.genui.healthScore.scorePoint(score: score),
              style: AppTextStyles.listTrailing(
                theme,
              ).copyWith(color: statusColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: colors.muted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: score / 100,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(description, style: AppTextStyles.detailLabel(theme)),
      ],
    );
  }
}
