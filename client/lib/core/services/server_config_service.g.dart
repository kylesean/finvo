// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_config_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SharedPreferences (should be overridden in main.dart)

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences (should be overridden in main.dart)

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Provider for SharedPreferences (should be overridden in main.dart)
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'1c2dd1a84771b17e16cc7c9461dd6736a2a28921';

/// Provider for ServerConfigService

@ProviderFor(serverConfigService)
final serverConfigServiceProvider = ServerConfigServiceProvider._();

/// Provider for ServerConfigService

final class ServerConfigServiceProvider
    extends
        $FunctionalProvider<
          ServerConfigService,
          ServerConfigService,
          ServerConfigService
        >
    with $Provider<ServerConfigService> {
  /// Provider for ServerConfigService
  ServerConfigServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverConfigServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverConfigServiceHash();

  @$internal
  @override
  $ProviderElement<ServerConfigService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServerConfigService create(Ref ref) {
    return serverConfigService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerConfigService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerConfigService>(value),
    );
  }
}

String _$serverConfigServiceHash() =>
    r'09dcbbf25565e519f911fed195ac05b4417f9ec6';

/// Provider for checking if server is configured

@ProviderFor(isServerConfigured)
final isServerConfiguredProvider = IsServerConfiguredProvider._();

/// Provider for checking if server is configured

final class IsServerConfiguredProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if server is configured
  IsServerConfiguredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isServerConfiguredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isServerConfiguredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isServerConfigured(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isServerConfiguredHash() =>
    r'47e70a0bdbfe8e5bcb47358030d29eeb813940af';

/// Provider for current server URL

@ProviderFor(serverUrl)
final serverUrlProvider = ServerUrlProvider._();

/// Provider for current server URL

final class ServerUrlProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provider for current server URL
  ServerUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverUrlHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return serverUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$serverUrlHash() => r'89ee847ec834172d97d0d2950fc3c66168d35631';

/// Provider for API base URL

@ProviderFor(apiBaseUrl)
final apiBaseUrlProvider = ApiBaseUrlProvider._();

/// Provider for API base URL

final class ApiBaseUrlProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provider for API base URL
  ApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiBaseUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return apiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$apiBaseUrlHash() => r'8e8c4b7561e1a35018d4515ff6db1e85b9d9a3c3';
