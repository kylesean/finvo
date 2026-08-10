import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A widget that renders text with a smooth typing typewriter animation
/// when text arrives or updates incrementally via A2UI stream.
class StreamingTypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDuration;
  final bool showCursor;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const StreamingTypingText({
    super.key,
    required this.text,
    this.style,
    this.charDuration = const Duration(milliseconds: 25),
    this.showCursor = true,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  @override
  State<StreamingTypingText> createState() => _StreamingTypingTextState();
}

class _StreamingTypingTextState extends State<StreamingTypingText> {
  int _displayedLength = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startOrUpdateTyping();
  }

  @override
  void didUpdateWidget(covariant StreamingTypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startOrUpdateTyping();
    }
  }

  void _startOrUpdateTyping() {
    _timer?.cancel();
    if (widget.text.isEmpty) {
      setState(() {
        _displayedLength = 0;
      });
      return;
    }

    // Keep already typed characters if text is extended
    if (_displayedLength > widget.text.length) {
      _displayedLength = widget.text.length;
    }

    _timer = Timer.periodic(widget.charDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_displayedLength < widget.text.length) {
        setState(() {
          _displayedLength++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentText = widget.text.substring(0, _displayedLength);
    final isTyping = _displayedLength < widget.text.length;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: currentText, style: widget.style),
          if (widget.showCursor && isTyping)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _BlinkingCursor(style: widget.style),
            ),
        ],
      ),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final TextStyle? style;

  const _BlinkingCursor({this.style});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    unawaited(_controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        '▌',
        style: (widget.style ?? const TextStyle()).copyWith(
          color: (widget.style?.color ?? context.theme.colors.primary)
              .withValues(alpha: 0.8),
          fontSize: widget.style?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
