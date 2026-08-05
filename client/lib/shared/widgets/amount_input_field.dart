import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Amount input field with currency symbol prefix.
///
/// Follows the global currency setting and shares the same appearance across
/// budget and recurring transaction forms.
class AmountInputField extends ConsumerWidget {
  final TextEditingController controller;
  final double fontSize;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Currency symbol - follows global settings
        Text(
          Currency.fromCode(
                ref.watch(financialSettingsProvider).primaryCurrency,
              )?.symbol ??
              '¥',
          style: AppTextStyles.statLabel(theme).copyWith(fontSize: fontSize),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: fontSize,
              color: colors.foreground,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            cursorColor: colors.primary,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              isCollapsed: true,
              hintText: '0.00',
              hintStyle: TextStyle(
                fontSize: fontSize,
                color: colors.mutedForeground,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
