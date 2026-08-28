/// Whitelist resolver for server-supplied notification deep links .
///
/// Notification payloads carry a `target_path` written by the backend. The
/// tap handler used to `context.push` that raw string, so a malicious or
/// buggy backend could navigate the user to any internal route (e.g. the
/// server-setup or logout-adjacent flows), bypassing the typed-route
/// discipline. This resolver only accepts paths matching the exact set of
/// targets the backend actually emits (see
/// `server/app/services/notification_handlers.py` and
/// `server/app/services/transaction/comment_service.py`):
///
/// - `/home/transaction/{transactionId}` (optionally `?commentId=...`)
/// - `/profile/shared-space` and `/profile/shared-space/{spaceId}`
/// - `/finance/recurring-transactions`
///
/// Anything else resolves to null and the caller ignores the navigation.
library;

/// Route prefixes a notification `target_path` may point at.
///
/// Matched on path-segment boundaries only: `/home/transaction` does NOT
/// match `/home/transactions-evil`, mirroring the router guard's boundary
/// matching.
const List<String> notificationTargetPrefixes = [
  '/home/transaction',
  '/profile/shared-space',
  '/finance/recurring-transactions',
];

/// Resolves a server-supplied `target_path` to a safe internal route.
///
/// Returns the path unchanged when it is on the whitelist, or null when it
/// is absent, malformed, or points outside the whitelist.
String? resolveNotificationTarget(String? rawPath) {
  if (rawPath == null || rawPath.isEmpty) {
    return null;
  }
  // Same-app absolute paths only: reject any scheme/host injection
  // (`http://...`, `//evil.com`) and unparseable input.
  if (!rawPath.startsWith('/')) {
    return null;
  }
  final uri = Uri.tryParse(rawPath);
  if (uri == null || uri.scheme.isNotEmpty || uri.hasAuthority) {
    return null;
  }
  // `uri.path` excludes any query string, so boundary matching sees only
  // the path segments.
  final pathOnly = uri.path;
  for (final prefix in notificationTargetPrefixes) {
    if (pathOnly == prefix || pathOnly.startsWith('$prefix/')) {
      return rawPath;
    }
  }
  return null;
}
