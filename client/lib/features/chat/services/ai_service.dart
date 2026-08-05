import 'package:logging/logging.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/network/dio_provider.dart' show dioProvider;
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';

/// AI Service for chat operations against the backend.
///
/// Streaming responses are handled by the GenUI layer ([CustomContentGenerator]);
/// this service only exposes the non-streaming operations still in use.
class AIService {
  final _logger = Logger('AIService');
  final SecureStorageService _storageService;
  final Dio _dio;
  final String _baseUrl;

  AIService(this._storageService, this._dio, {required this._baseUrl});

  /// Cancel the last turn and clean up checkpoint state.
  Future<bool> cancelLastTurn(String sessionId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        _logger.info('AIService: cancelLastTurn - No auth token');
        return false;
      }

      final url = '$_baseUrl/chatbot/sessions/$sessionId/cancel';

      _logger.info(
        'AIService: Calling cancel endpoint for session: $sessionId',
      );

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['code'] == 0) {
          final data = body['data'] as Map<String, dynamic>?;
          final removedCount = data?['removed_count'] ?? 0;
          _logger.info(
            'AIService: Cancel successful, removed $removedCount messages',
          );
          return true;
        }
      }
      _logger.info('AIService: Cancel failed - ${response.statusMessage}');
      return false;
    } catch (e, stackTrace) {
      _logger.info('AIService: cancelLastTurn error', e, stackTrace);
      return false;
    }
  }
}

// AIService Provider
final aiServiceProvider = Provider<AIService>((ref) {
  final storageService = ref.watch(secureStorageServiceProvider);
  // Use the main Dio instance so error mapping / interceptors apply.
  final dio = ref.watch(dioProvider);
  final apiConstants = ref.watch(apiConstantsProvider);
  return AIService(storageService, dio, baseUrl: apiConstants.baseUrl);
});
