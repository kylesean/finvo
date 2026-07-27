import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/i18n/strings.g.dart';
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
                        t.sharedSpace.inviteCard.title,
                        style: theme.typography.body.lg.copyWith(
                          fontWeight: AppFontConfig.bodyMedium,
                        ),
                      ),
                      Text(
                        t.sharedSpace.inviteCard.subtitle,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FLucideIcons.copy, size: 16),
                        const SizedBox(width: 8),
                        Text(t.sharedSpace.inviteCard.copyCode),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FButton(
                    onPress: () => _shareInviteLink(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FLucideIcons.share, size: 16),
                        const SizedBox(width: 8),
                        Text(t.sharedSpace.inviteCard.shareLink),
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
    if (expiresAt == null) return t.sharedSpace.inviteCard.noExpiry;
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return t.sharedSpace.inviteCard.expired;
    }

    if (difference.inDays > 0) {
      return t.sharedSpace.inviteCard.expiresInDays(days: difference.inDays);
    } else if (difference.inHours > 0) {
      return t.sharedSpace.inviteCard.expiresInHours(hours: difference.inHours);
    } else if (difference.inMinutes > 0) {
      return t.sharedSpace.inviteCard.expiresInMinutes(
        minutes: difference.inMinutes,
      );
    } else {
      return t.sharedSpace.inviteCard.expiringSoon;
    }
  }

  void _copyInviteCode(BuildContext context) {
    unawaited(Clipboard.setData(ClipboardData(text: inviteCode.code)));
    ToastService.show(description: Text(t.sharedSpace.inviteCard.codeCopied));
  }

  void _shareInviteLink(BuildContext context) {
    final inviteLink = '$appScheme://join-space?code=${inviteCode.code}';
    final shareText = t.sharedSpace.inviteCard.shareText(
      spaceName: inviteCode.spaceName,
      code: inviteCode.code,
      link: inviteLink,
      expiry: _formatExpiryTime(inviteCode.expiresAt),
    );

    // ignore: deprecated_member_use
    unawaited(Share.share(shareText));
  }
}
