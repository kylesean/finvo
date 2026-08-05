// features/chat/widgets/image_preview_page.dart
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';

/// Image preview page with zoom and swipe navigation support
///
/// Supports two image sources:
/// - [files]: local [XFile]s (iOS/Android: efficient FileImage, Web: MemoryImage)
/// - [imageProvider]: arbitrary [ImageProvider] per index (network, memory, ...)
class ImagePreviewPage extends StatefulWidget {
  final List<XFile>? files;
  final ImageProvider Function(int index)? imageProvider;
  final int itemCount;
  final int initialIndex;
  final String Function(int index)? heroTag;
  final void Function(int)? onDelete;

  const ImagePreviewPage({
    super.key,
    this.files,
    this.imageProvider,
    this.itemCount = 0,
    this.initialIndex = 0,
    this.heroTag,
    this.onDelete,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  // Web platform: cache image byte data to avoid redundant reads
  final Map<int, Uint8List> _imageCache = {};

  int get _count => widget.files?.length ?? widget.itemCount;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Web platform: preload current and adjacent images
    if (kIsWeb && widget.files != null) {
      _preloadImages();
    }
  }

  void _preloadImages() {
    // Preload current, previous, and next images
    for (int i = -1; i <= 1; i++) {
      final index = _currentIndex + i;
      if (index >= 0 && index < _count && !_imageCache.containsKey(index)) {
        unawaited(_loadImage(index));
      }
    }
  }

  Future<void> _loadImage(int index) async {
    if (_imageCache.containsKey(index)) return;

    try {
      final bytes = await widget.files![index].readAsBytes();
      if (mounted) {
        setState(() {
          _imageCache[index] = bytes;
        });
      }
    } catch (e) {
      debugPrint('Failed to load image $index: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / $_count'),
        centerTitle: true,
        actions: [
          if (widget.onDelete != null)
            FButton.icon(
              variant: .ghost,
              onPress: () => _showDeleteConfirmation(),
              child: const Icon(FLucideIcons.trash2, size: 20),
            ),
        ],
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: _getImageProvider(index),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.5,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            heroAttributes: PhotoViewHeroAttributes(tag: _heroTag(index)),
          );
        },
        itemCount: _count,
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: Colors.white,
          ),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Web platform: preload adjacent images when page changes
          if (kIsWeb && widget.files != null) {
            _preloadImages();
          }
        },
      ),
    );
  }

  String _heroTag(int index) {
    if (widget.heroTag != null) return widget.heroTag!(index);
    return 'image_$index';
  }

  /// Get image provider
  /// iOS/Android: use efficient FileImage
  /// Web: use MemoryImage
  /// Custom: delegate to [imageProvider]
  ImageProvider _getImageProvider(int index) {
    if (widget.imageProvider != null) {
      return widget.imageProvider!(index);
    }

    final image = widget.files![index];

    if (kIsWeb) {
      // Web platform: use cached byte data
      if (_imageCache.containsKey(index)) {
        return MemoryImage(_imageCache[index]!);
      }
      // If not loaded yet, trigger loading and return a temporary empty image
      unawaited(_loadImage(index));
      return MemoryImage(Uint8List(0));
    } else {
      // iOS/Android: use efficient FileImage
      return FileImage(File(image.path));
    }
  }

  void _showDeleteConfirmation() {
    unawaited(
      showConfirmDialog(
        context: context,
        title: t.image.deleteTitle,
        message: t.image.deleteConfirm,
        confirmLabel: t.common.delete,
        onConfirm: () async {
          _deleteCurrentImage();
        },
      ),
    );
  }

  void _deleteCurrentImage() {
    if (widget.onDelete != null) {
      widget.onDelete!(_currentIndex);
      Navigator.of(context).pop();
    }
  }
}
