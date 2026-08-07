import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finvo/features/chat/models/media_upload_exception.dart';
import 'package:finvo/features/chat/services/retry_policy.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/widgets/top_toast.dart';

/// Media upload error handling service
/// Provides user-friendly error handling and guidance functionality
class MediaErrorHandler {
  static final Logger _logger = Logger('MediaErrorHandler');

  /// Handle media upload exceptions and display user-friendly error messages
  ///
  /// [context] Build context
  /// [exception] Media upload exception
  /// [onRetry] Retry callback (optional)
  static Future<void> handleException(
    BuildContext context,
    MediaUploadException exception, {
    VoidCallback? onRetry,
  }) async {
    _logger.warning(
      'Handling media upload exception: ${exception.type} - ${exception.message}',
    );

    switch (exception.type) {
      case MediaUploadError.permissionDenied:
        await _handlePermissionDenied(context, exception);
        break;
      case MediaUploadError.fileSizeExceeded:
        await _handleFileSizeExceeded(context, exception);
        break;
      case MediaUploadError.unsupportedFormat:
        await _handleUnsupportedFormat(context, exception);
        break;
      case MediaUploadError.storageInsufficient:
        await _handleStorageInsufficient(context, exception);
        break;
      case MediaUploadError.networkError:
        await _handleNetworkError(context, exception, onRetry);
        break;
      case MediaUploadError.noFilesSelected:
        // Usually no need to display error, user actively cancelled selection
        break;
      case MediaUploadError.platformNotSupported:
        await _handlePlatformNotSupported(context, exception);
        break;
      case MediaUploadError.fileReadError:
        await _handleFileReadError(context, exception, onRetry);
        break;
      case MediaUploadError.fileNotFound:
        await _handleFileNotFound(context, exception, onRetry);
        break;
      case MediaUploadError.validationError:
        await _handleValidationError(context, exception);
        break;
      case MediaUploadError.thumbnailGenerationError:
        await _handleThumbnailGenerationError(context, exception);
        break;
      case MediaUploadError.unknownError:
        await _handleUnknownError(context, exception, onRetry);
        break;
    }
  }

  /// Handle permission denied error
  static Future<void> _handlePermissionDenied(
    BuildContext context,
    MediaUploadException exception,
  ) async {
    // Log detailed permission denial information
    _logger.warning(
      'Permission denied: ${exception.message}',
      exception.originalError,
    );

    final scheme = Theme.of(context).colorScheme;
    await _showMediaErrorDialog(
      context,
      title: t.error.permissionRequired,
      icon: Icons.security,
      iconColor: scheme.primary,
      content: [
        Text(exception.message),
        const SizedBox(height: 16),
        _highlightBoxWithHeading(
          context,
          icon: Icons.settings,
          heading: t.error.settingsSteps,
          body: t.error.permissionInstructions,
          containerColor: scheme.primaryContainer,
          onContainerColor: scheme.onPrimaryContainer,
        ),
      ],
      actions: [
        _dialogCancelButton(context),
        _dialogIconButton(
          context,
          icon: Icons.settings,
          label: t.error.openSettings,
          onPressed: () {
            _logger.info('User chose to open app settings');
            unawaited(_openAppSettings());
          },
        ),
      ],
    );
  }

  /// Handle file size exceeded error
  static Future<void> _handleFileSizeExceeded(
    BuildContext context,
    MediaUploadException exception,
  ) async {
    // Log detailed file size exceeded information
    _logger.warning(
      'File size exceeded: ${exception.message}',
      exception.originalError,
    );

    final scheme = Theme.of(context).colorScheme;
    await _showMediaErrorDialog(
      context,
      title: t.error.fileTooLarge,
      icon: Icons.file_present,
      iconColor: scheme.error,
      content: [
        _errorMessageBox(context, message: exception.message),
        const SizedBox(height: 16),
        _highlightBoxWithHeading(
          context,
          icon: Icons.lightbulb_outline,
          heading: t.error.suggestions,
          body: t.error.fileSizeHint,
          containerColor: scheme.surfaceContainerHighest,
          onContainerColor: scheme.onSurfaceVariant,
        ),
      ],
      actions: [_dialogOkButton(context)],
    );
  }

  /// Handle unsupported file format error
  static Future<void> _handleUnsupportedFormat(
    BuildContext context,
    MediaUploadException exception,
  ) async {
    await _showMediaErrorDialog(
      context,
      title: t.media.unsupportedFormat,
      content: [
        Text(exception.message),
        const SizedBox(height: 16),
        Text(
          t.error.supportedFormatsHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      actions: [_dialogOkButton(context)],
    );
  }

  /// Handle insufficient storage space error
  static Future<void> _handleStorageInsufficient(
    BuildContext context,
    MediaUploadException exception,
  ) async {
    await _showMediaErrorDialog(
      context,
      title: t.media.storageInsufficient,
      content: [
        Text(exception.message),
        const SizedBox(height: 16),
        Text(
          t.error.storageCleanupHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      actions: [_dialogOkButton(context)],
    );
  }

  /// Handle network error
  static Future<void> _handleNetworkError(
    BuildContext context,
    MediaUploadException exception,
    VoidCallback? onRetry,
  ) async {
    // Log detailed network error information
    _logger.warning(
      'Network error details: ${exception.message}',
      exception.originalError,
    );

    final scheme = Theme.of(context).colorScheme;
    await _showMediaErrorDialog(
      context,
      title: t.media.networkError,
      icon: Icons.wifi_off,
      iconColor: scheme.error,
      content: [
        Text(exception.message),
        const SizedBox(height: 16),
        _highlightBox(
          context,
          icon: Icons.info_outline,
          body: t.error.networkErrorHint,
          containerColor: scheme.surfaceContainerHighest,
          onContainerColor: scheme.onSurfaceVariant,
        ),
      ],
      actions: [
        _dialogCancelButton(context),
        if (onRetry != null)
          _dialogIconButton(
            context,
            icon: Icons.refresh,
            label: t.common.retry,
            onPressed: () {
              _logger.info('User chose to retry network operation');
              onRetry();
            },
          ),
      ],
    );
  }

  /// Handle platform not supported error
  static Future<void> _handlePlatformNotSupported(
    BuildContext context,
    MediaUploadException exception,
  ) async {
    await _showMediaErrorDialog(
      context,
      title: t.error.platformNotSupported,
      content: [Text(exception.message)],
      actions: [_dialogOkButton(context)],
    );
  }

  /// Handle file read error
  static Future<void> _handleFileReadError(
    BuildContext context,
    MediaUploadException exception,
    VoidCallback? onRetry,
  ) async {
    await _showMediaErrorDialog(
      context,
      title: t.error.fileReadError,
      content: [
        Text(exception.message),
        const SizedBox(height: 16),
        Text(
          t.error.fileReadErrorHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      actions: [
        _dialogCancelButton(context),
        if (onRetry != null)
          _dialogTextButton(context, label: t.common.retry, onPressed: onRetry),
      ],
    );
  }

  /// Handle file not found error
  static Future<void> _handleFileNotFound(
    BuildContext context,
    MediaUploadException exception,
    VoidCallback? onRetry,
  ) async {
    final scheme = Theme.of(context).colorScheme;
    await _showMediaErrorDialog(
      context,
      title: t.error.fileNotFound,
      icon: Icons.file_present,
      iconColor: scheme.error,
      content: [
        _errorMessageBox(context, message: exception.message),
        const SizedBox(height: 16),
        Text(
          t.error.fileNotFoundHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      actions: [
        _dialogCancelButton(context),
        if (onRetry != null)
          _dialogTextButton(
            context,
            label: t.error.selectAgain,
            onPressed: onRetry,
          ),
      ],
    );
  }

  /// Handle validation error
  static Future<void> _handleValidationError(
    BuildContext context,
    MediaUploadException exception,
  ) async {
    await _showMediaErrorDialog(
      context,
      title: t.error.validationError,
      content: [Text(exception.message)],
      actions: [_dialogOkButton(context)],
    );
  }

  /// Handle thumbnail generation failure error
  static Future<void> _handleThumbnailGenerationError(
    BuildContext context,
    MediaUploadException exception,
  ) async {
    // Log detailed thumbnail generation failure information
    _logger.warning(
      'Thumbnail generation failed: ${exception.message}',
      exception.originalError,
    );

    final scheme = Theme.of(context).colorScheme;
    await _showMediaErrorDialog(
      context,
      title: t.error.thumbnailGenerationFailed,
      icon: Icons.image_not_supported,
      iconColor: scheme.primary,
      content: [
        _highlightBox(
          context,
          icon: Icons.info,
          body: t.error.thumbnailGenerationHint,
          containerColor: scheme.primaryContainer,
          onContainerColor: scheme.onPrimaryContainer,
          bodyStyle: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          exception.message,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
      actions: [_dialogOkButton(context)],
    );
  }

  /// Handle unknown error
  static Future<void> _handleUnknownError(
    BuildContext context,
    MediaUploadException exception,
    VoidCallback? onRetry,
  ) async {
    // Log detailed error information for debugging, including stack trace
    final errorDetails = {
      'message': exception.message,
      'originalError': exception.originalError?.toString(),
      'errorType': exception.originalError?.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logger.severe(
      'Unknown error details: $errorDetails',
      exception.originalError,
    );

    final scheme = Theme.of(context).colorScheme;
    await _showMediaErrorDialog(
      context,
      title: t.error.unknownError,
      icon: Icons.error_outline,
      iconColor: scheme.error,
      content: [
        _errorMessageBox(context, message: exception.message),
        const SizedBox(height: 16),
        _highlightBoxWithHeading(
          context,
          icon: Icons.support_agent,
          heading: t.error.help,
          body: t.error.unknownErrorHint,
          containerColor: scheme.surfaceContainerHighest,
          onContainerColor: scheme.onSurfaceVariant,
        ),
      ],
      actions: [
        _dialogCancelButton(context),
        if (onRetry != null)
          _dialogIconButton(
            context,
            icon: Icons.refresh,
            label: t.common.retry,
            onPressed: () {
              _logger.info('User chose to retry unknown error operation');
              onRetry();
            },
          ),
      ],
    );
  }

  // ==========================================================================
  // Shared dialog building blocks
  // ==========================================================================

  /// Opens an [AlertDialog] with a consistent title row, content column and
  /// action buttons. Handlers only supply their payload, removing the
  /// duplicated dialog scaffolding.
  static Future<void> _showMediaErrorDialog(
    BuildContext context, {
    required String title,
    IconData? icon,
    Color? iconColor,
    required List<Widget> content,
    List<Widget> actions = const [],
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: _buildDialogTitle(
            dialogContext,
            title: title,
            icon: icon,
            iconColor: iconColor,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content,
          ),
          actions: actions,
        );
      },
    );
  }

  /// Title row: icon + text when [icon] is provided, plain text otherwise.
  static Widget _buildDialogTitle(
    BuildContext context, {
    required String title,
    IconData? icon,
    Color? iconColor,
  }) {
    if (icon == null) {
      return Text(title);
    }
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(title)),
      ],
    );
  }

  /// Error-styled box (errorContainer) with a warning icon and the raw message.
  static Widget _errorMessageBox(
    BuildContext context, {
    required String message,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, size: 16, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  /// Icon + single-line body box (no heading), e.g. network/thumbnail hints.
  static Widget _highlightBox(
    BuildContext context, {
    required IconData icon,
    required String body,
    required Color containerColor,
    required Color onContainerColor,
    TextStyle? bodyStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: onContainerColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              body,
              style: (bodyStyle ?? Theme.of(context).textTheme.bodySmall)
                  ?.copyWith(color: onContainerColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Icon + bold heading + body box, e.g. "Settings steps:" / "Suggestions:".
  static Widget _highlightBoxWithHeading(
    BuildContext context, {
    required IconData icon,
    required String heading,
    required String body,
    required Color containerColor,
    required Color onContainerColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: onContainerColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onContainerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: onContainerColor),
          ),
        ],
      ),
    );
  }

  /// Primary "OK" button that closes the dialog.
  static Widget _dialogOkButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(t.common.ok),
    );
  }

  /// Neutral "Cancel" button that closes the dialog.
  static Widget _dialogCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(t.common.cancel),
    );
  }

  /// Elevated button with leading icon; closes the dialog then runs [onPressed].
  static Widget _dialogIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        onPressed();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
    );
  }

  /// Plain elevated action button; closes the dialog then runs [onPressed].
  static Widget _dialogTextButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        onPressed();
      },
      child: Text(label),
    );
  }

  /// Open app settings page
  static Future<void> _openAppSettings() async {
    _logger.info('Attempting to open app settings page');

    try {
      // Try to open app settings page
      await SystemChannels.platform.invokeMethod(
        'SystemNavigator.openAppSettings',
      );
      _logger.info('Successfully opened app settings page');
    } catch (e) {
      _logger.warning('Primary method to open app settings page failed: $e');

      // If unable to open settings page, try other methods
      try {
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          _logger.info('Successfully opened settings page via backup method');
        } else {
          _logger.warning(
            'Backup method unavailable, cannot open settings page',
          );
        }
      } catch (e2) {
        _logger.severe('All methods to open settings page failed: $e2');

        // Log device and platform information for debugging
        _logger.info(
          'Device info: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        );
      }
    }
  }

  /// Display simple error notification (for scenarios that don't require dialog)
  ///
  /// [context] Build context
  /// [message] Error message
  /// [actionLabel] Optional action button label (rendered when non-null)
  /// [onActionPressed] Action button callback (used when [actionLabel] supplied)
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final action = actionLabel != null && onActionPressed != null
        ? TopToastAction(label: actionLabel, onPressed: onActionPressed)
        : null;
    ToastService.showDestructive(description: Text(message), action: action);
  }

  /// Display retry error notification
  ///
  /// [context] Build context
  /// [message] Error message
  /// [onRetry] Retry callback
  static void showRetrySnackBar(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    showErrorSnackBar(
      context,
      message,
      actionLabel: t.common.retry,
      onActionPressed: onRetry,
    );
  }

  /// Automatically retry network operation (with exponential backoff)
  ///
  /// [operation] Operation to retry
  /// [maxRetries] Maximum retry attempts
  /// [initialDelay] Initial delay time (milliseconds)
  /// [onRetryAttempt] Retry attempt callback (optional)
  ///
  /// Delegates to the shared [RetryPolicy] so retry mechanics live in one place.
  static Future<T> retryNetworkOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    int initialDelay = 1000,
    void Function(int attempt, Duration delay)? onRetryAttempt,
  }) {
    return RetryPolicy().retryWithBackoff<T>(
      operation: operation,
      maxAttempts: maxRetries,
      initialDelay: Duration(milliseconds: initialDelay),
      onRetry: onRetryAttempt,
    );
  }

  /// Log error statistics (for analysis and improvement)
  ///
  /// [exception] Media upload exception
  /// [context] Additional context information
  static void logErrorStatistics(
    MediaUploadException exception, {
    Map<String, dynamic>? context,
  }) {
    final errorStats = {
      'errorType': exception.type.toString(),
      'message': exception.message,
      'timestamp': DateTime.now().toIso8601String(),
      'originalErrorType': exception.originalError?.runtimeType.toString(),
      if (context != null) ...context,
    };

    _logger.info('Error statistics: $errorStats');
  }
}
