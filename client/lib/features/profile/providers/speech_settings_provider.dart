import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/profile/models/speech_settings.dart';

part 'speech_settings_provider.g.dart';

final _logger = Logger('SpeechSettingsNotifier');

/// SharedPreferences storage keys
const String _speechSettingsKey = 'speech_settings';

/// Speech settings Notifier
///
/// [keepAlive] so the locally-stored settings are kept in memory after the
/// startup pre-warm instead of being re-read on every screen mount.
@Riverpod(keepAlive: true)
class SpeechSettingsNotifier extends _$SpeechSettingsNotifier {
  @override
  SpeechSettingsState build() {
    // Pure build: app startup triggers [loadSettings] explicitly (see
    // main.dart) so this SharedPreferences read is not a build() side-effect.
    return const SpeechSettingsState();
  }

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final jsonString = prefs.getString(_speechSettingsKey);

      SpeechSettings settings;
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        settings = SpeechSettings.fromJson(json);
        _logger.info(
          'Loaded speech settings successfully: ${settings.serviceType}',
        );
      } else {
        // Default settings
        settings = const SpeechSettings();
        _logger.info('Using default speech settings');
      }

      state = state.copyWith(isLoading: false, settings: settings);
    } catch (e) {
      _logger.severe('Failed to load speech settings: $e');
      state = state.copyWith(
        isLoading: false,
        settings: const SpeechSettings(), // Use default settings
        errorMessage: 'Failed to load settings',
      );
    }
  }

  /// Save settings to SharedPreferences
  Future<bool> _saveSettings(SpeechSettings settings) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString(_speechSettingsKey, jsonString);
      _logger.info('Saved speech settings successfully');
      return true;
    } catch (e) {
      _logger.severe('Failed to save speech settings: $e');
      return false;
    }
  }

  /// Update service type
  Future<void> updateServiceType(SpeechServiceType type) async {
    if (state.isSaving || state.settings == null) return;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final newSettings = state.settings!.copyWith(serviceType: type);
    final success = await _saveSettings(newSettings);

    if (success) {
      state = state.copyWith(isSaving: false, settings: newSettings);
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save settings',
      );
    }
  }

  /// Update WebSocket configuration. Returns true on success, false when the
  /// settings are not yet loaded (settings == null), a save is already in
  /// progress (isSaving == true), or the save fails, so callers can surface a
  /// truthful result instead of a fake success toast.
  Future<bool> updateWebsocketConfig({
    String? host,
    int? port,
    String? path,
  }) async {
    if (state.isSaving || state.settings == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final newSettings = state.settings!.copyWith(
      websocketHost: host ?? state.settings!.websocketHost,
      websocketPort: port ?? state.settings!.websocketPort,
      websocketPath: path ?? state.settings!.websocketPath,
    );
    final success = await _saveSettings(newSettings);

    if (success) {
      state = state.copyWith(isSaving: false, settings: newSettings);
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save settings',
      );
    }
    return success;
  }

  /// Update speech recognition language
  Future<void> updateLocaleId(String localeId) async {
    if (state.isSaving || state.settings == null) return;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final newSettings = state.settings!.copyWith(localeId: localeId);
    final success = await _saveSettings(newSettings);

    if (success) {
      state = state.copyWith(isSaving: false, settings: newSettings);
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save settings',
      );
    }
  }

  /// Reset to default settings
  Future<void> resetToDefault() async {
    if (state.isSaving) return;

    state = state.copyWith(isSaving: true, errorMessage: null);

    const defaultSettings = SpeechSettings();
    final success = await _saveSettings(defaultSettings);

    if (success) {
      state = state.copyWith(isSaving: false, settings: defaultSettings);
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to reset settings',
      );
    }
  }
}

/// Convenience provider for the current speech service type
@riverpod
SpeechServiceType currentSpeechServiceType(Ref ref) {
  final state = ref.watch(speechSettingsProvider);
  return state.settings?.serviceType ?? SpeechServiceType.system;
}
