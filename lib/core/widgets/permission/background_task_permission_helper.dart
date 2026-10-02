import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_education_dialog.dart';

/// Helper class to guide users through enabling background task permissions
///
/// On Android: checks and requests battery optimization exemption via
/// [Permission.ignoreBatteryOptimizations] (permission_handler package).
/// Without this exemption, WorkManager periodic tasks are killed by the OS
/// on most physical Android devices (Samsung, Xiaomi, Huawei, etc.).
///
/// On iOS: background task scheduling is managed by the OS and cannot be
/// programmatically enabled, so we only educate the user.
class BackgroundTaskPermissionHelper {
  /// Check if background tasks can run without OS interference.
  ///
  /// On Android: returns true if battery optimization is disabled for this app.
  /// On iOS: always returns true (cannot be checked programmatically).
  static Future<bool> isBackgroundTaskEnabled() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Request the OS to exempt this app from battery optimization.
  ///
  /// On Android: shows the system dialog "Allow <app> to ignore battery
  /// optimizations?" via ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS.
  /// Returns true if the user granted the exemption.
  ///
  /// On iOS: returns true immediately (not applicable).
  static Future<bool> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final result = await Permission.ignoreBatteryOptimizations.request();
    return result.isGranted;
  }

  /// Show education dialog explaining why background tasks need to be enabled.
  ///
  /// Returns true if the user acknowledged and wants to proceed to settings,
  /// false if the user cancelled.
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

  /// Show information dialog about background tasks being disabled, with an
  /// option to open the battery optimization settings page.
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
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // Open the app's battery optimization settings page
                await openAppSettings();
              },
              child: Text(settingsText),
            ),
          ],
        );
      },
    );
  }

  /// Full flow: educate the user, then request the battery optimization
  /// exemption, then optionally show a denied-info dialog.
  ///
  /// Returns true if the user granted (or already had) the exemption.
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
      return false;
    }

    // Step 2: Request exemption (Android shows system dialog)
    final granted = await requestBatteryOptimizationExemption();

    // Step 3: If denied, offer to open settings
    if (!granted && context.mounted) {
      await showBackgroundTaskDeniedInfo(
        context: context,
        title: deniedTitle,
        message: deniedMessage,
        settingsText: settingsText,
        cancelText: cancelText,
      );
    }

    return granted;
  }
}
