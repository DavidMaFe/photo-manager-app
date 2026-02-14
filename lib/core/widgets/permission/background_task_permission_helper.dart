import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_education_dialog.dart';

/// Helper class to guide users through enabling background task permissions
///
/// Note: Unlike photo or notification permissions, background task settings
/// (battery optimization, background app refresh) typically cannot be
/// programmatically requested. This helper educates users and guides them
/// to the appropriate settings.
class BackgroundTaskPermissionHelper {
  /// Show education dialog for background tasks
  ///
  /// Returns true if user acknowledges and wants to proceed to settings,
  /// false if user cancels
  ///
  /// On Android: Guides users to disable battery optimization
  /// On iOS: Guides users to enable background app refresh
  static Future<bool> showBackgroundTaskEducation({
    required BuildContext context,
    required String title,
    required String messageAndroid,
    required String messageIOS,
    required String continueText,
    required String cancelText,
  }) async {
    final message = Platform.isAndroid ? messageAndroid : messageIOS;

    final result = await PermissionEducationDialog.show(
      context: context,
      title: title,
      message: message,
      continueText: continueText,
      cancelText: cancelText,
      icon: Icons.settings_backup_restore,
    );

    return result ?? false;
  }

  /// Show information dialog about background tasks being disabled
  ///
  /// Informs users about limited functionality and offers to guide them
  /// to settings
  static Future<void> showBackgroundTaskDeniedInfo({
    required BuildContext context,
    required String title,
    required String message,
    required String settingsText,
    required String cancelText,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber, size: 48),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(cancelText),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // In a production app, you might want to use a plugin like
                // app_settings to open specific settings pages
                // For now, we'll just close the dialog
              },
              child: Text(settingsText),
            ),
          ],
        );
      },
    );
  }

  /// Request background task "permission" (really just education + guidance)
  ///
  /// This method shows an education dialog and returns true if the user
  /// acknowledges. It cannot programmatically enable background tasks.
  ///
  /// Returns:
  /// - true: User acknowledged and wants to enable background tasks
  /// - false: User cancelled
  static Future<bool> requestBackgroundTaskPermission({
    required BuildContext context,
    required String educationTitle,
    required String educationMessageAndroid,
    required String educationMessageIOS,
    required String deniedTitle,
    required String deniedMessage,
    required String continueText,
    required String settingsText,
    required String cancelText,
  }) async {
    // Step 1: Show education dialog
    final userWantsToProceed = await showBackgroundTaskEducation(
      context: context,
      title: educationTitle,
      messageAndroid: educationMessageAndroid,
      messageIOS: educationMessageIOS,
      continueText: continueText,
      cancelText: cancelText,
    );

    if (!userWantsToProceed) {
      return false; // User cancelled
    }

    // Step 2: For now, we'll assume the user will enable it manually
    // In a real implementation, you could:
    // 1. Open device settings using a plugin like app_settings
    // 2. Guide users through the process with a tutorial overlay
    // 3. Check if settings were actually changed (difficult to detect)

    // For this implementation, we'll consider the "permission" granted
    // if the user acknowledged the education dialog
    // The actual functionality will work or not based on device settings

    return true; // User acknowledged
  }

  /// Check if background app refresh is likely enabled (best effort)
  ///
  /// Note: It's difficult to programmatically check battery optimization
  /// or background app refresh settings. This method returns a best-effort guess.
  ///
  /// Returns true (optimistic default - assume enabled unless we can detect otherwise)
  static Future<bool> isBackgroundTaskEnabled() async {
    // On most platforms, we cannot reliably check this without specific plugins
    // Return true by default (optimistic)
    //
    // In a production app, you might:
    // - Use a plugin like battery_plus to check optimization status
    // - Use platform channels to check iOS background refresh settings
    // - Track whether background tasks are actually executing successfully

    return true;
  }
}
