import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/profile/providers/user_profile_provider.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';
import 'package:finvo/shared/providers/financial_settings_provider.dart';

part 'server_config_provider.freezed.dart';

final _logger = Logger('ServerConfigProvider');

/// State for server configuration
@freezed
class ServerConfigState with _$ServerConfigState {
  const factory ServerConfigState.initial() = _Initial;
  const factory ServerConfigState.loading() = _Loading;
  const factory ServerConfigState.notConfigured() = _NotConfigured;
  const factory ServerConfigState.checking() = _Checking;
  const factory ServerConfigState.configured({
    required String serverUrl,
    String? version,
    String? environment,
  }) = _Configured;
  const factory ServerConfigState.error(String message) = _Error;
}

/// Notifier for managing server configuration state
class ServerConfigNotifier extends Notifier<ServerConfigState> {
  @override
  ServerConfigState build() {
    final configService = ref.watch(serverConfigServiceProvider);

    if (configService.isConfigured) {
      return ServerConfigState.configured(serverUrl: configService.serverUrl!);
    }
    return const ServerConfigState.notConfigured();
  }

  /// Save the server URL and mark as configured
  ///
  /// If switching to a different server, local authentication data
  /// will be cleared to prevent data conflicts between servers.
  Future<void> saveServerUrl(String url) async {
    final configService = ref.read(serverConfigServiceProvider);
    final currentUrl = configService.serverUrl;
    final isNewServer = currentUrl != null && currentUrl != url;

    // If switching to a different server, clear local auth data
    if (isNewServer) {
      _logger.info(
        'Switching server from $currentUrl to $url, clearing auth data',
      );
      final storageService = ref.read(secureStorageServiceProvider);
      await storageService.clearAllData();
    }

    await configService.saveServerUrl(url);

    state = ServerConfigState.configured(serverUrl: url);

    // Invalidate all providers that depend on server URL
    ref.invalidate(serverConfigServiceProvider);
    ref.invalidate(apiConfiguredProvider);
    ref.invalidate(apiBaseUrlProvider);
    ref.invalidate(serverUrlProvider);

    // CORE-M7: a server switch is effectively a new account context (local
    // auth data was cleared above) — invalidate every provider holding data
    // fetched from the OLD server, not just the URL providers. Without this,
    // the previous server's PII/currency settings keep rendering until the
    // first 401 from the new server.
    ref.invalidate(financialSettingsProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(financialAccountProvider);
    ref.invalidate(exchangeRateProvider);
    ref.invalidate(notificationProvider);

    // Rebuild the notification WebSocket: it captures the baseUrl once at
    // build time, so without this invalidation it would keep connecting to
    // (and reconnect-looping towards) the old server after a server switch.
    ref.invalidate(notificationWsProvider);
  }

  /// Clear server configuration
  Future<void> clearConfiguration() async {
    final configService = ref.read(serverConfigServiceProvider);
    await configService.clearServerUrl();

    state = const ServerConfigState.notConfigured();

    // Invalidate all providers that depend on server URL
    ref.invalidate(serverConfigServiceProvider);
    ref.invalidate(apiConfiguredProvider);
    ref.invalidate(apiBaseUrlProvider);
    ref.invalidate(serverUrlProvider);
    // Same account-scoped invalidation as saveServerUrl (CORE-M7).
    ref.invalidate(financialSettingsProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(financialAccountProvider);
    ref.invalidate(exchangeRateProvider);
    ref.invalidate(notificationProvider);
    ref.invalidate(notificationWsProvider);
  }

  /// Reset to initial state (for retry)
  void reset() {
    final configService = ref.read(serverConfigServiceProvider);
    if (configService.isConfigured) {
      state = ServerConfigState.configured(serverUrl: configService.serverUrl!);
    } else {
      state = const ServerConfigState.notConfigured();
    }
  }
}

/// Provider for server configuration state
final serverConfigProvider =
    NotifierProvider<ServerConfigNotifier, ServerConfigState>(() {
      return ServerConfigNotifier();
    });
