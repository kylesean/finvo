import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/chat/models/attachment_signed_url_result.dart';
import 'package:finvo/features/chat/models/chat_message_attachment.dart';

final _logger = Logger('FileAttachmentService');

class FileAttachmentService {
  final NetworkClient _networkClient;

  FileAttachmentService(this._networkClient);

  Future<AttachmentSignedUrlResult> fetchSignedUrls(
    List<ChatMessageAttachment> attachments,
  ) async {
    if (attachments.isEmpty) {
      return emptyAttachmentSignedUrlResult;
    }

    try {
      final response = await _networkClient.request<Map<String, dynamic>>(
        '/files/signed-urls',
        method: HttpMethod.post,
        data: {
          'attachments': attachments
              .map(
                (attachment) => {
                  'attachment_id': attachment.id,
                  // Prefer the server-provided storage key; fall back to the
                  // display filename only when the key is unknown.
                  'object_key': attachment.objectKey ?? attachment.filename,
                },
              )
              .toList(),
        },
        fromJsonT: (json) {
          if (json is Map<String, dynamic>) {
            return json;
          }
          throw DataParsingException(
            'API /files/signed-urls returned unexpected payload ${json.runtimeType}',
          );
        },
      );

      return attachmentSignedUrlResultFromJson(response);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.warning(
        'FileAttachmentService: fetchSignedUrls failed: $e',
        e,
        stackTrace,
      );
      throw NetworkException('Failed to fetch signed URLs: $e');
    }
  }
}

final fileAttachmentServiceProvider = Provider<FileAttachmentService>((ref) {
  final client = ref.watch(networkClientProvider);
  return FileAttachmentService(client);
});
