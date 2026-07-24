import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:augo/app/theme/app_font_config.dart';
import '../models/shared_space_models.dart';
import '../../../shared/services/toast_service.dart';
import 'dart:async';

class InviteCodeCard extends StatelessWidget {
  final InviteCode inviteCode;
  final String appScheme;

  const InviteCodeCard({
    super.key,
    required this.inviteCode,
    this.appScheme = 'yourapp', // Can be obtained from config
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Invite code title
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    FLucideIcons.qrCode,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite Code',
                        style: theme.typography.body.lg.copyWith(
                          fontWeight: AppFontConfig.bodyMedium,
                        ),
                      ),
                      Text(
                        'Share with friends to join the space',
                        style: theme.typography.body.sm.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Invite code display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.muted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.border, width: 1),
              ),
              child: Column(
                children: [
                  // Invite code
                  Text(
                    inviteCode.code,
                    style: theme.typography.body.xl2.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FLucideIcons.clock,
                        size: 14,
                        color: colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatExpiryTime(inviteCode.expiresAt),
                        style: theme.typography.body.sm.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FButton(
                    variant: .outline,
                    onPress: () => _copyInviteCode(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FLucideIcons.copy, size: 16),
                        SizedBox(width: 8),
                        Text('Copy Invite Code'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FButton(
                    onPress: () => _shareInviteLink(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FLucideIcons.share, size: 16),
                        SizedBox(width: 8),
                        Text('Share Invite Link'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiryTime(DateTime? expiresAt) {
    if (expiresAt == null) return 'No expiry';
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 0) {
      return 'Expires in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'Expires in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'Expires in ${difference.inMinutes} minutes';
    } else {
      return 'Expiring soon';
    }
  }

  void _copyInviteCode(BuildContext context) {
    unawaited(Clipboard.setData(ClipboardData(text: inviteCode.code)));
    ToastService.show(description: const Text('Invite code copied'));
  }

  void _shareInviteLink(BuildContext context) {
    final inviteLink = '$appScheme://join-space?code=${inviteCode.code}';
    final shareText =
        'You are invited to join the shared space "${inviteCode.spaceName}"\n\n'
        'Invite code: ${inviteCode.code}\n'
        'Or click the link to join directly: $inviteLink\n\n'
        'Invite code ${_formatExpiryTime(inviteCode.expiresAt)}';

    // ignore: deprecated_member_use
    unawaited(Share.share(shareText));
  }
}
