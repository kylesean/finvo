import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../molecules/molecules.dart';

/// Account selection sheet (bottom sheet)
///
/// Reusable account selection sheet, tap to select and dismiss
class AccountSelectSheet extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> accounts;
  final String? selectedId;

  const AccountSelectSheet({
    super.key,
    required this.title,
    required this.accounts,
    this.selectedId,
  });

  /// Show account selection sheet
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> accounts,
    String? selectedId,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (ctx) => AccountSelectSheet(
        title: title,
        accounts: accounts,
        selectedId: selectedId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top drag indicator
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: colors.muted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.foreground,
                    ),
                  ),
                ),
                FFancyButton.icon(
                  onPress: () => Navigator.pop(context),
                  child: Icon(
                    FLucideIcons.x,
                    size: 20,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Account list
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: accounts.map((account) {
                  final id = account['id'] as String;
                  final isSelected = id == selectedId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AccountCard(
                      data: account,
                      selected: isSelected,
                      onTap: () => Navigator.pop(context, id),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Since FButton may not have a convenient icon constructor for header use, use basic styling
class FFancyButton extends StatelessWidget {
  final VoidCallback onPress;
  final Widget child;

  const FFancyButton.icon({
    super.key,
    required this.onPress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
