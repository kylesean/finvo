import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/server/providers/server_config_provider.dart';

class _FakeSecureStorageService extends SecureStorageService {
  _FakeSecureStorageService() : super(const FlutterSecureStorage());

  bool cleared = false;

  @override
  Future<void> clearAllData() async {
    cleared = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late _FakeSecureStorageService storage;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = _FakeSecureStorageService();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStorageServiceProvider.overrideWithValue(storage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ServerConfigNotifier', () {
    test('build returns notConfigured when no server URL is saved', () {
      final state = container.read(serverConfigProvider);

      expect(state, const ServerConfigState.notConfigured());
    });

    test('build returns configured when server URL exists', () async {
      final configService = container.read(serverConfigServiceProvider);
      await configService.saveServerUrl('http://192.168.1.10:8000');

      final freshContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(freshContainer.dispose);

      final state = freshContainer.read(serverConfigProvider);
      expect(
        state,
        const ServerConfigState.configured(
          serverUrl: 'http://192.168.1.10:8000',
        ),
      );
    });

    test('saveServerUrl persists URL and updates state', () async {
      await container
          .read(serverConfigProvider.notifier)
          .saveServerUrl('http://localhost:8000');

      final state = container.read(serverConfigProvider);
      expect(
        state,
        const ServerConfigState.configured(serverUrl: 'http://localhost:8000'),
      );
      expect(
        container.read(serverConfigServiceProvider).serverUrl,
        'http://localhost:8000',
      );
    });

    test(
      'saveServerUrl clears secure storage when switching servers',
      () async {
        await container
            .read(serverConfigProvider.notifier)
            .saveServerUrl('http://192.168.1.10:8000');

        await container
            .read(serverConfigProvider.notifier)
            .saveServerUrl('http://192.168.1.11:8000');

        expect(storage.cleared, isTrue);
        expect(
          container.read(serverConfigProvider),
          const ServerConfigState.configured(
            serverUrl: 'http://192.168.1.11:8000',
          ),
        );
      },
    );

    test('clearConfiguration removes saved URL', () async {
      await container
          .read(serverConfigProvider.notifier)
          .saveServerUrl('http://localhost:8000');

      await container.read(serverConfigProvider.notifier).clearConfiguration();

      expect(
        container.read(serverConfigProvider),
        const ServerConfigState.notConfigured(),
      );
      expect(container.read(serverConfigServiceProvider).serverUrl, isNull);
    });

    test('reset restores configured state from persisted URL', () async {
      await container
          .read(serverConfigProvider.notifier)
          .saveServerUrl('http://localhost:8000');

      container.read(serverConfigProvider.notifier).reset();

      expect(
        container.read(serverConfigProvider),
        const ServerConfigState.configured(serverUrl: 'http://localhost:8000'),
      );
    });
  });
}
