import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:genui/genui.dart' as genui;
import 'package:finvo/features/chat/models/chat_message.dart' as app;
import 'package:finvo/i18n/strings.g.dart';

final _logger = Logger('ChatMessageCopyUtils');

/// Extension on [app.ChatMessage] providing copyable content extraction
extension ChatMessageCopyExtension on app.ChatMessage {
  /// Extract copyable text or JSON serialization from the message
  ({String content, String message}) getCopyableContent(
    genui.SurfaceHost? genUiHost,
  ) {
    // 1. If plain text content exists, return directly
    if (content.trim().isNotEmpty) {
      return (content: content, message: t.chat.contentCopied);
    }

    // 2. If GenUI component data exists (history messages), copy JSON data
    if (uiComponents.isNotEmpty) {
      try {
        final componentsData = uiComponents
            .map(
              (comp) => {
                'componentType': comp.componentType,
                'surfaceId': comp.surfaceId,
                'data': comp.data,
                if (comp.userSelection != null)
                  'userSelection': comp.userSelection,
              },
            )
            .toList();

        final jsonString = const JsonEncoder.withIndent('  ').convert(
          componentsData.length == 1 ? componentsData.first : componentsData,
        );
        return (content: jsonString, message: t.chat.jsonCopied);
      } catch (e) {
        _logger.info('Failed to serialize UI components: $e');
      }
    }

    // 3. If surfaceIds exist (real-time messages), get data from GenUI Host
    if (surfaceIds.isNotEmpty && genUiHost != null) {
      try {
        final surfaceDataList = <Map<String, dynamic>>[];

        for (final surfaceId in surfaceIds) {
          final surfaceDefinition = genUiHost
              .contextFor(surfaceId)
              .definition
              .value;

          if (surfaceDefinition != null) {
            final components = surfaceDefinition.components;
            if (components.isNotEmpty) {
              for (final entry in components.entries) {
                surfaceDataList.add({
                  'surfaceId': surfaceId,
                  'componentId': entry.key,
                  'componentType': entry.value.type,
                  'componentProperties': entry.value.properties,
                });
              }
            }
          }
        }

        if (surfaceDataList.isNotEmpty) {
          final jsonString = const JsonEncoder.withIndent('  ').convert(
            surfaceDataList.length == 1
                ? surfaceDataList.first
                : surfaceDataList,
          );
          return (content: jsonString, message: t.chat.jsonCopied);
        }
      } catch (e) {
        _logger.info('Failed to get surface data from GenUI Host: $e');
      }
    }

    // 4. No copyable content
    return (content: '', message: '');
  }
}
