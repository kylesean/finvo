import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/budget/models/budget_models.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Bottom-sheet period-type picker for the budget form.
///
/// M-28: extracted from `_PeriodTypePicker` inside `budget_form_page` so the
/// page stays focused on form state while this helper owns the selection UI.
class BudgetPeriodTypePicker extends StatelessWidget {
  final BudgetPeriodType selectedType;
  final ValueChanged<BudgetPeriodType> onSelected;

  const BudgetPeriodTypePicker({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              t.budget.selectPeriodType,
              style: AppTextStyles.dialogTitle(theme),
            ),
            const SizedBox(height: 16),
            ...BudgetPeriodType.values.map((type) {
              final isSelected = type == selectedType;
              return ListTile(
                leading: Icon(
                  isSelected ? FLucideIcons.check : FLucideIcons.calendarDays,
                  color: isSelected ? colors.primary : colors.mutedForeground,
                ),
                title: Text(
                  type.label,
                  style: theme.typography.body.sm.copyWith(
                    color: colors.foreground,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () => onSelected(type),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
