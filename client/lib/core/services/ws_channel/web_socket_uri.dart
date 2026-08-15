// Platform-neutral helper for attaching the auth token to a WebSocket URL.
// Kept free of any web/io imports so it can be unit tested on the VM without
// pulling in `dart:html` (web_socket_channel/html.dart) transitive deps.
//
// The web implementation uses this because the browser WebSocket API does not
// allow custom headers, so the token travels as a query parameter instead.

/// Attach [token] to [wsUrl] as a query parameter (web fallback).
///
/// Existing query parameters on [wsUrl] are preserved: a future caller that
/// appends e.g. `?trace=1` must not silently lose parameters when the token
/// is added.
Uri webSocketUriWithToken(String wsUrl, {required String token}) {
  final base = Uri.parse(wsUrl);
  return base.replace(
    queryParameters: {...base.queryParameters, 'token': token},
  );
}
