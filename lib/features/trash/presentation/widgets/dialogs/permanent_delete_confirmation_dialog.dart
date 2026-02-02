import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class PermanentDeleteConfirmationDialog extends StatelessWidget {
  final int fileCount;
  final VoidCallback onConfirm;

  const PermanentDeleteConfirmationDialog({
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
      type: DialogType.danger,
      icon: Icons.delete_forever,
      title: l10n.deletePermanently,
      message: fileCount == 1
          ? l10n.deletePermanentlyConfirmation
          : l10n.deleteFilesPermanentlyConfirmation(fileCount),
      cancelText: l10n.cancel,
      confirmText: l10n.delete,
    );

    if (result == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget is now just a wrapper for backwards compatibility
    // Use PermanentDeleteConfirmationDialog.show() instead
    return const SizedBox.shrink();
  }
}
