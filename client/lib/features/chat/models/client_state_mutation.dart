import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_state_mutation.freezed.dart';

/// Client state mutation
///
/// GenUI atomic mode protocol:
/// - Client attaches state mutation in message request
/// - Server atomically applies mutation before graph execution
@freezed
abstract class ClientStateMutation with _$ClientStateMutation {
  const factory ClientStateMutation({
    /// UI mode: Controls graph entry routing
    /// - 'idle': Goes through agent node
    /// - 'direct_execute': Skips LLM, executes tool_name directly
    String? uiMode,

    /// Tool name to execute directly (must be registered in INTERNAL_TOOLS)
    String? toolName,

    /// Tool parameters
    Map<String, dynamic>? toolParams,
  }) = _ClientStateMutation;

  /// Quick creation for transfer execution
  static ClientStateMutation forTransfer({
    String? surfaceId,
    required String sourceAccountId,
    required String targetAccountId,
    required String sourceAccountName,
    required String targetAccountName,
    required double amount,
    String currency = 'CNY',
  }) {
    return ClientStateMutation(
      uiMode: 'direct_execute',
      toolName: 'execute_transfer',
      toolParams: {
        'surface_id': surfaceId,
        'source_account_id': sourceAccountId,
        'target_account_id': targetAccountId,
        'source_account_name': sourceAccountName,
        'target_account_name': targetAccountName,
        // 8 decimal places to match backend Decimal(20,8) precision contract
        'amount': amount.toStringAsFixed(8),
        'currency': currency,
      },
    );
  }

  /// Quick creation for space association (direct_execute)
  static ClientStateMutation forSpaceAssociation({
    String? surfaceId,
    required int spaceId,
    required List<String> transactionIds,
  }) {
    return ClientStateMutation(
      uiMode: 'direct_execute',
      toolName: 'associate_transactions_to_space',
      toolParams: {
        'surface_id': surfaceId,
        'space_id': spaceId,
        'transaction_ids': transactionIds,
      },
    );
  }
}

extension ClientStateMutationX on ClientStateMutation {
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    if (uiMode != null) {
      result['ui_mode'] = uiMode;
    }
    if (toolName != null) {
      result['tool_name'] = toolName;
    }
    if (toolParams != null) {
      result['tool_params'] = toolParams;
    }
    return result;
  }

  bool get isEmpty => uiMode == null && toolName == null;
}
