/// Pure helpers for SSE stream parsing and receipt currency derivation.
///
/// Extracted from [CustomContentGenerator] so the parsing rules can be unit
/// tested without Dio, streams, or Riverpod.
library;

/// Incrementally accumulates SSE `data:` lines into event payloads.
///
/// Follows the SSE dispatch model used by the backend:
/// - `data:` lines accumulate into one event;
/// - an empty line is the event boundary;
/// - multi-line data fields are joined with `'\n'`;
/// - other fields (`event:` / `id:` / `retry:` / comments) are ignored.
class SseEventAccumulator {
  final StringBuffer _buffer = StringBuffer();

  /// Feed one stream line. Returns the completed event payload when this
  /// line closes an event (blank-line boundary), otherwise `null`.
  String? addLine(String line) {
    if (line.isEmpty) {
      if (_buffer.isEmpty) return null;
      final event = _buffer.toString();
      _buffer.clear();
      return event;
    }

    if (!line.startsWith('data:')) {
      // Ignore other SSE fields (event:/id:/retry:) and comments; the
      // backend protocol only relies on data fields.
      return null;
    }

    // Field value per the SSE spec: the optional single space after the
    // colon is stripped, everything else is preserved byte-for-byte.
    // Accept both `data: value` and the space-less `data:value` variant;
    // a bare `data:` line contributes an empty segment.
    final String value = line.length > 5 && line[5] == ' '
        ? line.substring(6)
        : line.substring(5);

    if (_buffer.isNotEmpty) _buffer.write('\n');
    _buffer.write(value);
    return null;
  }

  /// Return a trailing event that was never terminated by a blank line,
  /// or `null` when nothing is pending.
  String? flush() {
    if (_buffer.isEmpty) return null;
    final event = _buffer.toString();
    _buffer.clear();
    return event;
  }
}

/// Receipt event extracted from one currency bucket.
typedef ReceiptBucketEvent = ({double amount, String type, String currency});

/// Per-currency events from a TransactionGroupReceipt summary.
///
/// Buckets are never summed across currencies; each emits its own event with
/// its own currency. Malformed buckets are skipped.
List<ReceiptBucketEvent> receiptBucketEvents(Object? summary) {
  final events = <ReceiptBucketEvent>[];
  if (summary is! Map<String, dynamic>) return events;
  final byCurrency = summary['by_currency'];
  if (byCurrency is! Map) return events;
  double asDouble(Object? value) => switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s) ?? 0,
    _ => 0,
  };
  byCurrency.forEach((code, totals) {
    if (totals is! Map) return;
    final currency = code.toString().toUpperCase();
    final expense = asDouble(totals['expense']);
    final income = asDouble(totals['income']);
    if (expense > 0) events.add((amount: expense, type: 'expense', currency: currency));
    if (income > 0) events.add((amount: income, type: 'income', currency: currency));
  });
  return events;
}
