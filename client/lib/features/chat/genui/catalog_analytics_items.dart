// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:finvo/features/chat/genui/catalog_helpers.dart';
import 'package:finvo/features/chat/genui/templates/templates.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Cash flow / health score / forecast analytics catalog items.
List<CatalogItem> buildAnalyticsItems() {
  return [
    _buildCashFlowCard(),
    _buildHealthScoreCard(),
    _buildCashFlowForecastChart(),
    _buildExpenseSummaryCard(),
  ];
}

/// Cash flow analysis card component
///
/// Data source: reviewing-finances skill's analyze_cashflow.py.
/// Backend returns camelCase field names (from StatisticsService's CashFlowResponse),
/// where totalIncome/totalExpense/netCashFlow are pre-formatted strings.
/// Health score data (healthScore/healthGrade/healthDimensions/suggestions)
/// is also embedded in the same payload. Widget reads camelCase, schema must match,
/// otherwise genui 0.10's schema validation will trigger error feedback due to missing required fields.
CatalogItem _buildCashFlowCard() {
  return CatalogItem(
    name: 'CashFlowCard',
    dataSchema: ObjectSchema(
      properties: {
        'title': StringSchema(description: '卡片标题'),
        // Cash flow data (camelCase, consistent with backend CashFlowResponse)
        'totalIncome': StringSchema(description: '总收入（格式化字符串）'),
        'totalExpense': StringSchema(description: '总支出（格式化字符串）'),
        'netCashFlow': StringSchema(description: '净现金流（格式化字符串）'),
        'savingsRate': NumberSchema(description: '储蓄率'),
        'expenseToIncomeRatio': NumberSchema(description: '支出收入比'),
        'essentialExpenseRatio': NumberSchema(description: '必要支出占比'),
        'discretionaryExpenseRatio': NumberSchema(description: '可选消费占比'),
        'incomeChangePercent': NumberSchema(description: '收入环比变化'),
        'expenseChangePercent': NumberSchema(description: '支出环比变化'),
        'savingsRateChange': NumberSchema(description: '储蓄率变化'),
        'periodStart': StringSchema(description: '统计周期开始时间'),
        'periodEnd': StringSchema(description: '统计周期结束时间'),
        // Health score data (embedded in analyze_cashflow.py)
        'healthScore': IntegerSchema(description: '财务健康评分 (0-100)'),
        'healthGrade': StringSchema(description: '健康等级 (A/B/C/D/F)'),
        'healthDimensions': ListSchema(
          description: '各维度健康评分',
          items: ObjectSchema(
            properties: {
              'name': StringSchema(description: '维度名称'),
              'score': IntegerSchema(description: '维度得分'),
              'weight': NumberSchema(description: '权重'),
              'description': StringSchema(description: '维度描述'),
              'status': StringSchema(
                description: '状态 (excellent/good/fair/poor)',
              ),
            },
            required: ['name', 'score'],
          ),
        ),
        'suggestions': ListSchema(description: '改进建议列表', items: StringSchema()),
      },
      required: ['netCashFlow', 'savingsRate'],
    ),
    widgetBuilder: _buildCashFlowCardWidget,
  );
}

/// Financial health score card component
///
/// Data source: StatisticsService's HealthScoreResponse (camelCase).
/// Widget reads camelCase fields like totalScore, schema must match.
CatalogItem _buildHealthScoreCard() {
  return CatalogItem(
    name: 'HealthScoreCard',
    dataSchema: ObjectSchema(
      properties: {
        'totalScore': IntegerSchema(description: '总分 (0-100)'),
        'grade': StringSchema(description: '等级 (A/B/C/D/F)'),
        'dimensions': ListSchema(
          description: '各维度评分',
          items: ObjectSchema(
            properties: {
              'name': StringSchema(description: '维度名称'),
              'score': IntegerSchema(description: '维度得分'),
              'weight': NumberSchema(description: '权重'),
              'description': StringSchema(description: '维度描述'),
              'status': StringSchema(
                description: '状态 (excellent/good/fair/poor)',
              ),
            },
            required: ['name', 'score'],
          ),
        ),
        'suggestions': ListSchema(description: '改进建议列表', items: StringSchema()),
        'periodStart': StringSchema(description: '统计周期开始时间'),
        'periodEnd': StringSchema(description: '统计周期结束时间'),
      },
      required: ['totalScore', 'grade'],
    ),
    widgetBuilder: _buildHealthScoreCardWidget,
  );
}

/// Cash flow forecast chart component
CatalogItem _buildCashFlowForecastChart() {
  return CatalogItem(
    name: 'CashFlowForecastChart',
    dataSchema: ObjectSchema(
      properties: {
        'success': BooleanSchema(description: '操作是否成功'),
        'forecast_period': ObjectSchema(
          description: '预测周期信息',
          properties: {
            'start': StringSchema(description: '开始日期 (ISO)'),
            'end': StringSchema(description: '结束日期 (ISO)'),
            'days': IntegerSchema(description: '预测天数'),
          },
        ),
        'current_balance': NumberSchema(description: '当前余额'),
        'data_points': ListSchema(
          description: '预测数据点',
          items: ObjectSchema(
            properties: {
              'date': StringSchema(description: '日期 (ISO)'),
              'predicted_balance': NumberSchema(description: '预测余额'),
              'lower_bound': NumberSchema(description: '下限（保守估计）'),
              'upper_bound': NumberSchema(description: '上限（乐观估计）'),
              'events': ListSchema(
                description: '当日事件',
                items: ObjectSchema(
                  properties: {
                    'type': StringSchema(
                      description: '事件类型',
                      enumValues: [
                        'RECURRING',
                        'PREDICTED_VARIABLE',
                        'SIMULATED',
                      ],
                    ),
                    'description': StringSchema(description: '事件描述'),
                    'amount': NumberSchema(description: '金额'),
                    'source_id': StringSchema(description: '来源ID'),
                    'category_key': StringSchema(description: '分类'),
                    'confidence': NumberSchema(description: '置信度 (0-1)'),
                  },
                  required: ['type', 'description', 'amount'],
                ),
              ),
            },
            required: ['date', 'predicted_balance'],
          ),
        ),
        'warnings': ListSchema(
          description: '预警信息',
          items: ObjectSchema(
            properties: {
              'date': StringSchema(description: '预警日期'),
              'type': StringSchema(
                description: '预警类型',
                enumValues: ['BELOW_SAFETY', 'NEGATIVE_BALANCE'],
              ),
              'message': StringSchema(description: '预警消息'),
            },
            required: ['date', 'type', 'message'],
          ),
        ),
        'summary': ObjectSchema(
          description: '预测摘要',
          properties: {
            'total_recurring_income': NumberSchema(description: '周期性收入总计'),
            'total_recurring_expense': NumberSchema(description: '周期性支出总计'),
            'predicted_variable_expense': NumberSchema(description: '预测可变支出'),
            'net_change': NumberSchema(description: '净变化'),
          },
        ),
        'purchase_analysis': ObjectSchema(
          description: '购买分析（simulate_purchase 专用）',
          properties: {
            'purchase_date': StringSchema(description: '购买日期'),
            'purchase_amount': NumberSchema(description: '购买金额'),
            'description': StringSchema(description: '购买描述'),
            'balance_before': NumberSchema(description: '购买前余额'),
            'balance_after_purchase': NumberSchema(description: '购买后余额'),
            'will_trigger_warning': BooleanSchema(description: '是否触发预警'),
          },
        ),
      },
      required: ['success'],
    ),
    widgetBuilder: _buildCashFlowForecastChartWidget,
  );
}

/// Expense summary card component
CatalogItem _buildExpenseSummaryCard() {
  return CatalogItem(
    name: 'ExpenseSummaryCard',
    dataSchema: ObjectSchema(
      properties: {
        'summary': ObjectSchema(
          properties: {
            'total_expense': NumberSchema(),
            'currency': StringSchema(),
            'distribution': ListSchema(items: ObjectSchema()),
            'top_items': ListSchema(items: ObjectSchema()),
            'count': IntegerSchema(),
          },
        ),
        'items': ListSchema(items: ObjectSchema()),
      },
      required: ['summary'],
    ),
    widgetBuilder: _buildExpenseSummaryCardWidget,
  );
}

/// Build cash flow card widget
Widget _buildCashFlowCardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'CashFlowCard',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      if (!validateRequiredFields(data, ['netCashFlow', 'savingsRate'])) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }
      return CashFlowAnalysisCard(data: data);
    },
  );
}

/// Build financial health score card widget
Widget _buildHealthScoreCardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'HealthScoreCard',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      if (!validateRequiredFields(data, ['totalScore', 'grade'])) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }
      return HealthScoreAnalysisCard(data: data);
    },
  );
}

/// Build cash flow forecast chart widget
Widget _buildCashFlowForecastChartWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'CashFlowForecastChart',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;
      if (!success) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.fetchFailed,
        );
      }
      return CashFlowForecastChart(data: data);
    },
  );
}

/// Build expense summary card widget
Widget _buildExpenseSummaryCardWidget(CatalogItemContext context) {
  try {
    final data = context.data as Map<String, dynamic>;
    return ExpenseSummaryCard(data: data);
  } catch (e) {
    return buildErrorWidget(
      context.buildContext,
      t.chat.genui.error.fetchFailed,
    );
  }
}
