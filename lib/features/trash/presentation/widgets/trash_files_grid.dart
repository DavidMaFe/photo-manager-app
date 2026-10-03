import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_file_card.dart';

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
    return Stack(
      children: [
        RefreshIndicator(
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
              childAspectRatio: 1,
            ),
            itemCount: widget.files.length + (widget.hasNext ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.files.length) {
                return _buildLoadingIndicator();
              }

              final file = widget.files[index];
              return TrashFileCard(
                file: file,
                isSelectionMode: widget.isSelectionMode,
                isSelected: widget.selectedFileIds.contains(file.id),
                onTap: widget.onFileTap != null
                    ? () => widget.onFileTap!(file)
                    : null,
                onLongPress: widget.onFileLongPress != null
                    ? () => widget.onFileLongPress!(file)
                    : null,
              );
            },
          ),
        ),
        if (widget.isProcessing)
          Container(
            color: context.palette.media.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
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
