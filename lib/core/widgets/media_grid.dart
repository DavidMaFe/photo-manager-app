import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_spacing.dart';

/// Grupo de fecha de [MediaGrid].
class MediaGridGroup {
  /// «Hoy», «Ayer», «Septiembre»…
  final String title;

  /// Fecha corta («jue, 1 oct»).
  final String? subtitle;
  final int itemCount;

  /// Acción opcional a la derecha («Seleccionar»).
  final String? actionLabel;
  final VoidCallback? onAction;

  const MediaGridGroup({
    required this.title,
    this.subtitle,
    required this.itemCount,
    this.actionLabel,
    this.onAction,
  });
}

/// Rejilla de 3 columnas agrupada por fecha. La primera miniatura de cada
/// grupo ocupa 2×2.
///
/// Es un *sliver*: va dentro de un `CustomScrollView`.
class MediaGrid extends StatelessWidget {
  static const int columns = 3;

  final List<MediaGridGroup> groups;
  final Widget Function(BuildContext context, int groupIndex, int itemIndex) itemBuilder;

  const MediaGrid({super.key, required this.groups, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        for (var g = 0; g < groups.length; g++) ...[
          SliverToBoxAdapter(child: MediaGroupHeader(group: groups[g])),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gridGap),
            sliver: SliverList.builder(
              itemCount: rowCount(groups[g].itemCount),
              itemBuilder: (context, row) => _buildRow(context, g, row),
            ),
          ),
        ],
      ],
    );
  }

  /// Filas de un grupo: la primera contiene hasta 3 elementos (1 grande + 2
  /// pequeños apilados) y el resto, 3 por fila.
  static int rowCount(int itemCount) {
    if (itemCount <= 0) return 0;
    if (itemCount <= 3) return 1;
    return 1 + ((itemCount - 3) / columns).ceil();
  }

  Widget _buildRow(BuildContext context, int group, int row) {
    const gap = AppSpacing.gridGap;
    final total = groups[group].itemCount;
    Widget cell(int index) => index < total
        ? AspectRatio(aspectRatio: 1, child: itemBuilder(context, group, index))
        : const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());

    if (row == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: gap),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final small = (constraints.maxWidth - gap * (columns - 1)) / columns;
            final big = small * 2 + gap;
            return SizedBox(
              height: big,
              child: Row(
                children: [
                  SizedBox.square(dimension: big, child: itemBuilder(context, group, 0)),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: small,
                    child: Column(
                      children: [
                        SizedBox.square(
                          dimension: small,
                          child: total > 1 ? itemBuilder(context, group, 1) : null,
                        ),
                        const SizedBox(height: gap),
                        SizedBox.square(
                          dimension: small,
                          child: total > 2 ? itemBuilder(context, group, 2) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    final start = 3 + (row - 1) * columns;
    return Padding(
      padding: const EdgeInsets.only(bottom: gap),
      child: Row(
        children: [
          for (var c = 0; c < columns; c++) ...[
            if (c > 0) const SizedBox(width: gap),
            Expanded(child: cell(start + c)),
          ],
        ],
      ),
    );
  }
}

/// Cabecera de grupo: título de sección + fecha corta + acción opcional.
class MediaGroupHeader extends StatelessWidget {
  final MediaGridGroup group;

  const MediaGroupHeader({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Semantics(
            header: true,
            child: Text(group.title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (group.subtitle != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ),
          ] else
            const Spacer(),
          if (group.actionLabel != null)
            TextButton(
              onPressed: group.onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              child: Text(group.actionLabel!),
            ),
        ],
      ),
    );
  }
}
