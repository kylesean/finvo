import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../models/media_file.dart';

/// Full-screen image viewer
/// Uses photo_view for image zoom and drag, supports multi-image swipe navigation
/// iOS/Android: uses efficient FileImage
/// Web: uses NetworkImage (since MediaFile.path is typically a server URL)
class ImageFullScreenViewer extends StatefulWidget {
  /// Image file list
  final List<MediaFile> imageFiles;

  /// Initial image index to display
  final int initialIndex;

  const ImageFullScreenViewer({
    super.key,
    required this.imageFiles,
    this.initialIndex = 0,
  });

  /// Show full-screen image viewer
  static Future<void> show(
    BuildContext context, {
    required List<MediaFile> imageFiles,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageFullScreenViewer(
          imageFiles: imageFiles,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ImageFullScreenViewer> createState() => _ImageFullScreenViewerState();
}

class _ImageFullScreenViewerState extends State<ImageFullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // Ensure initial index is within valid range
    _currentIndex = widget.imageFiles.isEmpty
        ? 0
        : (widget.initialIndex >= 0 &&
              widget.initialIndex < widget.imageFiles.length)
        ? widget.initialIndex
        : 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty list case
    if (widget.imageFiles.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: Text(
                  'No images to display',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Positioned(
                top: 8,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image viewer body
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final imageFile = widget.imageFiles[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: _getImageProvider(imageFile),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.0,
                heroAttributes: PhotoViewHeroAttributes(tag: imageFile.id),
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            itemCount: widget.imageFiles.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: _pageController,
            onPageChanged: (index) {
              if (mounted && index >= 0 && index < widget.imageFiles.length) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),

          // Top toolbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Close button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const Spacer(),

                    // Image counter
                    if (widget.imageFiles.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.imageFiles.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom image info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _buildImageInfo(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build image info widget
  Widget _buildImageInfo() {
    if (widget.imageFiles.isEmpty ||
        _currentIndex < 0 ||
        _currentIndex >= widget.imageFiles.length) {
      return const SizedBox.shrink();
    }

    final currentImage = widget.imageFiles[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          currentImage.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _formatFileSize(currentImage.size),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Get image provider
  /// MediaFile.path is typically a server URL, so use NetworkImage
  /// For local file paths, use FileImage on iOS/Android
  ImageProvider _getImageProvider(MediaFile imageFile) {
    final path = imageFile.path;

    // If network URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    // If local file path
    if (kIsWeb) {
      // Web platform: local file path unavailable, try using as URL
      return NetworkImage(path);
    } else {
      // iOS/Android: use efficient FileImage
      return FileImage(File(path));
    }
  }

  /// Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
