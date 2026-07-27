import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import '../models/shared_space_models.dart';

class SpaceDashboardCard extends StatelessWidget {
  final SharedSpace space;
  final Settlement settlement;

  const SpaceDashboardCard({
    super.key,
    required this.space,
    required this.settlement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.foreground.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.sharedSpace.dashboard.cumulativeTotalExpense,
                  style: theme.typography.body.xs.copyWith(
                    color: colors.primaryForeground.withValues(alpha: 0.7),
                    fontWeight: AppFontConfig.bodyMedium,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¥${_formatAmount(space.totalExpense)}',
                  style: theme.typography.body.xl3.copyWith(
                    color: colors.primaryForeground,
                    fontWeight: AppFontConfig.amountBold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildQuickStat(
                      context,
                      t.sharedSpace.dashboard.participatingMembers,
                      t.sharedSpace.dashboard.membersCount(
                        count: space.members?.length ?? 0,
                      ),
                    ),
                    const SizedBox(width: 32),
                    _buildQuickStat(
                      context,
                      t.sharedSpace.dashboard.averagePerMember,
                      '¥${_calculateAverage()}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.sharedSpace.dashboard.spendingDistribution,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.foreground,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDistributionBar(context),
                const SizedBox(height: 24),
                ..._buildMemberList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String label, String value) {
    final theme = context.theme;
    final colors = theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: colors.primaryForeground.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.typography.body.sm.copyWith(
            color: colors.primaryForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionBar(BuildContext context) {
    final colors = context.theme.colors;
    final members = space.members ?? [];
    final total = members.fold<double>(
      0,
      (sum, m) => sum + (double.tryParse(m.contributionAmount) ?? 0),
    );

    if (total <= 0 || members.isEmpty) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: colors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // Build proportional segments based on real contribution data
    final segments = <Widget>[];
    for (int i = 0; i < members.length; i++) {
      final amount = double.tryParse(members[i].contributionAmount) ?? 0;
      final ratio = (amount / total * 100).round();
      if (ratio <= 0) continue;
      // Use decreasing opacity to distinguish members
      final opacity = 1.0 - (i * 0.25).clamp(0.0, 0.7);
      segments.add(
        Expanded(
          flex: ratio,
          child: Container(color: colors.primary.withValues(alpha: opacity)),
        ),
      );
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(children: segments),
      ),
    );
  }

  List<Widget> _buildMemberList(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final members = space.members ?? [];

    if (members.isEmpty) return [const SizedBox()];

    return members.map((member) {
      final isOwner = member.role == MemberRole.owner;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            _buildAvatar(context, member),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      member.username,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: AppFontConfig.bodyMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(width: 6),
                    Icon(FLucideIcons.crown, size: 14, color: colors.primary),
                  ],
                ],
              ),
            ),
            Text(
              '¥${_formatAmount(member.contributionAmount)}',
              style: theme.typography.body.sm.copyWith(
                fontWeight: AppFontConfig.amountBold,
                color: colors.foreground,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAvatar(BuildContext context, SharedSpaceMember member) {
    final colors = context.theme.colors;
    return UserAvatar(
      userId: member.userId,
      size: 36,
      border: Border.all(color: colors.background, width: 2),
    );
  }

  String _formatAmount(dynamic amount) {
    final valueStr = amount.toString();
    final value = double.tryParse(valueStr) ?? 0.0;
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    var formatted = '';
    var count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0 && intPart[i] != '-') {
        formatted = ',$formatted';
      }
      formatted = intPart[i] + formatted;
      count++;
    }
    return '$formatted.$decPart';
  }

  String _calculateAverage() {
    final total = double.tryParse(space.totalExpense) ?? 0.0;
    final memberCount = space.members?.length ?? 1;
    final avg = memberCount > 0 ? total / memberCount : total;
    return _formatAmount(avg);
  }
}
