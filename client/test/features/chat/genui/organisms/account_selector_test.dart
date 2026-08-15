import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart' as genui;

import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/chat/genui/molecules/molecules.dart';
import 'package:finvo/features/chat/genui/organisms/account_selector.dart';
import 'package:finvo/i18n/strings.g.dart';

const List<Map<String, dynamic>> _openAccounts = [
  {'id': 'a1', 'name': 'Checking', 'type': 'checking', 'currency': 'CNY'},
  {'id': 'a2', 'name': 'Savings', 'type': 'savings', 'currency': 'CNY'},
];

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      builder: (context, child) {
        final theme = FThemeData(colors: FColors.neutralLight, touch: false);
        final extended = FThemeData(
          colors: theme.colors,
          touch: false,
          typography: theme.typography,
          extensions: [AppSemanticColors.light],
        );
        return FTheme(data: extended, child: child!);
      },
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders accounts from the accounts param with default title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const AccountSelector(data: {}, accounts: _openAccounts)),
    );

    expect(find.text(t.transaction.selectLinkedAccount), findsOneWidget);
    expect(find.text('Checking'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
  });

  testWidgets('never offers a CLOSED account for selection', (tester) async {
    const accounts = [
      {'id': 'a1', 'name': 'Checking', 'type': 'checking', 'currency': 'CNY'},
      {'id': 'a9', 'name': 'Archived', 'type': 'checking', 'status': 'CLOSED'},
    ];
    await tester.pumpWidget(
      _wrap(const AccountSelector(data: {}, accounts: accounts)),
    );

    expect(find.text('Checking'), findsOneWidget);
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets('tapping an account dispatches an account_selected action', (
    tester,
  ) async {
    genui.UiEvent? lastEvent;
    await tester.pumpWidget(
      _wrap(
        AccountSelector(
          data: const {},
          accounts: _openAccounts,
          dispatchEvent: (e) => lastEvent = e,
        ),
      ),
    );

    await tester.tap(find.text('Savings'));
    await tester.pump();

    expect(lastEvent, isNotNull);
    expect(lastEvent!.isUserAction, isTrue);
    final action = genui.UserActionEvent.fromMap(lastEvent!.toMap());
    expect(action.name, 'account_selected');
    expect(action.sourceComponentId, 'account_selector');
    expect(action.context['account_id'], 'a2');
    expect(action.context['account_name'], 'Savings');
    expect(action.context['account_type'], 'savings');
  });

  testWidgets('search filters the account list and empty results show noData', (
    tester,
  ) async {
    const many = [
      {'id': 'a1', 'name': 'Checking', 'type': 'checking', 'currency': 'CNY'},
      {'id': 'a2', 'name': 'Savings', 'type': 'savings', 'currency': 'CNY'},
      {'id': 'a3', 'name': 'Wallet', 'type': 'cash', 'currency': 'CNY'},
      {'id': 'a4', 'name': 'Credit', 'type': 'credit', 'currency': 'CNY'},
      {'id': 'a5', 'name': 'Fund', 'type': 'investment', 'currency': 'CNY'},
      {'id': 'a6', 'name': 'Bonus', 'type': 'checking', 'currency': 'CNY'},
    ];
    await tester.pumpWidget(
      _wrap(const AccountSelector(data: {}, accounts: many)),
    );

    // >5 accounts -> search box appears automatically.
    expect(find.byType(FTextField), findsOneWidget);

    await tester.enterText(find.byType(FTextField), 'sav');
    await tester.pump();
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Checking'), findsNothing);

    await tester.enterText(find.byType(FTextField), 'zzzz');
    await tester.pump();
    expect(find.text(t.common.noData), findsOneWidget);
  });

  testWidgets('historical mode hides search and disables selection', (
    tester,
  ) async {
    genui.UiEvent? lastEvent;
    await tester.pumpWidget(
      _wrap(
        AccountSelector(
          data: const {},
          accounts: _openAccounts,
          isHistorical: true,
          dispatchEvent: (e) => lastEvent = e,
        ),
      ),
    );

    expect(find.byType(FTextField), findsNothing);

    await tester.tap(find.text('Checking'));
    await tester.pump();
    expect(lastEvent, isNull);
  });

  testWidgets('preselectedId marks the matching card as selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AccountSelector(
          data: {},
          accounts: _openAccounts,
          preselectedId: 'a2',
        ),
      ),
    );

    final savingsCard = tester
        .widgetList<AccountCard>(find.byType(AccountCard))
        .firstWhere((c) => c.data['id'] == 'a2');
    expect(savingsCard.selected, isTrue);

    final checkingCard = tester
        .widgetList<AccountCard>(find.byType(AccountCard))
        .firstWhere((c) => c.data['id'] == 'a1');
    expect(checkingCard.selected, isFalse);
  });
}
