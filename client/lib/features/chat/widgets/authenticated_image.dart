// features/chat/widgets/authenticated_image.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:dio/dio.dart';

import 'package:finvo/core/network/dio_provider.dart';

/// Authenticated image loading component
/// Automatically attaches JWT token when requesting images
class AuthenticatedImage extends ConsumerStatefulWidget {
  final String attachmentId;
  final BoxFit fit;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AuthenticatedImage({
    super.key,
    required this.attachmentId,
    this.fit = BoxFit.cover,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  ConsumerState<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends ConsumerState<AuthenticatedImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadImage());
  }

  @override
  void didUpdateWidget(covariant AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachmentId != widget.attachmentId) {
      unawaited(_loadImage());
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _imageBytes = null;
    });

    try {
      // Use the shared Dio pipeline (auth interceptor attaches the JWT,
      // timeouts/cancellation and error normalization come for free).
      // Previously this created a bare Dio() per load, bypassing the
      // interceptor chain: no timeout, no cancel, and 401 responses were
      // never re-signed.
      final dio = ref.read(dioProvider);
      final response = await dio.get<List<int>>(
        '/files/view/${widget.attachmentId}',
        options: Options(responseType: ResponseType.bytes),
      );

      if (!mounted) return;

      if (response.data != null) {
        setState(() {
          _imageBytes = Uint8List.fromList(response.data!);
          _isLoading = false;
        });
      } else {
        throw Exception('Image data is empty');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      if (widget.loadingBuilder != null) {
        return widget.loadingBuilder!(context, Container(), null);
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, null);
      }
      return Center(
        child: Icon(
          FLucideIcons.imageOff,
          color: context.theme.colors.destructive,
        ),
      );
    }

    if (_imageBytes == null) {
      return const SizedBox.shrink();
    }

    // Downscale the decoded bitmap to the actual display size: full-size
    // decoding of large photos wastes memory and hurts scroll performance.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final cacheWidth = maxWidth.isFinite && maxWidth > 0
            ? (maxWidth * MediaQuery.devicePixelRatioOf(context)).round()
            : null;
        return Image.memory(
          _imageBytes!,
          fit: widget.fit,
          gaplessPlayback: true,
          cacheWidth: cacheWidth,
        );
      },
    );
  }
}
