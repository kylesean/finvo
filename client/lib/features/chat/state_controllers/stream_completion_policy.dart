// Pure decision logic for stream-completion callbacks.
//
// Extracted from ChatHistory._handleStreamComplete so the subtle
// double-completion guard and the error-state preservation rule (CHAT-1) are
// unit-testable without spinning up the whole provider: both the SSE layer and
// the GenUI layer can fire onStreamComplete for the same message, and an error
// path may pair onError with onStreamComplete — the ordering rules below keep
// the terminal bookkeeping on a single guarded path.

/// Outcome of a stream-completion callback, resolved *before* any state
/// mutation.
enum StreamCompletionAction {
  /// The stream is already terminal (completed/error/cancelled): this is a
  /// duplicate completion callback. Skip all finalization bookkeeping; the
  /// caller may still clear the in-flight streaming flag.
  skipAlreadyCompleted,

  /// The message is in a terminal *error* state (an error handler already
  /// appended the error text and marked it `error`). Never overwrite that with
  /// `completed` — only drive the stream phase to error (so a trailing
  /// completion short-circuits too) and clear the in-flight flag.
  preserveError,

  /// Normal path: finalize the message — sweep pending tool calls, mark it
  /// `completed`, then clear the in-flight streaming flag.
  finalize,
}

/// Resolve which [StreamCompletionAction] applies.
///
/// Order matters (CHAT-1): the double-completion guard wins over the
/// error-preservation rule, mirroring ChatHistory._handleStreamComplete.
StreamCompletionAction resolveStreamCompletionAction({
  required bool isMessageCompleted,
  required bool isMessageInErrorState,
}) {
  if (isMessageCompleted) return StreamCompletionAction.skipAlreadyCompleted;
  if (isMessageInErrorState) return StreamCompletionAction.preserveError;
  return StreamCompletionAction.finalize;
}
