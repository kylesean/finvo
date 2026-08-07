// app/router/branches/finance_branch.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/i18n/strings.g.dart';

import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/finance/pages/financial_accounts_page.dart';
import 'package:finvo/features/finance/pages/account_type_picker_page.dart';
import 'package:finvo/features/finance/pages/account_add_page.dart';
import 'package:finvo/features/finance/pages/account_edit_page.dart';
import 'package:finvo/features/finance/pages/account_detail_page.dart';
import 'package:finvo/features/finance/pages/recurring_transaction_list_page.dart';
import 'package:finvo/features/finance/pages/recurring_transaction_page.dart';
import 'package:finvo/features/budget/pages/budget_overview_page.dart';
import 'package:finvo/features/budget/pages/budget_form_page.dart';
import 'package:finvo/features/budget/pages/budget_settings_page.dart';
import 'package:finvo/features/budget/pages/budget_detail_page.dart';

/// The finance [StatefulShellBranch]: financial accounts, recurring
/// transactions and budgets. Extracted to keep the root router concise.
///
/// NOTE: route `name`s are kept identical to the original definitions because
/// they are referenced by named navigation elsewhere.
StatefulShellBranch buildFinanceBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePaths.finance,
        name: AppRouteNames.finance,
        builder: (context, state) {
          return const FinancialAccountsPage();
        },
        routes: [
          GoRoute(
            path: 'accounts',
            name: AppRouteNames.financialAccounts,
            // Reuse FinancialAccountsPage: the previous AccountSourcesPage was
            // a second, duplicated implementation that hard-coded English
            // strings. Converging on the maintained page keeps one source of
            // truth for account management (H4 fix).
            builder: (context, state) => const FinancialAccountsPage(),
            routes: [
              GoRoute(
                path: 'type-picker',
                name: AppRouteNames.financialAccountTypePicker,
                builder: (context, state) => const AccountTypePickerPage(),
              ),
              GoRoute(
                path: 'add',
                name: AppRouteNames.financialAccountAdd,
                builder: (context, state) {
                  final args = state.extra as FinancialAccountAddArgs?;
                  if (args == null) {
                    return Scaffold(
                      body: Center(child: Text(t.error.accountInfoMissing)),
                    );
                  }
                  return FinancialAccountAddPage(args: args);
                },
              ),
              GoRoute(
                path: 'edit',
                name: AppRouteNames.financialAccountEdit,
                builder: (context, state) {
                  final args = state.extra as FinancialAccountEditArgs?;
                  if (args == null) {
                    return Scaffold(
                      body: Center(child: Text(t.error.accountInfoMissing)),
                    );
                  }
                  return FinancialAccountEditPage(args: args);
                },
                routes: [],
              ),
              GoRoute(
                path: 'detail',
                name: AppRouteNames.financialAccountDetail,
                builder: (context, state) {
                  final args = state.extra as FinancialAccountDetailArgs?;
                  if (args == null) {
                    return Scaffold(
                      body: Center(child: Text(t.error.accountInfoMissing)),
                    );
                  }
                  return FinancialAccountDetailPage(args: args);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'recurring-transactions',
            name: AppRouteNames.recurringTransactions,
            builder: (context, state) => const RecurringTransactionListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: AppRouteNames.recurringTransactionNew,
                builder: (context, state) => const RecurringTransactionPage(),
              ),
              GoRoute(
                path: ':id/edit',
                name: AppRouteNames.recurringTransactionEdit,
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  if (id == null) {
                    return Scaffold(
                      body: Center(child: Text(t.error.unknownError)),
                    );
                  }
                  return RecurringTransactionPage(editId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'budgets',
            name: AppRouteNames.budgetOverview,
            builder: (context, state) => const BudgetOverviewPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: AppRouteNames.budgetNew,
                builder: (context, state) => const BudgetFormPage(),
              ),
              GoRoute(
                path: 'settings',
                name: AppRouteNames.budgetSettings,
                builder: (context, state) => const BudgetSettingsPage(),
              ),
              GoRoute(
                path: ':id',
                name: AppRouteNames.budgetDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  if (id == null) {
                    return Scaffold(
                      body: Center(child: Text(t.error.unknownError)),
                    );
                  }
                  return BudgetDetailPage(budgetId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: AppRouteNames.budgetEdit,
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      if (id == null) {
                        return Scaffold(
                          body: Center(child: Text(t.error.unknownError)),
                        );
                      }
                      return BudgetFormPage(editId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
