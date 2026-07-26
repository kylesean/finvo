import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:augo/i18n/strings.g.dart';
import '../../models/shared_space_models.dart';
import '../../services/shared_space_service.dart';
import '../../../../shared/services/toast_service.dart';

/// Bottom sheet that generates and displays an invite code for a shared space.
class SpaceInviteCodeSheet extends ConsumerStatefulWidget {
  final SharedSpace space;

  const SpaceInviteCodeSheet({super.key, required this.space});

  @override
  ConsumerState<SpaceInviteCodeSheet> createState() =>
      _SpaceInviteCodeSheetState();
}

class _SpaceInviteCodeSheetState extends ConsumerState<SpaceInviteCodeSheet> {
  InviteCode? _inviteCode;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_generateInviteCode());
  }

  Future<void> _generateInviteCode() async {
    try {
      final service = ref.read(sharedSpaceServiceProvider);
      final inviteCode = await service.generateInviteCode(widget.space.id);
      if (mounted) {
        setState(() {
          _inviteCode = inviteCode;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SpaceInviteCodeSheet] Error: $e');
      if (mounted) {
        setState(() {
          _error = t.sharedSpace.detail.loadFailed;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.muted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            t.sharedSpace.detail.inviteCode,
            style: theme.typography.body.xl.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.sharedSpace.join.subtitle,
            style: theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Column(
              children: [
                Icon(
                  FLucideIcons.circleAlert,
                  size: 48,
                  color: colors.mutedForeground,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                FButton(
                  variant: .outline,
                  onPress: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    unawaited(_generateInviteCode());
                  },
                  child: Text(t.sharedSpace.detail.retry),
                ),
              ],
            )
          else if (_inviteCode != null)
            Column(
              children: [
                // Invite code display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        t.sharedSpace.detail.inviteCode,
                        style: theme.typography.body.sm.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _inviteCode!.code,
                        style: theme.typography.body.xl3.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.sharedSpace.detail.validFor24h,
                        style: theme.typography.body.xs.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Copy button
                FButton(
                  variant: .primary,
                  onPress: () {
                    unawaited(
                      Clipboard.setData(ClipboardData(text: _inviteCode!.code)),
                    );
                    ToastService.show(
                      description: Text(
                        t.sharedSpace.detail.codeCopied(
                          code: _inviteCode!.code,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FLucideIcons.copy, size: 16),
                      const SizedBox(width: 8),
                      Text(t.sharedSpace.detail.copyCode),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
