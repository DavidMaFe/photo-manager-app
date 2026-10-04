import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/core/widgets/media_grid.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
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

  /// "Select" action of each date header (hidden in selection mode).
  final VoidCallback? onSelect;

  /// Content shown when there are no files.
  final Widget? emptyState;

  /// "Favorites" filter: thumbnails of files no longer favorite fade out
  /// before the bloc removes them.
  final bool fadeOutUnfavorited;

  /// Album being viewed: its covers show the «Cover» badge.
  final String? coverOfFolderId;

  /// Slivers placed above the grid (e.g. the review card).
  final List<Widget> leading;

  final double bottomPadding;

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
    this.onFileLongPress,
    this.onSelect,
    this.emptyState,
    this.fadeOutUnfavorited = false,
    this.coverOfFolderId,
    this.leading = const [],
    this.bottomPadding = 24,
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
    final groups = _localizedGroups(l10n);

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ...widget.leading,
          if (groups.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: widget.emptyState ?? const SizedBox())
          else
            MediaGrid(
              groups: [
                for (final group in groups)
                  MediaGridGroup(
                    title: group.label,
                    subtitle: _shortDate(group, l10n),
                    itemCount: group.files.length,
                    actionLabel: widget.isSelectionMode || widget.onSelect == null ? null : l10n.select,
                    onAction: widget.onSelect,
                  ),
              ],
              itemBuilder: (context, g, i) {
                final file = groups[g].files[i];
                return FileThumbnailCard(
                  key: ValueKey(file.id),
                  file: file,
                  isSelectionMode: widget.isSelectionMode,
                  isSelected: widget.selectedFileIds.contains(file.id),
                  showFavorite: AppConfig.favoritesAndCoversEnabled,
                  large: i == 0,
                  leaving: widget.fadeOutUnfavorited && !file.isFavorite,
                  isCover: AppConfig.favoritesAndCoversEnabled &&
                      widget.coverOfFolderId != null &&
                      file.isCoverOf(widget.coverOfFolderId!),
                  onTap: widget.onFileTap != null ? () => widget.onFileTap!(file) : null,
                  onLongPress: widget.onFileLongPress != null ? () => widget.onFileLongPress!(file) : null,
                );
              },
            ),
          if (widget.hasNext)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: widget.bottomPadding + MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }

  List<FileDateGroup> _localizedGroups(AppLocalizations l10n) {
    final monthNames = [
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december,
    ];

    return DateGroupingUtil.relabelGroups(
      widget.groupedFiles,
      todayLabel: l10n.today,
      yesterdayLabel: l10n.yesterday,
      thisWeekLabel: l10n.thisWeek,
      lastWeekLabel: l10n.lastWeek,
      monthNames: monthNames,
      noDateLabel: l10n.noDate,
    );
  }

  /// Short date ("Thu, Oct 1") next to the "Today"/"Yesterday" headers.
  String? _shortDate(FileDateGroup group, AppLocalizations l10n) {
    final date = group.date;
    if (date == null) return null;
    final day = DateGroupingUtil.normalizeDateToDay(date);
    final today = DateGroupingUtil.normalizeDateToDay(DateTime.now());
    final isDayGroup = day == today || day == today.subtract(const Duration(days: 1));
    if (!isDayGroup) return null;
    return DateFormat.MMMEd(l10n.localeName).format(date);
  }
}
