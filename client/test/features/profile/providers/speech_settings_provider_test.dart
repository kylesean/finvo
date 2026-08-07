import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/profile/models/speech_settings.dart';
import 'package:finvo/features/profile/providers/speech_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeechSettingsState', () {
    test('default state has null settings and is not loading/saving', () {
      const state = SpeechSettingsState();
      expect(state.settings, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, isNull);
    });
  });

  group('SpeechSettingsNotifier with ProviderContainer DI', () {
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'loadSettings loads default settings when SharedPreferences is empty',
      () async {
        final notifier = container.read(speechSettingsProvider.notifier);
        await notifier.loadSettings();

        final state = container.read(speechSettingsProvider);
        expect(state.isLoading, isFalse);
        expect(state.settings, isNotNull);
        expect(state.settings?.serviceType, equals(SpeechServiceType.system));
      },
    );

    test('updateServiceType persists changes to SharedPreferences', () async {
      final notifier = container.read(speechSettingsProvider.notifier);
      await notifier.loadSettings();

      await notifier.updateServiceType(SpeechServiceType.websocket);

      final state = container.read(speechSettingsProvider);
      expect(state.settings?.serviceType, equals(SpeechServiceType.websocket));
      expect(prefs.getString('speech_settings'), contains('websocket'));
    });

    test(
      'updateWebsocketConfig updates and persists websocket options',
      () async {
        final notifier = container.read(speechSettingsProvider.notifier);
        await notifier.loadSettings();

        final result = await notifier.updateWebsocketConfig(
          host: '192.168.1.100',
          port: 8088,
          path: '/ws/asr',
        );

        expect(result, isTrue);
        final state = container.read(speechSettingsProvider);
        expect(state.settings?.websocketHost, equals('192.168.1.100'));
        expect(state.settings?.websocketPort, equals(8088));
        expect(state.settings?.websocketPath, equals('/ws/asr'));
      },
    );

    test('resetToDefault restores initial default settings', () async {
      final notifier = container.read(speechSettingsProvider.notifier);
      await notifier.loadSettings();
      await notifier.updateServiceType(SpeechServiceType.websocket);

      await notifier.resetToDefault();

      final state = container.read(speechSettingsProvider);
      expect(state.settings?.serviceType, equals(SpeechServiceType.system));
    });
  });

  group('SpeechSettingsNotifier concurrent save guard', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('updateServiceType returns early when isSaving is true', () async {
      final notifier = container.read(speechSettingsProvider.notifier);
      notifier.state = const SpeechSettingsState(
        settings: SpeechSettings(serviceType: SpeechServiceType.system),
        isSaving: true,
      );

      await notifier.updateServiceType(SpeechServiceType.websocket);

      expect(
        notifier.state.settings?.serviceType,
        equals(SpeechServiceType.system),
      );
    });

    test('updateWebsocketConfig returns false when isSaving is true', () async {
      final notifier = container.read(speechSettingsProvider.notifier);
      notifier.state = const SpeechSettingsState(
        settings: SpeechSettings(websocketHost: '127.0.0.1'),
        isSaving: true,
      );

      final result = await notifier.updateWebsocketConfig(host: '192.168.1.1');

      expect(result, isFalse);
      expect(notifier.state.settings?.websocketHost, equals('127.0.0.1'));
    });
  });
}
