/// Extensions on [Map<String, dynamic>] for safe, strongly-typed parsing
extension SafeMapExtension on Map<String, dynamic> {
  /// Safely get a list of items mapped by [mapper].
  /// Returns empty list if key is missing or not a [List].
  List<T> getList<T>(String key, T Function(Map<String, dynamic>) mapper) {
    final value = this[key];
    if (value is! List) return const [];
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => mapper(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Safely extract a [double] value. Supports [num] and [String] parsing.
  double getDouble(String key, {double defaultValue = 0.0}) {
    final val = this[key];
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  /// Safely extract an [int] value. Supports [num] and [String] parsing.
  int getInt(String key, {int defaultValue = 0}) {
    final val = this[key];
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  /// Safely extract a [String] value.
  String getString(String key, {String defaultValue = ''}) {
    final val = this[key];
    if (val == null) return defaultValue;
    return val.toString();
  }

  /// Safely extract a nested [Map<String, dynamic>].
  Map<String, dynamic>? getMap(String key) {
    final val = this[key];
    if (val is Map) {
      return Map<String, dynamic>.from(val);
    }
    return null;
  }
}
