import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class EmptyTrashConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const EmptyTrashConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await ModernDialog.show(
      context: context,
      type: DialogType.danger,
      icon: Icons.delete_sweep,
      title: l10n.emptyTrash,
      message: l10n.emptyTrashConfirmation,
      cancelText: l10n.cancel,
      confirmText: l10n.emptyTrash,
    );

    if (result == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget is now just a wrapper for backwards compatibility
    // Use EmptyTrashConfirmationDialog.show() instead
    return const SizedBox.shrink();
  }
}
