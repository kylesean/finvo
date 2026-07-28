/// Utility for safe type parsing in GenUI components
class GenUiNumUtils {
  /// Safely convert dynamic value to double
  static double toDouble(dynamic val, [double defaultValue = 0.0]) {
    if (val == null) return defaultValue;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely convert dynamic value to int
  static int toInt(dynamic val, [int defaultValue = 0]) {
    if (val == null) return defaultValue;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ??
          (double.tryParse(val)?.toInt() ?? defaultValue);
    }
    return defaultValue;
  }
}
