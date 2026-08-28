// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_input_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatInputNotifier)
final chatInputProvider = ChatInputNotifierProvider._();

final class ChatInputNotifierProvider
    extends $NotifierProvider<ChatInputNotifier, ChatInputState> {
  ChatInputNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatInputProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatInputNotifierHash();

  @$internal
  @override
  ChatInputNotifier create() => ChatInputNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatInputState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatInputState>(value),
    );
  }
}

String _$chatInputNotifierHash() => r'fb1c2d8cd3d06e401d63c828f41ade52f9170540';

abstract class _$ChatInputNotifier extends $Notifier<ChatInputState> {
  ChatInputState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatInputState, ChatInputState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatInputState, ChatInputState>,
              ChatInputState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
