import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../config/theme/app_palette.dart';
import '../icon_circle_button.dart';

/// Top bar of the photo/video viewer: back, title + subtitle and actions over a
/// black gradient for legibility.
class MediaViewerTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback onBack;

  const MediaViewerTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.media.withValues(alpha: 0.4), p.media.withValues(alpha: 0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          child: Row(
            children: [
              MediaViewerIconButton(
                icon: Symbols.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.onMedia),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: p.onMedia.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              for (final action in actions) ...[const SizedBox(width: 8), action],
            ],
          ),
        ),
      ),
    );
  }
}

/// Round icon button for the dark viewer chrome (white 12 % background).
class MediaViewerIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const MediaViewerIconButton({super.key, required this.icon, required this.tooltip, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconCircleButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
      backgroundColor: p.onMedia.withValues(alpha: 0.12),
      foregroundColor: p.onMedia,
    );
  }
}

/// "To review" pill for the dark viewer chrome.
class MediaViewerReviewPill extends StatelessWidget {
  final String label;

  const MediaViewerReviewPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: p.review.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: p.review, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.mediaReview)),
        ],
      ),
    );
  }
}

/// "Cover of {album}" pill under the viewer header.
class MediaViewerCoverPill extends StatelessWidget {
  final String label;

  const MediaViewerCoverPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: p.mediaCoverSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.auto_awesome_mosaic_rounded, size: 16, fill: 1, color: p.mediaCover),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.mediaCover)),
        ],
      ),
    );
  }
}
