import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';

/// Welcome dialog shown to first-time users explaining why permissions are needed
class WelcomePermissionDialog {
  /// Show the welcome permission dialog
  ///
  /// Returns true if user wants to proceed with permission setup,
  /// false if user somehow dismisses (though dialog is non-dismissible)
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
  }) async {
    final result = await ModernDialog.show(
      context: context,
      type: DialogType.info,
      icon: Icons.photo_library,
      title: title,
      message: message,
      confirmText: buttonText,
      // No cancel button: user must proceed to set up permissions
      cancelText: '',
      barrierDismissible: false,
    );

    return result == true;
  }
}
