// features/chat/widgets/upload_progress_widget.dart
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Upload progress status
enum UploadStatus { uploading, success, failed, cancelled }

/// Upload progress data model
class UploadProgressData {
  final String id;
  final XFile file;
  final double progress; // 0.0 - 1.0
  final UploadStatus status;
  final String? errorMessage;
  final String? uploadUrl;

  const UploadProgressData({
    required this.id,
    required this.file,
    this.progress = 0.0,
    this.status = UploadStatus.uploading,
    this.errorMessage,
    this.uploadUrl,
  });

  UploadProgressData copyWith({
    String? id,
    XFile? file,
    double? progress,
    UploadStatus? status,
    String? errorMessage,
    String? uploadUrl,
  }) {
    return UploadProgressData(
      id: id ?? this.id,
      file: file ?? this.file,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadUrl: uploadUrl ?? this.uploadUrl,
    );
  }

  /// Whether upload is completed (success or failure)
  bool get isCompleted =>
      status == UploadStatus.success || status == UploadStatus.failed;

  /// Whether upload is in progress
  bool get isUploading => status == UploadStatus.uploading;

  /// Whether upload succeeded
  bool get isSuccess => status == UploadStatus.success;

  /// Whether upload failed
  bool get isFailed => status == UploadStatus.failed;
}

/// Upload progress display widget
class UploadProgressWidget extends StatelessWidget {
  final UploadProgressData uploadData;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const UploadProgressWidget({
    super.key,
    required this.uploadData,
    this.onCancel,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          // File thumbnail
          _buildThumbnail(theme, colors),
          const SizedBox(width: 12),

          // File info and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File name
                Text(
                  uploadData.file.name,
                  style: AppTextStyles.listTrailing(theme),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Status and progress
                _buildStatusInfo(theme, colors),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action button
          _buildActionButton(colors),
        ],
      ),
    );
  }

  /// Build file thumbnail
  /// iOS/Android: use efficient Image.file
  /// Web: use Image.memory + readAsBytes
  Widget _buildThumbnail(FThemeData theme, FColors colors) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _isImageFile(uploadData.file.name)
            ? _buildImageThumbnail(colors)
            : _buildFileIcon(colors),
      ),
    );
  }

  /// Build image thumbnail
  Widget _buildImageThumbnail(FColors colors) {
    if (kIsWeb) {
      // Web platform: use readAsBytes
      return FutureBuilder<List<int>>(
        future: uploadData.file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.mutedForeground,
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildFileIcon(colors);
          }

          return Image.memory(
            snapshot.data as Uint8List,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFileIcon(colors);
            },
          );
        },
      );
    } else {
      // iOS/Android: use efficient Image.file
      return Image.file(
        File(uploadData.file.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFileIcon(colors);
        },
      );
    }
  }

  /// Build file icon
  Widget _buildFileIcon(FColors colors) {
    return Center(
      child: Icon(FLucideIcons.file, size: 24, color: colors.mutedForeground),
    );
  }

  /// Build status info
  Widget _buildStatusInfo(FThemeData theme, FColors colors) {
    switch (uploadData.status) {
      case UploadStatus.uploading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: uploadData.progress,
                backgroundColor: colors.muted,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 2),
            // Progress text
            Text(
              'Uploading... ${(uploadData.progress * 100).toInt()}%',
              style: AppTextStyles.detailLabel(theme),
            ),
          ],
        );

      case UploadStatus.success:
        return Row(
          children: [
            const Icon(FLucideIcons.check, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'Upload successful',
              style: theme.typography.body.xs.copyWith(color: Colors.green),
            ),
          ],
        );

      case UploadStatus.failed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FLucideIcons.x, size: 16, color: colors.destructive),
                const SizedBox(width: 4),
                Text(
                  'Upload failed',
                  style: theme.typography.body.xs.copyWith(
                    color: colors.destructive,
                  ),
                ),
              ],
            ),
            if (uploadData.errorMessage != null) ...[
              const SizedBox(height: 2),
              Text(
                uploadData.errorMessage!,
                style: theme.typography.body.xs.copyWith(
                  color: colors.destructive.withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );

      case UploadStatus.cancelled:
        return Row(
          children: [
            Icon(FLucideIcons.ban, size: 16, color: colors.mutedForeground),
            const SizedBox(width: 4),
            Text('Cancelled', style: AppTextStyles.detailLabel(theme)),
          ],
        );
    }
  }

  /// Build action button
  Widget _buildActionButton(FColors colors) {
    switch (uploadData.status) {
      case UploadStatus.uploading:
        return FButton.icon(
          variant: .ghost,
          onPress: onCancel,
          child: Icon(FLucideIcons.x, size: 16, color: colors.mutedForeground),
        );

      case UploadStatus.success:
        return FButton.icon(
          variant: .ghost,
          onPress: onRemove,
          child: Icon(FLucideIcons.x, size: 16, color: colors.mutedForeground),
        );

      case UploadStatus.failed:
        return Row(
          children: [
            FButton.icon(
              variant: .ghost,
              onPress: onRetry,
              child: Icon(
                FLucideIcons.refreshCcw,
                size: 16,
                color: colors.primary,
              ),
            ),
            FButton.icon(
              variant: .ghost,
              onPress: onRemove,
              child: Icon(
                FLucideIcons.x,
                size: 16,
                color: colors.mutedForeground,
              ),
            ),
          ],
        );

      case UploadStatus.cancelled:
        return FButton.icon(
          variant: .ghost,
          onPress: onRemove,
          child: Icon(FLucideIcons.x, size: 16, color: colors.mutedForeground),
        );
    }
  }

  /// Check if file is an image
  bool _isImageFile(String fileName) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }
}

/// Batch upload progress display widget
class BatchUploadProgressWidget extends StatelessWidget {
  final List<UploadProgressData> uploadList;
  final void Function(String id)? onCancel;
  final void Function(String id)? onRetry;
  final void Function(String id)? onRemove;

  const BatchUploadProgressWidget({
    super.key,
    required this.uploadList,
    this.onCancel,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (uploadList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Upload progress (${_getCompletedCount()}/${uploadList.length})',
              style: AppTextStyles.listTrailing(theme),
            ),
          ),

          // Upload item list
          ...uploadList.map((uploadData) {
            return UploadProgressWidget(
              uploadData: uploadData,
              onCancel: onCancel != null
                  ? () => onCancel!(uploadData.id)
                  : null,
              onRetry: onRetry != null ? () => onRetry!(uploadData.id) : null,
              onRemove: onRemove != null
                  ? () => onRemove!(uploadData.id)
                  : null,
            );
          }),
        ],
      ),
    );
  }

  /// Get count of completed uploads
  int _getCompletedCount() {
    return uploadList.where((data) => data.isCompleted).length;
  }
}
