import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/features/shared_space/services/shared_space_service.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:logging/logging.dart';

final _logger = Logger('SpaceInviteCodeSheet');

/// Bottom sheet that shows the current space's invite code so members can
/// share it with friends.
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
    _tryUseCachedCode();
  }

  /// Try to use the cached invite code from the space model first.
  /// Only calls the API if no valid cached code exists AND user can manage.
  void _tryUseCachedCode() {
    final cached = widget.space.currentInviteCode;
    final expiresAt = widget.space.inviteCodeExpiresAt;
    if (cached != null &&
        expiresAt != null &&
        expiresAt.isAfter(DateTime.now())) {
      setState(() {
        _inviteCode = InviteCode(
          code: cached,
          spaceId: widget.space.id,
          spaceName: widget.space.name,
          expiresAt: expiresAt,
        );
        _isLoading = false;
      });
    } else if (widget.space.canGenerateInvite) {
      // Only OWNER/ADMIN can generate a new code
      unawaited(_generateInviteCode());
    } else {
      // Regular member: no valid code exists and cannot generate
      setState(() {
        _isLoading = false;
        _error = t.sharedSpace.detail.loadFailed;
      });
    }
  }

  Future<void> _generateInviteCode() async {
    try {
      final service = ref.read(sharedSpaceServiceProvider);
      final inviteCode = await service.generateInviteCode(widget.space.id);
      if (mounted) {
        setState(() {
          _inviteCode = inviteCode;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      _logger.severe('Failed to load invite code', e);
      if (mounted) {
        setState(() {
          _error = t.sharedSpace.detail.loadFailed;
          _isLoading = false;
        });
      }
    }
  }

  void _copyCode() {
    final code = _inviteCode?.code;
    if (code == null) return;
    unawaited(Clipboard.setData(ClipboardData(text: code)));
    ToastService.show(
      description: Text(t.sharedSpace.detail.codeCopied(code: code)),
    );
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
      child: SafeArea(
        child: Padding(
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
                style: AppTextStyles.pageTitleLarge(theme),
              ),
              const SizedBox(height: 24),

              // Invite code content
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Column(
                  children: [
                    Icon(
                      FLucideIcons.circleAlert,
                      size: 40,
                      color: colors.mutedForeground,
                    ),
                    const SizedBox(height: 12),
                    Text(_error!, style: AppTextStyles.listSubtitle(theme)),
                    const SizedBox(height: 12),
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
                            _inviteCode!.code,
                            style: AppTextStyles.actionText(
                              theme,
                            ).copyWith(letterSpacing: 4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.sharedSpace.detail.validFor24h,
                            style: AppTextStyles.detailLabel(theme),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Copy + Refresh buttons
                    Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: .primary,
                            onPress: _copyCode,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FLucideIcons.copy, size: 16),
                                const SizedBox(width: 8),
                                Text(t.sharedSpace.detail.copyCode),
                              ],
                            ),
                          ),
                        ),
                        // Refresh button - only for OWNER/ADMIN
                        if (widget.space.canGenerateInvite) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: FButton(
                              variant: .outline,
                              onPress: () {
                                setState(() {
                                  _isLoading = true;
                                  _error = null;
                                });
                                unawaited(_generateInviteCode());
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(FLucideIcons.refreshCw, size: 16),
                                  const SizedBox(width: 8),
                                  Text(t.sharedSpace.detail.refreshCode),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
