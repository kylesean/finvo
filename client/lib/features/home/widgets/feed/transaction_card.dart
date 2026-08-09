import 'dart:async';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
// features/home/widgets/feed/transaction_card.dart
import 'package:flutter/material.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/core/utils/app_haptics.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/providers/locale_provider.dart';

import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:finvo/shared/config/category_config.dart';
import 'package:finvo/core/constants/category_constants.dart';

import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// TransactionCard
class TransactionCard extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  /// Primary title: description > rawInput > category name.
  /// Text widget handles truncation via maxLines + ellipsis.
  String _getPrimaryTitle(TransactionModel transaction) {
    final desc = transaction.description?.trim();
    if (desc != null && desc.isNotEmpty) return desc;
    final raw = transaction.rawInput?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return _getCategoryDisplayName(transaction);
  }

  String _getCategoryDisplayName(TransactionModel transaction) {
    if (transaction.categoryText != null &&
        transaction.categoryText!.isNotEmpty) {
      return transaction.categoryText!;
    }

    if (transaction.categoryKey != null &&
        transaction.categoryKey!.isNotEmpty) {
      final category = TransactionCategory.fromKey(transaction.categoryKey!);
      // fromKey maps unknown keys to `others`; for those, prefer the
      // configured display name over a generic "Others" (restores the
      // fallback the former catch branch provided).
      if (category == TransactionCategory.others &&
          transaction.categoryKey!.toUpperCase() != 'OTHERS') {
        return CategoryConfig.getCategoryName(transaction.categoryKey!);
      }
      return category.displayText;
    }
    return transaction.category;
  }

  String _getAmountDisplayText(TransactionModel transaction) {
    if (transaction.display != null) {
      return transaction.display!.fullString;
    }

    return AmountFormatter.formatTransaction(
      type: transaction.type,
      amount: transaction.amount.toDouble(),
      currency: transaction.currency ?? 'CNY',
      showSign: true,
    );
  }

  String _getTimeDisplay(DateTime timestamp) {
    return relativeTime(timestamp);
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return showConfirmDialog(
      context: context,
      title: t.transaction.confirmDelete,
      message: t.transaction.deleteTransactionConfirm,
      cancelLabel: t.common.cancel,
      confirmVariant: FButtonVariant.destructive,
      confirmLabel: t.common.delete,
    );
  }

  /// Performs the optimistic delete. Called from [Dismissible.onDismissed]
  /// AFTER the dismiss animation has completed, so the optimistic removal
  /// inside [deleteTransaction] cannot race the Dismissible's own state (the
  /// "dismissed Dismissible is still in the tree" problem that occurs when
  /// deleting inside confirmDismiss).
  Future<void> _performDelete(BuildContext context, WidgetRef ref) async {
    // Capture the overlay before the async gap: when the optimistic removal
    // succeeds this card is unmounted, so its context can no longer resolve
    // the overlay after the API call returns.
    final overlay = Overlay.maybeOf(context);
    final overlayContext = overlay?.context;

    unawaited(AppHaptics.medium());

    final success = await ref
        .read(transactionFeedProvider.notifier)
        .deleteTransaction(transaction.id);

    if (success) {
      unawaited(AppHaptics.success());
    } else {
      unawaited(AppHaptics.error());
    }

    if (overlay == null) {
      if (context.mounted) {
        TopToast.show(
          context,
          message: success ? t.transaction.deleted : t.transaction.deleteFailed,
          type: success ? ToastType.success : ToastType.error,
        );
      }
      return;
    }

    if (overlayContext == null || !overlayContext.mounted) return;
    TopToast.show(
      overlayContext,
      message: success ? t.transaction.deleted : t.transaction.deleteFailed,
      type: success ? ToastType.success : ToastType.error,
      overlayState: overlay,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final theme = context.theme;
    final colors = theme.colors;
    final amountTheme = ref.watch(currentAmountThemeProvider);

    return Dismissible(
      key: Key('transaction_${transaction.id}'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.4},
      confirmDismiss: (direction) async {
        await AppHaptics.selection();
        if (!context.mounted) return false;
        return _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        unawaited(_performDelete(context, ref));
      },
      background: Container(
        color: colors.background,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.destructive,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: colors.destructive.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            FLucideIcons.trash2,
            color: colors.destructiveForeground,
            size: 22,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          unawaited(
            context.pushNamed(
              AppRouteNames.transactionDetail,
              pathParameters: {'transactionId': transaction.id},
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: colors.background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Left: Category Icon (ThemedIcon) ---
              ThemedIcon.large(
                icon: TransactionCategory.fromKey(transaction.categoryKey).icon,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
                iconColor: colors.primary,
              ),
              const SizedBox(width: 14),

              // --- Right: Content ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Category Name + Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            _getPrimaryTitle(transaction),
                            style: AppTextStyles.listTitle(theme),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getAmountDisplayText(transaction),
                          style: theme.typography.body.lg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AmountFormatter.getAmountColor(
                              transaction.type,
                              amountTheme,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Row 2: Tags/PaymentMethod + Time
                    Row(
                      children: [
                        // Tags or Payment Method
                        Expanded(
                          child: transaction.tags.isNotEmpty
                              ? _buildTagsRow(theme, colors, transaction.tags)
                              : Text(
                                  transaction.paymentMethod ??
                                      t.transaction.expense,
                                  style: AppTextStyles.listSubtitle(theme),
                                ),
                        ),
                        // Time display
                        Text(
                          _getTimeDisplay(transaction.timestamp),
                          style: AppTextStyles.detailLabel(theme),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build tags row
  Widget _buildTagsRow(FThemeData theme, FColors colors, List<String> tags) {
    const maxVisible = 2;
    final visibleTags = tags.take(maxVisible).toList();
    final extraCount = tags.length - maxVisible;

    return Row(
      children: [
        ...visibleTags.map(
          (tag) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tag, style: AppTextStyles.detailLabel(theme)),
            ),
          ),
        ),
        if (extraCount > 0)
          Text('+$extraCount', style: AppTextStyles.detailLabel(theme)),
      ],
    );
  }
}
