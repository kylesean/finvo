/// GenUI Event Registry
///
/// 事件注册表 —— 解耦 ContentGenerator/InteractionRouter 与业务逻辑。
///
/// 设计理念（P0 类型化改造）：
/// - 处理器以 [GenUiInteractionEvent] 密封层次为输入，通过穷尽 `switch` 分发。
///   新增事件类型时编译器强制要求补充处理分支，杜绝「漏处理」静默通过。
/// - 注册表不再维护字符串键 -> 处理器的动态映射；事件 wire 契约由
///   `events/interaction_events.dart` 的密封类型单点定义。
/// - Router 仅负责 `tryParse` + 调用 [handle]，无需知道具体业务事件。
///
/// 使用方式：
/// ```dart
/// final event = GenUiInteractionEvent.tryParse(name, context);
/// if (event != null) {
///   final result = GenUiEventRegistry.handle(event);
///   if (result != null && !result.isEmpty) {
///     body['client_state'] = result.mutation?.toJson();
///   }
/// }
/// ```
library;

import 'package:logging/logging.dart';

import '../models/client_state_mutation.dart';
import 'events/interaction_events.dart';

/// 事件处理器结果
///
/// 包含业务变更 (ClientStateMutation) 和 可选的发送给 LLM 的 Payload 增强数据
class EventProcessingResult {
  final ClientStateMutation? mutation;
  final Map<String, dynamic>? payloadExtensions;

  const EventProcessingResult({this.mutation, this.payloadExtensions});

  bool get isEmpty => mutation == null && payloadExtensions == null;
}

/// GenUI 事件注册表
///
/// 以密封事件类型为输入的无状态分发器。
class GenUiEventRegistry {
  GenUiEventRegistry._(); // 禁止实例化

  static final _logger = Logger('GenUiEventRegistry');

  /// 分发类型化事件，返回业务处理结果。
  ///
  /// 穷尽 `switch` 保证新增 [GenUiInteractionEvent] 子类时编译期强制实现处理器。
  /// 返回 null 表示该事件无业务处理（由调用方走兜底）。
  static EventProcessingResult? handle(GenUiInteractionEvent event) {
    _logger.fine('GenUiEventRegistry: handling "${event.eventName}"');
    return switch (event) {
      TransferPathConfirmedEvent() => _handleTransferPathConfirmed(event),
      SpaceSelectedEvent() => _handleSpaceSelected(event),
      AccountSelectedEvent() => _handleAccountSelected(event),
      // 交易确认（含账户）当前无原子 mutation，返回 null 让 Router 走兜底，
      // 保持与重构前完全一致的行为。
      TransactionConfirmedWithAccountEvent() => null,
    };
  }

  /// 转账路径确认 -> direct_execute 原子转账。
  static EventProcessingResult _handleTransferPathConfirmed(
    TransferPathConfirmedEvent event,
  ) {
    return EventProcessingResult(
      mutation: ClientStateMutation.forTransfer(
        surfaceId: event.surfaceId,
        sourceAccountId: event.sourceAccountId,
        targetAccountId: event.targetAccountId,
        sourceAccountName: event.sourceAccountName,
        targetAccountName: event.targetAccountName,
        amount: event.amount,
        currency: event.currency,
      ),
      payloadExtensions: {
        'role': 'user',
        'content': '按照我的选择执行转账',
        'metadata': {'event_type': event.eventName, ...event.toContext()},
      },
    );
  }

  /// 空间选择 -> direct_execute 交易关联。
  static EventProcessingResult _handleSpaceSelected(SpaceSelectedEvent event) {
    return EventProcessingResult(
      mutation: ClientStateMutation.forSpaceAssociation(
        surfaceId: event.surfaceId,
        spaceId: event.spaceId,
        transactionIds: event.transactionIds,
      ),
      payloadExtensions: {
        'role': 'user',
        'content': '关联选定的空间',
        'metadata': {'event_type': event.eventName, ...event.toContext()},
      },
    );
  }

  /// 账户选择 -> 回传 LLM 的人类可读文案（无原子 mutation）。
  static EventProcessingResult _handleAccountSelected(
    AccountSelectedEvent event,
  ) {
    return EventProcessingResult(
      payloadExtensions: {
        'role': 'user',
        'content': '我选择了账户 ID: ${event.accountId} (${event.accountType})',
        'metadata': {'event_type': event.eventName, ...event.toContext()},
      },
    );
  }
}
