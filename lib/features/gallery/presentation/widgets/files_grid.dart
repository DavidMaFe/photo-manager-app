import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/file_thumbnail_card.dart';

import '../../../../l10n/app_localizations.dart';


class FilesGrid extends StatefulWidget {

  final List<GalleryFile> files;
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
    required this.files,
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

    if(widget.files.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1
        ),
        itemCount: widget.files.length + (widget.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.files.length) {
            return _buildLoadingIndicator();
          }

          final file = widget.files[index];
          return FileThumbnailCard(
            file: file,
            isSelectionMode: widget.isSelectionMode,
            isSelected: widget.selectedFileIds.contains(file.id),
            onTap: widget.onFileTap != null ? () => widget.onFileTap!(file) : null,
            onLongPress: widget.onFileLongPress != null ? () => widget.onFileLongPress!(file) : null,
          );
        },
      ),
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