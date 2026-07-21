/// Typed GenUI Interaction Events
///
/// 类型化交互事件模型 —— GenUI 按钮交互 wire 契约的「单一事实来源」。
///
/// 设计理念（P0：根治键名拼写 / 类型不一致类 bug）：
/// - 在 A2UI v0.9 中，Surface 按钮交互经 genui [genui.UserActionEvent] 发出，
///   其 `context` 是无类型的 `Map<String, Object?>`。重构前 dispatcher（组件）
///   与 handler（注册表）靠字符串键隐式约定 context 结构，编译器无法校验，
///   曾导致 `sourceAccount` vs `source_account_id` 这类静默错配。
/// - 本模型把每个交互事件定义为 sealed 子类，wire 键名只出现在对应类的
///   [toContext]（编码 / dispatcher 侧）与 `fromContext`（解码 / handler 侧）
///   中一次。dispatcher 通过 [toUserActionEvent] 发出，handler 通过
///   [GenUiInteractionEvent.tryParse] 解码，两端共享同一类型契约。
/// - sealed 层次使注册表可用穷尽 `switch` 处理事件：新增事件类型时编译器
///   强制要求补充处理器，杜绝「漏处理」静默通过。
///
/// 行为契约（与重构前完全等价）：
/// - [tryParse] 对未知事件名返回 null，由调用方（InteractionRouter）走
///   `Action: <name>` 兜底。
/// - 各事件 `toContext` 产出的键值与重构前组件内联构造的 context 字节级一致，
///   保证后端契约不变。
library;

import 'package:genui/genui.dart' as genui;

import 'event_names.dart';
import 'space_events.dart';

/// 把 wire 上的 amount 字段（num 或 String）安全转换为 double。
double _amountToDouble(Object? raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw) ?? 0.0;
  return 0.0;
}

/// GenUI 交互事件基类。
///
/// sealed 以支持穷尽 switch；每个子类对应一个 wire 事件名（[eventName]）。
sealed class GenUiInteractionEvent {
  const GenUiInteractionEvent();

  /// wire 上的 `action.name`。
  String get eventName;

  /// 来源 Surface ID（部分事件无 surface 上下文，可空）。
  String? get surfaceId;

  /// 编码为 wire context（dispatcher 侧）。
  ///
  /// 键名必须与对应 `fromContext` 解码完全对称。
  Map<String, dynamic> toContext();

  /// 编码为 genui [genui.UserActionEvent]（dispatcher 侧统一出口）。
  ///
  /// [sourceComponentId] 为触发组件标识，写入 wire `action.sourceComponentId`。
  genui.UserActionEvent toUserActionEvent({required String sourceComponentId}) {
    return genui.UserActionEvent(
      name: eventName,
      sourceComponentId: sourceComponentId,
      context: toContext(),
    );
  }

  /// 从 wire action 解码为类型化事件（handler 侧统一入口）。
  ///
  /// 未知事件名返回 null，由调用方走兜底；已知事件即使字段缺失也返回实例
  /// （字段按各自默认值降级），与重构前注册表的宽松解析一致。
  static GenUiInteractionEvent? tryParse(
    String? name,
    Map<String, dynamic> context,
  ) {
    return switch (name) {
      GenUiEventNames.transferPathConfirmed =>
        TransferPathConfirmedEvent.fromContext(context),
      SpaceEventNames.spaceSelected => SpaceSelectedEvent.fromContext(context),
      GenUiEventNames.accountSelected => AccountSelectedEvent.fromContext(
        context,
      ),
      GenUiEventNames.transactionConfirmedWithAccount =>
        TransactionConfirmedWithAccountEvent.fromContext(context),
      _ => null,
    };
  }
}

/// 转账路径确认事件（`transfer_path_confirmed`）。
///
/// 由 TransferWizard 在用户确认转账路径时发出；注册表据此生成
/// `direct_execute` 原子转账 mutation。
final class TransferPathConfirmedEvent extends GenUiInteractionEvent {
  final String sourceAccountId;
  final String targetAccountId;
  final String sourceAccountName;
  final String targetAccountName;
  final double amount;
  final String currency;
  final String? memo;
  @override
  final String? surfaceId;

  const TransferPathConfirmedEvent({
    required this.sourceAccountId,
    required this.targetAccountId,
    required this.sourceAccountName,
    required this.targetAccountName,
    required this.amount,
    this.currency = 'CNY',
    this.memo,
    this.surfaceId,
  });

  factory TransferPathConfirmedEvent.fromContext(Map<String, dynamic> context) {
    return TransferPathConfirmedEvent(
      sourceAccountId: context['source_account_id'] as String? ?? '',
      targetAccountId: context['target_account_id'] as String? ?? '',
      sourceAccountName: context['source_account_name'] as String? ?? '转出账户',
      targetAccountName: context['target_account_name'] as String? ?? '转入账户',
      amount: _amountToDouble(context['amount']),
      currency: context['currency'] as String? ?? 'CNY',
      memo: context['memo'] as String?,
      surfaceId: context['surface_id'] as String?,
    );
  }

  @override
  String get eventName => GenUiEventNames.transferPathConfirmed;

  @override
  Map<String, dynamic> toContext() => {
    'surface_id': surfaceId,
    'source_account_id': sourceAccountId,
    'target_account_id': targetAccountId,
    'source_account_name': sourceAccountName,
    'target_account_name': targetAccountName,
    'amount': amount,
    'currency': currency,
    'memo': memo,
  };
}

/// 共享空间选择事件（`space_selected`）。
///
/// 由 SpaceSelectorCard 在用户确认空间归属时发出；注册表据此生成
/// `direct_execute` 交易关联 mutation。
final class SpaceSelectedEvent extends GenUiInteractionEvent {
  final int spaceId;
  final String? spaceName;
  final List<String> transactionIds;
  @override
  final String? surfaceId;

  const SpaceSelectedEvent({
    required this.spaceId,
    this.spaceName,
    this.transactionIds = const [],
    this.surfaceId,
  });

  factory SpaceSelectedEvent.fromContext(Map<String, dynamic> context) {
    return SpaceSelectedEvent(
      spaceId: (context['space_id'] as num?)?.toInt() ?? 0,
      spaceName: context['space_name'] as String?,
      transactionIds:
          (context['transaction_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      surfaceId: context['surface_id'] as String?,
    );
  }

  @override
  String get eventName => SpaceEventNames.spaceSelected;

  @override
  Map<String, dynamic> toContext() => {
    'surface_id': surfaceId,
    'space_id': spaceId,
    'space_name': spaceName ?? '',
    'transaction_ids': transactionIds,
  };
}

/// 账户选择事件（`account_selected`）。
///
/// 由 AccountSelector 在用户点选账户时发出；注册表据此生成回传给 LLM 的
/// 人类可读文案（无原子 mutation）。
final class AccountSelectedEvent extends GenUiInteractionEvent {
  final String? accountId;
  final String? accountName;
  final String? accountType;
  @override
  final String? surfaceId;

  const AccountSelectedEvent({
    this.accountId,
    this.accountName,
    this.accountType,
    this.surfaceId,
  });

  factory AccountSelectedEvent.fromContext(Map<String, dynamic> context) {
    return AccountSelectedEvent(
      accountId: context['account_id'] as String?,
      accountName: context['account_name'] as String?,
      accountType: context['account_type'] as String?,
      surfaceId: context['surface_id'] as String?,
    );
  }

  @override
  String get eventName => GenUiEventNames.accountSelected;

  @override
  Map<String, dynamic> toContext() => {
    'account_id': accountId,
    'account_name': accountName,
    'account_type': accountType,
  };
}

/// 交易确认（含账户关联）事件（`transaction_confirmed_with_account`）。
///
/// 由 TransactionConfirmation 在用户确认记账时发出。当前无原子 mutation，
/// 注册表对其返回 null，由 InteractionRouter 走兜底（保持重构前行为）。
/// 类型化后 dispatcher 侧仍获得编译期键名/类型校验。
final class TransactionConfirmedWithAccountEvent extends GenUiInteractionEvent {
  final String? accountId;
  final String? accountName;
  final Object? amount;
  final String? description;
  final String? transactionType;
  final String? categoryKey;
  final String? currency;
  final String? rawInput;
  final List<dynamic>? tags;
  @override
  final String? surfaceId;

  const TransactionConfirmedWithAccountEvent({
    this.accountId,
    this.accountName,
    this.amount,
    this.description,
    this.transactionType,
    this.categoryKey,
    this.currency,
    this.rawInput,
    this.tags,
    this.surfaceId,
  });

  factory TransactionConfirmedWithAccountEvent.fromContext(
    Map<String, dynamic> context,
  ) {
    return TransactionConfirmedWithAccountEvent(
      accountId: context['account_id'] as String?,
      accountName: context['account_name'] as String?,
      amount: context['amount'],
      description: context['description'] as String?,
      transactionType: context['transaction_type'] as String?,
      categoryKey: context['category_key'] as String?,
      currency: context['currency'] as String?,
      rawInput: context['raw_input'] as String?,
      tags: context['tags'] as List<dynamic>?,
      surfaceId: context['surface_id'] as String?,
    );
  }

  @override
  String get eventName => GenUiEventNames.transactionConfirmedWithAccount;

  @override
  Map<String, dynamic> toContext() => {
    'account_id': accountId,
    'account_name': accountName,
    'amount': amount,
    'description': description,
    'transaction_type': transactionType,
    'category_key': categoryKey,
    'currency': currency,
    'raw_input': rawInput,
    'tags': tags,
  };
}
