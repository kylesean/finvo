import 'package:logging/logging.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/notification/models/notification_item.dart';
import 'package:finvo/shared/services/response_parser.dart';

class NotificationRepository {
  final NetworkClient _networkClient;
  final _logger = Logger('NotificationRepository');

  NotificationRepository(this._networkClient);

  /// Fetch paginated notifications from server
  Future<({List<NotificationItem> items, int total, int unreadCount})>
  getNotifications({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _networkClient.request<Map<String, dynamic>>(
        '/notifications',
        method: HttpMethod.get,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'unread_only': unreadOnly,
        },
      );

      // API response structure: {code, message, data: {notifications, total, unreadCount}}
      // A missing `data` field falls back to the root object (legacy shape).
      final data = ResponseParser.parseData<Map<String, dynamic>>(
        response,
        whenNull: () => response,
      );
      final notificationsJson = (data['notifications'] as List<dynamic>?) ?? [];
      final items = notificationsJson
          .map(
            (json) => NotificationItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final total = data['total'] as int? ?? items.length;
      final unreadCount = data['unreadCount'] as int? ?? 0;

      return (items: items, total: total, unreadCount: unreadCount);
    } catch (e, stackTrace) {
      _logger.severe('Failed to fetch notifications', e, stackTrace);
      rethrow;
    }
  }

  /// Mark single notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _networkClient.request<dynamic>(
        '/notifications/$notificationId/read',
        method: HttpMethod.patch,
      );
      return true;
    } catch (e) {
      _logger.warning(
        'Failed to mark notification $notificationId as read: $e',
      );
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      await _networkClient.request<dynamic>(
        '/notifications/mark-all-read',
        method: HttpMethod.patch,
      );
      return true;
    } catch (e) {
      _logger.warning('Failed to mark all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _networkClient.request<dynamic>(
        '/notifications/$notificationId',
        method: HttpMethod.delete,
      );
      return true;
    } catch (e) {
      _logger.warning('Failed to delete notification $notificationId: $e');
      return false;
    }
  }
}
