import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/shared/services/response_parser.dart';
import 'package:finvo/features/chat/models/conversation_info.dart';
import 'package:finvo/features/chat/models/paginated_conversations.dart';
import 'package:finvo/features/chat/models/conversation_detail.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/chat/models/chat_message.dart';

part 'conversation_service.g.dart';

final _logger = Logger('ConversationService');

/// Parse datetime string with compatibility for non-standard ISO 8601 formats.
/// Handles formats like "2025-12-27T07:07:20.586784+00:00Z" where both offset
/// and Z are present.
///
/// Prefer parsing directly; only fall back to stripping a redundant trailing
/// 'Z' when the standard parser rejects the input. This avoids the previous
/// heuristic string scanning, which could misfire on unrelated characters.
DateTime _parseDateTime(String dateStr) {
  try {
    return DateTime.parse(dateStr);
  } on FormatException {
    if (dateStr.endsWith('Z')) {
      return DateTime.parse(dateStr.substring(0, dateStr.length - 1));
    }
    rethrow;
  }
}

class ConversationService {
  final NetworkClient _networkClient;

  ConversationService(this._networkClient);

  static const PaginatedConversations _emptyConversations =
      PaginatedConversations(
        data: [],
        meta: ConversationMeta(
          currentPage: 1,
          lastPage: 1,
          perPage: 10,
          total: 0,
          hasMore: false,
        ),
      );

  /// Parse a session list payload into a [PaginatedConversations].
  ///
  /// Accepts both an empty/null payload (yielding an empty page) and the
  /// unified pagination envelope produced by the backend
  /// (`items` / `page` / `size` / `total` / `pages` / `hasMore`).
  PaginatedConversations _parseConversationsData(
    Map<String, dynamic> data, {
    required int page,
    required int perPage,
  }) {
    if (data.isEmpty) return _emptyConversations;

    final itemsData = data['items'] as List<dynamic>? ?? [];
    final conversations = itemsData
        .map(
          (session) => _parseConversationInfo(session as Map<String, dynamic>),
        )
        .toList();

    final int totalPages = data['pages'] as int? ?? 1;
    final int size = data['size'] as int? ?? perPage;
    final int total = data['total'] as int? ?? conversations.length;

    return PaginatedConversations(
      data: conversations,
      meta: ConversationMeta(
        currentPage: data['page'] as int? ?? page,
        lastPage: totalPages,
        perPage: size,
        total: total,
        // Backend may omit hasMore; derive it from the page window instead of
        // silently defaulting to false (which would hide further pages).
        hasMore: data['hasMore'] as bool? ?? (page < totalPages),
      ),
    );
  }

  ConversationInfo _parseConversationInfo(Map<String, dynamic> session) {
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();

    if (session['created_at'] != null &&
        session['created_at'].toString().isNotEmpty) {
      try {
        createdAt = _parseDateTime(session['created_at'] as String);
      } catch (e, stackTrace) {
        _logger.warning('Error parsing created_at', e, stackTrace);
      }
    }

    if (session['updated_at'] != null &&
        session['updated_at'].toString().isNotEmpty) {
      try {
        updatedAt = _parseDateTime(session['updated_at'] as String);
      } catch (e, stackTrace) {
        _logger.warning('Error parsing updated_at', e, stackTrace);
      }
    }

    return ConversationInfo(
      id: session['session_id'] as String,
      title: session['name'] as String? ?? 'New Chat',
      createdAt: createdAt,
      updatedAt: updatedAt,
      token: session['token'] as String?,
    );
  }

  /// Get paginated conversation list
  Future<PaginatedConversations> getConversationList({
    int page = 1,
    int perPage = 10,
  }) async {
    _logger.info(
      'ConversationService: Starting getConversationList API call for page $page...',
    );
    final envelope = await _networkClient.requestMap(
      '/auth/sessions',
      method: HttpMethod.get,
      queryParameters: {'page': page, 'size': perPage},
    );
    final data = ResponseParser.parseData<Map<String, dynamic>>(
      envelope,
      whenNull: () => {},
    );
    return _parseConversationsData(data, page: page, perPage: perPage);
  }

  Future<List<ConversationInfo>> getSimpleConversationList({
    int page = 1,
    int perPage = 10,
  }) async {
    final paginatedResult = await getConversationList(
      page: page,
      perPage: perPage,
    );
    return paginatedResult.data;
  }

  Future<ConversationDetail> getConversationDetail(
    String conversationId,
  ) async {
    _logger.info('Fetching conversation detail for: $conversationId');

    final envelope = await _networkClient.requestMap(
      '/chatbot/sessions/$conversationId/messages',
      method: HttpMethod.get,
    );
    final data = ResponseParser.parseItem<Map<String, dynamic>>(
      envelope,
      (map) => map,
    );

    final messages = (data['messages'] as List? ?? []).map((msg) {
      if (msg is Map<String, dynamic>) {
        return ChatMessage.fromJson(msg);
      }
      throw DataParsingException('Invalid message format');
    }).toList();

    // Parse the server-provided updated_at timestamp. Fall back to now if
    // it is missing or malformed so conversation ordering stays accurate.
    DateTime updatedAt = DateTime.now();
    if (data['updated_at'] != null &&
        data['updated_at'].toString().isNotEmpty) {
      try {
        updatedAt = _parseDateTime(data['updated_at'] as String);
      } catch (e, stackTrace) {
        _logger.warning('Error parsing conversation updated_at', e, stackTrace);
      }
    }

    return ConversationDetail(
      id: data['session_id'] as String? ?? conversationId,
      title: data['title'] as String? ?? 'Chat',
      updatedAt: updatedAt,
      messages: messages,
    );
  }

  Future<ResumeStatus> getResumeStatus(String sessionId) async {
    final envelope = await _networkClient.requestMap(
      '/chatbot/sessions/$sessionId/resume-status',
      method: HttpMethod.get,
    );
    final data = ResponseParser.parseData<Map<String, dynamic>>(
      envelope,
      whenNull: () => {},
    );
    return ResumeStatus(
      canResume: data['canResume'] as bool? ?? false,
      nextNodes:
          (data['nextNodes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Delete a conversation/session by ID
  /// This performs cascade deletion on the server:
  /// - Session metadata
  /// - LangGraph checkpoints
  /// - Searchable messages
  ///
  /// Throws on failure instead of returning a bool: swallowing the exception
  /// here would hide the concrete error cause from every call site.
  Future<void> deleteConversation(String sessionId) async {
    await _networkClient.requestMap(
      '/auth/session/$sessionId',
      method: HttpMethod.delete,
    );
    _logger.info('Conversation deleted: $sessionId');
  }
}

class ResumeStatus {
  final bool canResume;
  final List<String> nextNodes;

  const ResumeStatus({required this.canResume, required this.nextNodes});
}

@riverpod
ConversationService conversationService(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ConversationService(networkClient);
}

@riverpod
Future<List<ConversationInfo>> conversationList(Ref ref) async {
  ref.watch(authTokenProvider);
  final service = ref.watch(conversationServiceProvider);
  return service.getSimpleConversationList();
}
