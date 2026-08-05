import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/features/chat/services/genui_logger.dart';

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
    return buildErrorWidget(context.buildContext, 'Rendering failed: $e');
  }
}

/// Build error widget
Widget buildErrorWidget(BuildContext context, String message) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8.0),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.red.shade50.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade800,
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
                '组件渲染遇到问题',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: AppFontConfig.headingBold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
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
