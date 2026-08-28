import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/version/models/update_info.dart';
import 'package:finvo/shared/services/response_parser.dart';

final appVersionServiceProvider = Provider<AppVersionService>((ref) {
  return AppVersionService(ref.watch(networkClientProvider));
});

class AppVersionService {
  final NetworkClient _networkClient;
  final _logger = Logger('AppVersionService');

  AppVersionService(this._networkClient);

  /// Check version update against backend API
  Future<UpdateInfo?> checkUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      return await _networkClient.request<UpdateInfo>(
        '/version/check',
        method: HttpMethod.get,
        fromJsonT: (json) {
          // A missing `data` field falls back to the root (legacy shape);
          // a non-object envelope throws DataParsingException from the parser.
          final data = ResponseParser.parseData<Map<String, dynamic>>(
            json,
            // parseData only reaches whenNull when the root IS a Map.
            whenNull: () => json as Map<String, dynamic>,
          );

          final latestVersion =
              data['latestVersion'] as String? ?? currentVersion;
          final hasUpdate = _isVersionHigher(latestVersion, currentVersion);

          // The server may raise the minimum supported version
          // WITHOUT bumping latestVersion — a hard gate that must force an
          // update regardless of hasUpdate. Previously minSupportedVersion
          // was parsed into the model but never compared anywhere, so the
          // gate was a dead field.
          final minSupported =
              data['minSupportedVersion'] as String? ?? '0.0.0';
          final minNotMet = _isVersionHigher(minSupported, currentVersion);
          final forceUpdate =
              (data['forceUpdate'] as bool? ?? false) || minNotMet;

          String? targetUrl;
          final downloadUrls =
              data['downloadUrls'] as Map<String, dynamic>? ?? {};

          if (kIsWeb) {
            targetUrl = downloadUrls['webUrl'] as String?;
          } else if (Platform.isAndroid) {
            targetUrl = downloadUrls['androidApk'] as String?;
          } else if (Platform.isIOS) {
            targetUrl = downloadUrls['iosTestFlight'] as String?;
          }

          return UpdateInfo.fromServerResponse(
            currentVersion: currentVersion,
            data: data,
            targetDownloadUrl: targetUrl,
            hasUpdate: hasUpdate || minNotMet,
            forceUpdateOverride: forceUpdate,
          );
        },
      );
    } catch (e, stack) {
      _logger.warning('Failed to check app version: $e', e, stack);
      return null;
    }
  }

  /// Launch target download URL in browser or TestFlight
  Future<bool> openUpdateUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      _logger.severe('Failed to launch update URL: $url', e);
      return false;
    }
  }

  /// Helper to compare Semantic Versions (e.g. 0.2.0 vs 0.1.2-alpha)
  bool _isVersionHigher(String latest, String current) {
    try {
      final lClean = latest.split('-')[0].split('+')[0];
      final cClean = current.split('-')[0].split('+')[0];

      final lParts = lClean
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final cParts = cClean
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      for (var i = 0; i < 3; i++) {
        final lVal = i < lParts.length ? lParts[i] : 0;
        final cVal = i < cParts.length ? cParts[i] : 0;
        if (lVal > cVal) return true;
        if (lVal < cVal) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
