import 'dart:math' as math;
import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/app/theme/app_theme_palette.dart';
import 'package:finvo/app/theme/forui_theme_config.dart';
import 'package:finvo/features/chat/widgets/chat_action_button.dart';
import 'package:finvo/features/chat/widgets/media_upload_button.dart';
import 'package:finvo/shared/models/transaction_type.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:decimal/decimal.dart';

/// Helper to compute WCAG 2.1 relative luminance
double _relativeLuminance(Color color) {
  double channelLuminance(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    } else {
      return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  final r = channelLuminance(color.r);
  final g = channelLuminance(color.g);
  final b = channelLuminance(color.b);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Helper to calculate contrast ratio between two colors (range: 1.0 to 21.0)
double _contrastRatio(Color c1, Color c2) {
  final l1 = _relativeLuminance(c1);
  final l2 = _relativeLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WCAG 2.1 AA Contrast Ratios (>= 4.5:1)', () {
    test('AppSemanticColors.light.warningAccent meets WCAG AA on white', () {
      final ratio = _contrastRatio(
        AppSemanticColors.light.warningAccent,
        Colors.white,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'warningAccent contrast on white must be >= 4.5:1 for WCAG AA',
      );
    });

    test(
      'AmountTheme.colorBlindFriendly.incomeColor meets WCAG AA on white',
      () {
        final ratio = _contrastRatio(
          AmountTheme.colorBlindFriendly.incomeColor,
          Colors.white,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'colorBlindFriendly incomeColor on white must be >= 4.5:1',
        );
      },
    );

    test(
      'AppThemePalette.yellow light foreground meets WCAG AA on yellow primary',
      () {
        final theme = AppThemePalette.yellow.resolveBaseTheme(Brightness.light);
        final ratio = _contrastRatio(
          theme.colors.primaryForeground,
          theme.colors.primary,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'yellow theme primaryForeground on primary must be >= 4.5:1',
        );
      },
    );
  });

  group('ForUI Adaptive Touch Mode', () {
    test(
      'ForuiThemeConfig.resolve reflects explicit isTouch parameter on button metrics',
      () {
        final touchTheme = ForuiThemeConfig.resolve(
          palette: AppThemePalette.zinc,
          brightness: Brightness.light,
          isTouch: true,
        );
        // touch = true configures minHeight 44 for primary md button
        expect(
          touchTheme.buttonStyles.primary.md.contentStyle.constraints.minHeight,
          equals(44.0),
        );

        final desktopTheme = ForuiThemeConfig.resolve(
          palette: AppThemePalette.zinc,
          brightness: Brightness.light,
          isTouch: false,
        );
        // touch = false configures minHeight 36 for primary md button
        expect(
          desktopTheme
              .buttonStyles
              .primary
              .md
              .contentStyle
              .constraints
              .minHeight,
          equals(36.0),
        );
      },
    );
  });

  group('Interactive Widgets Minimum Tap Target Sizes (>= 48x48 dp)', () {
    testWidgets(
      'ChatActionButton occupies compact 32x32 dp target with semantics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ChatActionButton(
                  icon: FLucideIcons.copy,
                  semanticLabel: 'Copy message',
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(ChatActionButton));
        expect(size.width, greaterThanOrEqualTo(32.0));
        expect(size.height, greaterThanOrEqualTo(32.0));

        final semantics = tester.getSemantics(find.byType(ChatActionButton));
        expect(semantics.label, equals('Copy message'));
        expect(
          semantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
      },
    );

    testWidgets('MediaUploadButton occupies at least 48x48 dp tap target', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: Center(child: MediaUploadButton())),
          ),
        ),
      );

      final size = tester.getSize(find.byType(MediaUploadButton));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      final semantics = tester.getSemantics(find.byType(MediaUploadButton));
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
    });
  });

  group('AmountText Semantics & Contrast', () {
    testWidgets(
      'AmountText provides unified Semantics node and excludes inner spans',
      (tester) async {
        final extendedTheme = FThemeData(
          colors: FColors.neutralLight,
          touch: false,
          extensions: [AppSemanticColors.light],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentAmountThemeProvider.overrideWithValue(
                AmountTheme.chinaMarket,
              ),
            ],
            child: MaterialApp(
              home: FTheme(
                data: extendedTheme,
                child: Scaffold(
                  body: Center(
                    child: AmountText(
                      amount: Decimal.parse('123.45'),
                      type: TransactionType.expense,
                      currency: 'CNY',
                      showSign: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final semanticsFinder = find.descendant(
          of: find.byType(AmountText),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label != null,
          ),
        );
        expect(semanticsFinder, findsAtLeastNWidgets(1));

        final semantics = tester.widget<Semantics>(semanticsFinder.first);
        expect(semantics.properties.label, contains('123.45'));
        expect(semantics.excludeSemantics, isTrue);
      },
    );
  });
}
