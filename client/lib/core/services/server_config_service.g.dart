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
