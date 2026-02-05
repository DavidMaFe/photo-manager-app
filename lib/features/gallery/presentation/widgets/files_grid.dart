import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/date_section_header.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/file_thumbnail_card.dart';

import '../../../../l10n/app_localizations.dart';


class FilesGrid extends StatefulWidget {

  final List<FileDateGroup> groupedFiles;
  final bool hasNext;
  final bool isLoadingMore;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;
  final ValueChanged<GalleryFile>? onFileTap;
  final ValueChanged<GalleryFile>? onFileLongPress;

  const FilesGrid({
    super.key,
    required this.groupedFiles,
    required this.hasNext,
    required this.isLoadingMore,
    required this.isSelectionMode,
    required this.selectedFileIds,
    required this.onLoadMore,
    required this.onRefresh,
    this.onFileTap,
    this.onFileLongPress
  });

  @override
  State<FilesGrid> createState() => _FilesGridState();
}


class _FilesGridState extends State<FilesGrid> {

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

    if (widget.isLoadingMore) return;
    if (!widget.hasNext) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.9) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    if(widget.groupedFiles.isEmpty) {
      return _buildEmptyState(l10n);
    }

    // Build month names array
    final monthNames = [
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december,
    ];

    // Relabel groups with localized strings
    final localizedGroups = DateGroupingUtil.relabelGroups(
      widget.groupedFiles,
      todayLabel: l10n.today,
      yesterdayLabel: l10n.yesterday,
      thisWeekLabel: l10n.thisWeek,
      lastWeekLabel: l10n.lastWeek,
      monthNames: monthNames,
    );

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          ..._buildGroupedSlivers(localizedGroups),
          if (widget.hasNext) _buildLoadingSliver(),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedSlivers(List<FileDateGroup> groups) {
    final slivers = <Widget>[];

    for (final group in groups) {
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
                return FileThumbnailCard(
                  file: file,
                  isSelectionMode: widget.isSelectionMode,
                  isSelected: widget.selectedFileIds.contains(file.id),
                  onTap: widget.onFileTap != null ? () => widget.onFileTap!(file) : null,
                  onLongPress: widget.onFileLongPress != null ? () => widget.onFileLongPress!(file) : null,
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

  Widget _buildLoadingSliver() {
    return SliverToBoxAdapter(
      child: _buildLoadingIndicator(),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey.shade400
          ),
          const SizedBox(height: 16),
          Text(l10n.noFiles, style: TextStyle(
            fontSize: 16, color: Colors.grey.shade600,
            fontWeight: FontWeight.w500
          )),
          const SizedBox(height: 8),
          Text(l10n.syncToHaveFiles, style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500
          ), textAlign: TextAlign.center)
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}