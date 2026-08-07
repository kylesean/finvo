// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/chat/services/genui_cache_service.dart';
import 'package:finvo/features/chat/genui/events/interaction_events.dart';
import 'package:finvo/features/chat/genui/organisms/organisms.dart';
import 'package:finvo/shared/widgets/app_card.dart';

/// Submission cache
class _ConfirmationCache {
  static const String _cacheCategory = 'transaction_confirmation';

  static void markConfirmed(String surfaceId, String? accountId) {
    GenUiCacheService().put(_cacheCategory, surfaceId, accountId);
  }

  static bool isConfirmed(String surfaceId) =>
      GenUiCacheService().containsKey(_cacheCategory, surfaceId);

  static String? getAccountId(String surfaceId) =>
      GenUiCacheService().get<String>(_cacheCategory, surfaceId);
}

/// Transaction confirmation - account selection
///
/// @deprecated This component is deprecated (2024-12).
/// The backend tool `request_transaction_confirmation` has been removed.
/// Adopting a "record first, link account later" design pattern:
/// - Users record transactions directly (using create_transaction without account_id)
/// - Users can link accounts later in transaction details
///
/// This component is retained only to support historical data rendering.
@Deprecated(
  'Use create_transaction without account_id, then link account in transaction details',
)
class TransactionConfirmation extends StatefulWidget {
  final Map<String, dynamic> data;
  final void Function(UiEvent) dispatchEvent;

  const TransactionConfirmation({
    super.key,
    required this.data,
    required this.dispatchEvent,
  });

  @override
  State<TransactionConfirmation> createState() =>
      _TransactionConfirmationState();
}

class _TransactionConfirmationState extends State<TransactionConfirmation> {
  String? _selectedAccountId;
  bool _isConfirmed = false;

  bool get _isHistorical => widget.data['_isHistorical'] == true;
  String get _surfaceId => widget.data['_surfaceId']?.toString() ?? 'unknown';

  @override
  void initState() {
    super.initState();

    // Check cache
    if (_ConfirmationCache.isConfirmed(_surfaceId)) {
      _isConfirmed = true;
      _selectedAccountId = _ConfirmationCache.getAccountId(_surfaceId);
      return;
    }

    _selectedAccountId = widget.data['preselected_account_id']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final accountsRaw = widget.data['available_accounts'];
    final accounts = accountsRaw is List ? accountsRaw : const <dynamic>[];

    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final accountMaps = accounts
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    // Whether disabled: confirmed or historical mode
    final isDisabled = _isConfirmed || _isHistorical;

    final isIncome =
        (widget.data['transaction_type'] as String?)?.toUpperCase() == 'INCOME';
    final titleText = isIncome
        ? t.chat.transferWizard.selectReceiveAccount
        : t.chat.transferWizard.selectAccount;

    return AppCard(
      style: const .delta(padding: .value(EdgeInsets.zero)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AccountPickerCard(
          accounts: accountMaps,
          selectedId: _selectedAccountId,
          title: titleText,
          subtitle: isDisabled
              ? null
              : t.chat.genui.transactionConfirmation.multipleAccounts,
          confirmText: isDisabled
              ? t.chat.genui.transactionConfirmation.confirmed
              : t.common.confirm,
          enabled: !isDisabled,
          onSelect: isDisabled
              ? null
              : (id) {
                  setState(() {
                    _selectedAccountId = id;
                  });
                },
          onConfirm: isDisabled ? null : _onConfirm,
        ),
      ),
    );
  }

  void _onConfirm() {
    if (_isConfirmed) return;

    setState(() {
      _isConfirmed = true;
    });

    _ConfirmationCache.markConfirmed(_surfaceId, _selectedAccountId);

    String? accountName;
    if (_selectedAccountId != null) {
      final accountsRaw = widget.data['available_accounts'];
      final accounts = accountsRaw is List ? accountsRaw : const <dynamic>[];
      accountName = _getAccountName(_selectedAccountId!, accounts);
    }

    widget.dispatchEvent(
      TransactionConfirmedWithAccountEvent(
        accountId: _selectedAccountId,
        accountName: accountName,
        amount: widget.data['amount'],
        description: widget.data['description']?.toString(),
        transactionType: widget.data['transaction_type']?.toString(),
        categoryKey: widget.data['category_key']?.toString(),
        currency: widget.data['currency']?.toString(),
        rawInput: widget.data['raw_input']?.toString(),
        tags: widget.data['tags'] is List ? widget.data['tags'] as List : null,
      ).toUserActionEvent(sourceComponentId: 'TransactionConfirmation'),
    );
  }

  String _getAccountName(String accountId, List<dynamic> accounts) {
    for (final acc in accounts) {
      if (acc is! Map) continue;
      final accMap = Map<String, dynamic>.from(acc);
      if (accMap['id']?.toString() == accountId) {
        return accMap['name']?.toString() ??
            t.chat.genui.transactionCard.noAccount;
      }
    }
    return t.chat.genui.transactionCard.noAccount;
  }
}
