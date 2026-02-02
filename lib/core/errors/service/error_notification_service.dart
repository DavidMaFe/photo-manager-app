import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/widgets/error_dialog.dart';
import 'package:photo_manager_app/core/errors/widgets/error_snack_bar.dart';

/// Configuration for how errors should be displayed
class ErrorDisplayConfig {
  final Duration duration;
  final bool showAsSnackBar;
  final bool showAsDialog;
  final bool showAsBanner;
  final bool vibrate;
  final Color? backgroundColor;
  final IconData? icon;

  const ErrorDisplayConfig({
    this.duration = const Duration(seconds: 4),
    this.showAsSnackBar = true,
    this.showAsDialog = false,
    this.showAsBanner = false,
    this.vibrate = false,
    this.backgroundColor,
    this.icon,
  });

  /// Shows error as a SnackBar (default, non-intrusive)
  static const snackBar = ErrorDisplayConfig(showAsSnackBar: true);

  /// Shows error as a Dialog (requires user interaction)
  static const dialog = ErrorDisplayConfig(
    showAsSnackBar: false,
    showAsDialog: true,
  );

  /// Shows error as a Dialog with vibration (for critical errors)
  static const critical = ErrorDisplayConfig(
    showAsSnackBar: false,
    showAsDialog: true,
    duration: Duration(seconds: 0),
    vibrate: true,
  );

  /// Shows error as an inline banner (for forms/inline errors)
  static const banner = ErrorDisplayConfig(
    showAsSnackBar: false,
    showAsBanner: true,
  );
}

/// Service for displaying error notifications using modern, beautiful widgets
///
/// Supports multiple display modes:
/// - SnackBar: Non-intrusive, dismissible (default)
/// - Dialog: Modal, requires interaction
/// - Banner: Inline, for forms (use ErrorBanner widget directly)
///
/// Features:
/// - Automatic field-level validation error display
/// - Failure-type specific colors and icons
/// - Retry and dismiss callbacks
/// - Haptic feedback for critical errors
/// - Light/dark theme support
class ErrorNotificationService {
  /// Shows an error notification based on the provided configuration
  static void showError(
    BuildContext context,
    Failure failure, {
    ErrorDisplayConfig config = ErrorDisplayConfig.snackBar,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? retryButtonText,
    String? dismissButtonText,
  }) {
    // Vibrate if configured (for critical errors)
    if (config.vibrate) {
      HapticFeedback.heavyImpact();
    }

    // Show error based on configuration
    if (config.showAsDialog) {
      ErrorDialog.show(
        context,
        failure,
        onRetry: onRetry,
        onDismiss: onDismiss,
        retryButtonText: retryButtonText,
        dismissButtonText: dismissButtonText,
      );
    } else if (config.showAsSnackBar) {
      ErrorSnackBar.show(
        context,
        failure,
        onRetry: onRetry,
        duration: config.duration,
      );

      // Call onDismiss after duration if provided
      if (onDismiss != null) {
        Future.delayed(config.duration, onDismiss);
      }
    }
    // Note: For banner display, use ErrorBanner widget directly in your UI
  }

  /// Shows a success notification as a SnackBar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.check_circle,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
