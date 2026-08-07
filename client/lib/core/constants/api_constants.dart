import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/services/server_config_service.dart';

/// API Configuration Constants
///
/// Holds compile-time/default configuration as pure static constants, plus the
/// providers that resolve the effective base URLs (dynamic server config >
/// compile-time env). Keeping the constants free of any [Ref] dependency makes
/// them usable from pure logic and tests without building a Riverpod container.
class ApiConstants {
  ApiConstants._();

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _envSseBaseUrl = String.fromEnvironment(
    'SSE_BASE_URL',
    defaultValue: '',
  );

  // SSE Endpoint Paths
  static const String aiChatSseEndpoint = '/stream';
  static const String aiChatResumeEndpoint = '/resume';

  // Auth endpoint paths (single source of truth for service calls and the
  // auth interceptor's public-path / refresh-path checks).
  static const String authLoginPath = '/auth/login';
  static const String authRegisterPath = '/auth/register';
  static const String authSendCodePath = '/auth/send-code';
  static const String authRefreshPath = '/auth/refresh';

  /// Paths that do not require an access token. Includes the refresh path
  /// so the refresh flow never re-enters the interceptor's 401 handling.
  static const List<String> publicAuthPaths = [
    authLoginPath,
    authRegisterPath,
    authSendCodePath,
    authRefreshPath,
  ];

  // Timeout Configuration
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // HTTP Header Keys
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String acceptHeader = 'Accept';
  static const String acceptLanguageHeader = 'Accept-Language';
  static const String applicationJson = 'application/json';
}

/// Whether the API server is configured (dynamic config or compile-time env).
final apiConfiguredProvider = Provider<bool>((ref) {
  if (ApiConstants._envBaseUrl.isNotEmpty) return true;
  return ref.watch(serverConfigServiceProvider).isConfigured;
});

/// Effective API base URL.
///
/// Priority: Dynamic Config > Compile-time Env.
/// Returns an empty string if not configured (allows app startup to show the
/// config page; the router redirects to the server-setup page in that case).
final apiBaseUrlProvider = Provider<String>((ref) {
  final configService = ref.watch(serverConfigServiceProvider);
  final dynamicUrl = configService.baseUrl;
  if (dynamicUrl != null && dynamicUrl.isNotEmpty) return dynamicUrl;
  if (ApiConstants._envBaseUrl.isNotEmpty) return ApiConstants._envBaseUrl;
  return '';
});

/// Effective SSE base URL (for AI chat streaming).
///
/// Priority: Dynamic Config > Compile-time Env > Derived from [apiBaseUrlProvider].
final sseBaseUrlProvider = Provider<String>((ref) {
  final configService = ref.watch(serverConfigServiceProvider);
  final dynamicSseUrl = configService.sseBaseUrl;
  if (dynamicSseUrl != null && dynamicSseUrl.isNotEmpty) return dynamicSseUrl;
  if (ApiConstants._envSseBaseUrl.isNotEmpty) {
    return ApiConstants._envSseBaseUrl;
  }
  return '${ref.watch(apiBaseUrlProvider)}/chatbot/chat';
});
