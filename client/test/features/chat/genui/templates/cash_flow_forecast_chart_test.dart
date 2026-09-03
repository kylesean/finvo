import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/chat/genui/templates/cash_flow_forecast_chart.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CashFlowForecastViewModel.fromRawMap', () {
    test('parses normal payload', () {
      final vm = CashFlowForecastViewModel.fromRawMap({
        'title': 'Next 30 days',
        'data_points': [
          {
            'date': '2026-08-01',
            'predicted_balance': 100,
            'lower_bound': 90,
            'upper_bound': 110,
            'events': <dynamic>[],
          },
        ],
        'warnings': [
          {'date': '2026-08-02', 'type': 'low', 'message': 'tight'},
        ],
        'summary': {'net': 10},
        'forecast_period': {'days': 30},
        'current_balance': 100,
      });

      expect(vm.title, 'Next 30 days');
      expect(vm.dataPoints, hasLength(1));
      expect(vm.warnings, hasLength(1));
      expect(vm.summary, isNotNull);
      expect(vm.forecastPeriod, isNotNull);
      expect(vm.currentBalance, 100);
    });

    test('tolerates missing fields without crashing', () {
      final vm = CashFlowForecastViewModel.fromRawMap({});

      expect(vm.title, '');
      expect(vm.dataPoints, isEmpty);
      expect(vm.warnings, isEmpty);
      expect(vm.summary, isNull);
      expect(vm.forecastPeriod, isNull);
      expect(vm.currentBalance, 0.0);
    });

    test('tolerates malformed types without crashing', () {
      final vm = CashFlowForecastViewModel.fromRawMap({
        'title': 123,
        'data_points': 'not-a-list',
        'warnings': [42, 'oops'],
        'summary': 'not-a-map',
        'forecast_period': [1, 2],
        'current_balance': 'abc',
      });

      // getString coerces, getList/getMap drop non-maps, getDouble falls back.
      expect(vm.title, '123');
      expect(vm.dataPoints, isEmpty);
      expect(vm.warnings, isEmpty);
      expect(vm.summary, isNull);
      expect(vm.forecastPeriod, isNull);
      expect(vm.currentBalance, 0.0);
    });
  });

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
