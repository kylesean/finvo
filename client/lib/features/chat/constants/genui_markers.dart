/// Wire-level marker for optimistic UI notifications.
///
/// When an internal GenUI interaction sends a request through
/// [CustomContentGenerator], the upper layer is notified with this prefix so
/// it knows the request is already in flight and must NOT re-send it.
const String genuiInternalMarker = '[GENUI_INTERNAL]';
