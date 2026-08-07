class SpeechConfig {
  /// Default WebSocket host from compile-time environment
  /// Returns empty string if not configured (allows user to configure in settings)
  static String get host {
    const envHost = String.fromEnvironment('SPEECH_WS_HOST', defaultValue: '');
    return envHost;
  }

  /// Check if Speech WebSocket is configured via compile-time environment
  static bool get isConfiguredFromEnv => host.isNotEmpty;

  static int get port {
    const envPort = int.fromEnvironment('SPEECH_WS_PORT', defaultValue: 8080);
    return envPort;
  }

  /// WebSocket scheme: 'ws' (plaintext, legacy default) or 'wss' (TLS).
  ///
  /// Voice data is sensitive; deployments behind TLS should set
  /// SPEECH_WS_SCHEME=wss so the audio stream is encrypted in transit.
  static String get scheme {
    const envScheme = String.fromEnvironment(
      'SPEECH_WS_SCHEME',
      defaultValue: 'ws',
    );
    return envScheme == 'wss' ? 'wss' : 'ws';
  }

  static String get path => '/ws';

  /// Full WebSocket URL (only valid if host is configured)
  /// Returns empty string if host is not configured.
  /// A host value that already carries a scheme (ws:// or wss://) is used
  /// verbatim so user-configured endpoints can opt into TLS directly.
  static String get fullUrl {
    if (host.isEmpty) return '';
    if (host.startsWith('ws://') || host.startsWith('wss://')) {
      return '$host$path';
    }
    return '$scheme://$host:$port$path';
  }
}
