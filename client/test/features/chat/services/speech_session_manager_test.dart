import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/chat/models/speech_error_type.dart';
import 'package:finvo/features/chat/services/speech_session_manager.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';

class DummySpeechRecognitionService implements SpeechRecognitionService {
  final StreamController<String> _resultController =
      StreamController<String>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  bool isReadyToReturn = true;
  bool isIncremental = false;
  bool startListeningCalled = false;
  bool stopListeningCalled = false;
  bool disposed = false;

  @override
  bool get isListening => startListeningCalled && !stopListeningCalled;

  @override
  SpeechServiceType get serviceType => SpeechServiceType.system;

  @override
  Stream<String> get onResult => _resultController.stream;

  @override
  Stream<String> get onStatus => _statusController.stream;

  @override
  Stream<String> get onError => _errorController.stream;

  @override
  bool get isIncrementalResult => isIncremental;

  @override
  Future<bool> ensureReady() async => isReadyToReturn;

  @override
  Future<bool> initialize() async => isReadyToReturn;

  @override
  bool get isInitialized => false;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> startListening() async {
    startListeningCalled = true;
  }

  @override
  Future<void> stopListening() async {
    stopListeningCalled = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _resultController.close();
    await _statusController.close();
    await _errorController.close();
  }

  void emitResult(String text) => _resultController.add(text);
  void emitStatus(String status) => _statusController.add(status);
  void emitError(String error) => _errorController.add(error);
}

class FakeSoundFeedbackService extends SoundFeedbackService {
  bool startSoundPlayed = false;

  @override
  Future<void> playStartSound() async {
    startSoundPlayed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeechErrorClassifier', () {
    test('classifies network errors correctly', () {
      expect(
        SpeechErrorClassifier.classify('network connection failed'),
        SpeechErrorType.connectionFailed,
      );
    });

    test('classifies permission errors correctly', () {
      expect(
        SpeechErrorClassifier.classify('permission denied'),
        SpeechErrorType.permissionDenied,
      );
    });

    test('classifies unknown errors as generic error', () {
      expect(
        SpeechErrorClassifier.classify('some_random_error'),
        SpeechErrorType.unknown,
      );
    });
  });

  group('SpeechSessionManager', () {
    late FakeSoundFeedbackService fakeSoundFeedback;
    late SpeechSessionManager manager;

    setUp(() {
      fakeSoundFeedback = FakeSoundFeedbackService();
      manager = SpeechSessionManager(soundFeedback: fakeSoundFeedback);
    });

    tearDown(() {
      manager.disposeService();
    });

    test('initial state is unconfigured and not listening', () {
      expect(manager.isListening, false);
      expect(manager.serviceType, null);
      expect(manager.isIncrementalResult, false);
    });

    test('startSession returns error when no service set', () async {
      final error = await manager.startSession();
      expect(error, SpeechErrorType.notConfigured);
    });

    test('cancelNoInputTimer disarms active timer without throwing', () {
      expect(() => manager.cancelNoInputTimer(), returnsNormally);
    });

    test('disposeService resets state and cleans up resources', () {
      manager.disposeService();
      expect(manager.isListening, false);
      expect(manager.serviceType, null);
    });
  });
}
