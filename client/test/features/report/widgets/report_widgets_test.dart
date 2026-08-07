import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/features/report/widgets/overview_card.dart';
import 'package:finvo/features/report/widgets/trend_chart.dart';
import 'package:finvo/features/report/widgets/category_analysis_section.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/models/financial_settings.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';

void main() {
  final periodStart = DateTime.utc(2026, 1, 1);
  final periodEnd = DateTime.utc(2026, 1, 31);

  final overview = StatisticsOverview(
    totalBalance: '10000.00',
    totalIncome: '8000.00',
    totalExpense: '3000.00',
    incomeChangePercent: 5.5,
    expenseChangePercent: -2.0,
    netChangePercent: 3.2,
    balanceNote: 'Healthy',
    periodStart: periodStart,
    periodEnd: periodEnd,
  );

  const trendData = TrendDataResponse(
    dataPoints: [
      TrendDataPoint(date: '2026-01-01', amount: '100.00', label: '2026-01-01'),
      TrendDataPoint(date: '2026-01-02', amount: '200.00', label: '2026-01-02'),
    ],
    timeRange: 'week',
    transactionType: 'expense',
  );

  const breakdown = CategoryBreakdownResponse(
    items: [
      CategoryBreakdownItem(
        categoryKey: 'food',
        categoryName: 'Food',
        amount: '120.50',
        percentage: 40.0,
        color: '#ff0000',
        icon: 'restaurant',
      ),
      CategoryBreakdownItem(
        categoryKey: 'transport',
        categoryName: 'Transport',
        amount: '80.00',
        percentage: 30.0,
        color: '#00ff00',
        icon: 'car',
      ),
    ],
    total: '200.50',
  );

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          _SharedPrefsHolder.instance,
        ),
        financialSettingsProvider.overrideWithValue(
          const FinancialSettingsState(primaryCurrency: 'CNY'),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _SharedPrefsHolder.instance = await SharedPreferences.getInstance();
  });

  group('OverviewCard', () {
    testWidgets('renders balance, income and expense labels and amounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(OverviewCard(overview: overview)));
      await tester.pumpAndSettle();

      expect(find.byType(OverviewCard), findsOneWidget);
      expect(find.text(t.statistics.overview.balance), findsOneWidget);
      expect(find.text(t.statistics.overview.income), findsOneWidget);
      expect(find.text(t.statistics.overview.expense), findsOneWidget);
      // Amount strings surface the numeric values.
      expect(find.textContaining('10,000'), findsOneWidget);
      expect(find.textContaining('8,000'), findsOneWidget);
      expect(find.textContaining('3,000'), findsOneWidget);
    });
  });

  group('TrendChart', () {
    testWidgets('renders title and expense/income filters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          TrendChart(
            trendData: trendData,
            chartType: ChartType.expense,
            onChartTypeChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TrendChart), findsOneWidget);
      expect(find.text(t.statistics.trend.title), findsOneWidget);
      expect(find.text(t.statistics.trend.expense), findsOneWidget);
      expect(find.text(t.statistics.trend.income), findsOneWidget);
    });

    testWidgets('invokes onChartTypeChanged when income chip is tapped', (
      WidgetTester tester,
    ) async {
      ChartType? changed;
      await tester.pumpWidget(
        wrap(
          TrendChart(
            trendData: trendData,
            chartType: ChartType.expense,
            onChartTypeChanged: (type) => changed = type,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.statistics.trend.income));
      await tester.pumpAndSettle();

      expect(changed, ChartType.income);
    });
  });

  group('CategoryAnalysisSection', () {
    testWidgets('renders nothing when there are no items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const CategoryAnalysisSection(
            breakdown: CategoryBreakdownResponse(items: [], total: '0.00'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryAnalysisSection), findsOneWidget);
      expect(find.text(t.statistics.analysis.expenseTitle), findsNothing);
    });

    testWidgets('renders expense title and default bar view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(const CategoryAnalysisSection(breakdown: breakdown)),
      );
      await tester.pumpAndSettle();

      expect(find.text(t.statistics.analysis.expenseTitle), findsOneWidget);
      expect(find.byKey(const ValueKey('bar')), findsOneWidget);
    });

    testWidgets('switches to income title and list view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const CategoryAnalysisSection(
            breakdown: breakdown,
            chartType: ChartType.income,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(t.statistics.analysis.incomeTitle), findsOneWidget);

      // Switch to list view.
      await tester.tap(find.byIcon(FLucideIcons.list));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('list')), findsOneWidget);
    });
  });
}

/// Holds the shared prefs instance so the amount-theme provider (which reads
/// `sharedPreferencesProvider`) can resolve without hitting real storage.
class _SharedPrefsHolder {
  static late SharedPreferences instance;
}
