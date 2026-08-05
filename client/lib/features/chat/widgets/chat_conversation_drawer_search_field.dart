import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/chat/providers/conversation_search_provider.dart';
import 'package:finvo/features/chat/providers/conversation_search_state.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Custom search text field component
class SearchTextField extends StatefulWidget {
  final ConversationSearchState searchState;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchTextField({
    super.key,
    required this.searchState,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchState.query);
    _focusNode = FocusNode();

    // Listen for focus changes
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // When search box gains focus, trigger fullscreen search mode
      // Use WidgetsBinding to ensure execution in next frame, avoiding state modification during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          final ref = ProviderScope.containerOf(
            context,
          ).read(conversationSearchProvider.notifier);
          ref.enterFullscreenSearchMode();
        }
      });
    }
  }

  @override
  void didUpdateWidget(SearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync provider's query when not focused, to prevent overwriting input and cursor during rebuild
    if (!_focusNode.hasFocus && widget.searchState.query != _controller.text) {
      _controller.text = widget.searchState.query;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              FLucideIcons.search,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ),
          // Input field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              style: theme.typography.body.sm,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: t.common.search,
                hintStyle: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          // Clear button
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  FLucideIcons.x,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fullscreen search text field component
class FullscreenSearchTextField extends ConsumerStatefulWidget {
  const FullscreenSearchTextField({super.key});

  @override
  ConsumerState<FullscreenSearchTextField> createState() =>
      _FullscreenSearchTextFieldState();
}

class _FullscreenSearchTextFieldState
    extends ConsumerState<FullscreenSearchTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final searchState = ref.read(conversationSearchProvider);
    _controller = TextEditingController(text: searchState.query);
    _focusNode = FocusNode();

    // Auto-focus search box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(FullscreenSearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Don't force sync controller in fullscreen input mode, to avoid cursor jumping when rebuild is triggered by query return
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final query = ref.watch(conversationSearchProvider.select((s) => s.query));

    // Only sync external query to controller when not focused, to prevent misalignment from query return write-back
    if (!_focusNode.hasFocus && query != _controller.text) {
      _controller.text = query;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            style: theme.typography.body.sm,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: t.common.search,
              hintStyle: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              // Only push changes to provider, don't write back to controller, to avoid circular overwrites
              ref.read(conversationSearchProvider.notifier).updateQuery(value);
            },
          ),
        ),
        // Clear button
        if (_controller.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              // Clear controller and provider, maintain focus
              _controller.clear();
              ref.read(conversationSearchProvider.notifier).clearSearch();
              _focusNode.requestFocus();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colors.mutedForeground.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FLucideIcons.x,
                size: 10,
                color: theme.colors.background,
              ),
            ),
          ),
      ],
    );
  }
}
