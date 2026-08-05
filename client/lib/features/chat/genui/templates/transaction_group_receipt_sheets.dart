import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Standalone dialogs / sheets used by [TransactionGroupReceipt].
///
/// Extracted from the 1200+ line template so each dialog is independently
/// testable and the widget state only orchestrates, not renders, these flows.

/// Info row (label + value) used inside the currency-mismatch dialog.
Widget _buildInfoRow(
  FThemeData theme,
  FColors colors,
  String label,
  String value,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTextStyles.listSubtitle(theme)),
      Text(value, style: AppTextStyles.listTrailing(theme)),
    ],
  );
}

/// Confirms associating a transaction to an account whose currency differs
/// from the transaction's currency. Returns true when the user accepts.
Future<bool> showCurrencyMismatchConfirmDialog(
  BuildContext context, {
  required double amount,
  required String fromCurrency,
  required String toCurrency,
  required String accountName,
}) async {
  final theme = context.theme;
  final colors = theme.colors;
  bool confirmed = false;

  await showFDialog<void>(
    context: context,
    builder: (dialogContext, style, animation) => FDialog(
      animation: animation,
      builder: (context, dialogStyle) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  FLucideIcons.triangleAlert,
                  color: theme.semantic.warningAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t.chat.genui.transactionGroupReceipt.currencyMismatchTitle,
                  style: dialogStyle.titleTextStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.chat.genui.transactionGroupReceipt.currencyMismatchDesc,
                  style: AppTextStyles.listSubtitle(theme),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        theme,
                        colors,
                        t.chat.genui.transactionGroupReceipt.transactionAmount,
                        '${amount.toStringAsFixed(2)} $fromCurrency',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        theme,
                        colors,
                        t.chat.genui.transactionGroupReceipt.accountCurrency,
                        toCurrency,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        theme,
                        colors,
                        t.chat.genui.transactionGroupReceipt.targetAccount,
                        accountName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t.chat.genui.transactionGroupReceipt.currencyMismatchNote,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.semantic.warningAccent,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FButton(
              variant: .outline,
              onPress: () => Navigator.pop(dialogContext),
              child: Text(t.common.cancel),
            ),
            const SizedBox(height: 8),
            FButton(
              onPress: () {
                confirmed = true;
                Navigator.pop(dialogContext);
              },
              child: Text(
                t.chat.genui.transactionGroupReceipt.confirmAssociate,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  return confirmed;
}

/// Bottom sheet to pick a shared space for a transaction.
///
/// [spaces] is the cached list of `{id, name}` maps; [associatedIds] are the
/// space ids already attached to the transaction. Returns the selected space
/// id, or null when cancelled.
Future<dynamic> showSpacePickerSheet(
  BuildContext context, {
  required List<Map<String, dynamic>> spaces,
  required List<String> associatedIds,
}) {
  final theme = context.theme;
  final colors = theme.colors;

  return showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.chat.genui.transactionGroupReceipt.selectSpace,
            style: AppTextStyles.listTitle(theme),
          ),
          const SizedBox(height: 16),
          ...spaces.map((space) {
            final spaceId = space['id'];
            final isSelected = associatedIds.contains(spaceId?.toString());
            final name = space['name'] as String? ?? 'unnamed';

            return GestureDetector(
              onTap: () => Navigator.pop(context, spaceId),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.theme.semantic.sharedSpaceBackground
                      : colors.muted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? context.theme.semantic.sharedSpaceAccent.withValues(
                            alpha: 0.5,
                          )
                        : colors.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.users,
                      size: 18,
                      color: isSelected
                          ? context.theme.semantic.sharedSpaceAccent
                          : colors.mutedForeground,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                          color: isSelected
                              ? context.theme.semantic.sharedSpaceAccent
                              : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: context.theme.semantic.sharedSpaceAccent,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
