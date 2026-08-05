import 'package:flutter_test/flutter_test.dart';
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

      expect(scanMessageExpense(msg), 50.0);
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

      expect(scanMessageExpense(msg), 0.0);
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

      expect(scanMessageExpense(msg), 0.0);
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

      expect(scanMessageExpense(msg), 50.0);
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

        expect(scanMessageExpense(msg), 50.0);
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

        expect(scanMessageExpense(msg), 50.0);
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

      expect(scanMessageExpense(msg), 33.0);
    });

    test('empty message yields zero', () {
      expect(scanMessageExpense(message()), 0.0);
    });
  });
}
