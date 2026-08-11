import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:finvo/features/layout/widgets/nav_icon.dart';

void main() {
  group('NavIcon', () {
    testWidgets('renders outline SVG when inactive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavIcon(
              type: NavIconType.house,
              active: false,
              color: Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders filled SVG when active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavIcon(
              type: NavIconType.botChat,
              active: true,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('supports all navigation icon types', (tester) async {
      for (final type in NavIconType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NavIcon(type: type, active: false, color: Colors.black),
            ),
          ),
        );

        expect(find.byType(SvgPicture), findsOneWidget);
      }
    });
  });
}
