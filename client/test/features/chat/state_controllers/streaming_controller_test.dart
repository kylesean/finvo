import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:finvo/features/chat/state_controllers/streaming_controller.dart';
import 'package:finvo/features/chat/state_controllers/stream_state_controller.dart';
import 'package:finvo/features/chat/services/genui_service.dart';
import 'package:finvo/features/chat/models/chat_message.dart';

import 'streaming_controller_test.mocks.dart';

@GenerateMocks([GenUiService])
void main() {
  late StreamingController controller;
  late StreamStateController streamState;
  late MockGenUiService mockGenUiService;

  // Callbacks

  late String? lastDelayExceededReceived;
  late String? lastStreamCompleteFinalText;
  late dynamic lastStreamError;

  setUp(() {
    streamState = StreamStateController();
    mockGenUiService = MockGenUiService();

    // Reset callback trackers
    lastDelayExceededReceived = null;
    lastStreamCompleteFinalText = null;
    lastStreamError = null;

    controller = StreamingController(
      config: const StreamingConfig(
        initialDelayMs: 100,
      ), // Short delay for testing
      streamState: streamState,
      callbacks: StreamingCallbacks(
        onUpdateMessageState:
            ({
              required String id,
              String? content,
              bool? isTyping,
              StreamingStatus? streamingStatus,
            }) {},
        getCurrentMessageContent: (id) => 'Current Content',
        onInitialDelayExceeded: () {
          lastDelayExceededReceived = 'Exceeded';
        },
        onStreamComplete: (finalText) {
          lastStreamCompleteFinalText = finalText;
        },
        onStreamError: (error) {
          lastStreamError = error;
        },
        onStreamCancelled: (hasContent) {},
      ),
    );

    controller.setGenUiService(mockGenUiService);
  });

  group('StreamingController', () {
    test(
      'resetForNewMessage should reset internal state and call streamState',
      () {
        controller.resetForNewMessage('msg-1');

        expect(controller.currentMessageId, 'msg-1');
        expect(controller.isStreamDone, false);
        expect(controller.isFirstChunkReceived, false);
        expect(controller.isMessageCompleted, false);
        expect(controller.isUserCancelled, false);

        expect(streamState.currentPhase, StreamPhase.waitingForFirstChunk);
        expect(streamState.currentMessageId, 'msg-1');
      },
    );

    test(
      'updateCurrentMessageId should replace temp ID and keep stream flags',
      () {
        controller.resetForNewMessage('temp-uuid-1');
        controller.handleTextChunk('Hello');

        controller.updateCurrentMessageId('server-msg-1');

        expect(controller.currentMessageId, 'server-msg-1');
        expect(streamState.currentMessageId, 'server-msg-1');
        // Stream flags must be preserved (not reset like resetForNewMessage)
        expect(controller.isFirstChunkReceived, true);
        expect(controller.isMessageCompleted, false);
        expect(controller.isUserCancelled, false);
      },
    );

    test('updateCurrentMessageId should ignore empty or same IDs', () {
      controller.resetForNewMessage('msg-1');

      controller.updateCurrentMessageId('msg-1');
      controller.updateCurrentMessageId('');

      expect(controller.currentMessageId, 'msg-1');
      expect(streamState.currentMessageId, 'msg-1');
    });

    test(
      'startInitialDelayTimer should trigger callback after delay if no chunk received',
      () async {
        controller.startInitialDelayTimer();

        // Wait for delay + buffer
        await Future<void>.delayed(const Duration(milliseconds: 150));

        expect(lastDelayExceededReceived, 'Exceeded');
      },
    );

    test('handleTextChunk should mark first chunk and cancel timer', () async {
      controller.resetForNewMessage('msg-1');
      controller.startInitialDelayTimer();

      // Send first chunk immediately
      final isFirst = controller.handleTextChunk('Hello');

      expect(isFirst, true);
      expect(controller.isFirstChunkReceived, true);
      expect(streamState.currentPhase, StreamPhase.streaming);

      // Wait to ensure timer was cancelled (callback shouldn't fire)
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(lastDelayExceededReceived, null);
    });

    test('handleTextChunk subsequent chunks should return false', () {
      controller.resetForNewMessage('msg-1');
      controller.handleTextChunk('Hello');
      final isFirst = controller.handleTextChunk(' World');

      expect(isFirst, false);
      // First chunk should have advanced the state machine only once
      expect(streamState.currentPhase, StreamPhase.streaming);
    });

    test('handleStreamError should update flags and notify', () {
      controller.handleStreamError('Error');

      expect(controller.isStreamDone, true);
      expect(controller.isMessageCompleted, true);
      expect(streamState.currentPhase, StreamPhase.error);
      expect(lastStreamError, 'Error');
    });

    test(
      'markStreamEnded should update flags without callback notification',
      () {
        controller.markStreamEnded();

        expect(controller.isStreamDone, true);
        expect(controller.isMessageCompleted, true);
        expect(streamState.currentPhase, StreamPhase.completed);
        // Callbacks should NOT be fired
        expect(lastStreamCompleteFinalText, null);
        expect(lastStreamError, null);
      },
    );

    test('markFirstChunkReceived should check flag before updating', () {
      controller.resetForNewMessage('msg-1');
      controller.markFirstChunkReceived();
      expect(controller.isFirstChunkReceived, true);
      expect(streamState.currentPhase, StreamPhase.streaming);

      controller.markFirstChunkReceived();
      // State machine stays in streaming phase
      expect(streamState.currentPhase, StreamPhase.streaming);
    });
  });
}
