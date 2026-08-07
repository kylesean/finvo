import 'package:finvo/core/services/server_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ServerConfigService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = ServerConfigService(prefs);
  });

  group('saveServerUrl default scheme', () {
    test('bare private LAN IP defaults to http', () async {
      await service.saveServerUrl('192.168.1.10:8000');
      expect(service.serverUrl, 'http://192.168.1.10:8000');
    });

    test('bare loopback address defaults to http', () async {
      await service.saveServerUrl('127.0.0.1:8000');
      expect(service.serverUrl, 'http://127.0.0.1:8000');
    });

    test('bare localhost defaults to http', () async {
      await service.saveServerUrl('localhost:8000');
      expect(service.serverUrl, 'http://localhost:8000');
    });

    test('bare IPv6 loopback defaults to http (C1 regression)', () async {
      await service.saveServerUrl('[::1]:8000');
      expect(service.serverUrl, 'http://[::1]:8000');
    });

    test('bare IPv6 link-local defaults to http (C1 regression)', () async {
      await service.saveServerUrl('[fe80::1]:8000');
      expect(service.serverUrl, 'http://[fe80::1]:8000');
    });

    test('bare 10.x private address defaults to http', () async {
      await service.saveServerUrl('10.0.0.5:8080');
      expect(service.serverUrl, 'http://10.0.0.5:8080');
    });

    test('bare 172.16-31 private address defaults to http', () async {
      await service.saveServerUrl('172.20.3.9:8000');
      expect(service.serverUrl, 'http://172.20.3.9:8000');
    });

    test('bare 172.32 (non-private) defaults to https', () async {
      await service.saveServerUrl('172.32.0.1:8443');
      expect(service.serverUrl, 'https://172.32.0.1:8443');
    });

    test('bare public hostname defaults to https', () async {
      await service.saveServerUrl('finvo.example.com');
      expect(service.serverUrl, 'https://finvo.example.com');
    });

    test('explicit http scheme is preserved', () async {
      await service.saveServerUrl('http://192.168.1.10:8000');
      expect(service.serverUrl, 'http://192.168.1.10:8000');
    });

    test('explicit https scheme is preserved', () async {
      await service.saveServerUrl('https://finvo.example.com');
      expect(service.serverUrl, 'https://finvo.example.com');
    });

    test('trailing slash is stripped', () async {
      await service.saveServerUrl('192.168.1.10:8000/');
      expect(service.serverUrl, 'http://192.168.1.10:8000');
    });
  });

  group('validateUrl', () {
    test('bare private IP is accepted', () {
      expect(service.validateUrl('192.168.1.10:8000'), isNull);
    });

    test('bare public hostname is accepted', () {
      expect(service.validateUrl('finvo.example.com'), isNull);
    });

    test('path component is rejected', () {
      expect(service.validateUrl('https://finvo.example.com/api'), isNotNull);
    });

    test('empty input is rejected', () {
      expect(service.validateUrl(''), isNotNull);
    });
  });

  group('baseUrl', () {
    test('appends /api/v1 and strips trailing slash', () async {
      await service.saveServerUrl('192.168.1.10:8000/');
      expect(service.baseUrl, 'http://192.168.1.10:8000/api/v1');
    });
  });
}
