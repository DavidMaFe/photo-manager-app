import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_album_card.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/dialogs/delete_folder_confirmation_dialog.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/rename_folder_modal.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';
import '../widgets/folder_card.dart';


class FoldersPage extends StatefulWidget {

  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: l10n.navAlbums,
              actions: [
                AppButton.primary(
                  label: l10n.newAlbum,
                  icon: Symbols.add_rounded,
                  size: AppButtonSize.small,
                  onPressed: () => CreateFolderModal.show(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _SearchField(
                controller: _searchController,
                hintText: l10n.searchAlbums,
                onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: BlocConsumer<FolderBloc, FolderState>(
                listener: _handleStateChanges,
                builder: (context, state) {

                  if (state is FolderLoading) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }

                  if (state is FolderLoaded) {
                    return _buildFoldersGrid(context, state);
                  }

                  if (state is FolderError) {
                    return ErrorDisplay(
                      failure: state.failure,
                      onRetry: () => context.read<FolderBloc>().add(const LoadFolders()),
                    );
                  }

                  if (state is FolderOperationLoading) {
                    return _buildOperationLoading(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, FolderState state) {

    if (state is FolderOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
    }
    if (state is FolderOperationError) {
      ErrorNotificationService.showError(
        context,
        state.failure,
        config: ErrorDisplayConfig.snackBar,
        onRetry: () => context.read<FolderBloc>().add(const LoadFolders()),
      );
    }
  }

  Widget _buildFoldersGrid(BuildContext context, FolderLoaded state) {

    final l10n = AppLocalizations.of(context)!;

    if (state.folders.isEmpty) {
      return EmptyState(
        icon: Symbols.photo_album_rounded,
        title: l10n.emptyFolders,
        message: l10n.createFirstFolder,
        actionLabel: l10n.createAlbum,
        actionIcon: Symbols.add_rounded,
        onAction: () => CreateFolderModal.show(context),
      );
    }

    final folders = _query.isEmpty
        ? state.folders
        : state.folders.where((f) => f.name.toLowerCase().contains(_query)).toList();

    if (folders.isEmpty) {
      return EmptyState(icon: Symbols.search_off_rounded, title: l10n.noAlbumsMatch(_searchController.text.trim()));
    }

    // The "create album" card closes the grid, except while searching.
    final showCreateCard = _query.isEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FolderBloc>().add(const RefreshFolders());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Card = square cover + name + meta lines.
          final cellWidth = (constraints.maxWidth - 32 - 14) / 2;
          final textHeight = 8 + MediaQuery.textScalerOf(context).scale(15) * 1.4 + 2 +
              MediaQuery.textScalerOf(context).scale(12) * 1.4;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
              mainAxisExtent: cellWidth + textHeight + 4,
            ),
            itemCount: folders.length + (showCreateCard ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == folders.length) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CreateAlbumCard(label: l10n.createAlbum, onTap: () => CreateFolderModal.show(context)),
                  ),
                );
              }
              final folder = folders[index];
              return FolderCard(
                folder: folder,
                onTap: () => _navigateToFolderContent(context, folder.id),
                onRename: () => RenameFolderModal.show(context, folder),
                onDelete: () => _showDeleteConfirmation(context, folder)
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOperationLoading(BuildContext context, FolderOperationLoading state) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 16),
          Text(_getOperationMessage(state.operation, AppLocalizations.of(context)!), style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.palette.ink2
          ))
        ],
      )
    );
  }

  String _getOperationMessage(String operation, AppLocalizations l10n) {
    switch(operation) {
      case 'create':
        return l10n.creatingFolder;
      case 'rename':
        return l10n.renamingFolder;
      case 'delete':
        return l10n.deletingFolder;
      default:
        return l10n.processing;
    }
  }

  void _navigateToFolderContent(BuildContext context, String folderId) {
    context.pushNamed(
      RouteNames.folderContent,
      pathParameters: {'folderId': folderId},
    );
  }

  void _showDeleteConfirmation(BuildContext context, Folder folder) {
    DeleteFolderConfirmationDialog.show(
      context: context,
      folderName: folder.name,
      filesCount: folder.fileCount > 0 ? folder.fileCount : null,
      subfoldersCount: folder.subfolderCount > 0 ? folder.subfolderCount : null,
      onConfirm: () {
        context.read<FolderBloc>().add(
          DeleteFolderRequested(folderId: folder.id)
        );
      },
    );
  }
}

/// Compact search field (46 high, radius 14, surface2).
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink),
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        prefixIcon: Icon(Symbols.search_rounded, size: 22, color: p.ink3),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 46),
      ),
    );
  }
}
