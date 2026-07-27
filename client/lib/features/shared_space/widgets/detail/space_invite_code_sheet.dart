import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import '../../models/shared_space_models.dart';
import '../../services/shared_space_service.dart';
import '../../providers/shared_space_provider.dart';
import '../../../notification/providers/notification_provider.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../core/network/exceptions/app_exception.dart';

/// Bottom sheet that shows invite code for current space AND allows joining
/// another space via invite code.
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

  // Join space state
  final _joinCodeController = TextEditingController();
  bool _isJoining = false;
  String? _joinError;

  @override
  void initState() {
    super.initState();
    _tryUseCachedCode();
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
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
      debugPrint('[SpaceInviteCodeSheet] Error: $e');
      if (mounted) {
        setState(() {
          _error = t.sharedSpace.detail.loadFailed;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinSpace() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _joinError = t.sharedSpace.join.codeRequired);
      return;
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(code)) {
      setState(() => _joinError = t.sharedSpace.join.codeFormat);
      return;
    }

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      // Call service directly to get precise error messages
      final service = ref.read(sharedSpaceServiceProvider);
      final space = await service.joinSpaceWithCode(code);

      // Also update the provider's space list
      if (mounted) {
        unawaited(
          ref.read(sharedSpaceProvider.notifier).loadSpaces(refresh: true),
        );
        // Refresh notification badge (welcome notification was created)
        ref.invalidate(notificationProvider);
        // Pop the sheet first, then navigate to space detail
        Navigator.of(context).pop();
        ToastService.show(
          description: Text(t.sharedSpace.list.joinedSuccess(name: space.name)),
        );
        // Navigate to the newly joined space
        unawaited(
          GoRouter.of(context).push('/profile/shared-space/${space.id}'),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _joinError = e.message;
          _isJoining = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _joinError = t.sharedSpace.detail.loadFailed;
          _isJoining = false;
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
      child: SafeArea(
        child: SingleChildScrollView(
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

              // ===== Section 1: Current space invite code =====
              Text(
                t.sharedSpace.detail.inviteCode,
                style: theme.typography.body.xl.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.sharedSpace.inviteCard.subtitle,
                style: theme.typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),

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
                    Text(
                      _error!,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
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
                    // Copy + Refresh buttons
                    Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: .primary,
                            onPress: () {
                              unawaited(
                                Clipboard.setData(
                                  ClipboardData(text: _inviteCode!.code),
                                ),
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

              const SizedBox(height: 24),

              // ===== Divider =====
              Row(
                children: [
                  Expanded(child: Divider(color: colors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      t.sharedSpace.detail.joinOtherSpace,
                      style: theme.typography.body.xs.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.border)),
                ],
              ),

              const SizedBox(height: 20),

              // ===== Section 2: Join another space =====
              FTextField(
                control: .managed(
                  controller: _joinCodeController,
                  onChange: (value) {
                    if (_joinError != null) {
                      setState(() => _joinError = null);
                    }
                    final upper = value.text.toUpperCase();
                    if (upper != value.text) {
                      _joinCodeController.value = _joinCodeController.value
                          .copyWith(
                            text: upper,
                            selection: TextSelection.collapsed(
                              offset: upper.length,
                            ),
                          );
                    }
                  },
                ),
                label: Text(t.sharedSpace.join.codeLabel),
                hint: t.sharedSpace.join.codeHint,
              ),
              if (_joinError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      _joinError!,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.destructive,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FButton(
                variant: .outline,
                onPress: _isJoining ? null : _joinSpace,
                child: _isJoining
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FLucideIcons.logIn, size: 16),
                          const SizedBox(width: 8),
                          Text(t.sharedSpace.join.submit),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
