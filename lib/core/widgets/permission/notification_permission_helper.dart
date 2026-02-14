import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_education_dialog.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_denied_dialog.dart';

/// Helper class to request notification permissions with education dialogs
class NotificationPermissionHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Request notification permission with education dialog
  ///
  /// Returns true if permission is granted, false otherwise
  ///
  /// Shows an education dialog before requesting permission, and a denial dialog
  /// if the user denies the permission.
  static Future<bool> requestNotificationPermission({
    required BuildContext context,
    required String educationTitle,
    required String educationMessage,
    required String deniedTitle,
    required String deniedMessage,
    required String continueText,
    required String settingsText,
    required String cancelText,
  }) async {
    // Step 1: Check if permission is already granted
    final currentStatus = await _checkNotificationPermission();

    if (currentStatus == true) {
      return true;
    }

    // Step 2: Show education dialog (check mounted after async gap)
    if (!context.mounted) return false;
    final shouldRequestPermission = await PermissionEducationDialog.show(
      context: context,
      title: educationTitle,
      message: educationMessage,
      continueText: continueText,
      cancelText: cancelText,
      icon: Icons.notifications,
    );

    if (shouldRequestPermission != true) {
      return false; // User cancelled
    }

    // Step 3: Request permission from OS
    final granted = await _requestPermissionFromOS();

    // Step 4: If denied, show denial dialog
    // Check context is still valid after async gap
    if (!granted && context.mounted) {
      await PermissionDeniedDialog.show(
        context: context,
        title: deniedTitle,
        message: deniedMessage,
        settingsText: settingsText,
        cancelText: cancelText,
      );
    }

    return granted;
  }

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

  /// Check if notifications are enabled (public method for external use)
  static Future<bool> areNotificationsEnabled() async {
    final status = await _checkNotificationPermission();
    return status ?? false;
  }
}
