import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/notification/utils/notification_target_resolver.dart';

void main() {
  group('resolveNotificationTarget (H8 whitelist)', () {
    test('accepts the transaction-detail paths the backend emits', () {
      expect(
        resolveNotificationTarget('/home/transaction/abc-123'),
        '/home/transaction/abc-123',
      );
      expect(
        resolveNotificationTarget('/home/transaction/abc-123?commentId=42'),
        '/home/transaction/abc-123?commentId=42',
      );
    });

    test('accepts the shared-space paths the backend emits', () {
      expect(
        resolveNotificationTarget('/profile/shared-space'),
        '/profile/shared-space',
      );
      expect(
        resolveNotificationTarget('/profile/shared-space/space-9'),
        '/profile/shared-space/space-9',
      );
    });

    test('accepts the recurring-transactions list path', () {
      expect(
        resolveNotificationTarget('/finance/recurring-transactions'),
        '/finance/recurring-transactions',
      );
    });

    test('rejects paths outside the whitelist', () {
      // Internal flows that must never be reachable from a notification.
      expect(resolveNotificationTarget('/server-setup'), isNull);
      expect(resolveNotificationTarget('/login'), isNull);
      expect(resolveNotificationTarget('/profile'), isNull);
      // Segment-boundary: a lookalike prefix must not slip through.
      expect(resolveNotificationTarget('/home/transactions-evil'), isNull);
      expect(resolveNotificationTarget('/profile/shared-spaceX'), isNull);
      expect(resolveNotificationTarget('/unknown'), isNull);
    });

    test('rejects scheme and host injection', () {
      expect(resolveNotificationTarget('http://evil.example/x'), isNull);
      expect(resolveNotificationTarget('https://evil.example/home'), isNull);
      // Protocol-relative URL: parses with an implicit host.
      expect(resolveNotificationTarget('//evil.example/home'), isNull);
      expect(resolveNotificationTarget('javascript:alert(1)'), isNull);
    });

    test('rejects absent, empty, and malformed input', () {
      expect(resolveNotificationTarget(null), isNull);
      expect(resolveNotificationTarget(''), isNull);
      expect(resolveNotificationTarget('   '), isNull);
      expect(resolveNotificationTarget('home/transaction/1'), isNull);
    });
  });
}
