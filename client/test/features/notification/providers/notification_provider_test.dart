import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/notification/models/notification_item.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';

void main() {
  group('NotificationState', () {
    test('default state has empty items and zero unread count', () {
      const state = NotificationState();
      expect(state.items, isEmpty);
      expect(state.unreadCount, equals(0));
      expect(state.total, equals(0));
      expect(state.isLoading, isFalse);
    });
  });

  group('NotificationNotifier realtime additions', () {
    NotificationNotifier buildNotifier() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container.read(notificationProvider.notifier);
    }

    test('addRealtimeNotification updates items, total, and unreadCount', () {
      final notifier = buildNotifier();
      final item = NotificationItem(
        id: 'test_1',
        userId: 'u1',
        type: 'system',
        title: 'Test Notification',
        message: 'Hello World',
        isRead: false,
        createdAt: DateTime.now(),
      );

      notifier.addRealtimeNotification(item);

      expect(notifier.state.items.length, equals(1));
      expect(notifier.state.items.first.id, equals('test_1'));
      expect(notifier.state.unreadCount, equals(1));
      expect(notifier.state.total, equals(1));
    });

    test(
      'addRealtimeNotificationFromPayload constructs items with unique sequential ids',
      () {
        final notifier = buildNotifier();

        notifier.addRealtimeNotificationFromPayload({
          'title': 'First',
          'message': 'Body 1',
        }, 'system');
        notifier.addRealtimeNotificationFromPayload({
          'title': 'Second',
          'message': 'Body 2',
        }, 'system');

        final items = notifier.state.items;
        expect(items.length, equals(2));
        expect(items[0].title, equals('Second')); // newest first
        expect(items[1].title, equals('First'));
        expect(items[0].id != items[1].id, isTrue);
      },
    );
  });
}
