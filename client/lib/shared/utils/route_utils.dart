import 'dart:async';

/// How long to wait after dismissing a transient route (a drawer, a bottom
/// sheet, or a just-completed auth flow) before scheduling the next
/// navigation.
///
/// Navigating while the previous route is still animating out would cut the
/// closing animation short and can flash an intermediate frame. This constant
/// centralises the previously copy-pasted
/// `Future.delayed(const Duration(milliseconds: 100))` navigational hack so
/// the timing is defined once instead of scattered across call sites.
const Duration routeSettleDelay = Duration(milliseconds: 100);

/// Yields for [routeSettleDelay] so the closing animation of a just-dismissed
/// route completes before the caller schedules the next navigation.
Future<void> waitForRouteSettle() => Future<void>.delayed(routeSettleDelay);
