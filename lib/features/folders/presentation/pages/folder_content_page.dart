import 'package:photo_manager_app/core/navigation/shell_selection_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_context_menu.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/filter_pill.dart';
import 'package:photo_manager_app/core/widgets/icon_circle_button.dart';
import 'package:photo_manager_app/core/widgets/media_grid_skeleton.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/core/widgets/selection_header.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_selection_bar.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/breadcrumbs_bar.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/subfolders_section.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/file_filter_label.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/files_grid.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/folder_card.dart';


class FolderContentPage extends StatelessWidget {

  /// Filters offered inside an album ("to review" only applies to the gallery).
  static const filters = [FileFilter.all, FileFilter.images, FileFilter.videos];

  final String folderId;

  const FolderContentPage({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<FolderContentBloc, FolderContentState>(
      listener: (context, state) {
        if (state is FolderContentLoaded && state.selectionLimitReached) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.selectionLimitReached),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {

        final isSelectionMode = state is FolderContentLoaded && state.isSelectionMode;
        final selectedCount = isSelectionMode ? state.selectedFileIds.length : 0;

        return ReportSelectionMode(
          active: isSelectionMode,
          child: Scaffold(
            appBar: isSelectionMode ? null : _buildTopBar(context),
            body: SafeArea(
              top: isSelectionMode,
              bottom: false,
              child: Column(
                children: [
                  if (isSelectionMode) _buildSelectionHeader(context, state, selectedCount),
                  // Always present — height is 0 when not refreshing.
                  // A conditional `if` would shift the indices of all siblings,
                  // causing the scroll view to be remounted and losing scroll position.
                  SizedBox(
                    height: (state is FolderContentLoaded && state.isRefreshing) ? 2 : 0,
                    child: LinearProgressIndicator(
                      backgroundColor: context.palette.background,
                      color: context.palette.accent,
                    ),
                  ),
                  Expanded(child: _buildMainContent(context, state))
                ],
              ),
            ),
            bottomNavigationBar: isSelectionMode
                ? ManageSelectionBar(
                    fileIds: state.selectedFileIds.toList(),
                    selectedSizeBytes: state.selectedSizeBytes,
                    onFinished: () => context.read<FolderContentBloc>().add(const ExitSelectionMode()),
                  )
                : null,
          ),
        );
      }
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return SecondaryTopBar(
      onBack: () => context.pop(),
      actions: [
        Builder(
          builder: (buttonContext) => IconCircleButton(
            icon: Symbols.more_vert_rounded,
            tooltip: l10n.moreOptions,
            onPressed: () => _showMoreMenu(buttonContext),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionHeader(BuildContext context, FolderContentLoaded state, int selectedCount) {

    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<FolderContentBloc>();

    return SelectionHeader(
      title: l10n.selectedCount(selectedCount),
      closeTooltip: l10n.closeSelection,
      onClose: () => bloc.add(const ExitSelectionMode()),
      toggleLabel: state.areAllFilesSelected ? l10n.selectNone : l10n.selectAllShort,
      onToggle: () => bloc.add(state.areAllFilesSelected ? const DeselectAllFiles() : const SelectAllFiles()),
    );
  }

  Future<void> _showMoreMenu(BuildContext buttonContext) async {
    final l10n = AppLocalizations.of(buttonContext)!;
    final box = buttonContext.findRenderObject() as RenderBox;
    final position = box.localToGlobal(box.size.bottomRight(Offset.zero));

    final action = await showAppContextMenu<String>(
      buttonContext,
      position: position,
      items: [
        AppMenuItem(value: 'subalbum', label: l10n.newSubalbum, icon: Symbols.create_new_folder_rounded),
      ],
    );
    if (action == 'subalbum' && buttonContext.mounted) {
      CreateFolderModal.show(buttonContext, parentFolderId: folderId);
    }
  }

  Widget _buildMainContent(BuildContext context, FolderContentState state) {

    if (state is FolderContentLoaded) {
      return _buildContent(
        context,
        folder: state.currentFolder,
        subfolders: state.subfolders,
        files: state.files,
        groupedFiles: state.groupedFiles,
        totalFilesCount: state.totalFilesCount,
        filter: state.currentFilter,
        hasMoreFiles: state.hasMoreFiles,
        isLoadingMore: false,
        isSelectionMode: state.isSelectionMode,
        selectedFileIds: state.selectedFileIds,
      );
    }

    if (state is FolderContentLoadingMore) {
      return _buildContent(
        context,
        folder: state.currentFolder,
        subfolders: state.subfolders,
        files: state.files,
        groupedFiles: state.groupedFiles,
        totalFilesCount: state.totalFilesCount,
        filter: state.currentFilter,
        hasMoreFiles: true,
        isLoadingMore: true,
        isSelectionMode: false,
        selectedFileIds: const {},
      );
    }

    if (state is FolderContentError) {
      return ErrorDisplay(
        failure: state.failure,
        onRetry: () => context.read<FolderContentBloc>().add(
          LoadFolderContent(folderId: folderId)
        ),
      );
    }

    return const MediaGridSkeleton();
  }

  Widget _buildContent(
    BuildContext context, {
    required Folder folder,
    required List<Folder> subfolders,
    required List<GalleryFile> files,
    required List<FileDateGroup> groupedFiles,
    required int totalFilesCount,
    required FileFilter filter,
    required bool hasMoreFiles,
    required bool isLoadingMore,
    required bool isSelectionMode,
    required Set<String> selectedFileIds,
  }) {

    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<FolderContentBloc>();
    final isEmpty = files.isEmpty && subfolders.isEmpty && filter == FileFilter.all;

    return FilesGrid(
      groupedFiles: groupedFiles,
      hasNext: hasMoreFiles,
      isLoadingMore: isLoadingMore,
      isSelectionMode: isSelectionMode,
      selectedFileIds: selectedFileIds,
      onLoadMore: () => bloc.add(const LoadMoreFiles()),
      onRefresh: () => bloc.add(const RefreshFolderContent()),
      onSelect: () => bloc.add(const EnterSelectionMode()),
      leading: [
        if (!isSelectionMode) ...[
          SliverToBoxAdapter(child: _AlbumHeader(folder: folder, totalFilesCount: totalFilesCount)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SubfoldersSection(
                subfolders: subfolders,
                onFolderTap: (subfolder) => context.pushNamed(
                  RouteNames.folderContent,
                  pathParameters: {'folderId': subfolder.id},
                ),
                onCreate: () => CreateFolderModal.show(context, parentFolderId: folderId),
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilterPillBar<FileFilter>(
              items: [
                for (final f in filters) FilterPillItem(value: f, label: f.label(l10n)),
              ],
              selected: filter,
              onSelected: (f) => bloc.add(FilterFilesInFolder(filter: f)),
            ),
          ),
        ),
      ],
      emptyState: isEmpty
          ? EmptyState(
              icon: Symbols.photo_album_rounded,
              title: l10n.emptyFolder,
              message: l10n.emptyFolderDescription,
            )
          : files.isEmpty
              ? EmptyState(icon: Symbols.filter_alt_off_rounded, title: l10n.noFiles)
              : null,
      onFileTap: (file) {
        if (isSelectionMode) {
          bloc.add(ToggleFileSelection(file.id));
        } else {
          _navigateToFileDetail(context, files, files.indexWhere((f) => f.id == file.id), totalFilesCount);
        }
      },
      onFileLongPress: (file) {
        if (!isSelectionMode) {
          bloc.add(const EnterSelectionMode());
        }
        bloc.add(ToggleFileSelection(file.id));
      },
    );
  }

  void _navigateToFileDetail(BuildContext context, List<GalleryFile> files, int index, int totalFilesCount) {
    context.pushNamed(
      RouteNames.fileDetail,
      pathParameters: {'fileId': files[index].id},
      extra: {
        'files': files,
        'initialIndex': index,
        'totalFilesCount': totalFilesCount,
      },
    );
  }
}

/// Breadcrumbs, album name, item count and the months it covers.
class _AlbumHeader extends StatelessWidget {
  final Folder folder;
  final int totalFilesCount;

  const _AlbumHeader({required this.folder, required this.totalFilesCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final dateRange = FolderCard.dateRangeFor(folder, l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BreadcrumbsBar(
            currentFolder: folder,
            onNavigate: (parentId) {
              if (parentId == null) {
                context.pop();
              } else {
                context.pushReplacementNamed(RouteNames.folderContent, pathParameters: {'folderId': parentId});
              }
            },
          ),
          Semantics(
            header: true,
            child: Text(
              folder.name,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: p.ink),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [l10n.itemsCount(totalFilesCount), if (dateRange != null) dateRange].join(' · '),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
          ),
        ],
      ),
    );
  }
}
