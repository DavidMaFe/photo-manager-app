import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/files_grid.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/filter_chips.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../widgets/pending_info_banner.dart';


class GalleryPage extends StatelessWidget {

  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<GalleryBloc, GalleryState>(
        listener: _handleStateChanges,
        builder: (context, state) {

          final isSelectionMode = state is GalleryLoaded && state.isSelectionMode;
          final selectedCount = isSelectionMode ? state.selectedFileIds.length : 0;

          return Scaffold(
            appBar: GalleryHeader(
              isSelectionMode: isSelectionMode,
              selectedCount: selectedCount,
              onCancelSelection: () {
                context.read<GalleryBloc>().add(const ExitSelectionMode());
              },
              onSelectAll: () {
                //context.read<GalleryBloc>().add(const SelectAllFiles());
              },
            ),
            body: Column(
              children: [
                _buildFilters(context, state),
                _buildPendingBanner(state),
                Expanded(child: _buildContent(context, state))
              ],
            ),
            floatingActionButton: _buildFAB(context, state),
          );
        }
    );
  }

  Widget? _buildFAB(BuildContext context, GalleryState state) {

    if (state is! GalleryLoaded || !state.isSelectionMode) {
      return null;
    }

    final selectedCount = state.selectedFileIds.length;

    if (selectedCount == 0) {
      return null;
    }

    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PhotoManagerColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showManageModal(context, state.selectedFileIds.toList()),
        backgroundColor: PhotoManagerColors.primary,
        elevation: 0,
        icon: const Icon(Icons.tune, size: 22, color: Colors.white),
        label: Row(
          children: [
            Text(
              selectedCount == 1 ? l10n.manageSingleFile : l10n.manageMultipleFiles(selectedCount),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 15
              )
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  void _showManageModal(BuildContext context, List<String> fileIds) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<FileManagementBloc>()),
          BlocProvider.value(value: context.read<ManageFolderBloc>())
        ],
        child: ManageFileModal(fileIds: fileIds, isMultiple: fileIds.length > 1),
      )
    ).then((_) {
      if (!context.mounted) return;
      context.read<GalleryBloc>().add(const ExitSelectionMode());
    });
  }

  void _handleStateChanges(BuildContext context, GalleryState state) {
    // TODO: Implementar al final
    if (state is GalleryError) {}
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

    return FilterChips(
      selectedFilter: currentFilter,
      onFilterSelected: (filter) {
        context.read<GalleryBloc>().add(LoadGallery(filter: filter));
      },
    );
  }

  Widget _buildPendingBanner(GalleryState state) {

    int pendingCount = 0;

    if (state is GalleryLoaded) {
      pendingCount = state.pendingCount;
    } else if (state is GalleryLoadingMore) {
      pendingCount = state.pendingCount;
    }

    return PendingInfoBanner(pendingCount: pendingCount);
  }

  Widget _buildContent(BuildContext context, GalleryState state) {

    if (state is GalleryStarting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GalleryBloc>().add(const LoadGallery());
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GalleryLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state is GalleryLoaded) {
      return _buildGrid(context, state);
    }

    if (state is GalleryLoadingMore) {
      return _buildGrid(context, state);
    }

    if (state is GalleryError) {
      // TODO: Implementar después
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  Widget _buildGrid(BuildContext context, dynamic state) {

    List<GalleryFile> files = [];
    bool hasNext = false;
    bool isLoadingMore = false;
    bool isSelectionMode = false;
    Set<String> selectedFileIds = {};

    if (state is GalleryLoaded) {
      files = state.files;
      hasNext = state.hasNext;
      isLoadingMore = false;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
    } else if (state is GalleryLoadingMore) {
      files = state.files;
      hasNext = true;
      isLoadingMore = true;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
    }

    return FilesGrid(
      files: files,
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
              'initialIndex': fileIndex
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