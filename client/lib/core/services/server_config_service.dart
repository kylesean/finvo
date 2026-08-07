import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:finvo/core/constants/api_constants.dart';
part 'server_config_service.g.dart';

final _logger = Logger('ServerConfigService');

/// Storage key for server URL
const String _serverUrlKey = 'server_url';

/// Service for managing server configuration
///
/// Handles:
/// - Persisting server URL to SharedPreferences
/// - Validating URL format
/// - Health checking the server
/// - Providing dynamic base URLs for network layer
class ServerConfigService {
  final SharedPreferences _prefs;

  ServerConfigService(this._prefs);

  /// Get the currently configured server URL
  String? get serverUrl => _prefs.getString(_serverUrlKey);

  /// Check if a server is configured
  bool get isConfigured => serverUrl != null && serverUrl!.isNotEmpty;

  /// Get the API base URL (with /api/v1 suffix)
  String? get baseUrl {
    final url = serverUrl;
    if (url == null || url.isEmpty) return null;

    // Remove trailing slash if present
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    return '$cleanUrl/api/v1';
  }

  /// Get the SSE base URL for streaming endpoints
  String? get sseBaseUrl {
    final base = baseUrl;
    if (base == null) return null;
    return '$base/chatbot/chat';
  }

  /// Save server URL to persistent storage
  Future<void> saveServerUrl(String url) async {
    // Normalize URL
    String normalizedUrl = url.trim();

    // Add protocol if missing. Loopback/private-network hosts (typical
    // self-hosted LAN servers that usually only listen on cleartext http)
    // default to http://; everything else defaults to the security-first
    // https://. Callers can always override by typing an explicit scheme.
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = '${_defaultSchemeFor(normalizedUrl)}://$normalizedUrl';
    }

    // Remove trailing slash
    if (normalizedUrl.endsWith('/')) {
      normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length - 1);
    }

    await _prefs.setString(_serverUrlKey, normalizedUrl);
    _logger.info('Server URL saved: $normalizedUrl');
  }

  /// Clear saved server URL
  Future<void> clearServerUrl() async {
    await _prefs.remove(_serverUrlKey);
    _logger.info('Server URL cleared');
  }

  /// Validate URL format
  /// Returns null if valid, error message if invalid
  String? validateUrl(String url) {
    if (url.trim().isEmpty) {
      return 'URL cannot be empty';
    }

    String testUrl = url.trim();
    if (!testUrl.startsWith('http://') && !testUrl.startsWith('https://')) {
      testUrl = '${_defaultSchemeFor(testUrl)}://$testUrl';
    }

    try {
      final uri = Uri.parse(testUrl);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Invalid URL format';
      }
      if (uri.host.isEmpty) {
        return 'Host cannot be empty';
      }
      // The stored value is used as the base URL and later suffixed with
      // /api/v1. Accepting a path here would produce a doubled path like
      // /api/v1/api/v1 on the wire, so reject any path component.
      if (uri.path.isNotEmpty && uri.path != '/') {
        return 'URL must be a host without a path (e.g. https://example.com)';
      }
    } catch (e) {
      return 'Invalid URL format';
    }

    return null; // Valid
  }

  /// Choose a default scheme for a bare host: loopback/private-network hosts
  /// (typical self-hosted LAN deployments that usually only listen on
  /// cleartext http) default to ``http``; anything else (public/intranet)
  /// defaults to the security-first ``https``. Callers can always override by
  /// typing an explicit scheme.
  static String _defaultSchemeFor(String bareUrl) {
    final host = _bareHostOf(bareUrl);
    if (host == 'localhost' || host == '::1') return 'http';
    if (host.startsWith('127.') ||
        host.startsWith('10.') ||
        host.startsWith('192.168.') ||
        host.startsWith('fe80:')) {
      return 'http';
    }
    // 172.16.0.0/12.
    if (host.startsWith('172.')) {
      final parts = host.split('.');
      final second = parts.length > 1 ? int.tryParse(parts[1]) : null;
      if (second != null && second >= 16 && second <= 31) return 'http';
    }
    return 'https';
  }

  /// Extract the bare host from a scheme-less ``host[:port]`` URL.
  ///
  /// Handles IPv6 literals (``[::1]:8080`` → ``::1``) and scheme-qualified
  /// inputs (``http://localhost:8080`` → ``localhost``) correctly.
  static String _bareHostOf(String bareUrl) {
    // Uri.parse correctly strips brackets from IPv6 literals and handles ports.
    final Uri? uri = Uri.tryParse(
      bareUrl.contains('://') ? bareUrl : 'http://$bareUrl',
    );
    if (uri != null && uri.host.isNotEmpty) {
      return uri.host.toLowerCase();
    }
    // Fallback: strip brackets manually and drop any port suffix.
    final stripped = bareUrl.replaceAll('[', '').replaceAll(']', '');
    final withoutPort = stripped.split(':').first;
    return withoutPort.toLowerCase();
  }

  /// Check server health and return server info
  /// Returns a [ServerHealthResult] with connection status and server info
  Future<ServerHealthResult> checkHealth(String url) async {
    // Normalize URL for health check
    String normalizedUrl = url.trim();
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = '${_defaultSchemeFor(normalizedUrl)}://$normalizedUrl';
    }
    if (normalizedUrl.endsWith('/')) {
      normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length - 1);
    }

    final healthUrl = '$normalizedUrl/api/v1/health';
    _logger.info('Checking health at: $healthUrl');

    // Health checks run from the server-setup flow, i.e. BEFORE the server is
    // configured, so the app's unified Dio (whose ConfigurationCheckInterceptor
    // rejects unconfigured requests) cannot be used here. A minimal standalone
    // instance with the shared timeout constants is used instead.
    final dio = Dio()
      ..options.connectTimeout = ApiConstants.connectTimeout
      ..options.receiveTimeout = ApiConstants.receiveTimeout;

    try {
      final response = await dio.get<dynamic>(healthUrl);

      if (response.statusCode == 200) {
        final data = response.data;

        // Accept both the unified envelope {"code": 0, "data": {…}} and the
        // legacy flat {"status": "healthy", …} shapes. The server-setup flow
        // talks to the lightweight /api/v1/health probe, which intentionally
        // returns a flat dict, while the comprehensive /health endpoint in
        // main.py returns the envelope. Either way we require an explicit
        // "healthy" status so an unrelated HTTP 200 (an HTML error page, a
        // proxy, a different service) is never mistaken for a healthy Finvo
        // backend.
        if (data is Map) {
          final body = data['data'] is Map ? data['data'] as Map : data;
          if (body['status'] == 'healthy') {
            final version = body['version']?.toString();
            final environment = body['environment']?.toString();
            _logger.info(
              'Health check successful: version=$version, env=$environment',
            );
            return ServerHealthResult(
              isHealthy: true,
              version: version,
              environment: environment,
            );
          }
        }

        _logger.warning('Health check returned an unexpected envelope: $data');
        return const ServerHealthResult(
          isHealthy: false,
          errorMessage: 'Server returned an invalid health response',
        );
      } else {
        _logger.warning(
          'Health check failed with status: ${response.statusCode}',
        );
        return ServerHealthResult(
          isHealthy: false,
          errorMessage: 'Server returned status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timed out';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Could not connect to server';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'SSL certificate error';
          break;
        default:
          errorMessage = e.message ?? 'Connection failed';
      }
      _logger.warning('Health check error: $errorMessage');
      return ServerHealthResult(isHealthy: false, errorMessage: errorMessage);
    } catch (e, stackTrace) {
      _logger.severe('Unexpected health check error', e, stackTrace);
      return ServerHealthResult(
        isHealthy: false,
        errorMessage: 'Unexpected error: $e',
      );
    } finally {
      dio.close();
    }
  }
}

/// Result of a server health check
class ServerHealthResult {
  final bool isHealthy;
  final String? version;
  final String? environment;
  final String? errorMessage;

  const ServerHealthResult({
    required this.isHealthy,
    this.version,
    this.environment,
    this.errorMessage,
  });

  @override
  String toString() {
    if (isHealthy) {
      return 'ServerHealthResult(healthy, version: $version, env: $environment)';
    }
    return 'ServerHealthResult(unhealthy, error: $errorMessage)';
  }
}

/// Provider for SharedPreferences (should be overridden in main.dart)
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
}

/// Provider for ServerConfigService
@Riverpod(keepAlive: true)
ServerConfigService serverConfigService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ServerConfigService(prefs);
}

/// Provider for checking if server is configured
@Riverpod(keepAlive: true)
bool isServerConfigured(Ref ref) {
  return ref.watch(serverConfigServiceProvider).isConfigured;
}

/// Provider for current server URL
@Riverpod(keepAlive: true)
String? serverUrl(Ref ref) {
  return ref.watch(serverConfigServiceProvider).serverUrl;
}
