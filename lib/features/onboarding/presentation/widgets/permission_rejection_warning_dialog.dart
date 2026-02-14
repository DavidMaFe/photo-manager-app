import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';

/// Warning dialog shown when users deny some onboarding permissions
class PermissionRejectionWarningDialog {
  /// Show the permission rejection warning dialog
  ///
  /// [limitations] is a formatted string listing the features that won't work
  /// without the denied permissions
  ///
  /// Returns the user's choice:
  /// - true: User wants to retry permission requests
  /// - false: User understands and wants to continue with limited functionality
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String retryButtonText,
    required String continueButtonText,
  }) async {
    final result = await ModernDialog.show(
      context: context,
      type: DialogType.warning,
      icon: Icons.warning_amber,
      title: title,
      message: message,
      cancelText: continueButtonText,
      confirmText: retryButtonText,
      barrierDismissible: false, // User must make a choice
    );

    // Result is true if user clicked retry (confirm button)
    // Result is false if user clicked continue (cancel button)
    return result == true;
  }
}
