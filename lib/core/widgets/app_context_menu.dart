import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';

/// Entry of [showAppContextMenu].
class AppMenuItem<T> {
  final T value;
  final String label;
  final IconData icon;
  final bool destructive;

  const AppMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.destructive = false,
  });
}

/// Context menu (radius 18, soft shadow) anchored at [position] in global
/// coordinates, e.g. from a long press.
Future<T?> showAppContextMenu<T>(
  BuildContext context, {
  required Offset position,
  required List<AppMenuItem<T>> items,
}) {
  final p = context.palette;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    ),
    color: p.surface,
    surfaceTintColor: p.surface.withValues(alpha: 0),
    elevation: 8,
    shadowColor: p.shadow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    items: [
      for (final item in items)
        PopupMenuItem<T>(
          value: item.value,
          height: 48,
          child: Row(
            children: [
              Icon(item.icon, size: 22, color: item.destructive ? p.danger : p.ink2),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: item.destructive ? p.dangerInk : p.ink,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
