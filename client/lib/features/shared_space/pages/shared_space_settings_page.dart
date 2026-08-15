import 'dart:async';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/features/shared_space/providers/shared_space_provider.dart';
import 'package:finvo/features/shared_space/services/shared_space_service.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:finvo/shared/models/action_item_model.dart';
import 'package:finvo/shared/widgets/dialogs/action_bottom_sheet.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:logging/logging.dart';

final _logger = Logger('SharedSpaceSettings');

class SharedSpaceSettingsPage extends ConsumerStatefulWidget {
  final String spaceId;

  const SharedSpaceSettingsPage({super.key, required this.spaceId});

  @override
  ConsumerState<SharedSpaceSettingsPage> createState() =>
      _SharedSpaceSettingsPageState();
}

class _SharedSpaceSettingsPageState
    extends ConsumerState<SharedSpaceSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _initControllers(SharedSpace space) {
    if (_nameController.text.isEmpty && !_isEditing) {
      _nameController.text = space.name;
      _descController.text = space.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final spaceAsync = ref.watch(spaceDetailProvider(widget.spaceId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          t.sharedSpace.settings.title,
          style: theme.typography.body.xl,
        ),
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
        centerTitle: true,
        leading: FButton.icon(
          variant: .ghost,
          onPress: () => context.pop(),
          child: Icon(
            FLucideIcons.chevronLeft,
            color: colors.foreground,
            size: 20,
          ),
        ),
      ),
      body: spaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.circleAlert,
                size: 48,
                color: colors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                t.sharedSpace.detail.loadFailed,
                style: theme.typography.body.lg,
              ),
              const SizedBox(height: 16),
              FButton(
                variant: .outline,
                onPress: () =>
                    ref.invalidate(spaceDetailProvider(widget.spaceId)),
                child: Text(t.sharedSpace.detail.retry),
              ),
            ],
          ),
        ),
        data: (space) {
          _initControllers(space);
          return _buildSettingsContent(context, space);
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, SharedSpace space) {
    final theme = context.theme;
    final colors = theme.colors;
    final currentUser = ref.watch(currentUserProvider);
    // Single source of truth: the server-provided role on the space object
    // (SharedSpacePermissions extension) rather than re-deriving from members.
    final canEdit = space.canManage;
    final isOwner = space.isOwner;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section: Space Info
        _buildSectionHeader(theme, t.sharedSpace.settings.spaceInfo),
        const SizedBox(height: 8),
        _buildSpaceInfoSection(theme, colors, space, canEdit),
        const SizedBox(height: 24),

        // Section: Member Management
        _buildSectionHeader(theme, t.sharedSpace.settings.memberManagement),
        const SizedBox(height: 8),
        _buildMemberSection(theme, colors, space, canEdit, currentUser?.id),
        const SizedBox(height: 24),

        // Section: Danger Zone
        _buildSectionHeader(theme, t.sharedSpace.settings.dangerZone),
        const SizedBox(height: 8),
        _buildDangerZone(theme, colors, space, isOwner),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(FThemeData theme, String title) {
    return Text(
      title,
      style: theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colors.mutedForeground,
      ),
    );
  }

  // ==================== Space Info Section ====================

  Widget _buildSpaceInfoSection(
    FThemeData theme,
    FColors colors,
    SharedSpace space,
    bool canEdit,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: theme.style.borderRadius.md,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          Text(
            t.sharedSpace.settings.nameLabel,
            style: AppTextStyles.listSubtitle(theme),
          ),
          const SizedBox(height: 8),
          FTextField(
            control: .managed(controller: _nameController),
            enabled: _isEditing && canEdit,
            hint: t.sharedSpace.create.nameHint,
          ),
          const SizedBox(height: 16),

          // Description field
          Text(
            t.sharedSpace.settings.descLabel,
            style: AppTextStyles.listSubtitle(theme),
          ),
          const SizedBox(height: 8),
          FTextField(
            control: .managed(controller: _descController),
            enabled: _isEditing && canEdit,
            hint: t.sharedSpace.create.descHint,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Action buttons
          if (!canEdit)
            Text(
              t.sharedSpace.settings.editHint,
              style: AppTextStyles.detailLabel(theme),
            )
          else if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: FButton(
                    variant: .outline,
                    onPress: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = space.name;
                        _descController.text = space.description ?? '';
                      });
                    },
                    child: Text(t.sharedSpace.create.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FButton(
                    onPress: () => _saveSpaceInfo(space),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.sharedSpace.settings.save),
                  ),
                ),
              ],
            )
          else
            FButton(
              variant: .outline,
              onPress: () => setState(() => _isEditing = true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FLucideIcons.pencil, size: 16),
                  const SizedBox(width: 8),
                  Text(t.sharedSpace.settings.edit),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveSpaceInfo(SharedSpace space) async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      ToastService.showDestructive(
        description: Text(t.sharedSpace.create.nameTooShort),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final success = await ref
          .read(sharedSpaceProvider.notifier)
          .updateSpace(
            space.id,
            name: name,
            description: _descController.text.trim(),
          );
      if (success) {
        ref.invalidate(spaceDetailProvider(widget.spaceId));
        setState(() => _isEditing = false);
        ToastService.show(description: Text(t.sharedSpace.settings.saved));
      } else {
        ToastService.showDestructive(
          description: Text(t.sharedSpace.settings.saveFailed),
        );
      }
    } catch (e) {
      _logger.warning('Failed to save space settings', e);
      ToastService.showDestructive(
        description: Text(t.sharedSpace.settings.saveFailed),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ==================== Member Section ====================

  Widget _buildMemberSection(
    FThemeData theme,
    FColors colors,
    SharedSpace space,
    bool canManage,
    String? currentUserId,
  ) {
    final members = space.members ?? [];
    final isOwner = space.isOwner;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: theme.style.borderRadius.md,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member count header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              t.sharedSpace.settings.membersCount(
                count: members
                    .where((m) => m.status == InviteStatus.accepted)
                    .length,
              ),
              style: AppTextStyles.detailLabel(theme),
            ),
          ),
          // Member list
          for (int i = 0; i < members.length; i++) ...[
            _buildMemberRow(
              theme,
              colors,
              members[i],
              canManage,
              isOwner,
              currentUserId,
              space,
            ),
            if (i < members.length - 1)
              Divider(height: 1, indent: 60, color: colors.border),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberRow(
    FThemeData theme,
    FColors colors,
    SharedSpaceMember member,
    bool canManage,
    bool isOwner,
    String? currentUserId,
    SharedSpace space,
  ) {
    final isMemberOwner = member.role == MemberRole.owner;
    final isCurrentUser = member.userId == currentUserId;
    final isAccepted = member.status == InviteStatus.accepted;
    final canActOn = canManage && !isMemberOwner && !isCurrentUser;

    return Opacity(
      opacity: isAccepted ? 1.0 : 0.5,
      child: InkWell(
        onTap: canActOn
            ? () => _showMemberActions(member, space, isOwner)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar - same as dashboard card
              UserAvatar(
                userId: member.userId,
                size: 36,
                border: Border.all(color: colors.background, width: 2),
              ),
              const SizedBox(width: 12),
              // Username + icons
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.username,
                        style: AppTextStyles.listTrailing(theme),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMemberOwner) ...[
                      const SizedBox(width: 6),
                      Icon(FLucideIcons.crown, size: 14, color: colors.primary),
                    ],
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Icon(
                        FLucideIcons.shieldCheck,
                        size: 14,
                        color: colors.mutedForeground,
                      ),
                    ],
                    if (!isAccepted) ...[
                      const SizedBox(width: 6),
                      Text(
                        member.status == InviteStatus.pending
                            ? t.sharedSpace.settings.pending
                            : t.sharedSpace.settings.declined,
                        style: theme.typography.body.xs.copyWith(
                          color: member.status == InviteStatus.pending
                              ? colors.primary.withValues(alpha: 0.7)
                              : colors.destructive.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Management indicator
              if (canActOn)
                Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: colors.mutedForeground.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberActions(
    SharedSpaceMember member,
    SharedSpace space,
    bool isOwner,
  ) {
    final actions = <ActionItem>[];
    final destructiveActions = <ActionItem>[];

    // Role change - owner only
    if (isOwner) {
      if (member.role == MemberRole.member) {
        actions.add(
          ActionItem(
            title: t.sharedSpace.settings.setAsAdmin,
            icon: FLucideIcons.shieldPlus,
            onTap: () => _confirmRoleChange(member, space, 'ADMIN'),
          ),
        );
      } else if (member.role == MemberRole.admin) {
        actions.add(
          ActionItem(
            title: t.sharedSpace.settings.setAsMember,
            icon: FLucideIcons.user,
            onTap: () => _confirmRoleChange(member, space, 'MEMBER'),
          ),
        );
      }
    }

    // Remove member
    destructiveActions.add(
      ActionItem(
        title: t.sharedSpace.detail.removeMember,
        icon: FLucideIcons.userMinus,
        isDestructive: true,
        onTap: () => _confirmRemoveMember(member, space),
      ),
    );

    // The root navigator context can be null right after a deep link or
    // shell branch switch; bail out instead of crashing on a `!` unwrap.
    final rootContext = GoRouter.of(
      context,
    ).routerDelegate.navigatorKey.currentContext;
    if (rootContext == null) return;

    unawaited(
      showModalBottomSheet<void>(
        context: rootContext,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) {
          return ActionBottomSheet(
            actions: actions,
            destructiveActions: destructiveActions,
          );
        },
      ),
    );
  }

  void _confirmRoleChange(
    SharedSpaceMember member,
    SharedSpace space,
    String newRole,
  ) {
    final roleLabel = newRole == 'ADMIN'
        ? t.sharedSpace.roles.admin
        : t.sharedSpace.roles.member;

    unawaited(
      showConfirmDialog(
        context: context,
        title: t.sharedSpace.settings.changeRole,
        message: t.sharedSpace.settings.changeRoleConfirm(
          name: member.username,
          role: roleLabel,
        ),
        cancelLabel: t.sharedSpace.create.cancel,
        confirmLabel: t.sharedSpace.settings.confirm,
        onConfirm: () async {
          unawaited(_updateRole(member, space, newRole));
        },
      ),
    );
  }

  Future<void> _updateRole(
    SharedSpaceMember member,
    SharedSpace space,
    String newRole,
  ) async {
    try {
      final service = ref.read(sharedSpaceServiceProvider);
      await service.updateMemberRole(space.id, member.userId, newRole);
      ref.invalidate(spaceDetailProvider(widget.spaceId));
      ToastService.show(description: Text(t.sharedSpace.settings.roleChanged));
    } catch (e) {
      _logger.warning('Failed to change member role', e);
      ToastService.showDestructive(
        description: Text(t.sharedSpace.settings.roleChangeFailed),
      );
    }
  }

  void _confirmRemoveMember(SharedSpaceMember member, SharedSpace space) {
    unawaited(
      showConfirmDialog(
        context: context,
        title: t.sharedSpace.detail.removeMember,
        message: t.sharedSpace.settings.removeMemberConfirm(
          name: member.username,
        ),
        cancelLabel: t.sharedSpace.create.cancel,
        confirmVariant: FButtonVariant.destructive,
        confirmLabel: t.sharedSpace.detail.removeMember,
        onConfirm: () async {
          unawaited(_removeMember(member, space));
        },
      ),
    );
  }

  Future<void> _removeMember(
    SharedSpaceMember member,
    SharedSpace space,
  ) async {
    try {
      final service = ref.read(sharedSpaceServiceProvider);
      await service.removeMember(space.id, member.userId);
      ref.invalidate(spaceDetailProvider(widget.spaceId));
      ToastService.show(description: Text(t.sharedSpace.settings.removed));
    } catch (e) {
      _logger.warning('Failed to remove member', e);
      ToastService.showDestructive(
        description: Text(t.sharedSpace.settings.removeFailed),
      );
    }
  }

  // ==================== Danger Zone ====================

  Widget _buildDangerZone(
    FThemeData theme,
    FColors colors,
    SharedSpace space,
    bool isOwner,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.03),
        borderRadius: theme.style.borderRadius.md,
        border: Border.all(color: colors.destructive.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          if (!isOwner) ...[
            // Leave space
            InkWell(
              onTap: () => _confirmLeaveSpace(space),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.logOut,
                      size: 20,
                      color: colors.destructive,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.sharedSpace.detail.leaveSpace,
                        style: AppTextStyles.destructiveText(theme),
                      ),
                    ),
                    Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: colors.destructive.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Delete space
            InkWell(
              onTap: () => _confirmDeleteSpace(space),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.trash2,
                      size: 20,
                      color: colors.destructive,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.sharedSpace.detail.deleteSpace,
                        style: AppTextStyles.destructiveText(theme),
                      ),
                    ),
                    Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: colors.destructive.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmLeaveSpace(SharedSpace space) {
    unawaited(
      showConfirmDialog(
        context: context,
        title: t.sharedSpace.detail.leaveSpace,
        message: t.sharedSpace.detail.leaveConfirm,
        cancelLabel: t.sharedSpace.create.cancel,
        confirmVariant: FButtonVariant.destructive,
        confirmLabel: t.sharedSpace.detail.leaveSpace,
        onConfirm: () async {
          final success = await ref
              .read(sharedSpaceProvider.notifier)
              .leaveSpace(space.id);
          if (success && mounted) {
            context.pop();
            context.pop();
          }
        },
      ),
    );
  }

  void _confirmDeleteSpace(SharedSpace space) {
    unawaited(
      showConfirmDialog(
        context: context,
        title: t.sharedSpace.detail.deleteSpace,
        message: t.sharedSpace.detail.deleteConfirm,
        cancelLabel: t.sharedSpace.create.cancel,
        confirmVariant: FButtonVariant.destructive,
        confirmLabel: t.sharedSpace.detail.deleteSpace,
        onConfirm: () async {
          final success = await ref
              .read(sharedSpaceProvider.notifier)
              .deleteSpace(space.id);
          if (success && mounted) {
            context.pop();
            context.pop();
          }
        },
      ),
    );
  }
}
