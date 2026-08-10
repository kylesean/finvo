// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:finvo/features/chat/services/genui_logger.dart';
import 'package:finvo/features/chat/genui/catalog_helpers.dart';
import 'package:finvo/features/chat/genui/templates/templates.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Transaction / transfer related catalog items.
List<CatalogItem> buildTransactionItems() {
  return [
    _buildTransactionCard(),
    _buildTransferReceipt(),
    _buildExpenseTable(),
    _buildChartCard(),
    _buildSummaryCard(),
    _buildTransferWizard(),
    _buildTransactionGroupReceipt(),
    _buildTransactionList(),
  ];
}

/// Transaction card component
///
/// Used to display transaction receipt information, including status, amount, details, etc.
CatalogItem _buildTransactionCard() {
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
CatalogItem _buildTransferReceipt() {
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
CatalogItem _buildExpenseTable() {
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
          required: ['currentPage', 'totalPages', 'totalItems', 'itemsPerPage'],
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
CatalogItem _buildChartCard() {
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
                  'data': ListSchema(description: '数据值', items: NumberSchema()),
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
CatalogItem _buildSummaryCard() {
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
CatalogItem _buildTransferWizard() {
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

/// Batch transaction receipt component
CatalogItem _buildTransactionGroupReceipt() {
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

/// Transaction list component
CatalogItem _buildTransactionList() {
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

/// Build transaction card widget
Widget _buildTransactionCardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'TransactionReceipt',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;

      // Validate required fields (only check truly required fields)
      // transaction_id and amount are required
      // raw_input/description can be empty, will use default values
      final hasTransactionId =
          data.containsKey('transaction_id') && data['transaction_id'] != null;
      final hasAmount = data.containsKey('amount') && data['amount'] != null;

      if (!hasTransactionId || !hasAmount) {
        GenUiLogger.logError(
          message: 'TransactionReceipt missing required fields',
          schema: data,
        );
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }

      // Use standard TransactionCard (no reactive binding needed for one-shot receipts)
      return TransactionCard(data: data);
    },
  );
}

/// Build transfer receipt widget
Widget _buildTransferReceiptWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'TransferReceipt',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;

      // Validate required fields
      final hasTransactionId =
          data.containsKey('transaction_id') && data['transaction_id'] != null;
      final hasAmount = data.containsKey('amount') && data['amount'] != null;
      final hasTransferInfo =
          data.containsKey('transfer_info') && data['transfer_info'] != null;

      if (!hasTransactionId || !hasAmount || !hasTransferInfo) {
        GenUiLogger.logError(
          message: 'TransferReceipt missing required fields',
          schema: data,
        );
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }

      return TransferReceipt(data: data);
    },
  );
}

/// Build data table widget
Widget _buildExpenseTableWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'DataTable',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;

      // Validate required fields
      if (!validateRequiredFields(data, ['title', 'headers', 'rows'])) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }

      return ExpenseTable(data: data);
    },
  );
}

/// Build chart card widget
Widget _buildChartCardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'ChartCard',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;

      // Validate required fields
      if (!validateRequiredFields(data, ['title', 'chartType', 'chartData'])) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }

      return ChartCard(data: data);
    },
  );
}

/// Build summary card widget
Widget _buildSummaryCardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'SummaryCard',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;

      // Validate required fields
      if (!validateRequiredFields(data, ['title', 'summary', 'items'])) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }

      return SummaryCard(data: data);
    },
  );
}

/// Build transfer wizard widget
Widget _buildTransferWizardWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'TransferWizard',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;

      // Validate required fields
      if (!validateRequiredFields(data, ['sourceAccounts', 'targetAccounts'])) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.fetchFailed,
        );
      }

      // Inject the real surface ID (mirrors catalog_space_artifact_items.dart).
      // The backend strips '_'-prefixed keys from the wire payload, so without
      // this every live TransferWizard falls back to surfaceId 'unknown'.
      // TransferWizard uses surfaceId as its confirmed-state cache key, so a
      // shared 'unknown' key makes the first confirmed transfer poison every
      // later wizard in the same conversation (rendered as already-confirmed
      // with the previous transfer's data), blocking repeated transfers.
      final widgetData = Map<String, dynamic>.from(data);
      widgetData['_surfaceId'] = context.surfaceId;

      return TransferWizard(
        data: widgetData,
        dispatchEvent: context.dispatchEvent,
      );
    },
  );
}

/// Build batch transaction receipt widget
Widget _buildTransactionGroupReceiptWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'TransactionGroupReceipt',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;
      final transactions = data['transactions'] as List?;
      if (!success || transactions == null || transactions.isEmpty) {
        return buildErrorWidget(
          context.buildContext,
          t.chat.genui.error.dataIncomplete,
        );
      }
      return TransactionGroupReceipt(
        data: data,
        dispatchEvent: context.dispatchEvent,
      );
    },
  );
}

/// Build transaction list widget
Widget _buildTransactionListWidget(CatalogItemContext context) {
  return wrapBuilder(
    componentName: 'TransactionList',
    context: context,
    build: (CatalogItemContext context) {
      final data = context.data as Map<String, dynamic>;
      return TransactionList(data: data);
    },
  );
}
