import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/local_deletion_warning_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// User feedback for the results of a file management action, shared by the
/// manage sheet and the viewer.
class FileManagementFeedback {

  /// Success snackbar, or the local-files warning when the device copy may remain.
  ///
  /// With [deferWarning] the warning is shown shortly after, once the caller
  /// has closed its sheet; otherwise the returned future completes when the
  /// warning is dismissed.
  static Future<void> showSuccess(
    BuildContext context,
    FileManagementSuccess state, {
    bool deferWarning = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    if (!state.mayHaveLocalFiles) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
      return;
    }

    Future<void> showWarning() => LocalDeletionWarningDialog.show(
          context: context,
          message: '${state.message}\n\n${l10n.filesRemovedFromServerLocalMayRemain}',
          preferencesService: sl<UiPreferencesService>(),
        );

    if (!deferWarning) return showWarning();

    await Future.delayed(const Duration(milliseconds: 100));
    if (context.mounted) await showWarning();
  }

  static void showPartialSuccess(BuildContext context, FileManagementPartialSuccess state) {
    final l10n = AppLocalizations.of(context)!;
    AppDialog.show(
      context: context,
      icon: Symbols.warning_rounded,
      tone: AppDialogTone.review,
      title: l10n.partialManageTitle,
      message: '${l10n.correctManage(state.successCount)} ${l10n.failedManage(state.failedFiles.length)}',
      primaryLabel: l10n.ok,
    );
  }

  static void showError(BuildContext context, FileManagementError state, {VoidCallback? onRetry}) {
    ErrorNotificationService.showError(
      context,
      state.failure,
      config: ErrorDisplayConfig.snackBar,
      onRetry: onRetry,
    );
  }
}
