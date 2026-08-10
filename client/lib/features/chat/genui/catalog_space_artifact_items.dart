// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:finvo/features/chat/genui/catalog_helpers.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/chat/genui/templates/templates.dart';

/// Shared space & artifact link catalog items.
List<CatalogItem> buildSpaceArtifactItems() {
  return [
    _buildSpaceSelectorCard(),
    _buildSpaceAssociationReceipt(),
    _buildArtifactLink(),
    _buildArtifactLinkCard(),
  ];
}

/// Space selector card component
CatalogItem _buildSpaceSelectorCard() {
  return CatalogItem(
    name: 'SpaceSelectorCard',
    dataSchema: ObjectSchema(
      properties: {
        'matched_spaces': ListSchema(
          description: '匹配到的共享空间列表',
          items: ObjectSchema(
            properties: {
              'id': IntegerSchema(description: '空间ID'),
              'name': StringSchema(description: '空间名称'),
              'description': StringSchema(description: '空间描述'),
              'role': StringSchema(description: '用户角色'),
            },
            required: ['id', 'name'],
          ),
        ),
        'all_spaces': ListSchema(
          description: '所有可用共享空间列表',
          items: ObjectSchema(
            properties: {
              'id': IntegerSchema(description: '空间ID'),
              'name': StringSchema(description: '空间名称'),
              'description': StringSchema(description: '空间描述'),
              'role': StringSchema(description: '用户角色'),
            },
            required: ['id', 'name'],
          ),
        ),
        'pending_transaction_ids': ListSchema(
          description: '待关联的交易ID列表',
          items: StringSchema(),
        ),
        'match_keyword': StringSchema(description: '匹配关键词'),
        'message': StringSchema(description: '提示消息'),
      },
      required: ['pending_transaction_ids'],
    ),
    widgetBuilder: _buildSpaceSelectorCardWidget,
  );
}

/// Space association confirmation component
CatalogItem _buildSpaceAssociationReceipt() {
  return CatalogItem(
    name: 'SpaceAssociationReceipt',
    dataSchema: ObjectSchema(
      properties: {
        'space': ObjectSchema(
          description: '关联的空间信息',
          properties: {
            // Backend associate_transactions_to_space returns space_id as UUID string
            'id': StringSchema(description: '空间ID（UUID 字符串）'),
            'name': StringSchema(description: '空间名称'),
          },
          required: ['id', 'name'],
        ),
        'association': ObjectSchema(
          description: '关联统计',
          properties: {
            'total_count': IntegerSchema(description: '总数'),
            'success_count': IntegerSchema(description: '成功数'),
            'failed_count': IntegerSchema(description: '失败数'),
          },
        ),
        'message': StringSchema(description: '结果消息'),
      },
      required: ['space', 'association'],
    ),
    widgetBuilder: _buildSpaceAssociationReceiptWidget,
  );
}

CatalogItem _buildArtifactLink() {
  return CatalogItem(
    name: 'artifact_link',
    dataSchema: ObjectSchema(
      properties: {
        'url': StringSchema(description: 'File URL'),
        'path': StringSchema(description: 'File path'),
        'artifactName': StringSchema(description: 'Artifact name'),
        'artifactUrl': StringSchema(description: 'Artifact URL'),
        'message': StringSchema(description: 'Message'),
      },
    ),
    widgetBuilder: _buildArtifactLinkWidget,
  );
}

CatalogItem _buildArtifactLinkCard() {
  return CatalogItem(
    name: 'ArtifactLinkCard',
    dataSchema: ObjectSchema(
      properties: {
        'url': StringSchema(description: 'File URL'),
        'path': StringSchema(description: 'File path'),
        'artifactName': StringSchema(description: 'Artifact name'),
        'artifactUrl': StringSchema(description: 'Artifact URL'),
        'message': StringSchema(description: 'Message'),
      },
    ),
    widgetBuilder: _buildArtifactLinkWidget,
  );
}

Widget _buildSpaceSelectorCardWidget(CatalogItemContext context) {
  try {
    final data = context.data as Map<String, dynamic>;
    final widgetData = Map<String, dynamic>.from(data);
    widgetData['_surfaceId'] = context.surfaceId;

    return SpaceSelectorCard(
      data: widgetData,
      dispatchEvent: context.dispatchEvent,
    );
  } catch (e) {
    return buildErrorWidget(
      context.buildContext,
      t.chat.genui.error.fetchFailed,
    );
  }
}

Widget _buildSpaceAssociationReceiptWidget(CatalogItemContext context) {
  try {
    final data = context.data as Map<String, dynamic>;
    final widgetData = Map<String, dynamic>.from(data);
    widgetData['_surfaceId'] = context.surfaceId;

    return SpaceAssociationReceipt(
      data: widgetData,
      dispatchEvent: context.dispatchEvent,
    );
  } catch (e) {
    return buildErrorWidget(
      context.buildContext,
      t.chat.genui.error.fetchFailed,
    );
  }
}

Widget _buildArtifactLinkWidget(CatalogItemContext context) {
  try {
    final data = context.data as Map<String, dynamic>;
    final artifactName =
        data['artifactName'] as String? ??
        data['path'] as String? ??
        'Artifact File';
    final url = data['artifactUrl'] as String? ?? data['url'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context.buildContext).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(
            context.buildContext,
          ).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(FLucideIcons.fileText, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  artifactName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (url.isNotEmpty)
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context.buildContext).hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  } catch (e) {
    return buildErrorWidget(
      context.buildContext,
      t.chat.genui.error.fetchFailed,
    );
  }
}
