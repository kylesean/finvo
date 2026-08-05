import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Shared building blocks for the add/edit financial account form pages.
///
/// The account form (name / initial-balance / currency / hidden / include-in-
/// net-worth rows, plus the pinned save button) is identical across
/// [FinanceAccountAddAndEdit]. These helpers remove the duplicated row
/// builders that previously lived in both pages.

/// Divider between form rows.
Widget buildAccountFormDivider(FColors colors) {
  return Divider(
    height: 1,
    thickness: 1,
    indent: 56,
    color: colors.border.withValues(alpha: 0.3),
  );
}

/// Icon + label + input row.
Widget buildAccountInputRow({
  required FThemeData theme,
  required FColors colors,
  required Widget icon,
  required String label,
  required Widget child,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: Row(
      children: [
        SizedBox(width: 36, height: 36, child: Center(child: icon)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.formLabel(theme)),
              const SizedBox(height: 2),
              child,
            ],
          ),
        ),
      ],
    ),
  );
}

/// Clickable icon + label + value row (e.g. currency picker).
Widget buildAccountTapRow({
  required FThemeData theme,
  required FColors colors,
  required Widget icon,
  required String label,
  required String value,
  bool showArrow = false,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 36, height: 36, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.formLabel(theme)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.formValue(theme)),
              ],
            ),
          ),
          if (showArrow)
            Icon(
              FLucideIcons.chevronRight,
              size: 16,
              color: colors.mutedForeground,
            ),
        ],
      ),
    ),
  );
}

/// Toggle row (hidden / include-in-net-worth switches).
Widget buildAccountSwitchRow({
  required FThemeData theme,
  required FColors colors,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
  bool isLast = false,
}) {
  return InkWell(
    onTap: () => onChanged(!value),
    borderRadius: isLast
        ? const BorderRadius.vertical(bottom: Radius.circular(16))
        : null,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.switchTitle(theme)),
                Text(subtitle, style: AppTextStyles.switchSubtitle(theme)),
              ],
            ),
          ),
          FSwitch(value: value, onChange: onChanged),
        ],
      ),
    ),
  );
}

/// Pinned bottom save button.
Widget buildAccountSaveButton(
  FThemeData theme,
  FColors colors, {
  required VoidCallback onSave,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    decoration: BoxDecoration(
      color: colors.background,
      border: Border(
        top: BorderSide(color: colors.border.withValues(alpha: 0.3), width: 1),
      ),
    ),
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FButton(onPress: onSave, child: Text(t.account.save)),
      ),
    ),
  );
}

/// Format a balance as a 2-decimal string for the balance field.
String formatAccountAmount(Decimal balance) {
  final value = double.tryParse(balance.toString()) ?? 0.0;
  return value.toStringAsFixed(2);
}
