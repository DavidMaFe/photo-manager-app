import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../config/theme/app_palette.dart';
import 'app_card.dart';

/// Fila de lista dentro de una [AppCard] (sustituye a ProfileMenuItem).
class ListRow extends StatelessWidget {
  /// Sangría del divisor entre filas: padding 16 + icono 22 + gap 14.
  static const double dividerIndent = 52;

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const ListRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.value,
    this.trailing,
    bool? showChevron,
    this.onTap,
  }) : showChevron = showChevron ?? (onTap != null && trailing == null);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: iconColor ?? p.accent),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? p.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value!,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(Symbols.chevron_right_rounded, size: 22, color: p.ink3),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// Grupo de [ListRow] en una [AppCard] con divisores `lineSoft` sangrados.
class ListRowGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const ListRowGroup({super.key, required this.children, this.margin});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(const Divider(indent: ListRow.dividerIndent));
      }
      items.add(children[i]);
    }
    return AppCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(mainAxisSize: MainAxisSize.min, children: items),
    );
  }
}
