import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/chat/genui/utils/genui_error_boundary.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/i18n/strings.g.dart';

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

  group('GenUiErrorBoundary', () {
    testWidgets('renders child content when nothing throws', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const GenUiErrorBoundary(
            componentName: 'SafeComponent',
            child: Text('happy path'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('happy path'), findsOneWidget);
      expect(find.text(t.error.genui.loadingFailed), findsNothing);
    });

    testWidgets(
      'degenerates to fallback, reports onError and logs when the builder throws',
      (WidgetTester tester) async {
        final thrown = StateError('boom');
        Object? reportedError;
        StackTrace? reportedStack;

        await tester.pumpWidget(
          wrap(
            GenUiErrorBoundary(
              componentName: 'ExplodingBuilder',
              onError: (error, stackTrace) {
                reportedError = error;
                reportedStack = stackTrace;
              },
              builder: (_) => throw thrown,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Graceful degradation instead of a red error screen.
        expect(find.text(t.error.genui.loadingFailed), findsOneWidget);
        expect(find.text('ExplodingBuilder'), findsOneWidget);
        // The original error object is propagated to the error callback.
        expect(reportedError, same(thrown));
        expect(reportedStack, isNotNull);
      },
    );

    testWidgets(
      'does not catch errors thrown by an already-constructed child build '
      '(documented limitation: only the builder path is guarded)',
      (WidgetTester tester) async {
        final errors = <FlutterErrorDetails>[];
        final previousHandler = FlutterError.onError;
        FlutterError.onError = errors.add;
        addTearDown(() => FlutterError.onError = previousHandler);

        await tester.pumpWidget(
          wrap(
            GenUiErrorBoundary(
              componentName: 'ExplodingChild',
              child: Builder(builder: (_) => throw StateError('boom')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The child-build error surfaces to the framework (global
        // ErrorWidget.builder), not through the boundary's fallback.
        expect(errors, isNotEmpty);
        expect(find.text(t.error.genui.loadingFailed), findsNothing);
      },
    );

    testWidgets(
      'never leaks raw exception text into the fallback detail (M2)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            GenUiErrorBoundary(
              componentName: 'LeakyComponent',
              builder: (_) => throw StateError('internal url: https://secret'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The raw exception string (and the internal URL in it) must not be
        // rendered; the localized generic label is shown instead.
        expect(find.text(t.error.genui.loadingFailed), findsOneWidget);
        expect(find.textContaining('secret'), findsNothing);
        expect(find.textContaining('Bad state'), findsNothing);
      },
    );

    testWidgets('shows the safe message for a known AppException (M2)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          GenUiErrorBoundary(
            componentName: 'KnownErrorComponent',
            builder: (_) => throw BusinessException('预算超限'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // AppException messages are trusted/safe: they surface verbatim.
      expect(find.text(t.error.genui.loadingFailed), findsOneWidget);
      expect(find.text('预算超限'), findsOneWidget);
    });

    testWidgets('renders content produced by a successful builder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          GenUiErrorBoundary(
            componentName: 'BuilderComponent',
            builder: (_) => const Text('builder content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('builder content'), findsOneWidget);
      expect(find.text(t.error.genui.loadingFailed), findsNothing);
    });
  });
}
