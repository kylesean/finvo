class DownloadUrls {
  final String androidApk;
  final String iosTestFlight;
  final String webUrl;

  const DownloadUrls({
    this.androidApk = '',
    this.iosTestFlight = '',
    this.webUrl = '',
  });

  factory DownloadUrls.fromJson(Map<String, dynamic> json) {
    return DownloadUrls(
      androidApk: json['androidApk'] as String? ?? '',
      iosTestFlight: json['iosTestFlight'] as String? ?? '',
      webUrl: json['webUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'androidApk': androidApk,
      'iosTestFlight': iosTestFlight,
      'webUrl': webUrl,
    };
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String minSupportedVersion;
  final bool hasUpdate;
  final bool forceUpdate;
  final String releaseDate;
  final String changelog;
  final DownloadUrls downloadUrls;
  final String? targetDownloadUrl;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.hasUpdate,
    required this.forceUpdate,
    required this.releaseDate,
    required this.changelog,
    required this.downloadUrls,
    this.targetDownloadUrl,
  });

  factory UpdateInfo.fromServerResponse({
    required String currentVersion,
    required Map<String, dynamic> data,
    required String? targetDownloadUrl,
    required bool hasUpdate,
    bool? forceUpdateOverride,
  }) {
    return UpdateInfo(
      currentVersion: currentVersion,
      latestVersion: data['latestVersion'] as String? ?? currentVersion,
      minSupportedVersion: data['minSupportedVersion'] as String? ?? '0.0.0',
      hasUpdate: hasUpdate,
      // AUTH-V1: the service may force the update (e.g. when the local
      // version is below minSupportedVersion) without the server flagging it.
      forceUpdate:
          forceUpdateOverride ?? (data['forceUpdate'] as bool? ?? false),
      releaseDate: data['releaseDate'] as String? ?? '',
      changelog: data['changelog'] as String? ?? '',
      downloadUrls: DownloadUrls.fromJson(
        (data['downloadUrls'] as Map<String, dynamic>?) ?? {},
      ),
      targetDownloadUrl: targetDownloadUrl,
    );
  }
}
