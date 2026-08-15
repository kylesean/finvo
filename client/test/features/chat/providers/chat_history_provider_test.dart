// Provider-level integration tests for ChatHistory.loadConversation.
//
// Uses real ConversationService/FileAttachmentService/HistoricalMessageProcessor
// over a deterministic fake Dio transport, so the whole parse pipeline
// (envelope unwrap, ChatMessage.fromJson, history processing, i18n fallbacks)
// is exercised — not just mocked seams. Only the transport is faked.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/dio_provider.dart' show sseDioProvider;
import 'package:finvo/core/constants/api_constants.dart'
    show sseBaseUrlProvider;
import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Deterministic fake Dio transport that routes every request through
/// [handler] and returns canned JSON without touching the network.
class _FakeDioAdapter implements HttpClientAdapter {
  _FakeDioAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

const _jsonHeaders = {
  Headers.contentTypeHeader: ['application/json'],
};

ResponseBody _jsonResponse(Object body, [int status = 200]) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: _jsonHeaders);

void main() {
  late Dio dio;
  late ProviderContainer container;
  late _FakeDioAdapter adapter;

  setUp(() {
    adapter = _FakeDioAdapter((_) async => fail('Unexpected request'));
    dio = Dio()..httpClientAdapter = adapter;
    container = ProviderContainer(
      overrides: [
        // Bare transport over the fake adapter: no interceptors, no real IO.
        networkClientProvider.overrideWithValue(NetworkClient(dio)),
        sseDioProvider.overrideWithValue(dio),
        sseBaseUrlProvider.overrideWithValue('ws://test/chatbot/chat'),
      ],
    );
    addTearDown(container.dispose);
  });

  ChatHistory notifier() => container.read(chatHistoryProvider.notifier);

  /// Let the unawaited build-time GenUI init microtask settle so late async
  /// errors (if any) are surfaced inside the test body rather than leaking.
  Future<void> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  Map<String, Object?> detailPayload({
    required String id,
    required String title,
    required List<Map<String, Object?>> messages,
  }) {
    return {
      'data': {
        'id': id,
        'title': title,
        'updatedAt': '2026-01-01T00:00:00Z',
        'messages': messages,
      },
    };
  }

  group('ChatHistory.loadConversation', () {
    test('loads detail, title and historical messages', () async {
      adapter = _FakeDioAdapter((options) async {
        final path = options.path;
        if (path == '/chatbot/sessions/conv-1/messages') {
          return _jsonResponse(
            detailPayload(
              id: 'conv-1',
              title: 'Trip Budget',
              messages: [
                <String, Object?>{
                  'id': 'm1',
                  'content': 'hello',
                  'role': 'user',
                },
                <String, Object?>{
                  'id': 'm2',
                  'content': 'hi there',
                  'role': 'assistant',
                },
              ],
            ),
          );
        }
        if (path == '/chatbot/sessions/conv-1/resume-status') {
          return _jsonResponse({
            'data': {'canResume': false, 'nextNodes': <String>[]},
          });
        }
        fail('Unexpected request: $path');
      });
      dio.httpClientAdapter = adapter;

      await settle();
      await notifier().loadConversation('conv-1');

      final state = container.read(chatHistoryProvider);
      expect(state.currentConversationId, 'conv-1');
      expect(state.currentConversationTitle, 'Trip Budget');
      expect(state.messages.map((m) => m.id), containsAll(['m1', 'm2']));
      expect(
        state.messages.firstWhere((m) => m.id == 'm2').content,
        'hi there',
      );
      expect(state.isLoadingHistory, isFalse);
      expect(state.historyError, isNull);
      // detail + resume-status were both fetched through the real service.
      expect(adapter.requestCount, 2);
    });

    test(
      'a stale in-flight response never overwrites the newer session',
      () async {
        final gateA = Completer<void>();
        adapter = _FakeDioAdapter((options) async {
          final path = options.path;
          if (path == '/chatbot/sessions/conv-a/messages') {
            await gateA.future;
            return _jsonResponse(
              detailPayload(
                id: 'conv-a',
                title: 'Old',
                messages: [
                  <String, Object?>{
                    'id': 'a1',
                    'content': 'old data',
                    'role': 'user',
                  },
                ],
              ),
            );
          }
          if (path == '/chatbot/sessions/conv-b/messages') {
            return _jsonResponse(
              detailPayload(
                id: 'conv-b',
                title: 'New',
                messages: [
                  <String, Object?>{
                    'id': 'b1',
                    'content': 'new data',
                    'role': 'user',
                  },
                ],
              ),
            );
          }
          if (path == '/chatbot/sessions/conv-b/resume-status') {
            return _jsonResponse({
              'data': {'canResume': false, 'nextNodes': <String>[]},
            });
          }
          fail('Unexpected request: $path');
        });
        dio.httpClientAdapter = adapter;

        await settle();
        // Start loading conv-a (blocks on the gate) then switch to conv-b.
        final futureA = notifier().loadConversation('conv-a');
        await Future<void>.delayed(const Duration(milliseconds: 5));
        final futureB = notifier().loadConversation('conv-b');
        await futureB;
        gateA.complete();
        await futureA;

        final state = container.read(chatHistoryProvider);
        expect(state.currentConversationId, 'conv-b');
        expect(state.currentConversationTitle, 'New');
        expect(state.messages.map((m) => m.id), contains('b1'));
        expect(state.messages.map((m) => m.id), isNot(contains('a1')));
      },
    );

    test(
      'surfaces an error state (not a crash) when the detail fetch fails',
      () async {
        adapter = _FakeDioAdapter((options) async {
          // 400 is not retried by NetworkClient (only idempotent retryable
          // statuses are), so this fails fast without backoff.
          return _jsonResponse({
            'code': 400,
            'message': 'boom',
            'data': null,
          }, 400);
        });
        dio.httpClientAdapter = adapter;

        await settle();
        await notifier().loadConversation('conv-1');

        final state = container.read(chatHistoryProvider);
        expect(state.isLoadingHistory, isFalse);
        expect(state.historyError, isNotNull);
        expect(state.currentConversationTitle, t.common.loadFailed);
      },
    );
  });
}
