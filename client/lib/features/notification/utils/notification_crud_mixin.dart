import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import 'package:finvo/features/notification/utils/notification_list_mutations.dart';

final _logger = Logger('NotificationCrudMixin');

/// Shared mark-read/delete orchestration for notification-list providers.
///
/// The personal notification center ([NotificationNotifier]) and the
/// shared-space notification tab used to duplicate these three methods
/// verbatim; only the state plumbing (item accessors + copyWith) differed.
/// Hosts implement the small accessor surface below; the mixin owns the
/// repository calls, optimistic updates and badge accounting.
///
/// Deliberately does not constrain `on Notifier<...>`: Riverpod codegen
/// bases classes on the internal `$Notifier` type, so the mixin talks to the
/// host exclusively through [notificationState] + the accessor methods.
mixin NotificationCrudMixin<TItem, TState> {
  /// Current host state (read/write — the mixin replaces it after mutations).
  TState get notificationState;
  set notificationState(TState value);

  /// Current notification list.
  List<TItem> get notificationItems;

  /// Current unread badge count.
  int get notificationUnreadCount;

  /// Current total item count, or `null` when the host state has no total
  /// (in which case `deleteNotification` leaves it untouched).
  int? get notificationTotal;

  /// Rebuild host state with the mutated list. Only the provided fields
  /// are updated.
  TState updateNotificationState(
    List<TItem> items, {
    int? unreadCount,
    int? total,
  });

  /// Item identity/read accessors (kept agnostic of the concrete item type).
  String notificationIdOf(TItem item);
  bool notificationIsReadOf(TItem item);
  TItem notificationMarkRead(TItem item, {required DateTime readAt});

  /// Mark every item read during [markAllAsRead]. Defaults to
  /// [notificationMarkRead] with the current time; hosts whose read-at
  /// semantics differ (e.g. the personal center leaves `readAt` untouched on
  /// bulk-mark) override it.
  TItem notificationMarkAllRead(TItem item) =>
      notificationMarkRead(item, readAt: DateTime.now());

  /// Remote operations (host wires the repository).
  Future<bool> markNotificationReadRemote(String id);
  Future<bool> markAllNotificationsReadRemote();
  Future<bool> deleteNotificationRemote(String id);

  /// Mark a single notification as read.
  Future<void> markAsRead(String id) async {
    final success = await markNotificationReadRemote(id);
    if (!success) {
      // Failure is deliberately silent at the UI level (the item just stays
      // unread), but log it so repeat failures are diagnosable.
      _logger.warning('markAsRead failed for notification $id');
      return;
    }
    final result = NotificationListMutations.markAsRead(
      items: notificationItems,
      unreadCount: notificationUnreadCount,
      id: id,
      idOf: notificationIdOf,
      isReadOf: notificationIsReadOf,
      withReadAt: (item) => notificationMarkRead(item, readAt: DateTime.now()),
    );
    notificationState = updateNotificationState(
      result.items,
      unreadCount: result.unreadCount,
    );
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    final success = await markAllNotificationsReadRemote();
    if (!success) {
      _logger.warning('markAllAsRead failed');
      return;
    }
    final result = NotificationListMutations.markAllAsRead(
      items: notificationItems,
      withRead: notificationMarkAllRead,
    );
    notificationState = updateNotificationState(
      result.items,
      unreadCount: result.unreadCount,
    );
  }

  /// Delete a notification (optimistic), skipping the network call for
  /// synthetic local-only IDs (`rt_` prefix).
  Future<void> deleteNotification(String id) async {
    // Safe lookup - return early if item not found
    final itemToDelete = notificationItems
        .where((item) => notificationIdOf(item) == id)
        .firstOrNull;
    if (itemToDelete == null) return;

    // Optimistically remove from state for responsive UI
    final result = NotificationListMutations.delete(
      items: notificationItems,
      unreadCount: notificationUnreadCount,
      id: id,
      idOf: notificationIdOf,
      isReadOf: notificationIsReadOf,
    );
    final total = notificationTotal;
    notificationState = updateNotificationState(
      result.items,
      unreadCount: result.unreadCount,
      total: total == null ? null : (total - 1).clamp(0, 9999).toInt(),
    );

    // If ID is synthetic local-only ID (rt_), skip network deletion call
    if (id.startsWith('rt_')) return;

    try {
      final success = await deleteNotificationRemote(id);
      if (!success) {
        _logger.warning('deleteNotification API failed for notification $id');
      }
    } catch (e) {
      _logger.warning('deleteNotification failed for notification $id', e);
    }
  }
}
