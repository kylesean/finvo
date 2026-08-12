import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/shared/widgets/identicon_avatar.dart';

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

  /// Optional direct avatar URL (e.g. user.avatarUrl)
  final String? avatarUrl;

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
    this.avatarUrl,
    this.size = 40,
    this.backgroundColor,
    this.border,
    this.version,
    super.key,
  });

  // Hoisted out of build() so the pattern is compiled once instead of on every
  // widget rebuild.
  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = backgroundColor ?? context.theme.colors.muted;
    final fallback = IdenticonAvatar(
      seed: userId,
      size: size,
      backgroundColor: background,
    );

    final baseUrl = ref.read(apiBaseUrlProvider);
    final isUuid = _uuidPattern.hasMatch(userId);

    String? targetUrl;
    if (avatarUrl != null &&
        avatarUrl!.trim().isNotEmpty &&
        (avatarUrl!.startsWith('http://') ||
            avatarUrl!.startsWith('https://')) &&
        !avatarUrl!.contains('/files/view/')) {
      // External third-party URL loads directly
      targetUrl = avatarUrl!.trim();
    } else if (baseUrl.isNotEmpty && isUuid) {
      // Finvo internal uploaded avatars are served through the public /avatars/{userId} endpoint
      targetUrl = '$baseUrl/avatars/$userId';
    }

    final Widget content;
    if (targetUrl == null || targetUrl.isEmpty) {
      content = fallback;
    } else {
      var requestUrl = targetUrl;
      if (version != null && version!.isNotEmpty) {
        final sep = requestUrl.contains('?') ? '&' : '?';
        requestUrl += '${sep}v=${Uri.encodeQueryComponent(version!)}';
      }
      // Debug-only diagnostics: the URL and userId are PII and must never be
      // emitted in production logs.
      if (kDebugMode) {
        debugPrint(
          '[UserAvatar] userId=$userId url=$requestUrl version=${version ?? '-'}',
        );
      }
      content = Image(
        key: ValueKey(requestUrl),
        image: NetworkImage(requestUrl),
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            debugPrint(
              '[UserAvatar] IMAGE FAILED userId=$userId url=$requestUrl error=$error',
            );
          }
          return fallback;
        },
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
