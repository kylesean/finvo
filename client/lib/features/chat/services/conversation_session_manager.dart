// features/chat/services/conversation_session_manager.dart
//
// Conversation-session loading orchestration, extracted from ChatHistory so
// the provider reads as a thin facade over managers (same pattern as
// ChatInteractionManager). Owns the network fetch, the switch-race guard and
// the (non-critical) resume probe; state application stays with the provider
// via narrow per-call callbacks.

import 'package:logging/logging.dart';

import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/services/conversation_service.dart';
import 'package:finvo/features/chat/services/historical_message_processor.dart';

// ignore_for_file: prefer_initializing_formals - private fields with public named ctor params

final _logger = Logger('ConversationSessionManager');

/// Outcome of a successfully applied conversation-detail load.
class ConversationSessionLoadResult {
  final List<ChatMessage> messages;
  final String title;

  const ConversationSessionLoadResult({
    required this.messages,
    required this.title,
  });
}

/// Conversation Session Manager
///
/// Responsibilities:
/// - Fetch and process a conversation's historical detail
/// - Guard the switch-race: a stale in-flight response must never overwrite a
///   newer session's messages/title (the provider's [isCurrent] callback is
///   the source of truth for "still active")
/// - Probe server-side resumability (detection only; failures are
///   non-critical and swallowed at info level)
class ConversationSessionManager {
  /// Resolver-style accessor (same shape as `sseBaseUrlResolver`): the
  /// provider re-reads the conversation service at call time, so a server
  /// switch takes effect on the very next load instead of the manager
  /// holding a stale service for its whole lifetime.
  final ConversationService Function() _conversationService;
  final HistoricalMessageProcessor _historicalProcessor;

  ConversationSessionManager({
    required ConversationService Function() conversationService,
    required HistoricalMessageProcessor historicalProcessor,
  }) : _conversationService = conversationService,
       _historicalProcessor = historicalProcessor;

  /// Fetch, process and hand the applied detail back to the provider.
  ///
  /// [isCurrent] is consulted before applying: if the user switched to another
  /// conversation while this request was in flight, the stale response is
  /// dropped. [onError] is only invoked when this request is still current,
  /// so a superseded failure never marks the newer session as failed.
  Future<void> loadConversationDetail(
    String conversationId, {
    required bool Function() isCurrent,
    required void Function(ConversationSessionLoadResult result) onLoaded,
    required void Function(Object error) onError,
  }) async {
    try {
      final conversationDetail = await _conversationService()
          .getConversationDetail(conversationId);

      // Guard against the switch-race: a stale response must not overwrite
      // the newer conversation's messages/title.
      if (!isCurrent()) {
        _logger.info(
          'ConversationSessionManager: discarding stale conversation detail '
          'for $conversationId (session switched)',
        );
        return;
      }

      onLoaded(
        ConversationSessionLoadResult(
          messages: _historicalProcessor.processHistoricalMessages(
            conversationDetail.messages,
          ),
          title: conversationDetail.title,
        ),
      );
    } catch (e) {
      // Only surface errors for the conversation that is still current.
      if (!isCurrent()) return;
      _logger.warning(
        'ConversationSessionManager: Failed to load conversation '
        '$conversationId: $e',
      );
      onError(e);
    }
  }

  /// Probe whether the server can resume this session's graph state.
  ///
  /// Detection only for now — the resumable signal is observed but not yet
  /// acted upon. A failed probe is non-critical and must never break the
  /// conversation load, so it is swallowed at info level.
  Future<void> checkAndResumeIfNeeded(String conversationId) async {
    try {
      final resumeStatus = await _conversationService().getResumeStatus(
        conversationId,
      );
      if (resumeStatus.canResume) {
        _logger.info(
          'ConversationSessionManager: Detected resumable state for '
          '$conversationId, nextNodes: ${resumeStatus.nextNodes}',
        );
      }
    } catch (e) {
      _logger.info(
        'ConversationSessionManager: Resume status check failed '
        '(non-critical): $e',
      );
    }
  }
}
