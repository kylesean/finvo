import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// A high-fidelity placeholder for when there's no data.
class PremiumEmptyState extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const PremiumEmptyState({super.key, required this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Column(
      children: [
        const SizedBox(height: 16),
        // Ghost Overview Card (Visual Preview)
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.background, colors.muted.withValues(alpha: 0.2)],
            ),
          ),
          child: Stack(
            children: [
              // Abstract background elements
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  FLucideIcons.activity,
                  size: 120,
                  color: colors.primary.withValues(alpha: 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.muted.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildGhostIndicator(colors),
                        const SizedBox(width: 24),
                        _buildGhostIndicator(colors),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Main CTA Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FLucideIcons.sparkles,
                  size: 32,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t.statistics.emptyState.title,
                style: AppTextStyles.pageTitleLarge(theme),
              ),
              const SizedBox(height: 12),
              Text(
                t.statistics.emptyState.description,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 40,
                child: FButton(
                  onPress: onAddTransaction,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FLucideIcons.plus, size: 18),
                      const SizedBox(width: 8),
                      Text(t.statistics.emptyState.action),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Ghost Charts (Bottom Visual Balance)
        Opacity(
          opacity: 0.5,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: colors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      FLucideIcons.chartPie,
                      color: colors.mutedForeground.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: colors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      FLucideIcons.chartColumn,
                      color: colors.mutedForeground.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGhostIndicator(FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 6,
          decoration: BoxDecoration(
            color: colors.muted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 16,
          decoration: BoxDecoration(
            color: colors.muted.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
