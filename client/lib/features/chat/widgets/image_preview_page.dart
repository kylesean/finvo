// features/chat/widgets/image_preview_page.dart
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

/// Image preview page with zoom and swipe navigation support
/// iOS/Android: uses efficient FileImage
/// Web: uses MemoryImage + readAsBytes
class ImagePreviewPage extends StatefulWidget {
  final List<XFile> images;
  final int initialIndex;
  final void Function(int)? onDelete;

  const ImagePreviewPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Web platform: preload current and adjacent images
    if (kIsWeb) {
      _preloadImages();
    }
  }

  void _preloadImages() {
    // Preload current, previous, and next images
    for (int i = -1; i <= 1; i++) {
      final index = _currentIndex + i;
      if (index >= 0 &&
          index < widget.images.length &&
          !_imageCache.containsKey(index)) {
        unawaited(_loadImage(index));
      }
    }
  }

  Future<void> _loadImage(int index) async {
    if (_imageCache.containsKey(index)) return;

    try {
      final bytes = await widget.images[index].readAsBytes();
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
        title: Text('${_currentIndex + 1} / ${widget.images.length}'),
        centerTitle: true,
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(),
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
            heroAttributes: PhotoViewHeroAttributes(tag: 'image_$index'),
          );
        },
        itemCount: widget.images.length,
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
          if (kIsWeb) {
            _preloadImages();
          }
        },
      ),
    );
  }

  /// Get image provider
  /// iOS/Android: use efficient FileImage
  /// Web: use MemoryImage
  ImageProvider _getImageProvider(int index) {
    final image = widget.images[index];

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
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Image'),
            content: const Text('Are you sure you want to delete this image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteCurrentImage();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
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
