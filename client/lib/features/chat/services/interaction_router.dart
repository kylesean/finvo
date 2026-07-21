/// Interaction Router
///
/// 出站消息路由器 —— 将 genui 的 [genui.ChatMessage] 分类并转换为后端 payload。
///
/// 设计理念（单一职责、纯逻辑、可独立单测）：
/// - 在 genui 0.10 / A2UI v0.9 中，Surface 按钮交互统一以"空文本 user 消息 +
///   UiInteractionPart"形式到达（见 SurfaceController.handleUiEvent），旧的
///   "文本里塞 {"userAction":...}" 约定已废弃。
/// - 本组件负责：消息分类 -> 交互解析（类型化访问器，带 mimeType 校验）->
///   经 [GenUiEventRegistry] 分发业务事件 -> 产出 [OutgoingMessage]。
/// - 不含任何网络与副作用，[CustomContentGenerator] 仅负责把结果发出去。
///
/// 行为契约（与重构前完全等价）：
/// - SurfaceController.reportError 的错误反馈（interaction 内含 "error"）绝不转发。
/// - 已注册业务事件（如 transfer_path_confirmed）产出人类可读文案 +
///   client_state mutation（ui_mode=direct_execute），后端原子执行。
/// - 未注册事件兜底为 `Action: <name>`（保持现状）。
library;

import 'dart:convert';

import 'package:genui/genui.dart' as genui;

import '../genui/events/interaction_events.dart';
import '../genui/genui_event_registry.dart';

/// 出站消息的类型化结果。
///
/// 替代重构前松散 Map + `_skip` 哨兵键的返回约定。
class OutgoingMessage {
  /// 发给后端的消息体列表。
  final List<Map<String, dynamic>> payload;

  /// GenUI 原子模式的 client_state mutation（可空）。
  /// 非空时后端走 direct_execute，跳过 LLM。
  final Map<String, dynamic>? clientState;

  /// 乐观更新展示给用户的内容（null 表示不展示）。
  final String? displayContent;

  /// 是否整体跳过（错误反馈 / 空内容）。为 true 时不发送、不展示。
  final bool skip;

  const OutgoingMessage({
    required this.payload,
    this.clientState,
    this.displayContent,
    this.skip = false,
  });

  /// 构造一条"跳过"消息。
  factory OutgoingMessage.skipped() =>
      const OutgoingMessage(payload: [], skip: true);
}

/// 出站交互路由器。
///
/// 纯逻辑组件：把一条 genui 用户消息路由为 [OutgoingMessage]。
class InteractionRouter {
  /// 将 genui 消息路由为出站消息。
  OutgoingMessage route(genui.ChatMessage message) {
    // sendRequest 只收到 user 消息（controller.onSubmit）；非 user 防御性跳过。
    if (message.role != genui.ChatMessageRole.user) {
      return OutgoingMessage.skipped();
    }

    // A2UI v0.9 交互路径：空文本 + UiInteractionPart。
    final interaction = _extractInteraction(message);
    if (interaction != null) {
      return _routeInteraction(interaction);
    }

    // 纯文本用户消息。
    final text = message.text;
    if (text.isEmpty) {
      return OutgoingMessage.skipped();
    }
    return OutgoingMessage(
      payload: [
        {'role': 'user', 'content': text},
      ],
      displayContent: text,
    );
  }

  /// 用 genui 类型化访问器提取交互 JSON 字符串。
  ///
  /// `uiInteractionParts` 只匹配 mimeType 为
  /// `application/vnd.genui.interaction+json` 的 DataPart，避免误解析附件等
  /// 其它 DataPart（重构前的手工字节解析无视 mimeType）。
  String? _extractInteraction(genui.ChatMessage message) {
    for (final part in message.parts.uiInteractionParts) {
      return part.interaction;
    }
    return null;
  }

  /// 解析交互 JSON 并路由。
  OutgoingMessage _routeInteraction(String interactionJson) {
    final Map<String, dynamic> inner;
    try {
      inner = jsonDecode(interactionJson) as Map<String, dynamic>;
    } catch (_) {
      return OutgoingMessage.skipped();
    }

    // SurfaceController.reportError 的错误反馈，绝不转发回后端
    // （会打断进行中的 SSE 流并被后端以 422 拒绝）。
    if (inner.containsKey('error')) {
      return OutgoingMessage.skipped();
    }

    // 动作事件：交给业务注册表分发。
    final action = inner['action'];
    if (action is Map<String, dynamic>) {
      return _routeAction(action);
    }

    return OutgoingMessage.skipped();
  }

  /// 将动作事件经类型化解析与 [GenUiEventRegistry] 分发并构造出站消息。
  OutgoingMessage _routeAction(Map<String, dynamic> action) {
    final name = action['name'] as String?;
    final context = (action['context'] as Map<String, dynamic>?) ?? const {};

    // 类型化解码：未知事件 -> null，走 `Action: <name>` 兜底（保持现状）。
    final event = GenUiInteractionEvent.tryParse(name, context);
    if (event == null) {
      return _fallback('Action: $name');
    }

    final result = GenUiEventRegistry.handle(event);
    if (result != null && !result.isEmpty) {
      final extensions = result.payloadExtensions;
      final content =
          (extensions?['content'] as String?) ?? 'Action: ${event.eventName}';
      return OutgoingMessage(
        payload: [
          extensions ?? {'role': 'user', 'content': content},
        ],
        clientState: result.mutation?.toJson(),
        displayContent: content,
      );
    }

    // 已知事件但无业务处理（如交易确认）-> 兜底，保持重构前行为。
    return _fallback('Action: ${event.eventName}');
  }

  /// 构造兜底出站消息（未注册 / 无业务处理的事件）。
  OutgoingMessage _fallback(String content) {
    return OutgoingMessage(
      payload: [
        {'role': 'user', 'content': content},
      ],
      displayContent: content,
    );
  }
}
