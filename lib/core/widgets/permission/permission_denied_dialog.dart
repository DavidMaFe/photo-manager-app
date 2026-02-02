import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager/photo_manager.dart';

/// Dialog shown when user denies a permission
/// Explains the consequences and offers to open app settings
class PermissionDeniedDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String settingsText,
    required String cancelText,
  }) async {
    final result = await ModernDialog.show(
      context: context,
      type: DialogType.warning,
      icon: Icons.warning_amber,
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: settingsText,
    );

    if (result == true) {
      await PhotoManager.openSetting();
    }
  }

  static Future<void> showPhotoAccessDenied({
    required BuildContext context,
    required String title,
    required String message,
    required String settingsText,
    required String cancelText,
  }) async {
    await show(
      context: context,
      title: title,
      message: message,
      settingsText: settingsText,
      cancelText: cancelText,
    );
  }

  static Future<void> showPermanentlyDenied({
    required BuildContext context,
    required String title,
    required String message,
    required String settingsText,
    required String cancelText,
  }) async {
    final result = await ModernDialog.show(
      context: context,
      type: DialogType.danger,
      icon: Icons.block,
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: settingsText,
    );

    if (result == true) {
      await PhotoManager.openSetting();
    }
  }
}
