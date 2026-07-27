import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Account tile selector
///
/// Inline account selector based on FSelectTileGroup
/// Follows GenUI organisms layer spec, reusable by templates layer
class AccountTileSelector extends StatefulWidget {
  /// Account list, format: [{id, name, type?, subtitle?}, ...]
  final List<Map<String, dynamic>> accounts;

  /// Currently selected account ID
  final String? selectedId;

  /// Selection change callback
  final ValueChanged<String?>? onChanged;

  /// Whether to show "no account" option
  final bool showNoAccountOption;

  /// Text for "no account" option
  final String? noAccountText;

  /// Max height (scrollable when exceeded)
  final double? maxHeight;

  /// Whether disabled
  final bool enabled;

  const AccountTileSelector({
    super.key,
    required this.accounts,
    this.selectedId,
    this.onChanged,
    this.showNoAccountOption = true,
    this.noAccountText,
    this.maxHeight = 240,
    this.enabled = true,
  });

  @override
  State<AccountTileSelector> createState() => _AccountTileSelectorState();
}

class _AccountTileSelectorState extends State<AccountTileSelector> {
  late FMultiValueNotifier<String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = FMultiValueNotifier<String>.radio(widget.selectedId ?? '');
  }

  @override
  void didUpdateWidget(covariant AccountTileSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      final newValue = widget.selectedId ?? '';
      if (!_controller.contains(newValue)) {
        _controller.update(newValue, add: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final List<FSelectTile<String>> tiles = [];

    // "No account" option
    if (widget.showNoAccountOption) {
      tiles.add(
        FSelectTile<String>(
          title: Text(
            widget.noAccountText ?? t.chat.genui.transactionCard.noAccount,
            style: theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          suffix: Icon(FLucideIcons.x, size: 14, color: colors.mutedForeground),
          value: '',
          enabled: widget.enabled,
        ),
      );
    }

    // Account options
    for (final account in widget.accounts) {
      final id = account['id'] as String;
      final name = account['name'] as String;
      final type = account['type'] as String?;

      tiles.add(
        FSelectTile<String>(
          title: Text(
            name,
            style: theme.typography.body.sm.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: type != null
              ? Text(
                  _getAccountTypeDisplay(type),
                  style: theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                )
              : null,
          suffix: _buildAccountIcon(colors, type),
          value: id,
          enabled: widget.enabled,
        ),
      );
    }

    return FSelectTileGroup<String>(
      control: .managed(
        controller: _controller,
        onChange: (values) {
          widget.onChanged?.call(values.isEmpty ? null : values.first);
        },
      ),
      maxHeight: widget.maxHeight ?? 240,
      divider: FItemDivider.full,
      children: tiles,
    );
  }

  Widget _buildAccountIcon(FColors colors, String? type) {
    final icon = _getAccountIcon(type);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 14, color: colors.foreground),
    );
  }

  IconData _getAccountIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'CASH':
        return FLucideIcons.banknote;
      case 'BANK':
      case 'DEPOSIT':
        return FLucideIcons.building;
      case 'CREDIT_CARD':
        return FLucideIcons.creditCard;
      case 'ALIPAY':
      case 'WECHAT':
      case 'EWALLET':
        return FLucideIcons.smartphone;
      case 'INVESTMENT':
        return FLucideIcons.trendingUp;
      case 'RECEIVABLE':
        return FLucideIcons.arrowRightLeft;
      case 'LOAN':
        return FLucideIcons.landmark;
      default:
        return FLucideIcons.wallet;
    }
  }

  String _getAccountTypeDisplay(String type) {
    switch (type.toUpperCase()) {
      case 'CASH':
        return t.account.cash;
      case 'BANK':
      case 'DEPOSIT':
        return t.account.deposit;
      case 'CREDIT_CARD':
        return t.account.creditCard;
      case 'ALIPAY':
      case 'WECHAT':
      case 'EWALLET':
        return t.account.eWallet;
      case 'INVESTMENT':
        return t.account.investment;
      case 'LOAN':
        return t.account.loan;
      case 'RECEIVABLE':
        return t.account.receivable;
      case 'PAYABLE':
        return t.account.payable;
      default:
        return type;
    }
  }
}
