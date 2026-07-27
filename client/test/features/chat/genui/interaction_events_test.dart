import 'package:finvo/features/chat/genui/events/interaction_events.dart';
import 'package:finvo/features/chat/genui/genui_event_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// 类型化交互事件模型单元测试。
///
/// 覆盖 P0 类型化改造的核心契约：
/// - [GenUiInteractionEvent.tryParse] 对各事件名的解码与未知事件兜底（null）。
/// - encode（toContext）/ decode（fromContext）往返一致性。
/// - [GenUiInteractionEvent.toUserActionEvent] 产出的 wire 格式。
/// - [GenUiEventRegistry.handle] 对各类型事件的业务处理（含 account 修复与
///   交易确认返回 null 的兜底行为）。
void main() {
  group('GenUiInteractionEvent.tryParse', () {
    test('parses transfer_path_confirmed into typed event', () {
      final event = GenUiInteractionEvent.tryParse('transfer_path_confirmed', {
        'surface_id': 'surface_abc',
        'source_account_id': 'src-1',
        'target_account_id': 'tgt-1',
        'source_account_name': '现金钱包',
        'target_account_name': '储蓄卡',
        'amount': 50,
        'currency': 'CNY',
        'memo': '午餐',
      });

      expect(event, isA<TransferPathConfirmedEvent>());
      final transfer = event! as TransferPathConfirmedEvent;
      expect(transfer.surfaceId, 'surface_abc');
      expect(transfer.sourceAccountId, 'src-1');
      expect(transfer.targetAccountId, 'tgt-1');
      expect(transfer.amount, 50.0);
      expect(transfer.currency, 'CNY');
      expect(transfer.memo, '午餐');
    });

    test('parses amount given as String', () {
      final event =
          GenUiInteractionEvent.tryParse('transfer_path_confirmed', {
                'source_account_id': 'src-1',
                'target_account_id': 'tgt-1',
                'amount': '88.5',
              })!
              as TransferPathConfirmedEvent;

      expect(event.amount, 88.5);
      // 缺省字段降级为默认值。
      expect(event.sourceAccountName, '转出账户');
      expect(event.targetAccountName, '转入账户');
      expect(event.currency, 'CNY');
    });

    test('parses space_selected into typed event', () {
      final event = GenUiInteractionEvent.tryParse('space_selected', {
        'surface_id': 'surface_xyz',
        'space_id': 7,
        'space_name': '家庭',
        'transaction_ids': ['t1', 't2'],
      });

      expect(event, isA<SpaceSelectedEvent>());
      final space = event! as SpaceSelectedEvent;
      expect(space.spaceId, 7);
      expect(space.spaceName, '家庭');
      expect(space.transactionIds, ['t1', 't2']);
    });

    test('parses account_selected using dispatcher keys (regression fix)', () {
      // 重构前注册表误读 selected_account_id/selection_type，导致显示 null。
      // 类型化后统一使用 dispatcher 实际发出的 account_id/account_type 键。
      final event = GenUiInteractionEvent.tryParse('account_selected', {
        'account_id': 'acc-1',
        'account_name': '招商银行',
        'account_type': 'BANK',
      });

      expect(event, isA<AccountSelectedEvent>());
      final account = event! as AccountSelectedEvent;
      expect(account.accountId, 'acc-1');
      expect(account.accountName, '招商银行');
      expect(account.accountType, 'BANK');
    });

    test('parses transaction_confirmed_with_account into typed event', () {
      final event =
          GenUiInteractionEvent.tryParse('transaction_confirmed_with_account', {
            'account_id': 'acc-1',
            'amount': 15,
            'description': '早餐',
            'transaction_type': 'EXPENSE',
          });

      expect(event, isA<TransactionConfirmedWithAccountEvent>());
      final txn = event! as TransactionConfirmedWithAccountEvent;
      expect(txn.accountId, 'acc-1');
      expect(txn.amount, 15);
      expect(txn.transactionType, 'EXPENSE');
    });

    test('returns null for unknown event name', () {
      expect(
        GenUiInteractionEvent.tryParse('some_unregistered_event', {}),
        isNull,
      );
    });

    test('returns null for null event name', () {
      expect(GenUiInteractionEvent.tryParse(null, {}), isNull);
    });
  });

  group('encode/decode round-trip', () {
    test('transfer event survives toContext -> fromContext', () {
      const original = TransferPathConfirmedEvent(
        surfaceId: 'surface_abc',
        sourceAccountId: 'src-1',
        targetAccountId: 'tgt-1',
        sourceAccountName: '现金钱包',
        targetAccountName: '储蓄卡',
        amount: 50.0,
        currency: 'CNY',
        memo: '午餐',
      );

      final decoded = TransferPathConfirmedEvent.fromContext(
        original.toContext(),
      );

      expect(decoded.surfaceId, original.surfaceId);
      expect(decoded.sourceAccountId, original.sourceAccountId);
      expect(decoded.targetAccountId, original.targetAccountId);
      expect(decoded.sourceAccountName, original.sourceAccountName);
      expect(decoded.targetAccountName, original.targetAccountName);
      expect(decoded.amount, original.amount);
      expect(decoded.currency, original.currency);
      expect(decoded.memo, original.memo);
    });

    test('toUserActionEvent produces protocol wire format', () {
      const event = TransferPathConfirmedEvent(
        sourceAccountId: 'src-1',
        targetAccountId: 'tgt-1',
        sourceAccountName: '现金钱包',
        targetAccountName: '储蓄卡',
        amount: 50.0,
      );

      final uiEvent = event.toUserActionEvent(
        sourceComponentId: 'TransferWizard',
      );

      expect(uiEvent.name, 'transfer_path_confirmed');
      expect(uiEvent.sourceComponentId, 'TransferWizard');
      expect(uiEvent.context['source_account_id'], 'src-1');
      expect(uiEvent.context['target_account_id'], 'tgt-1');
      expect(uiEvent.context['amount'], 50.0);
    });
  });

  group('GenUiEventRegistry.handle', () {
    test('transfer yields direct_execute mutation and readable content', () {
      const event = TransferPathConfirmedEvent(
        surfaceId: 'surface_abc',
        sourceAccountId: 'src-1',
        targetAccountId: 'tgt-1',
        sourceAccountName: '现金钱包',
        targetAccountName: '储蓄卡',
        amount: 50.0,
      );

      final result = GenUiEventRegistry.handle(event);

      expect(result, isNotNull);
      expect(result!.mutation, isNotNull);
      final json = result.mutation!.toJson();
      expect(json['ui_mode'], 'direct_execute');
      expect(json['tool_name'], 'execute_transfer');
      final toolParams = json['tool_params'] as Map<String, dynamic>;
      expect(toolParams['source_account_id'], 'src-1');
      expect(toolParams['amount'], 50.0);
      expect(result.payloadExtensions!['content'], '按照我的选择执行转账');
    });

    test('space yields space-association mutation', () {
      const event = SpaceSelectedEvent(
        surfaceId: 'surface_xyz',
        spaceId: 7,
        transactionIds: ['t1', 't2'],
      );

      final result = GenUiEventRegistry.handle(event);

      expect(result, isNotNull);
      final json = result!.mutation!.toJson();
      expect(json['ui_mode'], 'direct_execute');
      expect(json['tool_name'], 'associate_transactions_to_space');
      final toolParams = json['tool_params'] as Map<String, dynamic>;
      expect(toolParams['space_id'], 7);
      expect(toolParams['transaction_ids'], ['t1', 't2']);
    });

    test('account yields readable content with real id (no mutation)', () {
      const event = AccountSelectedEvent(
        accountId: 'acc-1',
        accountName: '招商银行',
        accountType: 'BANK',
      );

      final result = GenUiEventRegistry.handle(event);

      expect(result, isNotNull);
      expect(result!.mutation, isNull);
      expect(result.payloadExtensions!['content'], '我选择了账户 ID: acc-1 (BANK)');
    });

    test('transaction confirmation returns null to preserve fallback', () {
      const event = TransactionConfirmedWithAccountEvent(
        accountId: 'acc-1',
        amount: 15,
      );

      expect(GenUiEventRegistry.handle(event), isNull);
    });
  });
}
