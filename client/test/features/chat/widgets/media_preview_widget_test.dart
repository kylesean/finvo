import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/chat/widgets/media_preview_widget.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      builder: (context, child) {
        final theme = FThemeData(colors: FColors.neutralLight, touch: false);
        final extendedTheme = FThemeData(
          colors: theme.colors,
          touch: false,
          typography: theme.typography,
          extensions: [AppSemanticColors.light],
        );
        return FTheme(data: extendedTheme, child: child!);
      },
      home: Scaffold(body: child),
    );
  }

  group('MediaPreviewWidget', () {
    testWidgets('renders nothing when no files are selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MediaPreviewWidget(
            selectedFiles: const [],
            uploadingFiles: const {},
            onRemove: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MediaPreviewWidget), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('renders a file icon for non-image files', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MediaPreviewWidget(
            selectedFiles: [XFile('/tmp/report.pdf', name: 'report.pdf')],
            uploadingFiles: const {},
            onRemove: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Non-images must not attempt to build an Image widget.
      expect(find.byType(Image), findsNothing);
      // The file-type icon row is present, plus the remove button icon.
      expect(find.byIcon(FLucideIcons.fileText), findsOneWidget);
    });

    testWidgets('remove button reports the tapped index', (
      WidgetTester tester,
    ) async {
      final removedIndices = <int>[];
      await tester.pumpWidget(
        wrap(
          MediaPreviewWidget(
            selectedFiles: [
              XFile('/tmp/a.pdf', name: 'a.pdf'),
              XFile('/tmp/b.pdf', name: 'b.pdf'),
            ],
            uploadingFiles: const {},
            onRemove: removedIndices.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Each file row exposes a remove button (the trailing GestureDetector
      // in its Stack); the second row's removes index 1.
      expect(find.byType(GestureDetector), findsNWidgets(4));
      await tester.tap(find.byType(GestureDetector).at(3));
      expect(removedIndices, [1]);
    });
  });
}
