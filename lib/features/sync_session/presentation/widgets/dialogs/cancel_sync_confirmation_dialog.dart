import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class CancelSyncConfirmationDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await ModernDialog.show(
      context: context,
      type: DialogType.warning,
      icon: Icons.sync_disabled,
      title: l10n.syncSessionCancelWarning,
      message: l10n.syncSessionCancelDescription,
      cancelText: l10n.cancel,
      confirmText: l10n.syncSessionCancelConfirm,
    );

    if (result == true) {
      onConfirm();
    }
  }
}
