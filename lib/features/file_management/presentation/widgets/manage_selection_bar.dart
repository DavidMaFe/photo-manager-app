import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/selection_action_bar.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/share_cubit.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_management_feedback.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Selection action bar. In the gallery: Save · Download · Album · Delete · More (Share, Free up). Inside an album:
/// [albumActions] (Favorites, Cover…) · Move · Delete · More (Download, Share).
class ManageSelectionBar extends StatefulWidget {
  final List<String> fileIds;

  /// The selected files, for sharing them (their type and size).
  final List<GalleryFile> files;

  /// Size of the selection, shown in the manage sheet; 0 while unknown.
  final int selectedSizeBytes;

  /// Called once the selection has been handled (to leave selection mode).
  final VoidCallback onFinished;

  /// Album layout: these actions first, then Move and Delete. `null` for the gallery layout.
  final List<SelectionAction>? albumActions;

  /// Optional line above the buttons (e.g. the cover limit in an album).
  final String? label;

  const ManageSelectionBar({
    super.key,
    required this.fileIds,
    this.files = const [],
    this.selectedSizeBytes = 0,
    required this.onFinished,
    this.albumActions,
    this.label,
  });

  @override
  State<ManageSelectionBar> createState() => _ManageSelectionBarState();
}

class _ManageSelectionBarState extends State<ManageSelectionBar> {

  /// Action dispatched from the bar itself (the sheet handles its own).
  ManageAction? _pendingAction;

  /// The selection ends only when the sheet applied something (closing it without acting keeps the selection).
  Future<void> _openSheet(ManageOption option) async {
    final applied = await ManageFileModal.show(
      context,
      fileIds: widget.fileIds,
      totalSizeBytes: widget.selectedSizeBytes,
      initialOption: option,
    );
    if (applied == true && mounted) widget.onFinished();
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

  void _download() {
    context.read<DownloadProgressBloc>().add(DownloadFilesRequested(widget.fileIds.toSet()));
    widget.onFinished();
  }

  void _share() {
    context.read<ShareCubit>().share([
      for (final file in widget.files)
        RemoteMediaFile(id: file.id, type: file.type, sizeBytes: file.sizeBytes),
    ]);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = widget.fileIds.length;
    final enabled = count > 0 && _pendingAction == null;

    final download = SelectionMenuItem(icon: Symbols.download_rounded, label: l10n.actionDownload, onSelected: _download);
    final share = SelectionMenuItem(icon: Symbols.share_rounded, label: l10n.actionShare, onSelected: _share);
    final delete = SelectionAction(
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
    );

    return BlocListener<FileManagementBloc, FileManagementState>(
      listener: _handleState,
      child: SelectionActionBar(
        label: widget.label,
        actions: [
          if (widget.albumActions case final albumActions?) ...[
            ...albumActions,
            SelectionAction(
              icon: Symbols.drive_file_move_rounded,
              label: l10n.move,
              onPressed: enabled ? () => _openSheet(ManageOption.album) : null,
            ),
            delete,
            SelectionAction(
              icon: Symbols.more_horiz_rounded,
              label: l10n.actionMore,
              onPressed: enabled ? () {} : null,
              menu: [download, share],
            ),
          ] else ...[
            SelectionAction(
              icon: Symbols.cloud_upload_rounded,
              label: l10n.actionSave,
              style: SelectionActionStyle.primary,
              onPressed: enabled ? () => _openSheet(ManageOption.saveAndFree) : null,
            ),
            SelectionAction(
              icon: Symbols.download_rounded,
              label: l10n.actionDownload,
              onPressed: enabled ? _download : null,
            ),
            SelectionAction(
              icon: Symbols.photo_album_rounded,
              label: l10n.actionToAlbum,
              onPressed: enabled ? () => _openSheet(ManageOption.album) : null,
            ),
            delete,
            SelectionAction(
              icon: Symbols.more_horiz_rounded,
              label: l10n.actionMore,
              onPressed: enabled ? () {} : null,
              menu: [
                share,
                SelectionMenuItem(
                  icon: Symbols.mobile_off_rounded,
                  label: l10n.actionFreeUp,
                  onSelected: () => _confirmAndDispatch(
                    action: const ManageAction(serverAction: ServerAction.save, keepOnDevice: false),
                    icon: Symbols.cloud_upload_rounded,
                    tone: AppDialogTone.accent,
                    title: l10n.freeUpTitle,
                    message: l10n.freeUpBody(count),
                    confirmLabel: l10n.actionFreeUp,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
