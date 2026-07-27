import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Shared brand header for auth pages (login / register steps).
///
/// Renders the Finvo logo + page title with a restrained entrance
/// animation (logo scale+fade in 280ms, title slide-up+fade in 320ms,
/// both start simultaneously for a clean parallel feel). Replaces the
/// old static `loginSubtitle` line, which was both repetitive across
/// screens and redundant with the page title.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.title});

  final String title;

  static const _logoAsset = 'assets/images/logo.png';
  static const _logoSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo: scale 0.85 -> 1.0 + fade in over 280ms
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.85 + 0.15 * value,
                  child: child,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _logoAsset,
                width: _logoSize,
                height: _logoSize,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: _logoSize,
                  height: _logoSize,
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'F',
                    style: theme.typography.body.xl2.copyWith(
                      color: theme.colors.primaryForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Title: slide up 12px + fade in over 320ms
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Text(
            title,
            style: theme.typography.body.xl2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
