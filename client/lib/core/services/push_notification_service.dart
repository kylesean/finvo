import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../network/network_client.dart';

/// Service responsible for managing push notification tokens and payload routing
class PushNotificationService {
  final NetworkClient _networkClient;
  final _logger = Logger('PushNotificationService');

  String? _currentToken;

  PushNotificationService(this._networkClient);

  /// Get currently registered token
  String? get currentToken => _currentToken;

  /// Register or update FCM device token with backend server
  Future<bool> registerDeviceToken(String deviceToken) async {
    try {
      _currentToken = deviceToken;
      final platform = kIsWeb ? 'web' : (Platform.isIOS ? 'ios' : 'android');

      await _networkClient.request<dynamic>(
        '/notifications/device-token',
        method: HttpMethod.post,
        data: {'deviceToken': deviceToken, 'platform': platform},
      );
      _logger.info(
        'Device token successfully registered with backend ($platform)',
      );
      return true;
    } catch (e, stackTrace) {
      _logger.severe(
        'Failed to register device token with backend',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Unregister FCM device token from backend server (e.g. on logout)
  Future<bool> unregisterDeviceToken() async {
    if (_currentToken == null) return true;

    try {
      await _networkClient.request<dynamic>(
        '/notifications/device-token',
        method: HttpMethod.delete,
        data: {'deviceToken': _currentToken},
      );
      _logger.info('Device token successfully unregistered');
      _currentToken = null;
      return true;
    } catch (e, stackTrace) {
      _logger.warning('Failed to unregister device token', e, stackTrace);
      return false;
    }
  }

  /// Fetch unread notification count
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _networkClient.request<Map<String, dynamic>>(
        '/notifications/unread-count',
        method: HttpMethod.get,
      );
      final count = response['count'] as int? ?? 0;
      return count;
    } catch (e) {
      _logger.warning('Failed to fetch unread notification count: $e');
      return 0;
    }
  }
}
