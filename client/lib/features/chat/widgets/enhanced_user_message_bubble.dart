import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:logging/logging.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/models/chat_message_attachment.dart';
import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/features/chat/services/data_uri_service.dart';
import 'package:finvo/features/chat/widgets/authenticated_image.dart';
import 'package:finvo/features/chat/services/genui_cache_service.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/chat/widgets/image_preview_page.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/i18n/strings.g.dart';

final _logger = Logger('EnhancedUserMessageBubble');

/// User message bubble widget
/// Supports displaying text and multimedia attachments
class UserMessageBubble extends ConsumerStatefulWidget {
  final ChatMessage message;

  const UserMessageBubble({super.key, required this.message});

  @override
  ConsumerState<UserMessageBubble> createState() => _UserMessageBubbleState();
}

class _UserMessageBubbleState extends ConsumerState<UserMessageBubble> {
  static const double _imagePreviewWidth = 200;
  static const double _imagePreviewHeight = 150;
  static const double _imageBorderRadius = 12;
  static const String _cacheCategory = 'user_media_previews';

  bool _hasRequestedSignedUrls = false;

  String _mediaCacheKey(DataUriFile file) {
    return '${widget.message.id}_${file.originalName}_${file.size}_${file.dataUri.hashCode}';
  }

  String get _visibilityKey {
    final buffer = StringBuffer(widget.message.id);
    for (final attachment in widget.message.attachments) {
      buffer
        ..write('_')
        ..write(attachment.id)
        ..write('_')
        ..write(attachment.signedUrl ?? '')
        ..write('_')
        ..write(attachment.status.name);
    }
    return buffer.toString();
  }

  bool get _hasAttachmentsNeedingFetch {
    return widget.message.attachments.any(_shouldAutoFetchAttachment);
  }

  bool _shouldAutoFetchAttachment(ChatMessageAttachment attachment) {
    return !attachment.hasSignedUrl &&
        attachment.status != AttachmentLoadStatus.loading &&
        attachment.status != AttachmentLoadStatus.failed;
  }

  @override
  void didUpdateWidget(covariant UserMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasAttachmentsNeedingFetch) {
      _hasRequestedSignedUrls = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final attachments = widget.message.attachments;
    final hasMediaFiles = widget.message.mediaFiles.isNotEmpty;
    final hasText = widget.message.content.isNotEmpty;

    final children = <Widget>[];

    if (attachments.isNotEmpty) {
      children.add(
        VisibilityDetector(
          key: ValueKey(_visibilityKey),
          onVisibilityChanged: _handleAttachmentVisibilityChanged,
          child: _buildAttachmentsSection(theme),
        ),
      );

      if (hasMediaFiles || hasText) {
        children.add(const SizedBox(height: 8));
      }
    }

    if (hasMediaFiles) {
      children.add(_buildMediaFilesPreview(context, theme));
      if (hasText) {
        children.add(const SizedBox(height: 8));
      }
    }

    if (hasText) {
      children.add(_buildTextBubble(theme));
    }

    return Align(
      key: ValueKey('user_message_${widget.message.id}'),
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        ),
      ),
    );
  }

  void _handleAttachmentVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    if (info.visibleFraction < 0.25) return;
    if (!_hasAttachmentsNeedingFetch) return;
    if (_hasRequestedSignedUrls) return;

    _hasRequestedSignedUrls = true;
    unawaited(
      ref
          .read(chatHistoryProvider.notifier)
          .ensureAttachmentsSignedUrls(widget.message.id),
    );
  }

  Widget _buildAttachmentsSection(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final attachment in widget.message.attachments)
          _buildAttachmentItem(attachment, theme),
      ],
    );
  }

  Widget _buildAttachmentItem(
    ChatMessageAttachment attachment,
    FThemeData theme,
  ) {
    if (attachment.isPreviewable) {
      return _buildAttachmentImage(attachment, theme);
    }
    return _buildAttachmentFileTile(attachment, theme);
  }

  Widget _buildAttachmentImage(
    ChatMessageAttachment attachment,
    FThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: _imagePreviewWidth,
        height: _imagePreviewHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_imageBorderRadius),
          child: SizedBox.expand(
            child: _buildAttachmentImageContent(attachment, theme),
          ),
        ),
      ),
    );
  }

  /// Render attachment image content
  ///
  /// Design principle: **data over status**
  /// - If signedUrl exists, render directly without depending on status
  /// - Only show skeleton or error based on status when no data is available
  Widget _buildAttachmentImageContent(
    ChatMessageAttachment attachment,
    FThemeData theme,
  ) {
    final url = attachment.signedUrl;

    // 1. Data first: if URL exists, render directly
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:')) {
        // Base64 data URI - decode and render directly
        return _renderBase64Image(attachment, url, theme);
      } else {
        // Network URL - use authenticated image widget
        return _renderNetworkImage(attachment, theme);
      }
    }

    // 2. No data: show different UI based on status
    switch (attachment.status) {
      case AttachmentLoadStatus.initial:
      case AttachmentLoadStatus.loading:
        return _buildAttachmentSkeleton(theme);
      case AttachmentLoadStatus.loaded:
        // Status is loaded but no URL, show error
        return _buildAttachmentError(theme, attachment);
      case AttachmentLoadStatus.failed:
        return _buildAttachmentError(theme, attachment);
    }
  }

  /// Render Base64 image
  Widget _renderBase64Image(
    ChatMessageAttachment attachment,
    String dataUri,
    FThemeData theme,
  ) {
    try {
      final bytes = _getImageBytesFromDataUri(dataUri);
      if (bytes == null) {
        return _buildAttachmentError(theme, attachment);
      }
      return Hero(
        tag: 'history_attachment_${attachment.id}',
        child: GestureDetector(
          onTap: () =>
              _showImagePreview(bytes, 'history_attachment_${attachment.id}'),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) =>
                _buildAttachmentError(theme, attachment),
          ),
        ),
      );
    } catch (e) {
      return _buildAttachmentError(theme, attachment);
    }
  }

  /// Render network image (with authentication)
  Widget _renderNetworkImage(
    ChatMessageAttachment attachment,
    FThemeData theme,
  ) {
    return Hero(
      tag: 'history_attachment_${attachment.id}',
      child: GestureDetector(
        onTap: () => _handleRemoteImageTap(attachment),
        child: AuthenticatedImage(
          attachmentId: attachment.id,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            return _buildAttachmentSkeleton(theme);
          },
          errorBuilder: (context, error, stackTrace) =>
              _buildAttachmentError(theme, attachment),
        ),
      ),
    );
  }

  void _showImagePreview(Uint8List bytes, String heroTag) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ImagePreviewPage(
            itemCount: 1,
            heroTag: (_) => heroTag,
            imageProvider: (_) => MemoryImage(bytes),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentFileTile(
    ChatMessageAttachment attachment,
    FThemeData theme,
  ) {
    switch (attachment.status) {
      case AttachmentLoadStatus.initial:
      case AttachmentLoadStatus.loading:
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 60,
          decoration: BoxDecoration(
            color: theme.colors.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildAttachmentSkeleton(theme),
        );
      case AttachmentLoadStatus.failed:
        return _buildAttachmentError(theme, attachment);
      case AttachmentLoadStatus.loaded:
        final fileCategory = DataUriService.getFileCategory(
          attachment.filename,
        );
        final icon = _getFileTypeIcon(fileCategory);
        final color = _getFileTypeColor(fileCategory, theme);
        return InkWell(
          onTap: attachment.hasSignedUrl
              ? () => _openAttachmentLink(attachment)
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        attachment.filename,
                        style: AppTextStyles.listTitle(theme),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attachment.fileExtension.isEmpty
                            ? ''
                            : attachment.fileExtension.toUpperCase(),
                        style: theme.typography.body.sm.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (attachment.hasSignedUrl) ...[
                  const SizedBox(width: 8),
                  Icon(
                    FLucideIcons.externalLink,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }

  Widget _buildAttachmentSkeleton(FThemeData theme) {
    final baseColor = theme.colors.muted.withValues(alpha: 0.35);
    final highlightColor = theme.colors.background.withValues(alpha: 0.6);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.muted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentError(
    FThemeData theme,
    ChatMessageAttachment attachment,
  ) {
    final message =
        attachment.errorMessage ?? 'Failed to load attachment, tap to retry';
    return InkWell(
      onTap: () => _retryAttachment(attachment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colors.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.refreshCcw,
              color: theme.colors.destructive,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: AppTextStyles.destructiveText(theme)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBubble(FThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colors.foreground.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.message.content,
        style: AppTextStyles.formValue(theme).copyWith(
          color: theme.colors.primaryForeground,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMediaFilesPreview(BuildContext context, FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final file in widget.message.mediaFiles)
          _buildMediaFileItem(context, file, theme),
        if (widget.message.mediaFiles.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${widget.message.mediaFiles.length} files total',
              style: AppTextStyles.detailLabel(theme).copyWith(fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaFileItem(
    BuildContext context,
    DataUriFile file,
    FThemeData theme,
  ) {
    final fileCategory = DataUriService.getFileCategory(file.originalName);

    if (fileCategory == 'image') {
      return _buildImagePreview(context, file, theme);
    }

    return _buildFileInfo(context, file, fileCategory, theme);
  }

  Widget _buildImagePreview(
    BuildContext context,
    DataUriFile file,
    FThemeData theme,
  ) {
    final cacheKey = _mediaCacheKey(file);

    // Use the cache service for media previews to prevent memory leaks
    var bytes = GenUiCacheService().get<Uint8List>(_cacheCategory, cacheKey);
    if (bytes == null) {
      bytes = _getImageBytesFromDataUri(file.dataUri);
      if (bytes == null) {
        final category = DataUriService.getFileCategory(file.originalName);
        return _buildFileInfo(context, file, category, theme);
      }
      GenUiCacheService().put(_cacheCategory, cacheKey, bytes);
    }

    final heroTag = 'media_$cacheKey';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: _imagePreviewWidth,
        height: _imagePreviewHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_imageBorderRadius),
          child: SizedBox.expand(
            child: GestureDetector(
              onTap: () => _showInlineImagePreview(context, file),
              child: Hero(
                tag: heroTag,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo(
    BuildContext context,
    DataUriFile file,
    String fileCategory,
    FThemeData theme,
  ) {
    final formattedSize = DataUriService.formatFileSize(file.size);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getFileTypeColor(fileCategory, theme),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileTypeIcon(fileCategory),
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.originalName,
                  style: AppTextStyles.listTitle(theme),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$formattedSize · ${fileCategory.toUpperCase()}',
                  style: AppTextStyles.detailLabel(
                    theme,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInlineImagePreview(
    BuildContext context,
    DataUriFile file,
  ) async {
    final heroTag = 'media_${_mediaCacheKey(file)}';
    final bytes = _getImageBytesFromDataUri(file.dataUri);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.chat.invalidAttachmentLink)));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ImagePreviewPage(
          itemCount: 1,
          heroTag: (_) => heroTag,
          imageProvider: (_) => MemoryImage(bytes),
        ),
      ),
    );
  }

  Future<void> _handleRemoteImageTap(ChatMessageAttachment attachment) async {
    final storageService = ref.read(secureStorageServiceProvider);
    final token = await storageService.getToken();
    if (token == null || token.isEmpty) return;
    final baseUrl = ref.read(apiBaseUrlProvider);
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ImagePreviewPage(
          itemCount: 1,
          heroTag: (_) => 'history_attachment_${attachment.id}',
          imageProvider: (_) => NetworkImage(
            '$baseUrl/files/view/${attachment.id}',
            headers: {'Authorization': 'Bearer $token'},
          ),
        ),
      ),
    );
  }

  void _retryAttachment(ChatMessageAttachment attachment) {
    unawaited(
      ref
          .read(chatHistoryProvider.notifier)
          .ensureAttachmentsSignedUrls(
            widget.message.id,
            attachmentIds: [attachment.id],
            forceRetry: true,
          ),
    );
    _hasRequestedSignedUrls = false;
  }

  Future<void> _openAttachmentLink(ChatMessageAttachment attachment) async {
    final url = attachment.signedUrl;
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.chat.invalidAttachmentLink)));
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.chat.unableToOpenAttachmentLink)),
      );
    }
  }

  /// Decodes the payload of a `data:` URI. Returns `null` when the URI is
  /// malformed or empty; callers must fall back instead of crashing the build.
  Uint8List? _getImageBytesFromDataUri(String dataUri) {
    if (!dataUri.startsWith('data:') || !dataUri.contains(',')) {
      _logger.warning(
        'EnhancedUserMessageBubble: data URI missing header or payload',
      );
      return null;
    }
    final base64String = dataUri.split(',').last.trim();
    if (base64String.isEmpty) {
      _logger.warning('EnhancedUserMessageBubble: empty data URI payload');
      return null;
    }
    try {
      return base64Decode(base64String);
    } catch (e) {
      _logger.warning(
        'EnhancedUserMessageBubble: data URI payload is not valid base64: $e',
      );
      return null;
    }
  }

  Color _getFileTypeColor(String fileCategory, FThemeData theme) {
    switch (fileCategory) {
      case 'image':
        return Colors.blue;
      case 'document':
        return Colors.green;
      case 'video':
        return Colors.purple;
      case 'audio':
        return Colors.orange;
      default:
        return theme.colors.mutedForeground;
    }
  }

  IconData _getFileTypeIcon(String fileCategory) {
    switch (fileCategory) {
      case 'image':
        return FLucideIcons.image;
      case 'document':
        return FLucideIcons.fileText;
      case 'video':
        return FLucideIcons.video;
      case 'audio':
        return FLucideIcons.volume2;
      default:
        return FLucideIcons.file;
    }
  }
}
