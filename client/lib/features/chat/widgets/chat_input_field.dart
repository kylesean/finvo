// features/chat/widgets/chat_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/chat/models/speech_error_type.dart';
import 'package:finvo/features/chat/providers/chat_input_provider.dart';
import 'package:finvo/features/chat/providers/chat_input_state.dart';
import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/features/chat/models/message_attachments.dart';
import 'package:finvo/features/chat/widgets/media_upload_button.dart';
import 'package:finvo/features/chat/widgets/media_preview_widget.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'dart:async';

class ChatInputField extends ConsumerStatefulWidget {
  final Future<void> Function(
    String, {
    List<PendingMessageAttachment>? attachments,
  })
  onSendMessage;

  const ChatInputField({super.key, required this.onSendMessage});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  late final provider = chatInputProvider(widget.onSendMessage);

  // Breathing animation controller
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize breathing animation controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Breathing effect: scale from 0.85 to 1.15, use easeInOut curve to simulate heartbeat/breathing
    _breathingAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _textController = TextEditingController();

    // Start/stop the breathing animation whenever the waiting state changes.
    // The animation is driven purely by listeners (never from build) so build
    // stays side-effect free.
    ref.listenManual(chatHistoryProvider.select((s) => s.isStreamingResponse), (
      previous,
      current,
    ) {
      _syncBreathingAnimation();
      if (previous == true && current == false && mounted) {
        ref.read(provider.notifier).resetLoadingState();
      }
    });
    ref.listenManual(
      provider.select((s) => s.isListening),
      (_, _) => _syncBreathingAnimation(),
    );
    _syncBreathingAnimation();

    // When the active conversation changes, reset draft text/media so a
    // previous conversation's input doesn't leak into the newly opened one.
    ref.listenManual(
      chatHistoryProvider.select((s) => s.currentConversationId),
      (previous, current) {
        if (previous != current) {
          ref.read(provider.notifier).resetForConversationSwitch();
        }
      },
    );

    ref.listenManual(provider.select((s) => s.text), (
      previousText,
      currentText,
    ) {
      if (!mounted) return;
      if (_textController.text != currentText) {
        final currentSelection = _textController.selection;
        _textController.text = currentText;
        try {
          if (currentSelection.baseOffset <= currentText.length &&
              currentSelection.extentOffset <= currentText.length) {
            _textController.selection = currentSelection;
          } else {
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: currentText.length),
            );
          }
        } catch (e) {
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: currentText.length),
          );
        }
      }
    }, fireImmediately: true);

    ref.listenManual(provider, (
      ChatInputState? previousState,
      ChatInputState currentState,
    ) {
      if (!mounted) return;
      final bool wasShowingError = previousState?.showError ?? false;
      final bool isShowingError = currentState.showError;
      if (isShowingError && !wasShowingError) {
        final errorType = currentState.speechErrorType;
        if (errorType != null) {
          _handleSpeechError(errorType, currentState.errorMessage);
        } else if (currentState.errorMessage.isNotEmpty) {
          _showSnackBarError(currentState.errorMessage);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(provider.notifier).clearError();
          }
        });
      }
    });
  }

  void _handleSpeechError(SpeechErrorType errorType, String rawMessage) {
    switch (errorType) {
      case SpeechErrorType.systemRestricted:
      case SpeechErrorType.dictationDisabled:
      case SpeechErrorType.permissionDenied:
      case SpeechErrorType.notConfigured:
      case SpeechErrorType.connectionFailed:
        _showSpeechErrorDialog(errorType);
        break;
      case SpeechErrorType.noSpeechRecognized:
        _showSnackBarError(t.speech.noSpeechRecognized);
        break;
      case SpeechErrorType.unknown:
        _showSnackBarError(rawMessage.isEmpty ? t.common.error : rawMessage);
        break;
    }
  }

  void _showSpeechErrorDialog(SpeechErrorType errorType) {
    final (dialogTitle, dialogContent) = switch (errorType) {
      SpeechErrorType.systemRestricted => (
        t.speech.systemVoiceRestrictedTitle,
        t.speech.systemVoiceRestrictedContent,
      ),
      SpeechErrorType.dictationDisabled => (
        t.speech.dictationDisabledTitle,
        t.speech.dictationDisabledContent,
      ),
      SpeechErrorType.permissionDenied => (
        t.speech.permissionDeniedTitle,
        t.speech.permissionDeniedContent,
      ),
      SpeechErrorType.notConfigured => (
        t.speech.connectionFailedTitle,
        t.speech.serviceNotConfigured,
      ),
      SpeechErrorType.connectionFailed => (
        t.speech.connectionFailedTitle,
        t.speech.connectionFailed,
      ),
      _ => (t.speech.connectionFailedTitle, t.speech.connectionFailed),
    };

    unawaited(
      showFDialog<void>(
        context: context,
        builder: (dialogContext, style, animation) => FDialog(
          animation: animation,
          builder: (context, dialogStyle) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(dialogTitle, style: dialogStyle.titleTextStyle),
                const SizedBox(height: 12),
                Text(dialogContent, style: dialogStyle.bodyTextStyle),
                const SizedBox(height: 24),
                FButton(
                  variant: .primary,
                  onPress: () {
                    Navigator.of(dialogContext).pop();
                    unawaited(context.pushNamed(AppRouteNames.speechSettings));
                  },
                  child: Text(t.speech.goToSettings),
                ),
                const SizedBox(height: 8),
                FButton(
                  variant: .outline,
                  onPress: () => Navigator.of(dialogContext).pop(),
                  child: Text(t.common.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBarError(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: t.common.ok,
          onPressed: () => ref.read(provider.notifier).clearError(),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.onSendMessage, widget.onSendMessage)) {
      ref.read(provider.notifier).updateOnSendMessage(widget.onSendMessage);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Sync breathing animation with the current waiting state
  void _syncBreathingAnimation() {
    if (!mounted) return;
    final isWaitingState =
        ref.read(chatHistoryProvider).isStreamingResponse ||
        ref.read(provider).isListening;
    if (isWaitingState) {
      if (!_breathingController.isAnimating) {
        unawaited(_breathingController.repeat(reverse: true));
      }
    } else {
      if (_breathingController.isAnimating) {
        _breathingController.stop();
        _breathingController.reset();
      }
    }
  }

  String _getHintText(
    HintType hintType,
    bool isListening, {
    bool isStreamingResponse = false,
  }) {
    if (isStreamingResponse) {
      return t.chat.aiThinking;
    }
    if (isListening) {
      return t.chat.listening;
    }
    switch (hintType) {
      case HintType.normal:
        return t.chat.inputMessage;
      case HintType.listening:
        return t.chat.listening;
      case HintType.aiProcessing:
        return t.chat.aiThinking;
      case HintType.speechNotRecognized:
        return t.chat.speechNotRecognized;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final chatInputState = ref.watch(provider);
    final chatInputNotifier = ref.read(provider.notifier);

    final isStreamingResponse = ref.watch(
      chatHistoryProvider.select((state) => state.isStreamingResponse),
    );
    final chatHistoryNotifier = ref.read(chatHistoryProvider.notifier);

    IconData currentIcon;
    Color buttonBackgroundColor;
    Color iconColor;
    VoidCallback? currentAction = chatInputNotifier.onMainButtonPressed;

    final canInteractWithTextField =
        !chatInputState.isListening && !isStreamingResponse;
    final canUseAddButton = !chatInputState.isListening && !isStreamingResponse;

    final isWaitingState = isStreamingResponse || chatInputState.isListening;

    final theme = context.theme;

    if (isStreamingResponse) {
      currentIcon = Icons.square_rounded;
      buttonBackgroundColor = theme.colors.primary;
      iconColor = theme.colors.primaryForeground;
      currentAction = () => chatHistoryNotifier.cancelPendingOperation();
    } else if (chatInputState.isListening) {
      currentIcon = Icons.square_rounded;
      buttonBackgroundColor = theme.colors.primary;
      iconColor = theme.colors.primaryForeground;
    } else if (chatInputState.text.trim().isNotEmpty) {
      currentIcon = Icons.arrow_upward;
      buttonBackgroundColor = theme.colors.primary;
      iconColor = theme.colors.primaryForeground;
    } else {
      currentIcon = chatInputState.isSpeechAvailable
          ? Icons.mic_none_outlined
          : Icons.mic_off_outlined;
      buttonBackgroundColor = theme.colors.muted;
      iconColor = chatInputState.isSpeechAvailable
          ? theme.colors.foreground
          : theme.colors.mutedForeground;
    }

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
          top: 8.0,
          bottom: 12.0,
        ),
        color: theme.colors.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MediaPreviewWidget(
              selectedFiles: chatInputState.selectedFiles,
              uploadingFiles: chatInputState.uploadingFiles,
              onRemove: (index) => chatInputNotifier.removeSelectedFile(index),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 52.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: theme.colors.border, width: 1.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MediaUploadButton(
                    enabled: canUseAddButton,
                    chatInputProvider: provider,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: canInteractWithTextField,
                      onChanged: chatInputNotifier.onTextChanged,
                      decoration: InputDecoration(
                        hintText: _getHintText(
                          chatInputState.hintType,
                          chatInputState.isListening,
                          isStreamingResponse: isStreamingResponse,
                        ),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (chatInputState.text.trim().isNotEmpty &&
                            canInteractWithTextField) {
                          unawaited(chatInputNotifier.onMainButtonPressed());
                        }
                      },
                      minLines: 1,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: currentAction,
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: buttonBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                        child: AnimatedBuilder(
                          animation: _breathingAnimation,
                          builder: (context, child) {
                            final scale = isWaitingState
                                ? _breathingAnimation.value
                                : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: Icon(
                                currentIcon,
                                key: ValueKey<IconData>(currentIcon),
                                color: iconColor,
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
