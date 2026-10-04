import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';

/// Thumbnails above the viewer action bar, kept in sync with the page view.
/// The current item is 46×46 with a white border; the rest are 34×46 at 60 %.
class MediaViewerThumbnailStrip extends StatefulWidget {
  static const double height = 46;
  static const double itemWidth = 34;
  static const double gap = 4;

  final int itemCount;
  final int currentIndex;
  final Widget Function(BuildContext context, int index) thumbnailBuilder;
  final ValueChanged<int> onSelected;

  const MediaViewerThumbnailStrip({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    required this.thumbnailBuilder,
    required this.onSelected,
  });

  @override
  State<MediaViewerThumbnailStrip> createState() => _MediaViewerThumbnailStripState();
}

class _MediaViewerThumbnailStripState extends State<MediaViewerThumbnailStrip> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerCurrent(animate: false));
  }

  @override
  void didUpdateWidget(covariant MediaViewerThumbnailStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerCurrent(animate: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _centerCurrent({required bool animate}) {
    if (!mounted || !_controller.hasClients) return;
    const step = MediaViewerThumbnailStrip.itemWidth + MediaViewerThumbnailStrip.gap;
    final viewport = _controller.position.viewportDimension;
    final target = (widget.currentIndex * step + MediaViewerThumbnailStrip.height / 2 - viewport / 2)
        .clamp(0.0, _controller.position.maxScrollExtent);
    if (animate) {
      _controller.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _controller.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: MediaViewerThumbnailStrip.height,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: MediaViewerThumbnailStrip.gap),
        itemBuilder: (context, index) {
          final current = index == widget.currentIndex;
          return GestureDetector(
            onTap: () => widget.onSelected(index),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: current ? 1 : 0.6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: current ? MediaViewerThumbnailStrip.height : MediaViewerThumbnailStrip.itemWidth,
                height: MediaViewerThumbnailStrip.height,
                decoration: BoxDecoration(
                  color: p.mediaChromeRaised,
                  borderRadius: BorderRadius.circular(current ? 8 : 6),
                  border: current ? Border.all(color: p.onMedia, width: 2) : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.thumbnailBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}
