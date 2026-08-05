import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// A premium list showing top transaction items with progress indicators
class TopTransactionCard extends ConsumerWidget {
  final TopTransactionItem transaction;
  final VoidCallback onTap;

  const TopTransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final category = TransactionCategory.fromKey(transaction.categoryKey);

    final currencyCode = ref.watch(financialSettingsProvider).primaryCurrency;

    return AppCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            ThemedIcon.large(icon: category.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayText,
                    style: AppTextStyles.listTrailing(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('MM-dd').format(transaction.transactionAt),
                        style: theme.typography.body.xs.copyWith(
                          color: colors.mutedForeground,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AmountText(
              amount: AmountFormatter.parseDecimal(
                transaction.amount,
              ).toDouble(),
              type: TransactionType.expense,
              semantic: AmountSemantic.status,
              currency: currencyCode,
              showSign: false,
              style: AppTextStyles.listTitle(
                theme,
              ).copyWith(letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}
