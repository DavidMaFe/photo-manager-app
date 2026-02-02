import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class RestoreConfirmationDialog extends StatelessWidget {
  final int fileCount;
  final VoidCallback onConfirm;

  const RestoreConfirmationDialog({
    super.key,
    required this.fileCount,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required int fileCount,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await ModernDialog.show(
      context: context,
      type: DialogType.success,
      icon: Icons.restore,
      title: fileCount == 1 ? l10n.restore : l10n.restoreFiles(fileCount),
      message: fileCount == 1
          ? l10n.restoreFileConfirmation
          : l10n.restoreFilesConfirmation(fileCount),
      cancelText: l10n.cancel,
      confirmText: l10n.restore,
    );

    if (result == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget is now just a wrapper for backwards compatibility
    // Use RestoreConfirmationDialog.show() instead
    return const SizedBox.shrink();
  }
}
