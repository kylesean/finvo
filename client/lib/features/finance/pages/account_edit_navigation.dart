import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/features/finance/pages/account_edit_page.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/finance/models/account_type_definition.dart';
import 'package:finvo/features/profile/models/financial_account.dart';

/// Shared navigation helper for opening the account edit page.
///
/// Extracted to avoid duplicating the definition-resolution and push logic
/// across [financial_accounts_page] and [account_sources_page].
Future<void> pushAccountEditPage(
  BuildContext context,
  FinancialAccount account,
  AccountTypeDefinition? definition,
) async {
  final accountDefinition =
      definition ??
      AccountTypeRegistry.resolveByApiType(account.type) ??
      AccountTypeRegistry.getDefaultDefinition(account.nature);

  await context.pushNamed(
    AppRouteNames.financialAccountEdit,
    extra: FinancialAccountEditArgs(
      definition: accountDefinition,
      account: account,
    ),
  );
}
