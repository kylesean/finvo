import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/features/chat/models/speech_error_type.dart';

part 'chat_input_state.freezed.dart';

@freezed
abstract class ChatInputState with _$ChatInputState {
  const factory ChatInputState({
    @Default('') String text, // Current text in the input box
    @Default(false)
    bool isListening, // Whether speech recognition is in progress
    @Default(false)
    bool isSpeechAvailable, // Whether speech recognition service is available
    @Default(false) bool isLoadingResponse, // Whether waiting for AI response
    @Default(false) bool showError, // Whether to show error prompt
    @Default('') String errorMessage, // Legacy error message string fallback
    SpeechErrorType? speechErrorType, // Strongly-typed speech error
    @Default(HintType.normal)
    HintType hintType, // Used to control input box hint text type
    @Default([]) List<XFile> selectedFiles, // List of selected files
    @Default({})
    Map<String, bool>
    uploadingFiles, // Mapping of files being uploaded (path -> isUploading)
  }) = _ChatInputState;
}

// New enum for more precise control of input box hint text
/// Stable per-file upload key shared by the input notifier and the media
/// preview widget.
///
/// On native platforms [XFile.path] is a unique filesystem path and makes a
/// perfect map key. On web, `XFile.fromData` (the picker's byte fallback)
/// leaves `path` empty for EVERY file, so path alone would collapse all
/// selected files into one bucket (CHAT-02). For pathless files, fall back to
/// an identity-derived key that stays stable for the file's whole lifetime.
///
/// The tiny registration store is deliberately global: both the provider and
/// the preview widget must resolve the *same* key for the *same* XFile
/// instance, and the instance themselves are kept alive by `selectedFiles`.
/// An [Expando] (not a plain Map keyed by identityHashCode) keeps this leak-
/// free: entries are garbage-collected with their XFile, so the store never
/// grows across a long session, and two live files can never collide on the
/// same hash.
String fileUploadKey(XFile file) {
  if (file.path.isNotEmpty) return file.path;
  return _pathlessUploadKeys[file] ??= 'web-file#${_pathlessUploadSeq++}';
}

final Expando<String> _pathlessUploadKeys = Expando<String>();
int _pathlessUploadSeq = 0;

enum HintType {
  normal, // "Input message..."
  listening, // "Listening..."
  aiProcessing, // "AI thinking..."
  speechNotRecognized, // "Speech not recognized, please try again" (brief prompt)
}
