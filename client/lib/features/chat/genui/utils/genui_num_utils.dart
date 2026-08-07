/// Utility for safe type parsing in GenUI components
class GenUiNumUtils {
  /// Safely convert Object? value to double
  static double toDouble(Object? val, [double defaultValue = 0.0]) {
    return switch (val) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? defaultValue,
      _ => defaultValue,
    };
  }

  /// Safely convert Object? value to int
  static int toInt(Object? val, [int defaultValue = 0]) {
    return switch (val) {
      final num n => n.toInt(),
      final String s =>
        int.tryParse(s) ?? (double.tryParse(s)?.toInt() ?? defaultValue),
      _ => defaultValue,
    };
  }
}
