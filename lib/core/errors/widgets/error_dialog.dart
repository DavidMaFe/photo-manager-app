import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';

/// Modern, beautiful dialog for displaying errors
///
/// Features:
/// - Clean, modern dialog design
/// - Prominent icon with failure-type coloring
/// - Clear title and message
/// - Field errors in expandable section (if validation failure)
/// - Primary action button (dismiss/retry)
/// - Optional secondary action
/// - Smooth animations
class ErrorDialog {
  /// Shows an error dialog with modern, beautiful design
  static Future<void> show(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? retryButtonText,
    String? dismissButtonText,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ErrorDialogContent(
        failure: failure,
        onRetry: onRetry,
        onDismiss: onDismiss,
        retryButtonText: retryButtonText,
        dismissButtonText: dismissButtonText,
      ),
    );
  }
}

class _ErrorDialogContent extends StatefulWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? retryButtonText;
  final String? dismissButtonText;

  const _ErrorDialogContent({
    required this.failure,
    this.onRetry,
    this.onDismiss,
    this.retryButtonText,
    this.dismissButtonText,
  });

  @override
  State<_ErrorDialogContent> createState() => _ErrorDialogContentState();
}

class _ErrorDialogContentState extends State<_ErrorDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showFieldErrors = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get failure-specific icon and color
    final iconData = _getIconForFailure(widget.failure);
    final iconColor = _getColorForFailure(widget.failure, isDark);

    // Get localized messages
    final title = FailureMessageHelper.getTitle(context, widget.failure);
    final message = FailureMessageHelper.getMessage(context, widget.failure);

    // Check if this is a ValidationFailure with field errors
    final hasFieldErrors = widget.failure is ValidationFailure &&
        widget.failure.data != null &&
        widget.failure.data is Map<String, String> &&
        (widget.failure.data as Map<String, String>).isNotEmpty;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Field errors (expandable)
                if (hasFieldErrors) ...[
                  const SizedBox(height: 16),
                  _buildFieldErrorsSection(
                    context,
                    widget.failure.data as Map<String, String>,
                    iconColor,
                    isDark,
                  ),
                ],

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    // Dismiss button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismiss?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          widget.dismissButtonText ?? 'Dismiss',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Retry button (if provided)
                    if (widget.onRetry != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onRetry!();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.retryButtonText ?? 'Retry',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldErrorsSection(
    BuildContext context,
    Map<String, String> fieldErrors,
    Color iconColor,
    bool isDark,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showFieldErrors = !_showFieldErrors;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: iconColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Field Validation Errors',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  _showFieldErrors
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _showFieldErrors
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fieldErrors.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: '${entry.key}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: entry.value),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForFailure(Failure failure) {
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

  Color _getColorForFailure(Failure failure, bool isDark) {
    // Network/connectivity issues - blue
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    }

    // Validation/warning issues - orange
    if (failure is ValidationFailure || failure is StorageSpaceExceededFailure) {
      return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
    }

    // Auth/permission issues - amber
    if (failure is UnauthorizedFailure || failure is PermissionDeniedFailure) {
      return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
    }

    // Critical errors - red
    return isDark ? Colors.red.shade300 : Colors.red.shade700;
  }
}
