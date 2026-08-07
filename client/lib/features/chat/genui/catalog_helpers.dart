import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/features/chat/services/genui_logger.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Shared building blocks used by the catalog item files.

/// Validate required fields
bool validateRequiredFields(
  Map<String, dynamic> data,
  List<String> requiredFields,
) {
  for (final field in requiredFields) {
    if (!data.containsKey(field) || data[field] == null) {
      return false;
    }
  }
  return true;
}

/// Wrap a builder with invocation logging and error handling
Widget wrapBuilder({
  required String componentName,
  required CatalogItemContext context,
  required Widget Function(CatalogItemContext context) build,
}) {
  final startTime = DateTime.now();
  try {
    final widget = build(context);
    GenUiLogger.logBuilderInvocation(
      componentName: componentName,
      success: true,
      durationMs: DateTime.now().difference(startTime).inMilliseconds,
    );
    return widget;
  } catch (e, stackTrace) {
    GenUiLogger.logBuilderInvocation(
      componentName: componentName,
      success: false,
      durationMs: DateTime.now().difference(startTime).inMilliseconds,
    );
    GenUiLogger.logError(
      message: 'Builder failed for $componentName',
      error: e,
      stackTrace: stackTrace,
    );
    // Never surface the raw exception to the user; it goes to the log only.
    return buildErrorWidget(
      context.buildContext,
      t.chat.genui.error.fetchFailed,
    );
  }
}

/// Build error widget
///
/// Theme-aware error surface for GenUI components. Uses Forui colors so it
/// follows light/dark mode instead of hardcoding Material red shades.
Widget buildErrorWidget(BuildContext context, String message) {
  final theme = context.theme;
  final colors = theme.colors;

  return Container(
    margin: const EdgeInsets.only(bottom: 8.0),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: colors.destructive.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colors.destructive.withValues(alpha: 0.35)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.destructive.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            FLucideIcons.triangleAlert,
            color: colors.destructive,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.chat.genui.error.title,
                style: theme.typography.body.sm.copyWith(
                  color: colors.destructive,
                  fontWeight: AppFontConfig.headingBold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: theme.typography.body.xs.copyWith(
                  color: colors.destructive.withValues(alpha: 0.85),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
