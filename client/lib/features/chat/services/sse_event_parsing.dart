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

    if (!line.startsWith('data: ')) {
      // Ignore other SSE fields (event:/id:/retry:) and comments; the
      // backend protocol only relies on data fields.
      return null;
    }

    if (_buffer.isNotEmpty) _buffer.write('\n');
    _buffer.write(line.substring(6).trim());
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

/// Resolve the currency of a TransactionGroupReceipt payload.
///
/// Priority: `summary['currency']` > first transaction entry's
/// `originalCurrency`/`currency` > app-wide default 'CNY'. AI-generated
/// payloads are untrusted, so every read is type-guarded.
String deriveReceiptCurrency(
  Map<String, dynamic> summary,
  Map<String, dynamic> props,
) {
  final summaryCurrency = summary['currency'];
  if (summaryCurrency is String && summaryCurrency.isNotEmpty) {
    return summaryCurrency;
  }

  final transactions = props['transactions'];
  if (transactions is List) {
    for (final entry in transactions) {
      if (entry is! Map) continue;
      final raw = entry['originalCurrency'] ?? entry['currency'];
      if (raw is String && raw.isNotEmpty) return raw;
    }
  }

  return 'CNY';
}
