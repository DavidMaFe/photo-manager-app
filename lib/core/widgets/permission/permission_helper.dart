import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_denied_dialog.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_education_dialog.dart';

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
}
