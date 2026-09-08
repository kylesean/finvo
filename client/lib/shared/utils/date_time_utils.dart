/// Defensive ISO-8601 timestamp parsing shared across features.
library;

import 'package:json_annotation/json_annotation.dart';

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

/// json_serializable converter that parses ISO-8601 timestamps into LOCAL
/// [DateTime] values.
///
/// Server timestamps are UTC (`timestamptz` + `isoformat()`), so the default
/// generated `DateTime.parse(json['x'])` yields `isUtc == true` — and intl's
/// `DateFormat.format` does NOT convert, meaning every non-UTC device showed
/// raw UTC wall-clock times (e.g. 8h off in China, dates off by one after
/// 16:00 local). Apply with `@JsonSerializable(converters: [LocalDateTimeConverter()])`
/// on the model class (freezed passes the annotation through).
///
/// `toJson` keeps `toIso8601String()` (not `toUtc()`) so local date-only
/// values (e.g. a budget start date picked at midnight) still serialize with
/// their local offset instead of rolling back a day in UTC+ zones.
class LocalDateTimeConverter extends JsonConverter<DateTime, String> {
  const LocalDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    final local = tryParseDateTime(json);
    if (local != null) return local;
    throw FormatException('Invalid ISO-8601 timestamp: $json');
  }

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
