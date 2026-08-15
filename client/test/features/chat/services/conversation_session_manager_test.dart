import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/models/conversation_detail.dart';
import 'package:finvo/features/chat/services/conversation_service.dart';
import 'package:finvo/features/chat/services/conversation_session_manager.dart';
import 'package:finvo/features/chat/services/historical_message_processor.dart';
import 'package:finvo/core/network/network_client.dart';

/// Real [ConversationService] subclass whose two used methods are stubbed;
/// the inherited [NetworkClient] is never touched.
class _FakeConversationService extends ConversationService {
  _FakeConversationService() : super(NetworkClient(Dio()));

  Object? detailError;
  Object? resumeError;
  bool canResume = false;

  @override
  Future<ConversationDetail> getConversationDetail(
    String conversationId,
  ) async {
    final err = detailError;
    if (err != null) throw err;
    return ConversationDetail(
      id: conversationId,
      title: 'Title $conversationId',
      updatedAt: DateTime.utc(2026, 1, 1),
      messages: [
        const ChatMessage(
          id: 'm1',
          content: 'first',
          sender: MessageSender.user,
        ),
        const ChatMessage(
          id: 'm2',
          content: 'second',
          sender: MessageSender.ai,
        ),
      ],
    );
  }

  @override
  Future<ResumeStatus> getResumeStatus(String sessionId) async {
    final err = resumeError;
    if (err != null) throw err;
    return ResumeStatus(canResume: canResume, nextNodes: const []);
  }
}

void main() {
  late _FakeConversationService service;
  late ConversationSessionManager manager;

  setUp(() {
    service = _FakeConversationService();
    manager = ConversationSessionManager(
      conversationService: () => service,
      historicalProcessor: HistoricalMessageProcessor(),
    );
  });

  group('ConversationSessionManager.loadConversationDetail', () {
    test(
      'loads, processes and hands back the detail when still current',
      () async {
        ConversationSessionLoadResult? result;
        await manager.loadConversationDetail(
          'c1',
          isCurrent: () => true,
          onLoaded: (r) => result = r,
          onError: (_) => fail('onError must not fire on success'),
        );

        expect(result, isNotNull);
        expect(result!.title, 'Title c1');
        expect(result!.messages.map((m) => m.id), containsAll(['m1', 'm2']));
        expect(
          result!.messages.firstWhere((m) => m.id == 'm2').content,
          'second',
        );
      },
    );

    test('drops a stale response after a session switch', () async {
      var onLoadedCalls = 0;
      var onErrorCalls = 0;
      await manager.loadConversationDetail(
        'c1',
        isCurrent: () => false, // the user switched away mid-flight
        onLoaded: (_) => onLoadedCalls++,
        onError: (_) => onErrorCalls++,
      );

      expect(onLoadedCalls, 0);
      expect(onErrorCalls, 0);
    });

    test(
      'surfaces the error only while the request is still current',
      () async {
        service.detailError = Exception('boom');
        Object? reported;
        await manager.loadConversationDetail(
          'c1',
          isCurrent: () => true,
          onLoaded: (_) => fail('onLoaded must not fire on error'),
          onError: (e) => reported = e,
        );

        expect(reported, isA<Exception>());
      },
    );

    test('swallows errors for a superseded request', () async {
      service.detailError = Exception('boom');
      var onErrorCalls = 0;
      await manager.loadConversationDetail(
        'c1',
        isCurrent: () => false,
        onLoaded: (_) => fail('onLoaded must not fire'),
        onError: (_) => onErrorCalls++,
      );

      expect(onErrorCalls, 0);
    });
  });

  group('ConversationSessionManager.checkAndResumeIfNeeded', () {
    test('does not throw when the probe fails (non-critical)', () async {
      service.resumeError = Exception('resume unavailable');
      await manager.checkAndResumeIfNeeded('c1'); // must complete cleanly
    });

    test('does not throw on a resumable probe', () async {
      service.canResume = true;
      await manager.checkAndResumeIfNeeded('c1'); // must complete cleanly
    });
  });
}
