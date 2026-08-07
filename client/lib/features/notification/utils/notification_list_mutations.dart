import 'package:collection/collection.dart';

/// Pure result of a badge-accounting mutation on a notification list.
class NotificationMutationResult<T> {
  const NotificationMutationResult({
    required this.items,
    required this.unreadCount,
  });

  final List<T> items;
  final int unreadCount;
}

/// Pure badge-accounting helpers shared by the central [NotificationNotifier]
/// and the shared-space notification provider.
///
/// Both implement the same mark-read / delete mutations with a badge counter
/// that must never undercount (a repeated call on an already-read item must not
/// keep decrementing). The bookkeeping lives here instead of being duplicated
/// line-by-line across modules.
///
/// The helpers are pure: they take the existing list + badge count and return
/// the new ones. Callers supply tiny accessors (`idOf`, `isReadOf`, `withRead`)
/// so the helpers stay agnostic of the concrete item type.
abstract final class NotificationListMutations {
  /// Mark a single entry as read, decrementing the badge only when the entry
  /// actually transitioned from unread to read.
  static NotificationMutationResult<T> markAsRead<T>({
    required List<T> items,
    required int unreadCount,
    required String id,
    required String Function(T item) idOf,
    required bool Function(T item) isReadOf,
    required T Function(T item) withReadAt,
  }) {
    final target = items.where((item) => idOf(item) == id).firstOrNull;
    final wasUnread = target != null && !isReadOf(target);

    final updated = items.map((item) {
      if (idOf(item) != id) return item;
      return withReadAt(item);
    }).toList();

    final newUnreadCount = wasUnread
        ? (unreadCount - 1).clamp(0, 999)
        : unreadCount;

    return NotificationMutationResult(
      items: updated,
      unreadCount: newUnreadCount,
    );
  }

  /// Mark every entry as read and zero the badge.
  static NotificationMutationResult<T> markAllAsRead<T>({
    required List<T> items,
    required T Function(T item) withRead,
  }) {
    final updated = items.map(withRead).toList();
    return NotificationMutationResult(items: updated, unreadCount: 0);
  }

  /// Delete a single entry, decrementing the badge when the entry was unread.
  static NotificationMutationResult<T> delete<T>({
    required List<T> items,
    required int unreadCount,
    required String id,
    required String Function(T item) idOf,
    required bool Function(T item) isReadOf,
  }) {
    final target = items.where((item) => idOf(item) == id).firstOrNull;
    final updated = items.where((item) => idOf(item) != id).toList();
    final newUnreadCount = target != null && !isReadOf(target)
        ? (unreadCount - 1).clamp(0, 999)
        : unreadCount;

    return NotificationMutationResult(
      items: updated,
      unreadCount: newUnreadCount,
    );
  }
}
