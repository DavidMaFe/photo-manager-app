import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_radius.dart';

/// Floating dark action bar at the bottom of the viewer.
class MediaViewerActionBar extends StatelessWidget {
  static const double height = 72;

  final List<Widget> children;

  const MediaViewerActionBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(minHeight: height),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: p.mediaChrome,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(children: children),
    );
  }
}

/// Action of [MediaViewerActionBar]: icon + label, optionally as an accent pill.
class MediaViewerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  /// Accent pill (main action).
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
    final foreground = highlighted ? p.onAccent : (color ?? p.onMedia);
    final radius = BorderRadius.circular(AppRadius.button);

    return Material(
      color: highlighted ? p.accent : p.accent.withValues(alpha: 0),
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56, minWidth: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: iconScale,
                  child: Icon(icon, size: 22, color: iconColor ?? foreground, fill: iconFill),
                ),
                const SizedBox(height: 2),
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
    );
  }
}
