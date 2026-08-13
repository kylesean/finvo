import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/features/chat/models/speech_error_type.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/chat/services/speech_session_manager.dart';
import 'package:finvo/features/chat/services/file_upload_service.dart';
import 'package:finvo/features/chat/models/message_attachments.dart';
import 'package:finvo/features/profile/models/speech_settings.dart';
import 'package:finvo/features/profile/providers/speech_settings_provider.dart';
import 'package:finvo/features/chat/providers/sound_feedback_provider.dart';
import 'package:finvo/features/chat/providers/chat_input_state.dart';
import 'package:finvo/i18n/strings.g.dart';

part 'chat_input_provider.g.dart';

final _logger = Logger('ChatInputNotifier');

typedef OnSendMessageCallback =
    Future<void> Function(
      String, {
      List<PendingMessageAttachment>? attachments,
    });

/// Simplified media file handling
extension ChatInputStateMediaHandling on ChatInputState {
  /// Currently uploaded file list
  List<XFile> get currentFiles => selectedFiles;

  /// Check if there are media files
  bool get hasMediaFiles => selectedFiles.isNotEmpty;
}

@riverpod
class ChatInputNotifier extends _$ChatInputNotifier {
  SpeechSessionManager? _speechSessionInstance;
  SpeechSessionManager get _speechSession => _speechSessionInstance ??=
      SpeechSessionManager(soundFeedback: ref.read(soundFeedbackProvider));
  FileUploadService? _fileUploadService;

  final Map<String, UploadedAttachmentInfo> _uploadedInfos = {};

  String _textBeforeSpeechSession = '';
  bool _isManualStop = false;

  /// Synchronous re-entrancy guard for [_submitMessage]. Must be set BEFORE
  /// any await: in voice mode the speech stop can take hundreds of
  /// milliseconds, and `state.isLoadingResponse` is only set after that
  /// await — a rapid double-tap would otherwise pass the guard twice and run
  /// two concurrent send pipelines (the second cancels the first's stream
  /// and both duplicate messages into the list).
  bool _isSubmitting = false;

  /// Set when the provider is disposed. Long-running async flows
  /// (_startNewSpeechSession, _submitMessage, _uploadFilesInBackground)
  /// must not touch `state` after disposal: the notifier is recreated on the
  /// next UI visit, so writing into a disposed instance would silently
  /// corrupt the fresh one.
  bool _disposed = false;

  /// The current send-message callback. Stored as a mutable field (instead of
  /// relying only on the build parameter) so a reused widget State can swap in
  /// a fresher callback via [updateOnSendMessage] without resetting the whole
  /// provider and losing the draft/isiVoice state.
  late OnSendMessageCallback _onSendMessage;

  @override
  ChatInputState build(OnSendMessageCallback onSendMessage) {
    _onSendMessage = onSendMessage;

    // Service initialization
    _fileUploadService = ref.watch(fileUploadServiceProvider);

    // Initial speech configuration. Follow-up changes are applied via
    // ref.listen below; using ref.watch here would rebuild the whole
    // provider (and re-run setServiceType) on every settings change.
    _configureSpeech(ref.read(speechSettingsProvider).settings);

    ref.listen(speechSettingsProvider, (previous, next) {
      _configureSpeech(next.settings);
    });

    // Wire the speech manager callbacks to the UI state machine.
    _speechSession.onResult = _onSpeechResult;
    _speechSession.onStatus = _onSpeechStatus;
    _speechSession.onError = _onSpeechError;

    ref.onDispose(() {
      _logger.info('Provider disposing, cleaning up speech session...');
      _disposed = true;
      _speechSession.disposeService();
    });

    return const ChatInputState(isSpeechAvailable: true);
  }

  void _configureSpeech(SpeechSettings? settings) {
    final newServiceType = settings?.serviceType ?? SpeechServiceType.system;

    // Select (create or swap) the underlying speech service.
    _speechSession.setServiceType(
      type: newServiceType,
      previousType: _speechSession.serviceType,
      websocketHost: settings?.websocketHost,
      websocketPort: settings?.websocketPort,
      websocketPath: settings?.websocketPath,
    );
  }

  /// Update the send-message callback in place. Called from the widget's
  /// `didUpdateWidget` when the parent supplies a new callback, so a reused
  /// State never submits through a stale closure captured at init time.
  void updateOnSendMessage(OnSendMessageCallback onSendMessage) {
    _onSendMessage = onSendMessage;
  }

  void _onSpeechStatus(String status) {
    _logger.info('Speech status: $status');
    final isCurrentlyListening = status == 'listening';

    if (state.isListening && !isCurrentlyListening) {
      _logger.info('Stopped listening.');

      if (state.isLoadingResponse) {
        _logger.info('Sending message, ignoring speech status change');
        return;
      }

      if (_isManualStop) {
        _logger.info(
          'User manually stopped speech recognition, setting to normal state',
        );
        _isManualStop = false;
        state = state.copyWith(isListening: false, hintType: HintType.normal);
        _textBeforeSpeechSession = state.text;
        return;
      }

      // Strip the pre-session base only if it is an actual PREFIX of the
      // recognised text. replaceFirst would delete the first occurrence at any
      // position, so if the pre-session text reappears inside the newly spoken
      // content it would strip the wrong location. Because the speech callbacks
      // fold the recognised text on top of the base, the prefix cut is exact.
      final currentText = state.text;
      final recognizedNewContent =
          currentText.startsWith(_textBeforeSpeechSession)
          ? currentText.substring(_textBeforeSpeechSession.length).trim()
          : currentText.trim();

      if (recognizedNewContent.isEmpty && _textBeforeSpeechSession.isEmpty) {
        _logger.info('Listening ended, no speech recognized.');
        state = state.copyWith(
          isListening: false,
          text: '',
          hintType: HintType.speechNotRecognized,
        );
      } else if (recognizedNewContent.isEmpty &&
          _textBeforeSpeechSession.isNotEmpty) {
        _logger.info('Listening ended, no new content recognized.');
        state = state.copyWith(
          isListening: false,
          text: _textBeforeSpeechSession,
          hintType: HintType.speechNotRecognized,
        );
      } else {
        _logger.info(
          "Listening ended, content recognized. Final text: '${state.text}'",
        );
        state = state.copyWith(isListening: false, hintType: HintType.normal);
        _textBeforeSpeechSession = state.text;
      }

      if (state.hintType == HintType.speechNotRecognized) {
        unawaited(
          Future<void>.delayed(const Duration(seconds: 2), () {
            if (!ref.mounted) return;
            if (state.hintType == HintType.speechNotRecognized &&
                !state.isListening &&
                !state.isLoadingResponse) {
              state = state.copyWith(hintType: HintType.normal);
            }
          }),
        );
      }
    } else if (!state.isListening && isCurrentlyListening) {
      _logger.info('Started listening.');
      state = state.copyWith(isListening: true, hintType: HintType.listening);
    }
  }

  void _onSpeechError(SpeechErrorType errorType) {
    _logger.severe('Speech error: $errorType');

    if (state.isLoadingResponse) {
      _logger.info('Sending message, ignoring speech error: $errorType');
      return;
    }

    if (_isManualStop) {
      _logger.info('Error caused by user manual stop, ignoring: $errorType');
      _isManualStop = false;
      return;
    }

    if (errorType == SpeechErrorType.noSpeechRecognized) {
      _textBeforeSpeechSession = '';
      state = state.copyWith(text: '');
    }

    state = state.copyWith(
      isListening: false,
      showError: true,
      speechErrorType: errorType,
      // The enum name is not user-facing copy; keep it only as a diagnostic
      // hint (the UI maps each type to localized text).
      errorMessage: errorType.name,
      hintType: HintType.normal,
    );
  }

  void _onSpeechResult(String recognizedText) {
    final isIncremental = _speechSession.isIncrementalResult;
    final newText = _textBeforeSpeechSession.trim().isEmpty
        ? recognizedText
        : '${_textBeforeSpeechSession.trim()} $recognizedText'.trim();
    _logger.fine(
      'Speech result (${isIncremental ? 'incremental' : 'final'}): '
      "'$recognizedText', text: '$newText'",
    );
    state = state.copyWith(text: newText.trim());
    if (!isIncremental) {
      _textBeforeSpeechSession = newText.trim();
    }
  }

  Future<void> onMainButtonPressed() async {
    if (state.isLoadingResponse) return;

    if (state.isListening) {
      _isManualStop = true;
      await _speechSession.stopListening(manual: true);
    } else if (state.text.trim().isNotEmpty || state.hasMediaFiles) {
      await _submitMessage();
    } else {
      await _startNewSpeechSession();
    }
  }

  Future<void> _startNewSpeechSession() async {
    _logger.info('Starting new speech recognition session');

    _isManualStop = false;
    unawaited(HapticFeedback.lightImpact());

    try {
      final errorType = await _speechSession.startSession();
      if (_disposed) return;

      if (errorType != null) {
        _logger.warning('Speech service not ready: $errorType');
        if (errorType == SpeechErrorType.noSpeechRecognized) {
          _textBeforeSpeechSession = '';
          state = state.copyWith(text: '');
        }
        state = state.copyWith(
          isListening: false,
          showError: true,
          speechErrorType: errorType,
          errorMessage: errorType.name,
          hintType: HintType.normal,
        );
        return;
      }

      _textBeforeSpeechSession = state.text.trim();
      state = state.copyWith(
        isListening: true,
        showError: false,
        speechErrorType: null,
        errorMessage: '',
        hintType: HintType.listening,
      );
    } catch (e) {
      if (_disposed) return;
      _logger.severe('Failed to start speech recognition session: $e');
      state = state.copyWith(
        isListening: false,
        showError: true,
        speechErrorType: SpeechErrorType.connectionFailed,
        errorMessage: t.speech.connectionFailed,
        hintType: HintType.normal,
      );
    }
  }

  void onTextChanged(String newText) {
    if (state.isListening) {
      _logger.info('User manually input, stopping current speech listening');
      unawaited(_speechSession.stopListening(manual: false));
    }
    _textBeforeSpeechSession = newText;
    state = state.copyWith(text: newText, hintType: HintType.normal);
  }

  Future<void> _submitMessage() async {
    if (_isSubmitting || state.isLoadingResponse) return;
    // Set synchronously, before any await (see the field doc).
    _isSubmitting = true;

    try {
      final textToSend = state.text.trim();
      final hasMediaFiles = state.hasMediaFiles;

      if (textToSend.isEmpty && !hasMediaFiles) return;

      if (state.isListening) {
        await _speechSession.stopListening(manual: false);
        state = state.copyWith(isListening: false, hintType: HintType.normal);
      }

      final currentTextAfterStop = state.text.trim();
      final currentMediaFiles = List<XFile>.from(state.selectedFiles);

      if (currentTextAfterStop.isEmpty && currentMediaFiles.isEmpty) return;

      final pendingAttachments = <PendingMessageAttachment>[];
      if (currentMediaFiles.isNotEmpty) {
        for (final file in currentMediaFiles) {
          final uploadInfo = _uploadedInfos[file.path];
          if (uploadInfo == null) {
            state = state.copyWith(
              showError: true,
              errorMessage: t.chat.uploadStillInProgress,
              hintType: HintType.normal,
            );
            return;
          }
          pendingAttachments.add(
            PendingMessageAttachment(file: file, uploadInfo: uploadInfo),
          );
        }
      }

      state = state.copyWith(
        isLoadingResponse: true,
        hintType: HintType.aiProcessing,
      );

      try {
        await _onSendMessage(
          currentTextAfterStop,
          attachments: pendingAttachments.isEmpty ? null : pendingAttachments,
        );
        if (_disposed) return;

        for (final attachment in pendingAttachments) {
          _uploadedInfos.remove(attachment.file.path);
        }

        _textBeforeSpeechSession = '';
        state = state.copyWith(text: '', selectedFiles: []);
      } catch (e, s) {
        if (_disposed) return;
        _logger.severe('Message send failed: $e\n$s');
        state = state.copyWith(
          isLoadingResponse: false,
          showError: true,
          errorMessage: t.chat.sendFailed,
          hintType: HintType.normal,
        );
      }
    } finally {
      _isSubmitting = false;
    }
  }

  void clearError() {
    if (state.showError) {
      state = state.copyWith(
        showError: false,
        errorMessage: '',
        speechErrorType: null,
      );
    }
  }

  void resetForConversationSwitch() {
    if (state.isListening) {
      unawaited(_speechSession.stopListening(manual: false));
    }
    _textBeforeSpeechSession = '';
    _uploadedInfos.clear();
    state = state.copyWith(
      text: '',
      selectedFiles: [],
      uploadingFiles: {},
      isLoadingResponse: false,
      isListening: false,
      showError: false,
      speechErrorType: null,
      errorMessage: '',
      hintType: HintType.normal,
    );
  }

  void showError(String message) {
    state = state.copyWith(showError: true, errorMessage: message);
  }

  void resetLoadingState() {
    if (state.isLoadingResponse) {
      state = state.copyWith(
        isLoadingResponse: false,
        hintType: HintType.normal,
      );
    }
  }

  void addSelectedFiles(List<XFile> files) {
    final updatedFiles = [...state.selectedFiles, ...files];
    final uploadingMap = Map<String, bool>.from(state.uploadingFiles);
    for (final file in files) {
      uploadingMap[file.path] = true;
    }

    state = state.copyWith(
      selectedFiles: updatedFiles,
      uploadingFiles: uploadingMap,
      showError: false,
      errorMessage: '',
    );
    unawaited(_uploadFilesInBackground(files));
  }

  void removeSelectedFile(int index) {
    if (index < 0 || index >= state.selectedFiles.length) return;

    final fileToRemove = state.selectedFiles[index];
    final updatedFiles = List<XFile>.from(state.selectedFiles)..removeAt(index);
    final uploadingMap = Map<String, bool>.from(state.uploadingFiles);
    uploadingMap.remove(fileToRemove.path);
    _uploadedInfos.remove(fileToRemove.path);

    state = state.copyWith(
      selectedFiles: updatedFiles,
      uploadingFiles: uploadingMap,
    );
  }

  void clearSelectedFiles() {
    if (state.selectedFiles.isNotEmpty) {
      state = state.copyWith(selectedFiles: []);
    }
  }

  void handleUploadCompleted(
    FileUploadResult result,
    List<XFile> originalFiles,
  ) {
    final failedFileNames = result.failures.map((f) => f.fileName).toSet();
    final failedPaths = <String>{};
    final failedNames = <String>[];

    for (final file in originalFiles) {
      if (failedFileNames.contains(file.name)) {
        failedPaths.add(file.path);
        failedNames.add(file.name);
      }
    }

    final uploadingMap = Map<String, bool>.from(state.uploadingFiles);

    if (failedPaths.isNotEmpty) {
      final updatedFiles = state.selectedFiles
          .where((file) => !failedPaths.contains(file.path))
          .toList();
      for (final path in failedPaths) {
        _uploadedInfos.remove(path);
        uploadingMap.remove(path);
      }
      state = state.copyWith(
        selectedFiles: updatedFiles,
        uploadingFiles: uploadingMap,
        showError: true,
        errorMessage: t.chat.attachmentUploadFailed(
          files: failedNames.join(', '),
        ),
      );
    }

    // CHAT-8: the server returns uploads in the SAME ORDER the files were
    // sent (the service uploads sequentially), so align by index. Matching by
    // `originalName` misattributes results when two selected files share a
    // name — the wrong attachmentId/uri would be attached to the wrong file.
    // Failed files are excluded from the zip by the filter above.
    final uploadableFiles = originalFiles
        .where((file) => !failedPaths.contains(file.path))
        .toList();
    final uploadCount = result.uploads.length < uploadableFiles.length
        ? result.uploads.length
        : uploadableFiles.length;
    for (var i = 0; i < uploadCount; i++) {
      final file = uploadableFiles[i];
      final upload = result.uploads[i];
      _uploadedInfos[file.path] = UploadedAttachmentInfo(
        id: upload.id,
        attachmentId: upload.attachmentId,
        originalName: upload.originalName,
        objectKey: upload.objectKey,
        uri: upload.uri,
        mimeType: upload.mimeType,
        size: upload.size,
        hash: upload.hash,
      );
      uploadingMap[file.path] = false;
    }

    state = state.copyWith(uploadingFiles: uploadingMap);
  }

  Future<void> _uploadFilesInBackground(List<XFile> files) async {
    try {
      final service = _fileUploadService;
      if (service == null) {
        throw StateError('File upload service is not initialized');
      }
      final uploadResult = await service.uploadFiles(files);
      if (_disposed) return;
      handleUploadCompleted(uploadResult, files);
    } catch (e, stackTrace) {
      if (_disposed) return;
      _logger.severe('Background upload exception: $e\n$stackTrace');
      final uploadingMap = Map<String, bool>.from(state.uploadingFiles);
      for (final file in files) {
        uploadingMap.remove(file.path);
      }
      state = state.copyWith(
        uploadingFiles: uploadingMap,
        showError: true,
        errorMessage: t.chat.fileUploadFailed,
      );
    }
  }
}
