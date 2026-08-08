import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';

final _logger = Logger('SystemSpeechService');

/// System speech recognition service
///
/// Based on speech_to_text library implementation, using device's built-in speech recognition service.
/// Supports iOS, Android, and Web platforms.
class SystemSpeechService implements SpeechRecognitionService {
  static const _platformChannel = MethodChannel('com.finvo.app/speech_check');

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Stream controllers for different events
  final StreamController<String> _resultController =
      StreamController<String>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  String? _lastError;

  /// Recognition language, default Chinese (BCP 47 format 'zh-CN')
  final String localeId;

  /// Constructor
  ///
  /// [localeId] Recognition language, default is 'zh-CN' (Chinese)
  SystemSpeechService({this.localeId = 'zh-CN'});

  String get _formattedLocaleId => localeId.replaceAll('_', '-');

  String? get lastError => _lastError;

  @override
  Stream<String> get onResult => _resultController.stream;

  @override
  Stream<String> get onStatus => _statusController.stream;

  @override
  Stream<String> get onError => _errorController.stream;

  @override
  bool get isListening => _isListening;

  @override
  bool get isInitialized => _isInitialized;

  @override
  SpeechServiceType get serviceType => SpeechServiceType.system;

  @override
  bool get isIncrementalResult => false; // System speech is replacement mode, not incremental

  @override
  Future<bool> hasPermission() async {
    if (_isInitialized) return true;

    try {
      final available = await _speech.initialize(
        onStatus: (_) {},
        onError: (_) {},
      );
      return available;
    } catch (e) {
      _logger.warning('Permission check failed: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    return await hasPermission();
  }

  @override
  Future<bool> ensureReady() async {
    if (_isInitialized) return true;
    return await initialize();
  }

  Future<bool> _isPlatformSpeechAvailable() async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      _logger.info(
        'System speech recognition is not supported on Linux/Windows desktop',
      );
      return false;
    }
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final bool? isAvailable = await _platformChannel.invokeMethod<bool>(
          'isSystemSpeechAvailable',
        );
        return isAvailable ?? false;
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) {
      _logger.info(
        'System speech service already initialized, reusing existing instance',
      );
      return true;
    }

    try {
      _logger.info('Initializing system speech recognition service...');
      _statusController.add('connecting');
      _lastError = null;

      final isPlatformAvailable = await _isPlatformSpeechAvailable();
      if (!isPlatformAvailable) {
        _logger.warning(
          'Native Android speech service is restricted or unavailable',
        );
        _lastError = 'system_speech_restricted';
        _statusController.add('error');
        _errorController.add(_lastError!);
        return false;
      }

      final available = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
        debugLogging: false,
      );

      if (available) {
        _isInitialized = true;
        _statusController.add('connected');
        _logger.info(
          'System speech recognition service initialized successfully',
        );

        // Get available language list
        final locales = await _speech.locales();
        _logger.info(
          'Available languages: ${locales.map((l) => l.localeId).join(', ')}',
        );
      } else {
        _statusController.add('disconnected');
        final hasPerm = await hasPermission();
        if (!hasPerm) {
          _lastError = 'permission_denied';
        } else if (!kIsWeb && Platform.isIOS) {
          _lastError = 'dictation_disabled';
        } else {
          _lastError = 'system_speech_restricted';
        }
        _logger.warning('System speech recognition unavailable: $_lastError');
        _errorController.add(_lastError!);
      }

      return available;
    } catch (e) {
      _logger.severe(
        'System speech recognition service initialization failed: $e',
      );
      _statusController.add('error');
      _lastError = 'Initialization failed: $e';
      _errorController.add(_lastError!);
      return false;
    }
  }

  @override
  Future<void> startListening() async {
    if (!_isInitialized) {
      _logger.warning('Service not initialized, cannot start listening');
      _statusController.add('error');
      _errorController.add(_lastError ?? 'system_speech_restricted');
      return;
    }

    if (_isListening) {
      _logger.warning('Already listening');
      return;
    }

    try {
      _logger.info(
        'Starting system speech recognition (locale: $_formattedLocaleId)...',
      );
      _isListening = true;
      _statusController.add('listening');

      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          localeId: _formattedLocaleId,
          listenFor: const Duration(
            seconds: 30,
          ), // Maximum listening time 30 seconds
          pauseFor: const Duration(
            seconds: 3,
          ), // Automatically end after 3 seconds of pause
        ),
      );

      _logger.info('System speech recognition started');
    } catch (e) {
      _logger.severe('Failed to start listening: $e');
      _isListening = false;
      _statusController.add('error');
      final errStr = e.toString();
      if (errStr.contains('permission') || errStr.contains('denied')) {
        _errorController.add('permission_denied');
      } else if (errStr.contains('SecurityException') ||
          errStr.contains('Not allowed to bind') ||
          errStr.contains('error_speech_restricted') ||
          errStr.contains('bindService')) {
        _errorController.add('system_speech_restricted');
      } else {
        _errorController.add('Failed to start listening: $e');
      }
    }
  }

  @override
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }

    try {
      _logger.info('Stopping system speech recognition...');
      await _speech.stop();
      _isListening = false;
      _statusController.add('stopped');
      _logger.info('System speech recognition stopped');
    } catch (e) {
      _logger.severe('Failed to stop listening: $e');
      _isListening = false;
      _statusController.add('error');
      _errorController.add('Failed to stop listening: $e');
    }
  }

  /// Handle recognition results
  ///
  /// speech_to_text's partialResults returns accumulated text.
  /// Only push final results to avoid conflicts with WebSocket incremental mode processing logic.
  void _onResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords;

    if (recognizedWords.isEmpty) return;

    _logger.fine(
      'Recognition result: $recognizedWords (final: ${result.finalResult})',
    );

    // Only push on final result
    if (result.finalResult) {
      _resultController.add(recognizedWords);
      _isListening = false;
      _statusController.add('stopped');
    }
  }

  /// Handle status changes
  void _onStatus(String status) {
    _logger.info('System speech status: $status');

    // Map speech_to_text status to our status
    switch (status) {
      case 'listening':
        _isListening = true;
        _statusController.add('listening');
        break;
      case 'notListening':
        _isListening = false;
        _statusController.add('stopped');
        break;
      case 'done':
        _isListening = false;
        _statusController.add('stopped');
        break;
      default:
        _statusController.add(status);
    }
  }

  /// Handle errors
  void _onError(SpeechRecognitionError error) {
    _logger.severe('System speech error: ${error.errorMsg}');
    _isListening = false;

    // Handle common errors
    // Note: no-speech is normal behavior for Android system speech recognition (user timeout),
    // should not be pushed to user as an error, just silently end listening
    if (error.errorMsg.contains('no-speech')) {
      _logger.info(
        'no-speech: User did not speak or paused, silently end listening',
      );
      _statusController.add('stopped');
      return; // Don't push error to avoid showing "no speech detected"
    }

    String userMessage;
    final lowerMsg = error.errorMsg.toLowerCase();
    if (lowerMsg.contains('permission') || lowerMsg.contains('denied')) {
      userMessage = 'permission_denied';
    } else if (lowerMsg.contains('error_speech_restricted') ||
        lowerMsg.contains('securityexception') ||
        lowerMsg.contains('not allowed to bind') ||
        lowerMsg.contains('bindservice')) {
      userMessage = (!kIsWeb && Platform.isIOS)
          ? 'dictation_disabled'
          : 'system_speech_restricted';
    } else if (lowerMsg.contains('audio')) {
      userMessage = 'permission_denied';
    } else if (lowerMsg.contains('network')) {
      userMessage = 'Network error, please check network connection';
    } else {
      userMessage = 'Speech recognition error: ${error.errorMsg}';
    }

    _errorController.add(userMessage);
    _statusController.add('error');
  }

  @override
  Future<void> dispose() async {
    _logger.info('Releasing system speech service resources');

    if (_isListening) {
      await _speech.stop();
    }
    await _speech.cancel();

    _isListening = false;
    _isInitialized = false;

    // Close stream controllers
    if (!_resultController.isClosed) unawaited(_resultController.close());
    if (!_statusController.isClosed) unawaited(_statusController.close());
    if (!_errorController.isClosed) unawaited(_errorController.close());
  }
}
