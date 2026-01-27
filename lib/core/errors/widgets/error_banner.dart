import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';

/// Compact inline error banner widget
///
/// Features:
/// - For form field errors or inline warnings
/// - Compact design with icon + message
/// - Support for field-level validation errors
/// - Dismissible
/// - Smooth slide-in animation
class ErrorBanner extends StatefulWidget {
  final Failure failure;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  final EdgeInsets? margin;
  final bool isDismissible;

  const ErrorBanner({
    super.key,
    required this.failure,
    this.onDismiss,
    this.onRetry,
    this.margin,
    this.isDismissible = true,
  });

  @override
  State<ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<ErrorBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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
    if (_isDismissed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _getColorForFailure(widget.failure, isDark);
    final message = FailureMessageHelper.getMessage(context, widget.failure);

    // Check if this is a ValidationFailure with field errors
    final hasFieldErrors = widget.failure is ValidationFailure &&
        widget.failure.data != null &&
        widget.failure.data is Map<String, String> &&
        (widget.failure.data as Map<String, String>).isNotEmpty;

    return SizeTransition(
      sizeFactor: _slideAnimation,
      axisAlignment: -1.0,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getIconForFailure(widget.failure),
                    color: iconColor,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 12),

                // Message
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Retry button (if provided)
                if (widget.onRetry != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onRetry,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],

                // Dismiss button
                if (widget.isDismissible) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white54 : Colors.black38,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Field errors (if any)
            if (hasFieldErrors) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (widget.failure.data as Map<String, String>)
                      .entries
                      .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
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
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      setState(() => _isDismissed = true);
      widget.onDismiss?.call();
    }
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
