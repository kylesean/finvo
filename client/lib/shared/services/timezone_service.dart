import 'package:logging/logging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timezone service for getting user's local timezone information.
class TimezoneService {
  final _logger = Logger('TimezoneService');

  /// Get user's local timezone.
  ///
  /// Returns the IANA timezone identifier, e.g. "Asia/Shanghai".
  Future<String> getCurrentTimezone() async {
    try {
      final result = await FlutterTimezone.getLocalTimezone();
      final id = result.identifier;
      if (id.isNotEmpty) return id;
      return result.toString();
    } catch (e) {
      _logger.info('TimezoneService: Failed to get timezone: $e');
      // Return default timezone if retrieval fails.
      return 'UTC';
    }
  }

  /// Get list of all available timezones (optional feature).
  Future<List<String>> getAvailableTimezones() async {
    try {
      final result = await FlutterTimezone.getAvailableTimezones();
      return result.map((tz) => tz.identifier).toList();
    } catch (e) {
      _logger.info('TimezoneService: Failed to get available timezones: $e');
      return [];
    }
  }
}

/// Riverpod Provider for TimezoneService
final timezoneServiceProvider = Provider<TimezoneService>((ref) {
  return TimezoneService();
});
