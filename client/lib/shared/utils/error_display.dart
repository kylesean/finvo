/// User-facing error message resolution.
library;

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Best-effort user-facing error message.
///
/// [AppException] carries a localized, user-safe message; anything else
/// collapses to the generic error label so raw exceptions (URLs, backend
/// payloads, stack traces) never leak into the UI. Internal details belong
/// in logs, not SnackBars.
String friendlyErrorMessage(Object error) =>
    error is AppException ? error.message : t.common.error;
