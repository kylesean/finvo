import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/network_client.dart';
import '../models/update_info.dart';

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
          if (json is Map<String, dynamic>) {
            final data = (json['data'] as Map<String, dynamic>?) ?? json;

            final latestVersion =
                data['latestVersion'] as String? ?? currentVersion;
            final hasUpdate = _isVersionHigher(latestVersion, currentVersion);

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
              hasUpdate: hasUpdate,
            );
          }
          throw Exception('Invalid version response format');
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
