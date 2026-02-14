import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/core/widgets/permission/background_task_permission_helper.dart';
import 'package:photo_manager_app/core/widgets/permission/notification_permission_helper.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_denied_dialog.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_education_dialog.dart';

/// Result of requesting all onboarding permissions
class OnboardingPermissionsResult {
  final bool photoGranted;
  final bool notificationGranted;
  final bool backgroundGranted;

  OnboardingPermissionsResult({
    required this.photoGranted,
    required this.notificationGranted,
    required this.backgroundGranted,
  });

  /// Check if all permissions were granted
  bool get allGranted => photoGranted && notificationGranted && backgroundGranted;

  /// Check if any permissions were granted
  bool get anyGranted => photoGranted || notificationGranted || backgroundGranted;

  /// Get a list of permission names that were denied
  List<String> getDeniedPermissions() {
    final denied = <String>[];
    if (!photoGranted) denied.add('photo');
    if (!notificationGranted) denied.add('notification');
    if (!backgroundGranted) denied.add('background');
    return denied;
  }
}

/// Helper class to handle permission requests with educational dialogs
class PermissionHelper {
  /// Request photo library access with educational dialog
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestPhotoAccess({
    required BuildContext context,
    required String educationTitle,
    required String educationMessage,
    required String deniedTitle,
    required String deniedMessage,
    required String continueText,
    required String settingsText,
    required String cancelText,
  }) async {
    // Check current permission status WITHOUT requesting
    final currentStatus = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
        androidPermission: AndroidPermission(
          type: RequestType.common,
          mediaLocation: false,
        ),
      ),
    );

    // If already granted, no need to show dialogs
    if (currentStatus.isAuth) {
      return true;
    }

    // Show educational dialog first
    if (!context.mounted) return false;
    final shouldRequestPermission = await PermissionEducationDialog.showPhotoAccess(
      context: context,
      title: educationTitle,
      message: educationMessage,
      continueText: continueText,
      cancelText: cancelText,
    );

    // User declined to grant permission
    if (!shouldRequestPermission) {
      return false;
    }

    // Request system permission (this will show the OS permission dialog)
    final permissionState = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
        androidPermission: AndroidPermission(
          type: RequestType.common,
          mediaLocation: false,
        ),
      ),
    );

    // Permission granted
    if (permissionState.isAuth) {
      return true;
    }

    // Permission denied - show explanation dialog
    if (!permissionState.isAuth && permissionState.hasAccess == false) {
      if (!context.mounted) return false;
      await PermissionDeniedDialog.showPhotoAccessDenied(
        context: context,
        title: deniedTitle,
        message: deniedMessage,
        settingsText: settingsText,
        cancelText: cancelText,
      );
      return false;
    }

    return false;
  }

  /// Simple permission check without dialogs
  static Future<bool> checkPhotoAccess() async {
    final status = await PhotoManager.requestPermissionExtend();
    return status.isAuth;
  }

  /// Open app settings
  static Future<void> openSettings() async {
    await PhotoManager.openSetting();
  }

  /// Request all onboarding permissions sequentially
  ///
  /// Requests permissions in the following order:
  /// 1. Photo access (required for core functionality)
  /// 2. Notifications (for sync status updates)
  /// 3. Background tasks (for automatic syncing)
  ///
  /// Returns an [OnboardingPermissionsResult] with the status of each permission.
  /// The process continues even if some permissions are denied.
  static Future<OnboardingPermissionsResult> requestAllOnboardingPermissions({
    required BuildContext context,
    required String photoEducationTitle,
    required String photoEducationMessage,
    required String photoDeniedTitle,
    required String photoDeniedMessage,
    required String notificationEducationTitle,
    required String notificationEducationMessage,
    required String notificationDeniedTitle,
    required String notificationDeniedMessage,
    required String backgroundEducationTitle,
    required String backgroundEducationMessageAndroid,
    required String backgroundEducationMessageIOS,
    required String backgroundDeniedTitle,
    required String backgroundDeniedMessage,
    required String continueText,
    required String settingsText,
    required String cancelText,
  }) async {
    bool photoGranted = false;
    bool notificationGranted = false;
    bool backgroundGranted = false;

    // Step 1: Request photo access
    if (context.mounted) {
      photoGranted = await requestPhotoAccess(
        context: context,
        educationTitle: photoEducationTitle,
        educationMessage: photoEducationMessage,
        deniedTitle: photoDeniedTitle,
        deniedMessage: photoDeniedMessage,
        continueText: continueText,
        settingsText: settingsText,
        cancelText: cancelText,
      );
    }

    // Step 2: Request notification permission
    if (context.mounted) {
      notificationGranted = await NotificationPermissionHelper.requestNotificationPermission(
        context: context,
        educationTitle: notificationEducationTitle,
        educationMessage: notificationEducationMessage,
        deniedTitle: notificationDeniedTitle,
        deniedMessage: notificationDeniedMessage,
        continueText: continueText,
        settingsText: settingsText,
        cancelText: cancelText,
      );
    }

    // Step 3: Request background task permission (education only)
    if (context.mounted) {
      backgroundGranted = await BackgroundTaskPermissionHelper.requestBackgroundTaskPermission(
        context: context,
        educationTitle: backgroundEducationTitle,
        educationMessageAndroid: backgroundEducationMessageAndroid,
        educationMessageIOS: backgroundEducationMessageIOS,
        deniedTitle: backgroundDeniedTitle,
        deniedMessage: backgroundDeniedMessage,
        continueText: continueText,
        settingsText: settingsText,
        cancelText: cancelText,
      );
    }

    return OnboardingPermissionsResult(
      photoGranted: photoGranted,
      notificationGranted: notificationGranted,
      backgroundGranted: backgroundGranted,
    );
  }
}
