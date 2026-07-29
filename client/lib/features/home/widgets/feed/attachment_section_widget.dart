import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Displays attachments linked to a transaction via its AI conversation thread.
///
/// Horizontal scrollable list of attachment cards:
/// - Images: rounded thumbnail (72x72) with progressive blur loading & PhotoView gallery preview
/// - Documents: file icon + truncated filename
/// - Empty state: entire section is hidden
class AttachmentSectionWidget extends ConsumerWidget {
  final List<TransactionAttachment> attachments;

  const AttachmentSectionWidget({super.key, required this.attachments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    final colors = theme.colors;
    final baseUrl = ref.read(apiConstantsProvider).baseUrl;
    final token = ref.watch(authProvider).token;

    final imageAttachments = attachments.where((a) => a.isImage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                FLucideIcons.paperclip,
                size: 14,
                color: colors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                t.transaction.attachments(count: attachments.length.toString()),
                style: AppTextStyles.sectionHeader(theme),
              ),
            ],
          ),
        ),

        // Horizontal scrollable attachment cards
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              if (attachment.isImage) {
                final imageIndex = imageAttachments.indexOf(attachment);
                return _buildImageCard(
                  context,
                  baseUrl,
                  token,
                  attachment,
                  imageAttachments,
                  imageIndex >= 0 ? imageIndex : 0,
                  colors,
                );
              }
              return _buildDocumentCard(context, theme, colors, attachment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    String baseUrl,
    String? token,
    TransactionAttachment attachment,
    List<TransactionAttachment> imageAttachments,
    int initialIndex,
    FColors colors,
  ) {
    final fullUrl = '$baseUrl${attachment.url}';
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        _showFullScreenGallery(
          context,
          imageAttachments,
          initialIndex,
          baseUrl,
          headers,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Image.network(
            fullUrl,
            headers: headers,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: child,
                );
              }
              // Progressive blur loading placeholder
              return Container(
                color: colors.muted,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: colors.primary.withValues(alpha: 0.1),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: colors.muted,
                child: Icon(
                  FLucideIcons.imageOff,
                  color: colors.mutedForeground,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    TransactionAttachment attachment,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(attachment.mimeType),
            size: 20,
            color: colors.mutedForeground,
          ),
          const SizedBox(height: 6),
          Text(
            attachment.filename,
            style: AppTextStyles.detailLabel(theme),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFullScreenGallery(
    BuildContext context,
    List<TransactionAttachment> images,
    int initialIndex,
    String baseUrl,
    Map<String, String> headers,
  ) {
    unawaited(
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: false,
          barrierColor: Colors.black.withValues(alpha: 0.95),
          pageBuilder: (context, animation, secondaryAnimation) {
            return _ImageGalleryDialog(
              images: images,
              initialIndex: initialIndex,
              baseUrl: baseUrl,
              headers: headers,
            );
          },
        ),
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return FLucideIcons.file;
    if (mimeType.contains('pdf')) return FLucideIcons.fileText;
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return FLucideIcons.sheet;
    }
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return FLucideIcons.fileText;
    }
    return FLucideIcons.file;
  }
}

/// Full-screen image gallery dialog with swipe gestures and count indicator (matching AI module)
class _ImageGalleryDialog extends StatefulWidget {
  final List<TransactionAttachment> images;
  final int initialIndex;
  final String baseUrl;
  final Map<String, String> headers;

  const _ImageGalleryDialog({
    required this.images,
    required this.initialIndex,
    required this.baseUrl,
    required this.headers,
  });

  @override
  State<_ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<_ImageGalleryDialog> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.images.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // PhotoView gallery for interactive swiping & zooming
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              pageController: _pageController,
              itemCount: totalCount,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              builder: (BuildContext context, int index) {
                final att = widget.images[index];
                final fullUrl = '${widget.baseUrl}${att.url}';

                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(fullUrl, headers: widget.headers),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 3.0,
                  heroAttributes: PhotoViewHeroAttributes(tag: fullUrl),
                );
              },
              loadingBuilder: (context, event) {
                return Center(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),

            // Top bar: Page count indicator ("1 / 3")
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / $totalCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Top-right close button
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FLucideIcons.x,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
