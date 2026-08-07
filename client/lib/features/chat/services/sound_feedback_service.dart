// features/chat/services/sound_feedback_service.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';

final _logger = Logger('SoundFeedbackService');

/// Speech Recognition Audio Feedback Service
///
/// Used to play start/end recording prompt sounds in a custom ASR service,
/// providing a user experience similar to system speech recognition.
///
/// Managed by a Riverpod `keepAlive` provider; do NOT instantiate directly
/// outside of the provider. Callers that need sound feedback should receive
/// the instance via constructor injection.
class SoundFeedbackService {
  AudioPlayer? _startPlayer;
  AudioPlayer? _stopPlayer;

  bool _isInitialized = false;
  bool _useHapticFallback = false;
  bool _isEnabled = true;

  /// Initialize sound resources
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Supported audio formats list (by priority)
    const startSoundFiles = [
      'assets/sounds/start_listening.mp3',
      'assets/sounds/start_listening.wav',
      'assets/sounds/start_listening.m4a',
    ];
    const stopSoundFiles = [
      'assets/sounds/stop_listening.mp3',
      'assets/sounds/stop_listening.wav',
      'assets/sounds/stop_listening.m4a',
    ];

    try {
      _startPlayer = AudioPlayer();
      _stopPlayer = AudioPlayer();

      // Try to load start sound
      bool startLoaded = false;
      for (final path in startSoundFiles) {
        try {
          await _startPlayer!.setAsset(path);
          _logger.info('Loaded start sound: $path');
          startLoaded = true;
          break;
        } catch (e) {
          _logger.fine('Failed to load $path: $e');
        }
      }

      // Try to load stop sound
      bool stopLoaded = false;
      for (final path in stopSoundFiles) {
        try {
          await _stopPlayer!.setAsset(path);
          _logger.info('Loaded stop sound: $path');
          stopLoaded = true;
          break;
        } catch (e) {
          _logger.fine('Failed to load $path: $e');
        }
      }

      if (!startLoaded || !stopLoaded) {
        throw Exception(
          'Failed to load sound files: start=$startLoaded, stop=$stopLoaded',
        );
      }

      // Set volume
      await _startPlayer!.setVolume(0.7);
      await _stopPlayer!.setVolume(0.7);

      _isInitialized = true;
      _useHapticFallback = false;
      _logger.info('Sound feedback service initialized with audio files');
    } catch (e, stackTrace) {
      final audioException = AudioServiceException(
        'Failed to load audio files, using haptic fallback: $e',
      );
      _logger.warning(
        'Sound feedback initialization fallback',
        audioException,
        stackTrace,
      );
      // Sound files not found, use haptic feedback as fallback
      _useHapticFallback = true;
      _isInitialized = true;

      // Clean up players
      unawaited(_startPlayer?.dispose());
      unawaited(_stopPlayer?.dispose());
      _startPlayer = null;
      _stopPlayer = null;
    }
  }

  /// Set whether sound feedback is enabled
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    _logger.info('Sound feedback ${enabled ? "enabled" : "disabled"}');
  }

  /// Play start recording prompt sound
  Future<void> playStartSound() async {
    if (!_isEnabled || !_isInitialized) {
      _logger.warning(
        'playStartSound skipped: enabled=$_isEnabled, initialized=$_isInitialized',
      );
      return;
    }

    _logger.info('Playing start sound (hapticFallback=$_useHapticFallback)');

    if (_useHapticFallback) {
      // Use haptic feedback as fallback
      await HapticFeedback.mediumImpact();
      return;
    }

    try {
      await _startPlayer?.seek(Duration.zero);
      await _startPlayer?.play();
      _logger.info('Start sound played successfully');
    } catch (e, stackTrace) {
      _logger.warning('Failed to play start sound', e, stackTrace);
      // Play failed, try haptic feedback
      await HapticFeedback.mediumImpact();
    }
  }

  /// Play stop recording prompt sound
  Future<void> playStopSound() async {
    if (!_isEnabled || !_isInitialized) {
      _logger.warning(
        'playStopSound skipped: enabled=$_isEnabled, initialized=$_isInitialized',
      );
      return;
    }

    _logger.info('Playing stop sound (hapticFallback=$_useHapticFallback)');

    if (_useHapticFallback) {
      // Use haptic feedback as fallback
      await HapticFeedback.lightImpact();
      return;
    }

    try {
      await _stopPlayer?.seek(Duration.zero);
      await _stopPlayer?.play();
      _logger.info('Stop sound played successfully');
    } catch (e, stackTrace) {
      _logger.warning('Failed to play stop sound', e, stackTrace);
      // Play failed, try haptic feedback
      await HapticFeedback.lightImpact();
    }
  }

  /// Release resources
  Future<void> dispose() async {
    await _startPlayer?.dispose();
    await _stopPlayer?.dispose();
    _isInitialized = false;
    _logger.info('Sound feedback service disposed');
  }
}
