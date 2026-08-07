import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/chat/providers/conversation_search_state.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';

part 'conversation_search_service.g.dart';

/// Conversation search service
class ConversationSearchService {
  final NetworkClient _networkClient;

  ConversationSearchService(this._networkClient);

  /// Search conversation history
  Future<List<ConversationSearchResult>> searchConversations(
    String query,
  ) async {
    // Only execute search when there are keywords
    return _apiSearchConversations(query);
  }

  /// Real API search implementation
  Future<List<ConversationSearchResult>> _apiSearchConversations(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _networkClient.request<dynamic>(
        '/chatbot/sessions/messages/search',
        method: HttpMethod.get,
        queryParameters: {'q': query.trim(), 'limit': 20},
        fromJsonT: (json) =>
            json, // Return raw data directly, no type conversion
      );

      // Handle different response formats
      List<dynamic> results;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          results = response['data'] as List<dynamic>? ?? [];
        } else {
          results = [];
        }
      } else if (response is List<dynamic>) {
        results = response;
      } else {
        results = [];
      }

      return results.map((item) {
        if (item is! Map<String, dynamic>) {
          throw DataParsingException(
            'Conversation search returned a non-map item',
          );
        }
        final data = item;

        // Defensive parsing: the server may omit fields or return non-string
        // types, so a strict `as String` cast would throw a TypeError deep
        // inside the map and abort the whole search. Normalise missing/typed
        // values instead of crashing.
        final String id = _stringField(data, 'id');
        final String title = _stringField(data, 'title');
        final String snippet = _stringField(data, 'snippet');
        final String? messageId = _nullableStringField(data, 'messageId');

        // Generate highlight ranges
        final highlights = _generateHighlights(
          query: query,
          title: title,
          snippet: snippet,
        );

        return ConversationSearchResult(
          id: id,
          title: title,
          snippet: snippet,
          messageId: messageId,
          createdAt: _dateTimeField(data, 'createdAt'),
          updatedAt: _dateTimeField(data, 'updatedAt'),
          highlights: highlights,
        );
      }).toList();
    } catch (e) {
      // Preserve the original error type (e.g. DataParsingException) instead of
      // wrapping everything in a bare Exception that flattens the type and
      // leaks the raw message into the UI. Network failures are already
      // normalised by the interceptor; here we only rethrow.
      if (e is DataParsingException) rethrow;
      throw DataParsingException('Failed to search conversations: $e');
    }
  }

  /// Read a required string field, defaulting to '' instead of crashing when
  /// the key is absent or has a non-string value.
  String _stringField(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return '';
    return value is String ? value : value.toString();
  }

  /// Read an optional string field, returning null when absent.
  String? _nullableStringField(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    return value is String ? value : value.toString();
  }

  /// Read an optional ISO-8601 timestamp, tolerating malformed values instead
  /// of throwing FormatException and aborting the whole search.
  DateTime? _dateTimeField(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    return DateTime.tryParse(value is String ? value : value.toString());
  }

  /// Generate highlight ranges
  List<HighlightRange> _generateHighlights({
    required String query,
    required String title,
    required String snippet,
  }) {
    final highlights = <HighlightRange>[];
    final queryLower = query.toLowerCase();

    // Find matches in title
    final titleLower = title.toLowerCase();
    int titleIndex = 0;
    while (titleIndex < titleLower.length) {
      final index = titleLower.indexOf(queryLower, titleIndex);
      if (index == -1) break;

      highlights.add(
        HighlightRange(start: index, end: index + query.length, field: 'title'),
      );
      titleIndex = index + query.length;
    }

    // Find matches in snippet
    final snippetLower = snippet.toLowerCase();
    int snippetIndex = 0;
    while (snippetIndex < snippetLower.length) {
      final index = snippetLower.indexOf(queryLower, snippetIndex);
      if (index == -1) break;

      highlights.add(
        HighlightRange(
          start: index,
          end: index + query.length,
          field: 'snippet',
        ),
      );
      snippetIndex = index + query.length;
    }

    return highlights;
  }
}

/// Conversation search service provider
@riverpod
ConversationSearchService conversationSearchService(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ConversationSearchService(networkClient);
}
