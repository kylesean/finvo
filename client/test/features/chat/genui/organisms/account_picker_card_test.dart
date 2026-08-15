import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/chat/genui/organisms/account_picker_card.dart';
import 'package:finvo/i18n/strings.g.dart';

const List<Map<String, dynamic>> _accounts = [
  {
    'id': 'a1',
    'name': 'Checking',
    'type': 'checking',
    'balance': 100,
    'currency': 'CNY',
  },
  {
    'id': 'a2',
    'name': 'Savings',
    'type': 'savings',
    'balance': 200,
    'currency': 'CNY',
  },
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
  testWidgets('renders the default title and every account', (tester) async {
    await tester.pumpWidget(
      _wrap(const AccountPickerCard(accounts: _accounts)),
    );

    expect(find.text(t.chat.transferWizard.selectAccount), findsOneWidget);
    expect(find.text('Checking'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
  });

  testWidgets('renders custom title and subtitle', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AccountPickerCard(
          accounts: _accounts,
          title: '选择账户',
          subtitle: '仅显示可用账户',
        ),
      ),
    );

    expect(find.text('选择账户'), findsOneWidget);
    expect(find.text('仅显示可用账户'), findsOneWidget);
  });

  testWidgets('tapping an account reports its id via onSelect', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _wrap(
        AccountPickerCard(accounts: _accounts, onSelect: (id) => selected = id),
      ),
    );

    await tester.tap(find.text('Savings'));
    await tester.pump();

    expect(selected, 'a2');
  });

  testWidgets('confirm is disabled until an account is selected', (
    tester,
  ) async {
    var confirmed = false;
    await tester.pumpWidget(
      _wrap(
        AccountPickerCard(
          accounts: _accounts,
          onConfirm: () => confirmed = true,
        ),
      ),
    );

    final button = tester.widget<FButton>(find.byType(FButton));
    expect(button.onPress, isNull);

    await tester.tap(find.text(t.common.confirm));
    await tester.pump();
    expect(confirmed, isFalse);
    // Let forui FButton's longPressExit timer elapse before teardown.
    await tester.pump(const Duration(milliseconds: 1600));
  });

  testWidgets('confirm calls onConfirm once an account is selected', (
    tester,
  ) async {
    var confirmed = false;
    await tester.pumpWidget(
      _wrap(
        AccountPickerCard(
          accounts: _accounts,
          selectedId: 'a1',
          onConfirm: () => confirmed = true,
        ),
      ),
    );

    final button = tester.widget<FButton>(find.byType(FButton));
    expect(button.onPress, isNotNull);

    await tester.tap(find.text(t.common.confirm));
    await tester.pump();
    expect(confirmed, isTrue);
    // Let forui FButton's longPressExit timer elapse before teardown.
    await tester.pump(const Duration(milliseconds: 1600));
  });

  testWidgets(
    'confirmed state (disabled + selected) shows the check card, no button',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AccountPickerCard(
            accounts: _accounts,
            selectedId: 'a1',
            enabled: false,
          ),
        ),
      );

      expect(find.byType(FButton), findsNothing);
      // The confirmed summary row replaces the button entirely.
      expect(find.byIcon(FLucideIcons.check), findsWidgets);
      expect(find.text(t.common.confirm), findsOneWidget);
    },
  );

  testWidgets('disabled card never reports a selection', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _wrap(
        AccountPickerCard(
          accounts: _accounts,
          enabled: false,
          onSelect: (id) => selected = id,
        ),
      ),
    );

    await tester.tap(find.text('Checking'));
    await tester.pump();

    expect(selected, isNull);
  });
}
