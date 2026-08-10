/// Defensive ISO-8601 timestamp parsing shared across features.
library;

/// Parse an ISO-8601 timestamp and convert it to local time.
///
/// UTC timestamps (trailing 'Z') are converted with [DateTime.toLocal] so
/// users in any timezone see the correct wall-clock time; local timestamps
/// are returned unchanged. Returns `null` for missing/malformed input so a
/// single bad value degrades gracefully instead of breaking a whole list.
///
/// Mirrors the fallback strategy of `ConversationService._parseDateTime`:
/// a redundant trailing 'Z' that the standard parser rejects is stripped
/// before the final attempt.
DateTime? tryParseDateTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed != null) return parsed.toLocal();
  if (value.endsWith('Z')) {
    return DateTime.tryParse(value.substring(0, value.length - 1))?.toLocal();
  }
  return null;
}
