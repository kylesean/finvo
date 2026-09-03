import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/models/tool_call_info.dart';
import 'package:finvo/features/chat/providers/conversation_expense_provider.dart';

void main() {
  group('scanMessageExpense', () {
    ChatMessage message({
      List<ToolCallInfo>? toolCalls,
      List<UIComponentInfo>? uiComponents,
    }) {
      return ChatMessage(
        id: 'm1',
        sender: MessageSender.ai,
        toolCalls: toolCalls ?? [],
        uiComponents: uiComponents ?? [],
      );
    }

    test('counts successful create_transaction tool call once', () {
      final msg = message(
        toolCalls: [
          const ToolCallInfo(
            id: 'tc1',
            name: 'create_transaction',
            args: {'transaction_type': 'expense', 'amount': 50},
            status: ToolExecutionStatus.success,
          ),
        ],
      );

      expect(scanMessageExpense(msg), Decimal.parse('50'));
    });

    test('does not count failed create_transaction tool call', () {
      final msg = message(
        toolCalls: [
          const ToolCallInfo(
            id: 'tc1',
            name: 'create_transaction',
            args: {'transaction_type': 'expense', 'amount': 50},
            status: ToolExecutionStatus.error,
          ),
        ],
      );

      expect(scanMessageExpense(msg), Decimal.zero);
    });

    test('ignores income tool calls', () {
      final msg = message(
        toolCalls: [
          const ToolCallInfo(
            id: 'tc1',
            name: 'create_transaction',
            args: {'transaction_type': 'income', 'amount': 100},
            status: ToolExecutionStatus.success,
          ),
        ],
      );

      expect(scanMessageExpense(msg), Decimal.zero);
    });

    test('counts record_transactions expense items in batch', () {
      final msg = message(
        toolCalls: [
          const ToolCallInfo(
            id: 'tc1',
            name: 'record_transactions',
            args: {
              'transactions': [
                {'type': 'expense', 'amount': 20},
                {'type': 'expense', 'amount': 30},
                {'type': 'income', 'amount': 999},
              ],
            },
            status: ToolExecutionStatus.success,
          ),
        ],
      );

      expect(scanMessageExpense(msg), Decimal.parse('50'));
    });

    test(
      'does not double-count component linked to an already counted tool call',
      () {
        final msg = message(
          toolCalls: [
            const ToolCallInfo(
              id: 'tc1',
              name: 'create_transaction',
              args: {'transaction_type': 'expense', 'amount': 50},
              status: ToolExecutionStatus.success,
            ),
          ],
          uiComponents: [
            const UIComponentInfo(
              surfaceId: 's1',
              componentType: 'transaction_success',
              data: {'amount': 50, 'type': 'expense'},
              toolCallId: 'tc1',
              toolName: 'create_transaction',
            ),
          ],
        );

        expect(scanMessageExpense(msg), Decimal.parse('50'));
      },
    );

    test(
      'counts component when no linked tool call exists (historical fallback)',
      () {
        final msg = message(
          uiComponents: [
            const UIComponentInfo(
              surfaceId: 's1',
              componentType: 'transaction_success',
              data: {'amount': 50, 'type': 'expense'},
              toolName: 'create_transaction',
            ),
          ],
        );

        expect(scanMessageExpense(msg), Decimal.parse('50'));
      },
    );

    test('counts create_space_transaction expense', () {
      final msg = message(
        toolCalls: [
          const ToolCallInfo(
            id: 'tc1',
            name: 'create_space_transaction',
            args: {'transaction_type': 'expense', 'amount': 33},
            status: ToolExecutionStatus.success,
          ),
        ],
      );

      expect(scanMessageExpense(msg), Decimal.parse('33'));
    });

    test('empty message yields zero', () {
      expect(scanMessageExpense(message()), Decimal.zero);
    });
  });

  group('record_transactions summary buckets', () {
    ChatMessage receipt(Map<String, dynamic> summary) {
      return ChatMessage(
        id: 'm1',
        sender: MessageSender.ai,
        uiComponents: [
          UIComponentInfo(
            surfaceId: 's1',
            componentType: 'TransactionGroupReceipt',
            data: {'summary': summary},
            toolName: 'record_transactions',
          ),
        ],
      );
    }

    test('single-currency buckets sum exactly', () {
      final msg = receipt({
        'expense_count': 2,
        'income_count': 0,
        'by_currency': {
          'CNY': {'expense': '30.10', 'income': '0.00'},
        },
        'mixed_currencies': false,
      });

      expect(scanMessageExpense(msg), Decimal.parse('30.10'));
    });

    test('legacy float totals are ignored', () {
      final msg = receipt({
        'expense_total': 9999.0,
        'income_total': 1.0,
        'by_currency': {
          'CNY': {'expense': '30.10', 'income': '0.00'},
        },
        'mixed_currencies': false,
      });

      expect(scanMessageExpense(msg), Decimal.parse('30.10'));
    });

    test('missing buckets yield zero', () {
      expect(scanMessageExpense(receipt({})), Decimal.zero);
    });

    test('malformed buckets are skipped', () {
      final msg = receipt({
        'by_currency': {
          'CNY': 'garbage',
          'USD': {'expense': 'n/a', 'income': '5.00'},
        },
        'mixed_currencies': true,
      });

      expect(scanMessageExpense(msg), Decimal.zero);
    });
  });
}
