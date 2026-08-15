import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/chat/state_controllers/stream_completion_policy.dart';

void main() {
  group('resolveStreamCompletionAction (CHAT-1 guard)', () {
    test('a duplicate completion on an already-terminal stream is skipped', () {
      expect(
        resolveStreamCompletionAction(
          isMessageCompleted: true,
          isMessageInErrorState: false,
        ),
        StreamCompletionAction.skipAlreadyCompleted,
      );
    });

    test('a terminal error state is preserved, never overwritten', () {
      expect(
        resolveStreamCompletionAction(
          isMessageCompleted: false,
          isMessageInErrorState: true,
        ),
        StreamCompletionAction.preserveError,
      );
    });

    test('the double-completion guard wins over error preservation', () {
      // Both the SSE layer and GenUI can fire a completion for the same
      // message after an error; the guard must short-circuit first.
      expect(
        resolveStreamCompletionAction(
          isMessageCompleted: true,
          isMessageInErrorState: true,
        ),
        StreamCompletionAction.skipAlreadyCompleted,
      );
    });

    test('a healthy stream finalizes normally', () {
      expect(
        resolveStreamCompletionAction(
          isMessageCompleted: false,
          isMessageInErrorState: false,
        ),
        StreamCompletionAction.finalize,
      );
    });
  });
}
