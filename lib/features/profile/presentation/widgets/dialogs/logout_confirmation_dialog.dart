import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class LogoutConfirmationDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await ModernDialog.show(
      context: context,
      type: DialogType.warning,
      icon: Icons.logout,
      title: l10n.logoutButton,
      message: l10n.logoutConfirmation,
      cancelText: l10n.cancel,
      confirmText: l10n.logoutButton,
    );

    if (result == true) {
      onConfirm();
    }
  }
}
