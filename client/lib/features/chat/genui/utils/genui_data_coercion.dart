import 'package:decimal/decimal.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/features/chat/genui/utils/genui_num_utils.dart';

/// Data coercion utility for GenUI components.
///
/// Provides safe, alias-aware extractions for dynamic JSON payloads.
class GenUiDataCoercion {
  const GenUiDataCoercion._();

  /// Retrieve raw value matching the first present key in [keys].
  static Object? getValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key];
      }
    }
    return null;
  }

  /// Extract String value trying multiple [keys] in fallback order.
  static String getString(
    Map<String, dynamic> map,
    List<String> keys, [
    String defaultValue = '',
  ]) {
    final val = getValue(map, keys);
    if (val == null) return defaultValue;
    return val.toString();
  }

  /// Extract Decimal amount trying multiple [keys] in fallback order.
  static Decimal getDecimal(Map<String, dynamic> map, List<String> keys) {
    final val = getValue(map, keys);
    return AmountFormatter.parseDecimal(val?.toString());
  }

  /// Extract double value trying multiple [keys] in fallback order.
  static double getDouble(
    Map<String, dynamic> map,
    List<String> keys, [
    double defaultValue = 0.0,
  ]) {
    final val = getValue(map, keys);
    return GenUiNumUtils.toDouble(val, defaultValue);
  }

  /// Extract int value trying multiple [keys] in fallback order.
  static int getInt(
    Map<String, dynamic> map,
    List<String> keys, [
    int defaultValue = 0,
  ]) {
    final val = getValue(map, keys);
    return GenUiNumUtils.toInt(val, defaultValue);
  }

  /// Extract `Map<String, dynamic>` trying multiple [keys] in fallback order.
  static Map<String, dynamic>? getMap(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    final val = getValue(map, keys);
    if (val is Map) {
      return Map<String, dynamic>.from(val);
    }
    return null;
  }

  /// Extract `List<dynamic>` trying multiple [keys] in fallback order.
  static List<dynamic> getList(Map<String, dynamic> map, List<String> keys) {
    final val = getValue(map, keys);
    if (val is List) {
      return val;
    }
    return const [];
  }

  /// Extract `List<String>` trying multiple [keys] in fallback order.
  static List<String> getStringList(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    final list = getList(map, keys);
    return list.map((e) => e.toString()).toList();
  }
}
