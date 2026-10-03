import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';

/// Modern, beautiful SnackBar for displaying errors
///
/// Features:
/// - Failure-type specific icons and colors
/// - Clear, readable typography
/// - Optional retry button
/// - Dismissible with swipe gesture
/// - Field-level validation error display (for ValidationFailure)
/// - Light/dark theme support
class ErrorSnackBar {
  /// Shows an error SnackBar with modern, beautiful design
  static void show(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    // The snackbar is inverted (ink background), so its content uses the
    // palette of the opposite brightness.
    final inverse = context.inversePalette;

    // Get failure-specific icon and color
    final iconData = _getIconForFailure(failure);
    final iconColor = _getColorForFailure(failure, inverse);

    // Get localized messages
    final title = FailureMessageHelper.getTitle(context, failure);
    final message = FailureMessageHelper.getMessage(context, failure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _ErrorSnackBarContent(
          icon: iconData,
          iconColor: iconColor,
          title: title,
          message: message,
          failure: failure,
          onRetry: onRetry,
        ),
        backgroundColor: context.palette.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        elevation: 4,
      ),
    );
  }

  static IconData _getIconForFailure(Failure failure) {
    if (failure is NetworkFailure) return Icons.wifi_off_rounded;
    if (failure is TimeoutFailure) return Icons.access_time_rounded;
    if (failure is ServerFailure) return Icons.cloud_off_rounded;
    if (failure is ValidationFailure) return Icons.warning_amber_rounded;
    if (failure is UnauthorizedFailure) return Icons.lock_rounded;
    if (failure is NotFoundFailure) return Icons.search_off_rounded;
    if (failure is StorageSpaceExceededFailure) return Icons.storage_rounded;
    if (failure is PermissionDeniedFailure) return Icons.block_rounded;
    return Icons.error_outline_rounded;
  }

  static Color _getColorForFailure(Failure failure, AppPalette p) {
    // Network/connectivity issues - accent
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return p.accent;
    }

    // Validation, warning, auth and permission issues - review
    if (failure is ValidationFailure ||
        failure is StorageSpaceExceededFailure ||
        failure is UnauthorizedFailure ||
        failure is PermissionDeniedFailure) {
      return p.review;
    }

    // Critical errors - danger
    return p.dangerInk;
  }
}

class _ErrorSnackBarContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Failure failure;
  final VoidCallback? onRetry;

  const _ErrorSnackBarContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.failure,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final inverse = context.inversePalette;
    final textColor = inverse.ink;
    final subtextColor = inverse.ink2;

    // Check if this is a ValidationFailure with field errors
    final hasFieldErrors = failure is ValidationFailure &&
                          failure.data != null &&
                          failure.data is Map<String, String> &&
                          (failure.data as Map<String, String>).isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 4),

              // Message
              Text(
                message,
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              // Field errors (if any)
              if (hasFieldErrors) ...[
                const SizedBox(height: 8),
                _buildFieldErrors(
                  context,
                  failure.data as Map<String, String>,
                  subtextColor,
                ),
              ],
            ],
          ),
        ),

        // Retry button (if provided)
        if (onRetry != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: iconColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldErrors(
    BuildContext context,
    Map<String, String> fieldErrors,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: fieldErrors.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color: textColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
