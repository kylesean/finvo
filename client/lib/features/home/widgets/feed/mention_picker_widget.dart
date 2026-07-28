// features/home/widgets/feed/mention_picker_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// A member item from space membership.
class SpaceMemberItem {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String role;

  const SpaceMemberItem({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.role,
  });
}

/// Provider that fetches space members for @ mention.
final spaceMembersProvider =
    FutureProvider.family<List<SpaceMemberItem>, String>((ref, spaceId) async {
      final networkClient = ref.read(networkClientProvider);
      final result = await networkClient.requestMap(
        '/shared-spaces/$spaceId',
        method: HttpMethod.get,
      );

      final members = (result['data']?['members'] as List<dynamic>? ?? [])
          .map(
            (m) => SpaceMemberItem(
              userId: m['user_id']?.toString() ?? '',
              username: m['username']?.toString() ?? '',
              avatarUrl: m['avatar_url']?.toString(),
              role: m['role']?.toString() ?? 'MEMBER',
            ),
          )
          .where((m) => m.userId.isNotEmpty && m.username.isNotEmpty)
          .toList();

      return members;
    });

/// Overlay widget that shows space members for @ mention selection.
class MentionPickerWidget extends ConsumerWidget {
  final String spaceId;
  final String filter;
  final ValueChanged<SpaceMemberItem> onSelected;

  const MentionPickerWidget({
    super.key,
    required this.spaceId,
    required this.filter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final membersAsync = ref.watch(spaceMembersProvider(spaceId));

    return membersAsync.when(
      data: (members) {
        // Filter members by typed text after @
        final filtered = filter.isEmpty
            ? members
            : members
                  .where(
                    (m) =>
                        m.username.toLowerCase().contains(filter.toLowerCase()),
                  )
                  .toList();

        if (filtered.isEmpty) return const SizedBox.shrink();

        return Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final member = filtered[index];
              return InkWell(
                onTap: () => onSelected(member),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      UserAvatar(userId: member.userId, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          member.username,
                          style: AppTextStyles.listTitle(theme),
                        ),
                      ),
                      Text(
                        member.role,
                        style: AppTextStyles.detailLabel(theme),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
