import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';

/// Educational dialog shown before requesting system permissions
/// Explains why the permission is needed and what benefits it provides
class PermissionEducationDialog {
  static Future<bool> showPhotoAccess({
    required BuildContext context,
    required String title,
    required String message,
    required String continueText,
    required String cancelText,
  }) async {
    final result = await ModernDialog.show(
      context: context,
      type: DialogType.info,
      icon: Icons.photo_library,
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: continueText,
    );

    return result == true;
  }

  static Future<bool> showCameraAccess({
    required BuildContext context,
    required String title,
    required String message,
    required String continueText,
    required String cancelText,
  }) async {
    final result = await ModernDialog.show(
      context: context,
      type: DialogType.info,
      icon: Icons.camera_alt,
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: continueText,
    );

    return result == true;
  }

  static Future<bool> showStorageAccess({
    required BuildContext context,
    required String title,
    required String message,
    required String continueText,
    required String cancelText,
  }) async {
    final result = await ModernDialog.show(
      context: context,
      type: DialogType.info,
      icon: Icons.folder,
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: continueText,
    );

    return result == true;
  }
}
