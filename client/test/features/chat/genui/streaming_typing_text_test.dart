import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/chat/genui/atoms/streaming_typing_text.dart';

void main() {
  group('StreamingTypingText Widget Tests', () {
    testWidgets('renders initial empty text cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StreamingTypingText(text: '')),
        ),
      );

      expect(find.byType(StreamingTypingText), findsOneWidget);
    });

    testWidgets('types text incrementally over time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingTypingText(
              text: 'Hello Finvo',
              charDuration: Duration(milliseconds: 10),
            ),
          ),
        ),
      );

      // Advance clock by 30ms -> 3 characters printed
      await tester.pump(const Duration(milliseconds: 35));
      expect(find.textContaining('Hel'), findsOneWidget);

      // Advance clock until typing completes
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Hello Finvo'), findsOneWidget);
    });

    testWidgets('handles incremental text updates without resetting progress', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingTypingText(
              text: 'Step 1',
              charDuration: Duration(milliseconds: 10),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Step 1'), findsOneWidget);

      // Update text widget to appended text
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingTypingText(
              text: 'Step 1 and Step 2',
              charDuration: Duration(milliseconds: 10),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Step 1 and'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.textContaining('Step 1 and Step 2'), findsOneWidget);
    });
  });
}
