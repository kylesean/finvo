import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/chat/services/speech_session_manager.dart';
import 'package:finvo/features/chat/services/file_upload_service.dart';
import 'package:finvo/features/chat/models/message_attachments.dart';
import 'package:finvo/features/profile/providers/speech_settings_provider.dart';
import 'package:finvo/features/chat/providers/chat_input_state.dart';

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
  final SpeechSessionManager _speechSession = SpeechSessionManager();
  FileUploadService? _fileUploadService;

  final Map<String, UploadedAttachmentInfo> _uploadedInfos = {};

  String _textBeforeSpeechSession = '';
  bool _isManualStop = false;

  @override
  ChatInputState build(OnSendMessageCallback onSendMessage) {
    // Service initialization
    _fileUploadService = ref.watch(fileUploadServiceProvider);

    final settings = ref.watch(speechSettingsProvider).settings;
    final newServiceType = settings?.serviceType ?? SpeechServiceType.system;

    // Select (create or swap) the underlying speech service.
    _speechSession.setServiceType(
      type: newServiceType,
      previousType: _speechSession.serviceType,
      websocketHost: settings?.websocketHost,
      websocketPort: settings?.websocketPort,
      websocketPath: settings?.websocketPath,
    );

    // Wire the speech manager callbacks to the UI state machine.
    _speechSession.onResult = _onSpeechResult;
    _speechSession.onStatus = _onSpeechStatus;
    _speechSession.onError = _onSpeechError;

    ref.onDispose(() {
      _logger.info('Provider disposing, cleaning up speech session...');
      _speechSession.disposeService();
    });

    return const ChatInputState(isSpeechAvailable: true);
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

  void _onSpeechError(String errorToken) {
    _logger.severe('Speech error: $errorToken');

    if (state.isLoadingResponse) {
      _logger.info('Sending message, ignoring speech error: $errorToken');
      return;
    }

    if (_isManualStop) {
      _logger.info('Error caused by user manual stop, ignoring: $errorToken');
      _isManualStop = false;
      return;
    }

    // The token is already classified by SpeechSessionManager; only the
    // no-speech case additionally clears the draft text.
    if (errorToken == 'no_speech_recognized') {
      _textBeforeSpeechSession = '';
      state = state.copyWith(text: '');
    }

    state = state.copyWith(
      isListening: false,
      showError: true,
      errorMessage: errorToken,
      hintType: HintType.normal,
    );
  }

  void _onSpeechResult(String recognizedText) {
    if (_speechSession.isIncrementalResult) {
      // Incremental (WebSocket) mode: every partial already contains the full
      // utterance recognized so far, so REPLACE the recognized part on top of
      // the fixed pre-session base. Folding each partial back into the base
      // would duplicate the accumulated text.
      final newText = _textBeforeSpeechSession.trim().isEmpty
          ? recognizedText
          : '${_textBeforeSpeechSession.trim()} $recognizedText'.trim();
      _logger.fine(
        "Speech result (incremental): '$recognizedText', text: '$newText'",
      );
      state = state.copyWith(text: newText.trim());
    } else {
      // Discrete-finals mode (system speech): each final result is a separate
      // utterance (pause-then-continue), so append to the accumulated text.
      final newText = _textBeforeSpeechSession.trim().isEmpty
          ? recognizedText
          : '${_textBeforeSpeechSession.trim()} $recognizedText'.trim();
      _logger.fine(
        "Speech result (final): '$recognizedText', concatenated text: '$newText'",
      );
      state = state.copyWith(text: newText.trim());
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

    // Play haptic feedback immediately to give the user instant feedback.
    unawaited(HapticFeedback.lightImpact());

    try {
      final errorToken = await _speechSession.startSession();

      if (errorToken != null) {
        _logger.warning('Speech service not ready: $errorToken');
        if (errorToken == 'no_speech_recognized') {
          _textBeforeSpeechSession = '';
          state = state.copyWith(text: '');
        }
        state = state.copyWith(
          isListening: false,
          showError: true,
          errorMessage: errorToken,
          hintType: HintType.normal,
        );
        return;
      }

      _textBeforeSpeechSession = state.text.trim();
      state = state.copyWith(
        isListening: true,
        showError: false,
        errorMessage: '',
        hintType: HintType.listening,
      );
    } catch (e) {
      _logger.severe('Failed to start speech recognition session: $e');
      state = state.copyWith(
        isListening: false,
        showError: true,
        errorMessage: 'speech_connection_failed',
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
    if (state.isLoadingResponse) return;

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
            errorMessage: 'Attachment still uploading, please try again later',
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
      await onSendMessage(
        currentTextAfterStop,
        attachments: pendingAttachments.isEmpty ? null : pendingAttachments,
      );

      for (final attachment in pendingAttachments) {
        _uploadedInfos.remove(attachment.file.path);
      }

      _textBeforeSpeechSession = '';
      state = state.copyWith(
        text: '',
        selectedFiles: [],
        isLoadingResponse: false,
        hintType: HintType.normal,
      );
    } catch (e, s) {
      _logger.severe('Message send failed: $e\n$s');
      state = state.copyWith(
        isLoadingResponse: false,
        showError: true,
        errorMessage: 'Send failed, please try again later',
        hintType: HintType.normal,
      );
    }
  }

  void clearError() {
    if (state.showError) {
      state = state.copyWith(showError: false, errorMessage: '');
    }
  }

  /// Reset input text and media for a conversation switch, so a previous
  /// conversation's draft doesn't leak into the newly opened one.
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
      errorMessage: '',
      hintType: HintType.normal,
    );
  }

  void showError(String message) {
    state = state.copyWith(showError: true, errorMessage: message);
  }

  /// Reset loading state - called by ChatHistory when AI response stream ends
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
        errorMessage: 'Attachment upload failed: ${failedNames.join(', ')}',
      );
    }

    // Pair server upload results back to the local files. The old
    // `firstWhere((f) => f.name == upload.originalName)` threw a StateError
    // (aborting the whole batch as failed) whenever the server-returned name
    // differed from the local name, and mapped duplicate file names onto the
    // same file. Instead: prefer an exact name match, consume each file at
    // most once, and fall back to the next unmatched file in request order
    // (the server response order mirrors the request order).
    final usedIndices = <int>{};
    for (final upload in result.uploads) {
      int fileIndex = -1;
      for (var i = 0; i < originalFiles.length; i++) {
        if (usedIndices.contains(i)) continue;
        if (originalFiles[i].name == upload.originalName) {
          fileIndex = i;
          break;
        }
      }
      if (fileIndex == -1) {
        for (var i = 0; i < originalFiles.length; i++) {
          if (usedIndices.contains(i)) continue;
          fileIndex = i;
          break;
        }
      }
      if (fileIndex == -1) break; // no files left to pair

      usedIndices.add(fileIndex);
      final file = originalFiles[fileIndex];
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
      final uploadResult = await _fileUploadService!.uploadFiles(files);
      handleUploadCompleted(uploadResult, files);
    } catch (e, stackTrace) {
      _logger.severe('Background upload exception: $e\n$stackTrace');
      final uploadingMap = Map<String, bool>.from(state.uploadingFiles);
      for (final file in files) {
        uploadingMap.remove(file.path);
      }
      state = state.copyWith(
        uploadingFiles: uploadingMap,
        showError: true,
        errorMessage: 'File upload failed: $e',
      );
    }
  }
}
