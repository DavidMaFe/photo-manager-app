import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/dialogs/delete_folder_confirmation_dialog.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/rename_folder_modal.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';
import '../widgets/folder_card.dart';


class FoldersPage extends StatelessWidget {

  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.folders),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: BlocConsumer<FolderBloc, FolderState>(
        listener: _handleStateChanges,
        builder: (context, state) {

          if (state is FolderLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2)
            );
          }

          if (state is FolderLoaded) {
            return _buildFoldersGrid(context, state);
          }

          if (state is FolderError) {
            return _buildErrorState(context, state, l10n);
          }

          if (state is FolderOperationLoading) {
            return _buildOperationLoading(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFAB(context, l10n),
    );
  }

  void _handleStateChanges(BuildContext context, FolderState state) {

    if (state is FolderOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(state.message)
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
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

    if (state.folders.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FolderBloc>().add(const RefreshFolders());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2
        ),
        itemCount: state.folders.length,
        itemBuilder: (context, index) {
          final folder = state.folders[index];
          return FolderCard(
            folder: folder,
            onTap: () => _navigateToFolderContent(context, folder.id),
            onRename: () => _showRenameModal(context, folder),
            onDelete: () => _showDeleteConfirmation(context, folder)
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, FolderError state, AppLocalizations l10n) {
    return ErrorDisplay(
      failure: state.failure,
      onRetry: () => context.read<FolderBloc>().add(const LoadFolders()),
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
            color: Colors.grey.shade600
          ))
        ],
      )
    );
  }

  Widget _buildFAB(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton(
      onPressed: () => _showCreateModal(context),
      backgroundColor: PhotoManagerColors.primary,
      child: const Icon(Icons.add, color: Colors.white)
    );
  }

  Widget _buildEmptyState(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyFolders,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstFolder,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
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

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<FolderBloc>(),
        child: const CreateFolderModal(),
      )
    );
  }

  void _showRenameModal(BuildContext context, Folder folder) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => BlocProvider.value(
          value: context.read<FolderBloc>(),
          child: RenameFolderModal(folder: folder),
        )
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