import 'package:finvo/core/network/exceptions/app_exception.dart';

/// Centralized parsing helpers for the standard backend response envelope
/// `{ code: 0, message: "...", data: ... }`.
///
/// All services should route their response decoding through these helpers
/// instead of re-implementing inline `as List<dynamic>` casts.
abstract final class ResponseParser {
  /// Unwraps the envelope's `data` field and casts it to [T].
  ///
  /// Use this when the payload carries pagination metadata or a non-standard
  /// shape that [parseItem]/[parseList] cannot express. When `data` is null,
  /// [whenNull] decides the outcome: throw for strict endpoints or return a
  /// sentinel value for tolerant ones.
  static T parseData<T>(dynamic json, {required T Function() whenNull}) {
    if (json is Map<String, dynamic>) {
      final dataField = json['data'];
      if (dataField == null) return whenNull();
      if (dataField is T) return dataField;
      throw DataParsingException(
        'Expected data to be $T, got ${dataField.runtimeType}',
      );
    }
    throw DataParsingException('Expected JSON Object, got ${json.runtimeType}');
  }

  /// Parses a single item: `{ data: {...} }` or a direct root object
  /// (legacy shape). Throws [DataParsingException] on mismatch.
  static T parseItem<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json is Map<String, dynamic>) {
      final dataField = json['data'];
      if (dataField is Map<String, dynamic>) {
        try {
          return fromJson(dataField);
        } catch (e) {
          throw DataParsingException('Failed to parse item: ${e.toString()}');
        }
      }
      // Fallback: try parsing the root object directly (legacy shape).
      try {
        return fromJson(json);
      } catch (e) {
        throw DataParsingException('Failed to parse item response: $json');
      }
    }
    throw DataParsingException('Expected JSON Object, got ${json.runtimeType}');
  }

  /// Parses a list response supporting:
  /// - `{ data: { items: [...] } }` (standard pagination shape)
  /// - `{ data: [...] }` (plain list shape)
  /// - `{ data: null }` (empty result)
  static List<T> parseList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json is Map<String, dynamic>) {
      final dataField = json['data'];
      if (dataField == null) return [];
      if (dataField is Map<String, dynamic>) {
        final items = dataField['items'];
        if (items is List) {
          return _mapItems(items, fromJson);
        }
      }
      if (dataField is List) {
        return _mapItems(dataField, fromJson);
      }
    }
    return [];
  }

  static List<T> _mapItems<T>(
    List<dynamic> items,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return items.map((item) {
      if (item is Map<String, dynamic>) {
        return fromJson(item);
      }
      throw DataParsingException(
        'Item in list is not a Map: ${item.runtimeType}',
      );
    }).toList();
  }
}
