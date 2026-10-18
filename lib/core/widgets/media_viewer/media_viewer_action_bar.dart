import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_radius.dart';
import '../app_context_menu.dart';
import 'media_viewer_thumbnail_strip.dart';

/// Bottom of the viewer, part of the viewer itself: full width on its black background, with a hairline above, the
/// thumbnail strip (when there is one) and the [actions].
class MediaViewerBottomPanel extends StatelessWidget {
  final Widget? strip;
  final Widget actions;

  const MediaViewerBottomPanel({super.key, this.strip, required this.actions});

  /// Height above the safe area, without the strip: under a video, its own controls stay above the panel.
  static const double heightWithoutStrip = _topPadding + MediaViewerActionBar.height + _bottomPadding + 1;

  /// Extra height of the strip and its gap.
  static const double stripHeight = MediaViewerThumbnailStrip.height + _stripGap;

  static const double _topPadding = 12;
  static const double _stripGap = 8;
  static const double _bottomPadding = 4;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.media,
        border: Border(top: BorderSide(color: p.mediaChromeRaised)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: _topPadding, bottom: _bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (strip case final strip?) ...[strip, const SizedBox(height: _stripGap)],
              actions,
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of actions of the viewer ([MediaViewerAction]), without a background of its own.
class MediaViewerActionBar extends StatelessWidget {
  static const double height = 60;

  final List<Widget> children;

  const MediaViewerActionBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: height),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: children),
      ),
    );
  }
}

/// Action of [MediaViewerActionBar]: icon + label.
class MediaViewerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  /// Main action of the viewer (Save, Restore): icon and label in the accent of the viewer.
  final bool highlighted;

  /// Icon fill (1 = filled), label weight and icon scale, for toggles like Favorite.
  final double? iconFill;
  final Color? iconColor;
  final FontWeight labelWeight;
  final double iconScale;

  const MediaViewerAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.highlighted = false,
    this.iconFill,
    this.iconColor,
    this.labelWeight = FontWeight.w700,
    this.iconScale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final foreground = color ?? (highlighted ? p.mediaAccent : p.onMedia);
    final radius = BorderRadius.circular(AppRadius.button);

    return Opacity(
      // Disabled actions stay visible but dimmed (e.g. «On phone» when the file is already here)
      opacity: onPressed == null ? 0.45 : 1,
      child: Material(
        color: p.accent.withValues(alpha: 0),
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 28,
                    child: Transform.scale(
                      scale: iconScale,
                      child: Icon(icon, size: 24, color: iconColor ?? foreground, fill: iconFill),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: labelWeight, color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// «More» action of [MediaViewerActionBar]: opens a menu above it with [items].
class MediaViewerMoreAction extends StatelessWidget {
  final String label;
  final List<MediaViewerMenuItem> items;

  const MediaViewerMoreAction({super.key, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return MediaViewerAction(
      icon: Symbols.more_horiz_rounded,
      label: label,
      onPressed: () async {
        final box = context.findRenderObject() as RenderBox;
        final selected = await showAppContextMenu<MediaViewerMenuItem>(
          context,
          position: box.localToGlobal(box.size.topRight(Offset.zero)),
          items: [
            for (final item in items)
              AppMenuItem(value: item, label: item.label, icon: item.icon, destructive: item.destructive),
          ],
        );
        selected?.onSelected();
      },
    );
  }
}

/// Option of [MediaViewerMoreAction].
class MediaViewerMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool destructive;

  const MediaViewerMenuItem({required this.icon, required this.label, required this.onSelected,
    this.destructive = false});
}


/// "Cover" action of the album viewer: in the accent of the viewer, filled, when the photo is a cover of an album.
class MediaViewerCoverAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isCover;

  const MediaViewerCoverAction({super.key, required this.label, required this.onPressed, this.isCover = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return MediaViewerAction(
      icon: Symbols.auto_awesome_mosaic_rounded,
      label: label,
      onPressed: onPressed,
      iconFill: isCover ? 1 : 0,
      color: isCover ? p.mediaAccent : null,
      labelWeight: isCover ? FontWeight.w800 : FontWeight.w700,
    );
  }
}
