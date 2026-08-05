import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/repositories/message_repository.dart';

void main() {
  group('MessageRepository streaming content', () {
    late List<ChatMessage> messages;
    late MessageRepository repo;

    setUp(() {
      messages = [
        const ChatMessage(id: 'msg1', sender: MessageSender.ai, content: ''),
      ];
      repo = MessageRepository(
        onMessagesChanged: (updated) => messages = updated,
        getCurrentMessages: () => messages,
      );
    });

    ChatMessage current() => messages.first;

    test('contentDelta appends incrementally', () {
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'Hello ');
      expect(current().content, 'Hello ');
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'world!');
      expect(current().content, 'Hello world!');
    });

    test('full content update resets the incremental buffer', () {
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'stale ');
      repo.updateAiMessageState(id: 'msg1', content: 'replaced');
      expect(current().content, 'replaced');
      repo.updateAiMessageState(id: 'msg1', contentDelta: ' +delta');
      expect(current().content, 'replaced +delta');
    });

    test('updateMessageId migrates the incremental buffer', () {
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'partial ');
      repo.updateMessageId('msg1', 'persisted-1');
      repo.updateAiMessageState(id: 'persisted-1', contentDelta: 'tail');
      expect(current().id, 'persisted-1');
      expect(current().content, 'partial tail');
    });

    test('clearContentBuffer drops accumulated text', () {
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'temp');
      repo.clearContentBuffer('msg1');
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'fresh');
      expect(current().content, 'fresh');
    });

    test('interleaved text keeps trailing UI components last', () {
      messages = [
        const ChatMessage(id: 'msg1', sender: MessageSender.ai, content: ''),
      ];
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'A');
      repo.updateAiMessageState(id: 'msg1', content: 'AB');
      repo.updateAiMessageState(id: 'msg1', contentDelta: 'C');
      expect(current().content, 'ABC');
    });
  });
}
