import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart' as genui;
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:finvo/features/chat/models/chat_message.dart' as app;
import 'package:finvo/features/chat/genui/components/historical_component_renderer.dart';
import 'package:finvo/features/chat/genui/utils/genui_error_boundary.dart';
import 'package:shimmer/shimmer.dart';
import 'package:finvo/features/chat/widgets/authenticated_image.dart';
import 'package:finvo/features/chat/widgets/tool_execution_block.dart';
import 'package:finvo/features/chat/models/tool_call_info.dart';
import 'package:finvo/features/chat/models/message_content_part.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/i18n/strings.g.dart';

final _logger = Logger('ChatMessageWidget');

/// Chat message widget that renders both text content and GenUI surfaces
///
/// This widget integrates GenUI's dynamic UI generation with traditional
/// text-based chat messages. It handles:
/// - Text content rendering using Markdown
/// - GenUI surface rendering for dynamic UI components
/// - Surface event handling
/// - Loading and error states
///
/// Requirements: 10.1, 10.3
class ChatMessageWidget extends ConsumerStatefulWidget {
  final app.ChatMessage message;
  final genui.SurfaceHost genUiHost;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.genUiHost,
  });

  @override
  ConsumerState<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends ConsumerState<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // --- Item-level memo (M-5) ---
  // Cache the built content subtree keyed by widget identity. When the message
  // does not change (identical or value-equal via freezed), we skip re-building
  // the whole content on the next frame. This avoids re-running rebuild (and
  // re-parsing Markdown) for every surrounding message on each streamed chunk;
  // only the actively-streaming message changes.
  Widget? _cachedContent;
  FThemeData? _cachedTheme;
  bool _reuseCache = false;

  // Cache GenUI UIComponent subtrees to prevent rebuilds during text streaming.
  final Map<String, _GenUiCacheEntry> _genUiCache = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Only animate while the streaming indicator is actually shown, so
    // historical/static messages don't keep a ticker running forever.
    if (_shouldShowStreamingIndicator()) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void didUpdateWidget(ChatMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldAnimate = _shouldShowStreamingIndicator();
    if (shouldAnimate && !_controller.isAnimating) {
      unawaited(_controller.repeat());
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }

    // Item-level memo: reuse the cached content when the message is unchanged.
    // `identical` covers the common case (the repository returns the same
    // ChatMessage instance for untouched messages); `==` covers recreated-but-
    // equal instances (freezed value equality).
    final unchanged =
        identical(oldWidget.message, widget.message) ||
        oldWidget.message == widget.message;
    _reuseCache = unchanged && oldWidget.genUiHost == widget.genUiHost;
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Item-level memo (M-5): reuse the cached content subtree when the message
    // is unchanged and the theme is the same, so that only the streaming
    // message rebuilds on each chunk.
    if (_reuseCache &&
        _cachedContent != null &&
        identical(_cachedTheme, theme)) {
      return _cachedContent!;
    }

    final content = _buildContent(context, theme);
    _cachedContent = content;
    _cachedTheme = theme;
    // After building, the cache is reusable on the next frame unless a new
    // message arrives (didUpdateWidget resets [_reuseCache]).
    _reuseCache = true;
    return content;
  }

  /// Build the full message content subtree (text, tool calls, GenUI, …).
  Widget _buildContent(BuildContext context, FThemeData theme) {
    // Access message from widget.message
    final message = widget.message;

    // Log surface/UI component rendering details
    if (message.surfaceIds.isNotEmpty || message.uiComponents.isNotEmpty) {
      _logger.fine(
        'ChatMessageWidget: Rendering message ${message.id} - surfaceIds: ${message.surfaceIds.length}, uiComponents: ${message.uiComponents.length}',
      );
    }

    // Log user message attachment count
    if (message.sender == app.MessageSender.user) {
      _logger.info(
        'ChatMessageWidget: User message ${message.id} has ${message.attachments.length} attachments',
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render all content parts (Text, ToolCall, GenUI UIComponent) in true chronological stream order:
          // Text -> ToolCall -> GenUI Component -> Text -> GenUI Component
          ...message.fullContent.map(
            (part) => _buildContentPart(context, theme, part),
          ),

          // If no tools are running and message is typing, show streaming indicator at the end
          if (_shouldShowStreamingIndicator())
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: _buildStreamingIndicator(context, theme),
            ),

          // 4. User message attachments
          if (message.attachments.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            _buildAttachments(context, theme, message),
          ],
        ],
      ),
    );
  }

  /// Build specific content part based on its type
  Widget _buildContentPart(
    BuildContext context,
    FThemeData theme,
    MessageContentPart part,
  ) {
    return part.when(
      text: (text) => RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildTextContentFromPart(context, theme, text),
        ),
      ),
      toolCall: (toolCall) => ToolExecutionBlock(
        key: ValueKey('tool_${toolCall.id}'),
        toolCall: toolCall,
      ),
      uiComponent: (component) =>
          _buildGenUiComponentMemoized(context, theme, component),
    );
  }

  /// Build or return cached GenUI component subtree to avoid rebuilding
  /// unchanged GenUI surfaces on every text streaming chunk.
  Widget _buildGenUiComponentMemoized(
    BuildContext context,
    FThemeData theme,
    UIComponentInfo component,
  ) {
    final cacheKey = '${component.mode.name}_${component.surfaceId}';
    final existing = _genUiCache[cacheKey];

    if (existing != null &&
        existing.mode == component.mode &&
        identical(existing.theme, theme) &&
        mapEquals(existing.data, component.data)) {
      return existing.widget;
    }

    final Widget builtWidget;
    if (component.mode == UIComponentMode.live) {
      // Live Real-time Surface (Streaming with instant Shimmer Skeleton)
      builtWidget = RepaintBoundary(
        child: Container(
          key: ValueKey('live_${component.surfaceId}'),
          margin: const EdgeInsets.only(top: 4.0, bottom: 12.0),
          child: GenUiErrorBoundary(
            componentName: 'LiveSurface_${component.surfaceId}',
            data: component.data,
            child: _buildLiveSurfaceWithSkeleton(
              context,
              theme,
              component.surfaceId,
            ),
          ),
        ),
      );
    } else {
      // Historical Static Surface
      builtWidget = Container(
        key: ValueKey('historical_${component.surfaceId}'),
        margin: const EdgeInsets.only(top: 4.0, bottom: 12.0),
        child: GenUiErrorBoundary(
          componentName: component.componentType,
          data: component.data,
          child: HistoricalComponentRenderer(
            componentType: component.componentType,
            data: component.data,
          ),
        ),
      );
    }

    _genUiCache[cacheKey] = _GenUiCacheEntry(
      mode: component.mode,
      theme: theme,
      data: component.data,
      widget: builtWidget,
    );

    return builtWidget;
  }

  /// Process message content to handle UserActionEvent JSON
  String _processContent(String content) {
    if (content.trim().startsWith('{')) {
      try {
        final json = jsonDecode(content);
        if (json is Map<String, dynamic> && json.containsKey('userAction')) {
          final eventData = json['userAction'] as Map<String, dynamic>;
          final eventName = eventData['name'] as String?;
          final context = eventData['context'] as Map<String, dynamic>?;

          if (eventName == 'transfer_path_confirmed' && context != null) {
            final sourceName = context['source_account_name'] ?? 'Unknown';
            final targetName = context['target_account_name'] ?? 'Unknown';
            final sourceId = context['source_account_id'] ?? '';
            final targetId = context['target_account_id'] ?? '';
            final amount = context['amount'];
            final currency = context['currency'] ?? 'CNY';

            final sourceDisplay = (sourceId as String).isNotEmpty
                ? '$sourceName ($sourceId)'
                : sourceName as String;
            final targetDisplay = (targetId as String).isNotEmpty
                ? '$targetName ($targetId)'
                : targetName as String;

            return 'Confirmed transfer path: from $sourceDisplay to $targetDisplay, amount $currency $amount. Please execute this transfer operation.';
          }
        }
      } catch (e) {
        // Ignore JSON parse errors, treat as normal text
      }
    }
    return content;
  }

  /// Build text content from a part
  Widget _buildTextContentFromPart(
    BuildContext context,
    FThemeData theme,
    String text,
  ) {
    if (text.isEmpty) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: _ThrottledMarkdown(
        text: _processContent(text),
        theme: theme,
        gptThemeData: _gptThemeData(theme),
        isStreaming: _isStreaming(),
      ),
    );
  }

  /// Whether the current message is actively streaming text. While streaming,
  /// Markdown re-parsing is throttled (see [_ThrottledMarkdown]) so the hot
  /// path stays O(n) instead of O(n^2) over the streamed chunks.
  bool _isStreaming() {
    return widget.message.isTyping &&
        (widget.message.streamingStatus == app.StreamingStatus.connecting ||
            widget.message.streamingStatus == app.StreamingStatus.streaming);
  }

  /// Build attachments (images) for user messages
  Widget _buildAttachments(
    BuildContext context,
    FThemeData theme,
    app.ChatMessage message,
  ) {
    if (kDebugMode) {
      _logger.fine(
        'Building attachments for message ${message.id}: ${message.attachments.length} attachments',
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: message.attachments.map((attachment) {
        final url = attachment.signedUrl;
        if (url == null || url.isEmpty) {
          _logger.warning(
            'Attachment ${attachment.id} has no signedUrl, skipping',
          );
          return const SizedBox.shrink();
        }

        Widget imageWidget;
        if (url.startsWith('data:')) {
          // Base64 data URI - decode and render directly
          final base64Data = url.split(',').last;
          imageWidget = Image.memory(
            base64Decode(base64Data),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageError(theme, attachment.filename);
            },
          );
        } else {
          // Network URL - use AuthenticatedImage component (with auth header)
          // Extract attachment ID from URL (e.g., /api/v1/files/view/{id})
          final attachmentId = attachment.id;
          imageWidget = AuthenticatedImage(
            attachmentId: attachmentId,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageError(theme, attachment.filename);
            },
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colors.muted, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageWidget,
          ),
        );
      }).toList(),
    );
  }

  /// Build error placeholder for image loading failures
  Widget _buildImageError(FThemeData theme, String filename) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: theme.colors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FLucideIcons.image,
            color: theme.colors.primaryForeground,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            filename,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build streaming indicator with shimmer effect
  Widget _buildStreamingIndicator(BuildContext context, FThemeData theme) {
    final colors = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon - consistent with ToolExecutionBlock
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Icon(
                  FLucideIcons.loader,
                  size: 14,
                  color: colors.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Shimmer text - consistent with ToolExecutionBlock
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final shimmerPosition = _controller.value * 3 - 1.0;

              return ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colors.mutedForeground,
                      colors.primary,
                      colors.mutedForeground,
                    ],
                    stops: [
                      (shimmerPosition - 0.3).clamp(0.0, 1.0),
                      shimmerPosition.clamp(0.0, 1.0),
                      (shimmerPosition + 0.3).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  Translations.of(context).chat.aiThinking,
                  style: theme.typography.body.sm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Check if streaming indicator should be shown
  bool _shouldShowStreamingIndicator() {
    return widget.message.isTyping &&
        (widget.message.streamingStatus == app.StreamingStatus.connecting ||
            widget.message.streamingStatus == app.StreamingStatus.streaming);
  }

  /// Get Markdown theme configuration
  GptMarkdownThemeData _gptThemeData(FThemeData theme) {
    final fallbacks = AppFontConfig.getGlobalFontFallbacks();
    const family = AppFontConfig.primaryFontFamily;
    // MiSansVF is a variable font; the wght axis faithfully applies font weight.
    // Headings already differentiate hierarchy via font size + color; weight stays
    // lightweight to match the harmonious feel of MiSans-L3 (static light).
    return GptMarkdownThemeData(
      brightness: theme.colors.brightness,
      h1: TextStyle(
        fontSize: 28,
        color: theme.colors.primary,
        fontWeight: AppFontConfig.titleSemibold, // w500
        fontFamily: family,
        fontFamilyFallback: fallbacks,
      ),
      h2: TextStyle(
        fontSize: 24,
        fontWeight: AppFontConfig.titleSemibold, // w500
        fontFamily: family,
        fontFamilyFallback: fallbacks,
      ),
      h3: TextStyle(
        fontSize: 20,
        fontWeight: AppFontConfig.bodyMedium, // w400
        fontFamily: family,
        fontFamilyFallback: fallbacks,
      ),
      h4: TextStyle(
        fontSize: 17,
        fontWeight: AppFontConfig.bodyMedium, // w400
        fontFamily: family,
        fontFamilyFallback: fallbacks,
      ),
      h5: TextStyle(
        fontSize: 15,
        fontWeight: AppFontConfig.bodyMedium, // w400
        fontFamily: family,
        fontFamilyFallback: fallbacks,
      ),
      h6: TextStyle(
        fontSize: 14,
        fontWeight: AppFontConfig.bodyMedium, // w400
        fontFamily: family,
        fontFamilyFallback: fallbacks,
      ),
    );
  }

  /// Build live GenUI surface with immediate Shimmer skeleton fallback
  Widget _buildLiveSurfaceWithSkeleton(
    BuildContext context,
    FThemeData theme,
    String surfaceId,
  ) {
    final surfaceContext = widget.genUiHost.contextFor(surfaceId);
    return ValueListenableBuilder<genui.SurfaceDefinition?>(
      valueListenable: surfaceContext.definition,
      builder: (context, definition, child) {
        if (definition == null || definition.components.isEmpty) {
          return _buildShimmerSkeletonCard(context, theme);
        }
        return genui.Surface(surfaceContext: surfaceContext);
      },
    );
  }

  /// Render Shimmer skeleton loading card for instant visual feedback on CreateSurface
  Widget _buildShimmerSkeletonCard(BuildContext context, FThemeData theme) {
    final colors = theme.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
      ),
      child: Shimmer.fromColors(
        baseColor: colors.mutedForeground.withValues(alpha: 0.15),
        highlightColor: colors.mutedForeground.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 180,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Throttled Markdown renderer (M-5).
///
/// During streaming the full text grows on every chunk, and re-parsing the
/// whole string with [GptMarkdown] on each chunk is O(n^2). This widget only
/// re-parses at most once per [_ThrottledMarkdownState.throttle] while
/// streaming, reusing the most recently parsed widget within the window, and
/// parses immediately once streaming finishes. Reusing the same [GptMarkdown]
/// instance across frames lets Flutter skip the unchanged subtree (identical
/// widget), so no redundant parse happens between throttled refreshes.
class _ThrottledMarkdown extends StatefulWidget {
  final String text;
  final FThemeData theme;
  final GptMarkdownThemeData gptThemeData;
  final bool isStreaming;

  const _ThrottledMarkdown({
    required this.text,
    required this.theme,
    required this.gptThemeData,
    required this.isStreaming,
  });

  @override
  State<_ThrottledMarkdown> createState() => _ThrottledMarkdownState();
}

class _ThrottledMarkdownState extends State<_ThrottledMarkdown> {
  static const throttle = Duration(milliseconds: 180);

  Timer? _timer;
  DateTime _lastRender = DateTime.fromMillisecondsSinceEpoch(0);
  Widget? _cached;

  @override
  void didUpdateWidget(_ThrottledMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) return;
    if (widget.isStreaming) {
      // Coalesce rapid chunks into a single throttled refresh.
      _timer?.cancel();
      _timer = Timer(throttle, () {
        _timer = null;
        if (mounted) setState(() {});
      });
    } else {
      // Streaming finished -> parse on the next build.
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final staleEnough = now.difference(_lastRender) >= throttle;
    // Reuse the cached Markdown within the throttle window while streaming.
    // ``_timer == null`` means the throttled timer just fired (its callback
    // nulls the field before setState), in which case we MUST render the very
    // latest text even inside the window. Without this, a dense stream that
    // keeps resetting the timer would never enter the ``!isStreaming`` branch
    // and would freeze the text until the stream ends.
    if (!widget.isStreaming || staleEnough || _timer == null) {
      _lastRender = now;
      _cached = _buildMarkdown(context);
    }
    // Within the throttle window while streaming, reuse the most recently
    // parsed Markdown instead of re-parsing the full growing text.
    return _cached ?? _buildMarkdown(context);
  }

  Widget _buildMarkdown(BuildContext context) {
    return GptMarkdownTheme(
      gptThemeData: widget.gptThemeData,
      child: GptMarkdown(
        widget.text,
        style: TextStyle(
          fontSize: 15,
          color: widget.theme.colors.foreground,
          height: 1.5,
          fontFamily: AppFontConfig.primaryFontFamily,
          fontFamilyFallback: AppFontConfig.getGlobalFontFallbacks(),
        ),
        // Custom ordered list builder for proper number alignment
        orderedListBuilder: (ctx, no, child, config) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed-width container for right-aligned numbers
                SizedBox(
                  width: 28,
                  child: Text(
                    '$no.',
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.theme.colors.foreground,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: child),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Cache entry for memoizing GenUI component subtrees
class _GenUiCacheEntry {
  final UIComponentMode mode;
  final FThemeData theme;
  final Map<String, dynamic> data;
  final Widget widget;

  _GenUiCacheEntry({
    required this.mode,
    required this.theme,
    required this.data,
    required this.widget,
  });
}
