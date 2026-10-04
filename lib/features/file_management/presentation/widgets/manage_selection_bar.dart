import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/selection_action_bar.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_management_feedback.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Selection action bar of the gallery and albums: Save, To album, Free up
/// and Delete for the selected files.
class ManageSelectionBar extends StatefulWidget {
  final List<String> fileIds;

  /// Size of the selection, shown in the manage sheet; 0 while unknown.
  final int selectedSizeBytes;

  /// Called once the selection has been handled (to leave selection mode).
  final VoidCallback onFinished;

  const ManageSelectionBar({
    super.key,
    required this.fileIds,
    this.selectedSizeBytes = 0,
    required this.onFinished,
  });

  @override
  State<ManageSelectionBar> createState() => _ManageSelectionBarState();
}

class _ManageSelectionBarState extends State<ManageSelectionBar> {

  /// Action dispatched from the bar itself (the sheet handles its own).
  ManageAction? _pendingAction;

  Future<void> _openSheet(ManageOption option) async {
    await ManageFileModal.show(
      context,
      fileIds: widget.fileIds,
      totalSizeBytes: widget.selectedSizeBytes,
      initialOption: option,
    );
    if (mounted) widget.onFinished();
  }

  Future<void> _confirmAndDispatch({
    required ManageAction action,
    required IconData icon,
    required AppDialogTone tone,
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.show(
      context: context,
      icon: icon,
      tone: tone,
      title: title,
      message: message,
      primaryLabel: confirmLabel,
      secondaryLabel: l10n.cancel,
      destructive: destructive,
    );
    if (confirmed == true && mounted) _dispatch(action);
  }

  void _dispatch(ManageAction action) {
    setState(() => _pendingAction = action);
    context.read<FileManagementBloc>().add(ManagedFilesRequested(fileIds: widget.fileIds, action: action));
  }

  Future<void> _handleState(BuildContext context, FileManagementState state) async {
    final action = _pendingAction;
    if (action == null) return;

    if (state is FileManagementSuccess) {
      setState(() => _pendingAction = null);
      await FileManagementFeedback.showSuccess(context, state);
      widget.onFinished();
    } else if (state is FileManagementPartialSuccess) {
      setState(() => _pendingAction = null);
      await FileManagementFeedback.showPartialSuccess(context, state);
      widget.onFinished();
    } else if (state is FileManagementError) {
      setState(() => _pendingAction = null);
      FileManagementFeedback.showError(context, state, onRetry: () => _dispatch(action));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = widget.fileIds.length;
    final enabled = count > 0 && _pendingAction == null;

    return BlocListener<FileManagementBloc, FileManagementState>(
      listener: _handleState,
      child: SelectionActionBar(
        label: l10n.photosCount(count),
        actions: [
          SelectionAction(
            icon: Symbols.cloud_upload_rounded,
            label: l10n.actionSave,
            style: SelectionActionStyle.primary,
            onPressed: enabled ? () => _openSheet(ManageOption.saveAndFree) : null,
          ),
          SelectionAction(
            icon: Symbols.photo_album_rounded,
            label: l10n.actionToAlbum,
            onPressed: enabled ? () => _openSheet(ManageOption.album) : null,
          ),
          SelectionAction(
            icon: Symbols.mobile_off_rounded,
            label: l10n.actionFreeUp,
            onPressed: enabled
                ? () => _confirmAndDispatch(
                      action: const ManageAction(serverAction: ServerAction.save, keepOnDevice: false),
                      icon: Symbols.cloud_upload_rounded,
                      tone: AppDialogTone.accent,
                      title: l10n.freeUpTitle,
                      message: l10n.freeUpBody(count),
                      confirmLabel: l10n.actionFreeUp,
                    )
                : null,
          ),
          SelectionAction(
            icon: Symbols.delete_rounded,
            label: l10n.actionDelete,
            style: SelectionActionStyle.danger,
            onPressed: enabled
                ? () => _confirmAndDispatch(
                      action: const ManageAction(serverAction: ServerAction.delete, keepOnDevice: false),
                      icon: Symbols.delete_rounded,
                      tone: AppDialogTone.danger,
                      title: l10n.deleteFilesTitle(count),
                      message: l10n.deleteFilesBody,
                      confirmLabel: l10n.actionDelete,
                      destructive: true,
                    )
                : null,
          ),
        ],
      ),
    );
  }
}
