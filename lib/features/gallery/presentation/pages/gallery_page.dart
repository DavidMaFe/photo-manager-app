import 'package:photo_manager_app/core/navigation/shell_selection_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/filter_pill.dart';
import 'package:photo_manager_app/core/widgets/media_grid_skeleton.dart';
import 'package:photo_manager_app/core/widgets/user_avatar.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_selection_bar.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/backup_status_chip.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/file_filter_label.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/files_grid.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/gallery_top_bar.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/pending_review_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class GalleryPage extends StatelessWidget {

  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<GalleryBloc, GalleryState>(
        listener: _handleStateChanges,
        builder: (context, state) {

          final isSelectionMode = state is GalleryLoaded && state.isSelectionMode;
          final selectedCount = isSelectionMode ? state.selectedFileIds.length : 0;
          final areAllFilesSelected = state is GalleryLoaded && state.areAllFilesSelected;

          return ReportSelectionMode(
            active: isSelectionMode,
            child: Scaffold(
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Always at index 0 — height is 0 when not refreshing.
                    // A conditional `if` would shift the indices of all siblings,
                    // causing FilesGrid to be recreated and losing the scroll position.
                    SizedBox(
                      height: (state is GalleryLoaded && state.isRefreshing) ? 2 : 0,
                      child: LinearProgressIndicator(
                        backgroundColor: context.palette.background,
                        color: context.palette.accent,
                      ),
                    ),
                    GalleryTopBar(
                      isSelectionMode: isSelectionMode,
                      selectedCount: selectedCount,
                      areAllFilesSelected: areAllFilesSelected,
                      actions: [
                        BackupStatusChip(onTap: () => context.go(RoutePaths.sync)),
                        _buildAvatar(context),
                      ],
                      onCancelSelection: () {
                        context.read<GalleryBloc>().add(const ExitSelectionMode());
                      },
                      onSelectAll: () {
                        context.read<GalleryBloc>().add(const SelectAllFiles());
                      },
                      onDeselectAll: () {
                        context.read<GalleryBloc>().add(const ClearSelection());
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilters(context, state),
                    const SizedBox(height: 8),
                    Expanded(child: _buildContent(context, state))
                  ],
                ),
              ),
              bottomNavigationBar: isSelectionMode
                  ? ManageSelectionBar(
                      fileIds: state.selectedFileIds.toList(),
                      selectedSizeBytes: state.selectedSizeBytes,
                      onFinished: () => context.read<GalleryBloc>().add(const ExitSelectionMode()),
                    )
                  : null,
            ),
          );
        }
    );
  }

  /// Manage sheet with every pending file selected by [ReviewPendingFiles].
  Future<void> _openReviewSheet(BuildContext context, List<String> fileIds, int totalSizeBytes) async {
    final bloc = context.read<GalleryBloc>();
    await ManageFileModal.show(context, fileIds: fileIds, totalSizeBytes: totalSizeBytes);
    bloc.add(const ExitSelectionMode());
  }

  Widget _buildAvatar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccessful ? state.user : null;
        return UserAvatar(
          name: user?.name ?? '',
          surname: user?.surname,
          semanticLabel: l10n.openProfile,
          onTap: () => context.go(RoutePaths.profile),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, GalleryState state) {
    if (state is GalleryLoaded && state.reviewRequested) {
      _openReviewSheet(context, state.selectedFileIds.toList(), state.selectedSizeBytes);
    }

    // GalleryError is handled by the full-page ErrorDisplay in _buildContent.
    // No snackbar here to avoid showing two error surfaces simultaneously.
    if (state is GalleryLoaded && state.selectionLimitReached) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectionLimitReached),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildFilters(BuildContext context, GalleryState state) {

    FileFilter currentFilter = FileFilter.all;

    if (state is GalleryLoading) {
      currentFilter = state.filter;
    } else if (state is GalleryLoaded) {
      currentFilter = state.filter;
    } else if (state is GalleryLoadingMore) {
      currentFilter = state.filter;
    }

    final l10n = AppLocalizations.of(context)!;
    final pendingCount = switch (state) {
      GalleryLoaded() => state.pendingCount,
      GalleryLoadingMore() => state.pendingCount,
      _ => 0,
    };

    return FilterPillBar<FileFilter>(
      items: [
        for (final filter in FileFilter.values)
          FilterPillItem(
            value: filter,
            label: filter.label(l10n),
            count: filter == FileFilter.pending ? pendingCount : null,
          ),
      ],
      selected: currentFilter,
      onSelected: (filter) {
        context.read<GalleryBloc>().add(LoadGallery(filter: filter));
      },
    );
  }

  Widget _buildContent(BuildContext context, GalleryState state) {

    if (state is GalleryStarting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GalleryBloc>().add(const LoadGallery());
      });
      return const MediaGridSkeleton();
    }

    if (state is GalleryLoading) {
      return const MediaGridSkeleton();
    }

    if (state is GalleryLoaded) {
      return _buildGrid(context, state);
    }

    if (state is GalleryLoadingMore) {
      return _buildGrid(context, state);
    }

    if (state is GalleryError) {
      return ErrorDisplay(
        failure: state.failure,
        onRetry: () => context.read<GalleryBloc>().add(const LoadGallery()),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGrid(BuildContext context, dynamic state) {

    List<GalleryFile> files = [];
    List<FileDateGroup> groupedFiles = [];
    bool hasNext = false;
    bool isLoadingMore = false;
    bool isSelectionMode = false;
    Set<String> selectedFileIds = {};
    int totalFilesCount = 0;
    int pendingCount = 0;
    FileFilter filter = FileFilter.all;

    if (state is GalleryLoaded) {
      files = state.files;
      groupedFiles = state.groupedFiles;
      hasNext = state.hasNext;
      isLoadingMore = false;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
      totalFilesCount = state.totalFilesCount;
      pendingCount = state.pendingCount;
      filter = state.filter;
    } else if (state is GalleryLoadingMore) {
      files = state.files;
      groupedFiles = state.groupedFiles;
      hasNext = true;
      isLoadingMore = true;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
      totalFilesCount = state.totalFilesCount;
      pendingCount = state.pendingCount;
      filter = state.filter;
    }

    final l10n = AppLocalizations.of(context)!;

    return FilesGrid(
      groupedFiles: groupedFiles,
      hasNext: hasNext,
      isLoadingMore: isLoadingMore,
      isSelectionMode: isSelectionMode,
      selectedFileIds: selectedFileIds,
      onLoadMore: () {
        context.read<GalleryBloc>().add(const LoadMoreFiles());
      },
      onRefresh: () {
        context.read<GalleryBloc>().add(const RefreshGallery());
      },
      onSelect: () {
        context.read<GalleryBloc>().add(const EnterSelectionMode());
      },
      leading: [
        if (!isSelectionMode && filter != FileFilter.pending)
          SliverToBoxAdapter(
            child: PendingReviewCard(
              pendingCount: pendingCount,
              onReview: () => context.read<GalleryBloc>().add(const ReviewPendingFiles()),
            ),
          ),
      ],
      emptyState: filter == FileFilter.all
          ? EmptyState(
              icon: Symbols.photo_library_rounded,
              title: l10n.noPhotosYet,
              message: l10n.noPhotosBody,
              actionLabel: l10n.backupNow,
              actionIcon: Symbols.sync_rounded,
              onAction: () => context.go(RoutePaths.sync),
            )
          : EmptyState(
              icon: Symbols.filter_alt_off_rounded,
              title: l10n.noFiles,
            ),
      onFileTap: (file) {
        if (isSelectionMode) {
          context.read<GalleryBloc>().add(ToggleFileSelection(file.id));
        } else {
          final fileIndex = files.indexWhere((f) => f.id == file.id);

          context.pushNamed(
            RouteNames.fileDetail,
            pathParameters: {'fileId': file.id},
            extra: {
              'files': files,
              'initialIndex': fileIndex,
              'totalFilesCount': totalFilesCount
            }
          );
        }
      },
      onFileLongPress: (file) {
        if (!isSelectionMode) {
          context.read<GalleryBloc>().add(const EnterSelectionMode());
        }
        context.read<GalleryBloc>().add(ToggleFileSelection(file.id));
      },
    );
  }
}