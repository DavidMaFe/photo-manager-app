import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class ErrorDisplayConfig {

  final Duration duration;
  final bool showAsSnackBar;
  final bool showAsDialog;
  final bool vibrate;
  final Color? backgroundColor;
  final IconData? icon;

  const ErrorDisplayConfig({
    this.duration = const Duration(seconds: 4),
    this.showAsSnackBar = true,
    this.showAsDialog = false,
    this.vibrate = false,
    this.backgroundColor,
    this.icon
  });

  static const snackBar = ErrorDisplayConfig(showAsSnackBar: true);
  static const dialog = ErrorDisplayConfig(showAsSnackBar: false, showAsDialog: true);
  static const critical = ErrorDisplayConfig(showAsDialog: true, duration: Duration(seconds: 0), vibrate: true);
}


class ErrorNotificationService {

  static void showError(
      BuildContext context,
      Failure failure,
      {
        ErrorDisplayConfig config = ErrorDisplayConfig.snackBar,
        VoidCallback? onRetry,
        VoidCallback? onDismiss
      }) {
    if (config.showAsDialog) {
      _showErrorDialog(context, failure, onRetry: onRetry);
    } else if (config.showAsSnackBar) {
      _showErrorSnackBar(context, failure, config: config, onRetry: onRetry);
    }

    if (config.vibrate){
      //HapticFeedback.vibrate();
    }

    if (onDismiss != null) {
      Future.delayed(config.duration, onDismiss);
    }
  }

  static void _showErrorDialog(
      BuildContext context,
      Failure failure,
      {
        VoidCallback? onRetry
      }) {
    final l10n = AppLocalizations.of(context)!;
    final message = FailureMessageHelper.getMessage(context, failure);
    final title = FailureMessageHelper.getTitle(context, failure);
    final formattedCode = FailureMessageHelper.getFormattedCode(context, failure.code);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getIconForFailure(failure),
              color: Colors.red.shade700,
              size: 28
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold
                ),
              )
            )
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (formattedCode != null) ...[
              const SizedBox(height: 8),
              Text(
                formattedCode,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600
                ),
              )
            ]
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(l10n.tryAgain),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            )
        ],
      )
    );
  }

  static void _showErrorSnackBar(
      BuildContext context,
      Failure failure,
      {
        required ErrorDisplayConfig config,
        VoidCallback? onRetry
      }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final message = FailureMessageHelper.getMessage(context, failure);
    final title = FailureMessageHelper.getTitle(context, failure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconForFailure(failure),
              color: Colors.white,
              size: 24
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13),
                  )
                ],
              ),
            )
          ],
        ),
        backgroundColor: config.backgroundColor ?? (isDark ? Colors.red.shade900 : Colors.red.shade700),
        duration: config.duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: onRetry != null ? SnackBarAction(label: l10n.tryAgain, textColor: Colors.white, onPressed: onRetry) : null
      ),
    );
  }

  static IconData _getIconForFailure(Failure failure) {
    if (failure is NetworkFailure) return Icons.wifi_off;
    if (failure is ServerFailure) return Icons.cloud_off;
    if (failure is ValidationFailure) return Icons.warning;
    if (failure is UnauthorizedFailure) return Icons.lock;
    if (failure is NotFoundFailure) return Icons.search_off;
    if (failure is StorageSpaceExceededFailure) return Icons.storage;
    return Icons.error_outline;
  }
}