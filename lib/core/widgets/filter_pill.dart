import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

/// Pastilla de filtro (alto 36). Seleccionada: fondo ink.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Contador opcional (círculo 20 px de color review).
  final int? count;

  /// Icono opcional delante del texto (p. ej. el corazón de «Favoritas»).
  final IconData? icon;
  final Color? iconColor;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.count,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final background = selected ? p.ink : p.surface2;
    final foreground = selected ? p.surface : p.ink;
    final radius = BorderRadius.circular(AppRadius.pill);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 17, color: iconColor ?? foreground, fill: 1),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    label,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: foreground),
                  ),
                  if (count != null && count! > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.review,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        count! > 99 ? '99+' : '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: p.onReview,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Elemento de [FilterPillBar].
class FilterPillItem<T> {
  final T value;
  final String label;
  final int? count;
  final IconData? icon;
  final Color? iconColor;

  const FilterPillItem({required this.value, required this.label, this.count, this.icon, this.iconColor});
}

/// Barra horizontal de [FilterPill] con scroll (sustituye FilterChips y FolderFilterChips).
class FilterPillBar<T> extends StatelessWidget {
  final List<FilterPillItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterPillBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            FilterPill(
              label: items[i].label,
              count: items[i].count,
              icon: items[i].icon,
              iconColor: items[i].iconColor,
              selected: items[i].value == selected,
              onTap: () => onSelected(items[i].value),
            ),
          ],
        ],
      ),
    );
  }
}
