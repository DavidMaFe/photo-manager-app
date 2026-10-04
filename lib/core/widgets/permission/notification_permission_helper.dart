import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Checks and requests the notification permission.
class NotificationPermissionHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check current notification permission status
  ///
  /// Returns true if granted, false if denied, null if not determined
  static Future<bool?> _checkNotificationPermission() async {
    if (Platform.isAndroid) {
      // On Android 13+, we need to check the permission status
      // Using the notification plugin's method
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted = await androidImplementation.areNotificationsEnabled();
        return granted;
      }

      // For Android < 13, notifications are enabled by default
      return true;
    } else if (Platform.isIOS) {
      // On iOS, check notification settings
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        // Request permission will return the current status
        return null; // We'll need to request to know the status
      }
    }

    return null;
  }

  /// Request notification permission from the operating system
  ///
  /// Returns true if permission was granted
  static Future<bool> _requestPermissionFromOS() async {
    if (Platform.isAndroid) {
      // On Android 13+, request notification permission
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      // For Android < 13, notifications are enabled by default
      return true;
    } else if (Platform.isIOS) {
      // On iOS, request notification permission
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }

    return false;
  }

  /// Shows the system prompt without education dialogs.
  static Future<bool> requestFromOS() => _requestPermissionFromOS();

  /// Check if notifications are enabled (public method for external use)
  static Future<bool> areNotificationsEnabled() async {
    final status = await _checkNotificationPermission();
    return status ?? false;
  }
}
