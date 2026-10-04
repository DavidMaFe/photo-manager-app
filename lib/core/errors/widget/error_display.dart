import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../base/failures.dart';

/// Modern, beautiful full-page error display widget
///
/// Features:
/// - Large, contextual illustration/icon
/// - Clear hierarchy: title → message → field errors (if any)
/// - Prominent retry button with loading state
/// - Support empty state vs error state
/// - Responsive design
/// - Beautiful animations
class ErrorDisplay extends StatefulWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final String? customMessageKey;
  final bool isLoading;

  const ErrorDisplay({
    super.key,
    required this.failure,
    this.onRetry,
    this.customMessageKey,
    this.isLoading = false,
  });

  @override
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = widget.customMessageKey != null
        ? _getCustomMessage(l10n, widget.customMessageKey!)
        : FailureMessageHelper.getMessage(context, widget.failure);
    final title = FailureMessageHelper.getTitle(context, widget.failure);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _getColorForFailure(widget.failure, isDark);

    // Check if this is a ValidationFailure with field errors
    final hasFieldErrors = widget.failure is ValidationFailure &&
        widget.failure.data != null &&
        widget.failure.data is Map<String, String> &&
        (widget.failure.data as Map<String, String>).isNotEmpty;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(),
                          size: 56,
                          color: iconColor,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.palette.ink,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Message
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.palette.ink2,
                          height: 1.6,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Field errors (if any)
                if (hasFieldErrors) ...[
                  const SizedBox(height: 24),
                  _buildFieldErrors(
                    context,
                    widget.failure.data as Map<String, String>,
                    iconColor,
                    isDark,
                  ),
                ],

                // Retry button
                if (widget.onRetry != null) ...[
                  const SizedBox(height: 40),
                  _isRetrying
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _handleRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.tryAgain),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconColor,
                            foregroundColor: context.palette.onAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldErrors(
    BuildContext context,
    Map<String, String> fieldErrors,
    Color iconColor,
    bool isDark,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Field Validation Errors',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fieldErrors.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: context.palette.ink2,
                          height: 1.5,
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
        ],
      ),
    );
  }

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onRetry?.call();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  IconData _getIcon() {
    if (widget.failure is NetworkFailure) return Icons.wifi_off_rounded;
    if (widget.failure is TimeoutFailure) return Icons.access_time_rounded;
    if (widget.failure is ServerFailure) return Icons.cloud_off_rounded;
    if (widget.failure is ValidationFailure) return Icons.warning_amber_rounded;
    if (widget.failure is UnauthorizedFailure) return Icons.lock_rounded;
    if (widget.failure is NotFoundFailure) return Icons.search_off_rounded;
    if (widget.failure is StorageSpaceExceededFailure) return Icons.storage_rounded;
    if (widget.failure is PermissionDeniedFailure) return Icons.block_rounded;
    return Icons.error_outline_rounded;
  }

  Color _getColorForFailure(Failure failure, bool isDark) {
    // Network/connectivity issues - blue
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return context.palette.accent;
    }

    // Validation/warning issues - orange
    if (failure is ValidationFailure || failure is StorageSpaceExceededFailure) {
      return context.palette.reviewIcon;
    }

    // Auth/permission issues - amber
    if (failure is UnauthorizedFailure || failure is PermissionDeniedFailure) {
      return context.palette.reviewIcon;
    }

    // Critical errors - red
    return context.palette.dangerInk;
  }

  String _getCustomMessage(AppLocalizations l10n, String key) {
    switch (key) {
      case 'errorNetwork':
        return l10n.errorNetwork;
      case 'errorServer':
        return l10n.errorServer;
      default:
        return l10n.errorUnknown;
    }
  }
}