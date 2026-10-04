import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_radius.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/core/widgets/dashed_border.dart';
import 'package:photo_manager_app/core/widgets/filter_pill.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_management_feedback.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// Options of the manage sheet.
enum ManageOption {
  /// Save to the cloud and remove from the phone (recommended).
  saveAndFree,

  /// Save to the cloud and keep the phone copy.
  saveAndKeep,

  /// Save into an existing or new album.
  album,
}


/// "What should we do with these photos?" sheet.
class ManageFileModal extends StatefulWidget {

  final List<String> fileIds;
  final bool isMultiple;

  /// Size of the files, shown as "occupy 48 MB" / "Free up 48 MB"; 0 while unknown.
  final int totalSizeBytes;

  /// Preselected option (e.g. from the selection bar).
  final ManageOption initialOption;

  const ManageFileModal({
    super.key,
    required this.fileIds,
    this.isMultiple = false,
    this.totalSizeBytes = 0,
    this.initialOption = ManageOption.saveAndFree,
  });

  /// Opens the sheet with the file management blocs taken from [context].
  /// Completes with `true` when the files were managed.
  static Future<bool?> show(
    BuildContext context, {
    required List<String> fileIds,
    int totalSizeBytes = 0,
    ManageOption initialOption = ManageOption.saveAndFree,
  }) {
    final fileManagementBloc = context.read<FileManagementBloc>();
    final manageFolderBloc = context.read<ManageFolderBloc>();
    return showAppSheet<bool>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: fileManagementBloc),
          BlocProvider.value(value: manageFolderBloc),
        ],
        child: ManageFileModal(
          fileIds: fileIds,
          isMultiple: fileIds.length > 1,
          totalSizeBytes: totalSizeBytes,
          initialOption: initialOption,
        ),
      ),
    );
  }

  @override
  State<ManageFileModal> createState() => _ManageFileModalState();
}


class _ManageFileModalState extends State<ManageFileModal> {

  late ManageOption _option = widget.initialOption;
  String? _selectedFolderId;
  String? _selectedFolderName;
  bool _creatingAlbum = false;
  bool _deleteAfterSaving = true;
  final TextEditingController _newAlbumController = TextEditingController();

  /// Last dispatched action, for retries.
  ManageAction? _lastAction;

  @override
  void initState() {
    super.initState();
    _newAlbumController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newAlbumController.dispose();
    super.dispose();
  }

  /// Action for the selected option, or `null` while it is incomplete.
  ManageAction? get _action {
    switch (_option) {
      case ManageOption.saveAndFree:
        return const ManageAction(serverAction: ServerAction.save, keepOnDevice: false);
      case ManageOption.saveAndKeep:
        return const ManageAction(serverAction: ServerAction.save, keepOnDevice: true);
      case ManageOption.album:
        final keepOnDevice = !_deleteAfterSaving;
        if (_creatingAlbum) {
          final name = _newAlbumController.text.trim();
          if (name.isEmpty) return null;
          return ManageAction(serverAction: ServerAction.newFolder, folderName: name, keepOnDevice: keepOnDevice);
        }
        if (_selectedFolderId == null) return null;
        return ManageAction(serverAction: ServerAction.folder, folderId: _selectedFolderId, keepOnDevice: keepOnDevice);
    }
  }

  /// "48 MB", or `null` while the size is unknown.
  String? _formattedSize(AppLocalizations l10n) => widget.totalSizeBytes > 0
      ? FileSizeFormatter.format(widget.totalSizeBytes, locale: l10n.localeName)
      : null;

  String _primaryLabel(AppLocalizations l10n) {
    switch (_option) {
      case ManageOption.saveAndFree:
        final size = _formattedSize(l10n);
        return size == null ? l10n.optSaveFree : l10n.freeUpSize(size);
      case ManageOption.saveAndKeep:
        return l10n.actionSave;
      case ManageOption.album:
        final name = _creatingAlbum ? _newAlbumController.text.trim() : _selectedFolderName;
        return name == null || name.isEmpty ? l10n.chooseAlbum : l10n.saveToAlbum(name);
    }
  }

  void _dispatchManageEvent(ManageAction action) {
    _lastAction = action;
    context.read<FileManagementBloc>().add(
      ManagedFilesRequested(fileIds: widget.fileIds, action: action)
    );
  }

  Future<void> _confirmDeleteEverywhere(AppLocalizations l10n) async {
    final confirmed = await AppDialog.show(
      context: context,
      icon: Symbols.delete_rounded,
      tone: AppDialogTone.danger,
      title: l10n.deleteFilesTitle(widget.fileIds.length),
      message: l10n.deleteFilesBody,
      primaryLabel: l10n.actionDelete,
      secondaryLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed == true && mounted) {
      _dispatchManageEvent(const ManageAction(serverAction: ServerAction.delete, keepOnDevice: false));
    }
  }

  Future<void> _handleStateChange(BuildContext context, FileManagementState state) async {
    // Only results of actions started from this sheet.
    if (_lastAction == null) return;

    if (state is FileManagementSuccess) {
      // Feedback first, while this sheet's context is still mounted.
      await FileManagementFeedback.showSuccess(context, state);
      if (context.mounted) Navigator.pop(context, true);
    } else if (state is FileManagementPartialSuccess) {
      await FileManagementFeedback.showPartialSuccess(context, state);
      if (context.mounted) Navigator.pop(context, true);
    } else if (state is FileManagementError) {
      FileManagementFeedback.showError(context, state, onRetry: () => _dispatchManageEvent(_lastAction!));
    }
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return BlocConsumer<FileManagementBloc, FileManagementState>(
      listener: _handleStateChange,
      builder: (context, state) {
        final isLoading = state is FileManagementLoading;
        final action = _action;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHeader(fileIds: widget.fileIds, formattedSize: _formattedSize(l10n)),
            const SizedBox(height: 20),
            _OptionCard(
              title: l10n.optSaveFree,
              body: l10n.optSaveFreeBody,
              tag: l10n.recommended,
              selected: _option == ManageOption.saveAndFree,
              onTap: () => setState(() => _option = ManageOption.saveAndFree),
            ),
            const SizedBox(height: 10),
            _OptionCard(
              title: l10n.optSaveKeep,
              body: l10n.optSaveKeepBody,
              selected: _option == ManageOption.saveAndKeep,
              onTap: () => setState(() => _option = ManageOption.saveAndKeep),
            ),
            const SizedBox(height: 10),
            _OptionCard(
              title: l10n.optAlbum,
              body: l10n.optAlbumBody,
              selected: _option == ManageOption.album,
              onTap: () => setState(() => _option = ManageOption.album),
              expanded: _buildAlbumPicker(l10n),
            ),
            const SizedBox(height: 20),
            AppButton.primary(
              label: _primaryLabel(l10n),
              loading: isLoading,
              onPressed: action == null ? null : () => _dispatchManageEvent(action),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: isLoading ? null : () => _confirmDeleteEverywhere(l10n),
              style: TextButton.styleFrom(foregroundColor: p.dangerInk, minimumSize: const Size(44, 48)),
              icon: const Icon(Symbols.delete_rounded, size: 20),
              label: Text(l10n.deleteEverywhere),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlbumPicker(AppLocalizations l10n) {
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        BlocBuilder<ManageFolderBloc, ManageFolderState>(
          builder: (context, state) {
            if (state is ManageFolderStarting) {
              context.read<ManageFolderBloc>().add(const LoadFolders());
            }
            final folders = state is ManageFoldersLoaded ? state.folders : const [];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final folder in folders) ...[
                    FilterPill(
                      label: folder.name,
                      selected: !_creatingAlbum && _selectedFolderId == folder.id,
                      onTap: () => setState(() {
                        _creatingAlbum = false;
                        _selectedFolderId = folder.id;
                        _selectedFolderName = folder.name;
                      }),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (state is ManageFoldersLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  _NewAlbumPill(
                    label: l10n.newAlbumChip,
                    selected: _creatingAlbum,
                    onTap: () => setState(() {
                      _creatingAlbum = true;
                      _selectedFolderId = null;
                      _selectedFolderName = null;
                    }),
                  ),
                ],
              ),
            );
          },
        ),
        if (_creatingAlbum) ...[
          const SizedBox(height: 12),
          AppTextField(
            controller: _newAlbumController,
            hintText: l10n.hintFolderName,
            autofocus: true,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.deleteAfterSaving,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink),
              ),
            ),
            AppSwitch(
              value: _deleteAfterSaving,
              semanticLabel: l10n.deleteAfterSaving,
              onChanged: (value) => setState(() => _deleteAfterSaving = value),
            ),
          ],
        ),
      ],
    );
  }
}


/// Stacked thumbnails, question and selection count.
class _SheetHeader extends StatelessWidget {
  final List<String> fileIds;

  /// "48 MB", or `null` while the size is unknown.
  final String? formattedSize;

  const _SheetHeader({required this.fileIds, this.formattedSize});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final preview = fileIds.take(3).toList();

    return Row(
      children: [
        SizedBox(
          width: 40.0 + (preview.length - 1).clamp(0, 2) * 26,
          height: 40,
          child: Stack(
            children: [
              for (var i = 0; i < preview.length; i++)
                Positioned(
                  left: i * 26.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: p.surface, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AuthenticatedImage(
                      imageUrl: '${DataConstants.backendBaseUrl}/api/file/${preview[i]}/thumbnail/',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.manageQuestion(fileIds.length),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink),
              ),
              const SizedBox(height: 2),
              Text(
                formattedSize == null
                    ? l10n.photosSelected(fileIds.length)
                    : l10n.photosSelectedSize(fileIds.length, formattedSize!),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


/// Radio-like option card.
class _OptionCard extends StatelessWidget {
  final String title;
  final String body;
  final String? tag;
  final bool selected;
  final VoidCallback onTap;

  /// Extra content shown while selected.
  final Widget? expanded;

  const _OptionCard({
    required this.title,
    required this.body,
    this.tag,
    required this.selected,
    required this.onTap,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(20);

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? p.accentSoft.withValues(alpha: 0.5) : p.surface,
          borderRadius: radius,
          border: Border.all(color: selected ? p.accent : p.line, width: selected ? 2 : 1.5),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selected ? Symbols.radio_button_checked_rounded : Symbols.radio_button_unchecked_rounded,
                        size: 22,
                        color: selected ? p.accent : p.ink3,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink)),
                                if (tag != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: p.safeSoft,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text(
                                      tag!,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: p.safeInk),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(body, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: p.ink2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (selected && expanded != null) expanded!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Dashed "+ New" pill of the album picker.
class _NewAlbumPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NewAlbumPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(AppRadius.pill);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? p.ink : p.surface.withValues(alpha: 0),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: DashedBorder(
            radius: 18,
            color: selected ? p.ink : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.add_rounded, size: 18, color: selected ? p.surface : p.accentInk),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? p.surface : p.accentInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
