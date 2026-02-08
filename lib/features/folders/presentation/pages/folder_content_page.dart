import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/breadcrumbs_bar.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/subfolders_section.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/date_section_header.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/file_thumbnail_card.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/filter_chips.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FolderContentPage extends StatefulWidget {

  final String folderId;

  const FolderContentPage({super.key, required this.folderId});

  @override
  State<FolderContentPage> createState() => _FolderContentPageState();
}

class _FolderContentPageState extends State<FolderContentPage> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {

    final state = context.read<FolderContentBloc>().state;

    if (state is! FolderContentLoaded) return;
    if (!state.hasMoreFiles) return;
    if (state is FolderContentLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.9) {
      context.read<FolderContentBloc>().add(const LoadMoreFiles());
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<FolderContentBloc, FolderContentState>(
          builder: (context, state) {

            final isSelectionMode = state is FolderContentLoaded && state.isSelectionMode;
            final selectedCount = isSelectionMode ? state.selectedFileIds.length : 0;

            return Scaffold(
              appBar: _buildAppBar(context, state, isSelectionMode, selectedCount),
              body: Column(
                children: [
                  _buildFilters(context, state),
                  _buildSubfolders(context, state),
                  Expanded(child: _buildMainContent(context, state))
                ],
              ),
              floatingActionButton: _buildFAB(context, state, isSelectionMode, selectedCount),
            );
          }
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, FolderContentState state, bool isSelectionMode, int selectedCount) {

    final l10n = AppLocalizations.of(context)!;

    if (isSelectionMode) {
      final areAllFilesSelected = state is FolderContentLoaded && state.areAllFilesSelected;

      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            context.read<FolderContentBloc>().add(const ExitSelectionMode());
          },
        ),
        title: Text(selectedCount == 1 ? l10n.selectedFilesSingle : l10n.selectedFiles(selectedCount)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: PhotoManagerColors.primary.withValues(alpha: 0.1),
        actions: [
          if (areAllFilesSelected)
            TextButton.icon(
              onPressed: () {
                context.read<FolderContentBloc>().add(const DeselectAllFiles());
              },
              icon: const Icon(Icons.deselect, size: 20),
              label: Text(l10n.deselectAll),
              style: TextButton.styleFrom(
                foregroundColor: PhotoManagerColors.primary
              ),
            )
          else
            TextButton.icon(
              onPressed: () {
                context.read<FolderContentBloc>().add(const SelectAllFiles());
              },
              icon: const Icon(Icons.select_all, size: 20),
              label: Text(l10n.selectAll),
              style: TextButton.styleFrom(
                foregroundColor: PhotoManagerColors.primary
              ),
            ),
          const SizedBox(width: 8)
        ],
      );
    }

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: BlocBuilder<FolderContentBloc, FolderContentState>(
        builder: (context, state) {
          if (state is FolderContentLoaded) {
            return BreadcrumbsBar(
              currentFolder: state.currentFolder,
              onNavigate: (folderId) {
                if(folderId == null) {
                  context.pop();
                } else {
                  context.pushReplacementNamed(
                      RouteNames.folderContent,
                      pathParameters: {'folderId': folderId}
                  );
                }
              },
            );
          }

          if (state is FolderContentLoading && state.previousFolder != null) {
            return BreadcrumbsBar(
              currentFolder: state.previousFolder!,
              onNavigate: (folderId) {
                if(folderId == null) {
                  context.pop();
                } else {
                  context.pushReplacementNamed(
                      RouteNames.folderContent,
                      pathParameters: {'folderId': folderId}
                  );
                }
              },
            );
          }
          return Text(l10n.folder);
        },
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildMainContent(BuildContext context, FolderContentState state) {

    if (state is FolderContentLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    if (state is FolderContentLoaded) {
      return _buildContent(context, state);
    }

    if (state is FolderContentLoadingMore) {
      return _buildContentWithLoadingMore(context, state);
    }

    if (state is FolderContentError) {
      final l10n = AppLocalizations.of(context)!;
      return _buildErrorState(context, state, l10n);
    }

    return SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, FolderContentLoaded state) {

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FolderContentBloc>().add(const RefreshFolderContent());
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (state.groupedFiles.isNotEmpty)
            ..._buildGroupedFileSlivers(context, state),
          if (state.hasMoreFiles)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (state.subfolders.isEmpty && state.files.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(context),
            )
        ],
      ),
    );
  }

  List<Widget> _buildGroupedFileSlivers(BuildContext context, FolderContentLoaded state) {
    final slivers = <Widget>[];
    final l10n = AppLocalizations.of(context)!;

    // Build month names array
    final monthNames = [
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december,
    ];

    // Relabel groups with localized strings
    final localizedGroups = DateGroupingUtil.relabelGroups(
      state.groupedFiles,
      todayLabel: l10n.today,
      yesterdayLabel: l10n.yesterday,
      thisWeekLabel: l10n.thisWeek,
      lastWeekLabel: l10n.lastWeek,
      monthNames: monthNames,
    );

    for (final group in localizedGroups) {
      // Add header for the date
      slivers.add(
        SliverPersistentHeader(
          pinned: false,
          delegate: DateSectionHeaderDelegate(label: group.label),
        ),
      );

      // Add grid for files in this date group
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final file = group.files[index];
                final fileIndexInAllFiles = state.files.indexWhere((f) => f.id == file.id);
                return FileThumbnailCard(
                  file: file,
                  isSelectionMode: state.isSelectionMode,
                  isSelected: state.selectedFileIds.contains(file.id),
                  onTap: () {
                    if (state.isSelectionMode) {
                      context.read<FolderContentBloc>().add(ToggleFileSelection(file.id));
                    } else {
                      _navigateToFileDetail(context, state.files, fileIndexInAllFiles);
                    }
                  },
                  onLongPress: () {
                    if (!state.isSelectionMode) {
                      context.read<FolderContentBloc>().add(const EnterSelectionMode());
                    }
                    context.read<FolderContentBloc>().add(ToggleFileSelection(file.id));
                  },
                );
              },
              childCount: group.files.length,
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  Widget _buildFilters(BuildContext context, FolderContentState state) {

    FileFilter currentFilter = FileFilter.all;

    if (state is FolderContentLoaded) {
      currentFilter = state.currentFilter;
    } else if (state is FolderContentLoadingMore) {
      currentFilter = state.currentFilter;
    }

    return FilterChips(
      selectedFilter: currentFilter,
      onFilterSelected: (filter) {
        context.read<FolderContentBloc>().add(
            FilterFilesInFolder(filter: filter)
        );
      },
    );
  }

  Widget _buildSubfolders(BuildContext context, FolderContentState state) {

    List<Folder> subfolders = [];

    if (state is FolderContentLoading) {
      subfolders = state.previousSubfolders ?? [];
    } else if (state is FolderContentLoaded) {
      subfolders = state.subfolders;
    } else if (state is FolderContentLoadingMore) {
      subfolders = state.subfolders;
    }

    if (subfolders.isEmpty) {
      return const SizedBox.shrink();
    }

    return SubfoldersSection(
      subfolders: subfolders,
      onFolderTap: (subfolder) {
        context.pushNamed(
            RouteNames.folderContent,
            pathParameters: {'folderId': subfolder.id}
        );
      },
    );
  }

  Widget _buildContentWithLoadingMore(BuildContext context, FolderContentLoadingMore state) {

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1
            ),
            delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final file = state.files[index];
                  return FileThumbnailCard(
                    file: file,
                    isSelectionMode: false,
                    isSelected: false,
                    onTap: () => _navigateToFileDetail(context, state.files, index),
                  );
                },
                childCount: state.files.length
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey.shade400
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyFolder,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyFolderDescription,
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

  Widget _buildErrorState(BuildContext context, FolderContentError state, AppLocalizations l10n) {
    return ErrorDisplay(
      failure: state.failure,
      onRetry: () => context.read<FolderContentBloc>().add(
        LoadFolderContent(folderId: widget.folderId)
      ),
    );
  }

  Widget _buildFAB(BuildContext context, FolderContentState state, bool isSelectionMode, int selectedCount) {
    
    final l10n = AppLocalizations.of(context)!;
    
    if (isSelectionMode && selectedCount > 0) {
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
          onPressed: () => _showManageModal(context, (state as FolderContentLoaded).selectedFileIds.toList()),
          backgroundColor: PhotoManagerColors.primary,
          elevation: 0,
          icon: const Icon(Icons.tune, size: 22, color: Colors.white),
          label: Text(
            selectedCount == 1 ? l10n.manageSingleFile : l10n.manageMultipleFiles(selectedCount),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15
            ),
          ),
        ),
      );
    }
    
    return FloatingActionButton(
        onPressed: () => _showCreateModal(context),
        backgroundColor: PhotoManagerColors.primary,
        child: const Icon(Icons.add, color: Colors.white)
    );
  }

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => BlocProvider.value(
          value: context.read<FolderBloc>(),
          child: CreateFolderModal(parentFolderId: widget.folderId),
        )
    );
  }

  void _showManageModal(BuildContext context, List<String> fileIds) async {
    await showModalBottomSheet<bool>(
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
    );

    if (!context.mounted) return;

    // Exit selection mode after modal is dismissed (regardless of result)
    context.read<FolderContentBloc>().add(const ExitSelectionMode());
  }

  void _navigateToFileDetail(BuildContext context, List<GalleryFile> files, int index) {
    context.pushNamed(
      RouteNames.fileDetail,
      pathParameters: {'fileId': files[index].id},
      extra: {
        'files': files,
        'initialIndex': index,
      },
    );
  }
}