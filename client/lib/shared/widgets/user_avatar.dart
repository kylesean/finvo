import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:augo/core/constants/api_constants.dart';
import 'identicon_avatar.dart';

/// A circular user avatar loaded from the public ``/avatars/{userId}``
/// endpoint, with a deterministic identicon as the offline / error fallback.
///
/// Every avatar in the app (profile, chat drawer, comments, shared spaces)
/// goes through this single widget, so display logic never diverges and no
/// location needs authentication plumbing: the server resolves the uploaded
/// image or the generated identicon behind one unauthenticated URL.
///
/// While the network image loads, or if it fails (offline, server down), the
/// user's identicon is shown — a graceful, themed placeholder that matches the
/// eventual image's identity.
class UserAvatar extends ConsumerWidget {
  /// The user's UUID, used both for the avatar URL and as the identicon seed.
  final String userId;

  /// The circle's diameter in logical pixels.
  final double size;

  /// Background color behind the image / identicon. Defaults to [FColors.muted].
  final Color? backgroundColor;

  /// Optional circular border (e.g. the profile page's ring).
  final BoxBorder? border;

  /// Optional cache-busting value (e.g. the user's ``updatedAt``) appended as
  /// ``?v=`` so a freshly uploaded avatar shows immediately on the owner's
  /// own profile while remaining cacheable everywhere else.
  final String? version;

  const UserAvatar({
    required this.userId,
    this.size = 40,
    this.backgroundColor,
    this.border,
    this.version,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = backgroundColor ?? context.theme.colors.muted;
    final fallback = IdenticonAvatar(
      seed: userId,
      size: size,
      backgroundColor: background,
    );

    final baseUrl = ref.read(apiConstantsProvider).baseUrl;
    final Widget content;
    if (baseUrl.isEmpty) {
      // Server not configured yet (setup screen) — show the local identicon.
      content = fallback;
    } else {
      var url = '$baseUrl/avatars/$userId';
      if (version != null && version!.isNotEmpty) {
        url += '?v=${Uri.encodeQueryComponent(version!)}';
      }
      content = Image(
        image: NetworkImage(url),
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, progress) => fallback,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
      ),
      child: ClipOval(child: content),
    );
  }
}
