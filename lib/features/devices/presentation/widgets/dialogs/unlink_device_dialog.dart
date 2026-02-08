import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class UnlinkDeviceDialog {
  static Future<void> show({
    required BuildContext context,
    required String deviceName,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await ModernDialog.show(
      context: context,
      type: DialogType.danger,
      icon: Icons.link_off,
      title: l10n.unlinkDevice,
      message: l10n.unlinkDeviceConfirmation(deviceName),
      cancelText: l10n.cancel,
      confirmText: l10n.unlinkDevice,
    );

    if (result == true) {
      onConfirm();
    }
  }
}
