import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';
import 'album_mosaic.dart';


/// "Cover" card under the album title: its mosaic, how many covers it has
/// (or that they are automatic) and "Edit".
class AlbumCoverCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback onEdit;

  const AlbumCoverCard({super.key, required this.folder, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final subtitle = folder.hasCustomCovers
        ? l10n.albumCoverCard(folder.coverFileIds.length)
        : l10n.albumCoverAuto;
    final radius = BorderRadius.circular(18);

    return Semantics(
      button: true,
      label: '${l10n.cover}, $subtitle, ${l10n.edit}',
      excludeSemantics: true,
      child: Material(
        color: p.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onEdit,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 52,
                  child: AlbumMosaic(fileIds: folder.mosaicFileIds, radius: 12, iconSize: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.cover, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink)),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(l10n.edit, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.accentInk)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
