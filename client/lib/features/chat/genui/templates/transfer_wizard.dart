import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/chat/genui/organisms/organisms.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/chat/services/genui_cache_service.dart';
import 'package:finvo/features/chat/genui/events/interaction_events.dart';
import 'package:finvo/features/chat/constants/genui_markers.dart';
import 'package:finvo/features/chat/models/chat_message.dart' as app;
import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:decimal/decimal.dart';

/// Transfer wizard data model (Data Layer)
class TransferWizardData {
  final Decimal amount;
  final String currency;
  final List<Map<String, dynamic>> sourceAccounts;
  final List<Map<String, dynamic>> targetAccounts;
  final String? preselectedSourceId;
  final String? preselectedTargetId;
  final String memo;

  /// LLM-generated tags extracted from the user's message (e.g. ["转账"]),
  /// persisted on the created transaction.
  final List<String> tags;

  /// Guidance code for the empty state when transfers are not possible:
  /// "NO_ACCOUNTS" (no asset accounts) | "SINGLE_ACCOUNT" (only one asset
  /// account) | null (wizard fully usable). Never a failure — the UI renders a
  /// friendly guidance card instead of an error.
  final String? guidance;
  final String surfaceId;
  final bool isHistorical;
  final bool isConfirmed;

  TransferWizardData({
    required this.amount,
    required this.currency,
    required this.sourceAccounts,
    required this.targetAccounts,
    this.preselectedSourceId,
    this.preselectedTargetId,
    this.memo = '',
    this.tags = const [],
    this.guidance,
    required this.surfaceId,
    this.isHistorical = false,
    this.isConfirmed = false,
  });

  factory TransferWizardData.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> coerceAccounts(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final amount = AmountFormatter.parseDecimal(json['amount']?.toString());
    final rawTags = json['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).where((t) => t.isNotEmpty).toList()
        : <String>[];

    return TransferWizardData(
      amount: amount,
      currency: json['currency']?.toString() ?? 'CNY',
      sourceAccounts: coerceAccounts(json['sourceAccounts']),
      targetAccounts: coerceAccounts(json['targetAccounts']),
      preselectedSourceId: json['preselectedSourceId']?.toString(),
      preselectedTargetId: json['preselectedTargetId']?.toString(),
      memo: json['memo']?.toString() ?? '',
      tags: tags,
      guidance: json['guidance']?.toString(),
      surfaceId: json['_surfaceId']?.toString() ?? 'unknown',
      isHistorical: json['_isHistorical'] == true,
      isConfirmed: json['isConfirmed'] == true || json['_isHistorical'] == true,
    );
  }
}

class TransferWizard extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final void Function(UiEvent) dispatchEvent;

  const TransferWizard({
    super.key,
    required this.data,
    required this.dispatchEvent,
  });

  @override
  ConsumerState<TransferWizard> createState() => _TransferWizardState();
}

/// State cache upon user confirmation
class _ConfirmedState {
  final String? sourceId;
  final String? targetId;
  final String amount;

  const _ConfirmedState({
    required this.sourceId,
    required this.targetId,
    required this.amount,
  });
}

class _TransferWizardState extends ConsumerState<TransferWizard> {
  static const String _cacheCategory = 'transfer_wizard';

  late TransferWizardData _model;
  late TextEditingController _amountController;
  String? _sourceId;
  String? _targetId;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _model = TransferWizardData.fromJson(widget.data);

    // Prefer restoring confirmed state from cache (fixes state loss on widget rebuild)
    final cachedState = GenUiCacheService().get<_ConfirmedState>(
      _cacheCategory,
      _model.surfaceId,
    );
    if (cachedState != null) {
      _sourceId = cachedState.sourceId;
      _targetId = cachedState.targetId;
      _amountController = TextEditingController(text: cachedState.amount);
      _isConfirmed = true;
    } else if (_model.isConfirmed) {
      // Historical load scenario: restore from backend backfilled data
      _sourceId = _model.preselectedSourceId;
      _targetId = _model.preselectedTargetId;
      _amountController = TextEditingController(
        text: _model.amount > Decimal.zero
            ? _model.amount.toStringAsFixed(2)
            : '',
      );
      _isConfirmed = true;
    } else {
      // Initialize with original data
      _sourceId = _model.preselectedSourceId;
      _targetId = _model.preselectedTargetId;
      _amountController = TextEditingController(
        text: _model.amount > Decimal.zero
            ? _model.amount.toStringAsFixed(2)
            : '',
      );

      if (_model.isHistorical) {
        _isConfirmed = true;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_sourceId == null || _targetId == null) return false;
    if (_sourceId == _targetId) return false;
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount > 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    // Insufficient accounts: render a friendly guidance card instead of an
    // unusable wizard. The backend never fails the transfer on this — it is a
    // state that needs the user to add asset accounts first.
    if (_model.guidance != null ||
        _model.sourceAccounts.isEmpty ||
        _model.targetAccounts.isEmpty) {
      return _buildGuidanceState(theme, colors);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.foreground.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(theme, colors),
              const SizedBox(height: 24),

              // Amount Section
              _buildAmountSection(theme, colors),
              const SizedBox(height: 24),

              // Account Path Section
              _buildTransferPath(context, theme, colors),
              const SizedBox(height: 32),

              // Action Button
              _buildConfirmButton(theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  /// Friendly guidance card for when a transfer can't be started yet (no asset
  /// accounts, or fewer than two). Shown instead of the unusable wizard so the
  /// user gets actionable guidance rather than a failed-operation tool block.
  Widget _buildGuidanceState(FThemeData theme, FColors colors) {
    final isSingle = _model.guidance == 'SINGLE_ACCOUNT';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.foreground.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(theme, colors),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FLucideIcons.wallet,
                        color: colors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSingle
                          ? t.chat.transferWizard.needTwoAssetAccounts
                          : t.chat.transferWizard.noAssetAccounts,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: AppFontConfig.headingBold,
                        color: colors.foreground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FButton(
                      onPress: () => context.goNamed(AppRouteNames.finance),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FLucideIcons.walletCards, size: 16),
                          const SizedBox(width: 8),
                          Text(t.chat.transferWizard.goToFinanceToAddAccounts),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FThemeData theme, FColors colors) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            FLucideIcons.arrowRightLeft,
            color: colors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          t.chat.transferWizard.title,
          style: theme.typography.body.lg.copyWith(
            fontWeight: AppFontConfig.headingBold,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        if (_isConfirmed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.semantic.successBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FLucideIcons.check,
                  color: theme.semantic.successAccent,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  t.chat.transferWizard.confirmed,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.semantic.successAccent,
                    fontWeight: AppFontConfig.headingBold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAmountSection(FThemeData theme, FColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.chat.transferWizard.amount,
            style: AppTextStyles.detailLabel(theme),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AmountFormatter.getCurrencySymbol(_model.currency),
                style: theme.typography.body.xl.copyWith(
                  color: colors.primary,
                  fontWeight: AppFontConfig.amountBold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _isConfirmed
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _amountController.text.isEmpty
                              ? '0.00'
                              : _amountController.text,
                          style: theme.typography.body.xl.copyWith(
                            fontWeight: AppFontConfig.amountBold,
                            color: colors.foreground,
                            letterSpacing: -1,
                          ),
                        ),
                      )
                    : TextField(
                        controller: _amountController,
                        enabled: !_isConfirmed,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: theme.typography.body.xl.copyWith(
                            color: colors.mutedForeground.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: theme.typography.body.xl.copyWith(
                          fontWeight: AppFontConfig.amountBold,
                          color: colors.foreground,
                          letterSpacing: -1,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferPath(
    BuildContext context,
    FThemeData theme,
    FColors colors,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 2. Base card layer
        Column(
          children: [
            _buildAccountItem(
              context,
              label: t.chat.transferWizard.sourceAccount,
              accountId: _sourceId,
              accounts: _model.sourceAccounts,
              onSelect: (id) => setState(() => _sourceId = id),
              theme: theme,
              colors: colors,
              isSource: true,
            ),
            const SizedBox(height: 12),
            _buildAccountItem(
              context,
              label: t.chat.transferWizard.targetAccount,
              accountId: _targetId,
              accounts: _model.targetAccounts,
              onSelect: (id) => setState(() => _targetId = id),
              theme: theme,
              colors: colors,
              isSource: false,
            ),
          ],
        ),

        // 3. Featured interaction: center overlapping circle
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isConfirmed ? colors.primary : colors.foreground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.foreground.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            _isConfirmed ? FLucideIcons.check : FLucideIcons.arrowDown,
            size: 16,
            color: _isConfirmed ? colors.primaryForeground : colors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountItem(
    BuildContext context, {
    required String label,
    required String? accountId,
    required List<Map<String, dynamic>> accounts,
    required void Function(String) onSelect,
    required FThemeData theme,
    required FColors colors,
    required bool isSource,
  }) {
    final account = _getAccount(accountId, accounts);

    return GestureDetector(
      onTap: _isConfirmed
          ? null
          : () async {
              final result = await AccountSelectSheet.show(
                context: context,
                title: label,
                accounts: accounts,
                selectedId: accountId,
              );
              if (result != null && mounted) onSelect(result);
            },
      child: Row(
        children: [
          // Restore: left-side inherent icon circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSource
                  ? colors.primary.withValues(alpha: 0.1)
                  : colors.foreground.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSource
                    ? colors.primary.withValues(alpha: 0.3)
                    : colors.border,
                width: 2,
              ),
            ),
            child: Icon(
              isSource ? FLucideIcons.logOut : FLucideIcons.logIn,
              size: 18,
              color: isSource ? colors.primary : colors.mutedForeground,
            ),
          ),
          const SizedBox(width: 16),
          // Card body
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colors.muted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accountId == null
                      ? colors.border.withValues(alpha: 0.5)
                      : colors.foreground.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTextStyles.detailLabel(theme)),
                        const SizedBox(height: 2),
                        Text(
                          account?['name']?.toString() ??
                              t.chat.transferWizard.selectAccount,
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: AppFontConfig.headingBold,
                            color: accountId == null
                                ? colors.mutedForeground
                                : colors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isConfirmed)
                    Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: colors.mutedForeground.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(FThemeData theme, FColors colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      child: FButton(
        onPress: _isValid && !_isConfirmed ? _onConfirm : null,
        variant: _isConfirmed ? .outline : .primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isConfirmed) ...[
              const Icon(FLucideIcons.send, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              _isConfirmed
                  ? t.chat.transferWizard.confirmed
                  : t.chat.transferWizard.confirmTransfer,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _getAccount(
    String? id,
    List<Map<String, dynamic>> accounts,
  ) {
    if (id == null) return null;
    for (final account in accounts) {
      if (account['id'] == id) return account;
    }
    return null;
  }

  void _onConfirm() {
    setState(() => _isConfirmed = true);
    final finalAmount =
        Decimal.tryParse(_amountController.text) ?? Decimal.zero;

    // Save user selection to cache to prevent state loss on widget rebuild
    GenUiCacheService().put(
      _cacheCategory,
      _model.surfaceId,
      _ConfirmedState(
        sourceId: _sourceId,
        targetId: _targetId,
        amount: _amountController.text,
      ),
    );

    // Get account names for backend TransferReceipt component display
    final sourceAccount = _getAccount(_sourceId, _model.sourceAccounts);
    final targetAccount = _getAccount(_targetId, _model.targetAccounts);
    final sourceAccountName =
        sourceAccount?['name']?.toString() ??
        t.chat.transferWizard.sourceAccount;
    final targetAccountName =
        targetAccount?['name']?.toString() ??
        t.chat.transferWizard.targetAccount;

    widget.dispatchEvent(
      TransferPathConfirmedEvent(
        surfaceId: _model.surfaceId,
        sourceAccountId: _sourceId ?? '',
        targetAccountId: _targetId ?? '',
        sourceAccountName: sourceAccountName,
        targetAccountName: targetAccountName,
        amount: finalAmount,
        currency: _model.currency,
        memo: _model.memo,
        tags: _model.tags,
        // Preserve the user's original input that triggered this transfer
        // (e.g. "转账") so the created transaction keeps its real raw input.
        rawInput: _resolveUserRawInput(),
      ).toUserActionEvent(sourceComponentId: 'TransferWizard'),
    );
  }

  /// The user's latest plain-text message in the conversation is the original
  /// input that triggered this transfer (e.g. "转账"). Genui-internal marker
  /// messages (the auto-generated confirm text) are excluded.
  String? _resolveUserRawInput() {
    try {
      final messages = ref.read(chatHistoryProvider).messages;
      for (final msg in messages.reversed) {
        if (msg.sender != app.MessageSender.user) continue;
        final text = msg.content.trim();
        if (text.isEmpty || text.startsWith(genuiInternalMarker)) continue;
        return text;
      }
    } catch (_) {
      // Provider unavailable (e.g. isolated render) — treat as no raw input.
    }
    return null;
  }
}
