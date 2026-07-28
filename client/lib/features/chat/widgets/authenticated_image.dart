// features/chat/widgets/authenticated_image.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'dart:async';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/constants/api_constants.dart';

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
      final storageService = ref.read(secureStorageServiceProvider);
      final token = await storageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final dio = Dio();
      final apiConstants = ref.read(apiConstantsProvider);
      final url = '${apiConstants.baseUrl}/files/view/${widget.attachmentId}';

      final response = await dio.get<List<int>>(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
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
          Icons.error_outline,
          color: context.theme.colors.destructive,
        ),
      );
    }

    if (_imageBytes == null) {
      return const SizedBox.shrink();
    }

    return Image.memory(_imageBytes!, fit: widget.fit, gaplessPlayback: true);
  }
}

/// Authenticated network image provider
/// Used to cache loaded image data
final authenticatedImageProvider = FutureProvider.family<Uint8List, String>((
  ref,
  attachmentId,
) async {
  final storageService = ref.watch(secureStorageServiceProvider);
  final token = await storageService.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Authentication token not found');
  }

  final dio = Dio();
  final apiConstants = ref.watch(apiConstantsProvider);
  final url = '${apiConstants.baseUrl}/files/view/$attachmentId';

  final response = await dio.get<List<int>>(
    url,
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
      responseType: ResponseType.bytes,
    ),
  );

  if (response.data == null) {
    throw Exception('Image data is empty');
  }

  return Uint8List.fromList(response.data!);
});
