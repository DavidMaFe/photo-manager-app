import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_spacing.dart';
import 'package:photo_manager_app/core/widgets/media_grid.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_file_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Trash grid: retention notice, then "Deleted soon" and "This month" groups.
class TrashFilesGrid extends StatefulWidget {
  final List<TrashFile> files;
  final bool hasNext;
  final bool isLoadingMore;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;
  final bool isProcessing;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;
  final ValueChanged<TrashFile>? onFileTap;
  final ValueChanged<TrashFile>? onFileLongPress;

  /// Extra space at the bottom (selection action bar).
  final double bottomPadding;

  const TrashFilesGrid({
    super.key,
    required this.files,
    required this.hasNext,
    required this.isLoadingMore,
    required this.isSelectionMode,
    required this.selectedFileIds,
    this.isProcessing = false,
    required this.onLoadMore,
    required this.onRefresh,
    this.onFileTap,
    this.onFileLongPress,
    this.bottomPadding = 24,
  });

  @override
  State<TrashFilesGrid> createState() => _TrashFilesGridState();
}

class _TrashFilesGridState extends State<TrashFilesGrid> {
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
    final soon = widget.files.where(TrashFileCard.isDeletedSoon).toList();
    final later = widget.files.where((f) => !TrashFileCard.isDeletedSoon(f)).toList();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            widget.onRefresh();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (!widget.isSelectionMode) const SliverToBoxAdapter(child: _RetentionNotice()),
              if (soon.isNotEmpty) ..._group(l10n.deletingSoon, soon),
              if (later.isNotEmpty) ..._group(l10n.thisMonth, later),
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
        ),
        if (widget.isProcessing)
          Positioned.fill(
            child: ColoredBox(
              color: context.palette.background.withValues(alpha: 0.6),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
      ],
    );
  }

  List<Widget> _group(String title, List<TrashFile> files) {
    return [
      SliverToBoxAdapter(child: MediaGroupHeader(group: MediaGridGroup(title: title, itemCount: files.length))),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gridGap),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.gridGap,
            mainAxisSpacing: AppSpacing.gridGap,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return TrashFileCard(
              key: ValueKey(file.id),
              file: file,
              isSelectionMode: widget.isSelectionMode,
              isSelected: widget.selectedFileIds.contains(file.id),
              onTap: widget.onFileTap != null ? () => widget.onFileTap!(file) : null,
              onLongPress: widget.onFileLongPress != null ? () => widget.onFileLongPress!(file) : null,
            );
          },
        ),
      ),
    ];
  }
}

/// "Items are deleted forever after 30 days…" notice.
class _RetentionNotice extends StatelessWidget {
  const _RetentionNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Symbols.auto_delete_rounded, size: 22, color: p.ink2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.trashInfo,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
