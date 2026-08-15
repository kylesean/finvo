// Re-export compatibility shim. The canonical notifier now lives in the
// `shared` layer so shared widgets can read the current currency without
// depending on a feature module. Keep this file so existing feature imports
// keep working.
export 'package:finvo/shared/providers/financial_settings_provider.dart';
