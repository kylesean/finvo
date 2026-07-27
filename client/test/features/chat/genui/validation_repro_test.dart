import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:finvo/features/chat/genui/app_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart' as genui;

/// Reproduction test: feeds REALISTIC backend data (exact format produced by
/// server/app/skills/reviewing-finances/scripts/analyze_spending.py) through
/// SurfaceController to check whether schema validation triggers reportError.
void main() {
  test(
    'BudgetAnalysisCard with real backend data triggers validation error feedback',
    () async {
      final catalog = AppCatalog.build();
      final controller = genui.SurfaceController(catalogs: [catalog]);

      final errorFeedbacks = <String>[];
      final sub = controller.onSubmit.listen((msg) {
        if (msg.text.isEmpty) {
          for (final part in msg.parts) {
            if (part is genui.DataPart) {
              errorFeedbacks.add(utf8.decode(part.bytes, allowMalformed: true));
            }
          }
        }
      });

      // Step 1: CreateSurface (what our translation layer emits)
      controller.handleMessage(
        core.CreateSurfaceMessage(
          surfaceId: 'surface_test_1',
          catalogId: genui.basicCatalogId,
        ),
      );

      // Step 2: UpdateComponents with REAL backend data format
      // (from analyze_spending.py output + event_generator.py injection)
      final componentData = <String, dynamic>{
        'success': true,
        'componentType': 'BudgetAnalysisCard',
        'title': '消费支出分析',
        // by_category: backend sends a DICT keyed by category
        'by_category': {
          'FOOD_DINING': {
            'total': 1234.5,
            'count': 20,
            'percentage': 45.2,
            'avg_per_tx': 61.7,
          },
          'SHOPPING': {
            'total': 800.0,
            'count': 5,
            'percentage': 29.3,
            'avg_per_tx': 160.0,
          },
        },
        // by_month: backend sends a DICT keyed by month
        'by_month': {
          '2026-06': {'total': 1500.0, 'count': 25},
          '2026-07': {'total': 2731.5, 'count': 42},
        },
        // trends: backend sends a DICT
        'trends': {
          'month_over_month': {
            'change_amount': 1231.5,
            'change_percent': 82.1,
            'direction': 'up',
          },
        },
        // top_spenders: array of objects
        'top_spenders': [
          {
            'amount': 500.0,
            'category': 'SHOPPING',
            'description': '电子产品',
            'date': '2026-07-01',
          },
        ],
        // suggestions: backend sends array of OBJECTS (not strings!)
        'suggestions': [
          {
            'type': 'high_percentage',
            'category_key': 'FOOD_DINING',
            'percentage': 45.2,
          },
          {'type': 'monthly_increase', 'percentage': 82.1},
        ],
        'total_expense': 2731.5,
        'transaction_count': 42,
        'period_days': 30,
        '_surfaceId': 'surface_test_1',
      };

      controller.handleMessage(
        core.UpdateComponentsMessage(
          surfaceId: 'surface_test_1',
          components: [
            {'id': 'root', 'component': 'BudgetAnalysisCard', ...componentData},
          ],
        ),
      );

      // Wait for async validation (fire-and-forget in _handleCoreMessage)
      await Future<void>.delayed(const Duration(seconds: 2));

      // After the schema fix (suggestions: StringSchema -> ObjectSchema),
      // validation must pass and NO error feedback should be emitted.
      expect(
        errorFeedbacks,
        isEmpty,
        reason:
            'Schema matches backend data -> no reportError expected. '
            'Got: $errorFeedbacks',
      );

      await sub.cancel();
      controller.dispose();
    },
  );

  test('same data but EMPTY suggestions passes validation', () async {
    final catalog = AppCatalog.build();
    final controller = genui.SurfaceController(catalogs: [catalog]);

    final errorFeedbacks = <String>[];
    final sub = controller.onSubmit.listen((msg) {
      if (msg.text.isEmpty) {
        for (final part in msg.parts) {
          if (part is genui.DataPart) {
            errorFeedbacks.add(utf8.decode(part.bytes, allowMalformed: true));
          }
        }
      }
    });

    controller.handleMessage(
      core.CreateSurfaceMessage(
        surfaceId: 'surface_test_2',
        catalogId: genui.basicCatalogId,
      ),
    );

    controller.handleMessage(
      core.UpdateComponentsMessage(
        surfaceId: 'surface_test_2',
        components: [
          {
            'id': 'root',
            'component': 'BudgetAnalysisCard',
            'success': true,
            'componentType': 'BudgetAnalysisCard',
            'title': '消费支出分析',
            'by_category': <String, dynamic>{},
            'by_month': <String, dynamic>{},
            'trends': <String, dynamic>{},
            'top_spenders': <dynamic>[],
            'suggestions': <dynamic>[],
            'total_expense': 0,
            'transaction_count': 0,
            'period_days': 30,
            '_surfaceId': 'surface_test_2',
          },
        ],
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 2));

    expect(errorFeedbacks, isEmpty);

    await sub.cancel();
    controller.dispose();
  });

  test('CashFlowCard with real backend data (camelCase, string amounts) '
      'passes validation', () async {
    final catalog = AppCatalog.build();
    final controller = genui.SurfaceController(catalogs: [catalog]);

    final errorFeedbacks = <String>[];
    final sub = controller.onSubmit.listen((msg) {
      if (msg.text.isEmpty) {
        for (final part in msg.parts) {
          if (part is genui.DataPart) {
            errorFeedbacks.add(utf8.decode(part.bytes, allowMalformed: true));
          }
        }
      }
    });

    controller.handleMessage(
      core.CreateSurfaceMessage(
        surfaceId: 'surface_test_3',
        catalogId: genui.basicCatalogId,
      ),
    );

    // Real backend format from analyze_cashflow.py:
    // camelCase keys; totalIncome/totalExpense/netCashFlow are FORMATTED
    // STRINGS (CashFlowResponse declares them as str); health score data
    // is embedded in the same payload.
    final componentData = <String, dynamic>{
      'success': true,
      'type': 'CashFlowCard',
      'title': '收支平衡与健康报告',
      'netCashFlow': '+1,234.56',
      'savingsRate': 32.5,
      'totalIncome': '5,000.00',
      'totalExpense': '3,765.44',
      'expenseToIncomeRatio': 75.3,
      'essentialExpenseRatio': 0.62,
      'discretionaryExpenseRatio': 0.38,
      'incomeChangePercent': 5.0,
      'expenseChangePercent': -3.2,
      'savingsRateChange': 4.1,
      'healthScore': 72,
      'healthGrade': 'C',
      'healthDimensions': [
        {
          'name': 'emergency_fund',
          'score': 60,
          'weight': 0.3,
          'description': '应急资金覆盖月数',
          'status': 'fair',
        },
        {
          'name': 'savings_rate',
          'score': 80,
          'weight': 0.25,
          'description': '储蓄率水平',
          'status': 'good',
        },
      ],
      'suggestions': ['建议提高应急资金储备', '保持当前储蓄率'],
      '_surfaceId': 'surface_test_3',
    };

    controller.handleMessage(
      core.UpdateComponentsMessage(
        surfaceId: 'surface_test_3',
        components: [
          {'id': 'root', 'component': 'CashFlowCard', ...componentData},
        ],
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 2));

    expect(
      errorFeedbacks,
      isEmpty,
      reason:
          'CashFlowCard schema must accept camelCase backend data. '
          'Got: $errorFeedbacks',
    );

    await sub.cancel();
    controller.dispose();
  });

  test('SpaceAssociationReceipt with real backend data (UUID string space id) '
      'passes validation', () async {
    final catalog = AppCatalog.build();
    final controller = genui.SurfaceController(catalogs: [catalog]);

    final errorFeedbacks = <String>[];
    final sub = controller.onSubmit.listen((msg) {
      if (msg.text.isEmpty) {
        for (final part in msg.parts) {
          if (part is genui.DataPart) {
            errorFeedbacks.add(utf8.decode(part.bytes, allowMalformed: true));
          }
        }
      }
    });

    controller.handleMessage(
      core.CreateSurfaceMessage(
        surfaceId: 'surface_test_4',
        catalogId: genui.basicCatalogId,
      ),
    );

    // Real backend format from associate_transactions_to_space:
    // space.id is a UUID STRING (not an integer).
    final componentData = <String, dynamic>{
      'success': true,
      'componentType': 'SpaceAssociationReceipt',
      'space': {'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6', 'name': '家庭账本'},
      'association': {'total_count': 3, 'success_count': 3, 'failed_count': 0},
      'message': '成功将 3 笔交易关联到「家庭账本」',
      '_surfaceId': 'surface_test_4',
    };

    controller.handleMessage(
      core.UpdateComponentsMessage(
        surfaceId: 'surface_test_4',
        components: [
          {
            'id': 'root',
            'component': 'SpaceAssociationReceipt',
            ...componentData,
          },
        ],
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 2));

    expect(
      errorFeedbacks,
      isEmpty,
      reason:
          'SpaceAssociationReceipt schema must accept UUID string id. '
          'Got: $errorFeedbacks',
    );

    await sub.cancel();
    controller.dispose();
  });
}
