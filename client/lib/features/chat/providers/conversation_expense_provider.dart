import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/models/tool_call_info.dart';
import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
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

  Decimal totalExpense = Decimal.zero;

  for (final message in messages) {
    totalExpense += scanMessageExpense(message);
  }

  return totalExpense.toDouble();
}

/// Scan a single message for expense amounts.
///
/// Extracts expenses from UI components and tool calls, deduplicating by
/// toolCallId so the same transaction rendered as both a component and a
/// tool call is counted once. Only successful tool calls are counted.
///
/// Accumulates in [Decimal] to avoid floating-point drift across many
/// transactions; callers convert to double only for display.
Decimal scanMessageExpense(ChatMessage message) {
  Decimal total = Decimal.zero;
  final countedToolCallIds = <String>{};

  // Tool calls are the canonical source of executed transactions.
  for (final messageToolCall in message.toolCalls) {
    if (messageToolCall.status == ToolExecutionStatus.error ||
        messageToolCall.status == ToolExecutionStatus.cancelled) {
      continue;
    }

    final expense = _expenseFromToolCall(messageToolCall);
    if (expense > Decimal.zero) {
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
    if (expense > Decimal.zero) {
      total += expense;
    }
  }

  return total;
}

/// Extract expense amount from a single UI component, or 0 if not expense.
Decimal _expenseFromUiComponent(UIComponentInfo component) {
  if (component.toolName == 'create_transaction') {
    final data = component.userSelection ?? component.data;
    if (data.isEmpty) return Decimal.zero;

    final type =
        data['transaction_type'] as String? ??
        data['type'] as String? ??
        'expense';

    if (type.toLowerCase() != 'expense') return Decimal.zero;

    return _parseAmount(data['amount']);
  }

  if (component.toolName == 'record_transactions' ||
      component.toolName == 'record_shared_transactions') {
    final data = component.userSelection ?? component.data;
    if (data.isEmpty) return Decimal.zero;

    // AI-generated data is untrusted: guard the cast instead of assuming the
    // shape promised by the tool contract.
    final summary = data['summary'];
    if (summary is Map<String, dynamic>) {
      final expenseTotal = _parseAmount(summary['expense_total']);
      if (expenseTotal > Decimal.zero) {
        return expenseTotal;
      }
    }
    return Decimal.zero;
  }

  if (component.toolName == 'create_space_transaction') {
    final data = component.userSelection ?? component.data;
    if (data.isEmpty) return Decimal.zero;

    final type = data['type'] as String? ?? 'expense';
    if (type.toLowerCase() != 'expense') return Decimal.zero;

    return _parseAmount(data['amount']);
  }

  return Decimal.zero;
}

/// Extract expense amount from a single tool call, or 0 if not expense.
Decimal _expenseFromToolCall(ToolCallInfo messageToolCall) {
  if (messageToolCall.name == 'create_transaction') {
    final args = messageToolCall.args;
    if (args.isEmpty) return Decimal.zero;

    final type = args['transaction_type'] as String? ?? 'expense';
    if (type.toLowerCase() != 'expense') return Decimal.zero;

    return _parseAmount(args['amount']);
  }

  if (messageToolCall.name == 'record_transactions' ||
      messageToolCall.name == 'record_shared_transactions') {
    final args = messageToolCall.args;
    if (args.isEmpty) return Decimal.zero;

    // Untrusted AI payload: skip malformed entries instead of throwing.
    final transactions = args['transactions'];
    if (transactions is! List) return Decimal.zero;

    Decimal total = Decimal.zero;
    for (final tx in transactions) {
      if (tx is! Map<String, dynamic>) continue;

      final type = tx['type'] as String? ?? 'expense';
      if (type.toLowerCase() != 'expense') continue;

      final amount = _parseAmount(tx['amount']);
      if (amount > Decimal.zero) {
        total += amount;
      }
    }
    return total;
  }

  if (messageToolCall.name == 'create_space_transaction') {
    final args = messageToolCall.args;
    if (args.isEmpty) return Decimal.zero;

    final type = args['transaction_type'] as String? ?? 'expense';
    if (type.toLowerCase() != 'expense') return Decimal.zero;

    return _parseAmount(args['amount']);
  }

  return Decimal.zero;
}

/// Parse amount, supporting multiple types. Returns [Decimal] so callers can
/// accumulate without floating-point drift.
Decimal _parseAmount(dynamic value) {
  if (value == null) return Decimal.zero;
  if (value is num) return Decimal.parse(value.toString());
  if (value is String) return Decimal.tryParse(value) ?? Decimal.zero;
  return Decimal.zero;
}

/// Formatted current conversation expense title Provider
///
@riverpod
String conversationExpenseTitle(Ref ref) {
  ref.watch(localeProvider);
  final expense = ref.watch(conversationTotalExpenseProvider);

  if (expense <= 0) {
    return '${t.chat.currentExpense}: 0.00';
  }

  final formatter = NumberFormat('#,##0.00');
  return '${t.chat.currentExpense}: ${formatter.format(expense)}';
}
