import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/features/finance/providers/account_view_currency_provider.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/profile/models/financial_account.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';

/// Account list card shown in the financial accounts page.
class FinancialAccountCard extends ConsumerWidget {
  const FinancialAccountCard({
    super.key,
    required this.account,
    required this.hideAmounts,
    required this.onEdit,
  });

  final FinancialAccount account;
  final bool hideAmounts;

  /// Invoked when the card is tapped. Receives the resolved account type
  /// definition (may be null) so callers can reuse it for navigation.
  final void Function(
    FinancialAccount account,
    AccountTypeDefinition? definition,
  )
  onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final definition = AccountTypeRegistry.resolveByApiType(account.type);

    // Use nature field to determine if liability
    final isLiabilityAccount = account.nature == FinancialNature.liability;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Reduced bottom padding
      child: AppCard(
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(10), // Match FCard radius
          child: InkWell(
            onTap: () => onEdit(account, definition),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  // Icon - Using ThemedIcon for consistency
                  ThemedIcon(
                    icon: _getAccountTypeIcon(
                      definition?.id,
                      isLiabilityAccount,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: AppTextStyles.listTitle(theme),
                        ),
                        Text(
                          definition != null
                              ? _getTypeDisplayName(definition)
                              : (isLiabilityAccount
                                    ? t.financial.liabilityAccounts
                                    : t.financial.assetAccounts),
                          style: theme.typography.body.sm.copyWith(
                            // Revert to sm
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      hideAmounts
                          ? const Text('****')
                          : AmountText(
                              amount:
                                  (account.currentBalance ??
                                          account.initialBalance)
                                      .toDouble(),
                              type: isLiabilityAccount
                                  ? TransactionType.expense
                                  : TransactionType.income,
                              semantic: AmountSemantic.status,
                              currency: account.currencyCode,
                              style: AppTextStyles.listTitle(theme),
                            ),
                      Text(
                        account.currencyCode,
                        style: AppTextStyles.listSubtitle(theme),
                      ),
                      if (!hideAmounts) ...[
                        Builder(
                          builder: (context) {
                            final viewCurrency = ref.watch(
                              effectiveViewCurrencyProvider,
                            );
                            if (viewCurrency.toUpperCase() ==
                                account.currencyCode.toUpperCase()) {
                              return const SizedBox.shrink();
                            }
                            final rawBalance =
                                account.currentBalance ??
                                account.initialBalance;
                            final ratesNotifier = ref.watch(
                              exchangeRateProvider.notifier,
                            );
                            final converted = ratesNotifier.convert(
                              rawBalance,
                              account.currencyCode,
                              viewCurrency,
                            );
                            if (converted == null) {
                              return const SizedBox.shrink();
                            }
                            final symbol =
                                Currency.fromCode(viewCurrency)?.symbol ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '≈ $symbol${converted.toDouble().toStringAsFixed(2)} $viewCurrency',
                                style: theme.typography.body.xs.copyWith(
                                  color: colors.mutedForeground.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  // const SizedBox(width: 8),
                  // Icon(
                  //   FLucideIcons.chevronRight,
                  //   size: 16,
                  //   color: colors.mutedForeground.withValues(alpha: 0.5),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _getTypeDisplayName(AccountTypeDefinition definition) {
  switch (definition.id) {
    case 'cash':
      return t.account.cash;
    case 'deposit':
      return t.account.deposit;
    case 'e_money':
      return t.account.eWallet;
    case 'investment':
      return t.account.investment;
    case 'receivable':
      return t.account.receivable;
    case 'credit_card':
      return t.account.creditCard;
    case 'loan':
      return t.account.loan;
    case 'payable':
      return t.account.payable;
    default:
      return definition.title;
  }
}

/// Get Forui icon for account type ID
IconData _getAccountTypeIcon(String? typeId, bool isLiability) {
  switch (typeId) {
    case 'cash':
      return FLucideIcons.wallet;
    case 'deposit':
      return FLucideIcons.landmark;
    case 'e_money':
      return FLucideIcons.smartphone;
    case 'investment':
      return FLucideIcons.trendingUp;
    case 'receivable':
      return FLucideIcons.arrowRight;
    case 'credit_card':
      return FLucideIcons.creditCard;
    case 'loan':
      return FLucideIcons.building;
    case 'payable':
      return FLucideIcons.arrowLeft;
    default:
      return isLiability ? FLucideIcons.creditCard : FLucideIcons.wallet;
  }
}
