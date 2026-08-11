import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/version/models/update_info.dart';
import 'package:finvo/features/version/providers/version_provider.dart';
import 'package:finvo/features/version/services/app_version_service.dart';

class _FakeAppVersionService extends AppVersionService {
  _FakeAppVersionService() : super(NetworkClient(Dio()));

  UpdateInfo? nextResult;
  Object? nextError;

  @override
  Future<UpdateInfo?> checkUpdate() async {
    if (nextError != null) {
      throw nextError!;
    }
    return nextResult;
  }
}

const _sampleUpdate = UpdateInfo(
  currentVersion: '0.2.0',
  latestVersion: '0.3.0',
  minSupportedVersion: '0.1.0',
  hasUpdate: true,
  forceUpdate: false,
  releaseDate: '2026-01-01',
  changelog: 'Bug fixes',
  downloadUrls: DownloadUrls(webUrl: 'https://example.com/app'),
  targetDownloadUrl: 'https://example.com/app',
);

void main() {
  late _FakeAppVersionService service;
  late ProviderContainer container;

  setUp(() {
    service = _FakeAppVersionService();
    container = ProviderContainer(
      overrides: [appVersionServiceProvider.overrideWithValue(service)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('VersionNotifier', () {
    test('build starts in idle state', () {
      final state = container.read(versionNotifierProvider);

      expect(state.isChecking, isFalse);
      expect(state.updateInfo, isNull);
      expect(state.error, isNull);
    });

    test('checkUpdate stores update info on success', () async {
      service.nextResult = _sampleUpdate;

      final result = await container
          .read(versionNotifierProvider.notifier)
          .checkUpdate();

      final state = container.read(versionNotifierProvider);
      expect(result, _sampleUpdate);
      expect(state.isChecking, isFalse);
      expect(state.updateInfo, _sampleUpdate);
      expect(state.error, isNull);
    });

    test('checkUpdate sets error when service returns null', () async {
      service.nextResult = null;

      final result = await container
          .read(versionNotifierProvider.notifier)
          .checkUpdate();

      final state = container.read(versionNotifierProvider);
      expect(result, isNull);
      expect(state.isChecking, isFalse);
      expect(state.updateInfo, isNull);
      expect(state.error, isNotNull);
    });

    test('checkUpdate maps exceptions to safe error message', () async {
      service.nextError = NetworkException('offline');

      await expectLater(
        container.read(versionNotifierProvider.notifier).checkUpdate(),
        throwsA(isA<NetworkException>()),
      );

      final state = container.read(versionNotifierProvider);
      expect(state.isChecking, isFalse);
      expect(state.error, isNotNull);
    });
  });

  group('UpdateInfo', () {
    test(
      'fromServerResponse marks newer server version as update available',
      () {
        final info = UpdateInfo.fromServerResponse(
          currentVersion: '0.2.0',
          data: const {
            'latestVersion': '0.3.0',
            'minSupportedVersion': '0.1.0',
            'forceUpdate': false,
            'releaseDate': '2026-01-01',
            'changelog': 'Improvements',
            'downloadUrls': {'webUrl': 'https://example.com/app'},
          },
          targetDownloadUrl: 'https://example.com/app',
          hasUpdate: true,
        );

        expect(info.latestVersion, '0.3.0');
        expect(info.hasUpdate, isTrue);
        expect(info.targetDownloadUrl, 'https://example.com/app');
      },
    );
  });
}
