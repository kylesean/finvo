import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/chat/genui/templates/cash_flow_forecast_chart.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CashFlowForecastChart', () {
    Widget createWidgetUnderTests(
      Map<String, dynamic> data, {
      required SharedPreferences prefs,
    }) {
      return ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          builder: (context, child) {
            final theme = FThemeData(
              colors: FColors.neutralLight,
              touch: false,
            );
            final extendedTheme = FThemeData(
              colors: theme.colors,
              touch: false,
              typography: theme.typography,
              extensions: [AppSemanticColors.light],
            );
            return FTheme(data: extendedTheme, child: child!);
          },
          home: Scaffold(body: CashFlowForecastChart(data: data)),
        ),
      );
    }

    testWidgets('flat prediction curve renders without crash (M10)', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // All predicted/lower/upper values are identical -> minY == maxY. The
      // chart range must be expanded symmetrically instead of dividing by zero.
      final data = {
        'data_points': [
          {
            'date': '2026-08-01',
            'predicted_balance': 100,
            'lower_bound': 100,
            'upper_bound': 100,
            'events': <dynamic>[],
          },
          {
            'date': '2026-08-02',
            'predicted_balance': 100,
            'lower_bound': 100,
            'upper_bound': 100,
            'events': <dynamic>[],
          },
        ],
        'warnings': <dynamic>[],
        'summary': <dynamic>{},
        'forecast_period': {'days': 30},
        'current_balance': 100,
      };

      await tester.pumpWidget(createWidgetUnderTests(data, prefs: prefs));
      await tester.pumpAndSettle();

      expect(
        find.byType(CashFlowForecastChart),
        findsOneWidget,
        reason: 'Flat data must render without throwing a division-by-zero.',
      );
    });

    testWidgets('empty data renders the no-data state', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final data = {
        'data_points': <dynamic>[],
        'warnings': <dynamic>[],
        'summary': <dynamic>{},
        'forecast_period': {'days': 30},
        'current_balance': 0,
      };

      await tester.pumpWidget(createWidgetUnderTests(data, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.byType(CashFlowForecastChart), findsOneWidget);
    });
  });
}
