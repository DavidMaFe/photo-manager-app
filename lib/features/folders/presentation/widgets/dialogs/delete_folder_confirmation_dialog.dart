import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class DeleteFolderConfirmationDialog {
  static Future<void> show({
    required BuildContext context,
    required String folderName,
    int? filesCount,
    int? subfoldersCount,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Build dynamic message based on folder content
    String message;
    if (filesCount == null && subfoldersCount == null) {
      // Empty folder
      message = l10n.deleteEmptyFolder(folderName);
    } else if (filesCount != null && subfoldersCount != null) {
      // Has both files and subfolders
      message = l10n.deleteFolderWithFilesAndSubfoldersWarning(
        folderName,
        filesCount,
        subfoldersCount,
      );
    } else if (filesCount != null) {
      // Has only files
      message = l10n.deleteFolderWithFiles(folderName, filesCount);
    } else {
      // Has only subfolders
      message = l10n.deleteFolderWithSubfolders(folderName, subfoldersCount!);
    }

    final result = await ModernDialog.show(
      context: context,
      type: DialogType.danger,
      icon: Icons.folder_delete,
      title: l10n.deleteFolder,
      message: message,
      cancelText: l10n.cancel,
      confirmText: l10n.delete,
    );

    if (result == true) {
      onConfirm();
    }
  }
}
