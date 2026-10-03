import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Helper class to guide users through enabling background task permissions
///
/// On Android: checks and requests battery optimization exemption via
/// [Permission.ignoreBatteryOptimizations] (permission_handler package).
/// Without this exemption, WorkManager periodic tasks are killed by the OS
/// on most physical Android devices (Samsung, Xiaomi, Huawei, etc.).
///
/// On iOS: background task scheduling is managed by the OS and cannot be
/// programmatically enabled.
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
}
