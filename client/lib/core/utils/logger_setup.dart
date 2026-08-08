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
    final log = StringBuffer(
      '${record.time}: [${record.level.name}] ${record.loggerName}: ${record.message}',
    );
    // Include the error and its full stack trace when present; stack
    // trimming/folding is the job of the console or the error-reporting
    // SDK (e.g. Sentry), not of the logger itself.
    if (record.error != null) {
      log.write('\nError: ${record.error}');
    }
    if (record.stackTrace != null) {
      log.write('\nStackTrace:\n${record.stackTrace}');
    }
    debugPrint(log.toString());
  });

  _logger.info('Logging system initialized');
}
