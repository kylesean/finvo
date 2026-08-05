import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../models/tool_call_info.dart';
import '../providers/chat_history_provider.dart';
import 'package:finvo/i18n/strings.g.dart';

part 'conversation_expense_provider.g.dart';

/// Current conversation expense state
class ConversationExpenseState {
  /// Current conversation ID
  final String? conversationId;

  const ConversationExpenseState({this.conversationId});

  ConversationExpenseState copyWith({String? conversationId}) {
    return ConversationExpenseState(
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

/// Current conversation expense Notifier
///
/// Tracks the active conversation; expense totals are derived from messages.
@riverpod
class ConversationExpenseNotifier extends _$ConversationExpenseNotifier {
  @override
  ConversationExpenseState build() {
    return const ConversationExpenseState();
  }

  /// Switch conversation
  void switchConversation(String? newConversationId) {
    if (state.conversationId != newConversationId) {
      state = ConversationExpenseState(conversationId: newConversationId);
    }
  }
}

/// Current conversation expense statistics Provider
///
/// Derived purely from historical messages (uiComponents + toolCalls).
/// A single transaction is counted at most once per message via toolCallId
/// deduplication between the two data sources.
@riverpod
double conversationTotalExpense(Ref ref) {
  // Only subscribe to messages changes, avoid recalculation triggered by other state changes
  final messages = ref.watch(
    chatHistoryProvider.select((state) => state.messages),
  );

  double totalExpense = 0.0;

  for (final message in messages) {
    totalExpense += scanMessageExpense(message);
  }

  return totalExpense;
}

/// Scan a single message for expense amounts.
///
/// Extracts expenses from UI components and tool calls, deduplicating by
/// toolCallId so the same transaction rendered as both a component and a
/// tool call is counted once. Only successful tool calls are counted.
double scanMessageExpense(ChatMessage message) {
  double total = 0.0;
  final countedToolCallIds = <String>{};

  // Tool calls are the canonical source of executed transactions.
  for (final messageToolCall in message.toolCalls) {
    if (messageToolCall.status == ToolExecutionStatus.error ||
        messageToolCall.status == ToolExecutionStatus.cancelled) {
      continue;
    }

    final expense = _expenseFromToolCall(messageToolCall);
    if (expense > 0) {
      total += expense;
      countedToolCallIds.add(messageToolCall.id);
    }
  }

  // UI components: only count when not already counted via a linked tool call.
  for (final component in message.uiComponents) {
    final toolCallId = component.toolCallId;
    if (toolCallId != null && countedToolCallIds.contains(toolCallId)) {
      continue;
    }

    final expense = _expenseFromUiComponent(component);
    if (expense > 0) {
      total += expense;
    }
  }

  return total;
}

/// Extract expense amount from a single UI component, or 0 if not expense.
double _expenseFromUiComponent(UIComponentInfo component) {
  if (component.toolName == 'create_transaction') {
    final data = component.userSelection ?? component.data;
    if (data.isEmpty) return 0.0;

    final type =
        data['transaction_type'] as String? ??
        data['type'] as String? ??
        'expense';

    if (type.toLowerCase() != 'expense') return 0.0;

    return _parseAmount(data['amount']);
  }

  if (component.toolName == 'record_transactions' ||
      component.toolName == 'record_shared_transactions') {
    final data = component.userSelection ?? component.data;
    if (data.isEmpty) return 0.0;

    final summary = data['summary'] as Map<String, dynamic>?;
    if (summary != null) {
      final expenseTotal = _parseAmount(summary['expense_total']);
      if (expenseTotal > 0) {
        return expenseTotal;
      }
    }
    return 0.0;
  }

  if (component.toolName == 'create_space_transaction') {
    final data = component.userSelection ?? component.data;
    if (data.isEmpty) return 0.0;

    final type = data['type'] as String? ?? 'expense';
    if (type.toLowerCase() != 'expense') return 0.0;

    return _parseAmount(data['amount']);
  }

  return 0.0;
}

/// Extract expense amount from a single tool call, or 0 if not expense.
double _expenseFromToolCall(ToolCallInfo messageToolCall) {
  if (messageToolCall.name == 'create_transaction') {
    final args = messageToolCall.args;
    if (args.isEmpty) return 0.0;

    final type = args['transaction_type'] as String? ?? 'expense';
    if (type.toLowerCase() != 'expense') return 0.0;

    return _parseAmount(args['amount']);
  }

  if (messageToolCall.name == 'record_transactions' ||
      messageToolCall.name == 'record_shared_transactions') {
    final args = messageToolCall.args;
    if (args.isEmpty) return 0.0;

    final transactions = args['transactions'] as List<dynamic>?;
    if (transactions == null) return 0.0;

    double total = 0.0;
    for (final tx in transactions) {
      final txMap = tx as Map<String, dynamic>;
      final type = txMap['type'] as String? ?? 'expense';
      if (type.toLowerCase() != 'expense') continue;

      final amount = _parseAmount(txMap['amount']);
      if (amount > 0) {
        total += amount;
      }
    }
    return total;
  }

  if (messageToolCall.name == 'create_space_transaction') {
    final args = messageToolCall.args;
    if (args.isEmpty) return 0.0;

    final type = args['transaction_type'] as String? ?? 'expense';
    if (type.toLowerCase() != 'expense') return 0.0;

    return _parseAmount(args['amount']);
  }

  return 0.0;
}

/// Parse amount, supporting multiple types
double _parseAmount(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Formatted current conversation expense title Provider
///
@riverpod
String conversationExpenseTitle(Ref ref) {
  final expense = ref.watch(conversationTotalExpenseProvider);

  if (expense <= 0) {
    return '${t.chat.currentExpense}: 0.00';
  }

  final formatter = NumberFormat('#,##0.00');
  return '${t.chat.currentExpense}: ${formatter.format(expense)}';
}
