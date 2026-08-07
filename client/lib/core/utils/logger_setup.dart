import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final _logger = Logger('LoggerSetup');

/// Active root subscription, kept so a repeated [setupLogging] call (e.g. the
/// fatal-init retry path re-running bootstrap) does not register a second
/// listener and duplicate every log line.
StreamSubscription<LogRecord>? _rootSubscription;

/// Initialize logging configuration. Idempotent: safe to call more than once.
void setupLogging() {
  // Set global log level
  // Level.INFO for development to avoid trace/fine log spam, Level.WARNING for production
  Logger.root.level = kDebugMode ? Level.INFO : Level.WARNING;

  // Configure log output format
  unawaited(_rootSubscription?.cancel());
  _rootSubscription = Logger.root.onRecord.listen((record) {
    final message =
        '${record.time}: [${record.level.name}] ${record.loggerName}: ${record.message}';

    // Print stack trace if error exists
    if (record.error != null) {
      debugPrint('$message\nError: ${record.error}');
    } else {
      debugPrint(message);
    }

    if (record.stackTrace != null) {
      debugPrint('StackTrace: ${record.stackTrace}');
    }
  });

  _logger.info('Logging system initialized');
}
