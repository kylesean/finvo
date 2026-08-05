// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import '../services/genui_logger.dart';
import 'templates/templates.dart';

/// Application-specific component catalog
///
/// This class defines the custom GenUI components available in the chat app.
/// Includes transaction cards, data tables, chart cards, and summary cards.
class AppCatalog {
  /// Build the complete component catalog
  ///
  /// Starts with core components, then adds application-specific custom components.
  static Catalog build() {
    // Start with core components
    final catalog = BasicCatalogItems.asCatalog();

    // Add custom components
    return catalog.copyWith(
      newItems: [
        _buildTransactionCard(),
        _buildTransferReceipt(),
        _buildExpenseTable(),
        _buildChartCard(),
        _buildSummaryCard(),
        _buildTransferWizard(),
        _buildBudgetStatusCard(),
        _buildBudgetReceipt(),
        _buildBudgetAnalysisCard(),
        _buildTransactionGroupReceipt(),
        _buildTransactionList(),
        _buildCashFlowCard(),
        _buildHealthScoreCard(),
        _buildCashFlowForecastChart(),
        _buildExpenseSummaryCard(),
        _buildSpaceSelectorCard(),
        _buildSpaceAssociationReceipt(),
        _buildArtifactLink(),
        _buildArtifactLinkCard(),
      ],
    );
  }

  /// Transaction card component
  ///
  /// Used to display transaction receipt information, including status, amount, details, etc.
  static CatalogItem _buildTransactionCard() {
    return CatalogItem(
      name: 'TransactionReceipt',
      dataSchema: ObjectSchema(
        properties: {
          // Fields returned by backend (create_transaction / enricher returns UUID string and type string)
          'success': BooleanSchema(description: '操作是否成功'),
          'transaction_id': StringSchema(description: '交易唯一标识符（UUID 字符串）'),
          'raw_input': StringSchema(description: '交易描述'),
          'amount': NumberSchema(description: '交易金额'),
          'type': StringSchema(description: '交易类型（EXPENSE/INCOME/TRANSFER）'),
          'transaction_at': StringSchema(description: '交易时间（ISO 8601格式）'),
          'message': StringSchema(description: '操作结果消息'),

          // Optional fields (backward compatibility with old format)
          'transactionId': StringSchema(description: '交易唯一标识符（旧格式）'),
          'status': StringSchema(description: '交易状态'),
          'title': StringSchema(description: '交易标题或描述（旧格式）'),
          'currency': StringSchema(description: '货币类型代码（如 CNY, USD）'),
          'amountColor': StringSchema(description: '金额显示颜色（如 red, green）'),
          'category': StringSchema(description: '交易类别'),
          'timestamp': StringSchema(description: '交易时间戳（旧格式）'),
          'details': ListSchema(
            description: '交易详细信息列表',
            items: ObjectSchema(
              properties: {
                'label': StringSchema(description: '详情标签'),
                'value': StringSchema(description: '详情值'),
              },
              required: ['label', 'value'],
            ),
          ),
          'tags': ListSchema(description: '交易标签列表', items: StringSchema()),
        },
        required: [
          // Only require fields actually returned by backend
          // raw_input and type may be empty, not treated as required fields
          'transaction_id',
          'amount',
        ],
      ),
      widgetBuilder: _buildTransactionCardWidget,
    );
  }

  /// Transfer receipt component
  ///
  /// Dedicated to displaying transfer transaction results, separated from regular transaction cards.
  /// Shows a dual-account (from → to) layout.
  static CatalogItem _buildTransferReceipt() {
    return CatalogItem(
      name: 'TransferReceipt',
      dataSchema: ObjectSchema(
        properties: {
          'success': BooleanSchema(description: '操作是否成功'),
          'transaction_id': StringSchema(description: '交易唯一标识符'),
          'amount': NumberSchema(description: '转账金额'),
          'currency': StringSchema(description: '货币代码'),
          'type': StringSchema(description: '交易类型（应为 TRANSFER）'),
          'transaction_at': StringSchema(description: '交易时间（ISO 8601格式）'),
          'category_key': StringSchema(description: '交易分类'),
          'tags': ListSchema(description: '交易标签', items: StringSchema()),
          'transfer_info': ObjectSchema(
            description: '转账详情',
            properties: {
              'source_account': ObjectSchema(
                properties: {
                  'id': StringSchema(description: '转出账户ID'),
                  'name': StringSchema(description: '转出账户名称'),
                  'type': StringSchema(description: '账户类型'),
                  'new_balance': StringSchema(description: '转账后余额'),
                },
                required: ['id', 'name'],
              ),
              'target_account': ObjectSchema(
                properties: {
                  'id': StringSchema(description: '转入账户ID'),
                  'name': StringSchema(description: '转入账户名称'),
                  'type': StringSchema(description: '账户类型'),
                  'new_balance': StringSchema(description: '转账后余额'),
                },
                required: ['id', 'name'],
              ),
            },
            required: ['source_account', 'target_account'],
          ),
        },
        required: ['transaction_id', 'amount', 'transfer_info'],
      ),
      widgetBuilder: _buildTransferReceiptWidget,
    );
  }

  /// Data table component
  ///
  /// Used to display structured tabular data with pagination support.
  static CatalogItem _buildExpenseTable() {
    return CatalogItem(
      name: 'DataTable',
      dataSchema: ObjectSchema(
        properties: {
          'title': StringSchema(description: '表格标题'),
          'headers': ListSchema(description: '表头列表', items: StringSchema()),
          'rows': ListSchema(
            description: '表格行数据',
            items: ListSchema(items: StringSchema()),
          ),
          'styling': ObjectSchema(
            description: '表格样式配置',
            properties: {
              'headerColor': StringSchema(description: '表头背景色'),
              'rowColor': StringSchema(description: '行背景色'),
              'borderColor': StringSchema(description: '边框颜色'),
            },
          ),
          'pagination': ObjectSchema(
            description: '分页信息',
            properties: {
              'currentPage': IntegerSchema(description: '当前页码'),
              'totalPages': IntegerSchema(description: '总页数'),
              'totalItems': IntegerSchema(description: '总条目数'),
              'itemsPerPage': IntegerSchema(description: '每页条目数'),
              'hasNextPage': BooleanSchema(description: '是否有下一页'),
              'hasPreviousPage': BooleanSchema(description: '是否有上一页'),
            },
            required: [
              'currentPage',
              'totalPages',
              'totalItems',
              'itemsPerPage',
            ],
          ),
        },
        required: ['title', 'headers', 'rows'],
      ),
      widgetBuilder: _buildExpenseTableWidget,
    );
  }

  /// Chart card component
  ///
  /// Used to display various types of charts (pie, bar, line, etc.).
  static CatalogItem _buildChartCard() {
    return CatalogItem(
      name: 'ChartCard',
      dataSchema: ObjectSchema(
        properties: {
          'title': StringSchema(description: '图表标题'),
          'chartType': StringSchema(
            description: '图表类型',
            enumValues: ['pie', 'bar', 'line', 'radar', 'area'],
          ),
          'chartData': ObjectSchema(
            description: '图表数据',
            properties: {
              'labels': ListSchema(description: '数据标签', items: StringSchema()),
              'datasets': ListSchema(
                description: '数据集',
                items: ObjectSchema(
                  properties: {
                    'label': StringSchema(description: '数据集标签'),
                    'data': ListSchema(
                      description: '数据值',
                      items: NumberSchema(),
                    ),
                    'backgroundColor': StringSchema(description: '背景色'),
                    'borderColor': StringSchema(description: '边框色'),
                  },
                  required: ['label', 'data'],
                ),
              ),
            },
            required: ['labels', 'datasets'],
          ),
          'chartOptions': ObjectSchema(
            description: '图表配置选项',
            properties: {
              'showLegend': BooleanSchema(description: '是否显示图例'),
              'showGrid': BooleanSchema(description: '是否显示网格'),
              'animationDuration': IntegerSchema(description: '动画时长（毫秒）'),
            },
          ),
        },
        required: ['title', 'chartType', 'chartData'],
      ),
      widgetBuilder: _buildChartCardWidget,
    );
  }

  /// Summary card component
  ///
  /// Used to display summary information and key metrics.
  static CatalogItem _buildSummaryCard() {
    return CatalogItem(
      name: 'SummaryCard',
      dataSchema: ObjectSchema(
        properties: {
          'title': StringSchema(description: '摘要标题'),
          'summary': StringSchema(description: '摘要文本内容'),
          'items': ListSchema(
            description: '摘要项目列表',
            items: ObjectSchema(
              properties: {
                'label': StringSchema(description: '项目标签'),
                'value': StringSchema(description: '项目值'),
                'color': StringSchema(description: '显示颜色'),
                'icon': StringSchema(description: '图标名称'),
              },
              required: ['label', 'value'],
            ),
          ),
          'styling': ObjectSchema(
            description: '样式配置',
            properties: {
              'backgroundColor': StringSchema(description: '背景色'),
              'textColor': StringSchema(description: '文本颜色'),
              'borderRadius': NumberSchema(description: '圆角半径'),
            },
          ),
        },
        required: ['title', 'summary', 'items'],
      ),
      widgetBuilder: _buildSummaryCardWidget,
    );
  }

  /// Transfer wizard component
  static CatalogItem _buildTransferWizard() {
    return CatalogItem(
      name: 'TransferWizard',
      dataSchema: ObjectSchema(
        properties: {
          'amount': NumberSchema(description: '转账金额'),
          'currency': StringSchema(description: '货币代码'),
          'sourceAccounts': ListSchema(
            description: '可选转出账户列表',
            items: ObjectSchema(
              properties: {
                'id': StringSchema(description: '账户ID'),
                'name': StringSchema(description: '账户名称'),
                'type': StringSchema(description: '账户类型'),
                'balance': NumberSchema(description: '账户余额'),
                'currency': StringSchema(description: '货币代码'),
                'subtitle': StringSchema(description: '账户副标题'),
              },
              required: ['id', 'name', 'type'],
            ),
          ),
          'targetAccounts': ListSchema(
            description: '可选转入账户列表',
            items: ObjectSchema(
              properties: {
                'id': StringSchema(description: '账户ID'),
                'name': StringSchema(description: '账户名称'),
                'type': StringSchema(description: '账户类型'),
                'balance': NumberSchema(description: '账户余额'),
                'currency': StringSchema(description: '货币代码'),
                'subtitle': StringSchema(description: '账户副标题'),
              },
              required: ['id', 'name', 'type'],
            ),
          ),
          'preselectedSourceId': StringSchema(description: '预选的转出账户ID'),
          'preselectedTargetId': StringSchema(description: '预选的转入账户ID'),
        },
        required: ['sourceAccounts', 'targetAccounts'],
      ),
      widgetBuilder: _buildTransferWizardWidget,
    );
  }

  /// Build transaction card widget
  static Widget _buildTransactionCardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'TransactionReceipt',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;

        // Validate required fields (only check truly required fields)
        // transaction_id and amount are required
        // raw_input/description can be empty, will use default values
        final hasTransactionId =
            data.containsKey('transaction_id') &&
            data['transaction_id'] != null;
        final hasAmount = data.containsKey('amount') && data['amount'] != null;

        if (!hasTransactionId || !hasAmount) {
          GenUiLogger.logError(
            message: 'TransactionReceipt missing required fields',
            schema: data,
          );
          return _buildErrorWidget(
            context.buildContext,
            'Failed to load transaction record, please retry',
          );
        }

        // Use standard TransactionCard (no reactive binding needed for one-shot receipts)
        return TransactionCard(data: data);
      },
    );
  }

  /// Build transfer receipt widget
  static Widget _buildTransferReceiptWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'TransferReceipt',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;

        // Validate required fields
        final hasTransactionId =
            data.containsKey('transaction_id') &&
            data['transaction_id'] != null;
        final hasAmount = data.containsKey('amount') && data['amount'] != null;
        final hasTransferInfo =
            data.containsKey('transfer_info') && data['transfer_info'] != null;

        if (!hasTransactionId || !hasAmount || !hasTransferInfo) {
          GenUiLogger.logError(
            message: 'TransferReceipt missing required fields',
            schema: data,
          );
          return _buildErrorWidget(
            context.buildContext,
            'Failed to load transfer record, please retry',
          );
        }

        return TransferReceipt(data: data);
      },
    );
  }

  /// Build data table widget
  static Widget _buildExpenseTableWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'DataTable',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;

        // Validate required fields
        if (!_validateRequiredFields(data, ['title', 'headers', 'rows'])) {
          return _buildErrorWidget(
            context.buildContext,
            'Missing required fields',
          );
        }

        return ExpenseTable(data: data);
      },
    );
  }

  /// Build chart card widget
  static Widget _buildChartCardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'ChartCard',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;

        // Validate required fields
        if (!_validateRequiredFields(data, [
          'title',
          'chartType',
          'chartData',
        ])) {
          return _buildErrorWidget(
            context.buildContext,
            'Missing required fields',
          );
        }

        return ChartCard(data: data);
      },
    );
  }

  /// Build summary card widget
  static Widget _buildSummaryCardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'SummaryCard',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;

        // Validate required fields
        if (!_validateRequiredFields(data, ['title', 'summary', 'items'])) {
          return _buildErrorWidget(
            context.buildContext,
            'Missing required fields',
          );
        }

        return SummaryCard(data: data);
      },
    );
  }

  /// Build transfer wizard widget
  static Widget _buildTransferWizardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'TransferWizard',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;

        // Validate required fields
        if (!_validateRequiredFields(data, [
          'sourceAccounts',
          'targetAccounts',
        ])) {
          return _buildErrorWidget(
            context.buildContext,
            'Failed to load transfer wizard, please retry',
          );
        }
        return TransferWizard(data: data, dispatchEvent: context.dispatchEvent);
      },
    );
  }

  /// Validate required fields
  static bool _validateRequiredFields(
    Map<String, dynamic> data,
    List<String> requiredFields,
  ) {
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        return false;
      }
    }
    return true;
  }

  /// Wrap a builder with invocation logging and error handling
  static Widget _wrapBuilder({
    required String componentName,
    required CatalogItemContext context,
    required Widget Function(CatalogItemContext context) build,
  }) {
    final startTime = DateTime.now();
    try {
      final widget = build(context);
      GenUiLogger.logBuilderInvocation(
        componentName: componentName,
        success: true,
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
      );
      return widget;
    } catch (e, stackTrace) {
      GenUiLogger.logBuilderInvocation(
        componentName: componentName,
        success: false,
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
      );
      GenUiLogger.logError(
        message: 'Builder failed for $componentName',
        error: e,
        stackTrace: stackTrace,
      );
      return _buildErrorWidget(context.buildContext, 'Rendering failed: $e');
    }
  }

  /// Build error widget
  static Widget _buildErrorWidget(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '组件渲染遇到问题',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: AppFontConfig.headingBold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Budget-related components
  // ═══════════════════════════════════════════════════════════════════════════

  /// Budget status card component
  static CatalogItem _buildBudgetStatusCard() {
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

  /// Transaction list component
  static CatalogItem _buildTransactionList() {
    return CatalogItem(
      name: 'TransactionList',
      dataSchema: ObjectSchema(
        properties: {
          'items': ListSchema(
            description: '交易记录列表',
            items: ObjectSchema(
              properties: {
                'id': StringSchema(description: '交易ID'),
                'amount': NumberSchema(description: '金额'),
                'currency': StringSchema(description: '货币'),
                'description': StringSchema(description: '描述'),
                'category': StringSchema(description: '分类'),
                'type': StringSchema(description: '类型'),
                'transaction_time': StringSchema(description: '时间'),
                'tags': ListSchema(items: StringSchema()),
              },
            ),
          ),
          'total': IntegerSchema(description: '总条数'),
          'page': IntegerSchema(description: '当前页'),
          'hasMore': BooleanSchema(description: '是否有更多'),
        },
        required: ['items'],
      ),
      widgetBuilder: _buildTransactionListWidget,
    );
  }

  /// Budget creation receipt component
  static CatalogItem _buildBudgetReceipt() {
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
  static CatalogItem _buildBudgetAnalysisCard() {
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

  /// Batch transaction receipt component
  static CatalogItem _buildTransactionGroupReceipt() {
    return CatalogItem(
      name: 'TransactionGroupReceipt',
      dataSchema: ObjectSchema(
        properties: {
          'success': BooleanSchema(description: '操作是否成功'),
          'count': IntegerSchema(description: '交易笔数'),
          'transactions': ListSchema(
            description: '交易列表',
            items: ObjectSchema(
              properties: {
                'id': StringSchema(description: '交易ID'),
                'amount': StringSchema(description: '交易金额'),
                'tags': ListSchema(items: StringSchema()),
                'category_key': StringSchema(description: '分类键'),
              },
              required: ['id', 'amount'],
            ),
          ),
          'account_id': StringSchema(description: '已关联的账户ID'),
        },
        required: ['success', 'transactions'],
      ),
      widgetBuilder: _buildTransactionGroupReceiptWidget,
    );
  }

  /// Cash flow analysis card component
  ///
  /// Data source: reviewing-finances skill's analyze_cashflow.py.
  /// Backend returns camelCase field names (from StatisticsService's CashFlowResponse),
  /// where totalIncome/totalExpense/netCashFlow are pre-formatted strings.
  /// Health score data (healthScore/healthGrade/healthDimensions/suggestions)
  /// is also embedded in the same payload. Widget reads camelCase, schema must match,
  /// otherwise genui 0.10's schema validation will trigger error feedback due to missing required fields.
  static CatalogItem _buildCashFlowCard() {
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
          'suggestions': ListSchema(
            description: '改进建议列表',
            items: StringSchema(),
          ),
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
  static CatalogItem _buildHealthScoreCard() {
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
          'suggestions': ListSchema(
            description: '改进建议列表',
            items: StringSchema(),
          ),
          'periodStart': StringSchema(description: '统计周期开始时间'),
          'periodEnd': StringSchema(description: '统计周期结束时间'),
        },
        required: ['totalScore', 'grade'],
      ),
      widgetBuilder: _buildHealthScoreCardWidget,
    );
  }

  /// Cash flow forecast chart component
  static CatalogItem _buildCashFlowForecastChart() {
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

  /// Build transaction list widget
  static Widget _buildTransactionListWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'TransactionList',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        return TransactionList(data: data);
      },
    );
  }

  /// Build budget status card widget
  static Widget _buildBudgetStatusCardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'BudgetStatusCard',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        return BudgetStatusCard(data: data);
      },
    );
  }

  /// Build budget creation receipt widget
  static Widget _buildBudgetReceiptWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'BudgetReceipt',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        return BudgetReceipt(data: data);
      },
    );
  }

  /// Build budget analysis card widget (Skills-specific)
  static Widget _buildBudgetAnalysisCardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'BudgetAnalysisCard',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        return BudgetAnalysisCard(data: data);
      },
    );
  }

  /// Build batch transaction receipt widget
  static Widget _buildTransactionGroupReceiptWidget(
    CatalogItemContext context,
  ) {
    return _wrapBuilder(
      componentName: 'TransactionGroupReceipt',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;
        final transactions = data['transactions'] as List?;
        if (!success || transactions == null || transactions.isEmpty) {
          return _buildErrorWidget(context.buildContext, '批量交易数据不完整');
        }
        return TransactionGroupReceipt(
          data: data,
          dispatchEvent: context.dispatchEvent,
        );
      },
    );
  }

  /// Build cash flow card widget
  static Widget _buildCashFlowCardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'CashFlowCard',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        if (!_validateRequiredFields(data, ['netCashFlow', 'savingsRate'])) {
          return _buildErrorWidget(
            context.buildContext,
            'Incomplete cash flow data',
          );
        }
        return CashFlowAnalysisCard(data: data);
      },
    );
  }

  /// Build financial health score card widget
  static Widget _buildHealthScoreCardWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'HealthScoreCard',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        if (!_validateRequiredFields(data, ['totalScore', 'grade'])) {
          return _buildErrorWidget(
            context.buildContext,
            'Incomplete financial health score data',
          );
        }
        return HealthScoreAnalysisCard(data: data);
      },
    );
  }

  /// Build cash flow forecast chart widget
  static Widget _buildCashFlowForecastChartWidget(CatalogItemContext context) {
    return _wrapBuilder(
      componentName: 'CashFlowForecastChart',
      context: context,
      build: (CatalogItemContext context) {
        final data = context.data as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;
        if (!success) {
          final errorMsg = data['error'] as String? ?? 'Forecast failed';
          return _buildErrorWidget(context.buildContext, errorMsg);
        }
        return CashFlowForecastChart(data: data);
      },
    );
  }

  /// Expense summary card component
  static CatalogItem _buildExpenseSummaryCard() {
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

  static Widget _buildExpenseSummaryCardWidget(CatalogItemContext context) {
    try {
      final data = context.data as Map<String, dynamic>;
      return ExpenseSummaryCard(data: data);
    } catch (e) {
      return _buildErrorWidget(
        context.buildContext,
        'Failed to load expense summary',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared space related components
  // ═══════════════════════════════════════════════════════════════════════════

  /// Space selector card component
  static CatalogItem _buildSpaceSelectorCard() {
    return CatalogItem(
      name: 'SpaceSelectorCard',
      dataSchema: ObjectSchema(
        properties: {
          'matched_spaces': ListSchema(
            description: '匹配到的共享空间列表',
            items: ObjectSchema(
              properties: {
                'id': IntegerSchema(description: '空间ID'),
                'name': StringSchema(description: '空间名称'),
                'description': StringSchema(description: '空间描述'),
                'role': StringSchema(description: '用户角色'),
              },
              required: ['id', 'name'],
            ),
          ),
          'all_spaces': ListSchema(
            description: '所有可用共享空间列表',
            items: ObjectSchema(
              properties: {
                'id': IntegerSchema(description: '空间ID'),
                'name': StringSchema(description: '空间名称'),
                'description': StringSchema(description: '空间描述'),
                'role': StringSchema(description: '用户角色'),
              },
              required: ['id', 'name'],
            ),
          ),
          'pending_transaction_ids': ListSchema(
            description: '待关联的交易ID列表',
            items: StringSchema(),
          ),
          'match_keyword': StringSchema(description: '匹配关键词'),
          'message': StringSchema(description: '提示消息'),
        },
        required: ['pending_transaction_ids'],
      ),
      widgetBuilder: _buildSpaceSelectorCardWidget,
    );
  }

  static Widget _buildSpaceSelectorCardWidget(CatalogItemContext context) {
    try {
      final data = context.data as Map<String, dynamic>;
      final widgetData = Map<String, dynamic>.from(data);
      widgetData['_surfaceId'] = context.surfaceId;

      return SpaceSelectorCard(
        data: widgetData,
        dispatchEvent: context.dispatchEvent,
      );
    } catch (e) {
      return _buildErrorWidget(
        context.buildContext,
        'Failed to load space selector: $e',
      );
    }
  }

  /// Space association confirmation component
  static CatalogItem _buildSpaceAssociationReceipt() {
    return CatalogItem(
      name: 'SpaceAssociationReceipt',
      dataSchema: ObjectSchema(
        properties: {
          'space': ObjectSchema(
            description: '关联的空间信息',
            properties: {
              // Backend associate_transactions_to_space returns space_id as UUID string
              'id': StringSchema(description: '空间ID（UUID 字符串）'),
              'name': StringSchema(description: '空间名称'),
            },
            required: ['id', 'name'],
          ),
          'association': ObjectSchema(
            description: '关联统计',
            properties: {
              'total_count': IntegerSchema(description: '总数'),
              'success_count': IntegerSchema(description: '成功数'),
              'failed_count': IntegerSchema(description: '失败数'),
            },
          ),
          'message': StringSchema(description: '结果消息'),
        },
        required: ['space', 'association'],
      ),
      widgetBuilder: _buildSpaceAssociationReceiptWidget,
    );
  }

  static Widget _buildSpaceAssociationReceiptWidget(
    CatalogItemContext context,
  ) {
    try {
      final data = context.data as Map<String, dynamic>;
      final widgetData = Map<String, dynamic>.from(data);
      widgetData['_surfaceId'] = context.surfaceId;

      return SpaceAssociationReceipt(
        data: widgetData,
        dispatchEvent: context.dispatchEvent,
      );
    } catch (e) {
      return _buildErrorWidget(
        context.buildContext,
        'Failed to load association confirmation: $e',
      );
    }
  }

  static CatalogItem _buildArtifactLink() {
    return CatalogItem(
      name: 'artifact_link',
      dataSchema: ObjectSchema(
        properties: {
          'url': StringSchema(description: 'File URL'),
          'path': StringSchema(description: 'File path'),
          'artifactName': StringSchema(description: 'Artifact name'),
          'artifactUrl': StringSchema(description: 'Artifact URL'),
          'message': StringSchema(description: 'Message'),
        },
      ),
      widgetBuilder: _buildArtifactLinkWidget,
    );
  }

  static CatalogItem _buildArtifactLinkCard() {
    return CatalogItem(
      name: 'ArtifactLinkCard',
      dataSchema: ObjectSchema(
        properties: {
          'url': StringSchema(description: 'File URL'),
          'path': StringSchema(description: 'File path'),
          'artifactName': StringSchema(description: 'Artifact name'),
          'artifactUrl': StringSchema(description: 'Artifact URL'),
          'message': StringSchema(description: 'Message'),
        },
      ),
      widgetBuilder: _buildArtifactLinkWidget,
    );
  }

  static Widget _buildArtifactLinkWidget(CatalogItemContext context) {
    try {
      final data = context.data as Map<String, dynamic>;
      final artifactName =
          data['artifactName'] as String? ??
          data['path'] as String? ??
          'Artifact File';
      final url =
          data['artifactUrl'] as String? ?? data['url'] as String? ?? '';

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context.buildContext).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(
              context.buildContext,
            ).dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined, size: 24.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    artifactName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (url.isNotEmpty)
                    Text(
                      url,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context.buildContext).hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return _buildErrorWidget(
        context.buildContext,
        'Failed to load artifact link: $e',
      );
    }
  }
}
