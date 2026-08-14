import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/i18n/strings.g.dart';

class FinancialAccountDetailArgs {
  const FinancialAccountDetailArgs({
    required this.account,
    required this.definition,
  });

  final FinancialAccount account;
  final AccountTypeDefinition definition;
}

class FinancialAccountDetailPage extends ConsumerWidget {
  const FinancialAccountDetailPage({super.key, required this.args});

  final FinancialAccountDetailArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final theme = context.theme;

    // Use the account's own currency code instead of a hardcoded CNY symbol.
    final formattedAmount = AmountFormatter.formatCommon(
      args.account.initialBalance.toDouble(),
      currencyCode: args.account.currencyCode,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
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
          args.definition.title,
          style: AppTextStyles.pageTitle(theme),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.account.nameLabel, style: AppTextStyles.listSubtitle(theme)),
            const SizedBox(height: 8),
            Text(
              // Use name field
              args.account.name,
              style: AppTextStyles.pageTitle(theme),
            ),
            const SizedBox(height: 24),
            Text(
              t.account.amountLabel,
              style: AppTextStyles.listSubtitle(theme),
            ),
            const SizedBox(height: 8),
            Text(
              formattedAmount,
              style: theme.typography.body.xl.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.statistics.filter.accountType,
                    style: AppTextStyles.listSubtitle(theme),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    args.definition.title,
                    style: AppTextStyles.listTitle(theme),
                  ),
                  if (args.definition.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      args.definition.subtitle,
                      style: AppTextStyles.detailLabel(theme),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  t.common.noData,
                  style: AppTextStyles.listSubtitle(theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
