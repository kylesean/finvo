import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/finance/models/recurring_transaction.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/widgets/amount_input_field.dart';
import 'package:finvo/shared/widgets/app_filter_chip.dart';

/// Human-readable label for a recurring transaction type.
///
/// M-28: extracted from `RecurringTransactionPage._getTypeLabel` so both the
/// page State and the presentational sections share one implementation.
String recurringTransactionTypeLabel(RecurringTransactionType type) {
  final rt = t.forecast.recurringTransaction;
  switch (type) {
    case RecurringTransactionType.expense:
      return rt.expense;
    case RecurringTransactionType.income:
      return rt.income;
    case RecurringTransactionType.transfer:
      return rt.transfer;
  }
}

/// Top three-button toggle (expense / income / transfer).
class RecurringTypeSelector extends StatelessWidget {
  final RecurringTransactionType selectedType;
  final ValueChanged<RecurringTransactionType> onChanged;

  const RecurringTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: RecurringTransactionType.values.map((type) {
          final isSelected = selectedType == type;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AppFilterChip(
                label: recurringTransactionTypeLabel(type),
                isSelected: isSelected,
                onTap: () => onChanged(type),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Amount input section with the "not fixed" estimate toggle.
class RecurringAmountSection extends StatelessWidget {
  final TextEditingController amountController;
  final AmountType amountType;
  final String typeName;
  final ValueChanged<AmountType> onAmountTypeChanged;

  const RecurringAmountSection({
    super.key,
    required this.amountController,
    required this.amountType,
    required this.typeName,
    required this.onAmountTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final amountFontSize = theme.typography.body.xl2.fontSize ?? 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: AmountInputField(
            controller: amountController,
            fontSize: amountFontSize,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.forecast.recurringTransaction.amountNotFixed(type: typeName),
              style: AppTextStyles.listTrailing(theme),
            ),
            FSwitch(
              value: amountType == AmountType.estimate,
              onChange: (value) => onAmountTypeChanged(
                value ? AmountType.estimate : AmountType.fixed,
              ),
            ),
          ],
        ),
        if (amountType == AmountType.estimate) ...[
          const SizedBox(height: 16),
          FAlert(
            icon: const Icon(FLucideIcons.info, size: 20),
            title: Text(t.forecast.recurringTransaction.dynamicAmountTitle),
            subtitle: Text(
              t.forecast.recurringTransaction.dynamicAmountDescription,
            ),
            variant: .destructive,
          ),
        ],
      ],
    );
  }
}

/// Generic bordered settings row (icon + title + subtitle + trailing).
class RecurringSettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const RecurringSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.mutedForeground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.detailLabel(theme)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.switchTitle(theme)),
                ],
              ),
            ),
            trailing ??
                Icon(
                  FLucideIcons.chevronRight,
                  size: 20,
                  color: colors.mutedForeground,
                ),
          ],
        ),
      ),
    );
  }
}

/// Period settings card: start date + recurrence rule rows.
class RecurringPeriodCard extends StatelessWidget {
  final DateTime startDate;
  final String recurrenceDescription;
  final VoidCallback onStartDateTap;
  final VoidCallback onRepeatTap;

  const RecurringPeriodCard({
    super.key,
    required this.startDate,
    required this.recurrenceDescription,
    required this.onStartDateTap,
    required this.onRepeatTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.budget.periodSettings,
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              RecurringSettingsRow(
                icon: FLucideIcons.calendar,
                title: t.dateRange.startDate,
                subtitle:
                    '${startDate.year}/${startDate.month}/${startDate.day}',
                onTap: onStartDateTap,
                trailing: Icon(
                  FLucideIcons.calendar,
                  size: 20,
                  color: colors.mutedForeground,
                ),
              ),
              Divider(height: 1, color: colors.border),
              RecurringSettingsRow(
                icon: FLucideIcons.repeat,
                title: t.budget.period,
                subtitle: recurrenceDescription,
                onTap: onRepeatTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Account, category and tags card.
class RecurringAccountCategoryCard extends StatelessWidget {
  final RecurringTransactionType selectedType;
  final String? sourceAccountName;
  final String? targetAccountName;
  final String categoryText;
  final List<String> tags;
  final TextEditingController tagController;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onSourceTap;
  final VoidCallback onTargetTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onTagChanged;

  const RecurringAccountCategoryCard({
    super.key,
    required this.selectedType,
    required this.sourceAccountName,
    required this.targetAccountName,
    required this.categoryText,
    required this.tags,
    required this.tagController,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSourceTap,
    required this.onTargetTap,
    required this.onCategoryTap,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final isTransfer = selectedType == RecurringTransactionType.transfer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.transaction.account} & ${t.transaction.category}',
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              if (isTransfer) ...[
                RecurringSettingsRow(
                  icon: FLucideIcons.wallet,
                  title: t.forecast.recurringTransaction.sourceAccount,
                  subtitle: sourceAccountName ?? t.common.all,
                  onTap: onSourceTap,
                ),
                Divider(height: 1, color: colors.border),
                RecurringSettingsRow(
                  icon: FLucideIcons.landmark,
                  title: t.forecast.recurringTransaction.targetAccount,
                  subtitle: targetAccountName ?? t.common.all,
                  onTap: onTargetTap,
                ),
              ] else ...[
                RecurringSettingsRow(
                  icon: FLucideIcons.wallet,
                  title: selectedType == RecurringTransactionType.expense
                      ? t.forecast.recurringTransaction.expenseAccount
                      : t.forecast.recurringTransaction.incomeAccount,
                  subtitle: sourceAccountName ?? t.common.all,
                  onTap: onSourceTap,
                ),
              ],
              Divider(height: 1, color: colors.border),
              RecurringSettingsRow(
                icon: FLucideIcons.layers,
                title: t.transaction.category,
                subtitle: categoryText,
                onTap: onCategoryTap,
              ),
              Divider(height: 1, color: colors.border),
              _buildTagsArea(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsArea(FThemeData theme) {
    final colors = theme.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) =>
                        _RecurringRemovableTag(tag: tag, onRemove: onRemoveTag),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(FLucideIcons.tag, size: 20, color: colors.mutedForeground),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: tagController,
                  decoration: InputDecoration(
                    hintText: t.transaction.tags,
                    hintStyle: AppTextStyles.listSubtitle(theme),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.listTrailing(theme),
                  onChanged: (_) => onTagChanged(),
                  onSubmitted: onAddTag,
                ),
              ),
              if (tagController.text.trim().isNotEmpty)
                GestureDetector(
                  onTap: () => onAddTag(tagController.text),
                  child: Text(
                    t.common.add,
                    style: AppTextStyles.actionText(theme),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Removable tag chip.
class _RecurringRemovableTag extends StatelessWidget {
  final String tag;
  final ValueChanged<String> onRemove;

  const _RecurringRemovableTag({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: theme.typography.body.sm.copyWith(color: colors.foreground),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onRemove(tag),
            child: Icon(
              FLucideIcons.x,
              size: 14,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Advanced options card: confirmation + activation toggles.
class RecurringAdvancedOptions extends StatelessWidget {
  final bool requiresConfirmation;
  final bool isActive;
  final ValueChanged<bool> onConfirmationChanged;
  final ValueChanged<bool> onActiveChanged;

  const RecurringAdvancedOptions({
    super.key,
    required this.requiresConfirmation,
    required this.isActive,
    required this.onConfirmationChanged,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.budget.advancedOptions,
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              _buildToggle(
                theme,
                title: t.forecast.recurringTransaction.confirmBeforeGeneration,
                subtitle:
                    t.forecast.recurringTransaction.confirmBeforeGenerationDesc,
                value: requiresConfirmation,
                onChanged: onConfirmationChanged,
              ),
              Divider(height: 1, color: colors.border),
              _buildToggle(
                theme,
                title: t.budget.enabled,
                subtitle: t.forecast.recurringTransaction.autoGenerateByRule,
                value: isActive,
                onChanged: onActiveChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(
    FThemeData theme, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.switchTitle(theme)),
                Text(subtitle, style: AppTextStyles.detailLabel(theme)),
              ],
            ),
          ),
          FSwitch(value: value, onChange: onChanged),
        ],
      ),
    );
  }
}

/// Bottom save button bar.
class RecurringBottomBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const RecurringBottomBar({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: FButton(
        onPress: isSaving ? null : onSave,
        variant: .primary,
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(t.common.save),
      ),
    );
  }
}
