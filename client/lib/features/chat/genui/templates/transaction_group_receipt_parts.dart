// Pure, stateless render helpers shared by [TransactionGroupReceipt].
//
// Extracted from the 1000+ line receipt widget so the atomic visual building
// blocks can be reviewed, reused and tested independently of the interactive
// state machinery (carousel/list mode, account/space pickers) in the parent.
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/models/transaction_type.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:decimal/decimal.dart';

/// Molecule: category icon + name/tags + amount, the repeated header row of
/// both the carousel and list view.
Widget buildGroupTransactionInfo(
  FThemeData theme,
  FColors colors,
  TransactionCategory category,
  List<String> tags,
  Decimal amount,
  bool isExpense, {
  double iconSize = 44,
  String? currency,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Left: Category Icon - Using ThemedIcon for consistency
      iconSize >= 44
          ? ThemedIcon.large(icon: category.icon)
          : ThemedIcon(icon: category.icon),
      const SizedBox(width: 12),

      // Middle: Category Name & Tags
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Name
            Text(
              category.displayText,
              style: AppTextStyles.listTitle(theme).copyWith(height: 1.2),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Tags or Type Description
            tags.isNotEmpty
                ? buildGroupTagsRow(theme, colors, tags)
                : Text(
                    isExpense ? t.transaction.expense : t.transaction.income,
                    style: theme.typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                      height: 1.2,
                    ),
                  ),
          ],
        ),
      ),

      const SizedBox(width: 8),

      // Right: Amount
      buildGroupAmount(
        theme,
        amount,
        isExpense,
        currency: currency,
        style: AppTextStyles.pageTitleLarge(
          theme,
        ).copyWith(letterSpacing: -0.5, height: 1.2),
      ),
    ],
  );
}

/// Atom: Tags row
///
/// Mirrors the home feed: show at most [maxVisible] tags and collapse the
/// rest into a `+N` counter. Each visible tag is [Flexible] so a long label
/// (e.g. a merchant name) ellipsizes instead of overflowing the row when the
/// amount column on the right leaves little room.
Widget buildGroupTagsRow(FThemeData theme, FColors colors, List<String> tags) {
  const maxVisible = 2;
  final visibleTags = tags.take(maxVisible).toList();
  final extraCount = tags.length - maxVisible;

  return Row(
    children: [
      for (final tag in visibleTags)
        Flexible(
          fit: FlexFit.loose,
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.muted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Text(
                tag,
                style: AppTextStyles.detailLabel(theme),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      if (extraCount > 0)
        Text('+$extraCount', style: AppTextStyles.detailLabel(theme)),
    ],
  );
}

/// Molecule: Amount
Widget buildGroupAmount(
  FThemeData theme,
  Decimal amount,
  bool isExpense, {
  TextStyle? style,
  String? currency,
}) {
  return AmountText(
    amount: amount,
    type: isExpense ? TransactionType.expense : TransactionType.income,
    currency: currency,
    style:
        style ??
        theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.w700,
        ), // Elevated default weight and size
  );
}

/// Atom: Action pill style (account/space association buttons)
Widget buildGroupActionPill(
  FThemeData theme,
  FColors colors, {
  required IconData icon,
  required String label,
  required Color activeColor,
  required bool isActive,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    decoration: BoxDecoration(
      color: isActive
          ? activeColor.withValues(alpha: 0.08)
          : colors.muted.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 12,
          color: isActive ? activeColor : colors.mutedForeground,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: theme.typography.body.xs.copyWith(
              color: isActive ? activeColor : colors.mutedForeground,
              fontWeight: isActive ? FontWeight.w600 : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
