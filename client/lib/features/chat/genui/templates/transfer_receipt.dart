import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';

import 'package:finvo/features/chat/genui/atoms/atoms.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';

/// Transfer success receipt card widget - concise three-section design
///
/// Design highlights:
/// - Electric current animation line (from source to target)
/// - Only shows account icons (labels already have names)
/// - Compact horizontal layout
class TransferReceipt extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransferReceipt({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    // Extract data (AI-provided payloads are untrusted; coerce types)
    final amount = AmountFormatter.parseDecimal(data['amount']?.toString());
    final currency = data['currency']?.toString() ?? 'CNY';
    final time = data['transaction_at']?.toString() ?? '';
    final tagsRaw = data['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((e) => e.toString()).toList()
        : <String>[];

    // Transfer info
    final transferInfoRaw = data['transfer_info'];
    final transferInfo = transferInfoRaw is Map
        ? Map<String, dynamic>.from(transferInfoRaw)
        : null;
    final sourceAccountRaw = transferInfo?['source_account'];
    final sourceAccount = sourceAccountRaw is Map
        ? Map<String, dynamic>.from(sourceAccountRaw)
        : null;
    final targetAccountRaw = transferInfo?['target_account'];
    final targetAccount = targetAccountRaw is Map
        ? Map<String, dynamic>.from(targetAccountRaw)
        : null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section 1: Top status bar
          _buildStatusHeader(theme, colors, time),

          // Section 2: Middle content - amount + tags
          _buildMainContent(theme, colors, currency, amount, tags),

          // Section 3: Bottom account animation (with account names)
          _TransferAnimation(
            colors: colors,
            sourceAccount: sourceAccount,
            targetAccount: targetAccount,
          ),
        ],
      ),
    );
  }

  /// Build top status bar
  Widget _buildStatusHeader(FThemeData theme, FColors colors, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1)),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FLucideIcons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t.chat.transferWizard.transferSuccess,
            style: AppTextStyles.actionText(theme),
          ),
          const Spacer(),
          Text(
            _formatTimeOnly(time),
            style: theme.typography.body.sm.copyWith(
              color: colors.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build middle main content area
  Widget _buildMainContent(
    FThemeData theme,
    FColors colors,
    String currency,
    Decimal amount,
    List<String> tags,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          // Transfer icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FLucideIcons.arrowRightLeft,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Amount - use unified AmountText (transfer type)
          AmountText(
            amount: amount,
            type: TransactionType.transfer,
            currency: currency,
            showSign: false,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colors.foreground,
              letterSpacing: -0.5,
            ),
          ),

          // Tags
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: tags.map((tag) => Tag(label: tag)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeOnly(String isoTime) {
    if (isoTime.isEmpty) {
      final now = DateTime.now();
      return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
    final dateTime = tryParseDateTime(isoTime);
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Transfer animation component - electric current effect
class _TransferAnimation extends StatefulWidget {
  final FColors colors;
  final Map<String, dynamic>? sourceAccount;
  final Map<String, dynamic>? targetAccount;

  const _TransferAnimation({
    required this.colors,
    this.sourceAccount,
    this.targetAccount,
  });

  @override
  State<_TransferAnimation> createState() => _TransferAnimationState();
}

class _TransferAnimationState extends State<_TransferAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    unawaited(
      (_controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )).repeat(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = widget.colors;

    final sourceName = widget.sourceAccount?['name']?.toString() ?? '';
    final targetName = widget.targetAccount?['name']?.toString() ?? '';
    final sourceType = widget.sourceAccount?['type']?.toString();
    final targetType = widget.targetAccount?['type']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(color: colors.muted.withValues(alpha: 0.15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Source account
          _buildAccountWithLabel(theme, colors, sourceName, sourceType),

          // Electric current animation line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 70,
              height: 30,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ElectricLinePainter(
                      progress: _controller.value,
                      color: colors.primary,
                    ),
                  );
                },
              ),
            ),
          ),

          // Target account
          _buildAccountWithLabel(theme, colors, targetName, targetType),
        ],
      ),
    );
  }

  Widget _buildAccountWithLabel(
    FThemeData theme,
    FColors colors,
    String name,
    String? type,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAccountIcon(colors, type),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.detailLabel(theme).copyWith(height: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountIcon(FColors colors, String? type) {
    final semantic = context.theme.semantic;
    IconData icon;
    Color bgColor;

    switch (type?.toUpperCase()) {
      case 'CASH':
        icon = FLucideIcons.banknote;
        bgColor = semantic.successAccent;
        break;
      case 'BANK':
      case 'DEPOSIT':
        icon = FLucideIcons.building;
        bgColor = colors.primary;
        break;
      case 'CREDIT_CARD':
        icon = FLucideIcons.creditCard;
        bgColor = semantic.warningAccent;
        break;
      case 'ALIPAY':
      case 'WECHAT':
      case 'EWALLET':
        icon = FLucideIcons.smartphone;
        bgColor = colors.primary;
        break;
      default:
        icon = FLucideIcons.wallet;
        bgColor = colors.mutedForeground;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Icon(icon, size: 22, color: bgColor),
    );
  }
}

/// Electric line painter
class _ElectricLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ElectricLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Base line
    final basePath = Path();
    basePath.moveTo(0, size.height / 2);
    basePath.lineTo(size.width, size.height / 2);
    canvas.drawPath(basePath, paint);

    // Arrow
    final arrowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arrowPath = Path();
    arrowPath.moveTo(size.width - 8, size.height / 2 - 5);
    arrowPath.lineTo(size.width, size.height / 2);
    arrowPath.lineTo(size.width - 8, size.height / 2 + 5);
    canvas.drawPath(arrowPath, arrowPaint);

    // Electric glow dots (moving effect)
    final glowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Multiple dots to create electric flow effect
    for (int i = 0; i < 3; i++) {
      final dotProgress = (progress + i * 0.33) % 1.0;
      final x = dotProgress * (size.width - 12) + 4;
      final alpha = (1 - (dotProgress - 0.5).abs() * 2).clamp(0.3, 1.0);

      canvas.drawCircle(
        Offset(x, size.height / 2),
        3,
        glowPaint..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ElectricLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
