import 'dart:convert';

import 'package:finvo/features/chat/services/interaction_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart' as genui;

/// InteractionRouter 单元测试。
///
/// 覆盖 A2UI v0.9 出站消息路由的核心路径：纯文本、UI 交互（动作/错误反馈）、
/// 已注册业务事件（转账）、未注册事件兜底、非法输入与非 user 消息。
void main() {
  final router = InteractionRouter();

  /// 构造一条携带 UI 交互的"空文本"user 消息（genui 0.10 按钮交互的标准形态）。
  genui.ChatMessage interactionMessage(Object interaction) {
    return genui.ChatMessage.user(
      '',
      parts: [
        genui.UiInteractionPart.create(
          interaction is String ? interaction : jsonEncode(interaction),
        ),
      ],
    );
  }

  group('plain text', () {
    test('plain text message is forwarded as user content', () {
      final outgoing = router.route(genui.ChatMessage.user('记一笔早餐 15 元'));

      expect(outgoing.skip, isFalse);
      expect(outgoing.clientState, isNull);
      expect(outgoing.displayContent, '记一笔早餐 15 元');
      expect(outgoing.payload, [
        {'role': 'user', 'content': '记一笔早餐 15 元'},
      ]);
    });

    test('empty text without interaction is skipped', () {
      final outgoing = router.route(genui.ChatMessage.user(''));

      expect(outgoing.skip, isTrue);
      expect(outgoing.payload, isEmpty);
    });
  });

  group('UI interaction', () {
    test('error feedback interaction is never forwarded', () {
      final outgoing = router.route(
        interactionMessage({
          'version': 'v0.9',
          'error': {'message': 'schema validation failed'},
        }),
      );

      expect(outgoing.skip, isTrue);
      expect(outgoing.payload, isEmpty);
    });

    test('malformed interaction JSON is skipped', () {
      final outgoing = router.route(interactionMessage('not-valid-json'));

      expect(outgoing.skip, isTrue);
      expect(outgoing.payload, isEmpty);
    });

    test('registered transfer_path_confirmed yields human-readable content '
        'and direct_execute client_state', () {
      final outgoing = router.route(
        interactionMessage({
          'version': 'v0.9',
          'action': {
            'name': 'transfer_path_confirmed',
            'sourceComponentId': 'TransferWizard',
            'context': {
              'surface_id': 'surface_abc',
              'source_account_id': 'src-1',
              'target_account_id': 'tgt-1',
              'source_account_name': '现金钱包',
              'target_account_name': 'test',
              'amount': 50,
              'currency': 'CNY',
            },
          },
        }),
      );

      expect(outgoing.skip, isFalse);
      expect(outgoing.displayContent, '按照我的选择执行转账');

      // client_state 触发后端 direct_execute 原子转账。
      final clientState = outgoing.clientState;
      expect(clientState, isNotNull);
      expect(clientState!['ui_mode'], 'direct_execute');
      expect(clientState['tool_name'], 'execute_transfer');
      final toolParams = clientState['tool_params'] as Map<String, dynamic>;
      expect(toolParams['source_account_id'], 'src-1');
      expect(toolParams['target_account_id'], 'tgt-1');
      expect(toolParams['amount'], 50.0);

      // 发给后端的 payload 为注册表提供的 payloadExtensions。
      expect(outgoing.payload, hasLength(1));
      expect(outgoing.payload.first['content'], '按照我的选择执行转账');
    });

    test('unregistered action falls back to "Action: <name>"', () {
      final outgoing = router.route(
        interactionMessage({
          'version': 'v0.9',
          'action': {
            'name': 'some_unregistered_event',
            'sourceComponentId': 'SomeComponent',
            'context': <String, dynamic>{},
          },
        }),
      );

      expect(outgoing.skip, isFalse);
      expect(outgoing.clientState, isNull);
      expect(outgoing.displayContent, 'Action: some_unregistered_event');
      expect(outgoing.payload, [
        {'role': 'user', 'content': 'Action: some_unregistered_event'},
      ]);
    });
  });

  group('message classification', () {
    test('non-user message is skipped defensively', () {
      final outgoing = router.route(genui.ChatMessage.model('assistant reply'));

      expect(outgoing.skip, isTrue);
      expect(outgoing.payload, isEmpty);
    });
  });
}
