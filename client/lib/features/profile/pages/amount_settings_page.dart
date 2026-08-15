import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'dart:async';
import 'package:finvo/shared/theme/form_text_styles.dart';

class AmountSettingsPage extends ConsumerWidget {
  const AmountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final currentThemeId = ref.watch(amountThemeProvider).themeId;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: FButton.icon(
          variant: .ghost,
          onPress: () => context.pop(),
          child: Icon(
            FLucideIcons.chevronLeft,
            color: colors.foreground,
            size: 20,
          ),
        ),
        title: Text(
          t.settings.amountDisplayStyle,
          style: AppTextStyles.pageTitle(theme),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Live Preview Card
            _AmountThemePreviewCard(themeId: currentThemeId),

            const SizedBox(height: 20),

            // Instruction text
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                t.settings.selectAmountStyle,
                style: AppTextStyles.sectionHeader(theme),
              ),
            ),

            // Amount theme options in FTileGroup
            FTileGroup(
              children: AmountTheme.availableThemes.map((option) {
                final isSelected = currentThemeId == option.id;

                // Get localized title and subtitle
                String title = option.name;
                String subtitle = option.description;

                if (option.id == 'chinaMarket') {
                  title = t.amountTheme.chinaMarket;
                  subtitle = t.amountTheme.chinaMarketDesc;
                } else if (option.id == 'international') {
                  title = t.amountTheme.international;
                  subtitle = t.amountTheme.internationalDesc;
                } else if (option.id == 'minimalist') {
                  title = t.amountTheme.minimalist;
                  subtitle = t.amountTheme.minimalistDesc;
                } else if (option.id == 'colorBlindFriendly') {
                  title = t.amountTheme.colorBlind;
                  subtitle = t.amountTheme.colorBlindDesc;
                }

                return FTile(
                  title: Text(
                    title,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? colors.primary : colors.foreground,
                    ),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: AppTextStyles.listSubtitle(theme),
                  ),
                  suffix: isSelected
                      ? Icon(
                          FLucideIcons.check,
                          size: 20,
                          color: colors.primary,
                        )
                      : null,
                  onPress: () {
                    unawaited(
                      ref
                          .read(amountThemeProvider.notifier)
                          .setTheme(option.id),
                    );
                    ToastService.success(
                      description: Text(t.settings.appearanceUpdated),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Live preview card widget for amount theme
class _AmountThemePreviewCard extends StatelessWidget {
  final String themeId;

  const _AmountThemePreviewCard({required this.themeId});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final amountTheme = AmountTheme.fromName(themeId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FLucideIcons.eye, size: 16, color: colors.mutedForeground),
              const SizedBox(width: 8),
              Text(
                t.forecast.recurringTransaction.preview,
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PreviewItem(
                label: t.transaction.income,
                amount: '+ ¥12,500.00',
                color: amountTheme.incomeColor,
              ),
              _PreviewItem(
                label: t.transaction.expense,
                amount: '- ¥45.00',
                color: amountTheme.expenseColor,
              ),
              _PreviewItem(
                label: t.transaction.transfer,
                amount: '¥500.00',
                color: amountTheme.transferColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _PreviewItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
