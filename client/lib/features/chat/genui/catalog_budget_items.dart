// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:finvo/features/chat/genui/catalog_helpers.dart';
import 'package:finvo/features/chat/genui/templates/templates.dart';

/// Budget related catalog items.
List<CatalogItem> buildBudgetItems() {
  return [
    _buildBudgetStatusCard(),
    _buildBudgetReceipt(),
    _buildBudgetAnalysisCard(),
  ];
}

/// Budget status card component
CatalogItem _buildBudgetStatusCard() {
  return CatalogItem(
    name: 'BudgetStatusCard',
    dataSchema: ObjectSchema(
      properties: {
        'success': BooleanSchema(description: '操作是否成功'),
        'has_budget': BooleanSchema(description: '是否有预算'),
        'message': StringSchema(description: '消息'),
        // Single budget query
        'budget': ObjectSchema(
          description: '单个预算信息',
          properties: {
            'id': StringSchema(description: '预算ID'),
            'name': StringSchema(description: '预算名称'),
            'category_key': StringSchema(description: '分类键'),
            'amount': NumberSchema(description: '预算金额'),
            'spent': NumberSchema(description: '已用金额'),
            'remaining': NumberSchema(description: '剩余金额'),
            'percentage': NumberSchema(description: '使用百分比'),
            'status': StringSchema(description: '状态'),
            'period_start': StringSchema(description: '周期开始'),
            'period_end': StringSchema(description: '周期结束'),
          },
        ),
        // Budget summary
        'overall_spent': NumberSchema(description: '总已用金额'),
        'overall_remaining': NumberSchema(description: '总剩余金额'),
        'overall_percentage': NumberSchema(description: '总使用百分比'),
        'budgets': ListSchema(
          description: '预算列表',
          items: ObjectSchema(
            properties: {
              'id': StringSchema(description: '预算ID'),
              'name': StringSchema(description: '预算名称'),
              'scope': StringSchema(description: '范围'),
              'category_key': StringSchema(description: '分类键'),
              'amount': NumberSchema(description: '预算金额'),
              'spent': NumberSchema(description: '已用金额'),
              'remaining': NumberSchema(description: '剩余金额'),
              'percentage': NumberSchema(description: '使用百分比'),
              'status': StringSchema(description: '状态'),
            },
          ),
        ),
        'alerts': ListSchema(
          description: '警告列表',
          items: ObjectSchema(
            properties: {
              'budget_name': StringSchema(description: '预算名称'),
              'alert_type': StringSchema(description: '警告类型'),
              'message': StringSchema(description: '警告消息'),
            },
          ),
        ),
        'period_start': StringSchema(description: '周期开始'),
        'period_end': StringSchema(description: '周期结束'),
      },
      required: ['success'],
    ),
    widgetBuilder: _buildBudgetStatusCardWidget,
  );
}

/// Budget creation receipt component
CatalogItem _buildBudgetReceipt() {
  return CatalogItem(
    name: 'BudgetReceipt',
    dataSchema: ObjectSchema(
      properties: {
        'success': BooleanSchema(description: '操作是否成功'),
        'budget_id': StringSchema(description: '预算ID'),
        'name': StringSchema(description: '预算名称'),
        'scope': StringSchema(description: '范围: TOTAL 或 CATEGORY'),
        'category_key': StringSchema(description: '分类键'),
        'amount': NumberSchema(description: '预算金额'),
        'period_start': StringSchema(description: '周期开始日期'),
        'period_end': StringSchema(description: '周期结束日期'),
        'rollover_enabled': BooleanSchema(description: '是否启用滚动预算'),
        'status': StringSchema(description: '状态'),
        'message': StringSchema(description: '消息'),
      },
      required: ['success'],
    ),
    widgetBuilder: _buildBudgetReceiptWidget,
  );
}

/// Budget analysis card component (Skills-specific)
CatalogItem _buildBudgetAnalysisCard() {
  return CatalogItem(
    name: 'BudgetAnalysisCard',
    dataSchema: ObjectSchema(
      properties: {
        'success': BooleanSchema(description: '操作是否成功'),
        'total_expense': NumberSchema(description: '总支出金额'),
        'period_days': IntegerSchema(description: '分析周期天数'),
        'transaction_count': IntegerSchema(description: '交易笔数'),
        'by_category': ObjectSchema(description: '分类统计', properties: {}),
        'trends': ObjectSchema(
          description: '趋势信息',
          properties: {
            'month_over_month': ObjectSchema(
              properties: {
                'change_amount': NumberSchema(description: '变化金额'),
                'change_percent': NumberSchema(description: '变化百分比'),
                'direction': StringSchema(description: '趋势方向: up/down/flat'),
              },
            ),
          },
        ),
        'top_spenders': ListSchema(
          description: '大额支出列表',
          items: ObjectSchema(
            properties: {
              'amount': NumberSchema(description: '金额'),
              'category': StringSchema(description: '分类'),
              'description': StringSchema(description: '描述'),
              'date': StringSchema(description: '日期'),
            },
          ),
        ),
        // Backend analyze_spending.py returns structured suggestion object array:
        // {type: 'high_percentage'|'monthly_increase'|'frequent_small',
        //  category_key?, percentage?, count?}
        // Note: genui 0.10 performs schema validation on component data. If declared as
        // StringSchema but actually an object, it triggers reportError feedback loop.
        'suggestions': ListSchema(
          description: '建议列表（结构化建议对象）',
          items: ObjectSchema(
            properties: {
              'type': StringSchema(
                description:
                    '建议类型: high_percentage/monthly_increase/frequent_small',
              ),
              'category_key': StringSchema(description: '相关分类键'),
              'percentage': NumberSchema(description: '相关百分比'),
              'count': IntegerSchema(description: '交易次数（frequent_small 类型）'),
            },
            required: ['type'],
          ),
        ),
        'ai_insight': StringSchema(description: 'AI 洞察文本'),
      },
      required: ['success'],
    ),
    widgetBuilder: _buildBudgetAnalysisCardWidget,
  );
}

/// Build budget status card widget
Widget _buildBudgetStatusCardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'BudgetStatusCard',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      return BudgetStatusCard(data: data);
    },
  );
}

/// Build budget creation receipt widget
Widget _buildBudgetReceiptWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'BudgetReceipt',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      return BudgetReceipt(data: data);
    },
  );
}

/// Build budget analysis card widget (Skills-specific)
Widget _buildBudgetAnalysisCardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'BudgetAnalysisCard',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      return BudgetAnalysisCard(data: data);
    },
  );
}
