import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_state.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_action_buttons.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_empty_state.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_files_grid.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../widgets/dialogs/empty_trash_confirmation_dialog.dart';
import '../widgets/dialogs/permanent_delete_confirmation_dialog.dart';
import '../widgets/dialogs/restore_confirmation_dialog.dart';

class TrashPage extends StatelessWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TrashBloc>(),
      child: const _TrashPageContent(),
    );
  }
}

class _TrashPageContent extends StatelessWidget {
  const _TrashPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrashBloc, TrashState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final isSelectionMode = state is TrashLoaded && state.isSelectionMode;
        final selectedCount = isSelectionMode ? state.selectedCount : 0;

        return Scaffold(
          appBar: TrashHeader(
            isSelectionMode: isSelectionMode,
            selectedCount: selectedCount,
            onCancelSelection: () {
              context.read<TrashBloc>().add(const ExitSelectionMode());
            },
            onEmptyTrash: () => _showEmptyTrashDialog(context),
          ),
          body: _buildContent(context, state),
          floatingActionButton: _buildFAB(context, state),
        );
      },
    );
  }

  Widget? _buildFAB(BuildContext context, TrashState state) {
    if (state is! TrashLoaded || !state.isSelectionMode) {
      return null;
    }

    final selectedCount = state.selectedCount;

    if (selectedCount == 0) {
      return null;
    }

    return TrashActionButtons(
      selectedCount: selectedCount,
      onRestore: () => _showRestoreDialog(context, selectedCount),
      onDelete: () => _showDeleteDialog(context, selectedCount),
    );
  }

  void _handleStateChanges(BuildContext context, TrashState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is TrashError) {
      ErrorNotificationService.showError(
        context,
        state.failure,
        config: ErrorDisplayConfig.snackBar,
        onRetry: () => context.read<TrashBloc>().add(const LoadTrash()),
      );
    }

    if (state is TrashRestoreSuccess) {
      ErrorNotificationService.showSuccess(
        context,
        l10n.filesRestoredSuccessfully(state.restoredCount),
      );
    }

    if (state is TrashRestoreError) {
      ErrorNotificationService.showError(
        context,
        state.failure,
        config: ErrorDisplayConfig.snackBar,
      );
    }

    if (state is TrashDeleteSuccess) {
      ErrorNotificationService.showSuccess(
        context,
        l10n.filesDeletedPermanently(state.deletedCount),
      );
    }

    if (state is TrashDeleteError) {
      ErrorNotificationService.showError(
        context,
        state.failure,
        config: ErrorDisplayConfig.snackBar,
      );
    }
  }

  Widget _buildContent(BuildContext context, TrashState state) {
    if (state is TrashInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TrashBloc>().add(const LoadTrash());
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TrashLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state is TrashLoaded || state is TrashLoadingMore) {
      return _buildGrid(context, state);
    }

    if (state is TrashRestoring || state is TrashDeleting) {
      return _buildGrid(context, state);
    }

    if (state is TrashError) {
      return ErrorDisplay(
        failure: state.failure,
        onRetry: () => context.read<TrashBloc>().add(const LoadTrash()),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGrid(BuildContext context, dynamic state) {
    List<TrashFile> files = [];
    bool hasNext = false;
    bool isLoadingMore = false;
    bool isSelectionMode = false;
    Set<String> selectedFileIds = {};
    bool isProcessing = false;

    if (state is TrashLoaded) {
      files = state.files;
      hasNext = state.hasNext;
      isLoadingMore = false;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
      isProcessing = false;
    } else if (state is TrashLoadingMore) {
      files = state.files;
      hasNext = true;
      isLoadingMore = true;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
      isProcessing = false;
    } else if (state is TrashRestoring || state is TrashDeleting) {
      final loadedState = state as TrashLoaded;
      files = loadedState.files;
      hasNext = loadedState.hasNext;
      isLoadingMore = false;
      isSelectionMode = loadedState.isSelectionMode;
      selectedFileIds = loadedState.selectedFileIds;
      isProcessing = true;
    }

    // Show empty state if no files
    if (files.isEmpty && !isLoadingMore) {
      return const TrashEmptyState();
    }

    return TrashFilesGrid(
      files: files,
      hasNext: hasNext,
      isLoadingMore: isLoadingMore,
      isSelectionMode: isSelectionMode,
      selectedFileIds: selectedFileIds,
      isProcessing: isProcessing,
      onLoadMore: () {
        context.read<TrashBloc>().add(const LoadMoreTrash());
      },
      onRefresh: () {
        context.read<TrashBloc>().add(const RefreshTrash());
      },
      onFileTap: (file) {
        if (isSelectionMode) {
          context.read<TrashBloc>().add(ToggleFileSelection(file.id));
        } else {
          // Navigate to file detail
          final fileIndex = files.indexWhere((f) => f.id == file.id);
          context.pushNamed(
            RouteNames.trashFileDetail,
            pathParameters: {'fileId': file.id},
            extra: {
              'files': files,
              'initialIndex': fileIndex
            }
          );
        }
      },
      onFileLongPress: (file) {
        if (!isSelectionMode) {
          context.read<TrashBloc>().add(const EnterSelectionMode());
        }
        context.read<TrashBloc>().add(ToggleFileSelection(file.id));
      },
    );
  }

  void _showRestoreDialog(BuildContext context, int count) {
    RestoreConfirmationDialog.show(
      context: context,
      fileCount: count,
      onConfirm: () {
        context.read<TrashBloc>().add(const RestoreSelectedFiles());
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int count) {
    PermanentDeleteConfirmationDialog.show(
      context: context,
      fileCount: count,
      onConfirm: () {
        context.read<TrashBloc>().add(const PermanentlyDeleteSelectedFiles());
      },
    );
  }

  void _showEmptyTrashDialog(BuildContext context) {
    final state = context.read<TrashBloc>().state;
    if (state is! TrashLoaded || state.files.isEmpty) return;

    EmptyTrashConfirmationDialog.show(
      context: context,
      onConfirm: () {
        context.read<TrashBloc>().add(const EmptyTrashRequested());
      },
    );
  }
}
